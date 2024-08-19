//Здесь расположен код отвечающие за взаимодействие с предметами.
/proc/anything_in_ashes(atom/input_item)
	var/turf/to_place = get_turf(input_item)
	new /obj/decal/cleanable/ash (to_place)
	qdel(input_item)

/proc/anything_in_remains(atom/input_item)
	var/turf/to_place = get_turf(input_item)
	new /obj/item/remains (to_place)
	qdel(input_item)
