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
