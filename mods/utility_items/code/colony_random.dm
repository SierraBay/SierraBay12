/obj/random/colony_flag
	name = "Colony flag"

/obj/random/colony_armor
	name = "random colony armor"

/obj/random/colony_helmet
	name  = "random colony helmet"

/obj/random/colony_smg
	name = "random colony smg"

/obj/random/colony_rifle
	name = "random colony rifle"

/obj/structure/sign/colony
	name = "Independent colony"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "colony"

/obj/random/colony_paper
	name = "Colony instructions paper"

/obj/random/colony2_paper
	name = "Colony instructions paper"


/obj/structure/sign/iccg_colony
	name = "\improper ICCG Colonial Seal"
	desc = "A sign which signifies who this colony belongs to."
	icon = 'mods/_maps/farfleet/icons/iccg_flag.dmi'
	icon_state = "iccg_seal"

/obj/item/clothing/head/helmet/solgov_colony
	accessories = list(/obj/item/clothing/accessory/helmet_cover/blue)
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_head_solgov_unathi.dmi'
		)

/obj/item/clothing/head/helmet/solgov_colony/security
	name = "security helmet"
	desc = "A helmet with 'POLICE' printed on the back in silver lettering."
	icon_state = "helmet_security"
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	accessories = null

/obj/item/clothing/head/helmet/solgov_colony/command
	name = "command helmet"
	desc = "A helmet with 'SOL CENTRAL GOVERNMENT' printed on the back in gold lettering."
	icon_state = "helmet_command"
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	accessories = null

/obj/item/clothing/head/helmet/solgov_colony/pilot
	name = "pilot's helmet"
	desc = "A pilot's helmet for operating the cockpit in style. For when you want to protect your noggin AND look stylish."
	icon_state = "pilotgov"
	accessories = null

/obj/item/clothing/head/helmet/solgov_colony/pilot/fleet
	name = "fleet pilot's helmet"
	desc = "A pilot's helmet for operating the cockpit in style. This one is worn by members of the SCG Fleet."
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	icon_state = "pilotfleet"
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	accessories = null

/obj/item/clothing/suit/armor/vest/solgov_colony
	name = "\improper Sol Central Government armored vest"
	desc = "A synthetic armor vest. This one is marked with the crest of the Sol Central Government."
	icon_state = "solvest"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_solgov_unathi.dmi'
	)

/obj/item/clothing/suit/storage/vest/solgov_colony
	name = "\improper Sol Central Government heavy armored vest"
	desc = "A synthetic armor vest with PEACEKEEPER printed in distinctive blue lettering on the chest. This one has added webbing and ballistic plates."
	icon_state = "solwebvest"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_solgov_unathi.dmi'
	)

/obj/item/clothing/suit/storage/vest/solgov_colony/security
	name = "master at arms heavy armored vest"
	desc = "A synthetic armor vest with MASTER AT ARMS printed in silver lettering on the chest. This one has added webbing and ballistic plates."
	icon_state = "secwebvest"

/obj/item/clothing/suit/storage/vest/solgov_colony/command
	name = "command heavy armored vest"
	desc = "A synthetic armor vest with SOL CENTRAL GOVERNMENT printed in gold lettering on the chest. This one has added webbing and ballistic plates."
	icon_state = "comwebvest"

/obj/item/clothing/suit/armor/pcarrier/medium/sol_colony
	accessories = list(/obj/item/clothing/accessory/armor_plate/medium, /obj/item/clothing/accessory/storage/pouches)

/obj/item/clothing/suit/armor/pcarrier/troops_colony
	accessories  = list(/obj/item/clothing/accessory/armor_plate/medium, /obj/item/clothing/accessory/storage/pouches)

/obj/item/clothing/suit/armor/pcarrier/troops_colony/heavy
	accessories  = list(/obj/item/clothing/accessory/armor_plate/medium, /obj/item/clothing/accessory/arm_guards, /obj/item/clothing/accessory/leg_guards, /obj/item/clothing/accessory/storage/pouches)

/obj/item/clothing/suit/armor/pcarrier/tactical_colony
	accessories  = list(/obj/item/clothing/accessory/armor_plate/tactical, /obj/item/clothing/accessory/arm_guards, /obj/item/clothing/accessory/leg_guards)
