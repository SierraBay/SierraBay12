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
