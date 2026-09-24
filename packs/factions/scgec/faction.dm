/datum/mil_branch/scgec
	name = "Expeditionary Corps"
	name_short = "SCGEC"
	email_domain = "ec.scg"

	rank_types = list(
		/datum/mil_rank/scgec/e3,
		/datum/mil_rank/scgec/e5,
		/datum/mil_rank/scgec/e7,
		/datum/mil_rank/scgec/o1,
		/datum/mil_rank/scgec/o3,
		/datum/mil_rank/scgec/o5,
		/datum/mil_rank/scgec/o6,
		/datum/mil_rank/scgec/o8,
		/datum/mil_rank/scgec/o10
	)

	spawn_rank_types = list(
		/datum/mil_rank/scgec/e3,
		/datum/mil_rank/scgec/e5,
		/datum/mil_rank/scgec/e7,
		/datum/mil_rank/scgec/o1
	)

/datum/mil_rank/scgec/e3
	name = "Explorer"
	name_short = "XPL"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/e3)
	sort_order = 30

/datum/mil_rank/scgec/e5
	name = "Senior Explorer"
	name_short = "SXPL"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/e5)
	sort_order = 50

/datum/mil_rank/scgec/e7
	name = "Chief Explorer"
	name_short = "CXPL"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/e7)
	sort_order = 70

/datum/mil_rank/scgec/o1
	name = "Ensign"
	name_short = "ENS"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/o1)
	sort_order = 110

/datum/mil_rank/scgec/o3
	name = "Lieutenant"
	name_short = "LT"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/o3)
	sort_order = 130

/datum/mil_rank/scgec/o5
	name = "Commander"
	name_short = "CDR"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/o5)
	sort_order = 150

/datum/mil_rank/scgec/o6
	name = "Captain"
	name_short = "CAPT"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/o6)
	sort_order = 160

/datum/mil_rank/scgec/o8
	name = "Admiral"
	name_short = "ADM"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/o8)
	sort_order = 180

/datum/mil_rank/scgec/o10
	name = "Commandant of the Expeditionary Corps"
	name_short = "CMDT"
	accessory = list(/obj/item/clothing/accessory/scgec/rank/o10)
	sort_order = 200

/obj/item/clothing/accessory/scgec
	name = "master SCGEC accessory"
	desc = "You shouldn't be seeing this."
	icon = 'maps/torch/icons/obj/obj_accessories_solgov.dmi'
	accessory_icons = list(slot_w_uniform_str = 'maps/torch/icons/mob/onmob_accessories_solgov.dmi', slot_wear_suit_str = 'maps/torch/icons/mob/onmob_accessories_solgov.dmi')
	w_class = ITEM_SIZE_TINY
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_accessories_solgov_unathi.dmi'
		)

/obj/item/clothing/accessory/scgec/rank
	name = "SCGEC rank insignia"

/obj/item/clothing/accessory/scgec/rank/e3
	name = "ranks (E-3 explorer)"
	desc = "Insignia denoting the rank of Explorer."
	icon_state = "ecrank_e3"

/obj/item/clothing/accessory/scgec/rank/e5
	name = "ranks (E-5 senior explorer)"
	desc = "Insignia denoting the rank of Senior Explorer."
	icon_state = "ecrank_e5"

/obj/item/clothing/accessory/scgec/rank/e7
	name = "ranks (E-7 chief explorer)"
	desc = "Insignia denoting the rank of Chief Explorer."
	icon_state = "ecrank_e7"

/obj/item/clothing/accessory/scgec/rank/o1
	name = "ranks (O-1 ensign)"
	desc = "Insignia denoting the rank of Ensign."
	icon_state = "ecrank_o1"

/obj/item/clothing/accessory/scgec/rank/o3
	name = "ranks (O-3 lieutenant)"
	desc = "Insignia denoting the rank of Lieutenant."
	icon_state = "ecrank_o3"

/obj/item/clothing/accessory/scgec/rank/o5
	name = "ranks (O-5 commander)"
	desc = "Insignia denoting the rank of Commander."
	icon_state = "ecrank_o5"

/obj/item/clothing/accessory/scgec/rank/o6
	name = "ranks (O-6 captain)"
	desc = "Insignia denoting the rank of Captain."
	icon_state = "ecrank_o6"

/obj/item/clothing/accessory/scgec/rank/o8
	name = "ranks (O-8 admiral)"
	desc = "Insignia denoting the rank of Admiral."
	icon_state = "ecrank_o8"

/obj/item/clothing/accessory/scgec/rank/o10
	name = "ranks (O-10 commandant of the expeditionary corps)"
	desc = "Insignia denoting the rank of Commandant of the Expeditionary Corps."
	icon_state = "ecrank_o10"
