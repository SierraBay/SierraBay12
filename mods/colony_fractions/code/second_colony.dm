/singleton/submap_archetype/playablecolony2
	crew_jobs = list(/datum/job/submap/colonist/ship, /datum/job/submap/colonist/scientist/ship, \
	/datum/job/submap/colonist/medic/ship, /datum/job/submap/colonist/engineer/ship, /datum/job/submap/colonist/leader/ship)

/datum/job/submap/colonist/leader/ship
	title = "Colony Ship Leader"
	info = "You are a Colonist Leader, living on the rim of the explored space. Control your landed colony ship and defend its interests."

/datum/job/submap/colonist/ship
	title = "Colony Ship Colonist"
	supervisors = "Ship Leader"
/datum/job/submap/colonist/scientist/ship
	title = "Colony Ship Scientist"
	supervisors = "Ship Leader"
/datum/job/submap/colonist/medic/ship
	title = "Colony Ship Medic"
	supervisors = "Ship Leader"
/datum/job/submap/colonist/engineer/ship
	title = "Colony Ship Engineer"
	supervisors = "Ship Leader"

/obj/submap_landmark/spawnpoint/ship_leader_spawn
	name = "Colony Ship Leader"

/obj/submap_landmark/spawnpoint/colonist_spawn2
	name = "Colony Ship Colonist"

/obj/submap_landmark/spawnpoint/colonist_scientist_spawn2
	name = "Colony Ship Scientist"

/obj/submap_landmark/spawnpoint/colonist_medic_spawn2
	name = "Colony Ship Medic"

/obj/submap_landmark/spawnpoint/colonist_engineer_spawn2
	name = "Colony Ship Engineer"

/singleton/hierarchy/outfit/job/colonist/leader
	name = OUTFIT_JOB_NAME("Colonist Leader")
	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/merchant/colony_leader)

// changing after New() proc because original playablecolony2 has suffixes which load before override
/datum/map_template/ruin/exoplanet/playablecolony2/New()
	. = ..()
	mappaths = list('mods/colony_fractions/maps/colony_ship.dmm')


/datum/map_template/ruin/exoplanet/playablecolony2/load(turf/T, centered=FALSE)
	if(!GLOB.choose_colony_type)
		log_and_message_admins("ОШИБКА: пустой выбранный тип колонии!.")
		GLOB.choose_colony_type = "СЛУЧАЙНЫЙ"
	if(GLOB.choose_colony_type == "СЛУЧАЙНЫЙ")
		var/number = rand(1,100)
		if(number < 30 || number == 30)
			GLOB.last_colony_type = "НАНОТРЕЙЗЕН"
		else if(number < 50 || number == 50)
			GLOB.last_colony_type = "ГКК"
		else if(number < 75 || number == 75)
			GLOB.last_colony_type = "ЦПСС"
		else if(number < 100 || number == 100)
			GLOB.last_colony_type = "НЕЗАВИСИМАЯ"
	else
		GLOB.last_colony_type = GLOB.choose_colony_type
		if(!(GLOB.last_colony_type in list("ГКК","ЦПСС","НАНОТРЕЙЗЕН","НЕЗАВИСИМАЯ")))
			log_and_message_admins("ОШИБКА: Некорректная работа кода колонии, выбран несуществующий тип: [GLOB.choose_colony_type].")
			log_and_message_admins("Колония выбрана стандартного типа - НАНОТРЕЙЗЕН.")
			if(GLOB.error_colony_reaction == "Прервать спавн колонии")
				log_and_message_admins("Спавн колонии прерван исходя из настроек спавна колонии.")
				return
			GLOB.last_colony_type = "НАНОТРЕЙЗЕН"
	log_and_message_admins("Начал спавн колонии следующего типа: [GLOB.last_colony_type].")

	.=..()

// --- FA: навпоинт (лендмарк) ---
/obj/shuttle_landmark/nav_facolony
	name = "Landing Site"
	landmark_tag = "nav_facolony_1"
	flags = SLANDMARK_FLAG_AUTOSET
	base_turf = /turf/simulated/floor/plating
	// base_area НЕ задаём руками — AUTOSET сам возьмёт инстанс area

