/obj/structure/casino/oh_bandit
	name = "one armed bandit"
	desc = "Turned off slot machine. "
	icon = 'mods/newUI/sprite/casino_sprites.dmi'
	icon_state = "slot_machine"
	density = TRUE
	anchored = TRUE

	var/theme = "pharaoh"
	var/money_loaded = 100
	var/spinning = FALSE
	var/coins_required = 10
	var/multiplier = 1
	var/list/reels = list("👑", "🐍", "🏺")

	/// PRD: consecutive non-jackpot spins since the last win
	var/prd_streak = 0
	/// PRD: base jackpot probability (%) before any streak bonus
	var/prd_base_chance = 5
	/// PRD: bonus added to jackpot chance per losing spin
	var/prd_step = 2

/obj/structure/casino/oh_bandit/New()
	..()
	AddOverlays("[theme]_idle")
	update_icon()

/obj/structure/casino/oh_bandit/attack_hand(mob/user)
	return(ui_interact(user))

/obj/structure/casino/oh_bandit/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = ui_data(user)

	var/template_name = "mods-slot_interface.tmpl"
	switch(theme)
		if("jade")
			template_name = "mods-slot_interface_jade.tmpl"
		if("casino")
			template_name = "mods-slot_interface_casino.tmpl"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, template_name, capitalize(name), 600, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/casino/oh_bandit/ui_data(mob/user)
	var/list/data = list()
	data["src"] = ref(src)
	data["spinning"] = spinning
	data["reels"] = reels
	data["coins"] = money_loaded
	data["cost"] = coins_required * multiplier
	data["multiplier"] = multiplier
	data["prd_streak"] = prd_streak
	data["prd_chance"] = min(30, prd_base_chance + prd_streak * prd_step)
	return data

/obj/structure/casino/oh_bandit/proc/perform_spin(mob/user)
	var/actual_cost = coins_required * multiplier
	if(money_loaded < actual_cost)
		to_chat(user, "Please insert money")
		return
	CutOverlays("[theme]_idle")
	icon_state = "slot_machine_active"
	AddOverlays("[theme]_spin")
	update_icon()
	money_loaded -= actual_cost
	playsound(src, 'mods/newUI/sound/spin.ogg', 40)

	spinning = TRUE
	var/list/data = ui_data(user)
	SSnano.update_uis(src, data)

	start_spin_animation(user)

/obj/structure/casino/oh_bandit/proc/start_spin_animation(mob/user)
	var/list/symbols = get_symbols()

	for(var/spin_frame = 1 to 20)
		addtimer(new Callback(src, PROC_REF(animate_spin_frame), user, symbols), spin_frame * 0.2 SECONDS)

	addtimer(new Callback(src, PROC_REF(finish_spin), user), 4 SECONDS)

/obj/structure/casino/oh_bandit/proc/animate_spin_frame(mob/user, list/symbols)
	if(!spinning)
		return

	reels = list(pick(symbols), pick(symbols), pick(symbols))
	var/list/data = ui_data(user)
	SSnano.update_uis(src, data)

/obj/structure/casino/oh_bandit/proc/finish_spin(mob/user)
	if(!spinning)
		return

	var/list/result = generate_result()
	reels = result
	var/winnings = calculate_winnings(result)

	if(winnings > 0)
		winning_money(winnings)

	spinning = FALSE
	icon_state = "slot_machine"
	CutOverlays("[theme]_spin")
	AddOverlays("[theme]_idle")
	update_icon()

	var/list/data = ui_data(user)
	SSnano.update_uis(src, data)

/obj/structure/casino/oh_bandit/OnTopic(user, href_list)
	if(href_list["spin"])
		if(!spinning)
			perform_spin(user)
		return TOPIC_HANDLED
	if(href_list["multiplier"])
		if(!spinning)
			multiplier = text2num(href_list["multiplier"])
			var/list/data = ui_data(user)
			SSnano.update_uis(src, data)
		return TOPIC_HANDLED
	return ..()


