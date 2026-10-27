// Individual Sierra goods; stock counts sale units, including complete stacks.
#define TRADE_GOOD_DATA(title, stock_range, cost, quantity, access) list("name" = title, "amount_range" = stock_range, "price" = cost, "stack_size" = quantity, "req_access" = access)
#define TRADE_MINERAL_OFFER(title, cost, count) list("name" = title, "price" = cost, "amount" = count, "price_multiplier" = 2)
#define TRADE_OFFER_MODS(title, cost, count, parts, required) list("name" = title, "price" = cost, "amount" = count, "attachments" = parts, "attach_count" = required)
#define TRADE_OFFER_DATA(title, cost, count) list("name" = title, "price" = cost, "amount" = count)

/datum/trade_station/hephaestus
	tree_x = 25
	tree_y = 75
	icon_state = "wrench"
	tree_label = "Hephaestus"
	desc = "Hephaestus and Grayson contractors supply the Locutus frontier with refined materials, industrial tools and maintenance equipment. Their relays exchange rare ore and processed alloys for engineering supplies."
	uid = "engineering"
	name = "Hephaestus / Grayson Frontier Relay"
	start_discovered = TRUE
	markup = TRADE_WHOLESALE
	stations_recommended = list("electronics", "engines")
	inventory = list(
		"Mining logistics" = list(
			/obj/item/storage/ore = TRADE_GOOD_DATA("Mining satchel", list(2, 6), 60, 0, null),
			/obj/structure/ore_box = TRADE_GOOD_DATA(null, list(1, 3), 150, 0, null),
			/obj/item/pickaxe = TRADE_GOOD_DATA("Industrial pickaxe", list(2, 5), 80, 0, null),
		),
		"Materials" = list(
			/obj/item/stack/material/steel = TRADE_GOOD_DATA("Steel sheets", list(5, 12), 250, 50, null),
			/obj/item/stack/material/glass = TRADE_GOOD_DATA("Glass sheets", list(5, 10), 250, 50, null),
			/obj/item/stack/material/glass/reinforced = TRADE_GOOD_DATA("Reinforced glass", list(3, 8), 300, 30, null),
			/obj/item/stack/material/plasteel = TRADE_GOOD_DATA("Plasteel sheets", list(3, 6), 600, 30, null),
			/obj/item/stack/material/rods = TRADE_GOOD_DATA("Metal rods", list(4, 10), 150, 60, null),
			/obj/item/stack/cable_coil = TRADE_GOOD_DATA("Cable coils", list(6, 15), 120, 30, null),
		),
		"Tools and equipment" = list(
			/obj/item/weldingtool/largetank = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/device/multitool = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/belt/utility/full = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/glasses/meson = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/extinguisher = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/cell/high = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/cell/super = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/module/power_control = TRADE_GOOD_DATA("APC power control module", list(2, 6), 100, 0, null),
			/obj/item/stock_parts/circuitboard/smes = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/wrench = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/screwdriver = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/crowbar = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/wirecutters = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Security equipment" = list(
			/obj/item/clothing/suit/armor/vest = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_security),
			/obj/item/clothing/head/helmet = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_security),
			/obj/item/handcuffs = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_security),
			/obj/item/grenade/flashbang = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_security),
			/obj/item/melee/baton/loaded = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_security),
		),
	)
	hidden_inventory = list(
		"Heavy industry" = list(
			/obj/item/rcd = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_engine),
			/obj/item/rcd_ammo = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_engine),
			/obj/item/stack/material/uranium = TRADE_GOOD_DATA("Uranium sheets", list(1, 3), 0, 30, access_engine),
		),
	)
	offer_types = list(
		/obj/item/stack/material/plasteel = TRADE_MINERAL_OFFER("Refined plasteel (full stack)", 600, 3),
		/obj/item/ore/diamond = TRADE_MINERAL_OFFER("Diamond ore", 250, 3),
		/obj/item/ore/uranium = TRADE_MINERAL_OFFER("Uranium ore", 100, 5),
		/obj/item/ore/osmium = TRADE_MINERAL_OFFER("Platinum ore", 150, 5),
	)

