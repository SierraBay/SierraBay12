/datum/map/sierra/setup_map()
	..()
	system_name = generate_system_name()
	minor_announcement = new(new_sound = sound(ANNOUNCER_COMMANDREPORT, volume = 45))

/datum/map/sierra/map_info(victim)
	to_chat(victim, "<h2>Информация о карте</h2>")
	to_chat(victim, "Вы находитесь на борту <b>[station_name]</b>, исследовательского судна корпорации НаноТрейзен. Основная миссия вашего объекта - проведение исследований на нейтральной территории, как правило, на известной границе космоса с целью нахождения новых залежей форона, космических объектов, артефактов и останков инопланетных цивилизаций.")
	to_chat(victim, "Охрана судна укомплектована сотрудниками Службы Безопасности НаноТрейзен и частных предприятий.")
	to_chat(victim, "Помимо ЧВК в охране, в остальных отделах также присутствуют подрядчики. Их наняли как выдающихся специалистов в своей области, что превзошли корпоративного кандидата. Как правило, они либо работают на себя (civilian), либо на другую корпорацию (contractor). Полезные ссылки:")
	to_chat(victim, "<a href='https://sierra.celadon.pro/index.php/Стандартные_процедуры_ИКН_Сьерра'>Процедуры НТ</a>, <a href='https://sierra.celadon.pro/index.php/Корпоративные_законы'>Регуляции НТ</a>, <a href='https://sierra.celadon.pro/index.php/Стандартные_процедуры_ИКН_Сьерра#Коды_угроз'>Коды угроз НТ</a>, <a href='https://sierra.celadon.pro/index.php/Итак,_Вы_хотите_узнать_о_мире_корпораций%3F'>Список корпораций</a>.")