/obj/structure/casino/oh_bandit/proc/generate_result()
	var/list/symbols = get_symbols()
	var/list/result = list()

	// PRD: win chance grows each spin without a jackpot, capped at 95%
	var/win_chance = min(95, prd_base_chance + prd_streak * prd_step)

	if(prob(win_chance))
		// Jackpot — all three reels match; reset streak
		prd_streak = 0
		var/sym = pick(symbols)
		result = list(sym, sym, sym)
	else
		// No jackpot — increment streak and guarantee a non-matching result
		prd_streak++
		var/attempts = 0
		do
			result = list(pick(symbols), pick(symbols), pick(symbols))
			attempts++
		while(result[1] == result[2] && result[2] == result[3] && attempts < 20)

	return result

/obj/structure/casino/oh_bandit/proc/calculate_winnings(result)
	var/winnings = 0

	if(result[1] == result[2] && result[2] == result[3])
		switch(result[1])
			// Pharaoh
			if("👑")
				winnings = 100
			if("🦂")
				winnings = 75
			if("🐍")
				winnings = 50
			if("🐫")
				winnings = 25
			if("🏺")
				winnings = 15
			if("⚱️")
				winnings = 10
			// Jade
			if("🐉")
				winnings = 100
			if("🐲")
				winnings = 75
			if("🦎")
				winnings = 50
			if("✨")
				winnings = 25
			if("🍀")
				winnings = 15
			if("💎")
				winnings = 10
			// Casino
			if("🎰")
				winnings = 100
			if("🎲")
				winnings = 75
			if("♦️")
				winnings = 50
			if("♥️")
				winnings = 25
			if("♠️")
				winnings = 15
			if("♣️")
				winnings = 10
		playsound(src, pick('mods/newUI/sound/jackpot.ogg'), 50, 1)
/* Пока что отрубим бонусы за 2 совпадения. Посмотрим как будет играться система с псевдорандомом.
	else if(result[1] == result[2] || result[2] == result[3])
		winnings = 5
		playsound(src, pick('mods/newUI/sound/e_death.ogg'), 50, 1)
*/
	winnings *= multiplier

	return winnings


/obj/structure/casino/oh_bandit/proc/get_symbols()
	if(theme == "jade")
		return list("🐉", "🐲", "🦎", "✨", "🍀", "💎")
	if(theme == "casino")
		return list("🎰", "🎲", "♦️", "♥️", "♠️", "♣️")

	return list("👑", "🦂", "🐍", "🏺", "🐫", "⚱️")

/obj/structure/casino/oh_bandit/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	if (istype(tool, /obj/item/device/multitool))
		var/choices = list("jade", "casino", "pharaoh")
		var/choice = input(user, "Choose a theme:", "Theme Selection") in choices
		if(choice)
			theme = choice
			var/list/data = ui_data(user)
			var/list/symbols = get_symbols()
			reels = list(pick(symbols), pick(symbols), pick(symbols))
			SSnano.update_uis(src, data)
			SSnano.close_uis(src)
			AddOverlays("[theme]_idle")
			update_icon()
		return TRUE

	if (istype(tool, /obj/item/spacecash))
		var/obj/item/spacecash/insertedmoney = tool
		money_loaded += insertedmoney.worth
		to_chat(user, "You loaded [insertedmoney.name] intro [src].")
		qdel(tool)
		return TRUE

	if (isWrench(tool))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if (!do_after(user, (tool.toolspeed * 4) SECONDS, src, DO_REPAIR_CONSTRUCT))
			return TRUE
		anchored = !anchored
		to_chat(user, "You [anchored ? "wrench" : "unwrench"] \the [src].")
		return TRUE

/obj/structure/casino/oh_bandit/proc/winning_money(amount)
	spawn_money(amount, src.loc,usr)
