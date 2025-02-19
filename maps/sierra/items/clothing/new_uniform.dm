//УНИФОРМА
/obj/item/clothing/under/new_uniform/get_icon_state(mob/user_mob, slot)
	if(item_state_slots && item_state_slots[slot])
		. = item_state_slots[slot]
	else
		. = icon_state
	if(!findtext(.,"_s", -2)) // If we don't already have our suffix
		. +=  get_gender_suffix()
	else
		. += "_s"

/obj/item/clothing/under/new_uniform/
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_w_uniform_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)

/obj/item/clothing/under/new_uniform/cargo_trousers
	name = "cargo trousers"
	desc = "Sleek slim-fit trousers with extra pockets and some stripes hanging off the belt for... extra style points perhaps."
	icon_state = "cargo_trousers"
	item_state = "cargo_trousers"
	worn_state = "cargo_trousers"

/obj/item/clothing/under/new_uniform/cargos
	name = "cargo pants"
	desc = "Loose-fit grey cargo pants with plenty of pockets."
	icon_state = "cargos"
	item_state = "cargos"
	worn_state = "cargos"

/obj/item/clothing/under/new_uniform/neotac
	name = "neotac pants"
	desc = "Regular-fit trousers with gradient pattern and plenty of belts around the waist. For the sake of style, of course."
	icon_state = "neotac"
	item_state = "cargos"
	worn_state = "cargos"

/obj/item/clothing/under/new_uniform/breeches
	name = "denim breeches"
	desc = "Short-cut jeans with micromesh underlayer at the crotch for extra durability."
	icon_state = "breeches"
	item_state = "breeches"
	worn_state = "breeches"

/obj/item/clothing/under/new_uniform/gorka_pants //olive
	name = "olive gorka paints"
	desc = "Sturdy pants made of tarp-like fabric. Extremely durable."
	item_flags = ITEM_FLAG_THICKMATERIAL
	icon_state = "gorka_pants_olive"
	item_state = "gorka_pants_olive"
	worn_state = "gorka_pants_olive"

/obj/item/clothing/under/new_uniform/gorka_pants/tan
	name = "tan gorka paints"
	icon_state = "gorka_pants_tan"
	item_state = "gorka_pants_tan"
	worn_state = "gorka_pants_tan"

/obj/item/clothing/under/new_uniform/gorka_pants/blue
	name = "blue gorka paints"
	icon_state = "gorka_pants_blue"
	item_state = "gorka_pants_blue"
	worn_state = "gorka_pants_blue"

/obj/item/clothing/under/new_uniform/netrunner
	name = "specialized netrunner suit"
	desc = "A compressing, thermoregulating suit that prevents body from going numb of sitting still too long monitoring telecommunication systems."
	icon_state = "netrunner"
	item_state = "netrunner"
	worn_state = "netrunner"
	gender_icons = TRUE
	min_cold_protection_temperature = T0C - 5

/obj/item/clothing/under/new_uniform/plain_suit
	name = "White plain suit"
	desc = "A plain suit with double-breasted shirt. Buttons not included."
	icon_state = "plain_suit"
	item_state = "plain_suit"
	worn_state = "plain_suit"
	gender_icons = TRUE

/obj/item/clothing/under/new_uniform/plain_suit/dark
	name = "Dark plain suit"
	desc = "A plain suit with double-breasted shirt. Buttons not included."
	icon_state = "plain_suit_dark"
	item_state = "plain_suit_dark"
	worn_state = "plain_suit_dark"
	gender_icons = TRUE

/obj/item/clothing/under/new_uniform/kitsch_dress
	name = "kitsch dress"
	desc = "Very extravagant piece of fashion. Style over necessity."
	icon_state = "kitsch_dress_1"
	item_state = "kitsch_dress_1"
	worn_state = "kitsch_dress_1"

/obj/item/clothing/under/new_uniform/kitsch_dress/second
	icon_state = "kitsch_dress_2"
	item_state =  "kitsch_dress_2"
	worn_state =  "kitsch_dress_2"

/obj/item/clothing/under/new_uniform/kitsch_dress/third
	icon_state = "kitsch_dress_3"
	item_state = "kitsch_dress_3"
	worn_state = "kitsch_dress_3"

/obj/item/clothing/under/new_uniform/cherry_suit
	name = "cherry suit"
	desc = "Some cherry-colored slacks with a burgundy shirt."
	icon_state = "cherry_suit"
	item_state = "cherry_suit"
	worn_state = "cherry_suit"
	gender_icons = TRUE

/obj/item/clothing/under/new_uniform/bdu
	name = "BDU suite"
	desc = "A padded jumpsuit purposed for combat engagement."
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR
		)
	siemens_coefficient = 0.9
	icon_state = "bdu"
	item_state = "bdu"
	worn_state = "bdu"

/obj/item/clothing/under/new_uniform/ems
	name = "emergency medical responder's jumpsuit"
	desc = "This jumpsuit bears a really big red cross on its back so to let everyone know what your job is."
	icon_state = "ems_dark"
	item_state = "ems_dark"
	worn_state = "ems_dark"


/obj/item/clothing/under/new_uniform/ems/white
	icon_state = "ems_white"
	item_state = "ems_white"
	worn_state = "ems_white"

/obj/item/clothing/under/new_uniform/papaleroy_rubiwhite
	name = "Rubiwhite"
	icon_state = "papaleroy_rubywhite"
	item_state = "papaleroy_rubywhite"
	worn_state = "papaleroy_rubywhite"
	gender_icons = TRUE

/obj/item/clothing/under/new_uniform/chvk
	name = "PCRC uniform"
	icon_state = "pcrcsuit"
	item_state = "pcrcsuit"
	worn_state = "pcrcsuit"
	gender_icons = TRUE

