#define RND_MISSION_STATE_AVAILABLE 1
#define RND_MISSION_STATE_ACCEPTED 2
#define RND_MISSION_STATE_COMPLETED 3
#define RND_MISSION_STATE_REWARDED 4

#define RND_MISSION_TYPE_SCAN 1
#define RND_MISSION_TYPE_DELIVER 2
#define RND_MISSION_TYPE_ARTIFACT_STUDY 3
#define RND_MISSION_TYPE_LIVE_CAPTURE 4
#define RND_MISSION_TYPE_PHOTO_DOCUMENTATION 7
#define RND_MISSION_TYPE_WEATHER_DATA 8
#define RND_MISSION_TYPE_BOTANY_CULTIVATION 9

#define RND_SCAN_MIN_SECONDS 1.0
#define RND_SCAN_MAX_SECONDS 2.5
#define RND_SCAN_STEPS 3
#define RND_MAX_ACTIVE_MISSIONS 5

#define RND_MISSION_LOC_EXOPLANET 1
#define RND_MISSION_LOC_ASTEROID 2

/proc/is_exoplanet_area(area/A)
	return istype(A, /area/exoplanet)

/proc/is_rnd_mission_asteroid_area(area/A)
	return istype(A, /area/rnd_mission_asteroid)

/proc/is_rnd_mission_area(area/A)
	return (istype(A, /area/exoplanet) || istype(A, /area/rnd_mission_asteroid))

/proc/pick_rnd_mission_exoplanet_turf()
	return pick_area_and_turf(
		list(GLOBAL_PROC_REF(is_exoplanet_area)),
		list(GLOBAL_PROC_REF(not_turf_contains_dense_objects))
	)

/// Pick a turf from a specific mission asteroid z-level
/proc/pick_rnd_mission_asteroid_turf(z_level)
	return pick_area_turf_in_single_z_level(
		list(GLOBAL_PROC_REF(is_rnd_mission_asteroid_area)),
		list(GLOBAL_PROC_REF(not_turf_contains_dense_objects)),
		z_level
	)

/// Pick a turf for a mission - 65% chance to generate asteroid, 35% to use exoplanet
/proc/pick_rnd_mission_location(datum/rnd_mission/mission)
	if(mission.mission_type == RND_MISSION_TYPE_LIVE_CAPTURE)
		var/turf/T = pick_rnd_mission_exoplanet_turf()
		if(T)
			mission.mission_location_type = RND_MISSION_LOC_EXOPLANET
			return T
		return null

	if(prob(65))
		var/obj/overmap/visitable/sector/rnd_mission_asteroid/asteroid = create_rnd_mission_asteroid()
		if(asteroid)
			mission.mission_sector = asteroid
			mission.mission_location_type = RND_MISSION_LOC_ASTEROID
			var/turf/T = null
			var/tries = 0
			while(!T && tries < 50)
				sleep(2)
				if(LAZYLEN(asteroid.map_z))
					T = pick_rnd_mission_asteroid_turf(asteroid.map_z[1])
				tries++
			if(T)
				return T
	var/turf/T = pick_rnd_mission_exoplanet_turf()
	if(T)
		mission.mission_location_type = RND_MISSION_LOC_EXOPLANET
		return T
	var/obj/overmap/visitable/sector/rnd_mission_asteroid/asteroid2 = create_rnd_mission_asteroid()
	if(asteroid2)
		mission.mission_sector = asteroid2
		mission.mission_location_type = RND_MISSION_LOC_ASTEROID
		var/turf/T2 = null
		var/tries2 = 0
		while(!T2 && tries2 < 50)
			sleep(2)
			if(LAZYLEN(asteroid2.map_z))
				T2 = pick_rnd_mission_asteroid_turf(asteroid2.map_z[1])
			tries2++
		if(T2)
			return T2
	return null

/// Create a dynamically-generated asteroid sector for an RnD mission
/proc/create_rnd_mission_asteroid()
	if(!GLOB.using_map || !GLOB.using_map.use_overmap)
		return null
	var/obj/overmap/visitable/sector/rnd_mission_asteroid/asteroid = new()
	if(!asteroid || !LAZYLEN(asteroid.map_z))
		if(asteroid)
			qdel(asteroid)
		return null
	return asteroid

/proc/get_rnd_mission_corporation_name(corp_id)
	switch(corp_id)
		if(RND_MISSION_CORP_KAPPA)
			return "Kappa Communications"
		if(RND_MISSION_CORP_VEYMED)
			return "Vey-Med"
		if(RND_MISSION_CORP_HEPHAESTUS)
			return "Hephaestus Industries"
		if(RND_MISSION_CORP_NANOTRASEN)
			return "NanoTrasen"
		if(RND_MISSION_CORP_DAIS)
			return "DAIS"
		if(RND_MISSION_CORP_GRAYSON)
			return "Grayson Manufactories Ltd."
		if(RND_MISSION_CORP_AETHER)
			return "Aether Atmospherics"
		if(RND_MISSION_CORP_WARD_TAKAHASHI)
			return "Ward-Takahashi GMB"
		if(RND_MISSION_CORP_EINSTEIN)
			return "Einstein Engines"
		if(RND_MISSION_CORP_XION)
			return "Xion Industrial"
		if(RND_MISSION_CORP_SLATE)
			return "Slate Sisters Engineering"
		if(RND_MISSION_CORP_MAHIMAKU)
			return "Mahimaku Collective"
		if(RND_MISSION_CORP_FOCAL)
			return "Focal Point Dynamics"
		if(RND_MISSION_CORP_BISHOP)
			return "Bishop Cybernetics"
		if(RND_MISSION_CORP_SHELLGUARD)
			return "SHELLGUARD"
		if(RND_MISSION_CORP_MORPHEUS)
			return "Morpheus Cybernetics"
		if(RND_MISSION_CORP_ZENG_HU)
			return "Zeng Hu Pharmaceuticals"
		if(RND_MISSION_CORP_ALMALIKI)
			return "Al-Maliki & Mosley"
	return "Independent"

