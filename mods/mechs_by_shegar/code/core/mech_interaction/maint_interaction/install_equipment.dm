/mob/living/exosuit/proc/install_equipment(obj/item/tool, mob/user)
	if (!maintenance_protocols)
		USE_FEEDBACK_FAILURE("\The [src]'s hardpoint system is locked. Turn on maintenance protocols")
		return
	var/obj/item/mech_equipment/mech_equipment = tool
	if (mech_equipment.owner)
		USE_FEEDBACK_FAILURE("\The [tool] is already owned by \the [mech_equipment.owner]. This might be a bug.")
		return
	var/list/free_hardpoints_images = list()
	for (var/hardpoint in hardpoints)
		if (isnull(hardpoints[hardpoint]) && (!length(mech_equipment.restricted_hardpoints) || (hardpoint in mech_equipment.restricted_hardpoints)))
			free_hardpoints_images[hardpoint] = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', hardpoint)

	if (!length(free_hardpoints_images))
		USE_FEEDBACK_FAILURE("\The [src] has no free hardpoints for \the [tool].")
		return

	var/input = show_radial_menu(user, user, free_hardpoints_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if (hardpoints[input] != null)
		USE_FEEDBACK_FAILURE("\The [input] slot on \the [src] is no longer free. It has \a [hardpoints[input]] attached.")
		return
	if(!check_whitelist_equipment(tool))
		USE_FEEDBACK_FAILURE("Одна из часть меха не поддерживает данное снаряжение.")
		return
	install_system(tool, input, user)

/mob/living/exosuit/proc/check_whitelist_equipment(obj/item/tool)
	for(var/obj/item/mech_component/mech_part in list(head, body, R_arm, L_arm, R_leg, L_leg))
		if(!LAZYLEN(mech_part.whitelist_equipment_paths))
			continue
		if(!(tool.type in mech_part.whitelist_equipment_paths))
			return FALSE
	return TRUE
