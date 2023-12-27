/datum/gear/suit/fancy_jackets
	display_name = "fancy jackets selection"
	path = /obj/item/clothing/suit

/datum/gear/suit/fancy_jackets/New()
	..()
	var/fancy_jackets = list()
	fancy_jackets += /obj/item/clothing/suit/storage/drive_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/toggle/the_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/brand_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/brand_orange_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/brand_rjacket
	fancy_jackets += /obj/item/clothing/suit/storage/hooded/faln_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/leon_jacket
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(fancy_jackets)
