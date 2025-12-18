//Здесь расположен код отвечающие за взаимодействие аномалий с предметами.
/proc/anything_in_ashes(atom/input_item)
	set waitfor = FALSE
	var/turf/to_place = get_turf(input_item)
	input_item.visible_message(SPAN_BAD("[input_item] плавится!"))
	var/obj/ashes = new /obj/decal/cleanable/ash (to_place)
	ashes.alpha = 0
	animate(input_item, alpha = 0, time = 10, easing = EASE_OUT)
	animate(ashes, alpha = 255, time = 10, easing = EASE_OUT)
	sleep(10)
	qdel(input_item)

/proc/anything_in_remains(atom/input_item)
	set waitfor = FALSE
	var/turf/to_place = get_turf(input_item)
	input_item.visible_message(SPAN_BAD("Тело [input_item] испепелило до костей!"))
	new /obj/item/remains (to_place)
	qdel(input_item)

//Разные аномалии уничтожают вещи по разному
/obj/anomaly/proc/destroy_item_by_anomaly(atom/input_item, overdrive_del)
	set waitfor = FALSE
	SSanom.destroyed_items++
	if(!overdrive_del)
		qdel(input_item)

/obj/anomaly/electra/destroy_item_by_anomaly(atom/input_item, overdrive_del = TRUE)
	.=..()
	anything_in_ashes(input_item)
