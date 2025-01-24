/obj/machinery/robotics_fabricator
	var/fab_status_flags
	wires = /datum/wires/fabricator/robotics_fabricator

/obj/machinery/robotics_fabricator/attack_hand(mob/user)
	if(!(fab_status_flags & FAB_HACKED))
		req_access = list(access_robotics)

	if(fab_status_flags & FAB_SHOCKED)
		shock(user, 50)
		return TRUE

	if((fab_status_flags & FAB_HACKED) && !panel_open)
		req_access.Cut()

	if(..())
		return TRUE

	user.set_machine(src)
	ui_interact(user)
	wires.Interact(user)

/obj/machinery/robotics_fabricator/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(panel_open && (isMultitool(I) || isWirecutter(I)))
		attack_hand(user)
		return TRUE
	if(fab_status_flags & FAB_SHOCKED)
		shock(user, 50)
		return TRUE
	if((fab_status_flags & FAB_DISABLED) && !panel_open)
		to_chat(user, SPAN_WARNING("\The [src] is disabled!"))
		return TRUE
	. = ..()
