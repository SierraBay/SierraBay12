//В этом файле написан код для многотайтловых аномалий. Их задача - заспавниться когда спавнится ЯДРО
//Код ядра в anomaly_core.dm, передавать информацию или "Включения" своему ядру.

//Здесь рассписаны переменные для корректной работы многотайтловых аномалий.
/obj/anomaly
	///Аномалия состоит из множества частей?
	var/multitile = FALSE
	///Радиус в котором спавнятся остальные части от ядра
	var/multititle_parts_range = 1
	var/list/list_of_parts

/obj/anomaly/Initialize()
	. = ..()
	if(multitile)
		if(multititle_parts_range == 1)
			var/turf/REF = get_turf(src)
			var/obj/anomaly/part/A = new(get_step(REF, NORTH))
			var/obj/anomaly/part/B = new(get_step(REF, NORTHEAST))
			var/obj/anomaly/part/C = new(get_step(REF, EAST))
			var/obj/anomaly/part/D = new(get_step(REF, SOUTHEAST))
			var/obj/anomaly/part/E = new(get_step(REF, SOUTH))
			var/obj/anomaly/part/F = new(get_step(REF, SOUTHWEST))
			var/obj/anomaly/part/G = new(get_step(REF, WEST))
			var/obj/anomaly/part/H = new(get_step(REF, NORTHWEST))
			list_of_parts = list(A,B,C,D,E,F,G,H)
		if(multititle_parts_range == 0)
			return
		connect_core_with_parts(list_of_parts)

///Эта функция соединит все дополнительные обьекты и ядро между собой
/obj/anomaly/proc/connect_core_with_parts(list/list_of_parts)
	for(var/obj/anomaly/part/part in list_of_parts)
		part.core = src

///Этот обьект в случае детектирования подходящих условий, передаст информацию ядру.
/obj/anomaly/part
	///ЯДРО, которму и передатся информация
	var/obj/anomaly/core
	name = "Вспомогательная часть аномалии."


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
