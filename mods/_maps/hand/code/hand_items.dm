// HAND TODO BELOW

/* CARDS
 * ========
 */

/obj/item/card/id/hand
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	detail_color = COLOR_BROWN
	access = list(access_away_cavalry, access_away_cavalry_ops)

/obj/item/card/id/hand/captain
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	color = COLOR_GRAY40
	detail_color = "#447ab1"
	access = list(access_away_cavalry, access_away_cavalry_ops, access_away_cavalry_fleet_armory, access_away_cavalry_captain)

/obj/item/card/id/hand/medic
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	color = COLOR_GRAY40
	detail_color = "#447ab1"
	access = list(access_away_cavalry)

/* CLOTHING
 * ========
 */

/obj/item/clothing/under/alliance/vacsuit/hand/guardsman
	accessories = list(/obj/item/clothing/accessory/medal/fa/guardsman)

/obj/item/clothing/under/solgov/utility/fleet/command/pilot
	accessories = list(
		/obj/item/clothing/accessory/solgov/specialty/pilot,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/medical/hand
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/medical/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)
