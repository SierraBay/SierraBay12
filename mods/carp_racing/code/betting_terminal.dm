// ===========================
//   CARP RACE BETTING — COMPUTER PROGRAM
// ===========================

/**
 * Computer program for carp race betting.
 *
 * Available on NTNet — players can download it to any PDA, laptop, or console.
 * For a fixed kiosk on the map, place /obj/machinery/computer/modular/preset/carp_race_betting.
 *
 * Auth is read automatically from the player's worn ID card each time the UI opens.
 */

// ---- Program file ----

/datum/computer_file/program/carp_race_betting
	filename           = "carprace"
	filedesc           = "Carp Racing"
	extended_desc      = "Parimutuel system for carp race betting. Place bets and watch the race via cameras!"
	program_icon_state = "generic"
	program_key_state  = "generic_key"
	program_menu_icon  = "money"
	size               = 4
	requires_ntnet     = FALSE
	available_on_ntnet = TRUE
	nanomodule_path    = /datum/nano_module/program/carp_race_betting
	usage_flags        = PROGRAM_ALL
	category           = PROG_MISC

// ---- NanoModule ----

/datum/nano_module/program/carp_race_betting
	name = "Carp Racing"
	/// Authenticated bank account for the current UI session
	var/datum/money_account/authenticated_account = null
	/// HTML result message from the last bet action
	var/last_bet_result = ""

/// Returns the active race datum, or null if unavailable.
/datum/nano_module/program/carp_race_betting/proc/get_race()
	if(carp_race_controller && !QDELETED(carp_race_controller))
		return carp_race_controller.race
	return null

/// Reads the player's worn ID card and updates authenticated_account.
/// Returns: "ok" | "no_card" | "no_account" | "bad_account"
/datum/nano_module/program/carp_race_betting/proc/try_auth(mob/living/carbon/human/user)
	var/obj/item/card/id/I = user.GetIdCard()
	if(!istype(I))
		authenticated_account = null
		return "no_card"
	if(!I.associated_account_number)
		authenticated_account = null
		return "no_account"
	authenticated_account = get_account(I.associated_account_number)
	if(!authenticated_account)
		return "bad_account"
	return "ok"

// ---- UI ----

