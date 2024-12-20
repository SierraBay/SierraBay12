/mob/living/exosuit/proc/welder_repair(obj/item/tool, mob/user)
	if (!getBruteLoss())
		USE_FEEDBACK_FAILURE("\The [src] has no physical damage to repair.")
		return
	var/list/damaged_parts = list()
	for (var/obj/item/mech_component/component in list(arms, legs, body, head))
		if (component?.brute_damage)
			damaged_parts += component
	var/obj/item/mech_component/input_fix = input(user, "Which component would you like to fix?", "\The [src] - Fix Component") as null|anything in damaged_parts
	if (!input_fix || !user.use_sanity_check(src, tool))
		return
	if (!input_fix.brute_damage)
		USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] no longer needs repair.")
		return
	if(input_fix.current_hp == input_fix.max_repair || input_fix.current_hp < input_fix.max_repair)
		USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] is too damaged and requires repair with material.")
		return
	input_fix.repair_brute_generic(tool, user)
