// ─── Away-site R&D consoles and accounts ────────────────────────────────────
// Away sites use a plain /obj/machinery/r_n_d/server placed on the map.
// It populates all 5 standard HDD categories (Autolathe/Medical/Exosuit/
// Electronics/Research) but has no System disk and no persistence.
// Set the server's network ID in-game via multitool to match the console ID.
//
// Console ID allocation:
//   1  = main station (Sierra)
//   2  = robotics (Sierra)
//   3  = public NTNet repo
//   10 = SRV Verne
//   11 = Colony

// ── Account keys ─────────────────────────────────────────────────────────────

#define ACCOUNT_VERNE   "Верне"
#define ACCOUNT_COLONY  "Колония"

// ── Account creation at game start ───────────────────────────────────────────

/hook/game_ready/proc/InitAwaySiteRnDAccounts()
	if(!(ACCOUNT_VERNE in department_accounts))
		department_accounts[ACCOUNT_VERNE] = create_account(
			"SRV Verne Science Account",
			ACCOUNT_VERNE,
			65000,
			ACCOUNT_TYPE_DEPARTMENT
		)
	if(!(ACCOUNT_COLONY in department_accounts))
		department_accounts[ACCOUNT_COLONY] = create_account(
			"Colony Science Account",
			ACCOUNT_COLONY,
			50000,
			ACCOUNT_TYPE_DEPARTMENT
		)
	// Fill in any map-spawned invoices. Must happen after accounts are created
	// because map object Initialize() runs before game_ready hooks.
	_init_away_invoices(/obj/item/paper/manifest/rnd_invoice/verne,  department_accounts[ACCOUNT_VERNE])
	_init_away_invoices(/obj/item/paper/manifest/rnd_invoice/colony, department_accounts[ACCOUNT_COLONY])
	return TRUE

/proc/_init_away_invoices(invoice_type, datum/money_account/A)
	if(!A)
		return
	for(var/obj/item/paper/manifest/rnd_invoice/P in world)
		if(P.type != invoice_type)
			continue
		P.target_account_number = A.account_number
		P.target_account_name   = A.account_name
		P.is_copy = FALSE
		if(!P.stamped)
			P.stamped = list()
		P.stamped |= /obj/machinery/computer/rdconsole

// ── SRV Verne console ────────────────────────────────────────────────────────

/obj/machinery/computer/rdconsole/verne
	name = "Verne R&D Control Console"
	id = 10
	department_account_key = ACCOUNT_VERNE
	can_switch_account = TRUE

// ── Colony console ────────────────────────────────────────────────────────────

/obj/machinery/computer/rdconsole/colony
	name = "Colony R&D Control Console"
	id = 11
	department_account_key = ACCOUNT_COLONY
	can_switch_account = TRUE

// ── Pre-filled invoices for away sites ───────────────────────────────────────
// Spawnable in the world (e.g. on Verne / colony) so crew knows the account
// number without having to print from the console first.
// target_account_number is filled by InitAwaySiteRnDAccounts() (game_ready hook).

/obj/item/paper/manifest/rnd_invoice/verne
	name = "SRV Verne R&D sales invoice"

/obj/item/paper/manifest/rnd_invoice/colony
	name = "Colony R&D sales invoice"
