/obj/structure/closet/secure_closet/explorer/medic
	name = "expedition medic's locker"
	req_access = list(access_explorer)
	closet_appearance = /singleton/closet_appearance/secure_closet/torch/exploration/medic

/obj/structure/closet/secure_closet/explorer/medic/WillContain()
	return list(
		/obj/item/storage/belt/medical/emt,
		/obj/item/storage/box/nitrilegloves,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/storage/box/masks,
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/stab,
		/obj/item/bodybag/rescue/loaded,
		/obj/item/bodybag/rescue/loaded,
		/obj/item/device/scanner/health,
		/obj/item/roller_bed,
		/obj/item/clothing/accessory/storage/holster/machete,
		/obj/item/device/radio,
		/obj/item/device/gps,
		/obj/item/taperoll/research,
		/obj/item/shuttle_beacon,
		/obj/item/clothing/accessory/storage/webbing_large,
		/obj/item/device/scanner/gas,
		/obj/item/device/radio/headset/exploration,
		/obj/item/device/radio/headset/exploration/alt,
		/obj/item/device/binoculars,
		/obj/item/clothing/accessory/buddy_tag,
		/obj/item/storage/firstaid/individual/military,
		/obj/item/material/knife/folding/swiss/explorer,
		/obj/item/device/camera,
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/explorer, /obj/item/storage/backpack/satchel/explorer)),
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/dufflebag, /obj/item/storage/backpack/messenger/explorer)),
		new /datum/atom_creator/weighted(list(/obj/item/device/flashlight, /obj/item/device/flashlight/flare, /obj/item/device/flashlight/flare/glowstick/random))
	)
/obj/structure/closet/secure_closet/explorer/engineer
	name = "expedition engineer's locker"
	req_access = list(access_explorer)
	closet_appearance = /singleton/closet_appearance/secure_closet/torch/exploration/engineer

/singleton/closet_appearance/secure_closet/torch/exploration/medic
	extra_decals = list(
		"stripe_vertical_mid_full" = COLOR_WHITE,
		"exped" = COLOR_PURPLE
	)

/obj/structure/closet/secure_closet/explorer/engineer/WillContain()
	return list(
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/gloves/insulated,
		/obj/item/device/multitool,
		/obj/item/clothing/accessory/storage/holster/machete,
		/obj/item/device/radio,
		/obj/item/device/gps,
		/obj/item/taperoll/research,
		/obj/item/shuttle_beacon,
		/obj/item/clothing/accessory/storage/webbing_large,
		/obj/item/device/scanner/gas,
		/obj/item/device/radio/headset/exploration,
		/obj/item/device/radio/headset/exploration/alt,
		/obj/item/device/binoculars,
		/obj/item/clothing/accessory/buddy_tag,
		/obj/item/storage/firstaid/individual/military,
		/obj/item/material/knife/folding/swiss/explorer,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/head/welding,
		/obj/item/device/camera,
		/obj/item/gun/energy/plasmacutter,
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/explorer, /obj/item/storage/backpack/satchel/explorer)),
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/dufflebag, /obj/item/storage/backpack/messenger/explorer)),
		new /datum/atom_creator/weighted(list(/obj/item/device/flashlight, /obj/item/device/flashlight/flare, /obj/item/device/flashlight/flare/glowstick/random))
	)

/obj/structure/closet/secure_closet/research_guard
	name = "Research Guard's locker"
	req_access = list(access_research_security)
	closet_appearance = /singleton/closet_appearance/secure_closet/torch/science

/singleton/closet_appearance/secure_closet/torch/exploration/engineer
	extra_decals = list(
		"stripe_vertical_mid_full" = COLOR_ORANGE,
		"exped" = COLOR_PURPLE
	)


/obj/structure/closet/secure_closet/guncabinet/sidearm/small
	name = "personal sidearm cabinet"

/obj/structure/closet/secure_closet/guncabinet/sidearm/small/WillContain()
	return list(/obj/item/gun/energy/gun/small/secure = 4)

/obj/structure/closet/secure_closet/guncabinet/sidearm/combined
	name = "combined sidearm cabinet"

/obj/structure/closet/secure_closet/guncabinet/sidearm/combined/WillContain()
	return list(
		/obj/item/storage/belt/holster/general = 3,
		/obj/item/gun/energy/gun/secure = 3,
		/obj/item/gun/energy/gun/small/secure = 1,
	)
