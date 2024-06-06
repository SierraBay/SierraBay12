/obj/vehicles/proc/get_all_positions()
	return list(VP_DRIVER)

/obj/vehicles/proc/position_name(position, prefix = TRUE)
	switch(position)
		if(VP_DRIVER)
			return "[prefix && "on"] [position] seat"
		if(VP_INTERIOR)
			return "[prefix && "in the"] interiors"

// call before changing position
/obj/vehicles/proc/handle_position_change(mob/user)

/obj/vehicles/proc/exit_vehicle(mob/user, ignore_incap_check = FALSE, mob/puller = null)
	if(!(user in get_occupants_in_position(VP_INTERIOR)) && user.loc != src)
		to_chat(user, SPAN_NOTICE("[puller || "You"] must be inside [src] to exit it."))
		return
	if(user.incapacitated() && !ignore_incap_check)
		to_chat(user, SPAN_WARNING("[puller || "You"] cannot do that when you are incapacitated!"))
		return
	var/loc_moveto = pick_valid_exit_loc()
	if(!loc_moveto)
		to_chat(user, SPAN_NOTICE("There is no valid location to exit at."))
		return

	handle_position_change(user)

	occupants -= user
	contents -= user
	user.forceMove(loc_moveto)

	update_icon()

/obj/vehicles/proc/show_occupants_contained(mob/user)
	var/has_passengers = 0
	for(var/mob/M in occupants)
		has_passengers = 1
		break
	if(has_passengers)
		to_chat(user, SPAN_NOTICE("Its visible occupants are:"))
		for(var/mob/M in occupants)
			if(occupants[M] in exposed_positions)
				M.examine(user)

/obj/vehicles/proc/kick_occupants()
	for(var/mob/m in occupants)
		exit_vehicle(m, TRUE)

/obj/vehicles/proc/get_occupants_in_position(position)
	var/list/to_return = list()
	for(var/mob/occupant in occupants)
		if(occupants[occupant] == position)
			to_return += occupant
	return to_return

/obj/vehicles/proc/get_occupant_amount()
	return occupants.len - 2

//Returns null to allow the enter, a string to disallow.
/obj/vehicles/proc/check_enter_invalid()
	if(get_occupant_amount() + 1 > (1 + occupants[1] + occupants[2]))
		return "[src] is full!"

/obj/vehicles/proc/check_position_blocked(position)
	var/list/occupants_in_pos = get_occupants_in_position(position)
	switch(position)
		if(VP_DRIVER)
			return occupants_in_pos.len >= 1
		if(VP_INTERIOR)
			return FALSE

/obj/vehicles/proc/check_entering(mob/user, position, puller)
	var/mob/msg_recipient = puller || user

	if(doors_locked())
		to_chat(msg_recipient, SPAN_WARNING("\The [src] is locked."))
		return FALSE

	if((position != VP_INTERIOR) && bounds_dist(src, msg_recipient) > 48)
		to_chat(msg_recipient, SPAN_WARNING("\The [src] is too far."))
		return FALSE

	if(check_position_blocked(position))
		to_chat(msg_recipient, SPAN_WARNING("No [position] spaces in [src]"))
		return FALSE

	if(!isliving(user) && position == VP_DRIVER)
		if(msg_recipient == user)
			to_chat(msg_recipient, SPAN_WARNING("You don't know how to drive that."))
		else
			to_chat(msg_recipient, SPAN_WARNING("It doesn't look like [user] can drive that."))
		return FALSE

	var/can_enter = check_enter_invalid()
	if(can_enter)
		to_chat(msg_recipient, SPAN_NOTICE("[can_enter]"))
		return FALSE

	return TRUE

/obj/vehicles/proc/handle_entering(mob/user, position, puller)
	handle_position_change(user)
	occupants |= user
	//user.client.view = "[round(VIEW_SIZE_X * vehicle_view_modifier)]x[round(VIEW_SIZE_Y * vehicle_view_modifier)]"
	occupants[user] = position
	user.loc = contents
	contents |= user
	update_icon()
	if(puller)
		visible_message(SPAN_NOTICE("[puller] put [user] [position_name(position)]."))
	else
		visible_message(SPAN_NOTICE("[user] enters the [position_name(position, null)] of [src]."))
	to_chat(user, SPAN_INFO("You are now [position_name(position)] of [src]."))

/obj/vehicles/proc/enter_as_position(mob/user, position, mob/puller)
	if(!check_entering(user, position))
		return FALSE

	if(user in occupants)
		if(occupants[user] == position)
			to_chat(user, SPAN_NOTICE("[puller || "You"]'re already a [position] of [src]"))
			return FALSE
		handle_entering(user, position, puller)
		return TRUE

	handle_entering(user, position, puller)

	return TRUE

/obj/vehicles/MouseDrop_T(mob/C, mob/user)
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated())
		return

	if(ismob(C))
		var/player_pos_choice
		var/list/positions = get_all_positions()
		if(positions.len == 1)
			player_pos_choice = positions[1]
		else
			player_pos_choice = input(user, "Which position to put?", "Vehicle entry position select", "Cancel") in positions + list("Cancel")

		if(player_pos_choice == "Cancel")
			return

		if(C == user)
			enter_as_position(C, player_pos_choice)
		else
			enter_as_position(C, player_pos_choice, user)
	else if(VP_INTERIOR in get_all_positions())
		enter_as_position(C, VP_INTERIOR, user)

/obj/vehicles/proc/do_seat_switch(mob/user, position)
	var/list/occ_in_pos = get_occupants_in_position(position)
	if(!occ_in_pos||occ_in_pos.len == 0)
		to_chat(user,"<span class = 'notice'>There are no [position] slots in [src]</span>")
	var/mob/occ_tradewith = pick(occ_in_pos)
	var/user_position = occupants[user]
	var/tradewith_response = alert(occ_tradewith,"[user], [user_position] wants to switch seats with you. Accept?",,"Yes","No")
	if(tradewith_response == "No" || isnull(tradewith_response))
		to_chat(user,"<span class = 'warning'>[occ_tradewith] denied your seat-switch request.</span>")
		return
	occupants[user] = "Awaiting Trade" //Used to allow for debugging if anything goes wrong during seat switch
	occupants[occ_tradewith] = "Awaiting Trade"
	enter_as_position(user,position)
	enter_as_position(occ_tradewith,user_position)

/obj/vehicles/proc/damage_occupant(position, obj/item/P, mob/user)
	var/list/occ_list = get_occupants_in_position(position)
	if(!occ_list?.len)
		return 1
	var/mob/mob_to_hit = pick(occ_list)
	if(isnull(mob_to_hit))
		return 1
	if(user)
		mob_to_hit.use_tool(P, user)
		return 0
	else
		mob_to_hit.bullet_act(P)
		return 0

/obj/vehicles/proc/should_damage_occ()
	for(var/position in exposed_positions)
		var/hit_chance = exposed_positions[position]
		if(isnull(hit_chance))
			continue
		if(prob(hit_chance))
			return position
	return null

/obj/vehicles/proc/get_exit_offsets()
	return
