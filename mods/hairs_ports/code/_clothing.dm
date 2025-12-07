/obj/item/clothing/ears
	sprite_sheets = list(
			SPECIES_SKRELL = 'mods/hairs_ports/icons/ears.dmi'
		)

/obj/item/clothing/ears/skrell/equipped(mob/user)
	. = ..()
	if(istype(src, /obj/item/clothing/ears/skrell/cloth/male))
		return
	var/mob/living/carbon/human/human_user = user
	var/datum/sprite_accessory/hair/hairstyle = GLOB.hair_styles_list[human_user.head_hair_style]
	src.item_state = "[initial(icon_state)]_[hairstyle.icon_state]_s"
	user.update_inv_head()
