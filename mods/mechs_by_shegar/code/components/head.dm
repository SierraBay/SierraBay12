/obj/item/mech_component/sensors/powerloader
	max_damage = 100
	min_damage = 50
	max_repair = 30
	repair_damage = 10
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 7
	emp_heat_generation = 50
	weight = 50

/obj/item/mech_component/sensors/light
	max_damage = 80
	min_damage = 50
	max_repair = 20
	repair_damage = 15
	req_material = MATERIAL_ALUMINIUM
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 80
	weight = 30

/obj/item/mech_component/sensors/heavy
	max_damage = 500
	min_damage = 300
	max_repair = 150
	repair_damage = 30
	repair_damage = 30
	req_material = MATERIAL_PLASTEEL
	back_modificator_damage = 1
	front_modificator_damage = 0.7
	max_heat = 300
	heat_cooling = 4
	emp_heat_generation = 100
	weight = 120

/obj/item/mech_component/sensors/combat
	max_damage = 180
	min_damage = 100
	max_repair = 60
	repair_damage = 20
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 100
	weight = 75

/obj/item/mech_component/sensors/get_sight(powered)
	var/flags = 0
	if(powered && camera)
		if(active_sensors) //SENSORS active? (Button)
			flags |= vision_flags //Мех получает спец зрение от сенсоров

	return flags

/mob/living/exosuit/handle_vision(powered)
	var/was_blind = sight & BLIND
	if(head)
		sight = head.get_sight(powered)
		see_invisible = head.get_invisible(powered)
	if(sight & BLIND && !was_blind)
		for(var/mob/pilot in pilots)
			to_chat(pilot, SPAN_WARNING("The sensors are not operational and you cannot see a thing!"))
	if(need_update_sensor_effects)
		check_sensors_blind()
	if(have_emp_effect)
		process_glich()

///Прок отвечает за обновление сенсоров от слепоты.
/mob/living/exosuit/proc/check_sensors_blind()
	if(body && (body.pilot_coverage < 100 || body.transparent_cabin) || !hatch_closed)
		need_update_sensor_effects = FALSE
		if(have_no_sensors_effect)
			remove_no_signal_effect()
		if(have_no_power_effect)
			remove_no_power_effect()
		return

	if(power != MECH_POWER_ON && hatch_closed) //Кабина закрыта и нет питания. Нужно накладывать лишь no_power эффект
		if(have_no_sensors_effect)
			remove_no_signal_effect()
		need_update_sensor_effects = FALSE
		add_no_power_effect()
	else if(power == MECH_POWER_ON && hatch_closed) //Кабина закрыта, есть питание. Нужно накладывать лишь no_signal (Потеря камеры)
		if(have_no_power_effect)
			remove_no_power_effect()
		if(!head.camera)
			add_no_signal_effect()
			need_update_sensor_effects = FALSE
		if(head.camera)
			remove_no_signal_effect()
			need_update_sensor_effects = FALSE


/mob/living/exosuit/proc/clear_sensors_effects(mob/living/pilot)
	if(have_emp_effect)
		pilot.overlay_fullscreen("sensoremp")
	if(have_no_sensors_effect)
		pilot.clear_fullscreen("sensorblind")
	if(have_no_power_effect)
		pilot.clear_fullscreen("nopower")

/obj/screen/fullscreen/mech_sensors_blind
	icon = 'mods/mechs_by_shegar/icons/mech_glitch.dmi'
	icon_state = "glitch_scan"
	layer = BLIND_LAYER
	scale_to_view = TRUE

/obj/screen/fullscreen/mech_sensors_glitchs
	icon = 'mods/mechs_by_shegar/icons/mech_glitch.dmi'
	icon_state = "glitch_eye"
	layer = BLIND_LAYER
	scale_to_view = TRUE

/obj/screen/fullscreen/mech_no_power
	icon = 'mods/mechs_by_shegar/icons/mech_glitch.dmi'
	icon_state = "no_power"
	layer = BLIND_LAYER
	scale_to_view = TRUE

/mob/living/exosuit/proc/process_glich()
	if((world.time - last_keybind_use) < 0.5 SECONDS)
		return
	remove_glitch_effects()

/mob/living/exosuit/proc/add_no_signal_effect()
	have_no_sensors_effect = TRUE
	for(var/mob/living/pilot in pilots)
		pilot.overlay_fullscreen("sensorblind", /obj/screen/fullscreen/mech_sensors_blind)

/mob/living/exosuit/proc/remove_no_signal_effect()
	if(have_no_sensors_effect)
		have_no_sensors_effect = FALSE
		for(var/mob/living/pilot in pilots)
			pilot.clear_fullscreen("sensorblind")

/mob/living/exosuit/proc/add_glitch_effects()
	have_emp_effect = TRUE
	for(var/mob/living/pilot in pilots)
		pilot.overlay_fullscreen("sensoremp", /obj/screen/fullscreen/mech_sensors_glitchs)

/mob/living/exosuit/proc/remove_glitch_effects()
	if(have_emp_effect)
		have_emp_effect = FALSE
		for(var/mob/living/pilot in pilots)
			pilot.clear_fullscreen("sensoremp")

/mob/living/exosuit/proc/add_no_power_effect()
	have_no_power_effect = TRUE
	for(var/mob/living/pilot in pilots)
		pilot.overlay_fullscreen("nopower", /obj/screen/fullscreen/mech_no_power)

/mob/living/exosuit/proc/remove_no_power_effect()
	if(have_no_power_effect)
		have_no_power_effect = FALSE
		for(var/mob/living/pilot in pilots)
			pilot.clear_fullscreen("nopower")