/proc/get_rnd_mission_corporations()
	return list(
		RND_MISSION_CORP_NANOTRASEN,
		RND_MISSION_CORP_WARD_TAKAHASHI,
		RND_MISSION_CORP_GRAYSON,
		RND_MISSION_CORP_AETHER,
		RND_MISSION_CORP_EINSTEIN,
		RND_MISSION_CORP_XION,
		RND_MISSION_CORP_SLATE,
		RND_MISSION_CORP_FOCAL,
		RND_MISSION_CORP_DAIS,
		RND_MISSION_CORP_KAPPA,
		RND_MISSION_CORP_VEYMED,
		RND_MISSION_CORP_HEPHAESTUS,
		RND_MISSION_CORP_MAHIMAKU,
		RND_MISSION_CORP_BISHOP,
		RND_MISSION_CORP_SHELLGUARD,
		RND_MISSION_CORP_MORPHEUS,
		RND_MISSION_CORP_ZENG_HU,
		RND_MISSION_CORP_ALMALIKI
	)

/proc/get_exoplanet_sector_for_turf(turf/T)
	if(!T)
		return null
	var/obj/overmap/visitable/sector/exoplanet/E = map_sectors["[T.z]"]
	if(istype(E, /obj/overmap/visitable/sector/exoplanet))
		return E
	return null

/proc/get_mission_sector_for_turf(turf/T)
	if(!T)
		return null
	var/obj/overmap/visitable/sector/S = map_sectors["[T.z]"]
	if(istype(S))
		return S
	return null

/// Get a human-readable location type name
/proc/get_rnd_mission_location_name(location_type)
	switch(location_type)
		if(RND_MISSION_LOC_EXOPLANET)
			return "Экзопланета"
		if(RND_MISSION_LOC_ASTEROID)
			return "Астероид"
	return "Локация"

// Get all designs that belong to a specific corporation
/proc/get_corporation_designs(corp_id)
	var/list/designs = list()
	if(!SSresearch || !SSresearch.all_tech_nodes)
		return designs

	for(var/datum/technology/tech_node in SSresearch.all_tech_nodes)
		if(!tech_node.required_corp_id || tech_node.required_corp_id != corp_id)
			continue
		if(!tech_node.unlocks_designs || !length(tech_node.unlocks_designs))
			continue
		for(var/design_id in tech_node.unlocks_designs)
			designs[design_id] = TRUE

	return designs

// Find which corporation owns a given design
/proc/get_design_corporation(design_id)
	if(!SSresearch || !SSresearch.all_tech_nodes)
		return null

	for(var/datum/technology/tech_node in SSresearch.all_tech_nodes)
		if(!tech_node.required_corp_id)
			continue
		if(!tech_node.unlocks_designs || !length(tech_node.unlocks_designs))
			continue
		if(design_id in tech_node.unlocks_designs)
			return tech_node.required_corp_id

	return null

// Get a random design from a corporation's tech tree
/proc/get_random_corporation_design(corp_id)
	var/list/corp_designs = get_corporation_designs(corp_id)
	if(!length(corp_designs))
		return null

	var/picked_design = pick(corp_designs)
	return picked_design

/datum/rnd_mission
	var/id = ""
	var/title = "R&D mission"
	var/description = "Complete the assigned objective."
	var/state = RND_MISSION_STATE_AVAILABLE
	var/mission_type = RND_MISSION_TYPE_SCAN
	var/assigned_ckey
	var/corporation_id = RND_MISSION_CORP_NANOTRASEN
	var/obj/machinery/computer/rd_mission_console/assigned_console
	var/reward_pack_id
	var/reward_pack_name = "Contract unlock pack"
	var/list/reward_design_ids = list()
	var/reward_node_id
	var/is_reputation_mission = FALSE
	var/reputation_reward = 0
	var/reputation_penalty = 0
	var/is_corporate_deal = FALSE
	var/competitor_corp_id = null  // Для корпоративных сделок - чей предмет требуется
	var/list/required_design_ids = list()  // Дизайны конкурента для сдачи
	var/corporate_item_delivered = FALSE
	var/min_cost = 0
	var/target_typepath = /obj/item/rnd_mission_target
	var/obj/item/rnd_mission_target/target
	var/target_delivered = FALSE
	var/target_mob_typepath
	var/mob/living/target_mob
	var/target_mob_name = "Неизвестное существо"
	var/target_mob_desc = "Описание недоступно."
	var/target_mob_habitat = "Среда обитания неизвестна."
	var/live_capture_delivered = FALSE
	var/target_location_type = "Локация"
	var/target_area_name = "Неизвестная зона"
	var/target_coords = "неизвестны"
	// Botany cultivation
	var/required_seed_name
	var/required_seed_display
	var/required_potency = 0
	var/required_trait
	var/required_trait_name
	var/delivered_botany_sample = FALSE
	// Photo documentation
	var/required_photo_count = 3
	var/list/submitted_photos = list()
	var/photo_target_type
	var/required_photo_z
	// Weather data
	var/list/weather_sensors = list()
	var/required_sensor_count = 3
	// Mission location tracking
	var/mission_location_type = RND_MISSION_LOC_EXOPLANET
	var/obj/overmap/visitable/sector/rnd_mission_asteroid/mission_sector