/datum/trade_station/veymed
	tree_x = 75
	tree_y = 75
	icon_state = "heart"
	tree_label = "Vey-Med"
	desc = "A joint Vey-Med and Zeng-Hu medical convoy supporting remote expeditions between human and Skrell space. Field laboratories acquire xenobiology samples and synthesized medicine while distributing surgical and emergency supplies."
	uid = "medicine"
	name = "Vey-Med / Zeng-Hu Medical Convoy"
	start_discovered = TRUE
	markup = TRADE_WHOLESALE
	stations_recommended = list("fauna", "morpheus")
	inventory = list(
		"Kits and supplies" = list(
			/obj/item/storage/firstaid/regular = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/firstaid/fire = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/firstaid/o2 = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/firstaid/toxin = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stack/medical/advanced/bruise_pack = TRADE_GOOD_DATA("Advanced trauma dressings", list(2, 6), 0, 10, null),
			/obj/item/stack/medical/advanced/ointment = TRADE_GOOD_DATA("Advanced burn dressings", list(2, 6), 0, 10, null),
			/obj/item/stack/medical/bruise_pack = TRADE_GOOD_DATA("Sterile bandages", list(3, 8), 0, 10, null),
			/obj/item/stack/medical/ointment = TRADE_GOOD_DATA("Ointment", list(3, 8), 0, 10, null),
			/obj/item/reagent_containers/ivbag = TRADE_GOOD_DATA("Empty IV bag", list(2, 6), 100, 0, null),
			/obj/item/device/scanner/health = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/bodybag/cryobag = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/box/syringes = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Surgical tools" = list(
			/obj/item/scalpel/basic = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/hemostat = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/retractor = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/circular_saw = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/cautery = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/surgicaldrill = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/bonesetter = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/bonegel = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/FixOVein = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
		),
		"Pharmaceuticals" = list(
			/obj/item/reagent_containers/glass/bottle/inaprovaline = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/bicaridine = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/kelotane = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/dexalin = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/dylovene = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
	)
	hidden_inventory = list(
		"Specialist medicine" = list(
			/obj/item/defibrillator/loaded = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/slime_extract = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/reagent_containers/hypospray/autoinjector = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
		),
	)
	offer_types = list(
		/obj/item/slime_extract = TRADE_OFFER_DATA("Xenobiology extracts", 150, 3),
		/datum/reagent/inaprovaline = TRADE_OFFER_DATA("Inaprovaline (60u per container)", 180, 3),
	)

/datum/trade_station/dais
	tree_x = 45
	tree_y = 50
	icon_state = "gear"
	tree_label = "DAIS"
	desc = "Ward-Takahashi and DAIS technicians maintain a frontier exchange for computer hardware, sensors and licensed component designs. New sector survey data supports their remote communications and navigation projects."
	uid = "electronics"
	name = "Ward-Takahashi / DAIS Technical Exchange"
	stations_recommended = list("morpheus")
	inventory = list(
		"Stock parts" = list(
			/obj/item/stock_parts/manipulator = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/manipulator/nano = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/matter_bin = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/matter_bin/adv = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/micro_laser = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/micro_laser/high = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/capacitor = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/capacitor/adv = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/scanning_module = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Computers and data" = list(
			/obj/item/stock_parts/computer/hard_drive/portable/design/frontier_trade = TRADE_GOOD_DATA("Encrypted design disk", list(1, 2), 500, 0, null),
			/obj/item/stock_parts/computer/hard_drive = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/computer/hard_drive/advanced = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/computer/card_slot = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/computer/network_card = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stock_parts/computer/hard_drive/portable = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/device/radio = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Robotics and sensors" = list(
			/obj/item/device/mmi = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stack/nanopaste = TRADE_GOOD_DATA("Nanopaste", list(2, 6), 0, 10, null),
			/obj/item/device/assembly/prox_sensor = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/device/assembly/timer = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/airlock_electronics = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
	)
	hidden_inventory = list(
		"Advanced electronics" = list(
			/obj/item/organ/internal/posibrain = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/stock_parts/manipulator/pico = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/stock_parts/matter_bin/super = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/stock_parts/computer/network_card/advanced = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
	)
	offer_types = list(
		/obj/item/camera_assembly = TRADE_OFFER_MODS("Upgraded camera assembly", 700, 2, list(/obj/item/device/assembly/prox_sensor, /obj/item/stock_parts/scanning_module), 2),
		/obj/item/disk/survey = TRADE_OFFER_DATA("Sector survey disk", 300, 2),
	)

/datum/trade_station/engines
	tree_x = 15
	tree_y = 35
	icon_state = "power"
	tree_label = "Einstein"
	desc = "Einstein Engines and Aether Atmospherics operate a service tender for isolated research vessels. The tender supplies sealed industrial gas canisters, containment equipment and engine control components."
	uid = "engines"
	name = "Einstein Engines / Aether Service Tender"
	stations_recommended = list("skrell")
	inventory = list(
		"Atmospherics and gas" = list(
			/obj/machinery/portable_atmospherics/canister/carbon_dioxide = TRADE_GOOD_DATA(null, list(2, 6), 400, 0, null),
			/obj/machinery/portable_atmospherics/canister/oxygen = TRADE_GOOD_DATA(null, list(2, 6), 450, 0, null),
			/obj/machinery/portable_atmospherics/canister/nitrogen = TRADE_GOOD_DATA(null, list(2, 6), 400, 0, null),
			/obj/item/tank/oxygen_emergency_double = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/device/scanner/gas = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/device/paint_sprayer = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Safety and containment" = list(
			/obj/item/clothing/suit/radiation = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/head/radiation = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/suit/bio_suit = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/head/bio_hood = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/mask/gas = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Engine equipment" = list(
			/obj/item/stock_parts/circuitboard/air_management/supermatter_core = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_engine),
			/obj/item/stock_parts/circuitboard/tele_beacon = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_engine),
			/obj/item/stock_parts/circuitboard/powermonitor = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_engine),
			/obj/item/stock_parts/circuitboard/pacman = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_engine),
			/obj/item/cell/super = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_engine),
		),
	)
	hidden_inventory = list(
		"Specialist atmospherics" = list(
			/obj/machinery/portable_atmospherics/canister/phoron = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_atmospherics),
			/obj/machinery/portable_atmospherics/powered/pump/filled = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_atmospherics),
			/obj/machinery/portable_atmospherics/powered/scrubber = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_atmospherics),
		),
	)
	offer_types = list(
		/obj/item/ore/phoron = TRADE_OFFER_DATA("Phoron ore", 100, 5),
		/obj/item/stack/material/uranium = TRADE_OFFER_DATA("Refined uranium", 150, 5),
	)

