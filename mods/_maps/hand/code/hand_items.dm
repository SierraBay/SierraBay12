// HAND TODO BELOW

/* CARDS
 * ========
 */

/obj/item/card/id/awaycavalry/ops
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	color = "#b10309c2"
	detail_color = "#000000"
	access = list(access_away_cavalry, access_away_cavalry_ops)

/obj/item/card/id/awaycavalry/ops/captain
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	access = list(access_away_cavalry, access_away_cavalry_ops, access_away_cavalry_fleet_armory, access_away_cavalry_captain)
	extra_details = list("goldstripe")

/obj/item/card/id/awaycavalry/fleet
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	color = COLOR_GRAY40
	detail_color = "#447ab1"
	access = list(access_away_cavalry)

/obj/item/card/id/awaycavalry/fleet/pilot
	access = list(access_away_cavalry, access_away_cavalry_pilot, access_away_cavalry_fleet_armory)

/obj/item/card/id/awaycavalry/fleet/commander
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	access = list(access_away_cavalry, access_away_cavalry_ops, access_away_cavalry_pilot, access_away_cavalry_fleet_armory, access_away_cavalry_commander) //TODO: беды с доступами
	extra_details = list("goldstripe")

/* RADIOHEADS
 * ========
 */

/obj/item/device/radio/headset/rescue
	name = "rescue team radio headset"
	desc = "The headset of the rescue team member."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/rescue

/obj/item/device/radio/headset/rescue/leader
	name = "rescue team leader radio headset"
	desc = "The headset of the rescue team member."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/rescue/leader

/obj/item/device/encryptionkey/rescue //for events
	name = "\improper rescue radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list("Response Team" = 1)

/obj/item/device/encryptionkey/rescue/leader
	name = "\improper rescue leader radio encryption key"
	channels = list("Response Team" = 1, "Command" = 1, )

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