/datum/rnd_mission/proc/get_brief()
	var/corp_name = get_rnd_mission_corporation_name(corporation_id)
	return "[corp_name] [title] — [description]"

/datum/rnd_mission/proc/accept(obj/machinery/computer/rd_mission_console/console, mob/living/user)
	if(state != RND_MISSION_STATE_AVAILABLE)
		return FALSE

	var/needs_spawn = (target_typepath || mission_type == RND_MISSION_TYPE_LIVE_CAPTURE)
	var/turf/spawn_turf
	var/obj/overmap/visitable/sector/exoplanet/planet
	if(needs_spawn)
		spawn_turf = pick_rnd_mission_location(src)
		if(!spawn_turf)
			to_chat(user, SPAN_WARNING("Не удалось найти подходящую локацию для задания."))
			return FALSE

		var/area/spawn_area = get_area(spawn_turf)
		if(spawn_area)
			target_area_name = spawn_area.name
			target_location_type = get_rnd_mission_location_name(mission_location_type)
		target_coords = "[spawn_turf.x],[spawn_turf.y],[spawn_turf.z]"
		if(mission_location_type == RND_MISSION_LOC_EXOPLANET)
			planet = get_exoplanet_sector_for_turf(spawn_turf)

	if(mission_type == RND_MISSION_TYPE_ARTIFACT_STUDY && spawn_turf)
		target = new /obj/machinery/artifact(spawn_turf)
		target.bound_mission = src
		target.bound_mission_ref = "\ref[src]"
		target.name = "[target.name] ([title])"
	else if(target_typepath && spawn_turf)
		target = new target_typepath(spawn_turf)
		target.bound_mission = src
		target.bound_mission_ref = "\ref[src]"
		target.name = "[target.name] ([title])"

	if(mission_type == RND_MISSION_TYPE_LIVE_CAPTURE && spawn_turf)
		if(!target_mob_typepath)
			if(planet && LAZYLEN(planet.fauna_types))
				target_mob_typepath = pick(planet.fauna_types)
			else
				target_mob_typepath = /mob/living/simple_animal/thinbug
		target_mob = new target_mob_typepath(spawn_turf)
		if(planet && istype(target_mob, /mob/living/simple_animal))
			planet.adapt_animal(target_mob)
		target_mob_name = target_mob.real_name ? target_mob.real_name : target_mob.name
		if(target_mob.desc)
			target_mob_desc = target_mob.desc
		if(planet && planet.desc)
			target_mob_habitat = planet.desc
		else
			target_mob_habitat = "Поверхность: [target_area_name]"

	assigned_ckey = user.ckey
	assigned_console = console
	state = RND_MISSION_STATE_ACCEPTED

	var/mission_hint = "Выполните условия. Предметы упакуйте в cargo wrap и отправьте через дрон пад используя designator."
	if(target)
		mission_hint = "Цель размещена: [target_location_type] [target_area_name]. Координаты цели: [target_coords]. Предмет упакуйте в cargo wrap, положите на дрон пад и используйте designator для отправки."
	if(mission_type == RND_MISSION_TYPE_LIVE_CAPTURE && target_mob)
		mission_hint = "Цель размещена: [target_location_type] [target_area_name]. Координаты цели: [target_coords]. Цель: [target_mob_name]. Описание: [target_mob_desc] Среда обитания: [target_mob_habitat]. Требуется стазис-клетка и отправка через миссионный дрон пад (используйте на дрон паде вручную)."
	to_chat(user, SPAN_NOTICE("Принят контракт [get_rnd_mission_corporation_name(corporation_id)]: [title]. [mission_hint]"))
	log_and_message_admins("accepted R&D mission '[title]'.", user)
	return TRUE

/datum/rnd_mission/proc/is_complete()
	// Репутационные миссии всегда готовы быть сданы когда приняты
	if(is_reputation_mission)
		return TRUE

	// Корпоративные сделки требуют доставки предмета конкурента
	if(is_corporate_deal)
		return corporate_item_delivered

	if(state != RND_MISSION_STATE_ACCEPTED)
		return FALSE

	if(mission_type == RND_MISSION_TYPE_LIVE_CAPTURE)
		return live_capture_delivered

	if(mission_type == RND_MISSION_TYPE_BOTANY_CULTIVATION)
		return delivered_botany_sample

	if(mission_type == RND_MISSION_TYPE_PHOTO_DOCUMENTATION)
		return LAZYLEN(submitted_photos) >= required_photo_count

	if(mission_type == RND_MISSION_TYPE_WEATHER_DATA)
		return LAZYLEN(weather_sensors) >= required_sensor_count

	if(!target)
		return FALSE

	if(mission_type == RND_MISSION_TYPE_SCAN)
		return target.scanned

	if(mission_type == RND_MISSION_TYPE_DELIVER)
		return target_delivered

	if(mission_type == RND_MISSION_TYPE_ARTIFACT_STUDY)
		return target_delivered

	return FALSE

