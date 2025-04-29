
/mob/living/exosuit/proc/add_heat(ammount,)
	current_heat += ammount * overheat_heat_modificator
	hud_heat.Update()
	if(current_heat != 0)
		process_heat = TRUE
	if(current_heat > max_heat || current_heat == max_heat)
		current_heat = max_heat
		overheat()


/mob/living/exosuit/proc/sub_heat(ammount) // substruct heat
	current_heat -= ammount
	hud_heat.Update()
	if(current_heat < min_heat || current_heat == min_heat)
		current_heat = min_heat
		process_heat = FALSE
		if(overheat)
			hud_heat.stop_overheat()
			overheat = FALSE
			overheat_heat_modificator = 1
			if(power == MECH_POWER_OFF)
				fast_toggle_power_garanted()
		overheat = FALSE
	else if(current_heat > max_heat || current_heat == max_heat)
		current_heat = max_heat
		overheat()

/mob/living/exosuit/proc/overheat()
	hud_heat.start_overheat()
	overheat_heat_modificator = 2
	if(power == MECH_POWER_ON)
		toggle_power()
		hud_power_control.update_icon()
	overheat = TRUE
	delayed_power_up()

/mob/living/exosuit/proc/delayed_power_up()
	set waitfor = 0
	sleep(body.overheat_time)
	if(power != MECH_POWER_OFF)
		return

/mob/living/exosuit/proc/process_heat()
	if((world.time - last_heat_process) < body.heat_process_speed)
		return
	if(overheat)
		sub_heat(total_heat_cooling * 2.5)
		return
	else if(power == MECH_POWER_OFF)
		sub_heat(total_heat_cooling * 4)
		return
	sub_heat(total_heat_cooling)


/obj/screen/movable/exosuit/heat/Update()
	var/value = (owner.current_heat/owner.max_heat) * 42
	var/output = floor(value)
	output = clamp(output, 0, 42)
	if(output > 21)
		icon_state = "heatprobe_up_[output]"
		heatprob_down.icon_state = "heatprobe_down_[21]"
	else if(output < 21)
		icon_state = "heatprobe_up_0"
		heatprob_down.icon_state = "heatprobe_down_[output]"
	return

/obj/screen/movable/exosuit/heat/proc/start_overheat()
	overheat.layer = 2.1

/obj/screen/movable/exosuit/heat/proc/stop_overheat()
	overheat.layer = 1.9
