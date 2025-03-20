/datum/trading_station/venus
	name_pool = list(
		"MCTB \"Boolean\"" = "Morpheus Cyberkinetics Trade Beacon \"Boolean\": Robotics maintenance and utility tools.",
		"VMTB \"Argenta\"" = "Vey-Med Trade Beacon \"Argenta\": All that you need to keep your body safe.",
		)
	uid = "venus"
	unlock_favor = 15000
	faction = FACTION_INDEPENDENT
	markup = 2.6
	inventory = list(
		TRADE_CAT_ROBOT = list(
			/obj/item/organ/internal/posibrain = GOODS_DEFAULT,
			/obj/item/borg/upgrade/rename = GOODS_DEFAULT,
			/obj/item/borg/upgrade/reset = GOODS_DEFAULT,
			/obj/item/borg/upgrade/restart = GOODS_DEFAULT,
			/obj/item/borg/upgrade/floodlight = GOODS_DEFAULT,
			/obj/item/borg/upgrade/flash_protection = GOODS_DEFAULT,
			/obj/item/device/flash/synthetic = GOODS_DEFAULT,
			),
		TRADE_CAT_EXOSUIT = list(
			/obj/item/device/paint_sprayer = GOODS_DEFAULT,
			/obj/item/device/kit/mech = GOODS_DEFAULT,
			),
		TRADE_CAT_AUG = list(
			/obj/item/organ/internal/augment/active/hud/security = CUSTOM_GOODS_NAME("Hephaestus Industries C-VSR HUD implant"),
			/obj/item/organ/internal/augment/active/hud/health = CUSTOM_GOODS_NAME("Vey-Med H-27 HUD implant"),
			/obj/item/organ/internal/augment/active/hud/janitor = CUSTOM_GOODS_NAME("Bishop CH-18 HUD implant"),
			/obj/item/organ/internal/augment/active/hud/science = CUSTOM_GOODS_NAME("Morpheus V-S HUD implant"),
			/obj/item/organ/internal/augment/boost/shooting = CUSTOM_GOODS_NAME("Hephaestus Industries AIM-4 gunnery booster implant"),
			/obj/item/organ/internal/augment/boost/muscle = CUSTOM_GOODS_NAME("Xion Industrial LMB220 leg muscle booster implant"),
			/obj/item/organ/internal/augment/boost/reflex = CUSTOM_GOODS_NAME("Ward-Takahashi GMB S4DTN reflex booster implant"),
			/obj/item/organ/internal/augment/active/iatric_monitor = CUSTOM_GOODS_NAME("Vey-Med M-45 iatric monitor implant"),
			/obj/item/organ/internal/augment/active/leukocyte_breeder = CUSTOM_GOODS_NAME("Zeng-Hu Lar-M10 leukocute breeder implant"),
			/obj/item/organ/internal/augment/active/nerve_dampeners = CUSTOM_GOODS_NAME("Vey-Med PK-31 neural dampener implant"),
			/obj/item/organ/internal/augment/active/internal_air_system = CUSTOM_GOODS_NAME("Zeng-Hu Chi-5 internal air system implant"),
			/obj/item/organ/internal/augment/active/item/adaptive_binoculars = CUSTOM_GOODS_NAME("Hephaestus Industries C-BNC vision implant"),
			/obj/item/organ/internal/augment/active/polytool/engineer = CUSTOM_GOODS_NAME("Xion Industrial PTI155 engineering polytool implant"),
			/obj/item/organ/internal/augment/active/polytool/surgical = CUSTOM_GOODS_NAME("Vey-Med SI-84 surgical polytool implant"),
			),
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/storage/firstaid/surgery = GOODS_DEFAULT,
			/obj/item/clothing/glasses/hud/health = GOODS_DEFAULT,
			/obj/item/clothing/glasses/hud/it = GOODS_DEFAULT,
			/obj/item/device/robotanalyzer = GOODS_DEFAULT,
			/obj/item/device/suit_cooling_unit = GOODS_DEFAULT,
			/obj/item/device/suit_cooling_unit/miniature = GOODS_DEFAULT,
			),
		TRADE_CAT_MEDICAL = list(
			/obj/item/stack/nanopaste = GOODS_DEFAULT,
			/obj/item/reagent_containers/spray/sterilizine = GOODS_DEFAULT,
			/obj/item/device/mmi = GOODS_DEFAULT,
			),
		)
	hidden_inventory = list(
		TRADE_CAT_AUG = list(
			/obj/item/organ/internal/augment/active/item/armblade = GOODS_DEFAULT,
			/obj/item/organ/internal/augment/active/item/wolverine = GOODS_DEFAULT,
			/obj/item/organ/internal/augment/active/item/popout_shotgun = GOODS_DEFAULT,
			/obj/item/organ/internal/augment/active/item/powerfist = GOODS_DEFAULT,
			),
		TRADE_CAT_ROBOT = list(
			/obj/item/borg/upgrade/vtec = GOODS_DEFAULT,
			/obj/item/borg/upgrade/weaponcooler = GOODS_DEFAULT,
			/obj/item/borg/upgrade/rcd = GOODS_DEFAULT,
			),
		)