/datum/rnd_mission/proc/try_complete(obj/machinery/computer/rd_mission_console/console, mob/living/user)
	to_chat(user, SPAN_WARNING("Сдача контрактов выполняется через миссионный дрон пад."))
	return FALSE

/datum/rnd_mission/proc/complete_mission(obj/machinery/computer/rd_mission_console/console, mob/living/user)
	state = RND_MISSION_STATE_COMPLETED
	if(!grant_rewards(console, user))
		if(user)
			to_chat(user, SPAN_WARNING("Задание выполнено, но не найдена R&D консоль для выдачи награды."))
		return FALSE

	state = RND_MISSION_STATE_REWARDED

	// Специальное сообщение для корпоративных сделок
	if(is_corporate_deal)
		var/corp_name = get_rnd_mission_corporation_name(corporation_id)
		var/competitor_name = get_rnd_mission_corporation_name(competitor_corp_id)
		if(user)
			to_chat(user, SPAN_NOTICE("Корпоративная сделка выполнена! Репутация с [corp_name]: +[reputation_reward]. Репутация с [competitor_name]: -[reputation_penalty]."))
			log_and_message_admins("completed corporate deal R&D mission '[title]'.", user)
		return TRUE

	// Специальное сообщение для репутационных миссий
	if(is_reputation_mission)
		var/reward_level = (reputation_reward >= 25) ? "ОСОБЫЙ контракт выполнен!" : "Контракт выполнен."
		if(user)
			to_chat(user, SPAN_NOTICE("[reward_level] Репутация у [get_rnd_mission_corporation_name(corporation_id)] увеличилась на [reputation_reward] пункт(ов)."))
			log_and_message_admins("completed reputation R&D mission '[title]'.", user)
		return TRUE

	if(user)
		to_chat(user, SPAN_NOTICE("Контракт '[title]' от [get_rnd_mission_corporation_name(corporation_id)] завершён. Пакет '[reward_pack_name]' выдан."))
		log_and_message_admins("completed R&D mission '[title]'.", user)
	cleanup_mission_sector()
	return TRUE

/// Clean up a dynamically generated asteroid sector after mission completion
/datum/rnd_mission/proc/cleanup_mission_sector()
	if(!mission_sector || QDELETED(mission_sector))
		return
	// Schedule cleanup with a delay so players can evacuate
	var/obj/overmap/visitable/sector/rnd_mission_asteroid/asteroid = mission_sector
	mission_sector = null
	spawn(5 MINUTES)
		if(!QDELETED(asteroid))
			asteroid.cleanup_and_destroy()

/datum/rnd_mission/proc/get_reward_design_ids(obj/machinery/computer/rd_mission_console/console)
	return reward_design_ids

/datum/rnd_mission/proc/try_submit_item(obj/machinery/delivery_device, obj/item/I, mob/living/user)
	if(istype(delivery_device, /obj/machinery/computer/rd_mission_console))
		to_chat(user, SPAN_WARNING("Сдача контрактов выполняется через миссионный дрон пад."))
		return FALSE
	if(!istype(delivery_device, /obj/machinery/drone_pad/rd_mission))
		return FALSE

	// Корпоративные сделки - проверка предмета конкурента
	if(is_corporate_deal)
		if(!I || !I.type)
			to_chat(user, SPAN_WARNING("Предмет не может быть обработан."))
			return FALSE

		// Проверяем, соответствует ли предмет одному из требуемых дизайнов
		var/item_design_id = null
		for(var/design_id in required_design_ids)
			var/datum/design/D = SSresearch.get_design(design_id)
			if(D && D.build_path == I.type)
				item_design_id = design_id
				break

		if(!item_design_id)
			var/competitor_name = get_rnd_mission_corporation_name(competitor_corp_id)
			to_chat(user, SPAN_WARNING("Этот предмет не соответствует требованиям. Требуется дизайн от [competitor_name]."))
			return FALSE

		// Проверяем, что предмет действительно принадлежит конкуренту
		var/item_corp = get_design_corporation(item_design_id)
		if(item_corp != competitor_corp_id)
			to_chat(user, SPAN_WARNING("Этот предмет не принадлежит конкурирующей корпорации."))
			return FALSE

		user.drop_item()
		I.forceMove(delivery_device)
		corporate_item_delivered = TRUE
		to_chat(user, SPAN_NOTICE("Предмет конкурента отправлен через дрон пад. Миссия готова к завершению."))
		return TRUE

	if(mission_type == RND_MISSION_TYPE_PHOTO_DOCUMENTATION && istype(I, /obj/item/photo))
		var/obj/item/photo/photo = I
		if(!photo_target_type)
			if(required_photo_z && photo.photo_z != required_photo_z)
				var/photo_z = isnull(photo.photo_z) ? "?" : "[photo.photo_z]"
				to_chat(user, SPAN_WARNING("Фото сделано в неверном месте(получено: [photo_z])."))
				return FALSE
			user.drop_item()
			photo.forceMove(delivery_device)
			LAZYADD(submitted_photos, photo)
			to_chat(user, SPAN_NOTICE("Фото отправлено. Доставлено: [LAZYLEN(submitted_photos)]/[required_photo_count]."))
			return TRUE
		if(required_photo_z && photo.photo_z != required_photo_z)
			var/photo_z = isnull(photo.photo_z) ? "?" : "[photo.photo_z]"
			to_chat(user, SPAN_WARNING("Фото сделано в неверном месте(получено: [photo_z])."))
			return FALSE
		user.drop_item()
		photo.forceMove(delivery_device)
		LAZYADD(submitted_photos, photo)
		to_chat(user, SPAN_NOTICE("Фото отправлено. Доставлено: [LAZYLEN(submitted_photos)]/[required_photo_count]."))
		return TRUE

	// Для ARTIFACT_STUDY: сдача артефакта и отчета
	if(mission_type == RND_MISSION_TYPE_ARTIFACT_STUDY)
		if(istype(I, /obj/machinery/artifact))
			if(I != target)
				to_chat(user, SPAN_WARNING("Этот артефакт не относится к текущему заданию."))
				return FALSE
			user.drop_item()
			I.forceMove(delivery_device)
			target_delivered = TRUE
			to_chat(user, SPAN_NOTICE("Артефакт отправлен через дрон пад."))
			return TRUE

	return FALSE

