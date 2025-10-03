/datum/map_template/ruin/exoplanet/field_of_suits
	name = "Field of suits"
	id = "field_of_suits"
	description = "a field of old spacesuits and mysterious circumstances"
	prefix = "mods/chich_overmap_content/maps/insidiae/"
	suffixes = list("field_of_suits.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS|TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_HUMAN



/obj/landmark/corpse/field_of_suits_poor_fellow
	corpse_outfits = list(/singleton/hierarchy/outfit/field_of_suits/eng, /singleton/hierarchy/outfit/field_of_suits/med, /singleton/hierarchy/outfit/field_of_suits/sci, /singleton/hierarchy/outfit/field_of_suits/sec)

/singleton/hierarchy/outfit/field_of_suits
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
