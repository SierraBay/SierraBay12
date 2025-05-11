#define CUBE_BLOCKED 1
#define CUBE_UNBLOCKED 2
//CUBE_BLOCKED - куб не пускает сквозь себя
//CUBE_UNBLOCKED - куб пускает сквозь себя
//Куб лабиринта который и будет пускать/не пускать
/obj/anomaly/part/labirint_cube
	var/STATUS = CUBE_UNBLOCKED
	var/is_path_part = FALSE
	//Куб неиграбелен, т.е через него нельзя выйти из лабиринта
	var/is_playable = TRUE
	var/pathweight = 1 //Цена куба для пайнтфайда. Используется чтоб АСтар не шёл куда не надо.

/obj/anomaly/part/labirint_cube/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(STATUS == CUBE_BLOCKED)
		if(get_turf(mover) in core.anomaly_turfs)
			deploy_temp_effect()
			core:move_to_start(mover)
		return FALSE
	else if(STATUS == CUBE_UNBLOCKED)
		return TRUE
	CRASH("Куб лабиринта имеет несуществующий для кода статус.")

/obj/anomaly/part/labirint_cube/proc/deploy_temp_effect()
	set waitfor = FALSE
	var/obj/spawned_effect = new /obj/effect/warp/labirint(get_turf(src))
	animate(spawned_effect, alpha = 40, time = 2 SECOND, easing = SINE_EASING)
	sleep(2 SECONDS)
	spawned_effect.Destroy()

/obj/anomaly/part/labirint_cube/Crossed(O)
	if(isghost(O) || isobserver(O) || LAZYLEN(core:exit_path))
		return
	if(src in core:border_parts)
		return
	core:start_labirint(O)

/obj/anomaly/part/labirint_cube/Uncrossed(O)
	if(!(get_turf(O) in core.anomaly_turfs))
		core:labirint_leaved()

/obj/anomaly/part/labirint_cube/get_detection_icon(mob/living/viewer)
	if(is_path_part)
		if(!(get_turf(viewer) in core.anomaly_turfs))
			return "labirint_way"
	return detection_icon_state

/obj/effect/warp/labirint
	icon = 'mods/anomaly/icons/effects.dmi'
	icon_state = "labirint_temp"
	pixel_x = 0
	pixel_y = 0

#undef CUBE_BLOCKED
#undef CUBE_UNBLOCKED
