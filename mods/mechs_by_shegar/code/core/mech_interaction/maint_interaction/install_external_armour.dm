/mob/living/exosuit/proc/install_external_armour(obj/item/tool, mob/living/user)

	var/obj/item/mech_external_armor/armor = tool
	if(armor.current_health == 0)
		to_chat(user, SPAN_BAD("Броня слишком повреждена для использования."))
		return
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC)) //Снимать и закреплять броню явно проще чем самого меха
		to_chat(user, SPAN_BAD("Понятия не имею как работать с навесной бронёй."))
		return
	var/obj/item/mech_component/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choosed_part.can_have_external_armour)
		to_chat(user, SPAN_BAD("На данной части попросту нет таких креплений."))
		return
	if(choosed_part.installed_armor)
		to_chat(user, SPAN_NOTICE("Бронеэлемент уже присутствует."))
		return
	if (!user.unEquip(tool, choosed_part))
		FEEDBACK_UNEQUIP_FAILURE(user, tool)
		return TRUE
	choosed_part.installed_armor = tool
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	on_update_icon()
	to_chat(user, SPAN_GOOD("Бронеэлемент установлен."))
