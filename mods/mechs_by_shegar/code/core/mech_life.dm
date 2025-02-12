/mob/living/exosuit/handle_disabilities()
	return

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




/mob/living/exosuit/handle_environment(datum/gas_mixture/environment)
	if(!environment) return
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

	hud_heat.Update()

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
	maxHealth = (body.mech_health + material.integrity) + head.max_damage + arms.max_damage + legs.max_damage
	health = maxHealth-(getFireLoss()+getBruteLoss())
	if(menu_status)
		update_big_menu_status()
