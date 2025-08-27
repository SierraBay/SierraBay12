#include "labirint_parts.dm"
#include "labirint_starting.dm"
#include "paths.dm"
#define CUBE_BLOCKED 1
#define CUBE_UNBLOCKED 2
//Сильно схожая с ашановской аномалия из которой нужно искать выход, выискивая закономерности в её работе
//После того как внутрь лабиринта попадает человек, он взводится
//Все кубы закрываются, открываются только те что являются кубами пути

/obj/anomaly/labirint
	name = "Refractions of light"
	anomaly_tag = "Labirint"
	idle_effect_type = "labirint"
	admin_name = "Лабиринт"
	effect_type = MOMENTUM_ANOMALY_EFFECT
	multitile = TRUE
	min_x_size = 5
	max_x_size = 10
	min_y_size = 5
	max_y_size = 10
	//Лабиринт перестраивает своё состояние
	cooldown_time = 1 MINUTES
	//В случае каких-либо багов и прочих непредвиденных чудес лабиринт автоматически раскроется
	//Спустя какое-то время
	//var/max_labirint_time = 8 MINUTES
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list(
		/obj/item/artefact/crystal
	)
	can_born_artefacts = TRUE
	spawn_artefact_in_center = TRUE
	detection_skill_req = SKILL_BASIC
	helper_part_path = /obj/anomaly/part/labirint_cube
	var/turf/start_turf
	var/obj/anomaly/part/labirint_cube/current_exit_cube
	var/list/border_parts = list() //Крайние кубы которые расположены по краям аномалии
	var/list/exit_path = list() //Кубы по которым и выходят из аномалии

//Кто-то вошёл в аномалию, нам нужно начать обрабатывать нашу ловушку
/obj/anomaly/labirint/Crossed(atom/movable/O)
	return

/obj/anomaly/labirint/proc/move_to_start(atom/movable/O)
	if(start_turf)
		O.forceMove(start_turf)

///Из лабиринта вышли, проверим, нам из-за этого засыпать?
/obj/anomaly/labirint/proc/labirint_leaved()
	var/result = FALSE
	for(var/turf/T in anomaly_turfs)
		for(var/mob/living/carbon/human/human in T)
			if(human.ckey)
				result = TRUE
				break
	if(!result)
		go_slep_labirint()
		return FALSE
	return TRUE

/obj/anomaly/labirint/proc/full_open_labirint()
	for(var/obj/anomaly/part/labirint_cube/cube in list_of_parts)
		cube.STATUS = CUBE_UNBLOCKED
	go_slep_labirint()

///Раскроет все граничные блоки аномалии
/obj/anomaly/labirint/proc/open_all_cubes()
	for(var/obj/anomaly/part/labirint_cube/border_part in list_of_parts)
		border_part.STATUS = CUBE_UNBLOCKED
		border_part.is_playable = TRUE
	border_parts = null

///Забудет о существовании выходного пути
/obj/anomaly/labirint/proc/desetup_exit_path()
	for(var/obj/anomaly/part/labirint_cube/cube in exit_path)
		cube.is_path_part = FALSE
	exit_path = null

/obj/anomaly/labirint/proc/go_slep_labirint()
	start_turf = null
	current_exit_cube = null
	open_all_cubes()
	desetup_exit_path()

#undef CUBE_BLOCKED
#undef CUBE_UNBLOCKED
