/mob/living/exosuit/proc/install_equipment(obj/item/tool, mob/user)
	if (!maintenance_protocols)
		USE_FEEDBACK_FAILURE("\The [src]'s hardpoint system is locked. Turn on maintenance protocols")
		return
	var/obj/item/mech_equipment/mech_equipment = tool
	if (mech_equipment.owner)
		USE_FEEDBACK_FAILURE("\The [tool] is already owned by \the [mech_equipment.owner]. This might be a bug.")
		return
	var/free_hardpoints = list()
	for (var/hardpoint in hardpoints)
		if (isnull(hardpoints[hardpoint]) && (!length(mech_equipment.restricted_hardpoints) || (hardpoint in mech_equipment.restricted_hardpoints)))
			free_hardpoints += hardpoint
	if (!length(free_hardpoints))
		USE_FEEDBACK_FAILURE("\The [src] has no free hardpoints for \the [tool].")
		return
	var/input = input(user, "Where would you like to install \the [tool]?", "\The [src] - Hardpoint Installation") as null|anything in free_hardpoints
	if (!input || !user.use_sanity_check(src, tool, SANITY_CHECK_DEFAULT | SANITY_CHECK_TOOL_UNEQUIP))
		return
	if (hardpoints[input] != null)
		USE_FEEDBACK_FAILURE("\The [input] slot on \the [src] is no longer free. It has \a [hardpoints[input]] attached.")
		return
	install_system(tool, input, user)
