/datum/trading_station/service
	name_pool = list(
		"FTB \"Mess Hall\"" = "Free Trade Beacon \"Mess Hall\": hydroponics, galley supplies, and janitorial support.",
		"FTB \"Pantry Post\"" = "Free Trade Beacon \"Pantry Post\": nutritional staples, food processing packs, and mess supplies.",
		"FTB \"Cornucopia\"" = "Free Trade Beacon \"Cornucopia\": hydroponic seeds, nutrient canisters, and botanical gardening tools.",
		"FTB \"Hydro-Haven\"" = "Free Trade Beacon \"Hydro-Haven\": agricultural supplies, cleaning agents, and station service essentials."
	)
	uid = "service"
	icon_states = list("service")
	unlock_favor = 3500
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	inventory = list(
		TRADE_CAT_BOTANY = list(
			/obj/item/seeds/tomatoseed = GOODS_DEFAULT,
			/obj/item/seeds/wheatseed = GOODS_DEFAULT,
			/obj/item/seeds/chiliseed = GOODS_DEFAULT,
			/obj/item/seeds/soyaseed = GOODS_DEFAULT,
			/obj/item/seeds/appleseed = GOODS_DEFAULT,
			/obj/item/seeds/potatoseed = GOODS_DEFAULT,
			/obj/item/seeds/carrotseed = GOODS_DEFAULT,
			/obj/item/seeds/cornseed = GOODS_DEFAULT,
			/obj/item/seeds/eggplantseed = GOODS_DEFAULT,
			/obj/item/seeds/sunflowerseed = GOODS_DEFAULT,
			/obj/item/seeds/berryseed = GOODS_DEFAULT,
			/obj/item/reagent_containers/spray/plantbgone = GOODS_DEFAULT,
			/obj/item/reagent_containers/glass/bottle/ammonia = GOODS_DEFAULT,
			/obj/item/material/minihoe = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/hydroponics = GOODS_DEFAULT
		),
		TRADE_CAT_FOOD = list(
			/obj/item/material/rollingpin = GOODS_DEFAULT,
			/obj/item/material/knife/kitchen = GOODS_DEFAULT,
			/obj/item/reagent_containers/food/condiment/flour = GOODS_DEFAULT,
			/obj/item/reagent_containers/food/drinks/milk = GOODS_DEFAULT,
			/obj/item/reagent_containers/food/drinks/soymilk = GOODS_DEFAULT,
			/obj/item/storage/fancy/egg_box/full = GOODS_DEFAULT,
			/obj/item/storage/box/donkpocket_protein = GOODS_DEFAULT,
			/obj/item/storage/box/glasses = GOODS_DEFAULT,
			/obj/item/storage/box/glasses/mug = GOODS_DEFAULT,
			/obj/item/reagent_containers/chem_disp_cartridge/beer = GOODS_DEFAULT,
			/obj/item/reagent_containers/chem_disp_cartridge/wine = GOODS_DEFAULT,
			/obj/item/reagent_containers/chem_disp_cartridge/whiskey = GOODS_DEFAULT,
			/obj/item/reagent_containers/chem_disp_cartridge/vodka = GOODS_DEFAULT
		),
		TRADE_CAT_JANITORIAL = list(
			/obj/structure/mopbucket = GOODS_DEFAULT,
			/obj/item/mop = GOODS_DEFAULT,
			/obj/item/caution = GOODS_DEFAULT,
			/obj/item/reagent_containers/spray/cleaner = GOODS_DEFAULT,
			/obj/item/reagent_containers/glass/bucket = GOODS_DEFAULT,
			/obj/item/storage/box/detergent = GOODS_DEFAULT,
			/obj/item/storage/bag/trash = GOODS_DEFAULT
		)
	)
