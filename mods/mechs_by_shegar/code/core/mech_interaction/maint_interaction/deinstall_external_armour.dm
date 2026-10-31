/mob/living/exosuit/proc/deinstall_external_armour(obj/item/tool, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC)) //Снимать и закреплять броню явно проще чем самого меха
		USE_FEEDBACK_FAILURE("You have no idea how to work with external armour.")
		return
	var/obj/item/mech_component/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choosed_part || !user.use_sanity_check(src, tool))
		return
	if(!choosed_part.installed_armor)
		USE_FEEDBACK_FAILURE("\The [choosed_part] has no external armour mounted.")
		return
	if(!choosed_part.armour_can_be_removed)
		USE_FEEDBACK_FAILURE("\The [choosed_part.installed_armor] is not built to come off \the [choosed_part].")
		return
	var/obj/item/mech_external_armor/plate = choosed_part.remove_external_armour()
	user.put_in_hands(plate)
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	to_chat(user, SPAN_NOTICE("You remove \the [plate] from \the [choosed_part]."))
