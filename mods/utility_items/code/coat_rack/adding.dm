/obj/structure/coatrack/proc/add_suit(mob/user, obj/item/clothing/input_suit)
	if(user)
		if(!user.unEquip(input_suit, src))
			FEEDBACK_UNEQUIP_FAILURE(user, input_suit)
			return TRUE
	else
		input_suit.loc = src

	suit = input_suit

	var/icon/crop_icon
	if(LAZYLEN(input_suit.item_icons) && input_suit.item_icons["slot_suit"])
		crop_icon = icon(input_suit.item_icons["slot_suit"], input_suit.icon_state)
	else
		crop_icon = icon('icons/mob/onmob/onmob_suit.dmi', input_suit.icon_state)

	crop_icon.Crop(1, 1, 16, 32)
	suit_image = image(crop_icon)
	suit_image.transform = suit_image.transform.Translate(-7, 6)
	AddOverlays(suit_image)



/obj/structure/coatrack/proc/add_helmet(mob/user, obj/item/clothing/input_helmet)
	if(user)
		if(!user.unEquip(input_helmet, src))
			FEEDBACK_UNEQUIP_FAILURE(user, input_helmet)
			return TRUE
	else
		input_helmet.loc = src

	helmet = input_helmet
	var/icon/crop_icon
	if(LAZYLEN(input_helmet.item_icons) && input_helmet.item_icons["slot_head"])
		crop_icon = icon(input_helmet.item_icons["slot_head"], input_helmet.icon_state)
	else
		crop_icon = icon('icons/mob/onmob/onmob_head.dmi', input_helmet.icon_state)

	helmet_image = image(crop_icon)
	helmet_image.transform = helmet_image.transform.Turn(90)
	helmet_image.transform = helmet_image.transform.Translate(-5, 6)
	AddOverlays(helmet_image)
