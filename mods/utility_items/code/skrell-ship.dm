// Закоментите весь файл, если вам не нужна эта карта
/datum/map_template/ruin/away_site/skrellscoutship
	prefix = "mods/utility_items/maps/"
	suffixes = list("skrell-sierrabay.dmm")


//А здесь мы заменим спрайты войдов
/obj/item/clothing/head/helmet/space/void/skrell/black
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

/obj/item/clothing/head/helmet/space/void/skrell/white
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

/obj/item/clothing/suit/space/void/skrell/black
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

/obj/item/clothing/suit/space/void/skrell/white
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

// Very vegan freezer
/obj/structure/closet/crate/freezer/skrell
	name = "SDF rations"
	desc = "A crate of skrellian rations."

/obj/structure/closet/crate/freezer/skrell/WillContain()
	return list(
		/obj/item/reagent_containers/food/snacks/skrellsnacks = 16,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit = 8,
		/obj/item/reagent_containers/food/snacks/tossedsalad = 8
	)

// The Frog
/mob/living/simple_animal/friendly/frog/skrells_frog
	name = "Kro-krri"
	desc = "An unusual creature that looks like a frog, it looks sad."