// --- playablecolony2: ставим иконку 'Unknown' ровно на тайл планеты в overmap ---
/datum/map_template/ruin/exoplanet/playablecolony2/after_load()
	. = ..()
	colony_inform()

	// найти (или создать) лендмарк посадки
	var/obj/shuttle_landmark/L = null
	for (var/obj/shuttle_landmark/S in world)
		if (S.landmark_tag == "nav_facolony_1")
			L = S
			break
	if (!L)
		var/area/A = locate(/area/map_template/colony2/FA/landing)
		if (A)
			for (var/turf/T in A)
				L = new /obj/shuttle_landmark/nav_facolony(T)
				break
	if (!L)
		log_and_message_admins("FA: nav_facolony_1 landmark not found after load.")
		return

	// базовый сектор overmap, соответствующий физическому Z колонии
	var/obj/overmap/visitable/base_sector = map_sectors["[L.z]"]
	if (!istype(base_sector))
		log_and_message_admins("FA: map_sectors for z=[L.z] is null; cannot place overmap marker.")
		return

	// найти планету на том же overmap-Z, СВЯЗАННУЮ с этим z
	var/obj/overmap/visitable/sector/exoplanet/target_planet = null
	for (var/obj/overmap/visitable/sector/exoplanet/P in world)
		if (P.z != base_sector.z) continue
		var/list/links = null
		if ("planetary_z_levels" in P.vars) links = P.vars["planetary_z_levels"]
		else if ("z_levels" in P.vars)       links = P.vars["z_levels"]
		if (islist(links) && (L.z in links))
			target_planet = P
			break

	// запасной путь — ближайшая планета на этом overmap-Z
	if (!target_planet)
		var/turf/base_turf = get_turf(base_sector)
		var/min_d = 1.0e9
		for (var/obj/overmap/visitable/sector/exoplanet/P in world)
			if (P.z != base_sector.z) continue
			var/d = get_dist(get_turf(P), base_turf)
			if (d < min_d)
				min_d = d
				target_planet = P

	if (!target_planet)
		log_and_message_admins("FA: no exoplanet icon found on overmap z=[base_sector.z].")
		return

	var/turf/planet_turf = get_turf(target_planet)
	if (!planet_turf) return

	// удалить старые дубликаты "Unknown" на самой планете (если вдруг были)
	for (var/obj/overmap/visitable/sector/facolony/E in planet_turf)
		qdel(E)

	// ВАЖНО: создаём БЕЗ локации, отключаем автоплейсмент, а затем переносим на след. тик
	var/obj/overmap/visitable/sector/facolony/sec = new

	// попробовать задушить любые механизмы рандом-расположения, если есть такие поля
	for (var/V in list("place_near_main", "autoplace", "place_randomly", "random_spread", "starts_randomized"))
		if (V in sec.vars)
			sec.vars[V] = null

	if ("anchored" in sec.vars)
		sec.anchored = TRUE

	// переносим СТРОГО на тайл планеты ПОСЛЕ Initialize()
	spawn(1)
		if (QDELETED(sec)) return
		sec.forceMove(planet_turf)
		// слой чуть выше, чтобы квадрат не прятался под кружком планеты
		sec.layer = target_planet.layer + 0.01
		log_and_message_admins("FA: overmap marker placed at [planet_turf.x],[planet_turf.y],[planet_turf.z] over [target_planet.name].")

	// пере-регистрируем навпоинт у текущего сектора через стандартную логику
	L.forceMove(get_turf(L))

