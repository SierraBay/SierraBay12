//Детектор Сарасповой получил дополнительную функцию - проверять, находится ли детектор в зоне поражения аномалии.
#define SCAN_ANOMALIES 1
#define SCAN_ARTEFACTS_AND_RADIATION 2

/turf
	var/in_anomaly_effect_range = FALSE

/obj/item/device/ano_scanner
	var/current_mode = SCAN_ARTEFACTS_AND_RADIATION
	var/last_peek_time = 0
	var/peek_delay = 0.2 SECONDS


///Альт клик по детектору
/obj/item/device/ano_scanner/AltClick(mob/living/user)
	changemode(user)

///Смена режима работы детектора
/obj/item/device/ano_scanner/proc/changemode(mob/living/user)
	if(current_mode == SCAN_ARTEFACTS_AND_RADIATION)
		current_mode = SCAN_ANOMALIES
		START_PROCESSING(SSobj, src)
		to_chat(user, SPAN_NOTICE("Current mode: Scan anomalies"))
	else if(current_mode == SCAN_ANOMALIES)
		current_mode = SCAN_ARTEFACTS_AND_RADIATION
		STOP_PROCESSING(SSobj, src)
		to_chat(user, SPAN_NOTICE("Current mode: Scan artifacts and radiation"))
	playsound(loc, 'sound/weapons/guns/selector.ogg', 40)

/obj/item/device/ano_scanner/interact(mob/living/user)
	if(current_mode == SCAN_ANOMALIES)
		scan_anomalies(user)
		return
	.=..()


/obj/item/device/ano_scanner/proc/scan_anomalies()
	if(world.time - last_scan_time >= peek_delay )
		last_peek_time = world.time
	var/turf/cur_turf = get_turf(src)
	//Проверяем, турф на котором мы находимся находится в зоне поражения?
	if(cur_turf.in_anomaly_effect_range)
		playsound(loc, 'mods/anomaly/sounds/detector_peek.ogg', 40)

/obj/item/device/ano_scanner/Process()
	if(current_mode != SCAN_ANOMALIES)
		return
	scan_anomalies()

/obj/item/device/ano_scanner/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_GOOD("Use alt+LBM to switch scan mode."))

/obj/item/paper/sierra/exploration
	name = "new dangers"
	info = "<tt><center><b><large>NSV Sierra</large></b></center><center>Новые опасности</center><li><b>Одна из последних экспедиций вернулась с новой информацией, и ранениями. Согласно последнему отчёту, экспедиционный отряд наткнулся на некую аномальную активность на одной из планет. Научно исследовательский отдел выделил вашему корпусу дополнительное снаряжение и модифицировал сканеры Сарасповой, добавив им АЛЬТЕРНАТИВНЫЙ режим. Советуем проявлять огромную осторожность при работе на планетах. Удачи.</b><hr></tt><br><i>This paper has been stamped by the Research&Development department.</i>"
	icon = 'maps/sierra/icons/obj/uniques.dmi'
	icon_state = "paper_words"
