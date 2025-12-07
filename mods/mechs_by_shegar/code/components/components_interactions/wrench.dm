/obj/item/mech_component/proc/wrench_interacion(obj/item/thing, mob/user)
	if(!armour_can_be_removed)
		to_chat(user, SPAN_BAD("У этого типа компонента не существует креплений."))
		return
	if(!installed_armor)
		to_chat(user,SPAN_BAD( "Броня отсутствует."))
		return
	user.put_in_hands(installed_armor)
	installed_armor = null
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	on_update_icon()
