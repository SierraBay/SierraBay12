/datum/gear/shoes/leather
	display_name = "leather boot selection"
	path = /obj/item/clothing/shoes/jackboots/leather/
	cost = 2

/datum/gear/shoes/leather/New()
	..()
	var/westernboots = list()
	westernboots += /obj/item/clothing/shoes/jackboots/leather
	westernboots += /obj/item/clothing/shoes/jackboots/leather/gray
	westernboots += /obj/item/clothing/shoes/jackboots/leather/heavy
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(westernboots)
