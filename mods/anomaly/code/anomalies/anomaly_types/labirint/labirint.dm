#include "labirint_parts.dm"
#define OUT 1
#define IN 2
#define BOTH 3
#define FORCE_OUT 4
#define FORCE_IN 5
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
	min_x_size = 2
	max_x_size = 9
	min_y_size = 2
	max_y_size = 9
	//Лабиринт перестраивает своё состояние
	cooldown_time = 1 MINUTES
	var/in_labirint_cooldown = FALSE
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list(
		/obj/item/artefact/crystal
	)
	spawn_artefact_in_center = TRUE
	detection_skill_req = SKILL_MASTER
	helper_part_path = /obj/anomaly/part/labirint_cube
	//Количество выходов из аномалии
	var/exits_ammout = 1
	var/list/border_parts = list()

//Куб лабиринта который и будет пускать/не пускать
/obj/anomaly/part/labirint_cube
	var/NORTH_STATUS = IN
	var/SOUTH_STATUS= IN
	var/WEST_STATUS = IN
	var/EAST_STATUS = IN

/obj/anomaly/labirint/connect_core_with_parts(list/list_of_parts)
	.=..()
	for(var/obj/anomaly/part/labirint_cube/picked_part in list_of_parts)
		picked_part.icon = icon
		picked_part.refresh_icon_state()

//Кто-то вошёл в аномалию, нам нужно начать обрабатывать нашу ловушку
/obj/anomaly/labirint/Crossed(atom/movable/O)
	. = ..()
	if(isghost(O) || isobserver(O) || in_labirint_cooldown)
		return
	setup_borders()
	process_labirint_trap()

/obj/anomaly/labirint/proc/setup_borders()
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
	//Всем выставляем гарантированный вход всем частям по краям
	for(var/obj/anomaly/part/labirint_cube/border_part in border_parts)
		if(border_part.x == max_x)
			border_part.EAST_STATUS = FORCE_IN
		if(border_part.x == min_x)
			border_part.WEST_STATUS = FORCE_IN
		if(border_part.y == max_y)
			border_part.NORTH_STATUS = FORCE_IN
		if(border_part.y == min_y)
			border_part.SOUTH_STATUS = FORCE_IN


	//После того как мы нашли все крайние блоки аномалии, нужно определиться какой из них выходной
	var/i = 0
	while(exits_ammout > i)
		var/obj/anomaly/part/labirint_cube/picked = pick(border_parts)
		if(picked.x == max_x)
			picked.EAST_STATUS = FORCE_OUT
		if(picked.x == min_x)
			picked.WEST_STATUS = FORCE_OUT
		if(picked.y == max_y)
			picked.NORTH_STATUS = FORCE_OUT
		if(picked.y == min_y)
			picked.SOUTH_STATUS = FORCE_OUT
		i++



//Задача функции - обновить состояния своих блоков и проверить, требуется ли оно исходя из того
//Есть ли в пределах аномалии люди
/obj/anomaly/labirint/proc/process_labirint_trap()
	var/somebody_inside = FALSE
	for(var/turf/T in anomaly_turfs)
		for(var/mob/living/carbon/somebody_detected in T)
			somebody_inside = TRUE
			break
		if(somebody_inside)
			break
	//Лабиринт засыпает
	if(!somebody_inside)
		go_slep_labirint()
		return
	for(var/obj/anomaly/part/labirint_cube/picked_cube in list_of_parts)
		picked_cube.randomise_ways()
	in_labirint_cooldown = TRUE
	addtimer(new Callback(src, PROC_REF(process_labirint_trap)), cooldown_time)

/obj/anomaly/labirint/proc/go_slep_labirint()
	in_labirint_cooldown = FALSE
	border_parts = null

#undef OUT
#undef IN
#undef BOTH
#undef FORCE_OUT
#undef FORCE_IN
