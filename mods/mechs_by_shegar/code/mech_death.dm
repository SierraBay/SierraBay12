/mob/living/exosuit/Destroy()

	selected_system = null

	for (var/mob/pilot as anything in pilots)
		remove_pilot(pilot)

	hud_health = null
	hud_power = null
	hud_power_control = null
	hud_camera = null

	QDEL_NULL_LIST(hud_elements)
	QDEL_NULL_LIST(menu_hud_elements)

	for (var/hardpoint in hardpoints)
		qdel(hardpoints[hardpoint])
	hardpoints = null

	QDEL_NULL(access_card)
	QDEL_NULL(arms)
	QDEL_NULL(legs)
	QDEL_NULL(head)
	QDEL_NULL(body)

	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		H.owner = null
		H.holding = null
		qdel(H)
	hardpoint_hud_elements.Cut()
	hardpoint_hud_elements = null

	. = ..()
