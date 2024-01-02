/obj/item/clothing/under/scp_uniform
	name = "SCP guard uniform"
	desc = "It's dark grey uniform made of a slightly sturdier material than standard jumpsuits, to allow for good protection.\nThis uniform has SCP tags on shoulders, terran organization of NT asset protection."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "scp_uniform"
	item_state = "scp_uniform"
	worn_state = "scp_uniform"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/zpci_uniform
	name = "ZPCI uniform"
	desc = "This is a standard model of the ZPCI uniform."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "zpci_uniform"
	item_state = "zpci_uniform"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) //it's security uniform's stats
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security/saarecombat
	name = "\improper SAARE combat uniform"
	desc = "Tight-fitting dark uniform with a bright-green SAARE patch on the shoulder. The perfect outfit in which to kick doors out and teeth in."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "saarecombat"
	item_state = "saarecombat"
	worn_state = "saarecombat"
	gender_icons = 1

// SIERRA TO DO: Cleanup icons from unused loadout

/obj/item/clothing/under/gray_camo
	name = "camo uniform"
	desc = "It's camo unifrom made of a slightly sturdier material than standard jumpsuits, to allow for good protection and military style."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "gray_camo"
	item_state = "gray_camo"
	worn_state = "gray_camo"

/obj/item/clothing/under/retro/security
	desc = "A retro corporate security jumpsuit. Although it provides same protection as modern jumpsuits do, wearing this almost feels like being wrapped in tarp."
	name = "retro security officer's uniform"
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "retro_sec"
	item_state = "retro_sec"
	siemens_coefficient = 0.9
	armor = list(
		melee = ARMOR_MELEE_SMALL
		)

/obj/item/clothing/under/retro/medical
	desc = "A biologically resistant retro medical uniform with high-vis reflective stripes."
	name = "retro medical officer's uniform"
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "retro_med"
	item_state = "retro_med"
	permeability_coefficient = 0.50
	armor = list(
		bio = ARMOR_BIO_MINOR
		)

/obj/item/clothing/under/retro/engineering
	desc = "A faded grimy engineering jumpsuit and overall combo. It craves for being soiled with oil, dust, and grit this damn instant."
	name = "retro engineering uniform"
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "retro_eng"
	item_state = "retro_eng"
	armor = list(
		rad = ARMOR_RAD_MINOR
		)

/obj/item/clothing/under/retro/science
	desc = "A faded polo and set of brown slacks with distinctive pink stripes. What a ridiculous tie."
	name = "retro science officer's uniform"
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "retro_sci"
	item_state = "retro_sci"
	armor = list(
		bio = ARMOR_BIO_MINOR
		)

/obj/item/clothing/under/blueshift_uniform
	desc = "Blue shirt with robust jeans from robust materials. Still standard issue equipment for long clam blue shifts."
	name = "research division security uniform"
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	icon_state = "blueshift"
	item_state = "blueshift"

/obj/item/clothing/under/scg_expeditonary
	name = "Expeditionary Corps uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has silver trim."
	icon = 'maps/torch/icons/obj/obj_under_solgov.dmi'
	item_icons = list(slot_w_uniform_str = 'maps/torch/icons/mob/onmob_under_solgov.dmi')
	icon_state = "blackutility_crew"
	item_state = "bl_suit"
	worn_state = "blackutility_crew"
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_under_solgov_unathi.dmi'
		)
	siemens_coefficient = 0.8
	gender_icons = 1

/obj/item/clothing/under/scg_expeditonary/officer
	name = "Expeditionary Corps officer's uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has gold trim."
	icon_state = "blackutility_com"
	worn_state = "blackutility_com"
	
// Unathi garnments

/obj/item/clothing/under/medic/paramedic
	name = "first responder uniform"
	desc = "Light and bulky paramedic jumpsuit with bright markings. It's too big to fit anyone, but unathi."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/onmob_under.dmi'
	)
	species_restricted  = list(SPECIES_UNATHI)
	icon_state = "unathi_paramedic"
	item_state = "unathi_paramedic"
	worn_state = "unathi_paramedic"
	//rolled_sleeves = 0

/obj/item/clothing/under/security/desert
	name = "desert jumpsuit"
	desc = "A bulky and light jumpsuit designed for use in the desert. Unathi use it to withstand scorhing heat rays when \"Burning Mother\" at it's zenith, something that their scales cannot handle. It's too big to fit anyone, but unathi."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/onmob_under.dmi'
	)
	species_restricted  = list(SPECIES_UNATHI)
	icon_state = "desertuniform"
	item_state = "desertuniform"
	worn_state = "desertuniform"
	rolled_sleeves = 0  //0 = unrolled, 1 = rolled, -1 = cannot be toggled

/obj/item/clothing/under/security/officer
	name = "large security uniform"
	desc = "An aftermarket modification of a regular desert jumpsuit, favored by unathi mercenaries. This one provides a bit more physical protection as if unathi ever needed that. It's too big to fit anyone, but unathi."
	icon = 'mods/loadout_items/icons/obj_under.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_under.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/onmob_under.dmi'
	)
	species_restricted  = list(SPECIES_UNATHI)
	icon_state = "unsecuniform"
	item_state = "unsecuniform"
	worn_state = "unsecuniform"
	rolled_sleeves = 0  //0 = unrolled, 1 = rolled, -1 = cannot be toggled
