// ===========================
//   CARP RACE ANNOUNCER
// ===========================

/// Dedicated radio announcer for the Entertainment channel.
/// global_announcer doesn't include "Entertainment", so we need our own.
/obj/item/device/radio/announcer/carp_racing
	channels = list("Entertainment" = 1)

GLOBAL_TYPED_NEW(carp_race_announcer, /obj/item/device/radio/announcer/carp_racing)

// ===========================
//   CARP RACE DATUM
// ===========================

/**
 * Manages a single carp race from betting → countdown → racing → finished.
 *
 * Lifecycle (driven by race_controller's Process()):
 *   IDLE → start_betting() → BETTING
 *   BETTING → start_countdown() → COUNTDOWN
 *   COUNTDOWN → start_race() → RACING
 *   RACING → carp_finished() → FINISHED
 *   FINISHED → reset_to_idle() → IDLE
 */
/datum/carp_race
	/// Current race state (RACE_STATE_*)
	var/state = RACE_STATE_IDLE
	/// Active racing carps (list of /mob/living/simple_animal/hostile/carp/racing)
	var/list/racers = list()
	/// Bets per carp: bets["1"] = assoc list[account_number -> amount]
	var/list/bets = list()
	/// Account numbers that have already placed a bet this race (no double-betting)
	var/list/bet_accounts = list()
	/// The first carp to cross the finish line
	var/mob/living/simple_animal/hostile/carp/racing/winner = null
	/// Parent controller machine
	var/obj/machinery/race_controller/linked_controller = null
	/// world.time when the current phase ends (used by the controller's Process())
	var/phase_end_time = 0
	/// Running total of all bets placed this race
	var/total_pool = 0
	/// Ghost bets per carp (index "1".."6"): simulated NPC bets for display only, not included in payouts
	var/list/ghost_bets = list()
	/// Sum of all ghost bets (display only)
	var/ghost_pool = 0
	/// Carps in the order they crossed the finish line (1st element = 1st place).
	/// Populated incrementally by carp_finished(); used for standings display and announce.
	var/list/finish_order = list()


/datum/carp_race/New(obj/machinery/race_controller/C)
	. = ..()
	linked_controller = C
	// Pre-allocate per-carp bet lists
	for(var/i = 1 to RACE_CARP_COUNT)
		bets["[i]"] = list()
		ghost_bets["[i]"] = 0


/datum/carp_race/Destroy()
	despawn_racers()
	bets.Cut()
	bet_accounts.Cut()
	racers.Cut()
	finish_order.Cut()
	. = ..()


// ---- Helpers ----

/// Despawn all racing carps currently on the track
/datum/carp_race/proc/despawn_racers()
	for(var/mob/living/simple_animal/hostile/carp/racing/C in racers)
		if(!QDELETED(C))
			qdel(C)
	racers.Cut()

/// Get total thalers bet on a specific carp slot number (includes ghost bets for display)
/datum/carp_race/proc/get_total_bets_on(carp_num)
	var/total = 0
	var/list/carp_bets = bets["[carp_num]"]
	if(islist(carp_bets))
		for(var/acc_num in carp_bets)
			total += carp_bets[acc_num]
	var/ghost = ghost_bets["[carp_num]"]
	if(ghost)
		total += ghost
	return total

/// Get the carp slot number that an account has bet on (0 = no bet placed)
/datum/carp_race/proc/get_bet_by_account(account_number)
	for(var/i = 1 to RACE_CARP_COUNT)
		var/list/cb = bets["[i]"]
		if(islist(cb) && ("[account_number]" in cb))
			return i
	return 0

/// Get the amount an account has bet (0 = no bet placed)
/datum/carp_race/proc/get_bet_amount_by_account(account_number)
	for(var/i = 1 to RACE_CARP_COUNT)
		var/list/carp_bets = bets["[i]"]
		if(islist(carp_bets) && ("[account_number]" in carp_bets))
			return carp_bets["[account_number]"]
	return 0


/// Send a message about the carp race to the entertainment radio channel (ENT_FREQ)
/datum/carp_race/proc/radio_announce(message)
	if(GLOB.carp_race_announcer)
		GLOB.carp_race_announcer.autosay("[message]", "Carp Races", "Entertainment")


// ---- State transitions ----

/**
 * Begin the betting phase.
 * Spawns racing carps at their start positions and opens bets.
 * @param start_turfs  Indexed list (1–6) of start turfs
 * @param finish       The finish-line turf
 */
