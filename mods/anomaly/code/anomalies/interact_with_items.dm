//Здесь расположен код отвечающие за взаимодействие аномалий с предметами.
/proc/anything_in_ashes(atom/input_item)
	var/turf/to_place = get_turf(input_item)
	input_item.visible_message(SPAN_BAD("[input_item] плавится!"))
	new /obj/decal/cleanable/ash (to_place)
	qdel(input_item)

/proc/anything_in_remains(atom/input_item)
	var/turf/to_place = get_turf(input_item)
	input_item.visible_message(SPAN_BAD("Тело [input_item] испепелило до костей!"))
	new /obj/item/remains (to_place)
	qdel(input_item)