/datum/rnd_mission/proc/register_weather_sensor(obj/item/device/weather_sensor/sensor, mob/living/user)
	if(mission_type != RND_MISSION_TYPE_WEATHER_DATA)
		return FALSE
	if(state != RND_MISSION_STATE_ACCEPTED)
		return FALSE

	if(!sensor.deployed)
		to_chat(user, SPAN_WARNING("Датчик должен быть установлен!"))
		return FALSE

	// Check if this sensor is already registered
	if("\ref[sensor]" in weather_sensors)
		to_chat(user, SPAN_WARNING("Этот датчик уже зарегистрирован."))
		return FALSE

	// Check if location is too close to another sensor
	var/turf/sensor_turf = get_turf(sensor)
	for(var/sensor_ref in weather_sensors)
		var/obj/item/device/weather_sensor/existing = locate(sensor_ref)
		if(existing)
			var/turf/existing_turf = get_turf(existing)
			if(get_dist(sensor_turf, existing_turf) < 50)
				to_chat(user, SPAN_WARNING("Эта локация слишком близка к другому датчику!"))
				return FALSE

	LAZYADD(weather_sensors, "\ref[sensor]")
	sensor.linked_mission = src
	to_chat(user, SPAN_NOTICE("Датчик зарегистрирован. Прогресс: [LAZYLEN(weather_sensors)]/[required_sensor_count]."))
	return TRUE

/datum/rnd_mission/proc/grant_rewards(obj/machinery/computer/rd_mission_console/console, mob/living/user)
	var/obj/machinery/computer/rdconsole/rd = console.find_nearest_rdconsole()
	if(!rd || !rd.files)
		return FALSE

	// Обработка корпоративных сделок
	if(is_corporate_deal)
		if(reputation_reward > 0)
			rd.files.ChangeCorporationReputation(corporation_id, reputation_reward)
		if(reputation_penalty > 0 && competitor_corp_id)
			rd.files.ChangeCorporationReputation(competitor_corp_id, -reputation_penalty)
		SSnano.update_uis(rd)
		return TRUE

	// Обработка репутационных миссий
	if(is_reputation_mission)
		if(reputation_reward > 0)
			rd.files.ChangeCorporationReputation(corporation_id, reputation_reward)
			SSnano.update_uis(rd)
		return TRUE

	if(reward_node_id)
		var/datum/technology/tech_node = get_rnd_reward_tech_node_by_id(reward_node_id)
		if(tech_node)
			if(!rd.files.IsResearched(tech_node))
				rd.files.UnlockTechology(tech_node, force = TRUE)
				SSnano.update_uis(rd)
			return TRUE

	var/list/designs_to_unlock = get_reward_design_ids(console)
	var/unlocked_any = FALSE
	for(var/design_id in designs_to_unlock)
		var/datum/design/D = SSresearch.get_design(design_id)
		if(!D)
			continue
		rd.files.AddDesign2Known(D)
		unlocked_any = TRUE

	if(unlocked_any)
		SSnano.update_uis(rd)
	return unlocked_any


/datum/rnd_mission/scan_exoplanet
	id = "scan_exoplanet"
	title = "Полевое сканирование"
	description = "Найдите и отсканируйте целевой объект научным сканером. Локация будет определена при принятии контракта."
	mission_type = RND_MISSION_TYPE_SCAN

/datum/rnd_mission/scan_exoplanet/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)

/datum/rnd_mission/deliver_specimen
	id = "deliver_specimen"
	title = "Доставка образца"
	description = "Отправьте целевой объект. Упакуйте предмет в cargo wrap, положите на дрон пад и используйте designator для отправки."
	mission_type = RND_MISSION_TYPE_DELIVER
	corporation_id = RND_MISSION_CORP_HEPHAESTUS
	reward_pack_id = "hephaestus_recovery"

/datum/rnd_mission/deliver_specimen/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)

/datum/rnd_mission/artifact_study
	id = "artifact_study"
	title = "Исследование артефакта"
	description = "Найдите ксеноархеологический артефакт, изучите его с помощью артефакт-анализатора. Для завершения миссии сдайте артефакт и отчет сканирования через миссионный дрон пад."
	mission_type = RND_MISSION_TYPE_ARTIFACT_STUDY
	corporation_id = RND_MISSION_CORP_NANOTRASEN
	reward_pack_id = "nanotrasen_esoteric"
	target_typepath = null

