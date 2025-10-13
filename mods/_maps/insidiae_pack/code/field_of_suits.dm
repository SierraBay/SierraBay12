/datum/map_template/ruin/exoplanet/field_of_suits
	name = "field of suits"
	id = "field_of_suits"
	description = "A field of old spacesuits and mysterious circumstances."
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("field_of_suits_base.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS|TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_HUMAN
	skip_main_unit_tests = TRUE

/obj/landmark/map_load_mark/field_of_suits
	name = "random field of suits site"
	templates = list(/datum/map_template/field_of_suits/a, /datum/map_template/field_of_suits/b, /datum/map_template/field_of_suits/c, /datum/map_template/field_of_suits/d)

/datum/map_template/field_of_suits
	skip_main_unit_tests = TRUE

/datum/map_template/field_of_suits/a
	name = "random field of suits site #1"
	id = "field_of_suits_1"
	mappaths = list("mods/_maps/insidiae_pack/maps/field_of_suits1.dmm")

/datum/map_template/field_of_suits/b
	name = "random field of suits site #2"
	id = "field_of_suits_2"
	mappaths = list("mods/_maps/insidiae_pack/maps/field_of_suits2.dmm")

/datum/map_template/field_of_suits/c
	name = "random field of suits site #3"
	id = "field_of_suits_3"
	mappaths = list("mods/_maps/insidiae_pack/maps/field_of_suits3.dmm")

/datum/map_template/field_of_suits/d
	name = "random field of suits site #4"
	id = "field_of_suits_4"
	mappaths = list("mods/_maps/insidiae_pack/maps/field_of_suits4.dmm")



/obj/landmark/corpse/field_of_suits_poor_fellow
	corpse_outfits = list(/singleton/hierarchy/outfit/field_of_suits/eng, /singleton/hierarchy/outfit/field_of_suits/med, /singleton/hierarchy/outfit/field_of_suits/sci, /singleton/hierarchy/outfit/field_of_suits/sec)

/singleton/hierarchy/outfit/field_of_suits
	name = "Dead body on the Field of Suits"
	suit = /obj/item/clothing/suit/space/void/excavation/field_of_suits
	head = /obj/item/clothing/head/helmet/space/void/excavation/field_of_suits
	mask = /obj/item/clothing/mask/breath
	l_pocket = /obj/item/device/radio
	suit_store = /obj/item/tank/jetpack/oxygen

/singleton/hierarchy/outfit/field_of_suits/eng
	name = "Dead engineer on the Field of Suits"
	uniform = /obj/item/clothing/under/retro/engineering
	shoes = /obj/item/clothing/shoes/workboots

/singleton/hierarchy/outfit/field_of_suits/med
	name = "Dead doctor on the Field of Suits"
	uniform = /obj/item/clothing/under/retro/medical
	shoes = /obj/item/clothing/shoes/jackboots

/singleton/hierarchy/outfit/field_of_suits/sci
	name = "Dead explorer on the Field of Suits"
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/workboots

/singleton/hierarchy/outfit/field_of_suits/sec
	name = "Dead officer on the Field of Suits"
	uniform = /obj/item/clothing/under/retro/security
	shoes = /obj/item/clothing/shoes/jackboots



/obj/item/clothing/head/helmet/space/void/excavation/field_of_suits
	name = "old excavation voidsuit helmet"
	desc = "An old and rusty voidsuit helmet, once capable of protecting its owner from exotic alien energies and many dangers. It seems that this helmet was not enough to protect its owner."
	color = "#b8a366"

/obj/item/clothing/suit/space/void/excavation/field_of_suits
	name = "old excavation voidsuit"
	desc = "An old, torn, and rusty voidsuit, it was supposed to protect its owner from exotic alien energies, as well as from the more common dangers associated with excavations. It seems that this voidsuit was not enough to protect its owner."
	color = "#b8a366"

/obj/item/clothing/suit/space/void/excavation/field_of_suits/Initialize()
	. = ..()
	create_breaches(DAMAGE_BRUTE, rand(30, 40))
	create_breaches(DAMAGE_BRUTE, rand(20, 40))
