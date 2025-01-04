/obj/overmap/visitable/sector/exoplanet/flying
	name = "flying exoplanet"
	desc = "A cluster of floating islands moving around an unknown object. WARNING: large gravity-anomalous activity detected. Extreme caution is required."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	//Большие артефакты
	big_anomaly_artefacts_min_amount = 4
	big_anomaly_artefacts_max_amount = 6
	big_artefacts_types = list(
		/obj/structure/big_artefact/gravi
		)
	big_artefacts_can_be_close = FALSE
	big_artefacts_range_spawn = 30
	//
	possible_themes = list(
		/datum/exoplanet_theme = 100
		)
	planetary_area = /area/exoplanet/flying
	map_generators = list(/datum/random_map/noise/exoplanet/flying)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES|RUIN_ELECTRA_ANOMALIES
	surface_color = "#11420c"
	water_color = "#ffffff"
	daycycle_range = list(5 HOURS, 1 MINUTES)
	//Вечный день
	sun_position = 1
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 5
	//Следующие руины нам НЕ подойдут из-за того что на облакал они выглядят крайне убого

/*
1. Сперва имеем чистое полотно из травы
2. Расставляем руины
3. После успешного спавна собирает весь список турфов травы, проверяем чтоб они были пустые(На них не было обьектов)
4. Заменяем всю подходящую траву на облака
5. Запускаем генератор спавна островов
*/
/obj/overmap/visitable/sector/exoplanet/flying/build_level()
	generate_atmosphere()
	for (var/datum/exoplanet_theme/T in themes)
		T.adjust_atmosphere(src)
	if (atmosphere)
		//Set up gases for living things
		if (!length(breathgas))
			var/list/goodgases = atmosphere.gas.Copy()
			var/gasnum = min(rand(1,3), length(goodgases))
			for (var/i = 1 to gasnum)
				var/gas = pick(goodgases)
				breathgas[gas] = round(0.4*goodgases[gas], 0.1)
				goodgases -= gas
		if (!badgas)
			var/list/badgases = gas_data.gases.Copy()
			badgases -= atmosphere.gas
			badgas = pick(badgases)
	generate_map()
	//Основные изменения
	generate_features()
	change_grass_to_clouds()
	spawn_flying_islands()
	//Основные изменения
	for (var/datum/exoplanet_theme/T in themes)
		T.after_map_generation(src)
	if(LAZYLEN(big_artefacts_types))
		generate_big_anomaly_artefacts()
	deploy_weather()
	generate_landing(2)
	update_biome()
	generate_daycycle()
	generate_planet_image()
	START_PROCESSING(SSobj, src)
	//Рисуем задник
	var/turf/any_turf
	for(var/turf/turfs in planetary_area)
		any_turf = turfs
		break
	var/planet_z = get_z(any_turf)
	var/datum/event/change_z_skybox = new /datum/event/change_z_skybox(new /datum/event_meta(EVENT_LEVEL_MAJOR))
	change_z_skybox.affecting_z = list(planet_z)
	change_z_skybox.setup('mods/anomaly/icons/planet_backgrounds.dmi', "flying")
	SSskybox.generate_skybox(planet_z)

/obj/overmap/visitable/sector/exoplanet/flying/proc/change_grass_to_clouds()
	var/list/list_to_change = list()
	///Все данные обьекты не будут заставлять оставлять траву.
	var/list/whitelisted_entities = list(
		/mob/observer/virtual,
		/mob/observer/virtual/mob,
		/atom/movable/lighting_overlay,
		/obj/landmark/exoplanet_spawn/large_plant,
		/mob/observer/ghost
	)
	for(var/turf/simulated/floor/exoplanet/grass/choosed_grass_tile in planetary_area)
		var/good_turf = TRUE
		//Проверяем, чтоб у турфа не было ничего кроме того что указано в списке whitelisted_entities
		for(var/atom/choosed_atom in choosed_grass_tile.contents)
			if(!whitelisted_entities.Find(choosed_atom.type))
				good_turf = FALSE
				//Значит обьект не входит в список дозволенных обьектов, оставим траву на месте.
		if(good_turf)
			LAZYADD(list_to_change, choosed_grass_tile) //Турф чистый, можно менять на облака

	for(var/turf/turf_to_spawn in list_to_change)
		turf_to_spawn.ChangeTurf(/turf/simulated/floor/exoplanet/clouds)
		turf_to_spawn.light_color = "#ffcc99"
		turf_to_spawn.light_range = 3
		turf_to_spawn.update_light()

//TODO: Я пока не смог найти причину по которой острова спавнятся на руинах, меняя тем самым турфы руины на турф острова
/obj/overmap/visitable/sector/exoplanet/flying/proc/spawn_flying_islands()
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
			if(!istype(picked_turf, /turf/simulated/floor/exoplanet/clouds))
				//При попытке размещения диреликта, мы наехали на другой остров/обьект/что угодно
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
	//Расставляем свет для самих островов. Будут чутка светится зелёненьким светом
	for(var/turf/simulated/floor/exoplanet/grass/picked_flying_grass in planetary_area)
		//Если в соседнем тайле нет облачек - подсветим турф
		picked_flying_grass.light_color = "#a3c8a0"
		picked_flying_grass.light_range = 2
		picked_flying_grass.light_power = 2
		picked_flying_grass.update_light()








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
	land_type = /turf/simulated/floor/exoplanet/grass
	//Указываем облака так же и водой, чтоб трава не могла спавнить на них флору и травушку
	water_type = /turf/simulated/floor/exoplanet/grass
	fauna_prob = 0
	flora_prob = 0
	grass_prob = 0


/area/exoplanet/flying
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/grass
