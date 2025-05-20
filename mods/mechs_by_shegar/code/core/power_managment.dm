/mob/living/exosuit
	var/power = MECH_POWER_OFF

/mob/living/exosuit/proc/toggle_power(mob/user)
	if(!body.cell.check_charge(50) && power == MECH_POWER_OFF)
		to_chat(user, SPAN_WARNING("Error: Not enough power for power up."))
		return
	if(overheat  && power == MECH_POWER_OFF)
		to_chat(user, SPAN_WARNING("Error: overheat detected, safe protocol active."))
		return
	else if(power == MECH_POWER_ON) //Turning it off is instant
		playsound(src, 'sound/mecha/mech-shutdown.ogg', 100, 0)
		turn_off_mech()
	else if(get_cell(TRUE))
		//Start power up sequence
		power = MECH_POWER_TRANSITION
		playsound(src, 'sound/mecha/powerup.ogg', 50, 0)
		if(user.do_skilled(1.5 SECONDS, SKILL_MECH, src, 0.5, DO_DEFAULT | DO_USER_UNIQUE_ACT) && power == MECH_POWER_TRANSITION)
			playsound(src, 'sound/mecha/nominal.ogg', 50, 0)
			turn_on_mech()
		else
			to_chat(user, SPAN_WARNING("You abort the powerup sequence."))
			turn_off_mech()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected."))

/mob/living/exosuit/get_cell(force)
	RETURN_TYPE(/obj/item/cell)
	if(power == MECH_POWER_ON || force) //For most intents we can assume that a powered off exosuit acts as if it lacked a cell
		return body ? body.cell : null
	return null

/mob/living/exosuit/proc/calc_power_draw()
	//Passive power stuff here. You can also recharge cells or hardpoints if those make sense
	var/total_draw = 0
	for(var/hardpoint in hardpoints)
		var/obj/item/mech_equipment/I = hardpoints[hardpoint]
		if(!istype(I))
			continue
		total_draw += I.passive_power_use

	if(head && head.active_sensors)
		total_draw += head.power_use

	if(body)
		total_draw += body.power_use

	return total_draw

//Аварийный запуск меха работает и при перегреве, но если мех перегреется повторно в состоянии перегрева он гибнется
/mob/living/exosuit/proc/emergency_toggle_power(mob/user)
	if(!overheat)
		to_chat(user, "Перегрев не обнаружен, протокол аварийного запуска заблокирован.")
		return
	if(power != MECH_POWER_OFF)
		return
	if(!body.cell.check_charge(50))
		to_chat(user, SPAN_WARNING("Error: Not enough power for emergency power up."))
		return
	if(get_cell(TRUE))
		playsound(src, 'mods/mechs_by_shegar/sounds/mecha_fast_power_up.ogg', 70, 0)
		turn_on_mech()
		var/obj/item/cell/cell = src.get_cell()
		cell.use(100)
		body.take_burn_damage(rand(5,15))
		update_icon()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected."))

/mob/living/exosuit/proc/fast_toggle_power_garanted(mob/user)
	if(get_cell(TRUE))
		turn_on_mech()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected, can't autoboot."))

/mob/living/exosuit/proc/turn_on_mech()
	power = MECH_POWER_ON
	update_big_buttons()
	update_icon()
	need_update_sensor_effects = TRUE

/mob/living/exosuit/proc/turn_off_mech()
	power = MECH_POWER_OFF
	update_big_buttons()
	update_icon()
	need_update_sensor_effects = TRUE
