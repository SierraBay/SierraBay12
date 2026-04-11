// Research Report Compilation System
// Scientists compile their current tech level progress into sellable data disks

// R&D Sales Invoice — printed from R&D console, placed in cargo crate
// When cargo sells the crate, all earnings are redirected to the account specified in this invoice
/obj/item/paper/manifest/rnd_invoice
	name = "R&D sales invoice"
	icon_state = "paper_words"
	item_state = "paper_words"
	desc = "An R&D department sales invoice. Place it in a cargo crate to have all sale proceeds credited to the specified account."
	var/target_account_number = null
	var/target_account_name = ""

/obj/item/paper/manifest/rnd_invoice/examine(mob/user)
	. = ..()
	if(target_account_number)
		to_chat(user, "Account: [target_account_name] (#[target_account_number])")
	else
		to_chat(user, "No account specified.")

/obj/item/disk/research_report
	name = "research data compilation"
	desc = "A compiled research report containing technological progress data. Valued by corporate R&D departments."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTIC = 30, MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)
	var/list/tech_data = list()   // list("Engineering" = 4, "Biotech" = 3, ...)
	var/delta_levels = 0          // New levels since last compilation
	var/cargo_value = 0           // Pre-calculated supply points value

/obj/item/disk/research_report/examine(mob/user)
	. = ..()
	to_chat(user, "Contains [delta_levels] new tech level\s of research data.")
	if(LAZYLEN(tech_data))
		for(var/tech_name in tech_data)
			to_chat(user, "  [tech_name]: level [tech_data[tech_name]]")
	to_chat(user, "Estimated cargo value: [cargo_value] thalers.")
