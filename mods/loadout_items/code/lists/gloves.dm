/datum/gear/gloves/driver
	display_name = "gloves, driver"
	path = /obj/item/clothing/gloves/driving_gloves

/datum/gear/gloves/driver/New()
	..()
	var/gloves = list()
	gloves += /obj/item/clothing/gloves/driving_gloves
	gloves += /obj/item/clothing/gloves/driving_gloves/gray
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(gloves)

/datum/gear/gloves/fingerless
	display_name = "fingerless gloves, color select"
	path = /obj/item/clothing/gloves/fingerless
	flags = GEAR_HAS_COLOR_SELECTION