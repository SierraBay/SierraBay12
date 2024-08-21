GLOBAL_VAR_INIT(last_colony_type, "СЛУЧАЙНЫЙ")
GLOBAL_VAR_INIT(choose_colony_type, "СЛУЧАЙНЫЙ") //Педальки выбирают, какой тип колонии будет заспавнен
GLOBAL_VAR_INIT(error_colony_reaction, "Прервать спавн колонии")

/singleton/submap_archetype/playablecolony
	crew_jobs = list(/datum/job/submap/colonist, /datum/job/submap/colonist_leader)

/datum/job/submap/colonist_leader
	title = "Colonist Leader"
	info = "You are a Colonist Leader, living on the rim of explored. Control your colonist, defend the interests of the colony."
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/colonist


/datum/job/submap/colonist
	supervisors = "Colonist Leader"
	max_skill = list(
		SKILL_MEDICAL = SKILL_MAX,
		SKILL_ANATOMY = SKILL_MAX
	)

/singleton/hierarchy/outfit/job/colonist/leader
	name = OUTFIT_JOB_NAME("Colonist Leader")
	id_types = list(/obj/item/card/id/merchant/colony_leader)

/obj/item/card/id/merchant/colony_leader
	name = "Colonist Leader ID"
	desc = "The card issued to the leaders of the colony allows to understand who really is the leader."
	access = list(access_merchant)
	color = COLOR_OFF_WHITE
	detail_color = COLOR_BEIGE

/datum/map_template/ruin/exoplanet/playablecolony
	mappaths = list('mods/colony_fractions/maps/colony_base.dmm')

/datum/map_template/ruin/exoplanet/playablecolony/load(turf/T, centered=FALSE)
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

/datum/map_template/ruin/exoplanet/playablecolony/after_load()
	.=..()
	colony_inform()

/datum/map_template/ruin/exoplanet/playablecolony/proc/colony_inform()
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
	name = "Private colonization license"
	info = "<center><img src = solcrest.png /><br /><h1>Лицензия на частную колониальную деятельность</h1><p></center>Настоящей Лицензией утверждается право <b>NanoTrasen Incorporated</b>, в лице представляющих её сотрудников, проживающих на территории колониального поселения, на размещение <b>исследовательского колониального поселения</b>, а также владение и управление им и прилегающими к нему территориями колонизированной экзопланеты. Это право также распространяется на все природные ресурсы, восполнимые и невосполнимые, обнаруженные на территории поселения.<br><br>Настоящей Лицензией заверяется, что колониальное поселение и прилегающие ему области являются <b>частной территорией NanoTrasen Incorporated</b>. Право присутствия на территории колониального поселения тех или иных лиц определяется по усмотрению представителей <b>NanoTrasen Incorporated</b>. Правовой статус лиц, которые не могут быть идентифицированы по подтверждающим их статус документам, может быть установлен посредством направления соответствующего запроса в <b>консульский отдел посольства ЦПСС в системе Траян</b>; до момента идентификации, решение о правомерности их нахождения в колониальном поселении принимается руководством колониального поселения.<br><br>Настоящей Лицензией утверждается, что безопасность данного поселения обеспечивается собственными силами <b>NanoTrasen Incorporated</b>. Сотрудники корпорации и иные лица, желающие проживать в поселении, выражают своё понимание опасностей, сопряженных с колонизацией Фронтира, и отказываются от каких-либо претензий в отношении вооруженных сил ЦПСС по вопросам, сопряженным с обеспечением безопасности колонии. Данное согласие должно быть закреплено в письменном виде и храниться в архиве <b>административной станции NanoTrasen \"Легион\"</b>.</p>"
	stamps = "<hr><i>This paper has been stamped with the personal seal of Horace Fields, Supreme Judge of the Sol System.</i><BR><i>This paper has been stamped with the stamp of Central Command.</i>"
	stamped = list(/obj/item/stamp/boss)
	ico = list("paper_stamp-boss")

