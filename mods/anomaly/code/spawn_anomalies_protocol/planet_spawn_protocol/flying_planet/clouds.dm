
//Облачка
/turf/simulated/floor/exoplanet/clouds
	name = "clouds"
	icon_state = "clouds"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE
	//У облак есть ЦЕЛОСТНОСТЬ. Чем её меньше - тем ближе облако к полному раскрытию. По умолчанию равно 100.
	var/integrity = 100
	//Собственно, максимальная целостность облак
	var/max_integrity = 100
	//Время последней обработки
	var/last_processing = 0
	//Облачка будут обрабатываться с помощью SSanom раз в 0.5 секунд
	var/processing_coldown = 0.5 SECONDS
	//Обрабатывает раскрытие
	var/opened = FALSE
	var/started_openning = FALSE

/turf/simulated/floor/exoplanet/clouds/Entered(atom/movable/AM)
	..()
	if(isanomalyhere(src))
		return
	//Если обьект НЕ моб, НЕ предмет или прожектайл - игнор
	if((!ismech(AM) && !ismob(AM) && !isitem(AM)) || isprojectile(AM))
		return
	if(locate(/obj/structure/catwalk) in src)
		return

	if(isliving(AM))
		var/mob/living/L = AM
		//Летающие существа не тревожат облака
		if (L.can_overcome_gravity())
			return
		//Артефакты с этим эффектом заставят облака игнорировать существо
		var/list/result_effects = calculate_artefact_reaction(L, "Возможность упасть")
		if(result_effects)
			if(result_effects.Find("Держит в воздухе"))
				return

	if(!opened && started_openning)
		return
	if(!opened && !started_openning)
		START_PROCESSING(SSanom, src)
	else if(opened)
		check_clouds_turf(AM)

//Проверяем сколько дамага наносится облачкам от обьектов на них
/turf/simulated/floor/exoplanet/clouds/Process()
	if(world.time - last_processing < processing_coldown)
		return //Время ещё не пришло
	last_processing = world.time
	//Собираем все обьекты на поверхности облачков
	var/total_clouds_damage = 0
	for(var/atom/movable/choosed_atom in src)
		if(isprojectile(choosed_atom) || isghost(choosed_atom) || (choosed_atom.anchored && !ismech(choosed_atom)))
			continue
		if(ismech(choosed_atom))
			total_clouds_damage += 100
		else if(isitem(choosed_atom))
			var/obj/item/choosed_item = choosed_atom
			total_clouds_damage += 5 * choosed_item.w_class
		else if(isliving(choosed_atom))
			var/mob/living/choosed_living = choosed_atom
			total_clouds_damage += choosed_living.mob_size
	if(total_clouds_damage)
		damage_clouds(total_clouds_damage)
	else
		regenerate_clouds()

/turf/simulated/floor/exoplanet/clouds/proc/damage_clouds(damage_amount)
	integrity -= damage_amount
	if(integrity <= 0)
		integrity = 0
		open_clouds()
	on_update_icon()

/turf/simulated/floor/exoplanet/clouds/proc/regenerate_clouds()
	integrity += 25
	if(integrity >= max_integrity)
		integrity = max_integrity
		STOP_PROCESSING(SSanom, src)
	on_update_icon()

/turf/simulated/floor/exoplanet/clouds/proc/open_clouds()
	appearance = SSskybox.space_appearance_cache[(((x + y) ^ ~(x * y) + z) % 25) + 1]
	opened = TRUE
	check_clouds_turf()
	addtimer(new Callback(src, PROC_REF(close_clouds)), 10 SECONDS)

/turf/simulated/floor/exoplanet/clouds/proc/close_clouds()
	appearance = initial(appearance)
	opened = FALSE
	START_PROCESSING(SSanom, src)


/turf/simulated/floor/exoplanet/clouds/on_update_icon()
	var/percent = integrity/max_integrity * 100
	switch(percent)
		if(100)
			color = "#ffffff"
		if(90 to 100)
			color  = "#e5f6ff"
		if(80 to 90)
			color  = "#cceeff"
		if(70 to 80)
			color  = "#b3e6ff"
		if(60 to 70)
			color  = "#99ddff"
		if(50 to 60)
			color  = "#80d5ff"
		if(40 to 50)
			color  ="#66ccff"
		if(30 to 40)
			color  = "#4db8ff"
		if(20 to 30)
			color  = "#33ccff"
		if(10 to 20)
			color  = "#00ccff"
		if(0 to 10)
			color  = "#00ccff"


/turf/simulated/floor/exoplanet/clouds/proc/check_clouds_turf(atom/movable/AM)
	if(!AM)
		for(var/atom/movable/movable_atom in src)
			//Если есть мостики - ничего не делаем
			if(locate(/obj/structure/catwalk) in src)
				return
			//Если это живое существо, просчитаем дополнительно
			if(isliving(AM))
				var/mob/living/L = AM
				//Если существо летает - ему ничего не будет
				if (L.can_overcome_gravity())
					return
				//Артефакты с этим эффектом не позволят существу провалится вниз
				var/list/result_effects = calculate_artefact_reaction(L, "Возможность упасть")
				if(result_effects)
					if(result_effects.Find("Защищает от падения"))
						return
			if(!movable_atom.anchored || ismech(movable_atom))
				visible_message("[movable_atom] со свистом улетает вниз", null, 7)
				move_to_closest_safe_turf(movable_atom)

///Задача функции - телепортировать игрока на любой турф который Не является облачками
/proc/move_to_closest_safe_turf(atom/movable/input_atom, bad_turf = /turf/simulated/floor/exoplanet/clouds)
	if(!input_atom)
		return FALSE
	var/list/list_of_turfs_in_area = get_area_turfs(get_area(input_atom))
	while(LAZYLEN(list_of_turfs_in_area))
		var/turf/current_turf = pick(list_of_turfs_in_area)
		if(!istype(current_turf, bad_turf))
			//Обьект/предмет/Моба вышвыривает на землю. СЖАЛИЛИСЬ.
			input_atom.forceMove(current_turf)
			//Мехам тут не место
			if(ismech(input_atom))
				var/mob/living/exosuit/mech = input_atom
				mech.gib()
			else if(isliving(input_atom))
				var/mob/living/target = input_atom
				//Артефакты с этим эффектом не позволят существу получить урон от падения
				var/list/result_effects = calculate_artefact_reaction(target, "Падение с высоты")
				if(result_effects)
					if(result_effects.Find("Защищает от падения"))
						return
				var/damage = 5
				target.Weaken(5)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_HEAD)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_CHEST)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_GROIN)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_L_LEG)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_R_LEG)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_L_FOOT)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_R_FOOT)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_L_ARM)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_R_ARM)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_L_HAND)
				target.apply_damage(damage, DAMAGE_BRUTE, BP_R_HAND)
			return
		else
			LAZYREMOVE(list_of_turfs_in_area, current_turf)
	//Если игрока не скинуло на новый турф - что-то не так.
	to_chat(input_atom, SPAN_BAD("Что-то не так...."))
