//Данный файл отвечает за всю графику и внешнюю часть аномалий. Спрайты, иконки, переменные отвечающие за внешний вид
//И тому подобное.
/obj/anomaly
	invisibility = INVISIBILITY_OBSERVER  //Будет виден лишь гостам
	icon = 'mods/anomaly/icons/effects.dmi'
	///Эффект активации.
	var/activation_effect_type
	///Эффект в идле
	var/idle_effect_type = "none"
	plane = OBSERVER_PLANE
	///Здесь вам потребуется вручную указать длинну анимации, для того чтоб игра вновь сделала её невидимой и некликабельной для игрока
	//Костыль, но лучше решения ещё не придумал
	var/momentum_animation_long = 0.6 SECONDS

/obj/anomaly/proc/do_momentum_animation()
	if(activation_effect_type)
		invisibility = 0
		flick(activation_effect_type, src)
		if(light_after_activation)
			start_light()
		addtimer(new Callback(src, PROC_REF(hide_momentum_animation)), momentum_animation_long)

/obj/anomaly/proc/hide_momentum_animation()
	invisibility = INVISIBILITY_OBSERVER

/obj/anomaly/proc/start_long_visual_effect()
	invisibility = 0
	icon_state = activation_effect_type
	if(light_after_activation)
		start_light()

/obj/anomaly/proc/stop_long_visual_effect()
	invisibility = INVISIBILITY_OBSERVER
	icon_state = idle_effect_type

/obj/ebeam/electra
	plane = WARP_EFFECT_PLANE
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | TILE_BOUND
	z_flags = ZMM_IGNORE
