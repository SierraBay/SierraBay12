#define CARTRIDGE(type) /obj/item/reagent_containers/chem_disp_cartridge/##type

/datum/trading_station/nanotrasen
	name_pool = list(
		"NTB \"Blanco\"" = "NanoTrasen Trade Beacon \"Blanco\": Wholesale sales and operational support.",
		"NTB \"Lobo\"" = "NanoTrasen Trade Beacon \"Lobo\": Wholesale sales and operational support.",
		"NTB \"Gris\"" = "NanoTrasen Trade Beacon \"Gris\": Wholesale sales and operational support.",
		)
	uid = "nanotrasen"
	unlock_favor = 2500
	faction = FACTION_NANOTRASEN
	whitelist_factions = list(FACTION_NANOTRASEN)
	spawn_always = TRUE
	markup = 1.5
	inventory = list(
		TRADE_CAT_EQUIPMENT = list(
			/obj/structure/closet/crate/freezer/meat = CUSTOM_GOODS_NAME("Meat supply pack"),
			/obj/structure/closet/crate/hydroponics/beekeeping = CUSTOM_GOODS_NAME("Beekeeping crate"),
			/obj/item/gun/projectile/pistol/magnum_pistol = CUSTOM_GOODS_NAME("magnum pistol"),
			),
		TRADE_CAT_CHEMCARTS = list(
			CARTRIDGE(whiskey) = CUSTOM_GOODS_NAME("cartridge (whiskey)"),
			CARTRIDGE(beer) = CUSTOM_GOODS_NAME("cartridge (beer)"),
			CARTRIDGE(kahlua) = CUSTOM_GOODS_NAME("cartridge (kahlua)"),
			CARTRIDGE(wine) = CUSTOM_GOODS_NAME("cartridge (wine)"),
			CARTRIDGE(vodka) = CUSTOM_GOODS_NAME("cartridge (vodka)"),
			CARTRIDGE(gin) = CUSTOM_GOODS_NAME("cartridge (gin)"),
			CARTRIDGE(rum) = CUSTOM_GOODS_NAME("cartridge (rum)"),
			CARTRIDGE(tequila) = CUSTOM_GOODS_NAME("cartridge (tequila)"),
			CARTRIDGE(vermouth) = CUSTOM_GOODS_NAME("cartridge (vermouth)"),
			CARTRIDGE(cognac) = CUSTOM_GOODS_NAME("cartridge (cognac)"),
			CARTRIDGE(ale) = CUSTOM_GOODS_NAME("cartridge (ale)"),
			CARTRIDGE(mead) = CUSTOM_GOODS_NAME("cartridge (mead)"),
			CARTRIDGE(water) = CUSTOM_GOODS_NAME("cartridge (water)"),
			CARTRIDGE(sugar) = CUSTOM_GOODS_NAME("cartridge (sugar)"),
			CARTRIDGE(ice) = CUSTOM_GOODS_NAME("cartridge (ice)"),
			CARTRIDGE(tea) = CUSTOM_GOODS_NAME("cartridge (tea)"),
			CARTRIDGE(green_tea) = CUSTOM_GOODS_NAME("cartridge (green_tea)"),
			CARTRIDGE(chai_tea) = CUSTOM_GOODS_NAME("cartridge (chai_tea)"),
			CARTRIDGE(red_tea) = CUSTOM_GOODS_NAME("cartridge (red_tea)"),
			CARTRIDGE(cola) = CUSTOM_GOODS_NAME("cartridge (cola)"),
			CARTRIDGE(smw) = CUSTOM_GOODS_NAME("cartridge (smw)"),
			CARTRIDGE(dr_gibb) = CUSTOM_GOODS_NAME("cartridge (dr_gibb)"),
			CARTRIDGE(spaceup) = CUSTOM_GOODS_NAME("cartridge (spaceup)"),
			CARTRIDGE(tonic) = CUSTOM_GOODS_NAME("cartridge (tonic)"),
			CARTRIDGE(sodawater) = CUSTOM_GOODS_NAME("cartridge (sodawater)"),
			CARTRIDGE(lemon_lime) = CUSTOM_GOODS_NAME("cartridge (lemon_lime)"),
			CARTRIDGE(orange) = CUSTOM_GOODS_NAME("cartridge (orange)"),
			CARTRIDGE(lime) = CUSTOM_GOODS_NAME("cartridge (lime)"),
			CARTRIDGE(watermelon) = CUSTOM_GOODS_NAME("cartridge (watermelon)"),
			CARTRIDGE(coffee) = CUSTOM_GOODS_NAME("cartridge (coffee)"),
			CARTRIDGE(cafe_latte) = CUSTOM_GOODS_NAME("cartridge (cafe_latte)"),
			CARTRIDGE(soy_latte) = CUSTOM_GOODS_NAME("cartridge (soy_latte)"),
			CARTRIDGE(hot_coco) = CUSTOM_GOODS_NAME("cartridge (hot_coco)"),
			CARTRIDGE(milk) = CUSTOM_GOODS_NAME("cartridge (milk)"),
			CARTRIDGE(cream) = CUSTOM_GOODS_NAME("cartridge (cream)"),
			CARTRIDGE(decaf_cof) = CUSTOM_GOODS_NAME("cartridge (decaf_cof)"),
			CARTRIDGE(decaf_tea) = CUSTOM_GOODS_NAME("cartridge (decaf_tea)"),
			CARTRIDGE(espresso) = CUSTOM_GOODS_NAME("cartridge (espresso)"),
			CARTRIDGE(syrup_chocolate) = CUSTOM_GOODS_NAME("cartridge (syrup_chocolate)"),
			CARTRIDGE(syrup_caramel) = CUSTOM_GOODS_NAME("cartridge (syrup_caramel)"),
			CARTRIDGE(syrup_vanilla) = CUSTOM_GOODS_NAME("cartridge (syrup_vanilla)"),
			CARTRIDGE(syrup_pumpkin) = CUSTOM_GOODS_NAME("cartridge (syrup_pumpkin)"),
			),
		)
