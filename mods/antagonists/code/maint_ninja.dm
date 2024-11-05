/obj/item/rig_module/teleporter/check(charge = 50)
	if(damage >= 2)
		to_chat(usr, SPAN_WARNING("The [interface_name] is damaged beyond use!"))
		return 0

	if(world.time < next_use)
		to_chat(usr, SPAN_WARNING("You cannot use the [interface_name] again so soon."))
		return 0

	if(!holder || holder.canremove)
		to_chat(usr, SPAN_WARNING("The suit is not initialized."))
		return 0

	if(holder.security_check_enabled && !holder.check_suit_access(usr))
		to_chat(usr, SPAN_DANGER("Access denied."))
		return 0

	if(!holder.check_power_cost(usr, charge, 0, src, (istype(usr,/mob/living/silicon ? 1 : 0) ) ) )
		return 0

	return 1
