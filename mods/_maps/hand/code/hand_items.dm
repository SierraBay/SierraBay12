/* CARDS
 * ========
 */

/obj/item/card/id/hand
	desc = "An identification card issued to corporate laborers across countless frontier facilities and vessels."
	detail_color = COLOR_BROWN
	access = list(access_away_hand)

/obj/item/card/id/hand/captain
	desc = "An identification card issued to corporate pilot crew."
	icon_state = "base"
	color = COLOR_GRAY40
	extra_details = list("goldstripe")
	detail_color = COLOR_COMMAND_BLUE
	access = list(access_away_hand, access_away_hand_captain)

/obj/item/card/id/hand/captain/ftu
	desc = "An identification card issued to Free Trade Union personnel."
	color = COLOR_OFF_WHITE
	detail_color = COLOR_BEIGE

/obj/item/card/id/hand/captain/fifth_fleet
	desc = "An identification card issued to SCGN Flight Crew. This one was issued to personnel of Fifth Fleet's Battlegroup 'Alpha'."
	icon_state = "base"
	extra_details = null
	color = COLOR_GRAY40
	detail_color = "#447ab1"
	access = list(access_away_hand, access_away_hand_captain)

/obj/item/card/id/hand/medic
	desc = "An identification card issued to corporate medical personnel across countless frontier facilities and vessels."
	icon_state = "base"
	detail_color = COLOR_PALE_BLUE_GRAY
	access = list(access_away_hand, access_away_hand_med, access_away_hand_captain)

/obj/item/card/id/hand/medic/fifth_fleet
	desc = "An identification card issued to corporate medical personnel across countless frontier facilities and vessels."
	icon_state = "base"
	detail_color = COLOR_PALE_BLUE_GRAY
	access = list(access_away_hand, access_away_hand_med, access_away_hand_captain)

/* CLOTHING
 * ========
 */

/obj/item/clothing/under/fa/vacsuit/hand/guardsman
	accessories = list(/obj/item/clothing/accessory/fa_badge/guardsman)

/obj/item/clothing/under/solgov/utility/fleet/command/pilot/fifth_fleet
	accessories = list(
		/obj/item/clothing/accessory/solgov/specialty/pilot,
		/obj/item/clothing/accessory/solgov/rank/fleet/officer/o3,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/medical/hand
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/medical/fleet,
		/obj/item/clothing/accessory/solgov/rank/fleet/officer,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/suit/bio_suit/anomaly/lethal
	name = "cheap anomaly suit"
	desc = "A cheap suit that should protect against exotic alien energies and biological contamination."
	icon = 'mods/_maps/hand/icons/obj/obj_hand.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/_maps/hand/icons/mob/onmob_hand.dmi')
	icon_state = "lethal_suit"

/obj/item/clothing/head/bio_hood/anomaly/lethal
	name = "cheap anomaly mask"
	desc = "A hood that should protect the head and face from exotic alien energies and biological contamination."
	icon = 'mods/_maps/hand/icons/obj/obj_hand.dmi'
	item_icons = list(slot_head_str = 'mods/_maps/hand/icons/mob/onmob_hand.dmi')
	icon_state = "lethal_helm"