/datum/rnd_mission/artifact_study/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)

/datum/rnd_mission/live_capture
	id = "live_capture"
	title = "Живой образец"
	description = "Поймайте живое существо, поместите в стазис-клетку и отправьте через миссионный дрон пад."
	mission_type = RND_MISSION_TYPE_LIVE_CAPTURE
	corporation_id = RND_MISSION_CORP_VEYMED
	reward_pack_id = "veymed_bioproduct"
	target_typepath = null

/datum/rnd_mission/live_capture/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)

/datum/rnd_mission/photo_documentation
	id = "photo_doc"
	title = "Фотодокументация экспедиции"
	description = "Сделайте фотографии интересных объектов. Упакуйте фото в cargo wrap и отправьте через дрон пад."
	mission_type = RND_MISSION_TYPE_PHOTO_DOCUMENTATION
	corporation_id = RND_MISSION_CORP_NANOTRASEN
	reward_pack_id = "nanotrasen_esoteric"
	target_typepath = null
	required_photo_count = 3

/datum/rnd_mission/photo_documentation/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)
	var/turf/photo_turf = pick_rnd_mission_exoplanet_turf()
	if(photo_turf)
		required_photo_z = photo_turf.z
		var/area/photo_area = get_area(photo_turf)
		if(photo_area)
			target_area_name = photo_area.name
			var/obj/overmap/visitable/sector/S = get_mission_sector_for_turf(photo_turf)
			target_location_type = S ? S.name : "Локация"
		target_coords = "[photo_turf.x],[photo_turf.y],[photo_turf.z]"
		description = "Сделайте [required_photo_count] фотографии на [target_location_type] ([target_area_name]). Упакуйте фото и отправьте через дрон пад."
	else
		description = "Сделайте [required_photo_count] фотографии. Упакуйте фото и отправьте через дрон пад."

/datum/rnd_mission/weather_data_collection
	id = "weather_data"
	title = "Метеорологические данные"
	description = "Установите датчики погоды для сбора атмосферных данных и передайте их через миссионный дрон пад."
	mission_type = RND_MISSION_TYPE_WEATHER_DATA
	target_typepath = null
	required_sensor_count = 3

/datum/rnd_mission/weather_data_collection/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)
	description = "Установите [required_sensor_count] метеорологических датчика на целевой локации. Используйте специальные маячки и передайте данные через миссионный дрон пад."


/datum/rnd_mission/botany_cultivation
	id = "botany_cultivation"
	title = "Генетическое выращивание"
	description = "Вырастите растение с заданными параметрами и отправьте образец через миссионный дрон пад."
	mission_type = RND_MISSION_TYPE_BOTANY_CULTIVATION
	corporation_id = RND_MISSION_CORP_VEYMED
	reward_pack_id = "veymed_bioproduct"
	target_typepath = null

/datum/rnd_mission/botany_cultivation/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)

	var/list/trait_options = list(
		list("id" = TRAIT_BIOLUM, "name" = "биолюминесценция"),
		list("id" = TRAIT_JUICY, "name" = "сочность"),
		list("id" = TRAIT_STINGS, "name" = "шипы"),
		list("id" = TRAIT_EXPLOSIVE, "name" = "взрывчатость"),
		list("id" = TRAIT_PRODUCES_POWER, "name" = "генерация энергии"),
		list("id" = TRAIT_TELEPORTING, "name" = "блюспейс-реакция")
	)

	var/datum/seed/seed
	if(SSplants && SSplants.seeds && length(SSplants.seeds))
		var/list/candidates = list()
		for(var/seed_id in SSplants.seeds)
			var/datum/seed/seed_candidate = SSplants.seeds[seed_id]
			if(!seed_candidate)
				continue
			if(seed_candidate.product_type)
				continue
			if(seed_candidate.name == "new line")
				continue
			candidates += seed_candidate
		if(length(candidates))
			seed = pick(candidates)

	if(!seed)
		seed = SSplants && SSplants.seeds ? SSplants.seeds["wheat"] : null

	if(seed)
		required_seed_name = seed.name
		required_seed_display = seed.display_name ? seed.display_name : seed.seed_name
		var/base_potency = max(1, seed.get_trait(TRAIT_POTENCY))
		required_potency = min(max(base_potency + rand(5, 25), 10), 120)
		var/list/trait_pick = pick(trait_options)
		required_trait = trait_pick["id"]
		required_trait_name = trait_pick["name"]
		target_location_type = "Станция"
		target_area_name = "Гидропоника"
		target_coords = "внутри станции"
		description = "Вырастите [required_seed_display] с потенцией не ниже [required_potency] и свойством: [required_trait_name]. Отправьте образец через миссионный телепортер."


/datum/rnd_mission/ward_takahashi_calibration
	id = "ward_calibration"
	title = "Калибровка сенсоров"
	description = "Найдите и отсканируйте тестовый модуль научным сканером. Передайте данные через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_SCAN
	corporation_id = RND_MISSION_CORP_WARD_TAKAHASHI
	reward_pack_id = "ward_takahashi_tools"
	target_typepath = /obj/item/rnd_mission_target/tech_module

