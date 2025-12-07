/mob/living/exosuit/proc/welder_repair(obj/item/tool, mob/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (!getBruteLoss())
		USE_FEEDBACK_FAILURE("Чинить нечего, всё целое.")
		return
	var/obj/item/mech_component/input_fix = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if (!input_fix || !user.use_sanity_check(src, tool))
		return
	if (!input_fix.brute_damage)
		USE_FEEDBACK_FAILURE("Ремонт больше не требуется.")
		return
	if(input_fix.current_hp == input_fix.max_repair || input_fix.current_hp < input_fix.max_repair)
		USE_FEEDBACK_FAILURE("Повреждения слишком серьёзные, понадобится ремонт материалом.")
		return
	input_fix.repair_brute_generic(tool, user)
