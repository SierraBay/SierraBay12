/datum/build_mode/anomalies
	name = "Anomaly spawner and editor"
	icon_state = "buildmode10"
	var/anomaly_type
	var/list/possible_anomalies = list(
		/obj/anomaly/zjarka = "Жарка - аномалия накладывающая BURN урон и поджигающая всех в зоне поражения. Взводится от болта и мобов.",
		/obj/anomaly/zjarka/short_effect = "Жарка - аномалия накладывающая BURN урон и поджигающая всех в зоне поражения. Взводится от болта и мобов.",
		/obj/anomaly/zjarka/long_effect = "Жарка - аномалия накладывающая BURN урон и поджигающая всех в зоне поражения. Взводится от болта и мобов.",
		/obj/anomaly/electra/three_and_three = "Электра - аномалия наносящая электроудар (50 урона + стан) всех в зоне поражения. Реагирует на мобов, металлические предметы. Подтип ТЕСЛА бьёт дальше чем чувствует, параметр предзарядка заставит её сперва зарядить, и лишь потом ударить. НЕ СОВЕТУЮ СОВМЕЩАТЬ ТЕСЛУ И ПРЕДЗАРЯДКУ.",
		/obj/anomaly/electra/three_and_three/tesla = "Электра - аномалия наносящая электроудар (50 урона + стан) всех в зоне поражения. Реагирует на мобов, металлические предметы. Подтип ТЕСЛА бьёт дальше чем чувствует, параметр предзарядка заставит её сперва зарядить, и лишь потом ударить. НЕ СОВЕТУЮ СОВМЕЩАТЬ ТЕСЛУ И ПРЕДЗАРЯДКУ.",
		/obj/anomaly/electra/three_and_three/tesla_second = "Электра - аномалия наносящая электроудар (50 урона + стан) всех в зоне поражения. Реагирует на мобов, металлические предметы. Подтип ТЕСЛА бьёт дальше чем чувствует, параметр предзарядка заставит её сперва зарядить, и лишь потом ударить. НЕ СОВЕТУЮ СОВМЕЩАТЬ ТЕСЛУ И ПРЕДЗАРЯДКУ.",
		/obj/anomaly/vspishka = "Вспышка - аномалия накладывающее ослепление и стан на всех людей в зоне поражения. Обнаруживается лишь детектором, реагирует на мобов.",
		/obj/anomaly/rvach/three_and_three = "Рвач - аномалия всасывающая в себе все предметы и существ в случае активации. Обнаруживается детектором, предметами и мобами. Из аномалии можно выбраться, если пытаться вылезать после 5 секунд активации (Если ориентироваться по звуку, то прям перед звуком удара). Люди лишаются конечностей (Руки/ноги), мобов гибает, вещи удаляет. Админский параметр мощности способен гибать, вместо отрывания конечностей.",
		/obj/anomaly/heater/three_and_three = "Грелка - аномалия греющая все существа находящиеся на турфе ядра и вспомогательных частей. Обнаруживается лишь детектором, никакие скафандры не защищают от её влияния.Взводятся лишь мобом.",
		/obj/anomaly/heater/two_and_two = "Грелка - аномалия греющая все существа находящиеся на турфе ядра и вспомогательных частей. Обнаруживается лишь детектором, никакие скафандры не защищают от её влияния.Взводятся лишь мобом.",
		/obj/anomaly/cooler/two_and_two = "Холодильник - аномалия охлаждающая все существа находящиеся на турфе ядра и вспомогательных частей. Обнаруживается лишь детектором, никакие скафандры не защищают от её влияния. Взводятся лишь мобом.",
		/obj/anomaly/cooler/three_and_three = "Холодильник - аномалия охлаждающая все существа находящиеся на турфе ядра и вспомогательных частей. Обнаруживается лишь детектором, никакие скафандры не защищают от её влияния. Взводятся лишь мобом."

	)
	var/help_text = {"\
********* Build Mode: Areas ********
Left Click        - Place anomaly
Right Click       - Delete anomaly
Middle click      - Choose anomaly
Shift + Left Click- Information about choosed anomaly
Cntrl + Left Click - Configurate anomaly
************************************\
"}



/datum/build_mode/anomalies/Destroy()
	UnselectAnomaly()
	Unselected()
	. = ..()


/datum/build_mode/anomalies/Help()
	to_chat(user, SPAN_NOTICE(help_text))


/datum/build_mode/anomalies/OnClick(atom/A, list/parameters)
	//Удаление аномалии
	if (parameters["right"])
		if(istype(A, /obj/anomaly))
			var/obj/anomaly/target = A
			target.delete_anomaly()
		else
			to_chat(user, SPAN_BAD("This is not anomaly"))
		return
	//Тонкая настройка именно этой аномалии
	else if(parameters["ctrl"])
		if(istype(A, /obj/anomaly))
			configurate_anomaly(A)
		else
			to_chat(user, SPAN_BAD("This is not anomaly"))
		return
	//Выбираем какую аномалию хотим заспавнить
	else if(parameters["middle"])
		Configurate()
		return
	else if(parameters["shift"])
		to_chat(user, SPAN_NOTICE("[possible_anomalies[anomaly_type]]"))
		return
	//Аномалия не выбрана
	if(!anomaly_type)
		to_chat(user, SPAN_BAD("Anomaly not choosed"))
		return
	var/location = get_turf(A)
	var/obj/anomaly/spawned_anomaly = new anomaly_type (location)
	if(spawned_anomaly.multitile)
		calculate_effected_turfs(spawned_anomaly)


/datum/build_mode/anomalies/Configurate()
	var/choosed_anomaly_type = input(usr, "Choose anomaly for spawn","Configurate") as null|anything in possible_anomalies
	anomaly_type = choosed_anomaly_type

/datum/build_mode/anomalies/proc/SelectAnomaly(obj/anomaly/A)
	if(!A || A == anomaly_type)
		return
	UnselectAnomaly()
	anomaly_type = A
	GLOB.destroyed_event.register(anomaly_type, src, PROC_REF(UnselectAnomaly))

/datum/build_mode/anomalies/proc/configurate_anomaly(atom/A)
	return

/datum/build_mode/anomalies/proc/UnselectAnomaly()
	if(!anomaly_type)
		return
	GLOB.destroyed_event.unregister(anomaly_type, src, PROC_REF(UnselectAnomaly))
	anomaly_type = null
