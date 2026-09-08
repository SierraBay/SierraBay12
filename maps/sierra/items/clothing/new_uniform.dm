//УНИФОРМА

/obj/item/clothing/under/new_uniform/
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_w_uniform_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)


/obj/item/clothing/suit/storage/toggle/new_suit
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
	item_state = "neotac"
	worn_state = "neotac"

/obj/item/clothing/under/new_uniform/breeches
	name = "denim breeches"
	desc = "Short-cut jeans with micromesh underlayer at the crotch for extra durability."
	icon_state = "breeches"
	item_state = "breeches"
	worn_state = "breeches"

/obj/item/clothing/under/new_uniform/gorka_pants //olive
	name = "olive gorka pants"
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


/obj/item/clothing/under/new_uniform/woman_business_uniform //ниже r
	name = "woman business suit"
	desc = "Smart woman business suit."
	icon_state = "woman_office"
	item_state = "woman_office"
	worn_state = "woman_office"

/obj/item/clothing/under/new_uniform/woman_business_uniform/red
	icon_state = "woman_office_red"
	item_state = "woman_office_red"
	worn_state = "woman_office_red"

/obj/item/clothing/under/new_uniform/woman_business_uniform/azure
	icon_state = "woman_office_azur"
	item_state = "woman_office_azur"
	worn_state = "woman_office_azur"

/obj/item/clothing/under/new_uniform/woman_business_uniform/dress
	icon_state = "woman_office_dress"
	item_state = "woman_office_dress"
	worn_state = "woman_office_dress"

/obj/item/clothing/under/new_uniform/woman_business_uniform/plaid
	icon_state = "woman_office_plaid"
	item_state = "woman_office_plaid"
	worn_state = "woman_office_plaid"

/obj/item/clothing/under/new_uniform/woman_business_uniform/plaid/war2
	icon_state = "woman_office_plaid_2"
	item_state = "woman_office_plaid_2"
	worn_state = "woman_office_plaid_2"

/obj/item/clothing/under/new_uniform/woman_business_uniform/plaid/war3
	icon_state = "woman_office_plaid_3"
	item_state = "woman_office_plaid_3"
	worn_state = "woman_office_plaid_3"

/obj/item/clothing/under/new_uniform/woman_business_uniform/black
	icon_state = "woman_office_black"
	item_state = "woman_office_black"
	worn_state = "woman_office_black"

/obj/item/clothing/under/new_uniform/heartneck_dress
	name = "black dress with heart neckline"
	desc = "Black outfit with flirty neckline."
	icon_state = "heartneck_dress"
	item_state = "heartneck_dress"
	worn_state = "heartneck_dress"

/obj/item/clothing/under/new_uniform/camo_brown
	name = "dark khaki camo jumpsuit"
	desc = "Military style. Always in fashion"
	icon_state = "camo_brown"
	item_state = "camo_brown"
	worn_state = "camo_brown"

/obj/item/clothing/under/new_uniform/plaid_colored_dress
	name = "plaid skirt dress"
	desc = "Simple base dress."
	icon_state = "plaid_color_dress"
	item_state = "plaid_color_dress"
	worn_state = "plaid_color_dress"

/obj/item/clothing/under/new_uniform/plaid_colored_dress/war2
	name = "skirt dress"
	icon_state = "plaid_color_dress_2"
	item_state = "plaid_color_dress_2"
	worn_state = "plaid_color_dress_2"

/obj/item/clothing/under/new_uniform/plaid_colored_dress/war3
	name = "straight dress"
	icon_state = "plaid_color_dress_3"
	item_state = "plaid_color_dress_3"
	worn_state = "plaid_color_dress_3"

/obj/item/clothing/under/new_uniform/office_skirt
	name = "mini skirt"
	desc = "Clasic mini-skirt. Don't lean too far forward."
	icon_state = "skirt_mini"
	item_state = "skirt_mini"
	worn_state = "skirt_mini"

/obj/item/clothing/under/new_uniform/office_skirt/slit
	name = "skirt with a slit"
	desc = "Fitted, knee-length skirt. Straight-cut hem with a slit at front."
	icon_state = "skirt_slit"
	item_state = "skirt_slit"
	worn_state = "skirt_slit"

/obj/item/clothing/under/new_uniform/office_skirt/wavy
	name = "comfortable skirt"
	desc = "Mini circle skirt."
	icon_state = "skirt_wavy"
	item_state = "skirt_wavy"
	worn_state = "skirt_wavy"

/obj/item/clothing/under/new_uniform/camopants
	name = "multicam pants"
	desc = "Loose-fit pants in woven fabric. Comfortable and strong."
	icon_state = "multicam_pants"
	item_state = "multicam_pants"
	worn_state = "multicam_pants"

