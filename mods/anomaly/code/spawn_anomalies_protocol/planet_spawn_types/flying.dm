/obj/overmap/visitable/sector/exoplanet/flying
	name = "flying exoplanet"
	desc = "Flying around a certain center of the island."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	can_spawn_anomalies = TRUE
	anomalies_type = list(
		/obj/anomaly/tramplin = 2,
		/obj/anomaly/rvach/three_and_three = 1
		)
	possible_themes = list(
		/datum/exoplanet_theme = 100
		)
	min_anomaly_size = 1
	max_anomaly_size = 9
	min_anomalies_ammout = 400
	max_anomalies_ammout = 500
	planetary_area = /area/exoplanet/flying
	map_generators = list(/datum/random_map/noise/exoplanet/flying)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES|RUIN_ELECTRA_ANOMALIES
	surface_color = "#a46610"
	water_color = "#ffffff"
	daycycle_range = list(2 HOURS, 3 HOURS)
	daycycle = FALSE
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0

//Генерируем бэкграунд для островов. TODO: нарисовать очень красивый бэкграунд
/obj/overmap/visitable/sector/exoplanet/flying/build_level()
	.=..()
	var/turf/any_turf
	for(var/turf/turfs in planetary_area)
		any_turf = turfs
		break
	var/planet_z = get_z(any_turf)
	var/datum/event/change_z_skybox = new /datum/event/change_z_skybox(new /datum/event_meta(EVENT_LEVEL_MAJOR))
	change_z_skybox.affecting_z = list(planet_z)
	change_z_skybox.setup('mods/anomaly/icons/planet_backgrounds.dmi', "flying")
	SSskybox.generate_skybox(planet_z)



/obj/overmap/visitable/sector/exoplanet/flying/generate_map()
	.=..()
	//Находим Z планеты, создаём с ним список
	var/turf/any_turf
	for(var/turf/turfs in planetary_area)
		any_turf = turfs
		break
	var/list/input_z = list()
	input_z += get_z(any_turf)

	//Создаём список возможных для спавна островов путём сбора "наследников"
	var/list/islands_list = list()
	for (var/T in subtypesof(/datum/map_template/ruin/flying_island))
		var/datum/map_template/ruin/exoplanet/ruin = T
		islands_list += new ruin
	//Выполняем спавн используя существующий код спавна диреликтов на планете
	var/list/list_of_turfs = list()
	for(var/turf/picked_turf in planetary_area)
		LAZYADD(list_of_turfs, picked_turf)
	var/islands_spawn_ammount = rand(25,45)
	//После того как мы определились с количеством островов, приступаем к спавну
	var/failures_ammount = 0
	for(var/i = 0, i < islands_spawn_ammount)
		//Выбираем случайный турф
		var/turf/current_turf = pick(list_of_turfs) //Выбираем турф для спавна
		var/datum/map_template/ruin = pick(islands_list) //Выбираем остров
		var/failure = FALSE
		for(var/turf/picked_turf in ruin.get_affected_turfs(current_turf, 1))
			if(istype(picked_turf, /turf/simulated/floor/exoplanet/grass))
				//При попытке размещения диреликта, мы наехали на другой остров
				failure = TRUE
				break
		if(!failure) //Все турфы на которых мы хотим разместить остров - не являются островом
			i++
			var/list/turfs_for_clean = ruin.get_affected_turfs(current_turf, 1)
			//Удаляем заменённые турфы из списка турфов, т.к проверять их уже нет смысла
			for(var/turf/cleared_turf in turfs_for_clean)
				LAZYREMOVE(list_of_turfs, cleared_turf)
			load_ruin(current_turf, pick(islands_list)) //Размещаем остров
		else
			failures_ammount++
		LAZYREMOVE(list_of_turfs, current_turf)
		if(failures_ammount == 100) //Как и в генераторе аномок, аварийно выйдет из цикла при слишком большом количестве "ошибок"
			break



/obj/overmap/visitable/sector/exoplanet/flying/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)


/obj/overmap/visitable/sector/exoplanet/flying/generate_atmosphere()
	..()
	atmosphere = new
	atmosphere.temperature = rand(290, 330)
	atmosphere.update_values()
	var/good_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)
	atmosphere.gas = good_gas


/datum/random_map/noise/exoplanet/flying
	descriptor = "flying islands"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/clouds
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/flying
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/clouds


//Облачка
/turf/simulated/floor/exoplanet/clouds
	name = "clouds"
	icon_state = "clouds"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE
	//Обрабатывает раскрытие
	var/opened = FALSE
	var/started_openning = FALSE

/turf/simulated/floor/exoplanet/clouds/Entered(atom/movable/AM)
	..()
	if(locate(/obj/structure/catwalk) in src)
		return
	if(!isitem(AM) && !isliving(AM))
		return
	if(isliving(AM))
		var/mob/living/L = AM
		//Летающие существа не тревожат облака
		if (L.can_overcome_gravity())
			return
		//Артефакты с этим эффектом заставят облака игнорировать существо
		var/list/result_effects = calculate_artefact_reaction(L, "Падение с высоты")
		if(result_effects)
			if(result_effects.Find("Защищает от падения"))
				return
	if(!opened && started_openning)
		return
	if(!opened && !started_openning)
		open_clouds()
		return
	else if(opened)
		check_clouds_turf(AM)

/turf/simulated/floor/exoplanet/clouds/proc/open_clouds()
	flick("clouds_opening", src)
	icon_state = "clouds_open"
	sleep(2.5 SECONDS)
	//Заставляем облака показывать задник TODO: нарисовать красивый бэк с островами для этой планеты
	appearance = SSskybox.space_appearance_cache[(((x + y) ^ ~(x * y) + z) % 25) + 1]
	opened = TRUE
	check_clouds_turf()
	addtimer(new Callback(src, PROC_REF(close_clouds)), 10 SECONDS)

/turf/simulated/floor/exoplanet/clouds/proc/close_clouds()
	flick("clouds_closing", src)
	icon_state = "clouds"
	appearance = initial(appearance)
	opened = FALSE

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
				var/list/result_effects = calculate_artefact_reaction(L, "Падение с высоты")
				if(result_effects)
					if(result_effects.Find("Защищает от падения"))
						return
			if(!movable_atom.anchored)
				visible_message("[movable_atom] со свистом улетает вниз", null, 7)
				//Живое существо отправляется на рандомный турф на островах
				if(isliving(movable_atom))
					move_to_closest_safe_turf(movable_atom)
					return
				//Всё что не живое существо - исчезает
				qdel(movable_atom)

///Задача функции - телепортировать игрока на любой турф который Не является летающими остравами
/proc/move_to_closest_safe_turf(atom/movable/input_atom, bad_turf = /turf/simulated/floor/exoplanet/clouds)
	if(!input_atom)
		return FALSE
	var/list/list_of_turfs_in_area = get_area_turfs(get_area(input_atom))
	while(LAZYLEN(list_of_turfs_in_area))
		var/turf/current_turf = pick(list_of_turfs_in_area)
		if(!istype(current_turf, bad_turf))
			//Обьект/предмет/Моба вышвыривает на землю. СЖАЛИЛИСЬ.
			input_atom.forceMove(current_turf)
			if(isliving(input_atom))
				var/mob/living/target = input_atom
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
