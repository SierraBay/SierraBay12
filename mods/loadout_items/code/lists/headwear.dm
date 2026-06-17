/datum/gear/head/ballcap
	display_name = "ballcap, colour select"
	path = /obj/item/clothing/head/soft/colorable
	flags = GEAR_HAS_COLOR_SELECTION
	slot = slot_head
	cost = 1

/datum/gear/head/kms_beret
	display_name = "KMS beret"
	description = "A white beret denoting KMS employee."
	path = /obj/item/clothing/head/beret/kms
	slot = slot_head
	cost = 1
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_KMS)

/datum/gear/head/asambleemask
	display_name = "masquerade mask selection"
	path = /obj/item/clothing/mask/fakemoustache/asamblee
	allowed_factions = list(FACTION_ASSAMBLEE)
	slot = slot_wear_mask
	cost = 2

/datum/gear/head/asambleemask/New()
	..()
	var/asamasks = list()
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/steel
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/shy
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/blush
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/black
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/target
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/smiley
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/happy
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/neutral
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/angry
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/sad
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/half
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/stoneo
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/stone
	asamasks += /obj/item/clothing/mask/fakemoustache/asamblee/stonetarget
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(asamasks)

/datum/gear/head/stetson
	display_name = "stetson hat selection"
	path = /obj/item/clothing/head/bighat

/datum/gear/head/stetson/New()
	..()
	var/stetson = list()
	stetson += /obj/item/clothing/head/bighat
	stetson += /obj/item/clothing/head/bighat/lawdog
	stetson += /obj/item/clothing/head/bighat/gunfighter
	stetson += /obj/item/clothing/head/bighat/kgbhat
	stetson += /obj/item/clothing/head/bighat/black
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(stetson)

/datum/gear/head/baseball
	display_name = "baseball cap, colour select"
	path = /obj/item/clothing/head/soft/baseball/colorable
	flags = GEAR_HAS_COLOR_SELECTION
	slot = slot_head
	cost = 1

/datum/gear/head/barc_cap
	display_name = "P317 cap"
	description = "It’s a baseball cap in colors of Periphery 317 - Enclave under the BARC PMC."
	path = /obj/item/clothing/head/soft/baseball/barc
	slot = slot_head
	cost = 1
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_BARC)

/datum/gear/head/barc_beret
	display_name = "P317 beret"
	description = "It’s a beret with crudely sewn over old ones Periphery 317 colors. The owner is employed by BARC PMC."
	path = /obj/item/clothing/head/beret/barc
	slot = slot_head
	cost = 1
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_BARC)
