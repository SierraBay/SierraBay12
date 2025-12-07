/obj/item/mech_component/proc/welder_interacion(obj/item/thing, mob/user)
	if(current_hp == max_repair || current_hp < max_repair)
		USE_FEEDBACK_FAILURE("Повреждения слишком серьёзные, понадобится ремонт материалом.")
		return TRUE
	repair_brute_generic(thing, user)
	return TRUE
