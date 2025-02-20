/mob/living/exosuit/proc/welder_repair(obj/item/tool, mob/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (!getBruteLoss())
		USE_FEEDBACK_FAILURE("\The [src] has no physical damage to repair.")
		return
	var/obj/item/mech_component/input_fix = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if (!input_fix || !user.use_sanity_check(src, tool))
		return
	if (!input_fix.brute_damage)
		USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] no longer needs repair.")
		return
	if(input_fix.current_hp == input_fix.max_repair || input_fix.current_hp < input_fix.max_repair)
		USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] is too damaged and requires repair with material.")
		return
	input_fix.repair_brute_generic(tool, user)