/obj/item/paper/colony_gkk
	name = "ICCG colonial charter"
	info = "<center><img src = terralogo.png /><br /><h1>Хартия колониального поселения</h1><p></center>Настоящей Хартией утверждается право <b>Независимой Колониальной Конфедерации Гильгамеша</b>, в лице представляющих его граждан, проживающих на территории колониального поселения, на владение и управление колониальным поселением и прилегающими к нему территориями колонизированной экзопланеты. Это право также распространяется на все природные ресурсы, восполнимые и невосполнимые, обнаруженные на территории поселения.<br><br>Настоящей хартией заверяется, что колониальное поселение и прилегающие ему области являются <b>суверенной территорией ГКК</b>. Граждане ГКК, а также лица, которым разрешено пребывание на территории ГКК, имеют все права и свободы, предоставляемые им Конфедерацией, находясь на территории колониального поселения; аналогично, лица, объявленные персонами нон-гранта решением <b>Верховной Коллегии Судей</b>, не имеют права приближаться к колониальному поселению. Правовой статус лиц, которые не могут быть идентифицированы по подтверждающим их статус документам, может быть установлен посредством направления соответствующего запроса в <b>консульский отдел представительства ГКК в системе Денебола</b>; до момента идентификации, решение о правомерности их нахождения в колониальном поселении принимается руководством колониального поселения.<br><br>Настоящей хартией утверждается, что безопасность данного поселения обеспечивается силами самих колонистов, а также силами действующих единиц <b>Пионерского Корпуса ГКК</b>. Колонисты, желающие проживать в поселении, выражают своё понимание опасностей, сопряженных с колонизацией Фронтира, и соглашаются самостоятельно обеспечивать свою безопасность в случае, если силы <b>Пионерского Корпуса</b> не могут своевременно отреагировать на полученный сигнал бедствия. Данное согласие должно быть закреплено в письменном виде и храниться в архиве <b>представительства ГКК в системе Денебола</b>.</p>"
	stamps = "<hr><i>This paper has been stamped by ICCG Ministry of Colonial Development and Deep Space Exploration.</i>"
	language = LANGUAGE_HUMAN_RUSSIAN
	stamped = list(/obj/item/stamp/boss)
	ico = list("paper_stamp-boss")

/obj/item/paper/colony_sol
	name = "SCG colonial charter"
	info = "<center><img src = solcrest.png /><br /><h1>Хартия колониального поселения</h1><p></center>Настоящей Хартией утверждается право <b>Центрального Правительства Солнечной Системы</b>, в лице представляющих его граждан, проживающих на территории колониального поселения, на владение и управление колониальным поселением и прилегающими к нему территориями колонизированной экзопланеты. Это право также распространяется на все природные ресурсы, восполнимые и невосполнимые, обнаруженные на территории поселения.<br><br>Настоящей хартией заверяется, что колониальное поселение и прилегающие ему области являются <b>суверенной территорией ЦПСС</b>. Граждане ЦПСС, а также лица, которым разрешено пребывание на территории ЦПСС, имеют все права и свободы, предоставляемые им Центральным Правительством, находясь на территории колониального поселения; аналогично, лица, объявленные персонами нон-гранта решением <b>Верховного Суда Солнечной Системы</b>, не имеют права приближаться к колониальному поселению. Правовой статус лиц, которые не могут быть идентифицированы по подтверждающим их статус документам, может быть установлен посредством направления соответствующего запроса в <b>консульский отдел посольства ЦПСС в системе Траян</b>; до момента идентификации, решение о правомерности их нахождения в колониальном поселении принимается руководством колониального поселения.<br><br>Настоящей хартией утверждается, что безопасность данного поселения обеспечивается силами самих колонистов, а также силами патрульных единиц <b>Пятого Флота Центрального Правительства Солнечной Системы</b>. Колонисты, желающие проживать в поселении, выражают своё понимание опасностей, сопряженных с колонизацией Фронтира, и соглашаются самостоятельно обеспечивать свою безопасность в случае, если силы <b>Пятого Флота</b> не могут своевременно отреагировать на полученный сигнал бедствия. Данное согласие должно быть закреплено в письменном виде и храниться в архиве <b>посольства ЦПСС в системе Траян</b>.</p>"
	stamps = "<hr><i>This paper has been stamped with the personal seal of Horace Fields, Supreme Judge of the Sol System.</i>"
	stamped = list(/obj/item/stamp/boss)
	ico = list("paper_stamp-boss")

/obj/item/paper/colony_ind
	name = "Colonization plans"
	info = "<i>Документ содержит весьма исчерпывающий план по колонизации данной экзопланеты, включающий перечень необходимого инвентаря, финансирования и инструкции для колонистов. В глаза бросаются многочисленные упоминания договоров о финансировании с теми или иными корпорациями и некой организации, именуемой \"Альянсом Фронтира\".</i>"

//ФЛАГ

