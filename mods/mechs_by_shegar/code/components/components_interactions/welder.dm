/obj/item/mech_component/proc/welder_interacion(obj/item/thing, mob/user)
	if(current_hp == max_repair || current_hp < max_repair)
		USE_FEEDBACK_FAILURE("\The [src]'s [name] is too damaged and requires repair with material.")
		return TRUE
	repair_brute_generic(thing, user)
	return TRUE
