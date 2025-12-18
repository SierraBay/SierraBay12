/turf/simulated/floor/exoplanet/titan_water/Entered(atom/movable/input_movable, atom/old_loc)
	if(!water_cant_affect_input_movable(input_movable))
		return
	input_movable.water_act(FLUID_MAX_DEPTH)

	affect_atom_crossed(input_movable)

	if(istitanwater(old_loc))
		var/turf/simulated/floor/exoplanet/titan_water/prev_water = old_loc
		if(prev_water.deep_status == deep_status)
			return //Глубокость одинаковая, нет смысла что-то делать

	if(ishuman(input_movable))
		input_movable.setup_water_filter(mask_icon_state)

	else if(ismech(input_movable))
		input_movable.setup_water_filter(mask_icon_state)

	else if(istype(input_movable, /obj/structure))
		input_movable.setup_water_filter(mask_icon_state_structure)

///Данная функция ВСЕГДА вызывается когда атом входит в воду
/turf/simulated/floor/exoplanet/titan_water/proc/affect_atom_crossed(atom/movable/input_movable)
	if(ishuman(input_movable))
		var/mob/living/carbon/human/detected_human = input_movable
		detected_human.handle_footsteps()
		if(detected_human.lying)
			drown_human(detected_human)
		affect_slowdown(detected_human)
		if(swim_stamina_spend)
			start_spend_stamina()

	else if(ismech(input_movable))
		if(deep_status == MAX_DEEP)
			drown_mech(input_movable)

	else if(istype(input_movable, /obj/structure))
		if(deep_status == MAX_DEEP)
			drown_structure(input_movable)


/turf/simulated/floor/exoplanet/titan_water/Exited(atom/movable/input_movable, atom/newloc)
	.=..()
	if(!water_cant_affect_input_movable(input_movable))
		return
	if(ismob(input_movable))
		stop_spend_stamina()
	if(istitanwater(newloc))
		var/turf/simulated/floor/exoplanet/titan_water/prev_water = newloc
		if(prev_water.deep_status == deep_status)
			return
	input_movable.desetup_water_filter()

/turf/simulated/floor/exoplanet/titan_water/proc/affect_slowdown(atom/movable/input_movable)
	if(ishuman(input_movable))
		var/mob/living/carbon/human/human = input_movable
		if(!(human.species.name in whitelist_specis_move_slowdown))
			var/datum/movement_handler/mob/delay/delay = human.GetMovementHandler(/datum/movement_handler/mob/delay)
			if(delay)
				delay.AddDelay(swim_delay)

//Может ли вода воздействовать на что-то? (Не может например на летающих).
/turf/simulated/floor/exoplanet/titan_water/proc/water_cant_affect_input_movable(atom/movable/input_movable)
	//Здесь очень тупорылый момент. К примеру при ревайве персонажа сперва его органы высыпаются на пол и
	// Моментально удаляются. Без этой проверки код воды будет по одному органу топить в воде, и лишь
	// Потом даст заменить все органы персонажу. Какая же это проклятая херня боже мой.
	if(QDELETED(input_movable))
		return FALSE
	if(!isturf(input_movable.loc))
		return FALSE
	if(isghost(input_movable) || isobserver(input_movable) || isprojectile(input_movable))
		return FALSE
	else if(ismob(input_movable))
		var/mob/mobik = input_movable
		//Жидкость ванильная не очень совместима с водой титана в вопросе этих проверок.
		if(!locate(/obj/fluid) in get_turf(mobik))
			if(mobik.can_overcome_gravity() || mobik.is_floating)
				return FALSE
	return TRUE

/turf/proc/react_turf_at_deploing()
	return

/turf/simulated/floor/exoplanet/titan_water/react_turf_at_deploing(atom/movable/input_movable)
	input_movable.setup_water_filter(mask_icon_state_structure)
