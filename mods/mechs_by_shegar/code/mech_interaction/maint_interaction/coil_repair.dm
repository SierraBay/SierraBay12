//Ремонт BURN урона при помощи проводки
/mob/living/exosuit/proc/coil_repair(obj/item/tool, mob/user)
	if (!getFireLoss())
		USE_FEEDBACK_FAILURE("\The [src] has no electrical damage to repair.")
		return TRUE
	if(usr in pilots)
		USE_FEEDBACK_FAILURE("\The [src] cannot be repaired from the inside.")
		return TRUE
	var/list/damaged_parts = list()
	for (var/obj/item/mech_component/component in list(arms, legs, body, head))
		if (component?.burn_damage)
			damaged_parts += component
	var/obj/item/mech_component/input_fix = input(user, "Which component would you like to fix?", "\The [src] - Fix Component") as null|anything in damaged_parts
	if (!input_fix || !user.use_sanity_check(src, tool))
		return TRUE
	if (!input_fix.burn_damage)
		USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] no longer needs repair.")
		return TRUE
	input_fix.repair_burn_generic(tool, user)
	return TRUE
