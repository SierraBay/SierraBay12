/obj/structure/coatrack/proc/can_be_added_suit(mob/user, obj/item/clothing/input_suit)
	if(suit)
		USE_FEEDBACK_FAILURE("\The [src] already has a suit on it.")
		return FALSE

	for(var/type in banned_clotch_types)
		if(istype(input_suit, type))
			return FALSE

	return TRUE



/obj/structure/coatrack/proc/can_be_added_helmet(mob/user, obj/item/clothing/input_helmet)
	if(helmet)
		USE_FEEDBACK_FAILURE("\The [src] already has a hat on it.")
		return FALSE

	for(var/type in banned_clotch_types)
		if(istype(input_helmet, type))
			return FALSE

	return TRUE
