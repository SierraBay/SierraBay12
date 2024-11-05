/*
 * Sierra Command
 */
//*

/obj/structure/closet/secure_closet/captains/sierra
	name = "captain's cabinet"
	req_access = list(access_captain)
	closet_appearance = /singleton/closet_appearance/secure_closet/sierra/command/captain

/obj/structure/closet/secure_closet/captains/sierra/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/medium,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/accessory/storage/holster/thigh,
		/obj/item/gun/energy/stunrevolver/secure,
		/obj/item/melee/telebaton,
		/obj/item/ammo_magazine/speedloader,
		/obj/item/device/radio/headset/heads/sierra_captain,
		/obj/item/device/radio/headset/heads/sierra_captain/alt,
		/obj/item/storage/belt/general,
		/obj/item/device/flash,
		/obj/item/device/megaphone,
		/obj/item/device/remote_device/captain,
		/obj/item/clothing/head/caphat/formal,
		/obj/item/clothing/head/caphat/cap,
		/obj/item/clothing/head/beret/infinity/captain,
		/obj/item/clothing/suit/captunic,
		/obj/item/clothing/suit/captunic/capjacket,
		/obj/item/clothing/suit/storage/toggle/captain_parade,
		/obj/item/clothing/suit/storage/toggle/captain_parade/female,
		/obj/item/clothing/gloves/captain,
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/dress/dress_cap,
		/obj/item/clothing/under/captainformal,
		/obj/item/clothing/under/captain_parade,
		/obj/item/clothing/under/captain_parade/female,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/shoes/dressheels,
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/command, /obj/item/storage/backpack/messenger/com, /obj/item/storage/backpack/satchel/com))
	)
/obj/structure/closet/secure_closet/hop/sierra
	name = "head of personnel's locker"
	req_access = list(access_hop)
	closet_appearance = /singleton/closet_appearance/secure_closet/sierra/command/hop

/obj/structure/closet/secure_closet/hop2
	closet_appearance = /singleton/closet_appearance/secure_closet/sierra/command/hop

/obj/structure/closet/secure_closet/hop/sierra/WillContain()
	return list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/suit/armor/pcarrier/medium,
		/obj/item/clothing/head/helmet,
		/obj/item/device/radio/headset/heads/hop,
		/obj/item/device/radio/headset/heads/hop/alt,
		/obj/item/clothing/accessory/storage/holster/thigh,
		/obj/item/gun/energy/gun/secure,
		/obj/item/melee/telebaton,
		/obj/item/device/taperecorder,
		/obj/item/device/tape/random = 3,
		/obj/item/device/remote_device/civillian,
		/obj/item/device/flash,
		/obj/item/device/megaphone,
		/obj/item/material/clipboard,
		/obj/item/folder/envelope/nuke,
		/obj/item/storage/box/PDAs,
		/obj/item/storage/box/ids,
		/obj/item/storage/belt/holster/general,
		/obj/item/clothing/head/beret/infinity/hop
	)

/obj/structure/closet/secure_closet/adjutant
	name = "adjutant's locker"
	req_access = list(access_adjutants)
	closet_appearance = /singleton/closet_appearance/secure_closet/sierra/command/adjutant

/obj/structure/closet/secure_closet/adjutant/WillContain()
	return list(
		/obj/item/device/radio,
		/obj/item/pen,
		/obj/item/clothing/suit/armor/pcarrier/light,
		/obj/item/storage/belt/general,
		/obj/item/clothing/head/helmet,
		/obj/item/device/flash,
		/obj/item/device/megaphone,
		/obj/item/modular_computer/tablet/lease/preset/command,
		/obj/item/device/radio/headset/adjutant,
		/obj/item/device/radio/headset/adjutant/alt,
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack, /obj/item/storage/backpack/satchel/grey)),
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/dufflebag, /obj/item/storage/backpack/messenger)),
		new /datum/atom_creator/weighted(list(/obj/item/device/flashlight, /obj/item/device/flashlight/flare, /obj/item/device/flashlight/flare/glowstick/random))
	)