/datum/carp_race/proc/start_betting(list/start_turfs, turf/finish)
	if(state != RACE_STATE_IDLE)
		return FALSE
	if(!finish || !length(start_turfs))
		return FALSE

	// Reset from previous race
	winner          = null
	total_pool      = 0
	ghost_pool      = 0
	bet_accounts.Cut()
	for(var/i = 1 to RACE_CARP_COUNT)
		bets["[i]"] = list()
		ghost_bets["[i]"] = 0
	despawn_racers()

	// Spawn carps at start positions
	for(var/i = 1 to RACE_CARP_COUNT)
		var/turf/start = (i <= length(start_turfs)) ? start_turfs[i] : null
		if(!start)
			break
		var/mob/living/simple_animal/hostile/carp/racing/C = new(start, i, src, finish)
		racers += C

	if(!length(racers))
		return FALSE

	state          = RACE_STATE_BETTING
	phase_end_time = world.time + RACE_BETTING_DURATION

	// Generate ghost bets: 4-9 simulated wagers spread across random carps.
	// These are added to total_pool, so they affect coefficients and payout size,
	// but no real account receives them — they just inflate the pot like bets from other station residents.
	var/list/ghost_amounts = list(50, 100, 100, 250, 250, 500, 500, 1000)
	for(var/g = 1 to rand(4, 9))
		var/tc = rand(1, RACE_CARP_COUNT)
		var/ga = pick(ghost_amounts)
		ghost_bets["[tc]"] += ga
		ghost_pool          += ga
		total_pool          += ga  // Ghost bets enter the real pool and affect payouts

	radio_announce("Betting is open! Place your bets at the terminal. Race starts in [round(RACE_BETTING_DURATION / (1 SECOND))] seconds.")
	return TRUE

/// Close bets and start the pre-race countdown
/datum/carp_race/proc/start_countdown()
	if(state != RACE_STATE_BETTING)
		return
	state          = RACE_STATE_COUNTDOWN
	phase_end_time = world.time + RACE_COUNTDOWN_DURATION
	radio_announce("Betting closed! Carps on the line. Watch the broadcast (network: Thunderdome)! Start in [round(RACE_COUNTDOWN_DURATION / (1 SECOND))] seconds.")

/// Start the race — carps begin moving
/datum/carp_race/proc/start_race()
	if(state != RACE_STATE_COUNTDOWN)
		return
	state          = RACE_STATE_RACING
	phase_end_time = world.time + RACE_MAX_DURATION  // Safety timeout
	radio_announce("START! Carps surge toward the finish line!")
	// All carps start simultaneously — one-tick delay so timers fire after initialization.
	for(var/mob/living/simple_animal/hostile/carp/racing/C in racers)
		if(!QDELETED(C))
			C.begin_racing(1)

/**
 * Called by a racing carp when it crosses the finish line.
 * Records placement in finish_order and announces position on radio.
 * Transitions to RACE_STATE_FINISHED only once every non-deleted carp has finished,
 * so the race stays alive long enough for all carps to cross.
 */
/datum/carp_race/proc/carp_finished(mob/living/simple_animal/hostile/carp/racing/C)
	if(state != RACE_STATE_RACING)
		return
	if(C.finished)
		return
	C.finished    = TRUE
	finish_order += C

	// The first carp to finish is the payout winner
	if(!winner)
		winner = C

	// Announce this carp's placement
	var/place     = LAZYLEN(finish_order)
	var/list/ord  = list("1st", "2nd", "3rd", "4th", "5th", "6th")
	var/place_str = (place >= 1 && place <= length(ord)) ? ord[place] : "[place]th"
	radio_announce("[place_str] to cross the finish line: Carp #[C.race_number] ([get_carp_color_name(C.race_number)])!")

	// Keep the race alive until every non-deleted carp has also finished
	for(var/mob/living/simple_animal/hostile/carp/racing/R in racers)
		if(!QDELETED(R) && !R.finished)
			return  // still waiting for other carps

	// All done — declare the race finished and pay out
	state          = RACE_STATE_FINISHED
	phase_end_time = world.time + RACE_RESET_DELAY
	announce_and_payout()