/obj/item/clothing/under/new_uniform/camopants/baggy
	name = "multicam pants"
	icon_state = "multicam_pants_baggy"
	item_state = "multicam_pants_baggy"
	worn_state = "multicam_pants_baggy"

/obj/item/clothing/under/new_uniform/camopants/grey
	name = "multicam pants"
	icon_state = "multicam_pants_grey"
	item_state = "multicam_pants_grey"
	worn_state = "multicam_pants_grey"

/obj/item/clothing/under/new_uniform/camopants/greybaggy
	name = "multicam pants"
	icon_state = "multicam_pants_grey_baggy"
	item_state = "multicam_pants_grey_baggy"
	worn_state = "multicam_pants_grey_baggy"

/obj/item/clothing/under/new_uniform/shortsmini
	name = "mini shorts"
	desc = "Fitted mini hot shorts. No ERP."
	icon_state = "shortsmini"
	item_state = "shortsmini"
	worn_state = "shortsmini"

/obj/item/clothing/under/new_uniform/shortsmini/denim
	name = "mini denim shorts"
	icon_state = "shortsmini_denim"
	item_state = "shortsmini_denim"
	worn_state = "shortsmini_denim"

/obj/item/clothing/under/new_uniform/shortsmini/camo
	name = "mini camo shorts"
	icon_state = "shortsmini_camo"
	item_state = "shortsmini_camo"
	worn_state = "shortsmini_camo"

/obj/item/clothing/under/new_uniform/scutracksuit
	name = "scuba track suit"
	desc = "Tracksuit with a jacket and joggers in soft scuba fabric."
	icon_state = "tracksuit"
	item_state = "tracksuit"
	worn_state = "tracksuit"

/obj/item/clothing/under/new_uniform/scutracksuit/red
	name = "scuba track suit"
	icon_state = "tracksuit_red"
	item_state = "tracksuit_red"
	worn_state = "tracksuit_red"

/obj/item/clothing/under/new_uniform/scutracksuit/black
	name = "scuba track suit"
	icon_state = "tracksuit_black"
	item_state = "tracksuit_black"
	worn_state = "tracksuit_black"

/obj/item/clothing/under/new_uniform/runningpants
	name = "running pants"
	icon_state = "runningpants"
	item_state = "runningpants"
	worn_state = "runningpants"

/obj/item/clothing/under/new_uniform/runningpants/red
	name = "running pants red"
	icon_state = "runningpants_red"
	item_state = "runningpants_red"
	worn_state = "runningpants_red"

/obj/item/clothing/under/new_uniform/runningpants/black
	name = "running pants black"
	icon_state = "runningpants_black"
	item_state = "runningpants_black"
	worn_state = "runningpants_black"


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

/obj/item/clothing/suit/surgicalapron
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	icon_state = "surgical_down"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

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


/obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber //отсюда искать remission
	name = "engineer jacket"
	desc = "This jacket protection without compromising mobility, making it ideal for engineers."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "eng_bomber"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber/atmos
	name = "atmos jacket"
	icon_state = "eng_bomber_atm"

/obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber/work
	name = "With grey jacket"
	icon_state = "eng_bomber_work"

/obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber/white
	name = "White jacket"
	icon_state = "eng_bomber_white"


/obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket
	name = "leather fur jacket"
	desc = "Aviator suit in leather fabric with notch lapels in fur."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "leather_fur_jacket"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket/grey
	name = "grey leather fur jacket"
	icon_state = "leather_fur_jacket_grey"

/obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket/coat
	name = "grey leather fur jacket"
	icon_state = "leather_fur_coat"

/obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket/greycoat
	name = "grey leather fur jacket"
	icon_state = "leather_fur_coat_grey"

/obj/item/clothing/suit/storage/toggle/new_suit/work_bomber
	name = "work orange jacket"
	desc = "High-visibility padded jacket."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "work_bomber"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/work_bomber/yellow
	name = "work yellow jacket"
	icon_state = "work_bomber_yel"


/obj/item/clothing/suit/storage/toggle/new_suit/sport_jacket
	name = "sport white-blue jacket"
	desc = "Two-color track jacket."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "sport_jacket_bluewhite"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/sport_jacket/blackwhite
	name = "sport white-black jacket"
	icon_state = "sport_jacket_blackwhite"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket
	name = "leather biker jacket"
	desc = "Regular-fit biker jacket in soft leather with a distressed look."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "leather_biker_jacket"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/dis
	name = "leather distressed biker jacket"
	icon_state = "leather_biker_jacket_dis"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/skull
	name = "skull leather jacket"
	icon_state = "leather_biker_jacket_skull"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/heart
	name = "heart leather jacket"
	icon_state = "leather_biker_jacket_heart"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/dragon
	name = "dragon head leather jacket"
	icon_state = "leather_biker_jacket_dragon"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/devil
	name = "devil head leather jacket"
	icon_state = "leather_biker_jacket_devil"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/fire
	name = "fire flame leather biker jacket"
	icon_state = "leather_biker_jacket_fire"

/obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/posh
	name = "pretentious leather jacket"
	icon_state = "leather_biker_jacket_diamond"

/obj/item/clothing/suit/storage/levis_bomber
	name = "denim bomber jacket"
	desc = "Classic denim jacket."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "levis_bomber"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket
	name = "multicam jacket"
	desc = "Why not?."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "multicam_jacket"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket/sand
	name = "multicam sand jacket"
	icon_state = "multicam_jacket_sand"

/obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket/grey
	name = "multicam sand jacket"
	icon_state = "multicam_jacket_grey"

/obj/item/clothing/suit/storage/toggle/new_suit/tracksuits
	name = "comfortable tracksuit"
	desc = "The latest statement sport fashion."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "tracks"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/tracksuits/blue
	name = "comfortable blue tracksuit"
	icon_state = "tracks_blue"

/obj/item/clothing/suit/storage/toggle/new_suit/tracksuits/red
	name = "comfortable red tracksuit"
	icon_state = "tracks_red"

/obj/item/clothing/suit/storage/toggle/new_suit/tracksuits/green
	name = "comfortable green tracksuit"
	icon_state = "tracks_green"

/obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie
	name = "loose-fit hoodie jacket"
	desc = "Loose-fit hooded sweatshirt jacket."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "sporthoodie"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/red
	name = "loose-fit red hoodie jacket"
	icon_state = "sporthoodie_r"

/obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/blue
	name = "loose-fit blue hoodie jacket"
	icon_state = "sporthoodie_blue"

/obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/rw
	name = "loose-fit two-tone hoodie jacket"
	icon_state = "sporthoodie_rw"

/obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/black
	name = "loose-fit black hoodie"
	icon_state = "sporthoodie_black"

/obj/item/clothing/suit/storage/toggle/new_suit/colorhoodie
	name = "hooded jacket"
	desc = "Loose fit drawstring hood jacket."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "colorhoodie"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')

/obj/item/clothing/suit/storage/toggle/new_suit/trench
	name = "beige trench coat"
	desc = "Calf-length, oversized belted trench coat. Don't forget to wear something under coat. "
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	icon_state = "beigetrench"
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')



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

/obj/item/clothing/shoes/martens_shoes
	name = "martens shoes."
	desc = "A pair of branded rubber-soled shoes."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_shoes_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)
	icon_state = "martens"
	species_restricted = list("exclude", SPECIES_NABBER, SPECIES_VOX)

/obj/item/clothing/shoes/martens_shoes/low
	name = "martens low shoes."
	icon_state = "martens_short"

/obj/item/clothing/shoes/lowsneackers
	name = "Comfort sneakers."
	desc = "Low profile sneakers with a lightly padded upper edge and tongue."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_shoes_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_TAJARA = 'maps/sierra/icons/obj/clothing/new_loadout_tajara.dmi',
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi'
		)
	icon_state = "lowsneackers"
	species_restricted = list("exclude", SPECIES_NABBER, SPECIES_VOX)



//Шляпки
/obj/item/clothing/head/drill_sergeant
	name = "drill sergeant's hat"
	desc = "Assert the dominance."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	icon_state = "sergeants"
	item_state = "sergeants"

/obj/item/clothing/head/engberet
	name = "engineers beret"
	desc = "Attribute of a problem solver."
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	icon_state = "engberet"
	item_state = "engberet"

/obj/item/clothing/head/engberet/bluecocard
	name = "engineers beret"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	icon_state = "engberet_b"
	item_state = "engberet_b"

/obj/item/clothing/head/engberet/atmos
	name = "engineers beret"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	icon_state = "engberet_atmos"
	item_state = "engberet_atmos"

/obj/item/clothing/head/headband
	name = "headband"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout_icons.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/obj/clothing/new_loadout.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/sierra/icons/obj/clothing/new_loadout_unati.dmi',
		)
	icon_state = "headband"
	item_state = "headband"

//Нижнее бельё
/datum/category_item/underwear/undershirt/yukata
	name = "Yukata shirt"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	icon_state = "yukata"
	has_color = TRUE

/datum/category_item/underwear/undershirt/badlon
	name = "Slim turtleneck shirt"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	icon_state = "u_turtleneck"
	has_color = TRUE


/datum/category_item/underwear/undershirt/badlonfemme
	name = "Slim turtleneck shirt female"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	icon_state = "u_turtleneck_f"
	has_color = TRUE

/datum/category_item/underwear/undershirt/womanvneck
	name = "Woman V-neck"
	icon = 'maps/sierra/icons/obj/clothing/new_loadout.dmi'
	icon_state = "womanvneck"
	has_color = TRUE
