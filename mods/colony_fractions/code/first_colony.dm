GLOBAL_VAR_INIT(last_colony_type, "СЛУЧАЙНЫЙ")
GLOBAL_VAR_INIT(choose_colony_type, "СЛУЧАЙНЫЙ") //Педальки выбирают, какой тип колонии будет заспавнен


/singleton/submap_archetype/playablecolony
	crew_jobs = list(/datum/job/submap/colonist, /datum/job/submap/colonist_leader)

/datum/job/submap/colonist_leader
	title = "Colonist Leader"
	info = "You are a Colonist Leader, living on the rim of explored. Control your colonist, defend the interests of the colony."
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/colonist


/datum/job/submap/colonist
	supervisors = "Colonist Leader"


/singleton/hierarchy/outfit/job/colonist/leader
	name = OUTFIT_JOB_NAME("Colonist Leader")
	id_types = list(/obj/item/card/id/merchant/colony_leader)

/obj/item/card/id/merchant/colony_leader
	name = "Colonist Leader ID"
	desc = "The card issued to the leaders of the colony allows to understand who really is the leader."
	access = list(access_merchant)
	color = COLOR_OFF_WHITE
	detail_color = COLOR_BEIGE


/obj/submap_landmark/spawnpoint/colonist_leader_spawn
	name = "Colonist Leader"

/datum/map_template/ruin/exoplanet/playablecolony/load(turf/T, centered=FALSE)
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

/datum/map_template/ruin/exoplanet/playablecolony/proc/colony_inform()
	//Информирует мир о типе колонии
	var/message // <- То, что будем отправлять в оповещение
	if(GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		message += "<center><img src = ntlogo.png /><br />[FONT_LARGE("<b>NSV Sierra</b> Colony detected:")]<br>"
		message += "<center>Сенсорами объекта ИСН Сьерра найдена колония принадлежавшей корпорации NanoTrasen. Далее будут стандартные протоколы с взаимодействием между объектом и колонии."
		message += "<center> ● Разрешены научные сделки на технологии или же обмен на артефактические структуры, Геологическая разведка планеты."
		message += "<center> ⊛ Разрешается любой обмен на интересующихся ресурс."
		message += "<center> ◍ Сотрудникам колонии одобрен проход на территорию объекта в случае чрезвычайное происшествия."
		message += "<center> Колония это актив корпорации Нанотрейзен, сделайте всё от себя зависящее не в вред основной миссии для помощи колонии."
		post_comm_message("Colony detected by sensors", message)
		minor_announcement.Announce(message = "Средствами дальней связи в данном секторе обнаружена колония Нанотрейзен. Высланы инструкции.")
	else if (GLOB.last_colony_type == "ЦПСС")
		message += "<center><img src = sollogo.png /><br />[FONT_LARGE("<b>NSV Sierra</b> Colony detected:")]<br>"
		message += "Перехвачено сообщение с колонии ЦПСС в данном секторе: Приветствуем слушателей данного сообщения, экзопланета под управлением ЦПСС. Требуется персональное разрешение на посадку территории планеты иначе вы будете судится по законам ЦПСС!"
		post_comm_message("Colony detected by sensors", message)

/obj/random/colony_paper
	name = "Colony instructions paper"

/obj/random/colony_paper/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/paper/colony_nt)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/paper/colony_gkk)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/paper/colony_sol)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/paper/colony_ind)

/obj/item/paper/colony_nt
	name = "Instructions for nanotrasen colony Leader."
	info = "Ваш отчёт об успешной высадке на планету и развёртывании аванпоста успешно получен. В связи с этим, миссия должна приступить к следующему этапу включающие в себя: Разведка прилегающей к аванпосту местности, добыча ресурсов для дальнейшего строительства, асширение аванпоста и его подготовка к прибытию основной колонии, производство снаряжения и оборудования, которое может помочь миссии в дальнейшем. Дополнительно сообщаем вам о прибытии исследовательного научного судна Сьерра в сектор. Способствуйте работу обьекта на планете в случае необходимости, сотрудничайте и помогайте обьекту в случае необходимости, не в вред своей освовной задаче."

/obj/item/paper/colony_gkk
	name = "Instructions for ICCG colony."
	info = "Ваш отчёт об успешной высадке на планету и развёртывании аванпоста успешно получен. В связи с этим, миссия должна приступить к следующему этапу включающие в себя: Разведка прилегающей к аванпосту местности, добыча ресурсов для дальнейшего строительства, расширение аванпоста и его подготовка к прибытию основной колонии, производство снаряжения и оборудования, которое может помочь миссии в дальнейшем. В случае необходимости, вы можете запросить помощи у патрульного судна разведывательного судна ГКК. Согласно нашим данным, ваш сектор находится на пути их следования."

/obj/item/paper/colony_sol
	name = "Instructions for sol colony."
	info = "Ваш отчёт об успешной высадке на планету и развёртывании аванпоста успешно получен. В связи с этим, миссия должна приступить к следующему этапу включающие в себя: Разведка прилегающей к аванпосту местности, добыча ресурсов для дальнейшего строительства,расширение аванпоста и его подготовка к прибытию основной колонии,производство снаряжения и оборудования, которое может помочь миссии в дальнейшем. В случае необходимости, вы можете запросить помощи у патрульного судна пятого флота. Согласно нашим данным, ваш сектор находится на пути их патрулирования."

