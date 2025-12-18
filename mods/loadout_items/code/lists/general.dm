/datum/gear/utility/wheelchair
	display_name = "compressed wheelchair kit"
	path = /obj/item/wheelchair_kit
	cost = 2

/datum/gear/utility/general_belt
	display_name = "equipment belt"
	path = /obj/item/storage/belt/general

/datum/gear/rolled_towel
	display_name = "big towel"
	description = "Collapsed big towel - looks like you can't use it as a normal one... Use it on the beach or gym."
	path = /obj/item/rolled_towel
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/cards_compact
	display_name = "deck of cards (compact)"
	path = /obj/item/deck/compact

/datum/gear/zippo_decorated
	display_name = "zippo (decorated)"
	path = /obj/item/flame/lighter/zippo/fancy
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/cigarettes
	display_name = "pack of cigarettes selection"
	path = /obj/item/storage/fancy/smokable

/datum/gear/cigarettes/New()
	var/cigarettes = list()
	cigarettes["Trans-Stellar"] = /obj/item/storage/fancy/smokable/transstellar
	cigarettes["Dromedary Co."] = /obj/item/storage/fancy/smokable/dromedaryco
	cigarettes["Acme Co."] = /obj/item/storage/fancy/smokable/killthroat
	cigarettes["Lucky Stars"] = /obj/item/storage/fancy/smokable/luckystars
	cigarettes["Jerichos"] = /obj/item/storage/fancy/smokable/jerichos
	cigarettes["Temperamento Menthols"] = /obj/item/storage/fancy/smokable/menthols
	cigarettes["Carcinoma Angels"] = /obj/item/storage/fancy/smokable/carcinomas
	cigarettes["Professional 120s"] = /obj/item/storage/fancy/smokable/professionals
	cigarettes["Trident Original"] = /obj/item/storage/fancy/smokable/trident
	cigarettes["Trident Fruit"] = /obj/item/storage/fancy/smokable/trident_fruit
	cigarettes["Trident Menthol"] = /obj/item/storage/fancy/smokable/trident_mint
	gear_tweaks += new/datum/gear_tweak/path(cigarettes)

/datum/gear/asamblee_card
	display_name = "assamblee membership card"
	path = /obj/item/card/assamblee_card
	allowed_factions = list(FACTION_ASSAMBLEE)
	custom_setup_proc = /obj/item/card/assamblee_card/proc/set_info
	slot = slot_in_backpack