/// Announce the full race standings and distribute winnings to the winner's bettors.
/// Called after every carp finishes naturally or by force_end_race on timeout.
/datum/carp_race/proc/announce_and_payout()
	if(!winner)
		radio_announce("Race ended with no winner. Bets refunded.")
		refund_all()
		return

	// Build a standings string: "1st: Carp #N (Name) | 2nd: ..."
	var/list/ord  = list("1st", "2nd", "3rd", "4th", "5th", "6th")
	var/standings = ""
	for(var/i = 1 to LAZYLEN(finish_order))
		var/mob/living/simple_animal/hostile/carp/racing/FC = finish_order[i]
		if(QDELETED(FC))
			continue
		var/ps = (i >= 1 && i <= length(ord)) ? ord[i] : "[i]th"
		standings += "[ps]: Carp #[FC.race_number] ([get_carp_color_name(FC.race_number)])"
		if(i < LAZYLEN(finish_order))
			standings += " | "

	// Compute announcer-facing payout coefficient
	var/wnum = winner.race_number
	var/payout_info = ""
	var/list/wb = bets["[wnum]"]
	var/real_winner_bets = 0
	for(var/a in wb)
		real_winner_bets += wb[a]
	if(total_pool > 0 && real_winner_bets > 0)
		var/ratio = round((total_pool * (1 - RACE_HOUSE_CUT)) / real_winner_bets, 0.01)
		payout_info = " Odds x[ratio]."

	radio_announce("RACE RESULTS — [standings][payout_info] Payouts underway.")
	payout()

/// Distribute winnings using parimutuel logic (90% pool to winners, 10% house)
/datum/carp_race/proc/payout()
	if(!winner)
		refund_all()
		return

	var/winner_num = "[winner.race_number]"
	var/list/winner_bets = bets[winner_num]

	var/winner_bets_real = 0  // Only real player bets are used as divisor
	for(var/acc_num in winner_bets)
		winner_bets_real += winner_bets[acc_num]

	if(winner_bets_real == 0 || total_pool == 0)
		refund_all()
		radio_announce("No one bet on the winner. Bets refunded.")
		return

	// total_pool includes ghost bets — this increases payout_pool, boosting player winnings
	var/payout_pool = total_pool * (1 - RACE_HOUSE_CUT)

	for(var/acc_num in winner_bets)
		var/their_bet     = winner_bets[acc_num]
		var/payout_amount = round((their_bet / winner_bets_real) * payout_pool)
		if(payout_amount <= 0)
			continue
		var/datum/money_account/acc = get_account(text2num(acc_num))
		if(acc)
			acc.deposit(payout_amount, "Winnings: Carp #[winner.race_number] finished 1st", "Carp Race Betting")

/// Refund all bets (called when no winner or no bets on winner)
/datum/carp_race/proc/refund_all()
	for(var/i = 1 to RACE_CARP_COUNT)
		var/list/carp_bets = bets["[i]"]
		for(var/acc_num in carp_bets)
			var/amount = carp_bets[acc_num]
			if(amount <= 0)
				continue
			var/datum/money_account/acc = get_account(text2num(acc_num))
			if(acc)
				acc.deposit(amount, "Bet refund (carp races)", "Carp Race Betting")

/**
 * Place a bet for a player.
 * @param account   The player's bank account
 * @param carp_num  Which carp to bet on (1–RACE_CARP_COUNT)
 * @param amount    The bet amount in thalers
 * @return TRUE on success, FALSE with a reason string otherwise
 */
/// Places a bet for the given account on carp_num with amount thalers.
/// Returns null on success, or an English error string on failure.
/datum/carp_race/proc/place_bet(datum/money_account/account, carp_num, amount)
	if(state != RACE_STATE_BETTING)
		return "Betting is not open."
	if(!carp_num || carp_num < 1 || carp_num > RACE_CARP_COUNT)
		return "Invalid carp number."
	if(account.account_number in bet_accounts)
		return "You have already placed a bet this race."
	if(account.suspended)
		return "Your bank account is suspended."
	amount = round(amount, 1)
	if(amount < RACE_MIN_BET || amount > RACE_MAX_BET)
		return "Bet amount must be between [RACE_MIN_BET] and [RACE_MAX_BET]T."
	if(account.money < amount)
		return "Insufficient funds. Balance: [account.money]T, need: [amount]T."
	if(!account.withdraw(amount, "Bet on Carp #[carp_num] (carp race)", "Carp Race Betting"))
		return "Transaction declined by bank. Try again later."

	// Guard: re-initialise the sub-list if it was lost (e.g. concurrent reset)
	if(!bets["[carp_num]"])
		bets["[carp_num]"] = list()
	// Keys MUST be strings — numeric keys cause positional indexing which crashes on empty lists
	bets["[carp_num]"]["[account.account_number]"] = amount
	bet_accounts         += account.account_number
	total_pool           += amount
	return null  // success

/// Reset to IDLE — called by the controller to prepare a new race
/datum/carp_race/proc/reset_to_idle()
	despawn_racers()
	finish_order.Cut()  // Clear standings from the previous race
	state          = RACE_STATE_IDLE
	winner         = null
	total_pool     = 0
	ghost_pool     = 0
	phase_end_time = 0
	bet_accounts.Cut()
	for(var/i = 1 to RACE_CARP_COUNT)
		bets["[i]"] = list()
		ghost_bets["[i]"] = 0
