/mob/living/exosuit/Life()

	for(var/thing in pilots)
		var/mob/pilot = thing
		if(pilot.loc != src) // Admin jump or teleport/grab.
			if(pilot.client)
				pilot.client.screen -= hud_elements
				LAZYREMOVE(pilots, pilot)
				UNSETEMPTY(pilots)
		update_pilots()

	if(radio)
		radio.on = (head && head.radio && head.radio.is_functional() && get_cell())

	body.update_air(hatch_closed && use_air)

	var/powered = FALSE
	if(get_cell())
		powered = get_cell().drain_power(0, 0, calc_power_draw()) > 0

	if(!powered)
		//Shut down all systems
		if(head)
			head.active_sensors = FALSE
		for(var/hardpoint in hardpoints)
			var/obj/item/mech_equipment/M = hardpoints[hardpoint]
			if(istype(M) && M.active && M.passive_power_use)
				M.deactivate()


	updatehealth()
	if(health <= 0 && stat != DEAD)
		death()
	if(process_heat)
		process_heat()
	if(process_move_speed)
		process_speed()

	if(emp_damage > 0)
		emp_damage -= min(1, emp_damage) //Reduce emp accumulation over time

	handle_hud_icons()

	lying = FALSE // Fuck off, carp.
	handle_vision(powered)


/mob/living/exosuit/updatehealth()
	maxHealth = (body.mech_health + material.integrity) + head.max_damage + arms.max_damage + legs.max_damage
	health = maxHealth-(getFireLoss()+getBruteLoss())
	if(menu_status)
		update_big_menu_status()
