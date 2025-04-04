/obj/anomaly/circus
	name = "Refractions of light"
	anomaly_tag = "Circus"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/rvach_activation.ogg'
	static_sound_type = 'mods/anomaly/sounds/gravi_idle.ogg'
	idle_effect_type = "rvach_idle"
	activation_effect_type = "gravy_anomaly_down"
	can_born_artefacts = TRUE
	weight_sensity = ITEM_SIZE_LARGE
	///Сколько длится первая фаза рвача(всасывание)
	effect_time = 3.5 SECONDS
	var/max_delay_between_cycles = 0.6 SECONDS
	var/min_delay_between_cycles = 0.1 SECONDS
	time_between_effects = 0.6 SECOND
	effect_type = LONG_ANOMALY_EFFECT
	cooldown_time = 25 SECONDS
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list(
		/obj/item/artefact/flyer = 2
	)
	spawn_artefact_in_center = TRUE
	artefact_spawn_chance = 20
	detection_skill_req = SKILL_MASTER
	//Это очень большая аномалия
	multitile = TRUE
	min_x_size = 3
	max_x_size = 9
	min_y_size = 3
	max_y_size = 9

/obj/anomaly/circus/Initialize()
	. = ..()
	calculate_corners()

/obj/anomaly/circus/Crossed(atom/movable/O)
	if(!currently_active && can_be_activated(O))
		activate_anomaly()
	else
		add_victim()
