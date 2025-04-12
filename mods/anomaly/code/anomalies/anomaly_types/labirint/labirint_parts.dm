#define OUT 1
#define IN 2
#define BOTH 3
#define FORCE_OUT 4
#define FORCE_IN 5
#define FORCE_BOTH 6
#define FORCE_BLOCKED 7
//OUT - по этому направлению лишь выпускает
//IN - по этому направлению лишь впускают
//BOTH - и впускает и выпускает
//FORCE_OUT 4 - пока из аномалии не выйдут в этом месте всегда будет выход. Используется чтоб поменить где будет выход из аномалии
//FORCE_IN 5 - В аномалию всегда можно войти с любой стороны.
//FORCE_BOTH 6 - В аномалию всегда можно войты и выйти с этой стороны
//Куб лабиринта который и будет пускать/не пускать
/obj/anomaly/part/labirint_cube
	var/NORTH_STATUS = IN
	var/SOUTH_STATUS= IN
	var/WEST_STATUS = IN
	var/EAST_STATUS = IN
	var/is_path_part = FALSE
	var/pathweight = 1 //Цена куба для пайнтфайда. Используется чтоб АСтар не шёл куда не надо.

/obj/anomaly/labirint/connect_core_with_parts(list/list_of_parts)
	.=..()
	for(var/obj/anomaly/part/labirint_cube/picked_part in list_of_parts)
		picked_part.icon = icon
		picked_part.refresh_icon_state()


//Куб обновляет свой спрайт исходя из своего состояния
/obj/anomaly/part/labirint_cube/proc/refresh_icon_state()
	ClearOverlays()
	var/list/new_overlays = list()
	//СЕВЕР
	if(NORTH_STATUS == IN || NORTH_STATUS == FORCE_IN)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "NORTH_IN")
	else if(NORTH_STATUS == OUT || NORTH_STATUS == FORCE_OUT)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "NORTH_OUT")
	else if(NORTH_STATUS == BOTH)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "NORTH_BOTH")
	//ЗАПАД
	if(WEST_STATUS == IN || WEST_STATUS == FORCE_IN)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "WEST_IN")
	else if(WEST_STATUS == OUT || WEST_STATUS == FORCE_OUT)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "WEST_OUT")
	else if(WEST_STATUS == BOTH)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "WEST_BOTH")
	//ВОСТОК
	if(EAST_STATUS == IN || EAST_STATUS == FORCE_IN)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "EAST_IN")
	else if(EAST_STATUS == OUT || EAST_STATUS == FORCE_OUT)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "EAST_OUT")
	else if(EAST_STATUS == BOTH)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "EAST_BOTH")
	//ЮГ
	if(SOUTH_STATUS == IN || SOUTH_STATUS == FORCE_IN)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "SOUTH_IN")
	else if(SOUTH_STATUS == OUT || SOUTH_STATUS == FORCE_OUT)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "SOUTH_OUT")
	else if(SOUTH_STATUS == BOTH)
		new_overlays += image('mods/anomaly/icons/labirint_anomaly.dmi', "SOUTH_BOTH")
	SetOverlays(new_overlays)


/obj/anomaly/part/labirint_cube/CanPass(atom/movable/mover, turf/target, height, air_group)
	var/target_to_cube_dir = get_dir(src, mover)
	switch(target_to_cube_dir)
		//Перс заходит с севера
		if(NORTH)
			if(NORTH_STATUS == IN || NORTH_STATUS == FORCE_IN || NORTH_STATUS == BOTH || NORTH_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE
		if(WEST)
			if(WEST_STATUS == IN || WEST_STATUS == FORCE_IN || WEST_STATUS == BOTH || WEST_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE
		if(SOUTH)
			if(SOUTH_STATUS == IN || SOUTH_STATUS == FORCE_IN || SOUTH_STATUS == BOTH || SOUTH_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE
		if(EAST)
			if(EAST_STATUS == IN || EAST_STATUS == FORCE_IN || EAST_STATUS == BOTH || EAST_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE


/obj/anomaly/part/labirint_cube/Uncross(atom/O)
	var/target_to_cube_dir = O.dir //Хз как понять направление куда хочет идти игрок, допустим исходя из его dir
	switch(target_to_cube_dir)
		//Перс заходит с севера
		if(NORTH)
			if(NORTH_STATUS == OUT || NORTH_STATUS == FORCE_OUT || NORTH_STATUS == BOTH || NORTH_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE
		if(WEST)
			if(WEST_STATUS == OUT || WEST_STATUS == FORCE_OUT || WEST_STATUS == BOTH || WEST_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE
		if(SOUTH)
			if(SOUTH_STATUS == OUT || SOUTH_STATUS == FORCE_OUT || SOUTH_STATUS == BOTH || SOUTH_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE
		if(EAST)
			if(EAST_STATUS == OUT || EAST_STATUS == FORCE_OUT || EAST_STATUS == BOTH || EAST_STATUS == FORCE_BOTH)
				return TRUE
			else
				return FALSE

/obj/anomaly/part/labirint_cube/proc/randomise_ways()
	if(is_path_part) // Кубы на пути статичны
		return
	if(NORTH_STATUS != FORCE_OUT && NORTH_STATUS != FORCE_IN && NORTH_STATUS != FORCE_BOTH && NORTH_STATUS != FORCE_BLOCKED)
		NORTH_STATUS = pick(list(IN, OUT, BOTH))
	if(SOUTH_STATUS != FORCE_OUT && SOUTH_STATUS != FORCE_IN && SOUTH_STATUS != FORCE_BOTH && SOUTH_STATUS != FORCE_BLOCKED)
		SOUTH_STATUS = pick(list(IN, OUT, BOTH))
	if(WEST_STATUS != FORCE_OUT && WEST_STATUS != FORCE_IN && WEST_STATUS != FORCE_BOTH && WEST_STATUS != FORCE_BLOCKED)
		WEST_STATUS = pick(list(IN, OUT, BOTH))
	if(EAST_STATUS != FORCE_OUT && EAST_STATUS != FORCE_IN && EAST_STATUS != FORCE_BOTH && EAST_STATUS != FORCE_BLOCKED)
		EAST_STATUS = pick(list(IN, OUT, BOTH))
	refresh_icon_state()

/obj/anomaly/part/labirint_cube/get_detection_icon(mob/living/viewer)
	if(is_path_part)
		if(!(get_turf(viewer) in core.anomaly_turfs))
			return "labirint_way"
	return detection_icon_state

#undef OUT
#undef IN
#undef BOTH
#undef FORCE_OUT
#undef FORCE_IN
#undef FORCE_BOTH
#undef FORCE_BLOCKED