/obj/random/colony_flag/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/structure/sign/nanotrasen)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/structure/sign/iccg_colony)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/structure/sign/icarus_solgov)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/structure/sign/colony)
	//стандарт значение
	return list(/obj/structure/sign/colony)


//БРОНИКИ

/obj/random/colony_armor/spawn_choices()
	if      (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/vest/nt,
					/obj/item/clothing/suit/armor/vest/old/security,
					/obj/item/clothing/suit/armor/pcarrier/navy,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/pcarrier/medium/nt
					)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/pcarrier/tactical_colony,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/pcarrier/tan,
					/obj/item/clothing/suit/armor/pcarrier/tan/tactical,
					/obj/item/clothing/suit/armor/pcarrier/troops_colony,
					/obj/item/clothing/suit/armor/pcarrier/troops_colony/heavy,
					/obj/item/clothing/suit/armor/pcarrier/navy
					)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/pcarrier/medium/sol_colony,
					/obj/item/clothing/suit/armor/pcarrier/tan/tactical,
					/obj/item/clothing/suit/armor/pcarrier/tan,
					/obj/item/clothing/suit/armor/pcarrier/troops_colony,
					/obj/item/clothing/suit/armor/vest/solgov_colony,
					/obj/item/clothing/suit/armor/pcarrier/troops_colony/heavy,
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
	//стандарт значение
	return list(/obj/item/clothing/suit/armor/riot)



//ШЛЕМА

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
					/obj/item/clothing/head/helmet/tactical
					)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet/ablative,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/solgov_colony/pilot,
					/obj/item/clothing/head/helmet/solgov_colony/pilot/fleet,
					/obj/item/clothing/head/helmet/solgov_colony,
					/obj/item/clothing/head/helmet/ballistic,
					/obj/item/clothing/head/helmet/pcrc,
					/obj/item/clothing/head/helmet/solgov_colony/command,
					/obj/item/clothing/head/helmet/tactical,
					/obj/item/clothing/head/helmet/solgov_colony/security
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
					/obj/item/clothing/head/helmet/swat
					)
	//стандарт значение
	return list(/obj/item/clothing/head/helmet/swat)
//ПП

/obj/random/colony_smg/spawn_choices()
	if     (GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/gun/projectile/automatic/nt41_colony)
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
	//стандарт значение
	return list(/obj/item/gun/projectile/automatic/merc_smg)

//АВТОМАТ

/obj/random/colony_rifle/spawn_choices()
	if(GLOB.last_colony_type == "НАНОТРЕЙЗЕН")
		return list(/obj/item/gun/projectile/automatic/bullpup_rifle,
					/obj/item/gun/projectile/automatic/bullpup_rifle/light
					)
	else if(GLOB.last_colony_type == "ГКК")
		return list(/obj/item/gun/projectile/automatic/assault_rifle,
					/obj/item/gun/projectile/automatic/assault_rifle/heltek_colony,
					/obj/item/gun/projectile/automatic/mbr_colony,
					/obj/item/gun/projectile/automatic/mr735_colony)
	else if(GLOB.last_colony_type == "ЦПСС")
		return list(/obj/item/gun/projectile/automatic/bullpup_rifle,
					/obj/item/gun/projectile/automatic/bullpup_rifle/light
					)
	else if(GLOB.last_colony_type == "НЕЗАВИСИМАЯ")
		return list(/obj/item/gun/projectile/automatic/assault_rifle,
					/obj/item/gun/projectile/automatic/assault_rifle/heltek_colony,
					/obj/item/gun/projectile/automatic/mbr_colony,
					/obj/item/gun/projectile/automatic/battlerifle
					)
	//стандарт значение
	return list(/obj/item/gun/projectile/automatic/battlerifle)

