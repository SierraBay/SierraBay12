/mob/living/exosuit/proc/deinstall_external_armour(obj/item/tool, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC)) //Снимать и закреплять броню явно проще чем самого меха
		to_chat(user, SPAN_BAD("Понятия не имею как работать с навесной бронёй."))
		return
	var/obj/item/mech_component/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choosed_part.armour_can_be_removed)
		to_chat(user, SPAN_BAD("У этого типа компонента не существует креплений."))
		return
	if(!choosed_part.installed_armor)
		to_chat(user, SPAN_BAD("Бронеэлемент отсутствует."))
		return
	user.put_in_hands(choosed_part.installed_armor)
	choosed_part.installed_armor = null
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	on_update_icon()
	to_chat(user, SPAN_GOOD("Бронеэлемент снят."))
