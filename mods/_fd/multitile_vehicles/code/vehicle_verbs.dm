/obj/vehicles/verb/verb_exit_vehicle()
	set name = "Exit vehicle"
	set category = "Vehicle"
	set src in view(1)

	exit_vehicle(usr)

/obj/vehicles/verb/enter_vehicle()
	set name = "Enter vehicle"
	set category = "Vehicle"
	set src in view(1)

	var/mob/living/user = usr
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return
	var/player_pos_choice
	var/list/positions = get_all_positions()
	if(positions.len == 1)
		player_pos_choice = positions[1]
	else
		player_pos_choice = input(user, "Enter which position?", "Vehicle Entry Position Select", "Cancel") in positions + list("Cancel")

	if(player_pos_choice == "Cancel")
		return

	enter_as_position(user, player_pos_choice)

/obj/vehicles/verb/switch_seats()
	set name = "Switch seats"
	set category = "Vehicle"
	set src in view(1)
	var/mob/user = usr
	if(!istype(user) || !Adjacent(user))
		return
	var/position_switchto = input(user, "Enter which position?", "Vehicle Position Select", "Cancel") in get_all_positions() + list("Cancel")

	if(position_switchto == "Cancel")
		return
	if(check_position_blocked(position_switchto))
		do_seat_switch(user,position_switchto)
		return
	else
		enter_as_position(user,position_switchto)
	update_icon()
