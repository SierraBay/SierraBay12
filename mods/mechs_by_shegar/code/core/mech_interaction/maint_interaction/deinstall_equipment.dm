/mob/living/exosuit/proc/deinstall_equipment(obj/item/tool, mob/user)
	var/list/parts = list()
	for (var/hardpoint in hardpoints)
		if (hardpoints[hardpoint])
			LAZYADD(parts, hardpoints[hardpoint])
			// Сохраняем связь между объектом и его hardpoint
			parts[hardpoints[hardpoint]] = hardpoint

	if(!LAZYLEN(parts))
		USE_FEEDBACK_FAILURE("У этого меха нет снаряжения")
		return

	var/list/equipments_list_images = make_item_radial_menu_choices(parts)
	if(!LAZYLEN(equipments_list_images))
		CRASH("MECH BUG, no equipmants images list")

	var/input = show_radial_menu(user, src, equipments_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if (!input || !user.use_sanity_check(src, tool))
		return

	// Получаем hardpoint для выбранного объекта
	var/hardpoint_to_remove = parts[input]
	if (isnull(hardpoints[hardpoint_to_remove]))
		USE_FEEDBACK_FAILURE("У меха больше нет снаряжения в этом слоте")
		return

	remove_system(hardpoint_to_remove, user)
