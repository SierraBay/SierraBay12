/datum/trading_station/medicine
	name_pool = list(
		"FTB \"Trauma Bay\"" = "Free Trade Beacon \"Trauma Bay\": medical replenishment, triage stock, and dispenser cartridges.",
		"FTB \"Caduceus\"" = "Free Trade Beacon \"Caduceus\": pharmaceutical restock and field medical emergency trauma kits.",
		"FTB \"Panacea\"" = "Free Trade Beacon \"Panacea\": chemical synthesizer supplies and surgical dispensary cart packages.",
		"FTB \"Bio-Pulse\"" = "Free Trade Beacon \"Bio-Pulse\": biological diagnostic aids and clinical replenishment goods."
	)
	uid = "medicine"
	icon_states = list("medical")
	unlock_favor = 4500
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	thematic_cores = list("Trauma Bay", "Caduceus", "Hygeia", "Panacea", "Triage Point", "Bio-Pulse", "Sanctuary", "Vitalis", "Remedy", "Helix")
	role_summary = "pharmaceutical stock, triage medical replenishments, and sterile supplies"
	inventory = list(
		TRADE_CAT_MEDKIT = list(
			/obj/item/storage/firstaid/regular = GOODS_DEFAULT,
			/obj/item/storage/firstaid/trauma = GOODS_DEFAULT,
			/obj/item/storage/firstaid/fire = GOODS_DEFAULT,
			/obj/item/storage/firstaid/toxin = GOODS_DEFAULT,
			/obj/item/storage/firstaid/o2 = GOODS_DEFAULT,
			/obj/item/storage/firstaid/radiation = GOODS_DEFAULT,
			/obj/item/storage/firstaid/adv = GOODS_DEFAULT,
			/obj/structure/closet/crate/med_crate/trauma = GOODS_DEFAULT,
			/obj/structure/closet/crate/med_crate/burn = GOODS_DEFAULT,
			/obj/structure/closet/crate/med_crate/toxin = GOODS_DEFAULT,
			/obj/structure/closet/crate/med_crate/oxyloss = GOODS_DEFAULT
		),
		TRADE_CAT_MEDICAL = list(
			/obj/item/stack/medical/bruise_pack = GOODS_DEFAULT,
			/obj/item/stack/medical/ointment = GOODS_DEFAULT,
			/obj/item/stack/medical/advanced/bruise_pack = GOODS_DEFAULT,
			/obj/item/stack/medical/advanced/ointment = GOODS_DEFAULT,
			/obj/item/reagent_containers/hypospray/autoinjector = GOODS_DEFAULT,
			/obj/item/roller_bed = GOODS_DEFAULT,
			/obj/item/storage/box/bodybags = GOODS_DEFAULT,
			/obj/item/bodybag/rescue = GOODS_DEFAULT,
			/obj/structure/bed/chair/wheelchair = GOODS_DEFAULT
		),
		TRADE_CAT_SURGERY = list(
			/obj/item/storage/firstaid/surgery = GOODS_DEFAULT,
			/obj/item/storage/belt/medical = GOODS_DEFAULT,
			/obj/item/scalpel = GOODS_DEFAULT,
			/obj/item/hemostat = GOODS_DEFAULT,
			/obj/item/retractor = GOODS_DEFAULT,
			/obj/item/cautery = GOODS_DEFAULT,
			/obj/item/circular_saw = GOODS_DEFAULT,
			/obj/item/surgicaldrill = GOODS_DEFAULT,
			/obj/item/bonegel = GOODS_DEFAULT,
			/obj/item/bonesetter = GOODS_DEFAULT,
			/obj/item/FixOVein = GOODS_DEFAULT
		),
		TRADE_CAT_CHEMICAL = list(
			/obj/item/reagent_containers/chem_disp_cartridge/bicaridine = CUSTOM_GOODS_NAME("bicaridine cartridge"),
			/obj/item/reagent_containers/chem_disp_cartridge/kelotane = CUSTOM_GOODS_NAME("kelotane cartridge"),
			/obj/item/reagent_containers/chem_disp_cartridge/dylovene = CUSTOM_GOODS_NAME("anti-toxin cartridge"),
			/obj/item/reagent_containers/chem_disp_cartridge/dexalin = CUSTOM_GOODS_NAME("dexalin cartridge"),
			/obj/item/reagent_containers/chem_disp_cartridge/inaprov = CUSTOM_GOODS_NAME("inaprovaline cartridge"),
			/obj/item/reagent_containers/chem_disp_cartridge/tramadol = CUSTOM_GOODS_NAME("tramadol cartridge"),
			/obj/item/reagent_containers/chem_disp_cartridge/spaceacillin = CUSTOM_GOODS_NAME("spaceacillin cartridge")
		)
	)
	hidden_inventory = list(
		TRADE_CAT_MEDICAL = list(
			/obj/item/reagent_containers/hypospray/autoinjector/combatstim = GOODS_DEFAULT,
			/obj/item/storage/firstaid/combat = GOODS_DEFAULT,
			/obj/item/defibrillator/loaded = GOODS_DEFAULT
		)
	)