/datum/map_template/ruin/exoplanet/playablecolony2/proc/colony_inform()
	//Информирует мир о типе колонии
	var/message // <- То, что будем отправлять в оповещение
	if(GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		message += "<center><img src = ntlogo.png /><br />[FONT_LARGE("<b>NSV Sierra</b> Communications Report:")]<br> </center>"
		message += "<center>Коммуникационным реле ИКН \"Сьерра\" было принято коммьюнике, указывающие на присутствие в текущей системе аванпоста корпорации NanoTrasen. Для удобства членов командования объекта в данном отчете приводятся стандартные процедуры для взаимодействия с передовым аванпостом корпорации:</center><br />"
		message += "● Разрешены и рекомендуются любые торговые и обменные операции имеющихся в наличии ресурсов, артефактов и научных данных обоих подразделений.<br />"
		message += "● В случае чрезвычайной ситуации на поверхности, персоналу аванпоста разрешена эвакуация на борт ИКН \"Сьерра\"; аналогично, в случае необходимости эвакуации судна, персонал может быть транспортирован на территорию аванпоста.<br />"
		message += "● Взаимное посещение объектов в условиях штатной ситуации осуществляется свободно; при необходимости, ограничительные меры могут быть установлены совместным решением членов командования ИКН \"Сьерра\" и командования аванпоста.<br />"
		message += "<center>Аванпост является важным активом корпорации NanoTrasen - ожидается, что ему будет оказана вся необходимая поддержка, не ставящая под удар основную миссию судна.</center>"
		post_comm_message("NSV Sierra Comms Relay", message)
		minor_announcement.Announce(message = "Коммуникационным реле ИКН \"Сьерра\" было принято коммьюнике, указывающие на присутствие в текущей системе аванпоста корпорации NanoTrasen. Дальнейшие инструкции направлены на консоль коммуникации.")

/obj/random/colony2_paper/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/paper/colony2_nt)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/paper/colony2_gkk)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/paper/colony2_sol)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/paper/colony2_ind)

/obj/item/paper/colony2_nt
	name = "Private colonization license"
	info = "<center><img src = solcrest.png /><br /><h1>Лицензия на частную колониальную деятельность</h1><p></center>Настоящей Лицензией утверждается право <b>NanoTrasen Incorporated</b>, в лице представляющих её сотрудников, проживающих на территории колониального поселения, на размещение <b>исследовательского колониального поселения</b>, а также владение и управление им и прилегающими к нему территориями колонизированной экзопланеты. Это право также распространяется на все природные ресурсы, восполнимые и невосполнимые, обнаруженные на территории поселения.<br><br>Настоящей Лицензией заверяется, что колониальное поселение и прилегающие ему области являются <b>частной территорией NanoTrasen Incorporated</b>. Право присутствия на территории колониального поселения тех или иных лиц определяется по усмотрению представителей <b>NanoTrasen Incorporated</b>. Правовой статус лиц, которые не могут быть идентифицированы по подтверждающим их статус документам, может быть установлен посредством направления соответствующего запроса в <b>консульский отдел посольства ЦПСС в системе Траян</b>; до момента идентификации, решение о правомерности их нахождения в колониальном поселении принимается руководством колониального поселения.<br><br>Настоящей Лицензией утверждается, что безопасность данного поселения обеспечивается собственными силами <b>NanoTrasen Incorporated</b>. Сотрудники корпорации и иные лица, желающие проживать в поселении, выражают своё понимание опасностей, сопряженных с колонизацией Фронтира, и отказываются от каких-либо претензий в отношении вооруженных сил ЦПСС по вопросам, сопряженным с обеспечением безопасности колонии. Данное согласие должно быть закреплено в письменном виде и храниться в архиве <b>административной станции NanoTrasen \"Легион\"</b>.</p>"
	stamps = "<hr><i>This paper has been stamped with the personal seal of Horace Fields, Supreme Judge of the Sol System.</i><BR><i>This paper has been stamped with the stamp of Central Command.</i>"
	stamped = list(/obj/item/stamp/boss)
	ico = list("paper_stamp-boss")