/datum/map/sierra/send_welcome()
	set waitfor = FALSE

	var/obj/overmap/visitable/ship/sierra/sierra = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/sierra)
	if(!sierra && length(map_sectors))
		sierra = map_sectors["1"]

	var/list/space_things = list()
	var/list/trade_stations = SSsupply.GetVisibleTradeStationsReportData()

	if(sierra)
		for(var/zlevel in map_sectors)
			var/obj/overmap/visitable/O = map_sectors[zlevel]
			if(!O || O == sierra)
				continue
			if(istype(O, /obj/overmap/visitable/ship/landable)) // Не отображаем челноки
				continue
			if(O.hide_from_reports)
				continue
			space_things |= O

	var/list/distress_calls = list()
	for(var/obj/overmap/radio/distress/D in world)
		if(D.loc)
			var/d_bearing = (sierra && D.loc != sierra.loc) ? "[get_bearing(sierra, D)]&deg;" : "&mdash;"
			var/d_dist = (sierra && D.loc != sierra.loc) ? "~[round(sqrt((D.x - sierra.x)**2 + (D.y - sierra.y)**2))] сект." : "в секторе"
			distress_calls += "<li><b>[D.name]</b> &mdash; пеленг [d_bearing], дистанция [d_dist]</li>"

	for(var/obj/overmap/visitable/ship/S in space_things)
		if(S.instant_contact)
			var/d_bearing = (sierra && S.loc != sierra.loc) ? "[get_bearing(sierra, S)]&deg;" : "&mdash;"
			var/d_dist = (sierra && S.loc != sierra.loc) ? "~[round(sqrt((S.x - sierra.x)**2 + (S.y - sierra.y)**2))] сект." : "в секторе"
			distress_calls += "<li><b>[S.name]</b> (аварийный транспондер) &mdash; пеленг [d_bearing], дистанция [d_dist]</li>"

	var/list/R = list()

	// Шапка с официальным гербом ИКН «Сьерра»
	R += "<center>"
	R += "<img src='sierralogo.png'><br>"
	R += "<span style='font-size: 14px; font-weight: bold; letter-spacing: 1px;'>ИКН «СЬЕРРА» // СВОДКА СЕНСОРОВ СЕКТОРА</span><br>"
	R += "<span style='font-size: 10px; color: #8fa7be;'>ЦК «Легион» &bull; Экспедиция в сектор Фронтира &bull; [stationdate2text()] [stationtime2text()]</span>"
	R += "</center>"
	R += "<hr style='border: 0; border-top: 1px solid #335577; margin: 8px 0;'>"

	// Навигационная сводка
	R += "<table style='border-collapse: collapse; font-size: 11px; margin-bottom: 8px;'>"
	R += "<tr><td style='padding: 2px 14px 2px 0; color: #8fa7be;'>Текущая система:</td><td><b>[system_name]</b> [sierra ? "([sierra.x]:[sierra.y])" : ""] (Фронтир)</td></tr>"
	R += "<tr><td style='padding: 2px 14px 2px 0; color: #8fa7be;'>Следующий гиперпереход:</td><td><b>[generate_system_name()]</b></td></tr>"
	R += "<tr><td style='padding: 2px 14px 2px 0; color: #8fa7be;'>Дистанция до пространства ЦПСС (Sol):</td><td>~[rand(15, 45)] суток марша</td></tr>"
	R += "<tr><td style='padding: 2px 14px 2px 0; color: #8fa7be;'>С последнего визита в порт снабжения:</td><td>[rand(60, 180)] суток экспедиции</td></tr>"
	R += "<tr><td style='padding: 2px 14px 2px 0; color: #8fa7be;'>Привод субпространства:</td><td>Krri'gli Corp BS-Drive (Штатный режим)</td></tr>"
	R += "</table>"

	// Контакты сенсоров
	R += "<hr style='border: 0; border-top: 1px solid #335577; margin: 8px 0;'>"
	R += "<b style='font-size: 11px; color: #7fa4c7;'>ОБЪЕКТЫ В ЗОНЕ ДЕЙСТВИЯ СЕНСОРОВ (РЛС / СПЕКТРОМЕТРИЯ):</b>"
	if(!length(space_things))
		R += "<br><span style='color: #8fa7be; font-size: 11px;'>В радиусе действия сенсоров устойчивых сигнатур не зафиксировано.</span>"
	else
		R += "<table style='width: 100%; border-collapse: collapse; font-size: 11px; margin-top: 4px;'>"
		R += "<tr style='border-bottom: 1px solid #335577; color: #7fa4c7; font-size: 10px;'>"
		R += "<th align='left' style='padding: 3px 6px;'>ОБЪЕКТ</th>"
		R += "<th align='right' style='padding: 3px 6px; width: 80px;'>ПЕЛЕНГ</th>"
		R += "<th align='right' style='padding: 3px 6px; width: 95px;'>ДИСТАНЦИЯ</th>"
		R += "</tr>"
		for(var/obj/overmap/visitable/O in space_things)
			var/bearing_text
			var/dist_text
			if(sierra && O.loc == sierra.loc)
				bearing_text = "&mdash;"
				dist_text = "в секторе"
			else if(sierra)
				bearing_text = "[get_bearing(sierra, O)]&deg;"
				dist_text = "~[round(sqrt((O.x - sierra.x)**2 + (O.y - sierra.y)**2))] сект."
			else
				bearing_text = "&mdash;"
				dist_text = "[O.x]:[O.y]"

			R += "<tr style='border-bottom: 1px solid #1a2c3d;'>"
			R += "<td style='padding: 3px 6px;'><b>[O.name]</b></td>"
			R += "<td align='right' style='padding: 3px 6px;'>[bearing_text]</td>"
			R += "<td align='right' style='padding: 3px 6px;'>[dist_text]</td>"
			R += "</tr>"
		R += "</table>"

	// Торговые маяки
	if(length(trade_stations))
		R += "<hr style='border: 0; border-top: 1px solid #335577; margin: 8px 0;'>"
		R += "<b style='font-size: 11px; color: #7fa4c7;'>ОБНАРУЖЕННЫЕ ТОРГОВЫЕ МАЯКИ ФРОНТИРА:</b>"
		R += "<table style='width: 100%; border-collapse: collapse; font-size: 11px; margin-top: 4px;'>"
		R += "<tr style='border-bottom: 1px solid #335577; color: #7fa4c7; font-size: 10px;'>"
		R += "<th align='left' style='padding: 3px 6px; width: 180px;'>МАЯК</th>"
		R += "<th align='center' style='padding: 3px 6px; width: 70px;'>СЕКТОР</th>"
		R += "<th align='left' style='padding: 3px 6px;'>СПЕЦИФИКАЦИЯ</th>"
		R += "</tr>"
		for(var/list/station_entry in trade_stations)
			var/st_name = station_entry["name"]
			var/st_desc = station_entry["desc"]
			var/st_x = station_entry["x"]
			var/st_y = station_entry["y"]

			var/colon_pos = findtext(st_desc, ": ")
			var/clean_desc = colon_pos ? copytext(st_desc, colon_pos + 2) : st_desc

			R += "<tr style='border-bottom: 1px solid #1a2c3d;'>"
			R += "<td style='padding: 3px 6px;'><b>[st_name]</b></td>"
			R += "<td align='center' style='padding: 3px 6px;'>[st_x]:[st_y]</td>"
			R += "<td style='padding: 3px 6px; color: #9bb1c4;'>[clean_desc]</td>"
			R += "</tr>"
		R += "</table>"

	// Сигналы бедствия
	R += "<hr style='border: 0; border-top: 1px solid #335577; margin: 8px 0;'>"
	if(length(distress_calls))
		R += "<b style='font-size: 11px; color: #e74c3c;'>ВНИМАНИЕ: ЗАРЕГИСТРИРОВАН СИГНАЛ БЕДСТВИЯ (СТАНДАРТ MIL-DTL-93352)</b>"
		R += "<ul style='margin: 4px 0 0 16px; padding: 0; font-size: 11px; color: #e74c3c;'>"
		R += jointext(distress_calls, "")
		R += "</ul>"
	else
		R += "<span style='font-size: 11px; color: #6db38a;'>Сигналов бедствия MIL-DTL-93352 на аварийных частотах не обнаружено.</span><br>"

	R += "<hr style='border: 0; border-top: 1px solid #335577; margin: 8px 0;'>"

	var/welcome_text = jointext(R, "")

	post_comm_message("ИКН Сьерра // Сводка сенсоров", welcome_text)

	minor_announcement.Announce(message = "Сканирование сектора завершено. Навигационная сводка и контакты доступны на консолях связи.")
	sleep(2 SECONDS)
	minor_announcement.Announce(message = "Координаты судна: [system_name], сектор [sierra ? "[sierra.x]:[sierra.y]" : "н/д"]. Приятной смены на борту [station_name].", new_sound = 'sound/misc/notice2.ogg')
