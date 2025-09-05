/obj/structure/heavy_vehicle_frame/proc/tags_check(obj/item/mech_component/input_part, mob/living/user)
	for(var/obj/item/mech_component/internal_part in src)
		if(internal_part.component_tag && !input_part.component_tag)
			return FALSE //У кого-то есть тэг, а у входного его нет, так не пойдёт
		if(!internal_part.component_tag && input_part.component_tag)
			return FALSE //Ни у кого из внутренних тэга нет, а у входного есть, так не пойдёт
		if(internal_part.component_tag != input_part.component_tag)
			return FALSE //Тэги не сходятся, так не пойдёт
	return TRUE