/obj/item/paper/colony2_gkk
	name = "ICCG colonial charter"
	info = "<center><img src = terralogo.png /><br /><h1>Хартия колониального поселения</h1><p></center>Настоящей Хартией утверждается право <b>Независимой Колониальной Конфедерации Гильгамеша</b>, в лице представляющих его граждан, проживающих на территории колониального поселения, на владение и управление колониальным поселением и прилегающими к нему территориями колонизированной экзопланеты. Это право также распространяется на все природные ресурсы, восполнимые и невосполнимые, обнаруженные на территории поселения.<br><br>Настоящей хартией заверяется, что колониальное поселение и прилегающие ему области являются <b>суверенной территорией ГКК</b>. Граждане ГКК, а также лица, которым разрешено пребывание на территории ГКК, имеют все права и свободы, предоставляемые им Конфедерацией, находясь на территории колониального поселения; аналогично, лица, объявленные персонами нон-гранта решением <b>Верховной Коллегии Судей</b>, не имеют права приближаться к колониальному поселению. Правовой статус лиц, которые не могут быть идентифицированы по подтверждающим их статус документам, может быть установлен посредством направления соответствующего запроса в <b>консульский отдел представительства ГКК в системе Денебола</b>; до момента идентификации, решение о правомерности их нахождения в колониальном поселении принимается руководством колониального поселения.<br><br>Настоящей хартией утверждается, что безопасность данного поселения обеспечивается силами самих колонистов, а также силами действующих единиц <b>Пионерского Корпуса ГКК</b>. Колонисты, желающие проживать в поселении, выражают своё понимание опасностей, сопряженных с колонизацией Фронтира, и соглашаются самостоятельно обеспечивать свою безопасность в случае, если силы <b>Пионерского Корпуса</b> не могут своевременно отреагировать на полученный сигнал бедствия. Данное согласие должно быть закреплено в письменном виде и храниться в архиве <b>представительства ГКК в системе Денебола</b>.</p>"
	stamps = "<hr><i>This paper has been stamped by ICCG Ministry of Colonial Development and Deep Space Exploration.</i>"
	language = LANGUAGE_HUMAN_RUSSIAN
	stamped = list(/obj/item/stamp/boss)
	ico = list("paper_stamp-boss")

/obj/item/paper/colony2_sol
	name = "SCG colonial charter"
	info = "<center><img src = solcrest.png /><br /><h1>Хартия колониального поселения</h1><p></center>Настоящей Хартией утверждается право <b>Центрального Правительства Солнечной Системы</b>, в лице представляющих его граждан, проживающих на территории колониального поселения, на владение и управление колониальным поселением и прилегающими к нему территориями колонизированной экзопланеты. Это право также распространяется на все природные ресурсы, восполнимые и невосполнимые, обнаруженные на территории поселения.<br><br>Настоящей хартией заверяется, что колониальное поселение и прилегающие ему области являются <b>суверенной территорией ЦПСС</b>. Граждане ЦПСС, а также лица, которым разрешено пребывание на территории ЦПСС, имеют все права и свободы, предоставляемые им Центральным Правительством, находясь на территории колониального поселения; аналогично, лица, объявленные персонами нон-гранта решением <b>Верховного Суда Солнечной Системы</b>, не имеют права приближаться к колониальному поселению. Правовой статус лиц, которые не могут быть идентифицированы по подтверждающим их статус документам, может быть установлен посредством направления соответствующего запроса в <b>консульский отдел посольства ЦПСС в системе Траян</b>; до момента идентификации, решение о правомерности их нахождения в колониальном поселении принимается руководством колониального поселения.<br><br>Настоящей хартией утверждается, что безопасность данного поселения обеспечивается силами самих колонистов, а также силами патрульных единиц <b>Пятого Флота Центрального Правительства Солнечной Системы</b>. Колонисты, желающие проживать в поселении, выражают своё понимание опасностей, сопряженных с колонизацией Фронтира, и соглашаются самостоятельно обеспечивать свою безопасность в случае, если силы <b>Пятого Флота</b> не могут своевременно отреагировать на полученный сигнал бедствия. Данное согласие должно быть закреплено в письменном виде и храниться в архиве <b>посольства ЦПСС в системе Траян</b>.</p>"
	stamps = "<hr><i>This paper has been stamped with the personal seal of Horace Fields, Supreme Judge of the Sol System.</i>"
	stamped = list(/obj/item/stamp/boss)
	ico = list("paper_stamp-boss")

