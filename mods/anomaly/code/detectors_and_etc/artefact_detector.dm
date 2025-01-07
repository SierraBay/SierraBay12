/obj/item/artefact_detector
	name = "artefact detector"
	desc = "Newest advanced device, which can find artefacts."
	icon = 'mods/anomaly/icons/artefact_detector.dmi'
	on_turf_icon = 'mods/anomaly/icons/artefact_detector_on_floor.dmi'
	on_floor_icon
	icon_state = "medv_turned_off"
	item_state = "on_floor_off"
	//on_turf_icon = 'mods/anomaly/icons/artefact_detector_on_floor.dmi'
	var/capturing_method = "RANDOM" //RANDOM - любой на Z уровне. CLOSEST - ближайший на Z уровне. LONGEST - дальнейший на Z уровне.
	var/status = FALSE
	var/showing_artefact = FALSE //Детектор уже указывает куда-то
	var/obj/item/artefact/captured_artefact

/obj/item/artefact_detector/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_GOOD("Используйте КНТРЛ + ЛКМ для включения/выключения детектора."))

//Переключения//
/obj/item/artefact_detector/AltClick()
	if(!status)
		turn_on()
	else
		turn_off()
	return

/obj/item/artefact_detector/proc/turn_on()
	to_chat(usr, SPAN_NOTICE("Вы включили детектор"))
	flick("medv_turning_on", src)
	status = TRUE
	icon_state = "medv_turned_on"
	item_state = "on_floor_on"

/obj/item/artefact_detector/proc/turn_off()
	to_chat(usr, SPAN_NOTICE("Вы выключили детектор"))
	flick("medv_turning_off", src)
	if(status)
		forgive_artefact()
	status = FALSE
	icon_state = "medv_turned_off"
	item_state = "on_floor_off"

/obj/item/artefact_detector/attack_self(mob/living/user)
	. = ..()
	if(status)
		find_and_capture_artefact_in_Z()
		//Начинаем захват артефакта
	else
		to_chat(usr, SPAN_NOTICE("Детектор выключен."))

//Процессинг//
/obj/item/artefact_detector/Process()
	..()
	var/dir = get_dir(get_turf(src), get_turf(captured_artefact))
	if(!dir)
		forgive_artefact()
		icon_state = "medv_turned_on"
	else
		var/text_dir = dir2text(dir)
		icon_state = "medv_[text_dir]"

///Отдельные функции///
/obj/item/artefact_detector/proc/find_and_capture_artefact_in_Z()//Задача - найти артефакт в на Z уровне и запомнить его.
	if(!LAZYLEN(SSanom.artefacts_list_in_world)) //Артефактов в мире попросту нет
		to_chat(usr, SPAN_NOTICE("Похоже, [src] ничего не улавливает."))
		return FALSE

	var/list/good_z_artefacts_list = list()
	for(var/obj/item/artefact/choosed_artefact in SSanom.artefacts_list_in_world)
		if(get_z(src) == get_z(choosed_artefact))
			LAZYADD(good_z_artefacts_list,choosed_artefact)

	if(!LAZYLEN(good_z_artefacts_list)) //Артефакты то есть в мире, но не на нашем Z уровне
		to_chat(usr, SPAN_NOTICE("Похоже, [src] ничего не улавливает."))
		return FALSE

	if(capturing_method == "RANDOM")
		capture_artefact(pick(good_z_artefacts_list))
	else if(capturing_method == "CLOSEST")
		return
	else if(capturing_method == "LONGEST")
		return


/obj/item/artefact_detector/proc/capture_artefact(obj/item/artefact/input_artefact) //Функция захватывает и запоминает артефакт.
	to_chat(usr, SPAN_NOTICE("Похоже, [src] Что-то улавливает."))
	captured_artefact = input_artefact
	START_PROCESSING(SSanom, src)

/obj/item/artefact_detector/proc/forgive_artefact() //Функция забывает артефакт
	to_chat(usr, SPAN_NOTICE("[src] умолкает."))
	captured_artefact = null
	STOP_PROCESSING(SSanom, src)
	icon_state = "medv_turned_on"
