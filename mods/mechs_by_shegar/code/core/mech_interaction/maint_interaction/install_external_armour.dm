/mob/living/exosuit/proc/install_external_armour(obj/item/mech_external_armor/plate, mob/living/user)
	if(plate.broken)
		USE_FEEDBACK_FAILURE("\The [plate] is too damaged to mount.")
		return
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC)) //Снимать и закреплять броню явно проще чем самого меха
		USE_FEEDBACK_FAILURE("You have no idea how to work with external armour.")
		return
	var/obj/item/mech_component/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choosed_part || !user.use_sanity_check(src, plate))
		return
	if(!choosed_part.can_have_external_armour)
		USE_FEEDBACK_FAILURE("\The [choosed_part] has no mounts for external armour.")
		return
	if(choosed_part.installed_armor)
		USE_FEEDBACK_FAILURE("\The [choosed_part] already has external armour mounted.")
		return
	if(!user.unEquip(plate, choosed_part))
		FEEDBACK_UNEQUIP_FAILURE(user, plate)
		return
	choosed_part.install_external_armour(plate)
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	to_chat(user, SPAN_NOTICE("You mount \the [plate] on \the [choosed_part]."))