/datum/nano_module/program/carp_race_betting/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	if(!ishuman(user))
		return
	var/auth_status = try_auth(user)

	var/datum/carp_race/race = get_race()
	var/list/data = host.initial_data(program)
	data["src"] = ref(src)

	if(!race)
		data["race_available"] = FALSE
	else
		data["race_available"] = TRUE

		var/status_text  = "—"
		var/status_class = "average"
		switch(race.state)
			if(RACE_STATE_IDLE)
				status_text  = "⏳ Preparing next race..."
				status_class = "average"
			if(RACE_STATE_BETTING)
				var/secs = round(max(0, race.phase_end_time - world.time) / (1 SECOND))
				status_text  = "💰 BETTING OPEN — [secs]s left."
				status_class = "good"
			if(RACE_STATE_COUNTDOWN)
				var/secs = round(max(0, race.phase_end_time - world.time) / (1 SECOND))
				status_text  = "🏁 START IN [secs]s — bets closed!"
				status_class = "average"
			if(RACE_STATE_RACING)
				status_text  = "🚀 RACE IN PROGRESS! Watch via cameras!"
				status_class = "bad"
			if(RACE_STATE_FINISHED)
				if(race.winner)
					var/wnum = race.winner.race_number
					status_text  = "🏆 WINNER: Carp #[wnum] ([get_carp_color_name(wnum)])"
					status_class = "good"
				else
					status_text  = "Race finished."
					status_class = "average"
		data["status_text"]  = status_text
		data["status_class"] = status_class
		data["betting_open"] = (race.state == RACE_STATE_BETTING)
		data["bets_closed"]  = (race.state == RACE_STATE_COUNTDOWN || race.state == RACE_STATE_RACING)

		// Preset bet amounts for the button UI
		var/list/bet_amounts = list(50, 100, 250, 500, 1000)
		data["bet_amounts"] = bet_amounts

		// Build the racers list
		// Use display pool (real + ghost bets) for correct %-display
		// Pre-compute player's current bet so we can flag racer rows
		var/my_carp_pre = authenticated_account ? race.get_bet_by_account(authenticated_account.account_number) : 0
		var/display_pool = 0
		for(var/i = 1 to RACE_CARP_COUNT)
			display_pool += race.get_total_bets_on(i)
		var/list/racers = list()
		for(var/i = 1 to RACE_CARP_COUNT)
			var/cbet = race.get_total_bets_on(i)
			var/pct  = display_pool > 0 ? round(cbet / display_pool * 100) : 0
			var/done = FALSE
			for(var/mob/living/simple_animal/hostile/carp/racing/C in race.racers)
				if(C.race_number == i && C.finished)
					done = TRUE
					break
			racers.Add(list(list(
				"num"        = i,
				"color_name" = get_carp_color_name(i),
				"html_color" = get_carp_html_color(i),
				"bet_total"  = "[cbet]",  // string, чтобы 0 не пропадал в JsRender
				"pct"        = "[pct]",   // string, чтобы 0% не пропадал в JsRender
				"done"       = done,
				"src_ref"    = ref(src),   // передаём ref в каждый racer — ~root недоступен в NanoUI
				"is_my_bet"  = (my_carp_pre == i)
			)))
		data["racers"] = racers

		// Build the finish standings list — shown in the UI as carps cross the line
		var/list/place_strs  = list("1st", "2nd", "3rd", "4th", "5th", "6th")
		var/list/finish_data = list()
		for(var/i = 1 to LAZYLEN(race.finish_order))
			var/mob/living/simple_animal/hostile/carp/racing/FC = race.finish_order[i]
			if(QDELETED(FC))
				continue
			var/fnum = FC.race_number
			finish_data.Add(list(list(
				"place"      = (i >= 1 && i <= length(place_strs)) ? place_strs[i] : "[i]th",
				"num"        = fnum,
				"color_name" = get_carp_color_name(fnum),
				"html_color" = get_carp_html_color(fnum)
			)))
		data["finish_order"] = finish_data

		// Account section
		if(authenticated_account)
			data["has_account"]     = TRUE
			data["auth_message"]    = ""
			data["account_name"]    = authenticated_account.owner_name
			data["account_balance"] = authenticated_account.money
			var/my_carp   = race.get_bet_by_account(authenticated_account.account_number)
			var/my_amount = race.get_bet_amount_by_account(authenticated_account.account_number)
			data["my_carp"]       = my_carp
			data["my_carp_name"]  = my_carp > 0 ? get_carp_color_name(my_carp) : ""
			data["my_carp_color"] = my_carp > 0 ? get_carp_html_color(my_carp) : ""
			data["my_amount"]     = my_amount
		else
			data["has_account"] = FALSE
			switch(auth_status)
				if("no_card")
					data["auth_message"] = "⚠️ Карта ID не обнаружена. Вставьте карту ID в слот КПК (нажмите на КПК картой ID) или держите её в руке."
				if("no_account")
					data["auth_message"] = "⚠️ No bank account linked to this ID. Visit an ATM."
				if("bad_account")
					data["auth_message"] = "⚠️ Account not found in NanoBank system."
				else
					data["auth_message"] = "⚠️ Authentication failed."

		data["min_bet"]         = RACE_MIN_BET
		data["max_bet"]         = RACE_MAX_BET
		data["last_bet_result"] = last_bet_result

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-carp_race_betting.tmpl", name, 550, 600, state = state)
		if(host.update_layout())
			ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)  // auto-update pool data every 2s while race is active
	// clear after sending—message shown to player, no need to retain
	last_bet_result = ""
// ---- Topic handler ----

/datum/nano_module/program/carp_race_betting/Topic(href, href_list)
	if(..())
		return TRUE
	if(!ishuman(usr))
		return
	try_auth(usr)
	last_bet_result = ""

	if(href_list["action"] == "place_bet")
		var/datum/carp_race/race = get_race()
		if(!authenticated_account)
			last_bet_result = "<span class='bad'>Error: account not authenticated.</span>"
		else if(!race)
			last_bet_result = "<span class='bad'>Races unavailable.</span>"
		else
			var/carp_num   = text2num(href_list["carp_num"])
			var/bet_amount = text2num(href_list["bet_amount"])
			if(!carp_num || !bet_amount)
				last_bet_result = "<span class='bad'>Invalid bet parameters.</span>"
			else
				var/err = race.place_bet(authenticated_account, carp_num, bet_amount)
				if(!err)
					var/cname = get_carp_color_name(carp_num)
					last_bet_result = "<span class='good'>✅ Bet accepted: [bet_amount]T on Carp #[carp_num] ([cname])</span>"
				else
					last_bet_result = "<span class='bad'>❌ [err]</span>"
		SSnano.update_uis(src)

// ---- Preset console for map placement ----

/**
 * Pre-configured modular console with the carp race betting program pre-installed.
 * Place this on the map as a fixed betting kiosk near the race track.
 */
/obj/machinery/computer/modular/preset/carp_race_betting
	default_software = list(/datum/computer_file/program/carp_race_betting)
	autorun_program  = /datum/computer_file/program/carp_race_betting
