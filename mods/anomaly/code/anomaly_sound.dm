//Здесь находится код и переменные отвечающие за звук
/obj/anomaly
	///У аномалии есть звук активации?
	var/with_sound = FALSE
	///Путь до звука
	var/sound_type
	///Мощность аномалии
	var/effect_power = DEFAULT_ANOMALY_EFFECT
	//У аномалии есть статичный звук
	var/have_static_sound = FALSE
	//Путь до звука статики
	var/static_sound_type = 'mods/anomaly/sounds/any_idle.ogg'

	var/preload_sound_type
