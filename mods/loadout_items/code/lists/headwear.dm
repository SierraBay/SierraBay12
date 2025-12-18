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

/datum/gear/head/wig
	display_name = "wig"
	path = /obj/item/clothing/head/wig
	flags = GEAR_HAS_COLOR_SELECTION
	description = "A stylish hairstyle, in case you don't have your own hair. OOC Guide: Either enter the exact name of the hairstyle in the description (match spacing and capitalization exactly, do not include anything else), or use a comb."
	custom_setup_proc = /obj/item/clothing/head/wig/proc/loadout_setup
	whitelisted = list(SPECIES_HUMAN, SPECIES_VATGROWN, SPECIES_SPACER, SPECIES_TRITONIAN, SPECIES_GRAVWORLDER, SPECIES_MULE, SPECIES_IPC)
