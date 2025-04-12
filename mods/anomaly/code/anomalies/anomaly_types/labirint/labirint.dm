#include "labirint_parts.dm"
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
	var/list/exit_parts = list() //Внешние кубы которые являются выходом
	var/list/border_parts = list() //Крайние кубы которые расположены по краям аномалии
	var/list/exit_path = list() //Кубы по которым и выходят из аномалии

//Кто-то вошёл в аномалию, нам нужно начать обрабатывать нашу ловушку
/obj/anomaly/labirint/Crossed(atom/movable/O)
	. = ..()
	if(isghost(O) || isobserver(O) || in_labirint_cooldown)
		return
	setup_borders()
	setup_exit_path(O)
	if(!LAZYLEN(exit_path))
		//УВИ мы поймали ошибку, надо бы это в рантайм логинг как-то закинуть.
		full_open_labirint()
		return
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


	//После того как мы нашли все крайние блоки аномалии, нужно определиться какой из них выходной
	//очень важно чтоб никто не стоял в этом турфе
	var/i = 0
	while(exits_ammout > i)
		var/obj/anomaly/part/labirint_cube/picked = pick(border_parts)
		if(!locate(/mob/living/carbon/human) in get_turf(picked))
			if(picked.x == max_x)
				picked.EAST_STATUS = FORCE_OUT
			if(picked.x == min_x)
				picked.WEST_STATUS = FORCE_OUT
			if(picked.y == max_y)
				picked.NORTH_STATUS = FORCE_OUT
			if(picked.y == min_y)
				picked.SOUTH_STATUS = FORCE_OUT
			i++
			LAZYADD(exit_parts, picked)


/obj/anomaly/labirint/proc/setup_exit_path(atom/movable/input_movable)
	var/turf/start = get_turf(input_movable)
	var/obj/anomaly/part/labirint_cube/exit = get_turf(pick(exit_parts))
	//Собираем лист турфов
	var/list/list_of_exit_turfs = AStar(start, exit, TYPE_PROC_REF(/turf, CardinalTurfsWithAccess), TYPE_PROC_REF(/turf, Distance), 0, 50, id = null, exclude = null) //Строим путь через алгоритм АСтар
	//Теперь собираем кубы на пути
	for(var/turf/turf in list_of_exit_turfs)
		for(var/obj/anomaly/part/labirint_cube/cube in turf)
			LAZYADD(exit_path, cube)
	//Теперь изменяем кубы в пути
	for(var/obj/anomaly/part/labirint_cube/cube in exit_path)
		cube.is_path_part = TRUE
	// Делаем проходы между кубами пути FORCE_BOTH
	for(var/i in 1 to (LAZYLEN(exit_path) - 1))
		var/obj/anomaly/part/labirint_cube/current = exit_path[i]
		var/obj/anomaly/part/labirint_cube/next = exit_path[i + 1]

		if(!current || !next)  // На всякий случай проверяем
			continue

		var/dir_to_next = get_dir(current, next)

		// Открываем сторону current в направлении next
		switch(dir_to_next)
			if(NORTH)
				current.NORTH_STATUS = FORCE_BOTH
			if(SOUTH)
				current.SOUTH_STATUS = FORCE_BOTH
			if(EAST)
				current.EAST_STATUS = FORCE_BOTH
			if(WEST)
				current.WEST_STATUS = FORCE_BOTH

		// Открываем сторону next в направлении current (чтобы можно было идти обратно)
		var/dir_to_prev = turn(dir_to_next, 180)
		switch(dir_to_prev)
			if(NORTH)
				next.NORTH_STATUS = FORCE_BOTH
			if(SOUTH)
				next.SOUTH_STATUS = FORCE_BOTH
			if(EAST)
				next.EAST_STATUS = FORCE_BOTH
			if(WEST)
				next.WEST_STATUS = FORCE_BOTH

		current.refresh_icon_state()
		next.refresh_icon_state()

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

/obj/anomaly/labirint/proc/full_open_labirint()
	for(var/obj/anomaly/part/labirint_cube/cube in list_of_parts)
		cube.NORTH_STATUS = FORCE_BOTH
		cube.EAST_STATUS = FORCE_BOTH
		cube.WEST_STATUS = FORCE_BOTH
		cube.SOUTH_STATUS = FORCE_BOTH
	go_slep_labirint()


/obj/anomaly/labirint/proc/go_slep_labirint()
	in_labirint_cooldown = FALSE
	border_parts = null
	for(var/obj/anomaly/part/labirint_cube/cube in exit_path)
		cube.is_path_part = FALSE
	exit_path = null

#undef OUT
#undef IN
#undef BOTH
#undef FORCE_OUT
#undef FORCE_IN
#undef FORCE_BOTH
#undef BLOCKED
#undef FORCE_BLOCKED