/datum/rnd_mission/ward_takahashi_calibration/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/grayson_ore_delivery
	id = "grayson_ore_delivery"
	title = "Доставка образца породы"
	description = "Отправьте образец породы через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_DELIVER
	corporation_id = RND_MISSION_CORP_GRAYSON
	reward_pack_id = "grayson_mining"
	target_typepath = /obj/item/rnd_mission_target/ore_sample

/datum/rnd_mission/grayson_ore_delivery/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/einstein_power_scan
	id = "einstein_power_scan"
	title = "Испытание энергоузла"
	description = "Найдите и отсканируйте энергетический модуль. Передайте данные через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_SCAN
	corporation_id = RND_MISSION_CORP_EINSTEIN
	reward_pack_id = "einstein_power"
	target_typepath = /obj/item/rnd_mission_target/power_module

/datum/rnd_mission/einstein_power_scan/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/xion_parts_delivery
	id = "xion_parts_delivery"
	title = "Промышленные компоненты"
	description = "Отправьте промышленные компоненты через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_DELIVER
	corporation_id = RND_MISSION_CORP_XION
	reward_pack_id = "xion_industrial"
	target_typepath = /obj/item/rnd_mission_target/industrial_component

/datum/rnd_mission/xion_parts_delivery/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/focal_power_delivery
	id = "focal_power_delivery"
	title = "Модуль энергосети"
	description = "Отправьте модуль энергосети через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_DELIVER
	corporation_id = RND_MISSION_CORP_FOCAL
	reward_pack_id = "focal_power"
	target_typepath = /obj/item/rnd_mission_target/power_grid_module

/datum/rnd_mission/focal_power_delivery/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/dais_photo_documentation
	id = "dais_photo_doc"
	title = "Сетевой отчет"
	description = "Сделайте фотографии телеком-узлов в заданной зоне и отправьте через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_PHOTO_DOCUMENTATION
	corporation_id = RND_MISSION_CORP_DAIS
	reward_pack_id = "dais_network"
	target_typepath = null
	required_photo_count = 2

/datum/rnd_mission/dais_photo_documentation/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)
	var/turf/photo_turf = pick_rnd_mission_exoplanet_turf()
	if(photo_turf)
		required_photo_z = photo_turf.z
		var/area/photo_area = get_area(photo_turf)
		if(photo_area)
			target_area_name = photo_area.name
			var/obj/overmap/visitable/sector/S = get_mission_sector_for_turf(photo_turf)
			target_location_type = S ? S.name : "Локация"
		target_coords = "[photo_turf.x],[photo_turf.y],[photo_turf.z]"
		description = "Сделайте [required_photo_count] фото в зоне [target_area_name] и отправьте через миссионный телепортер."
	else
		description = "Сделайте [required_photo_count] фото и отправьте через миссионный телепортер."


/datum/rnd_mission/kappa_relay_scan
	id = "kappa_relay_scan"
	title = "Стабилизация ретранслятора"
	description = "Найдите и отсканируйте модуль ретранслятора. Передайте данные через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_SCAN
	corporation_id = RND_MISSION_CORP_KAPPA
	reward_pack_id = "kappa_comms"
	target_typepath = /obj/item/rnd_mission_target/relay_node

/datum/rnd_mission/kappa_relay_scan/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/mahimaku_precision_delivery
	id = "mahimaku_precision_delivery"
	title = "Прецизионный прибор"
	description = "Отправьте прецизионный прибор через миссионный телепортер."
	mission_type = RND_MISSION_TYPE_DELIVER
	corporation_id = RND_MISSION_CORP_MAHIMAKU
	reward_pack_id = "mahimaku_precision"
	target_typepath = /obj/item/rnd_mission_target/precision_instrument

/datum/rnd_mission/mahimaku_precision_delivery/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/almaliki_ballistic_test
	id = "almaliki_ballistic_test"
	title = "Баллистический тест-модуль"
	description = "Найдите и отсканируйте баллистический тест-модуль. Полевые данные необходимы для калибровки стрелкового вооружения Al-Maliki & Mosley."
	mission_type = RND_MISSION_TYPE_SCAN
	corporation_id = RND_MISSION_CORP_ALMALIKI
	reward_pack_id = "almaliki_ballistics"
	target_typepath = /obj/item/rnd_mission_target/ballistic_module

/datum/rnd_mission/almaliki_ballistic_test/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/bishop_neural_interface
	id = "bishop_neural_interface"
	title = "Нейроимплант-прототип"
	description = "Доставьте прототип нейроинтерфейса. Модуль необходим Bishop Cybernetics для испытаний новой серии кибернетических имплантов."
	mission_type = RND_MISSION_TYPE_DELIVER
	corporation_id = RND_MISSION_CORP_BISHOP
	reward_pack_id = "bishop_neural"
	target_typepath = /obj/item/rnd_mission_target/neural_interface

/datum/rnd_mission/bishop_neural_interface/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/morpheus_synth_diagnostics
	id = "morpheus_synth_diagnostics"
	title = "Диагностика синтетического ядра"
	description = "Найдите синтетическое ядро, проведите полную диагностику научным инструментом и отправьте модуль в лабораторию Morpheus Cybernetics."
	mission_type = RND_MISSION_TYPE_ARTIFACT_STUDY
	corporation_id = RND_MISSION_CORP_MORPHEUS
	reward_pack_id = "morpheus_synth"
	target_typepath = /obj/item/rnd_mission_target/synth_core

