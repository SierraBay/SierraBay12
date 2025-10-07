//Ремонт BURN урона при помощи проводки
/mob/living/exosuit/proc/coil_repair(obj/item/tool, mob/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (!getFireLoss())
		USE_FEEDBACK_FAILURE("\The [src] has no electrical damage to repair.")
		return TRUE
	var/obj/item/mech_component/input_fix = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if (!input_fix || !user.use_sanity_check(src, tool))
		return TRUE
	if (!input_fix.burn_damage)
		USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] no longer needs repair.")
		return TRUE
	input_fix.repair_burn_generic(tool, user)
	return TRUE
