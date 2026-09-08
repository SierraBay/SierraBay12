/datum/fabricator_recipe/mini_suit_cooler
	path = /obj/item/device/suit_cooling_unit/mini

/mob/living/MouseDrop(atom/over_object)
	if(istype(loc, /obj/item/holder))
		return ..()

	if(over_object && usr == src && istype(over_object, /obj/item/storage))
		var/obj/item/storage/S = over_object
		if(holder_type && !buckled && !length(pinned) && !incapacitated())
			if(can_fit_in_storage(S))
				var/obj/item/holder/H = new holder_type(get_turf(src))
				src.forceMove(H)

				if(S.can_be_inserted(H, src) && S.handle_item_insertion(H))
					H.sync(src)
					to_chat(src, SPAN_NOTICE("You fold yourself up and climb into \the [S]!"))
					for(var/mob/living/M in S.loc)
						if(M != src)
							to_chat(M, SPAN_NOTICE("\The [src] folds themselves up and climbs into \the [S]!"))
					return TRUE
				else
					src.forceMove(get_turf(src))
					qdel(H)
					to_chat(src, SPAN_WARNING("You can't fit in \the [S]!"))

	return ..()

/obj/item/holder/MouseDrop(atom/over_atom, atom/source_loc, atom/over_loc, source_control, over_control, list/mouse_params)
	if(over_atom == usr)
		for(var/mob/M in contents)
			M.show_inv(usr)
	return ..()

/mob/living/proc/can_fit_in_storage(obj/item/storage/S)
	var/storage_space = S.max_storage_space
	if(isnull(storage_space) && S.storage_slots)
		storage_space = S.storage_slots * BASE_STORAGE_COST(S.max_w_class)

	if(!storage_space)
		return FALSE

	var/mob_space = mob_size
	return (storage_space >= mob_space)