//Куртки и прочий мусор в слоте EXOSUIT
/obj/item/clothing/suit/new_suits
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)

/obj/item/clothing/suit/new_suits/crystaljock
	name = "crystaljock bobmer"
	desc = "This neckband is really... something."
	icon_state = "crystaljock"

/obj/item/clothing/suit/new_suits/shortcoat
	icon_state = "shortcoat"
	desc = "A felt french coat. Incredibly warm and is heavy as well."

/obj/item/clothing/suit/new_suits/freefit_shirt
	name = "freefit shirt"
	desc = "This silken fabric is like a breath of fresh air."
	icon_state = "freefit_shirt_1"

/obj/item/clothing/suit/new_suits/freefit_shirt/second
	icon_state = "freefit_shirt_2"

/obj/item/clothing/suit/new_suits/freefit_shirt/third
	icon_state = "freefit_shirt_3"

/obj/item/clothing/suit/new_suits/crop_sweater
	name = "crop sweater"
	desc = "Well, this seems impractical. Are you actually cold or not?"
	icon_state = "crop_sweater_1"

/obj/item/clothing/suit/new_suits/crop_sweater/second
	icon_state = "crop_sweater_2"

/obj/item/clothing/suit/new_suits/crop_sweater/third
	icon_state = "crop_sweater_3"

/obj/item/clothing/suit/new_suits/denim_jacket
	name = "denim jacket"
	desc = "Behold - the pinnacle of colonial fashion."
	icon_state = "denim_jacket"

/obj/item/clothing/suit/new_suits/denim_jacket/gray
	icon_state = "denim_jacket_gray"

/obj/item/clothing/suit/new_suits/rugby //red
	name = "Red rugby"
	desc = "The pinnacle of the sportswear amongst school bullies."
	icon_state = "rugby_red"

/obj/item/clothing/suit/new_suits/rugby/black
	name = "Black rugby"
	icon_state = "rugby_black"

/obj/item/clothing/suit/new_suits/rugby/blue
	name = "Blue rugby"
	icon_state = "rugby_blue"

/obj/item/clothing/suit/new_suits/rugby/brown
	name = "Brown rugby"
	icon_state = "rugby_brown"

/obj/item/clothing/suit/new_suits/engjacket
	name = "Engineer jacket"
	desc = "A bright yellow jacket with NSV Sierra insignia and high-visibility reflective stripes."
	icon_state = "engjacket"

/obj/item/clothing/suit/new_suits/cargojacket
	name = "Cargo jacket"
	desc = "A brown sturdy jacket with NSV Sierra insignia on its back."
	icon_state = "cargojacket"

/obj/item/clothing/suit/new_suits/amizov
	name = "striped pullover"
	desc = "This pullover oddly reminisces you of some old video game."
	icon_state = "amizov"

/obj/item/clothing/suit/new_suits/grimjacket
	name = "Another cool jacket"
	icon_state = "grimjacket"

/obj/item/clothing/suit/storage/toggle/bomber_navy
	name = "bomber navy"
	desc = "Very warm jacket made of tanned leather with fleece inner."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	icon_state = "bomber_navy"
	body_parts_covered = UPPER_TORSO|ARMS
	cold_protection = UPPER_TORSO|ARMS
	min_cold_protection_temperature = T0C - 20
	siemens_coefficient = 0.7

/obj/item/clothing/suit/storage/hooded/hoodie/gorka
	name = "olive gorka"
	desc = "A warm gorka suit."
	item_flags = ITEM_FLAG_THICKMATERIAL
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)
	icon_state = "gorka_olive"
	hoodtype = /obj/item/clothing/head/hoodiehood/gorka

/obj/item/clothing/head/hoodiehood/gorka
	name = "gorka hood"
	desc = "A gorka hood attached to a warm gorka suit."

/obj/item/clothing/suit/storage/hooded/hoodie/gorka/tan
	name = "tan gorka"
	icon_state = "gorka_tan"
	hoodtype = /obj/item/clothing/head/hoodiehood/gorka

/obj/item/clothing/suit/storage/hooded/hoodie/gorka/blue
	name = "blue gorka"
	icon_state = "gorka_blue"
	hoodtype = /obj/item/clothing/head/hoodiehood/gorka

/obj/item/clothing/suit/color/storage/neo_blaser
	name = "neokitsch blaser"
	desc = "Style and substance. Show everyone all these money ain't for nothing."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "neokitsch_blaser"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)

/obj/item/clothing/suit/color/storage/neo_blaser/female
	icon_state = "neokitsch_blaser_f"

/obj/item/clothing/suit/color/storage/neo_jacket
	name = "neokitsch jacket"
	desc = "Style and substance. Show everyone all these money ain't for nothing."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "neokitsch_jacket"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)

/obj/item/clothing/suit/color/storage/neo_jacket/female
	icon_state = "neokitsch_jacket_f"

//Обувь
/obj/item/clothing/shoes/trekking_boots
	name = "Trekking boots"
	desc = "A pair of sleek and ergonomical military-style sneakers."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_shoes_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)
	icon_state = "trekking_boots"
	species_restricted = list("exclude", SPECIES_NABBER, SPECIES_VOX)

//Шляпки
/obj/item/clothing/head/drill_sergeant
	name = "drill sergeant's hat"
	desc = "Assert the dominance."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	icon_state = "sergeants"
	item_state = "sergeants"

//Нижнее бельё
/datum/category_item/underwear/undershirt/yukata
	name = "Yukata shirt"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "yukata"

/obj/item/clothing/suit/surgicalapron
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	icon_state = "surgical_down"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
