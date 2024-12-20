/mob/living/exosuit/install_system(obj/item/system, system_hardpoint, mob/user)
	if(hardpoints_locked || hardpoints[system_hardpoint])
		return FALSE

	var/obj/item/mech_equipment/ME = system
	if(istype(ME))
		if(ME.restricted_hardpoints && !(system_hardpoint in ME.restricted_hardpoints))
			return FALSE
		if(ME.restricted_software)
			if(!head || !head.software)
				return FALSE
			var/found
			for(var/software in ME.restricted_software)
				if(software in head.software.installed_software)
					found = TRUE
					break
			if(!found)
				return FALSE
	else
		return FALSE

	if(user)
		var/delay = 3 SECONDS * user.skill_delay_mult(SKILL_DEVICES)
		if(delay > 0)
			user.visible_message(
				SPAN_NOTICE("\The [user] begins trying to install \the [system] into \the [src]."),
				SPAN_NOTICE("You begin trying to install \the [system] into \the [src].")
			)
			if(!do_after(user, delay, src, DO_PUBLIC_UNIQUE) || user.get_active_hand() != system || !user.use_sanity_check(src, system, SANITY_CHECK_DEFAULT | SANITY_CHECK_TOOL_UNEQUIP))
				return FALSE

			if(hardpoints_locked || hardpoints[system_hardpoint])
				return FALSE

			if(user.unEquip(system))
				user.visible_message(
					SPAN_NOTICE("\The [user] installs \the [system] into \the [src]'s [system_hardpoint]."),
					SPAN_NOTICE("You install \the [system] in \the [src]'s [system_hardpoint].")
				)
				playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			else return FALSE

	GLOB.destroyed_event.register(system, src, .proc/forget_module)

	system.forceMove(src)
	hardpoints[system_hardpoint] = system
	ME.installed(src)

	var/obj/screen/exosuit/hardpoint/H = hardpoint_hud_elements[system_hardpoint]
	H.holding = system

	system.screen_loc = H.screen_loc
	system.hud_layerise()

	hardpoints_menu_elements |= system
	refresh_hud()
	queue_icon_update()

	return TRUE

/mob/living/exosuit/remove_system(system_hardpoint, mob/user, force)

	if((hardpoints_locked && !force) || !hardpoints[system_hardpoint])
		return 0

	var/obj/item/system = hardpoints[system_hardpoint]
	if(user)
		var/delay = 3 SECONDS * user.skill_delay_mult(SKILL_DEVICES)
		if(delay > 0)
			user.visible_message(SPAN_NOTICE("\The [user] begins trying to remove \the [system] from \the [src]."))
			if(!do_after(user, delay, src, DO_PUBLIC_UNIQUE) || hardpoints[system_hardpoint] != system)
				return FALSE

	hardpoints[system_hardpoint] = null

	if(system_hardpoint == selected_hardpoint)
		clear_selected_hardpoint()

	var/obj/item/mech_equipment/ME = system
	if(istype(ME))
		ME.uninstalled()
	system.forceMove(get_turf(src))
	system.screen_loc = null
	system.layer = initial(system.layer)
	GLOB.destroyed_event.unregister(system, src, .proc/forget_module)

	var/obj/screen/exosuit/hardpoint/H = hardpoint_hud_elements[system_hardpoint]
	H.holding = null

	for(var/thing in pilots)
		var/mob/pilot = thing
		if(pilot && pilot.client)
			pilot.client.screen -= system

	hardpoints_menu_elements -= system
	refresh_hud()
	queue_icon_update()

	if(user)
		system.forceMove(get_turf(user))
		user.put_in_hands(system)
		to_chat(user, SPAN_NOTICE("You remove \the [system] from \the [src]'s [system_hardpoint]."))
		playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)

	return 1
