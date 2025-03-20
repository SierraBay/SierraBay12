/datum/trading_station/eva
	name_pool = list(
		"FTB \"Oxyta\"" = "Free Trade Beacon \"Oxyta\": All you will ever need for your space walks!",
		"FTB \"Spacer\"" = "Free Trade Beacon \"Spacer\": Affordable gear for EVA operations!",
		)
	uid = "eva"
	unlock_favor = 8000
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	inventory = list(
		TRADE_CAT_CLOTHING = list(
			/obj/item/clothing/under/space = GOODS_DEFAULT,
			/obj/item/clothing/shoes/magboots = GOODS_DEFAULT,
			/obj/item/clothing/suit/space/emergency = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/space/emergency = GOODS_DEFAULT,
			),
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/inflatable_dispenser = GOODS_DEFAULT,
			/obj/item/storage/briefcase/inflatable = GOODS_DEFAULT,
			),
		TRADE_CAT_VOIDSUIT = list(
			/obj/item/clothing/suit/space/void/engineering/alt = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/space/void/engineering/alt = GOODS_DEFAULT,
			/obj/item/clothing/suit/space/void/medical/alt = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/space/void/medical/alt = GOODS_DEFAULT,
			/obj/item/clothing/suit/space/void/security/alt = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/space/void/security/alt = GOODS_DEFAULT,
			/obj/item/clothing/suit/space/void/mining = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/space/void/mining = GOODS_DEFAULT,
			),
		TRADE_CAT_RIG = list(
			/obj/item/rig/eva = GOODS_DEFAULT,
			/obj/item/rig/industrial = GOODS_DEFAULT,
			/obj/item/rig/medical = GOODS_DEFAULT,
			),
		TRADE_CAT_RIG_MODULES = list(
			/obj/item/rig_module/maneuvering_jets = GOODS_DEFAULT,
			/obj/item/rig_module/cooling_unit = GOODS_DEFAULT,
			/obj/item/rig_module/device/rcd = GOODS_DEFAULT,
			/obj/item/rig_module/mounted/energy/plasmacutter = GOODS_DEFAULT,
			/obj/item/rig_module/device/drill = GOODS_DEFAULT,
			/obj/item/rig_module/device/orescanner = GOODS_DEFAULT,
			/obj/item/rig_module/device/anomaly_scanner = GOODS_DEFAULT,
			/obj/item/rig_module/chem_dispenser/injector = GOODS_DEFAULT,
			/obj/item/rig_module/device/healthscanner = GOODS_DEFAULT,
			/obj/item/rig_module/device/defib = GOODS_DEFAULT,
			/obj/item/rig_module/vision/meson = GOODS_DEFAULT,
			/obj/item/rig_module/vision/medhud = GOODS_DEFAULT,
			/obj/item/rig_module/vision/sechud = GOODS_DEFAULT,
			),
		)
	hidden_inventory = list(
		TRADE_CAT_CLOTHING = list(
			/obj/item/clothing/suit/space/syndicate = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/space/syndicate = GOODS_DEFAULT,
			),

		TRADE_CAT_RIG = list(
			/obj/item/rig/vox = GOODS_DEFAULT,
			),
		TRADE_CAT_RIG_MODULES = list(
			/obj/item/rig_module/mounted/energy/egun = GOODS_DEFAULT,
			/obj/item/rig_module/mounted/energy/lcannon = GOODS_DEFAULT,
			/obj/item/rig_module/vision/thermal = GOODS_DEFAULT,
			/obj/item/rig_module/electrowarfare_suite = GOODS_DEFAULT,
			/obj/item/rig_module/chem_dispenser/combat = GOODS_DEFAULT,
			/obj/item/rig_module/fabricator/energy_net = GOODS_DEFAULT,
			),
		)
