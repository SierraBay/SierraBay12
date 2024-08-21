//Здесь расположена логика аномалий отвечающая за продолжительное воздействие аномалии, по типу жарки или рвача.
/obj/anomaly
	///В текущий момент времени находится в активном состоянии
	var/currently_active = FALSE
	///Если аномалия влияет не один тик, а продолжительное время вокруг себя
	var/effect_type = MOMENTUM_ANOMALY_EFFECT
	///Время, которое аномалия влият
	var/effect_time = 1 SECOND
	///Время между каждым воздействием аномалии
	var/time_between_effects = 0.5 SECOND


///Если аномалия обладает долгим эффектом, мы его обрабатываем
/obj/anomaly/proc/handle_long_effect()
	currently_active = TRUE //Обьявляем что аномалия активна
	start_processing_long_effect()
	last_activation_time = world.time

///Аномалия будет поджигать и жечь согласно её effect_range столько, сколько указано в effect_time
/obj/anomaly/proc/start_processing_long_effect()
	if((world.time - last_activation_time) > effect_time)
		stop_processing_long_effect()
		return
	start_long_visual_effect()
	addtimer(new Callback(src, PROC_REF(process_long_effect)), time_between_effects)

///Убиваем обработку эффекта
/obj/anomaly/proc/stop_processing_long_effect()
	stop_long_visual_effect()
	currently_active = FALSE
	start_recharge()

/obj/anomaly/proc/process_long_effect()
	return
