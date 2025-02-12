/mob/living/exosuit/proc/toggle_power(mob/user)
	if(power == MECH_POWER_TRANSITION)
		to_chat(user, SPAN_NOTICE("Power transition in progress. Please wait."))
	else if(power == MECH_POWER_ON) //Turning it off is instant
		playsound(src, 'sound/mecha/mech-shutdown.ogg', 100, 0)
		power = MECH_POWER_OFF
	else if(get_cell(TRUE))
		//Start power up sequence
		power = MECH_POWER_TRANSITION
		playsound(src, 'sound/mecha/powerup.ogg', 50, 0)
		if(user.do_skilled(1.5 SECONDS, SKILL_MECH, src, 0.5, DO_DEFAULT | DO_USER_UNIQUE_ACT) && power == MECH_POWER_TRANSITION)
			playsound(src, 'sound/mecha/nominal.ogg', 50, 0)
			power = MECH_POWER_ON
		else
			to_chat(user, SPAN_WARNING("You abort the powerup sequence."))
			power = MECH_POWER_OFF
		hud_power_control?.update()
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