/datum/rnd_mission/morpheus_synth_diagnostics/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/datum/rnd_mission/zeng_hu_specimen_capture
	id = "zeng_hu_specimen"
	title = "Фармацевтический биообразец"
	description = "Поймайте живое существо для фармацевтического исследования. Используйте стазис-клетку и миссионный дрон пад для транспортировки."
	mission_type = RND_MISSION_TYPE_LIVE_CAPTURE
	corporation_id = RND_MISSION_CORP_ZENG_HU
	reward_pack_id = "zeng_hu_pharma"
	target_typepath = null

/datum/rnd_mission/zeng_hu_specimen_capture/New()
	. = ..()
	apply_rnd_mission_reward_pack(src, reward_pack_id)


/obj/item/rnd_mission_target
	name = "unknown exoplanet sample"
	desc = "Mission-critical sample for the Science Department."
	icon = 'mods/RnD/icons/device.dmi'
	icon_state = "science"
	w_class = ITEM_SIZE_SMALL

	var/scanned = FALSE
	var/bound_mission_ref
	var/datum/rnd_mission/bound_mission
	var/scan_progress = 0
	var/scan_last_time = 0
	var/scan_active = FALSE

/obj/item/rnd_mission_target/artifact
	name = "sealed anomaly artifact"
	desc = "A sealed artifact package marked for laboratory study."

/obj/item/rnd_mission_target/tech_module
	name = "sealed tech module"
	desc = "A sealed electronics module prepared for field calibration."

/obj/item/rnd_mission_target/ore_sample
	name = "sealed ore sample"
	desc = "A sealed ore sample prepared for industrial analysis."

/obj/item/rnd_mission_target/power_module
	name = "sealed power module"
	desc = "A sealed power module awaiting diagnostic scan."

/obj/item/rnd_mission_target/industrial_component
	name = "sealed industrial component"
	desc = "A sealed industrial component prepared for delivery."

/obj/item/rnd_mission_target/power_grid_module
	name = "sealed power grid module"
	desc = "A sealed module for power grid diagnostics."

/obj/item/rnd_mission_target/relay_node
	name = "sealed relay node"
	desc = "A sealed communications relay node prepared for scanning."

/obj/item/rnd_mission_target/precision_instrument
	name = "sealed precision instrument"
	desc = "A sealed precision instrument requiring delivery."

/obj/item/rnd_mission_target/ballistic_module
	name = "sealed ballistic test module"
	desc = "A sealed ballistic testing module prepared for field calibration. Property of Al-Maliki & Mosley."

/obj/item/rnd_mission_target/neural_interface
	name = "sealed neural interface prototype"
	desc = "A sealed neural interface prototype module. Property of Bishop Cybernetics."

/obj/item/rnd_mission_target/synth_core
	name = "sealed synthetic core"
	desc = "A sealed synthetic diagnostic core module requiring full analysis. Property of Morpheus Cybernetics."

/obj/item/rnd_mission_target/proc/scan_with_tool(mob/living/user)
	if(scanned)
		to_chat(user, SPAN_NOTICE("Этот образец уже отсканирован."))
		return FALSE

	if(!bound_mission || bound_mission.state != RND_MISSION_STATE_ACCEPTED)
		to_chat(user, SPAN_WARNING("Этот образец не связан с активным заданием."))
		return FALSE

	if(!(bound_mission.mission_type in list(RND_MISSION_TYPE_SCAN, RND_MISSION_TYPE_ARTIFACT_STUDY)))
		to_chat(user, SPAN_WARNING("Для этого задания требуется доставка, а не сканирование."))
		return FALSE

	var/now = world.time
	var/min_ticks = max(1, round(RND_SCAN_MIN_SECONDS / world.tick_lag))
	var/max_ticks = max(min_ticks, round(RND_SCAN_MAX_SECONDS / world.tick_lag))
	if(!scan_active)
		scan_active = TRUE
		scan_progress = 1
		scan_last_time = now
		to_chat(user, SPAN_NOTICE("Сканирование начато. Выполните ещё [RND_SCAN_STEPS - 1] импульса с интервалом [RND_SCAN_MIN_SECONDS]-[RND_SCAN_MAX_SECONDS] сек."))
		return TRUE

	var/delta = now - scan_last_time
	if(delta < min_ticks || delta > max_ticks)
		scan_progress = 1
		scan_last_time = now
		to_chat(user, SPAN_WARNING("Сбой синхронизации. Начните ритм заново."))
		return TRUE

	scan_progress += 1
	scan_last_time = now
	if(scan_progress < RND_SCAN_STEPS)
		to_chat(user, SPAN_NOTICE("Импульс принят. Осталось [RND_SCAN_STEPS - scan_progress]."))
		return TRUE

	scan_active = FALSE
	scanned = TRUE
	if(bound_mission.mission_type == RND_MISSION_TYPE_ARTIFACT_STUDY)
		to_chat(user, SPAN_NOTICE("Исследование артефакта завершено. Отправьте объект через миссионный телепортер."))
	else
		to_chat(user, SPAN_NOTICE("Сканирование завершено. Передайте данные через миссионный телепортер."))
	return TRUE




/obj/item/device/science_tool/afterattack(obj/O, mob/living/user)
	. = ..()
	if(istype(O, /obj/item/rnd_mission_target))
		var/obj/item/rnd_mission_target/target = O
		target.scan_with_tool(user)