/obj/machinery/computer/rdconsole/core/colony/New()
	. = ..()
	files.research_points = 41250

	/*
	files.UnlockTechology(/datum/technology/engineering)
	files.UnlockTechology(/datum/technology/engineering/monitoring)
	files.UnlockTechology(/datum/technology/engineering/adv_parts)
	files.UnlockTechology(/datum/technology/engineering/res_tech)
	files.UnlockTechology(/datum/technology/engineering/basic_mining)
	files.UnlockTechology(/datum/technology/engineering/ship)
	files.UnlockTechology(/datum/technology/engineering/adv_eng)
	files.UnlockTechology(/datum/technology/engineering/super_parts)
	//POWER
	files.UnlockTechology(/datum/technology/power)
	files.UnlockTechology(/datum/technology/power/adv_power)
	files.UnlockTechology(/datum/technology/power/sup_power)
	files.UnlockTechology(/datum/technology/power/hyp_power)
	files.UnlockTechology(/datum/technology/power/sup_power_gen)
	files.UnlockTechology(/datum/technology/power/adv_power_gen)
	files.UnlockTechology(/datum/technology/power/power_storage)
	files.UnlockTechology(/datum/technology/power/adv_power_storage)
	//BLUESPACE
	files.UnlockTechology(/datum/technology/tcom/rcon)
	files.UnlockTechology(/datum/technology/tcom/monitoring)
	files.UnlockTechology(/datum/technology/tcom)
	files.UnlockTechology(/datum/technology/tcom/tcom_parts)
	files.UnlockTechology(/datum/technology/tcom/arti_blue)
	files.UnlockTechology(/datum/technology/tcom/tele_pad)
	//РОБО
	files.UnlockTechology(/datum/technology/robo)
	files.UnlockTechology(/datum/technology/robo/loader_mech)
	files.UnlockTechology(/datum/technology/robo/basic_hardsuitmods)
	files.UnlockTechology(/datum/technology/robo/adv_hardsuits)
	files.UnlockTechology(/datum/technology/robo/heavy_mech)
	files.UnlockTechology(/datum/technology/robo/light_mech)
	files.UnlockTechology(/datum/technology/robo/combat_mechs)
	files.UnlockTechology(/datum/technology/robo/mech_equipment)
	files.UnlockTechology(/datum/technology/robo/mech_weapons)
	files.UnlockTechology(/datum/technology/robo/mech_med_tools)
	files.UnlockTechology(/datum/technology/robo/adv_mech_tools)
	*/

	/*
	files.UpdateTech("materials", 7) //Материалы
	files.UpdateTech("engineering", 5) //Инженерка
	files.UpdateTech("phorontech", 5) //Форон
	files.UpdateTech("powerstorage", 7) //Повер манипулейшен
	files.UpdateTech("bluespace", 5) //Блюспейс
	files.UpdateTech("biotech", 7) //Биология
	files.UpdateTech("combat", 8) // Боевые
	files.UpdateTech("magnets", 7) //Электромагнитные
	files.UpdateTech("programming", 5) //ДАТА
	files.UpdateTech("esoteric", 8) //Эзотерика
	*/


/area/map_template/colony/science
	name = "\improper Colony R&D"
	icon_state = "solar"

/area/map_template/colony/warehouse
	name = "\improper Сolony warehouse"
	icon_state = "shipping"

/obj/machinery/vending/wallbartender/colony
	name = "\improper Glass-o-Mat"
	desc = "A wall-mounted glass storage."
	product_ads = "Free glasses!;Lets try something new.;Only the finest glasses.;Natural booze!;This stuff saves no lives.;Don't you want some?"
	icon = 'maps/sierra/icons/obj/vending.dmi'
	icon_state = "wallbartender"
	icon_deny = "wallbartender-deny"
	icon_vend = "wallbartender-vend"
	base_type = /obj/machinery/vending/wallbartender
	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(
		/obj/item/reagent_containers/food/drinks/glass2/square = 10,
		/obj/item/reagent_containers/food/drinks/glass2/shot = 5,
		/obj/item/reagent_containers/food/drinks/glass2/cocktail = 5,
		/obj/item/reagent_containers/food/drinks/glass2/rocks = 5,
		/obj/item/reagent_containers/food/drinks/glass2/shake = 5,
		/obj/item/reagent_containers/food/drinks/glass2/wine = 5,
		/obj/item/reagent_containers/food/drinks/glass2/flute = 5,
		/obj/item/reagent_containers/food/drinks/glass2/cognac = 5,
		/obj/item/reagent_containers/food/drinks/glass2/goblet = 5,
		/obj/item/reagent_containers/food/drinks/glass2/mug = 5,
		/obj/item/reagent_containers/food/drinks/glass2/pint = 5,
	)
	req_access = list()

//Пресетовая машинерия

/obj/machinery/space_heater/stationary/on/colony
	set_temperature = 273.15
	heating_power = 360000



/obj/machinery/power/smes/buildable/preset/colony
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil/super_capacity = 1,
									/obj/item/stock_parts/smes_coil/super_io = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/sleeper/survival_pod/colony
	name = "advanced colony stasis pod"

/obj/item/storage/firstaid/fire/special/colony
	name = "colony scorch first-aid kit"

/obj/machinery/vending/medical/colony
	req_access = list()
