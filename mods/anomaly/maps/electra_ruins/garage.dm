/datum/map_template/ruin/exoplanet/electra_garage
	name = "garage"
	id = "planetsite_anomalies_garage"
	description = "anomalies lol."
	mappaths = list('mods/anomaly/maps/electra_ruins/garage.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_ELECTRA_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/garage = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/map_template/garage/first_home = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/map_template/garage/second_home = NO_SCRUBBER|NO_VENT|NO_APC
	)

/area/map_template/garage
	name = "\improper Science garage"
	icon_state = "A"

/area/map_template/garage/first_home

/area/map_template/garage/second_home

/obj/forcefield/blocker
	invisibility = 101

/obj/structure/aurora/informative/wall_computer/garage
	possible_information = list(
		"#244...Шеф, я понимаю, вам приказали сверху, эксперименты и всё такое, но вы же сам человек умный, и понимаете, что колёсная техника на такой планете - это же шутка! После первого выезда, у колесницы колёса превратились в труху, день на это угробил! Пришлось из челнока брать запаски, благо взя42u447$@!*.",
		"Во время полевых работ аппаратура зафиксировала совсем неадекватные значения силы электромагнитного поля, я не знаю как но техника выдержала. ",
		"На аванпосте начинает отказывать понемногу техника, в особенности тонкая и хрупкая, по типу сенсоров и детекторов. У меня на личном компьютере начинает появляться совсем чужие записи, я этого не писал! Чертовщина!",
		"14$@!*(4)...ледней вылазке случилось что-то совсем странное, странные огни в небе, словно северное сияние. Ожидаем указа.",
		"Начинаем отлёт с базы согласно вашему приказу, в первую очередь забрали всех людей и критически важную аппаратуру с результатами исследованиями, а так же некоторые аномальные образования, включая этот светящийся шар. Надеюсь, вы сможете без проблем забрать наш БРДМ, мне ещё за него отчитываться."
		)