/obj/item/paper/colony2_ind
	name = "Colonization plans"
	info = "<i>Документ содержит весьма исчерпывающий план по колонизации данной экзопланеты, включающий перечень необходимого инвентаря, финансирования и инструкции для колонистов. В глаза бросаются многочисленные упоминания договоров о финансировании с теми или иными корпорациями и некой организации, именуемой \"Альянсом Фронтира\".</i>"

// Frontier Alliance extention by Garry Flint //

/obj/overmap/visitable/sector/facolony
	name = "Unknown"
	desc = "Unidentified structures emit a weak signal."
	icon_state = "object"
	initial_generic_waypoints = list("nav_facolony_1")
  
var/global/const/access_facolony = "ACCESS_FACOLONY"
/datum/access/facolony
	id = access_facolony
	desc = "Crew card"

/obj/item/card/id/facolony
	name = "Crew card"
	desc = "Old worn-out access card."
	access = list(access_facolony)
	color = COLOR_OFF_WHITE
	detail_color = COLOR_CIVIE_GREEN

/obj/floor_decal/falogo
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "falogo"

/obj/structure/sign/double/faflag/left
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "faflag_l"

/obj/structure/sign/double/faflag/right
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "faflag_r"

/area/map_template/colony2/FA/
	req_access = list(access_facolony)

/area/map_template/colony2/FA/command
	name = "\improper IPV Celeste Hauler - Bridge"
	icon_state = "A"

/area/map_template/colony2/FA/landing
	name = "\improper Landing Site"
	icon_state = "B"

/area/map_template/colony2/FA/airlock
	name = "\improper Base Primary External Airlock"
	icon_state = "A"

/area/map_template/colony2/FA/airlock2
	name = "\improper Trade Zone External Airlock"
	icon_state = "A"

/area/map_template/colony2/FA/armory
	name = "\improper Ship Armory"
	icon_state = "A"

/area/map_template/colony2/FA/bathroom
	name = "\improper Base Lavatory"
	icon_state = "A"

/area/map_template/colony2/FA/dorms
	name = "\improper Base Dormitories"
	icon_state = "A"

/area/map_template/colony2/FA/engineering
	name = "\improper Ship Engineering"
	icon_state = "processing"

/area/map_template/colony2/FA/atmospherics
	name = "\improper Ship Atmospherics"
	icon_state = "shipping"

/area/map_template/colony2/FA/atmospherics2
	name = "\improper Base Atmospherics"
	icon_state = "shipping"

/area/map_template/colony2/FA/cargo
	name = "\improper Ship Mid Cargo Area"
	icon_state = "A"

/area/map_template/colony2/FA/cargo2
	name = "\improper Ship Aft Cargo Area"
	icon_state = "A"

/area/map_template/colony2/FA/cargohatch
	name = "\improper Ship Cargo Hatch"
	icon_state = "B"

/area/map_template/colony2/FA/unspecified
	name = "\improper Unspecified Compartment"
	icon_state = "A"

/area/map_template/colony2/FA/tcomms
	name = "\improper Base Telecommunications"
	icon_state = "B2"

/area/map_template/colony2/FA/medbay
	name = "\improper Ship Infirmary"
	icon_state = "A"

/area/map_template/colony2/FA/surgery
	name = "\improper Ship Operating Theatre"
	icon_state = "A"

/area/map_template/colony2/FA/messhall
	name = "\improper Ship Mess Hall"
	icon_state = "B"

/area/map_template/colony2/FA/mineralprocessing
	name = "\improper Base Mining Site"
	icon_state = "A"

/area/map_template/colony2/FA/science
	name = "\improper Base R&D"
	icon_state = "A"

/area/map_template/colony2/FA/warehouse
	name = "\improper Base warehouse"
	icon_state = "shipping"

/area/map_template/colony2/FA/outsidewarehouse
	name = "\improper Trade Zone warehouse"
	icon_state = "shipping"

/area/map_template/colony2/FA/tradezone
	name = "\improper Trade Zone"
	icon_state = "shipping"


