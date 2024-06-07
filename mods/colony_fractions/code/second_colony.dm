/singleton/submap_archetype/playablecolony2
	crew_jobs = list(/datum/job/submap/colonist, /datum/job/submap/ship_leader)

/datum/job/submap/ship_leader
	title = "Ship Leader"
	info = "You are a Colonist Leader, living on the rim of explored. Control your colonist, defend the interests of the landed ship."
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/colonist


/datum/job/submap/colonist2
	supervisors = "Colonist Leader"


/singleton/hierarchy/outfit/job/colonist/leader
	name = OUTFIT_JOB_NAME("Colonist Leader")
	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/merchant/colony_leader)

/obj/submap_landmark/spawnpoint/ship_leader_spawn
	name = "Ship Leader"


/datum/map_template/ruin/exoplanet/playablecolony2/load(turf/T, centered=FALSE)
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
	log_and_message_admins("Начал спавн колонии следующего типа: [GLOB.last_colony_type].")

	.=..()
	colony_inform()

/datum/map_template/ruin/exoplanet/playablecolony2/proc/colony_inform()
	//Информирует мир о типе колонии
	var/message // <- То, что будем отправлять в оповещение
	if(GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		message += "<center><img src = ntlogo.png /><br />[FONT_LARGE("<b>NSV Sierra</b> Colony detected:")]<br>"
		message += "<center>Сенсорами объекта ИСН Сьерра зафиксирована посадка колониального судна корпорации NanoTrasen. Далее будут стандартные протоколы с взаимодействием между объектом и судном."
		message += "<center> ● Разрешены научные сделки на технологии или же обмен на артефактические структуры, Геологическая разведка планеты."
		message += "<center> ⊛ Разрешается любой обмен на интересующихся ресурс."
		message += "<center> ◍ Сотрудникам колонии одобрен проход на территорию объекта в случае чрезвычайное происшествия."
		message += "<center> Судно это актив корпорации Нанотрейзен, сделайте всё от себя зависящее не в вред основной миссии для помощи будущей колонии."
		post_comm_message("Colony detected by sensors", message)
		minor_announcement.Announce(message = "Средствами дальней связи в данном секторе обнаружена высадка колониального судна Нанотрейзен. Высланы инструкции.")
	else if (GLOB.last_colony_type == "ЦПСС")
		message += "<center><img src = sollogo.png /><br />[FONT_LARGE("<b>NSV Sierra</b> Colony detected:")]<br>"
		message += "Зафиксирована высадка колониального судна ЦПСС на планете в вашем секторе, получено следующее сообщение: Приветствуем слушателей данного сообщения, экзопланета под управлением ЦПСС. Требуется персональное разрешение на посадку территории экзопланеты иначе вы будете судится по законам ЦПСС!"
		post_comm_message("Colony detected by sensors", message)

/obj/random/colony2_paper
	name = "Colony instructions paper"

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
	name = "Instructions for nanotrasen colony Leader."
	info = "<h1>Отчёт принят</h1><p>Приняли информацию о успешном достижении цели полёта, приказываем начать высадку на планету. Ваши цели как авангарда основной колонии: <BR>Разведка прилегающей к судну местности<BR>Добыча ресурсов для дальнейшего строительства<BR>Строительство аванпоста и его подготовка к прибытию основной колонии<BR>Производство снаряжения и оборудования, которое может помочь миссии в дальнейшем. <BR></B>Дополнительно сообщаем вам о прибытии исследовательного научного судна Сьерра в сектор. Способствуйте работу обьекта на планете в случае необходимости, сотрудничайте и помогайте обьекту в случае необходимости, не в вред своей освовной задаче.</p>"

/obj/item/paper/colony2_gkk
	name = "Instructions for ICCG colony."
	info = "<h1>Отчёт принят</h1><p>Приняли информацию о успешном достижении цели полёта, приказываем начать высадку на планету. Ваши цели как авангарда основной колонии: <BR>Разведка прилегающей к судну местности<BR>Добыча ресурсов для дальнейшего строительства<BR>Строительство аванпоста и его подготовка к прибытию основной колонии<BR>Производство снаряжения и оборудования, которое может помочь миссии в дальнейшем. <BR></B>В случае необходимости, вы можете запросить помощи у патрульного судна разведывательного судна ГКК. Согласно нашим данным, ваш сектор находится на пути их следования.</p>"

/obj/item/paper/colony2_sol
	name = "Instructions for sol colony."
	info = "<h1>Отчёт принят</h1><p>Приняли информацию о успешном достижении цели полёта, приказываем начать высадку на планету. Ваши цели как авангарда основной колонии: <BR>Разведка прилегающей к судну местности<BR>Добыча ресурсов для дальнейшего строительства<BR>Строительство аванпоста и его подготовка к прибытию основной колонии<BR>Производство снаряжения и оборудования, которое может помочь миссии в дальнейшем. <BR></B> В случае необходимости, вы можете запросить помощи у патрульного судна пятого флота. Согласно нашим данным, ваш сектор находится на пути их патрулирования.</p>"

/obj/item/paper/colony2_ind
	name = "Instructions for colony."
	info = "<h1>Отчёт принят</h1><p>Приняли информацию о успешном достижении цели полёта, приказываем начать высадку на планету. Ваши цели как авангарда основной колонии: <BR>Разведка прилегающей к судну местности<BR>Добыча ресурсов для дальнейшего строительства<BR>Строительство аванпоста и его подготовка к прибытию основной колонии<BR>Производство снаряжения и оборудования, которое может помочь миссии в дальнейшем."
