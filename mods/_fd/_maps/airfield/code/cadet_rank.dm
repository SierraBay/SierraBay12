/datum/mil_rank/fleet/o0
	name = "Cadet"
	name_short = "CAD"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/cadet)
	sort_order = 11

/obj/item/clothing/accessory/solgov/rank/fleet/cadet
	name = "ranks (O-0 cadet)"
	desc = "Shoulderboards denoting the rank of Cadet of Officer Academy."

/datum/mil_branch/fleet/New()
	rank_types += /datum/mil_rank/fleet/o0
	spawn_rank_types += /datum/mil_rank/fleet/o0
	. = ..()
