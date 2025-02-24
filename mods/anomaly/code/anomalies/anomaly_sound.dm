//Здесь находится код и переменные отвечающие за звук
/obj/anomaly
	///У аномалии есть звук активации?
	var/with_sound = FALSE
	///Путь до звука
	var/sound_type
	///Мощность аномалии
	var/effect_power = MOMENTUM_ANOMALY_EFFECT
	//Путь до звука статики
	var/static_sound_type 

	var/preload_sound_type
