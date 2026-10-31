//Гаечный ключ по части, лежащей отдельно от меха: снять с неё внешний бронеэлемент
/obj/item/mech_component/proc/wrench_interacion(obj/item/thing, mob/user)
	if(!installed_armor)
		to_chat(user, SPAN_WARNING("\The [src] has no external armour mounted."))
		return
	if(!armour_can_be_removed)
		to_chat(user, SPAN_WARNING("\The [installed_armor] is not built to come off \the [src]."))
		return
	var/obj/item/mech_external_armor/plate = remove_external_armour()
	user.put_in_hands(plate)
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	to_chat(user, SPAN_NOTICE("You remove \the [plate] from \the [src]."))
