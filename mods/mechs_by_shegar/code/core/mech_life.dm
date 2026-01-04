/mob/living/exosuit/handle_disabilities()
	return

/mob/living/exosuit/Life()

	for(var/thing in pilots)
		var/mob/pilot = thing
		if(pilot.loc != src) // Admin jump or teleport/grab.
			remove_pilot(pilot)

	if(radio)
		radio.on = (head && head.radio && head.radio.is_functional() && get_cell())

	body.update_air(hatch_closed && use_air)

	var/powered = FALSE
	if(get_cell())
		if(get_cell().drain_power(0, 0, calc_power_draw()) > 0)
			powered = TRUE

	if(!powered)
		//Shut down all systems
		if(head)
			head.active_sensors = FALSE
		for(var/hardpoint in hardpoints)
			var/obj/item/mech_equipment/M = hardpoints[hardpoint]
			if(istype(M) && M.active && M.passive_power_use)
				M.deactivate()

	if(current_heat != 0)
		process_heat()

	updatehealth()


	if(emp_damage > 0)
		emp_damage -= min(1, emp_damage) //Reduce emp accumulation over time

	..() //Handles stuff like environment

	lying = FALSE // Fuck off, carp.
	if(process_mech_vision)
		handle_hud_icons()
		handle_vision(powered)
		handle_hud_icons()
	process_speed()


/mob/living/exosuit/handle_environment(datum/gas_mixture/environment)
	..()
	if(!environment)
		return
	//Mechs and vehicles in general can be assumed to just tend to whatever ambient temperature
	if(abs(environment.temperature - bodytemperature) > 0 )
		bodytemperature += ((environment.temperature - bodytemperature) / 6)

	if(bodytemperature > material.melting_point * 1.45 ) //A bit higher because I like to assume there's a difference between a mech and a wall
		var/damage = 5
		if(bodytemperature > material.melting_point * 1.75 )
			damage = 10
		if(bodytemperature > material.melting_point * 2.15 )
			damage = 15
		apply_damage(damage, DAMAGE_BURN)
	//A possibility is to hook up interface icons here. But this works pretty well in my experience
		if(prob(damage))
			visible_message(SPAN_DANGER("\The [src]'s hull bends and buckles under the intense heat!"))

/mob/living/exosuit/handle_vision(powered)
	var/was_blind = sight & BLIND
	if(head)
		sight = head.get_sight(powered)
		see_invisible = head.get_invisible(powered)
	if(body && (body.pilot_coverage < 100 || body.transparent_cabin) || !hatch_closed)
		sight &= ~BLIND

	if(sight & BLIND && !was_blind)
		for(var/mob/pilot in pilots)
			to_chat(pilot, SPAN_WARNING("The sensors are not operational and you cannot see a thing!"))

/mob/living/exosuit/additional_sight_flags()
	return sight

/mob/living/exosuit/additional_see_invisible()
	return see_invisible

/mob/living/exosuit/updatehealth()
	maxHealth = (head.current_hp + head.unrepairable_damage) + (body.max_hp + body.unrepairable_damage) + (L_arm.current_hp + L_arm.unrepairable_damage) + (R_arm.current_hp + R_arm.unrepairable_damage)  + (L_leg.current_hp + L_leg.unrepairable_damage) + (R_leg.current_hp + R_leg.unrepairable_damage)
	health = collect_current_hp()
	if(health <= 0) //тобишь 0 или меньше
		death()
		return
	if(menu_status)
		update_big_menu_status()

/mob/living/exosuit/proc/collect_current_hp()
	var/result = 0
	for(var/obj/item/mech_component/part in list(head, body, R_arm, L_arm, R_leg, L_leg))
		result += part.current_hp
	return result

/mob/living/exosuit/revive()
	current_heat = 0
	body.cell.charge = body.cell.maxcharge
	//голова
	head.max_hp = head.max_hp + head.unrepairable_damage
	head.current_hp = head.max_hp
	head.unrepairable_damage = 0
	//ручки
	L_arm.max_hp = L_arm.max_hp + L_arm.unrepairable_damage
	R_arm.max_hp = R_arm.max_hp + R_arm.unrepairable_damage
	L_arm.current_hp = L_arm.max_hp
	R_arm.current_hp = R_arm.max_hp
	L_arm.unrepairable_damage = 0
	R_arm.unrepairable_damage = 0
	//Пузико
	body.max_hp = body.max_hp + body.unrepairable_damage
	body.current_hp = body.max_hp
	body.unrepairable_damage = 0
	//ножки
	L_leg.max_hp = L_leg.max_hp + L_leg.unrepairable_damage
	R_leg.max_hp = R_leg.max_hp + R_leg.unrepairable_damage
	L_leg.current_hp = L_leg.max_hp
	R_leg.current_hp = R_leg.max_hp
	L_leg.unrepairable_damage = 0
	R_leg.unrepairable_damage = 0
