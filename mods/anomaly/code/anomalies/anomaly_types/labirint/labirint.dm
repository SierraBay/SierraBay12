#include "labirint_parts.dm"
#include "paths.dm"
#define OUT 1
#define IN 2
#define BOTH 3
#define FORCE_OUT 4
#define FORCE_IN 5
#define FORCE_BOTH 6
#define FORCE_BLOCKED 7
//Сильно схожая с ашановской аномалия из которой нужно искать выход, выискивая закономерности в её работе
//После того как внутрь лабиринта попадает человек, он заводится
//В заведённом состоянии лабиринт переключает состояния своих внутренних клеток.
//У внутренних клеток может быть закрыта или открыта одна сторона
/obj/anomaly/labirint
	name = "Refractions of light"
	anomaly_tag = "Labirint"
	icon = 'mods/anomaly/icons/labirint_anomaly.dmi'
	idle_effect_type = "base"
	effect_type = MOMENTUM_ANOMALY_EFFECT
	multitile = TRUE
	min_x_size = 5
	max_x_size = 10
	min_y_size = 5
	max_y_size = 10
	//Лабиринт перестраивает своё состояние
	cooldown_time = 1 MINUTES
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list(
		/obj/item/artefact/crystal
	)
	spawn_artefact_in_center = TRUE
	detection_skill_req = SKILL_BASIC
	helper_part_path = /obj/anomaly/part/labirint_cube
	//Количество выходов из аномалии
	var/exits_ammount = 1
	var/list/exit_parts = list() //Внешние кубы которые являются выходом
	var/list/border_parts = list() //Крайние кубы которые расположены по краям аномалии
	var/list/exit_path = list() //Кубы по которым и выходят из аномалии

//Кто-то вошёл в аномалию, нам нужно начать обрабатывать нашу ловушку
/obj/anomaly/labirint/Crossed(atom/movable/O)
	. = ..()
	if(isghost(O) || isobserver(O) || LAZYLEN(exit_path))
		return
	setup_borders(O)
	setup_pathweights()
	setup_exit_path(O)
	if(!LAZYLEN(exit_path))
		full_open_labirint()
	process_labirint_trap()

/obj/anomaly/labirint/proc/setup_borders(atom/movable/movable_atom)
	//Всё довольно просто. Включаются в список тех кто на краю те, что находятся на максимальных/минимальных X и Y
	var/max_x = 0
	var/min_x = 10000
	var/max_y = 0
	var/min_y = 10000
	for(var/obj/anomaly/part/labirint_cube/part in list_of_parts)
		if(!part.x || !part.y)
			continue
		if(part.x < min_x)
			min_x = part.x
		if(part.x > max_x)
			max_x = part.x
		if(part.y < min_y)
			min_y = part.y
		if(part.y > max_y)
			max_y = part.y
	//Вычисляем все те части что находятся скраю
	for(var/obj/anomaly/part/labirint_cube/picked_part in list_of_parts)
		if(picked_part.x == max_x || picked_part.x == min_x || picked_part.y == max_y || picked_part.y == min_y)
			LAZYADD(border_parts, picked_part)
	//Всем выставляем блок по краям чтоб 2 человека в аномалию не залезли
	for(var/obj/anomaly/part/labirint_cube/border_part in border_parts)
		if(border_part.x == max_x)
			border_part.EAST_STATUS = FORCE_BLOCKED
		if(border_part.x == min_x)
			border_part.WEST_STATUS = FORCE_BLOCKED
		if(border_part.y == max_y)
			border_part.NORTH_STATUS = FORCE_BLOCKED
		if(border_part.y == min_y)
			border_part.SOUTH_STATUS = FORCE_BLOCKED
	setup_exit_cube(movable_atom, max_x, min_x, max_y, min_y)

/obj/anomaly/labirint/proc/setup_pathweights()
	for(var/obj/anomaly/part/labirint_cube/picked_part in list_of_parts)
		picked_part.pathweight = rand(1, 5) //Мы выдаём рандомный вес чтоб игра строила более извилистые пути

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

//Задача функции - обновить состояния своих блоков и проверить, требуется ли оно исходя из того
//Есть ли в пределах аномалии люди
/obj/anomaly/labirint/proc/process_labirint_trap()
	for(var/obj/anomaly/part/labirint_cube/picked_cube in list_of_parts)
		picked_cube.randomise_ways()
	addtimer(new Callback(src, PROC_REF(process_labirint_trap)), cooldown_time)

/obj/anomaly/labirint/proc/full_open_labirint()
	for(var/obj/anomaly/part/labirint_cube/cube in list_of_parts)
		cube.NORTH_STATUS = FORCE_BOTH
		cube.EAST_STATUS = FORCE_BOTH
		cube.WEST_STATUS = FORCE_BOTH
		cube.SOUTH_STATUS = FORCE_BOTH
	go_slep_labirint()

///Раскроет все граничные блоки аномалии
/obj/anomaly/labirint/proc/desetup_borders()
	for(var/obj/anomaly/part/labirint_cube/border_part in border_parts)
		border_part.EAST_STATUS = BOTH
		border_part.WEST_STATUS = BOTH
		border_part.NORTH_STATUS = BOTH
		border_part.SOUTH_STATUS = BOTH
	border_parts = null

/obj/anomaly/labirint/proc/go_slep_labirint()
	desetup_borders()
	desetup_exit_path()
	for(var/obj/anomaly/part/labirint_cube/picked_cube in list_of_parts)
		picked_cube.force_randomise_ways()

#undef OUT
#undef IN
#undef BOTH
#undef FORCE_OUT
#undef FORCE_IN
#undef FORCE_BOTH
#undef BLOCKED
#undef FORCE_BLOCKED
