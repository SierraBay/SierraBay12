/mob/living/exosuit/proc/deinstall_equipment(obj/item/tool, mob/user)
	if (hardpoints_locked)
		USE_FEEDBACK_FAILURE("\The [src]'s hardpoint system is locked.")
		return TRUE
	var/list/parts = list()
	for (var/hardpoint in hardpoints)
		if (hardpoints[hardpoint])
			parts += hardpoint
	var/input = input(user, "Which component would you like to remove?", "\The [src] - Remove Hardpoint") as null|anything in parts
	if (!input || !user.use_sanity_check(src, tool))
		return
	if (isnull(hardpoints[input]))
		USE_FEEDBACK_FAILURE("\The [src] not longer has a component in the [input] slot.")
		return
	remove_system(input, user)
