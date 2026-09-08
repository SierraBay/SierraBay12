/proc/roulette_count_hand_money(mob/living/user)
	var/total = 0
	for(var/obj/item/spacecash/C in list(user.get_active_hand(), user.get_inactive_hand()))
		total += C.worth
	return total

/proc/roulette_deduct_hand_money(mob/living/user, amount)
	var/total = roulette_count_hand_money(user)
	if(total < amount)
		return FALSE
	var/remaining = amount
	for(var/obj/item/spacecash/C in list(user.get_active_hand(), user.get_inactive_hand()))
		if(remaining <= 0)
			break
		var/take = min(C.worth, remaining)
		C.worth -= take
		remaining -= take
		if(C.worth <= 0)
			qdel(C)
		else if(istype(C, /obj/item/spacecash/bundle))
			C.update_icon()
	return TRUE

/proc/roulette_number_color(num)
	if(num == 0)
		return "green"
	var/list/reds = list(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
	if(num in reds)
		return "red"
	return "black"

/proc/roulette_wheel_sequence()
	return list(0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26)

/obj/structure/casino/roulette_chart
	name = "roulette table"
	desc = "A classic green-felt roulette betting table. Place your bets before the wheel spins."
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "roulette_l"
	density = TRUE
	anchored = TRUE

	var/list/bets
	var/selected_amount = 10
	var/locked = FALSE
	var/last_result = -1
	var/list/result_history
	var/bank_balance = 50000

/obj/structure/casino/roulette_chart/New()
	..()
	bets           = list()
	result_history = list()

/obj/structure/casino/roulette_chart/attack_hand(mob/user)
	return ui_interact(user)

/obj/structure/casino/roulette_chart/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = ui_data(user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-roulette_table.tmpl", "Roulette — Betting Table", 860, 780)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/casino/roulette_chart/ui_data(mob/user)
	var/list/data = list()
	data["src"]             = ref(src)
	data["locked"]          = locked ? 1 : 0
	data["last_result"]     = last_result
	data["result_history"]  = result_history.Copy()
	data["selected_amount"] = selected_amount

	var/list/bet_list = list()
	var/total = 0
	for(var/list/B in bets)
		var/list/entry   = list()
		entry["type"]    = B["type"]
		entry["amount"]  = B["amount"]
		entry["is_mine"] = (B["bettor"] == user) ? 1 : 0
		var/mob/M_bettor_name = B["bettor"]
		entry["bettor_name"] = istype(B["bettor"], /mob) ? M_bettor_name.name : "Unknown"
		bet_list         += list(entry)
		total            += B["amount"]
	data["bets"]       = bet_list
	data["total_bet"]  = total
	data["is_ghost"]   = istype(user, /mob/observer) ? 1 : 0
	data["hand_money"] = istype(user, /mob/living) ? roulette_count_hand_money(user) : 0
	data["bank_balance"] = bank_balance
	return data

/obj/structure/casino/roulette_chart/OnTopic(user, href_list)
	// --- Change chip denomination ---
	if(href_list["set_amount"])
		var/amt = text2num(href_list["set_amount"])
		if(isnum(amt) && (amt == 10 || amt == 25 || amt == 50 || amt == 100 || amt == 500 || amt == 1000))
			selected_amount = amt
			SSnano.update_uis(src, ui_data(user))
		return TOPIC_HANDLED

	// --- Place a bet ---
	if(href_list["place_bet"])
		if(!istype(user, /mob/living))
			to_chat(user, SPAN_WARNING("Ghosts cannot place bets!"))
			return TOPIC_HANDLED
		if(locked)
			to_chat(user, SPAN_WARNING("No bets while the wheel is spinning!"))
			return TOPIC_HANDLED
		var/bet_type = href_list["place_bet"]
		if(!roulette_valid_bet(bet_type))
			return TOPIC_HANDLED
		var/mob/living/L = user
		var/hand_total = roulette_count_hand_money(L)
		if(hand_total < selected_amount)
			to_chat(user, SPAN_WARNING("You need [selected_amount] thalers in hand to place this bet! (You have [hand_total])"))
			return TOPIC_HANDLED
		if(!roulette_deduct_hand_money(L, selected_amount))
			to_chat(user, SPAN_WARNING("Could not deduct thalers from your hand."))
			return TOPIC_HANDLED
		var/list/bet    = list()
		bet["bettor"]   = user
		bet["type"]     = bet_type
		bet["amount"]   = selected_amount
		bets           += list(bet)
		bank_balance   += selected_amount
		to_chat(user, SPAN_NOTICE("You placed [selected_amount]T on [bet_type]."))
		SSnano.update_uis(src, ui_data(user))
		return TOPIC_HANDLED

	// --- Clear own bets ---
	if(href_list["clear_bets"])
		if(locked)
			return TOPIC_HANDLED
		var/list/kept = list()
		var/refund = 0
		for(var/list/B in bets)
			if(B["bettor"] == user)
				refund += B["amount"]
			else
				kept += list(B)
		bets = kept
		if(refund > 0)
			bank_balance -= refund
			var/mob/M_user = user
			spawn_money(refund, M_user.loc, M_user)
			to_chat(user, SPAN_NOTICE("Your bets were cleared. [refund]T has been returned to you."))
		SSnano.update_uis(src, ui_data(user))
		return TOPIC_HANDLED

	return ..()

/obj/structure/casino/roulette_chart/proc/roulette_valid_bet(bet_type)
	var/list/simple = list("red","black","odd","even","low","high",
	                       "dozen1","dozen2","dozen3","col1","col2","col3")
	if(bet_type in simple)
		return TRUE
	if(length(bet_type) > 9 && copytext(bet_type, 1, 10) == "straight_")
		var/num = text2num(copytext(bet_type, 10))
		if(isnum(num) && num >= 0 && num <= 36)
			return TRUE
	return FALSE

/obj/structure/casino/roulette_chart/proc/roulette_get_payout(bet_type, result)
	var/color   = roulette_number_color(result)
	var/is_odd  = (result > 0) && (result % 2 == 1)
	var/is_low  = (result >= 1 && result <= 18)
	var/dozen   = 0
	if(result >= 1  && result <= 12) dozen = 1
	else if(result >= 13 && result <= 24) dozen = 2
	else if(result >= 25 && result <= 36) dozen = 3
	var/col = 0
	if(result > 0) col = ((result - 1) % 3) + 1

	if(bet_type == "red")    return (color == "red")   ? 2 : 0
	if(bet_type == "black")  return (color == "black") ? 2 : 0
	if(bet_type == "odd")    return (result > 0 && is_odd)  ? 2 : 0
	if(bet_type == "even")   return (result > 0 && !is_odd) ? 2 : 0
	if(bet_type == "low")    return is_low               ? 2 : 0
	if(bet_type == "high")   return (!is_low && result>0) ? 2 : 0
	if(bet_type == "dozen1") return (dozen == 1) ? 3 : 0
	if(bet_type == "dozen2") return (dozen == 2) ? 3 : 0
	if(bet_type == "dozen3") return (dozen == 3) ? 3 : 0
	if(bet_type == "col1")   return (col == 1)   ? 3 : 0
	if(bet_type == "col2")   return (col == 2)   ? 3 : 0
	if(bet_type == "col3")   return (col == 3)   ? 3 : 0

	if(length(bet_type) > 9 && copytext(bet_type, 1, 10) == "straight_")
		var/num = text2num(copytext(bet_type, 10))
		return (isnum(num) && num == result) ? 36 : 0

	return 0

/obj/structure/casino/roulette_chart/proc/resolve_bets(result, mob/last_user)
	last_result = result
	result_history.Insert(1, result)
	if(length(result_history) > 12)
		result_history.Cut(13)

	var/color_name = roulette_number_color(result)
	var/color_icon = (color_name == "red") ? "🔴" : (color_name == "black") ? "⚫" : "🟢"

	for(var/list/B in bets)
		var/mult    = roulette_get_payout(B["type"], result)
		var/bettor  = B["bettor"]
		var/amount  = B["amount"]
		if(mult > 0)
			var/win = amount * mult
			var/payout = min(win, bank_balance)
			bank_balance -= payout
			var/mob/M_bettor = bettor
			var/spawn_loc = istype(bettor, /mob) ? M_bettor.loc : src.loc
			if(payout > 0)
				spawn_money(payout, spawn_loc, bettor)
			if(istype(bettor, /mob))
				if(payout < win)
					to_chat(bettor, SPAN_WARNING("Roulette: [color_icon] [result] — you won on [B["type"]], but the casino bank could only pay [payout]T (out of [win]T)!"))
				else
					to_chat(bettor, SPAN_NOTICE("Roulette: [color_icon] [result] — you won [win] thalers on [B["type"]]!"))
		else
			if(istype(bettor, /mob))
				to_chat(bettor, SPAN_DANGER("Roulette: [color_icon] [result] — you lost [amount] thalers on [B["type"]]."))

	bets   = list()
	locked = FALSE

	SSnano.update_uis(src, ui_data(last_user))


// ---------------------------------------------------------------
// 	Roulette Wheel
// ---------------------------------------------------------------

/obj/structure/casino/roulette
	name = "roulette wheel"
	desc = "A large mahogany-framed roulette wheel. Spin it to decide the fates of the gamblers."
	icon = 'maps/away/casino/casino_sprites.dmi'
	icon_state = "roulette_r"
	density = TRUE
	anchored = TRUE

	var/spinning = FALSE
	var/last_result = -1
	var/pending_result = -1
	var/list/result_history
	var/spin_deg = 1440

/obj/structure/casino/roulette/New()
	..()
	result_history = list()

/obj/structure/casino/roulette/attack_hand(mob/user)
	return ui_interact(user)

/obj/structure/casino/roulette/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = ui_data(user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-roulette_wheel.tmpl", "Roulette — Wheel", 600, 820)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/casino/roulette/ui_data(mob/user)
	var/list/data          = list()
	data["src"]            = ref(src)
	data["spinning"]       = spinning ? 1 : 0
	data["last_result"]    = last_result
	data["result_color"]   = (last_result >= 0) ? roulette_number_color(last_result) : "none"
	data["result_history"] = result_history.Copy()
	data["spin_deg"]       = spin_deg
	data["is_ghost"]       = istype(user, /mob/observer) ? 1 : 0

	var/obj/structure/casino/roulette_chart/T = locate(/obj/structure/casino/roulette_chart) in range(1, src)
	data["has_table"]    = T ? 1 : 0
	data["table_locked"] = (T && T.locked) ? 1 : 0
	data["total_bets"]   = T ? length(T.bets)  : 0
	data["table_total"]  = 0
	if(T)
		for(var/list/B in T.bets)
			data["table_total"] += B["amount"]
	return data

/obj/structure/casino/roulette/OnTopic(user, href_list)
	if(href_list["lock_bets"])
		if(!istype(user, /mob/living))
			return TOPIC_HANDLED
		var/obj/structure/casino/roulette_chart/T = locate(/obj/structure/casino/roulette_chart) in range(1, src)
		if(T && !T.locked && !spinning)
			T.locked = TRUE
			for(var/mob/M in viewers(7, src))
				to_chat(M, SPAN_NOTICE("[user] locks the bets — no more bets can be placed!"))
			SSnano.update_uis(T, T.ui_data(user))
			SSnano.update_uis(src, ui_data(user))
		return TOPIC_HANDLED
	if(href_list["spin"])
		if(!spinning)
			perform_spin(user)
		return TOPIC_HANDLED
	return ..()

/obj/structure/casino/roulette/proc/perform_spin(mob/user)
	if(!istype(user, /mob/living))
		to_chat(user, SPAN_WARNING("Ghosts cannot spin the wheel!"))
		return

	var/obj/structure/casino/roulette_chart/T = locate(/obj/structure/casino/roulette_chart) in range(1, src)
	if(!T)
		to_chat(user, SPAN_WARNING("There is no roulette table nearby!"))
		return

	T.locked = TRUE
	spinning = TRUE

	pending_result = rand(0, 36)
	var/list/seq = roulette_wheel_sequence()
	var/wheel_pos = seq.Find(pending_result) - 1   // 0-indexed position on the physical wheel
	var/seg_size = 360.0 / 37
	var/seg_center = wheel_pos * seg_size + seg_size * 0.5
	var/base_angle = 360 - seg_center
	if(base_angle < 0) base_angle += 360
	spin_deg = 1440 + round(base_angle)

	for(var/mob/M in viewers(7, src))
		to_chat(M, SPAN_NOTICE("[user] spins the roulette wheel!"))

	playsound(src, 'mods/newUI/sound/spin.ogg', 50, 1)
	SSnano.update_uis(src, ui_data(user))

	addtimer(new Callback(src, PROC_REF(finish_spin), user), 5 SECONDS)

/obj/structure/casino/roulette/proc/finish_spin(mob/user)
	last_result = pending_result

	result_history.Insert(1, last_result)
	if(length(result_history) > 12)
		result_history.Cut(13)

	spinning = FALSE

	var/color      = roulette_number_color(last_result)
	var/color_icon = (color == "red") ? "🔴" : (color == "black") ? "⚫" : "🟢"
	var/snd        = (color == "green") ? 'mods/newUI/sound/jackpot.ogg' : 'mods/newUI/sound/e_death.ogg'
	playsound(src, snd, 60, 1)

	for(var/mob/M in viewers(7, src))
		to_chat(M, SPAN_NOTICE("Roulette: [color_icon] The ball lands on [last_result]! ([color])"))

	var/obj/structure/casino/roulette_chart/T = locate(/obj/structure/casino/roulette_chart) in range(1, src)
	if(T)
		T.resolve_bets(last_result, user)

	SSnano.update_uis(src, ui_data(user))

/obj/structure/casino/roulette/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	if(isWrench(tool))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(!do_after(user, (tool.toolspeed * 4) SECONDS, src, DO_REPAIR_CONSTRUCT))
			return TRUE
		anchored = !anchored
		to_chat(user, "You [anchored ? "anchor" : "unanchor"] \the [src].")
		return TRUE
	return FALSE

/obj/structure/casino/roulette_chart/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	if(isWrench(tool))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(!do_after(user, (tool.toolspeed * 4) SECONDS, src, DO_REPAIR_CONSTRUCT))
			return TRUE
		anchored = !anchored
		to_chat(user, "You [anchored ? "anchor" : "unanchor"] \the [src].")
		return TRUE
	return FALSE