/datum/trade_station/xynergy
	tree_x = 85
	tree_y = 35
	icon_state = "search"
	tree_label = "Xynergy"
	desc = "Xynergy field teams collect living specimens in the Locutus Sector. Their relay sells cultivation and containment supplies and accepts non-player fauna secured in stasis cages."
	uid = "fauna"
	name = "Xynergy Specimen Acquisition"
	stations_recommended = list("skrell")
	inventory = list(
		"Hydroponics" = list(
			/obj/item/device/scanner/plant = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/material/minihoe = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/wirecutters/clippers = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/eznutrient = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/left4zed = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/robustharvest = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Seeds" = list(
			/obj/item/seeds/wheatseed = TRADE_GOOD_DATA("Wheat seeds", list(2, 6), 100, 0, null),
			/obj/item/seeds/tomatoseed = TRADE_GOOD_DATA("Tomato seeds", list(2, 6), 100, 0, null),
			/obj/item/seeds/potatoseed = TRADE_GOOD_DATA("Potato seeds", list(2, 6), 100, 0, null),
			/obj/item/seeds/appleseed = TRADE_GOOD_DATA("Apple seeds", list(2, 6), 100, 0, null),
			/obj/item/stack/material/cloth = TRADE_GOOD_DATA("Cotton cloth", list(2, 6), 0, 20, null),
			/obj/item/seeds/towermycelium = TRADE_GOOD_DATA("Tower-cap spores", list(2, 6), 100, 0, null),
		),
		"Fauna and field supplies" = list(
			/obj/machinery/stasis_cage = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/snacks/monkeycube = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/snacks/liquidfood = TRADE_GOOD_DATA("Animal nutrient ration", list(2, 6), 100, 0, null),
			/obj/item/clothing/suit/bio_suit = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/head/bio_hood = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/syringe = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
	)
	hidden_inventory = list(
		"Exotic cultivation and capture" = list(
			/obj/item/seeds/ambrosiavulgarisseed = TRADE_GOOD_DATA("Ambrosia seeds", list(1, 3), 500, 0, null),
			/obj/item/seeds/nettleseed = TRADE_GOOD_DATA("Nettle seeds", list(1, 3), 500, 0, null),
			/obj/item/seeds/tobaccoseed = TRADE_GOOD_DATA("Tobacco seeds", list(1, 3), 500, 0, null),
			/obj/item/bodybag/cryobag = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/reagent_containers/food/snacks/egg = TRADE_GOOD_DATA("Chicken egg", list(1, 3), 500, 0, null),
		),
	)
	offer_types = list(
		/mob/living/simple_animal/hostile/carp = TRADE_OFFER_DATA("Live carp in a stasis cage", 600, 2),
	)

/datum/trade_station/gilthari
	tree_x = 50
	tree_y = 85
	icon_state = "cart"
	tree_label = "Gilthari"
	desc = "Gilthari Exports and Free Trade Union merchants connect passing convoys with remote exploration ships. Food, everyday supplies, mining logistics and a small luxury inventory keep long voyages comfortable."
	uid = "general"
	name = "Gilthari Exports / Free Trade Union"
	start_discovered = TRUE
	markup = TRADE_WHOLESALE
	stations_recommended = list("smugglers")
	inventory = list(
		"Mining logistics" = list(
			/obj/item/storage/ore = TRADE_GOOD_DATA("Mining satchel", list(2, 6), 60, 0, null),
			/obj/structure/ore_box = TRADE_GOOD_DATA(null, list(1, 3), 150, 0, null),
			/obj/item/pickaxe = TRADE_GOOD_DATA("Industrial pickaxe", list(2, 5), 80, 0, null),
		),
		"Chef and service" = list(
			/obj/item/reagent_containers/food/condiment/flour = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/condiment/sugar = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/drinks/milk = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/fancy/egg_box/full = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/snacks/meat = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/material/knife/kitchen = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/material/rollingpin = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/drinks/shaker = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/structure/reagent_dispensers/beerkeg = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/drinks/cans/cola = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/food/drinks/cans/sodawater = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
		"Logistics and paperwork" = list(
			/obj/item/hand_labeler = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/paper_bin = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/pen = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stamp = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/material/clipboard = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/device/scanner/price = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/backpack = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/backpack/dufflebag = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/storage/box = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/stack/material/cardboard = TRADE_GOOD_DATA("Cardboard sheets", list(2, 6), 0, 20, null),
		),
		"Civilian comfort" = list(
			/obj/item/storage/fancy/smokable/luckystars = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/flame/lighter/zippo = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/mask/smokable/cigarette/cigar = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/soap = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/mop = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/structure/mopbucket = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/glass/bucket = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
		),
	)
	hidden_inventory = list(
		"Luxury goods" = list(
			/obj/item/storage/fancy/smokable/cigar = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/clothing/mask/smokable/cigarette/cigar/havana = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/reagent_containers/food/drinks/bottle/wine = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/clothing/head/that = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
	)
	offer_types = list(
		/obj/item/reagent_containers/food/snacks/grown = TRADE_OFFER_DATA("Hydroponics produce", 15, 5),
	)

/datum/trade_station/morpheus
	tree_x = 30
	tree_y = 15
	icon_state = "person"
	tree_label = "Morpheus"
	desc = "A Morpheus Cyberkinetics specialist serves frontier synthetics and prosthetic clinics. Trusted medical and technical partners can recommend this rare relay for neural interfaces, replacement organs and advanced augmentations."
	uid = "morpheus"
	name = "Morpheus Cyberkinetics Specialist Relay"
	spawn_chance = 50
	markup = TRADE_RARE
	recommendations_needed = 2
	inventory = list(
		"Prosthetic limbs" = list(
			/obj/item/robot_parts/l_arm = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/robot_parts/r_arm = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/robot_parts/l_leg = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/robot_parts/r_leg = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
		),
		"Cybernetic organs" = list(
			/obj/item/organ/internal/heart/frontier_trade = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/organ/internal/lungs/frontier_trade = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/organ/internal/liver/frontier_trade = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/organ/internal/eyes/robot = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/organ/internal/augment/active/hud/health = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
		),
		"Neural interfaces" = list(
			/obj/item/device/mmi = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/organ/internal/posibrain = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/stack/nanopaste = TRADE_GOOD_DATA("Nanopaste", list(1, 3), 0, 10, null),
		),
	)
	hidden_inventory = list(
		"Advanced augmentations" = list(
			/obj/item/organ/internal/augment/armor = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/organ/internal/augment/active/polytool/engineer = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/organ/internal/augment/active/polytool/surgical = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
		),
	)
	offer_types = list(
		/obj/item/stock_parts/computer/hard_drive = TRADE_OFFER_DATA("Computer storage hardware", 150, 2),
	)

/datum/trade_station/skrell
	tree_x = 70
	tree_y = 15
	icon_state = "star"
	tree_label = "Skrell"
	desc = "A Skrellian frontier outpost monitors the border of unexplored Locutus space. Its quartermasters exchange specialized exploration equipment for unusual crystal samples and value introductions from engine and fauna expeditions."
	uid = "skrell"
	name = "Skrellian Frontier Outpost"
	spawn_chance = 50
	markup = TRADE_RARE
	recommendations_needed = 2
	inventory = list(
		"Frontier exploration" = list(
			/obj/item/clothing/suit/space/void/skrell = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/clothing/head/helmet/space/void/skrell = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			// Map-local types resolve only when the corresponding map is included.
			"/obj/item/clothing/suit/space/void/exploration" = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			"/obj/item/clothing/head/helmet/space/void/exploration" = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/device/gps = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/device/gps/marker = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/stock_parts/circuitboard/tele_beacon = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/bluespace_crystal = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/cell/skrell = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/solar_assembly = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
	)
	hidden_inventory = list(
		"Advanced exploration" = list(
			/obj/item/stock_parts/subspace/transmitter = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/fossil/bone = TRADE_GOOD_DATA("Ancient fauna fossil", list(1, 3), 500, 0, null),
			/obj/item/gun/energy/laser = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
	)
	offer_types = list(
		/obj/item/ore/diamond = TRADE_OFFER_DATA("Anomalous crystal samples", 250, 3),
	)

/datum/trade_station/smugglers
	tree_x = 50
	tree_y = 5
	icon_state = "locked"
	tree_label = "Two Hands"
	desc = "An unregistered freeport broker trading under the Two Hands name. Legitimate terminals cannot connect to its restricted market; an established contact and a compromised manager terminal are both required."
	uid = "smugglers"
	name = "Frontier Freeport / Two Hands Broker"
	spawn_chance = 25
	markup = TRADE_RARE
	black_market = TRUE
	inventory = list(
		"Unregistered weapons" = list(
			/obj/item/gun/projectile/pistol = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/ammo_magazine/pistol = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/gun/projectile/shotgun/pump/sawn = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/ammobox/shotgun = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/material/knife/combat = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
		"Illicit equipment" = list(
			/obj/item/card/emag = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/weapon/finger_lockpick = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/device/radio/spy = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/reagent_containers/hypospray/autoinjector/combatstim = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
	)
	hidden_inventory = list(
		"Restricted goods" = list(
			/obj/item/gun/energy/laser = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/clothing/glasses/thermal/syndi = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/grenade/empgrenade = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
		),
	)
	offer_types = list(
		/obj/item/gun/projectile/pistol = TRADE_OFFER_MODS("Pistol with an installed suppressor", 1000, 2, list(/obj/item/silencer), 1),
		/obj/item/gun/energy/laser = TRADE_OFFER_DATA("Unregistered laser weapons", 1000, 2),
	)

#undef TRADE_GOOD_DATA
#undef TRADE_OFFER_DATA
#undef TRADE_OFFER_MODS
#undef TRADE_MINERAL_OFFER

// Sierra uses robotize() rather than separate cybernetic organ catalog types.

/obj/item/organ/internal/heart/frontier_trade
	name = "cybernetic heart"

/obj/item/organ/internal/heart/frontier_trade/Initialize(mapload)
	. = ..()
	robotize()

/obj/item/organ/internal/lungs/frontier_trade
	name = "cybernetic lungs"

/obj/item/organ/internal/lungs/frontier_trade/Initialize(mapload)
	. = ..()
	robotize()

/obj/item/organ/internal/liver/frontier_trade
	name = "cybernetic liver"

/obj/item/organ/internal/liver/frontier_trade/Initialize(mapload)
	. = ..()
	robotize()

// Native R&D consumes design files on portable drives, rather than legacy blueprint disks.
/obj/item/stock_parts/computer/hard_drive/portable/design/frontier_trade
	name = "encrypted design disk"
	desc = "A licensed random advanced component design, readable by Sierra research terminals."
	max_capacity = 32

/obj/item/stock_parts/computer/hard_drive/portable/design/frontier_trade/install_default_programs()
	if(length(stored_files) || !SSresearch.research_initialized)
		return
	var/list/choices = list()
	for(var/datum/design/design as anything in SSresearch.all_designs)
		if(design.type in list(/datum/design/item/stock_part/adv_capacitor, /datum/design/item/stock_part/nano_mani, /datum/design/item/stock_part/high_micro_laser))
			choices += design
	if(!length(choices))
		return
	var/datum/design/selected = pick(choices)
	var/datum/computer_file/binary/design/file = selected.file.clone()
	if(!create_file(file))
		qdel(file)
		return
	read_only = TRUE
