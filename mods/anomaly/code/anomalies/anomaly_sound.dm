//Здесь находится код и переменные отвечающие за звук
/obj/anomaly
	///У аномалии есть звук активации?
	var/with_sound = FALSE
	///Путь до звука
	var/sound_type
	///Мощность аномалии
	var/effect_power = MOMENTUM_ANOMALY_EFFECT
	//Путь до луп звука
	var/static_sound_type
	///Применяется для размещения ЛУП звука
	var/static_sound_obj
	var/preload_sound_type
