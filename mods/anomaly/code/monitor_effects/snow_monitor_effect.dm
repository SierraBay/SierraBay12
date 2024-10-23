//Эффект снежной вьюги
/obj/monitor_effect_triger/snow
	icon_state = "snow_storm"
	icon = 'mods/anomaly/icons/weather_effects.dmi'
	must_react_at_enter = TRUE
	sound_type = list(
		'mods/anomaly/sounds/snowstorm.ogg'
	)

/obj/monitor_effect_triger/snow
	trigger_messages_list = list(
		"Мрачные облака, толстый слой инея на земле и стремительные порывы ветра делают каждый шаг испытанием.",
		"Белое пространство, прерываемое лишь силуэтами ледяных скал, напоминающих причудливые формации.",
		"Бесконечный буран, да и только. Паршивая планета.",
		"Куда ни глянь — пустота. Ядовито-белый мрак простирается до самого горизонта, как бесконечный океан.",
		"Холод, кажется, проникает не только внутрь, но и в самые глубокие уголки твоей души сквозь скафандр. Каждое движение даётся через силу, а мысли теряются среди непрекращающегося гула ветра.",
		"Рокот небес, напряженный до предела, сопровождает каждое твое движение.",
		"Ледяная пыль начинает шевелиться, и этот далекий гул намекает на опасность.",
		"Ты поднимаешь голову, наблюдая, как пурга хлещет по ледяным вершинам.",
		"Каждый шорох и треск вокруг как будто вызывают у тебя певучее предчувствие опасности.",
		"Тьма нависла над тобой, как тяжелый саван. Кажется, что даже звезды в небе отдалились от этого ледяного кошмара."
	)

//Эффект снега на экране
/obj/screen/fullscreen/snow_effect
	icon = 'mods/anomaly/icons/snow_screen.dmi'
	icon_state = "snow"
	layer = BLIND_LAYER
	scale_to_view = TRUE



/obj/monitor_effect_triger/snow/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("snow_monitor", /obj/screen/fullscreen/snow_effect)
	//Логируем пользователя в глобальный список

/obj/monitor_effect_triger/snow/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("snow_monitor")