/obj/item/paper/colony_ind
	name = "Instructions for colony."
	info = "Ваш отчёт об успешной высадке на планету и развёртывании аванпоста успешно получен. В связи с этим, миссия должна приступить к следующему этапу включающие в себя: Разведка прилегающей к аванпосту местности, добыча ресурсов для дальнейшего строительства, расширение аванпоста и его подготовка к прибытию основной колонии, производство снаряжения и оборудования, которое может помочь миссии в дальнейшем."

//ФЛАГ
/obj/random/colony_flag
	name = "Colony flag"

/obj/random/colony_flag/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/structure/sign/nanotrasen)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/structure/sign/iccg)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/structure/sign/icarus_solgov)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/structure/sign/colony)



//БРОНИКИ
/obj/random/colony_armor
	name = "random colony armor"


/obj/random/colony_armor/spawn_choices()
	if      (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/vest/nt,
					/obj/item/clothing/suit/armor/vest/old/security,
					/obj/item/clothing/suit/armor/pcarrier/navy,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/pcarrier/medium/nt,
					/obj/item/clothing/suit/armor/pcarrier/medium/command
					)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/pcarrier/tactical,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/pcarrier/tan,
					/obj/item/clothing/suit/armor/pcarrier/tan/tactical,
					/obj/item/clothing/suit/armor/pcarrier/troops,
					/obj/item/clothing/suit/armor/pcarrier/troops/heavy,
					/obj/item/clothing/suit/armor/pcarrier/navy
					)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/pcarrier/medium/sol,
					/obj/item/clothing/suit/armor/pcarrier/tan/tactical,
					/obj/item/clothing/suit/armor/pcarrier/tan,
					/obj/item/clothing/suit/armor/pcarrier/troops,
					/obj/item/clothing/suit/armor/vest/solgov,
					/obj/item/clothing/suit/armor/pcarrier/troops/heavy,
					/obj/item/clothing/suit/armor/pcarrier/troops/heavy/pcrc,
					/obj/item/clothing/suit/armor/riot
					)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/clothing/suit/armor/swat/officer,
					/obj/item/clothing/suit/armor/vest/blueshift,
					/obj/item/clothing/suit/armor/vest/press,
					/obj/item/clothing/suit/armor/vest/detective,
					/obj/item/clothing/suit/armor/vest/old,
					/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/pcarrier/merc
					)




//ШЛЕМА
/obj/random/colony_helmet
	name  = "random colony helmet"


/obj/random/colony_helmet/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet/ablative,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/nt,
					/obj/item/clothing/head/helmet/nt/guard,
					/obj/item/clothing/head/helmet/ballistic,
					/obj/item/clothing/head/helmet/pcrc

					)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet/ablative,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/augment,
					/obj/item/clothing/head/helmet/ballistic,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/tactical
					)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet/ablative,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/solgov/pilot,
					/obj/item/clothing/head/helmet/solgov/pilot/fleet,
					/obj/item/clothing/head/helmet/solgov,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/ballistic,
					/obj/item/clothing/head/helmet/pcrc,
					/obj/item/clothing/head/helmet/solgov/command,
					/obj/item/clothing/head/helmet/tactical,
					/obj/item/clothing/head/helmet/solgov/security
					)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet/ablative,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/nt/blueshift,
					/obj/item/clothing/head/helmet/old_confederation,
					/obj/item/clothing/head/helmet/old_special_ops,
					/obj/item/clothing/head/helmet/merc,
					/obj/item/clothing/head/helmet/old_commonwealth,
					/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/head/helmet/daft_punk
					)
//ПП
/obj/random/colony_smg
	name = "random colony smg"

/obj/random/colony_smg/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/gun/projectile/automatic/nt41)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/gun/projectile/automatic/merc_smg)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/gun/projectile/automatic/sec_smg)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/gun/projectile/automatic/merc_smg,
					/obj/item/gun/projectile/automatic/sec_smg,
					/obj/item/gun/projectile/automatic/machine_pistol/usi,
					/obj/item/gun/projectile/automatic
					)

//АВТОМАТ
/obj/random/colony_rifle
	name = "random colony rifle"

/obj/random/colony_rifle/spawn_choices()
	if(GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/gun/projectile/automatic/bullpup_rifle,
					/obj/item/gun/projectile/automatic/bullpup_rifle/light
					)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/gun/projectile/automatic/assault_rifle,
					/obj/item/gun/projectile/automatic/assault_rifle/heltek,
					/obj/item/gun/projectile/automatic/mbr,
					/obj/item/gun/projectile/automatic/mr735)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/gun/projectile/automatic/bullpup_rifle,
					/obj/item/gun/projectile/automatic/bullpup_rifle/light
					)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/gun/projectile/automatic/assault_rifle,
					/obj/item/gun/projectile/automatic/assault_rifle/heltek,
					/obj/item/gun/projectile/automatic/mbr,
					/obj/item/gun/projectile/automatic/battlerifle
					)

/obj/structure/sign/colony
	name = "Independent colony"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "colony"
