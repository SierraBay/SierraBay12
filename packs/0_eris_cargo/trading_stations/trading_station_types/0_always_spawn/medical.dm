#define CARTRIDGE(type) /obj/item/reagent_containers/chem_disp_cartridge/##type

/datum/trading_station/medical
	name_pool = list(
		"ZHTB \"Pill\"" = "Zeng-Hu Trade Beacon \"Pill\": Wares for your wounds and more!",
		"ZHTB \"Medicus\"" = "Zeng-Hu Trade Beacon \"Medicus\": Bruise packs, surgery tools, chemicals!",
		)
	uid = "medical"
	unlock_favor = 5000
	faction = FACTION_INDEPENDENT // Should be under Zeng Hu, potentially
	spawn_always = TRUE
	markup = 1.2
	inventory = list(
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/defibrillator = GOODS_DEFAULT,
			/obj/item/auto_cpr = GOODS_DEFAULT,
			/obj/item/storage/firstaid/surgery = GOODS_DEFAULT,
			/obj/item/clothing/glasses/hud/health = GOODS_DEFAULT,
			/obj/item/device/scanner/health = GOODS_DEFAULT,
			/obj/item/autopsy_scanner = GOODS_DEFAULT,
			/obj/item/storage/box/pillbottles = GOODS_DEFAULT,
			/obj/item/storage/box/syringes = GOODS_DEFAULT,
			/obj/item/storage/box/masks = GOODS_DEFAULT,
			/obj/item/storage/box/gloves = GOODS_DEFAULT,
			/obj/item/storage/box/freezer = GOODS_DEFAULT,
			),
		TRADE_CAT_MEDICAL = list(
			/obj/item/stack/medical/advanced/bruise_pack = GOODS_DEFAULT,
			/obj/item/stack/medical/advanced/ointment = GOODS_DEFAULT,
			/obj/item/reagent_containers/glass/bottle/inaprovaline = GOODS_DEFAULT,
			/obj/item/reagent_containers/glass/bottle/antitoxin = GOODS_DEFAULT,
			/obj/item/reagent_containers/ivbag/nanoblood = CUSTOM_GOODS_NAME("nanoblood IV bag"),
			/obj/item/bodybag/rescue = GOODS_DEFAULT,
			),
		TRADE_CAT_MEDKIT = list(
			/obj/item/storage/firstaid/trauma = GOODS_DEFAULT,
			/obj/item/storage/firstaid/fire = GOODS_DEFAULT,
			/obj/item/storage/firstaid/toxin = GOODS_DEFAULT,
			/obj/item/storage/firstaid/o2 = GOODS_DEFAULT,
			/obj/item/storage/firstaid/adv = GOODS_DEFAULT,
			),
		TRADE_CAT_CHEMICAL = list(
			/obj/item/reagent_containers/glass/bottle/carpotoxin = GOODS_DEFAULT,
			/obj/item/reagent_containers/glass/bottle/spider_venom = GOODS_DEFAULT,
			),
		TRADE_CAT_CHEMCARTS = list(
			CARTRIDGE(water) = CUSTOM_GOODS_NAME("cartridge (water)"),
			CARTRIDGE(potassium) = CUSTOM_GOODS_NAME("cartridge (potassium)"),
			CARTRIDGE(sugar) = CUSTOM_GOODS_NAME("cartridge (sugar)"),
			CARTRIDGE(sodium) = CUSTOM_GOODS_NAME("cartridge (sodium)"),
			CARTRIDGE(aluminium) = CUSTOM_GOODS_NAME("cartridge (aluminium)"),
			CARTRIDGE(silicon) = CUSTOM_GOODS_NAME("cartridge (silicon)"),
			CARTRIDGE(phosphorus) = CUSTOM_GOODS_NAME("cartridge (phosphorus)"),
			CARTRIDGE(sulfur) = CUSTOM_GOODS_NAME("cartridge (sulfur)"),
			CARTRIDGE(iron) = CUSTOM_GOODS_NAME("cartridge (iron)"),
			CARTRIDGE(copper) = CUSTOM_GOODS_NAME("cartridge (copper)"),
			CARTRIDGE(mercury) = CUSTOM_GOODS_NAME("cartridge (mercury)"),
			CARTRIDGE(radium) = CUSTOM_GOODS_NAME("cartridge (radium)"),
			CARTRIDGE(ethanol) = CUSTOM_GOODS_NAME("cartridge (ethanol)"),
			CARTRIDGE(sacid) = CUSTOM_GOODS_NAME("cartridge (sacid)"),
			CARTRIDGE(tungsten) = CUSTOM_GOODS_NAME("cartridge (tungsten)"),
			CARTRIDGE(hclacid) = CUSTOM_GOODS_NAME("cartridge (hclacid)"),
			CARTRIDGE(lithium) = CUSTOM_GOODS_NAME("cartridge (lithium)"),
			CARTRIDGE(carbon) = CUSTOM_GOODS_NAME("cartridge (carbon)"),
			CARTRIDGE(ammonia) = CUSTOM_GOODS_NAME("cartridge (ammonia)"),
			CARTRIDGE(acetone) = CUSTOM_GOODS_NAME("cartridge (acetone)"),
			CARTRIDGE(hydrazine) = CUSTOM_GOODS_NAME("cartridge (hydrazine)"),
			CARTRIDGE(inaprov) = CUSTOM_GOODS_NAME("cartridge (inaprov)"),
			CARTRIDGE(ryetalyn) = CUSTOM_GOODS_NAME("cartridge (ryetalyn)"),
			CARTRIDGE(paracetamol) = CUSTOM_GOODS_NAME("cartridge (paracetamol)"),
			CARTRIDGE(dylovene) = CUSTOM_GOODS_NAME("cartridge (dylovene)"),
			CARTRIDGE(tricord) = CUSTOM_GOODS_NAME("cartridge (tricord)"),
			),
		)
	hidden_inventory = list(
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/defibrillator/compact = GOODS_DEFAULT,
			),
		TRADE_CAT_MEDICAL = list(
			/obj/item/reagent_containers/hypospray/vial = GOODS_DEFAULT,
			),
		TRADE_CAT_MEDKIT = list(
			/obj/item/storage/firstaid/combat = GOODS_DEFAULT,
			),
		)

#undef CARTRIDGE
