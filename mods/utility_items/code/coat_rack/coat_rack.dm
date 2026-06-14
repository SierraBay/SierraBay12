/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats and hats."
	icon = 'mods/utility_items/icons/coatrack.dmi'
	icon_state = "coatrack"

	var/obj/item/clothing/suit
	var/image/suit_image

	var/obj/item/clothing/helmet
	var/image/helmet_image
	///некоторые шмотки увы выглядят отвратительно. Можете их забанить
	var/list/banned_clotch_types = list(
		/obj/item/clothing/suit/armor,
		/obj/item/clothing/suit/space
		)



///Чтоб не крутило спрайты на держалке. Более простое решение.
/obj/structure/coatrack/set_dir()
	return




//Тыкаем голой рукой
/obj/structure/coatrack/attack_hand(mob/user as mob)
	var/list/radial_choices = list()
	if(suit)
		radial_choices["Снять костюм"] = suit_image
	if(helmet)
		radial_choices["Снять шляпку"] = helmet_image
	if(!LAZYLEN(radial_choices))
		return

	var/choice
	if(LAZYLEN(radial_choices) == 1)
		choice = radial_choices[1]
	else
		choice = show_radial_menu(user, src, radial_choices, require_near = TRUE, radius = 50, tooltips = TRUE, check_locs = list(src))



	if(choice == "Снять костюм")
		remove_suit(user)
	else if(choice == "Снять шляпку")
		remove_helmet(user)




///Пытаемся надеть шмотку
/obj/structure/coatrack/use_tool(obj/item/tool, mob/user, list/click_params)
	if(!istype(tool, /obj/item/clothing))
		return


	if(istype(tool, /obj/item/clothing/head))
		if(!can_be_added_helmet(user, tool))
			return
		add_helmet(user, tool)


	else if(istype(tool, /obj/item/clothing/suit))
		if(!can_be_added_suit(user, tool))
			return
		add_suit(user, tool)

	return ..()





/obj/structure/coatrack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!isitem(mover))
		return
	var/obj/item/item_moved = mover
	if (!suit && istype(item_moved, /obj/item/clothing/suit))
		if(!can_be_added_suit(usr, item_moved))
			return TRUE
		visible_message("[item_moved] lands on \the [src].")
		add_suit(input_suit = item_moved)
		return TRUE
	if(!helmet && istype(item_moved, /obj/item/clothing/head))
		if(!can_be_added_helmet(usr, item_moved))
			return TRUE
		visible_message("[item_moved] lands on \the [src].")
		add_helmet(input_helmet = item_moved)
		return TRUE

	return TRUE
