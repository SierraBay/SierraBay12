//В этом файле написан код для многотайтловых аномалий. Их задача - заспавниться когда спавнится ЯДРО
//Код ядра в anomaly_core.dm, передавать информацию или "Включения" своему ядру.

//Данная функция вычислит все турфы находящиеся в "Блоке", тобишь в прямоугольнике,левый верхний угол которого input_turf
//А правый нижний угол - вычисляется в функции как end_turf. Если выставлено move_to_center, функция постарается
//Сдвинуть блок так, чтоб исходный input_turf оказался в центре, таким образом проведя центрирование
/proc/block_by_coordinates(turf/input_turf, x, y, move_to_center = FALSE)
	var/turf/start_turf = input_turf
	var/turf/end_turf = input_turf

	if(move_to_center)
		var/x_offset = x/2
		var/y_offset = y/2
		x = x - x_offset
		y = y - y_offset
		x = floor(x)
		y = floor(y)
		x_offset = floor(x_offset)
		y_offset = floor(y_offset)

		for(var/i=1 to x_offset)
			start_turf = get_step(start_turf, WEST)
		for(var/i=1 to y_offset)
			start_turf = get_step(start_turf, NORTH)

	for(var/i=1 to x)
		end_turf = get_step(end_turf, EAST)
	for(var/i=1 to y)
		end_turf = get_step(end_turf, SOUTH)

	return block(start_turf, end_turf)

//Здесь рассписаны переменные для корректной работы многотайтловых аномалий.
/obj/anomaly
	///Аномалия состоит из множества частей?
	var/multitile = FALSE
	///Означает, что обьект является вспомогательной частью. Применяется для контроллера.
	var/is_helper = FALSE
	//Путь вспомогательной части аномалии
	var/helper_part_path = /obj/anomaly/part
	var/parts_x_width = 3
	var/parts_y_width = 3
	//Минимальное и максимальное значение ширины X
	var/min_x_size = 0
	var/max_x_size = 0
	var/min_y_size = 0
	var/max_y_size = 0
	var/list/possible_presets = list()
	///Одноразовая переменная цель которой обьяснить инициализации и спавну аномалии что ей не стоит вмешиваться.
	var/spawn_called_by_generator = FALSE

	var/list/list_of_parts

/obj/anomaly/Initialize()
	. = ..()
	if(multitile && !spawn_called_by_generator)
		deploy_tiles_of_anomaly()

//Должен вызываться
/obj/anomaly/New(turf,input_x, input_y, called_by_generator = FALSE)
	if(called_by_generator)
		spawn_called_by_generator = TRUE
	.=..()
	if(called_by_generator)
		deploy_tiles_of_anomaly(input_x, input_y)

/obj/anomaly/proc/deploy_tiles_of_anomaly(input_x_width, input_y_width)
	//Найдём конечный тууурф
	var/local_x
	var/local_y
	if(input_x_width && input_y_width) //Размеры уже посчитал протокол
		local_x = input_x_width
		local_y = input_y_width
	else //Значит считаем сами
		local_x = parts_x_width
		local_y = parts_y_width
		if(min_x_size && max_x_size)
			local_x = rand(min_x_size, max_x_size)
		if(min_y_size && max_y_size)
			local_y = rand(min_y_size, max_y_size)
	if((!parts_x_width || !parts_y_width) && (!max_x_size || !max_y_size))
		CRASH("AHTUNG RAZRAB DAUN: Ядро размещения аномалий попыталось разместить мультитайловую аномалию без нужных для этого значений.")
	for(var/turf/T in block_by_coordinates(input_turf = get_turf(src), x = local_x, y = local_y, move_to_center = TRUE))
		var/obj/anomaly/part/spawned_anomaly_part = new helper_part_path(T)
		LAZYADD(list_of_parts, spawned_anomaly_part)
	connect_core_with_parts(list_of_parts)
	for(var/obj/anomaly/part/detected_anomaly_part in get_turf(src))
		detected_anomaly_part.Destroy()

///Эта функция соединит все дополнительные обьекты и ядро между собой
/obj/anomaly/proc/connect_core_with_parts(list/list_of_parts)
	for(var/obj/anomaly/part/part in list_of_parts)
		part.core = src
		part.icon_state = icon_state
		LAZYADD(anomaly_turfs, get_turf(part))

/obj/anomaly/part
	///ЯДРО, которму и передатся информация
	var/obj/anomaly/core
	name = "Вспомогательная часть аномалии."
	is_helper = TRUE


///Если какой-либо атом пересекает вспомогательную часть - передаём сигнал ядру
/obj/anomaly/part/Crossed(atom/movable/O)
	if(!core || !core.loc) //Ядра нет у аномалии
		qdel(src)
		return
	core.Crossed(O)

///Вспомогательная часть аномалии сама по себе НЕ может взводится
/obj/anomaly/part/activate_anomaly()
	return

///Ядро запросил проверить свой тайтл на момент возбудителей
/obj/anomaly/part/proc/part_check_title()
	if(!core || !core.loc) //Ядра нет у аномалии
		qdel(src)
		return
	for(var/atom/movable/target in src.loc)
		if(core.can_be_activated(target))
			return TRUE

	return FALSE

/obj/anomaly/part/get_detection_icon(mob/living/viewer)
	if(core)
		return core.get_detection_icon(viewer)
