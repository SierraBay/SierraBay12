/singleton/closet_appearance/secure_closet/torch/chief_steward
	extra_decals = list(
		"stripe_vertical_right_full" = COLOR_GREEN_GRAY,
		"stripe_vertical_mid_full" = COLOR_CLOSET_GOLD
	)

/obj/structure/closet/secure_closet/cs_torch
	name = "chief steward's locker"
	req_access = list()
	closet_appearance = /singleton/closet_appearance/secure_closet/torch/chief_steward

/obj/structure/closet/secure_closet/cs_torch/WillContain()
	return list(
		/obj/item/storage/belt/general,
		/obj/item/clothing/head/chefhat,
		/obj/item/clothing/suit/chef/classic,
		/obj/item/clothing/suit/chef,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/glass/rag,
		/obj/item/clothing/glasses/science,
		/obj/item/storage/box/glasses,
		/obj/item/storage/plants,
		/obj/item/device/scanner/plant,
		/obj/item/storage/slide_projector,
		/obj/item/clothing/accessory/armband/hydro,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/device/megaphone,
		/obj/item/device/flashlight/upgraded,
		/obj/item/device/taperecorder,
		/obj/item/device/tape/random = 3,
		/obj/item/device/camera/tvcamera,
		/obj/item/device/camera_film = 2,
		/obj/item/device/radio/headset/headset_chief_steward,
		/obj/item/device/radio/headset/headset_chief_steward/alt,
	)
