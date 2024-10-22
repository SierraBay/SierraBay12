/proc/random_dir()
	return pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

/obj/anomaly/ventilyator
	name = "air flows"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/tramplin.ogg'
	idle_effect_type = "trampline_idle"
	layer = ABOVE_HUMAN_LAYER
	effect_range = 0
	effect_type = LONG_ANOMALY_EFFECT
	var/random_flow_dir = FALSE
	var/flow_dir = EAST
	var/range_of_flow = 8
	var/speed_of_flow = 5
	var/list/list_of_effected_turfs = list()
	iniciators = list(
		/mob/living,
		/obj/item
	)
	//Рандомизация
	ranzomize_with_initialize = TRUE
	can_born_artifacts = FALSE
	min_coldown_time = 15 SECONDS
	max_coldown_time = 30 SECONDS
	time_between_effects = 0.25 SECONDS
	being_preload_chance = 10
	chance_to_be_detected = 75

/obj/anomaly/ventilyator/Initialize()
	. = ..()
	if(!random_flow_dir)
		list_of_effected_turfs = collect_turfs(flow_dir, range_of_flow)


//Функция собирает все турфы на определённом растоянии на определённом dir
/obj/anomaly/ventilyator/proc/collect_turfs(dir, range)
	var/list/output_list = list()
	for(var/i = 1, i < range, i++)
		LAZYADD(output_list, get_edge_target_turf(src, dir))


/obj/anomaly/ventilyator/activate_anomaly()
	if(random_flow_dir)
		list_of_effected_turfs = collect_turfs(random_dir(), range_of_flow)


/obj/anomaly/ventilyator/get_effect_by_anomaly(target)
	if(ismech(target))
		return
	if(ishuman(target))
		to_chat(target, "Вас с силой сдувает с земли!")


///Жарим всех вокруг в течении действия аномалии
/obj/anomaly/ventilyator/process_long_effect()
	for(var/atom/atoms in list_of_effected_turfs)
		get_effect_by_anomaly(atoms)
	start_processing_long_effect()
