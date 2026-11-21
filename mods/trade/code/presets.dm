// Individual Sierra goods and legacy supply pack routing across 10 Frontier Trade relays.
#define TRADE_GOOD_DATA(title, stock_range, cost, quantity, access) list("name" = title, "amount_range" = stock_range, "price" = cost, "stack_size" = quantity, "req_access" = access)
#ifndef TRADE_PACK_DATA
#define TRADE_PACK_DATA(title, stock_range, target_cost, access) list("name" = title, "amount_range" = stock_range, "target_price" = target_cost, "req_access" = access)
#endif
#define TRADE_MINERAL_OFFER(title, cost, count) list("name" = title, "price" = cost, "amount" = count, "price_multiplier" = 2)
#define TRADE_OFFER_MODS(title, cost, count, parts, required) list("name" = title, "price" = cost, "amount" = count, "attachments" = parts, "attach_count" = required)
#define TRADE_OFFER_DATA(title, cost, count) list("name" = title, "price" = cost, "amount" = count)

/datum/trade_station/hephaestus
	tree_x = 20
	tree_y = 80
	icon_state = "wrench"
	overmap_color = "#ff9944"
	tree_label = "Hephaestus"
	desc = "Hephaestus and Grayson contractors supply the Locutus frontier with refined materials, industrial tools and maintenance equipment. Their relays exchange rare ore and processed alloys for engineering supplies."
	uid = "engineering"
	name = "Hephaestus / Grayson Frontier Relay"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_WHOLESALE
	stations_recommended = list("morpheus", "skrell")
	inventory = list(
		"Cargo & Logistics" = list(
			/obj/item/storage/ore = TRADE_GOOD_DATA("Mining satchel", list(4, 10), 60, 0, null),
			/obj/structure/ore_box = TRADE_GOOD_DATA(null, list(2, 6), 150, 0, null),
			/obj/item/pickaxe = TRADE_GOOD_DATA("Industrial pickaxe", list(4, 10), 80, 0, null),
			/singleton/hierarchy/supply_pack/operations/cargotrailer = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/operations/cargotrain = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/operations/minergear = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/operations/orebox = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/operations/plasma_cutter = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
		),
		"Materials" = list(
			/obj/item/stack/material/steel = TRADE_GOOD_DATA("Steel sheets", list(5, 12), 250, 50, null),
			/obj/item/stack/material/glass = TRADE_GOOD_DATA("Glass sheets", list(5, 10), 250, 50, null),
			/obj/item/stack/material/glass/reinforced = TRADE_GOOD_DATA("Reinforced glass", list(3, 8), 350, 30, null),
			/obj/item/stack/material/rods = TRADE_GOOD_DATA("Metal rods", list(4, 10), 150, 60, null),
			/obj/item/stack/cable_coil = TRADE_GOOD_DATA("Cable coils", list(6, 15), 120, 30, null),
			/singleton/hierarchy/supply_pack/materials/alum50 = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/materials/diamond10 = TRADE_PACK_DATA(null, list(1, 3), 1170, null),
			/singleton/hierarchy/supply_pack/materials/glass50 = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/materials/gold10 = TRADE_PACK_DATA(null, list(2, 6), 720, null),
			/singleton/hierarchy/supply_pack/materials/ocp10 = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/materials/ocp50 = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/materials/phoron10 = TRADE_PACK_DATA(null, list(1, 3), 1350, null),
			/singleton/hierarchy/supply_pack/materials/plasteel10 = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/materials/plasteel50 = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/materials/plastic50 = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/materials/silver10 = TRADE_PACK_DATA(null, list(2, 6), 540, null),
			/singleton/hierarchy/supply_pack/materials/steel50 = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/materials/titanium10 = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/materials/titanium50 = TRADE_PACK_DATA(null, list(1, 3), 1350, null),
			/singleton/hierarchy/supply_pack/materials/uranium10 = TRADE_PACK_DATA(null, list(2, 6), 810, null),
		),
		"Engineering" = list(
			/obj/item/weldingtool/largetank = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/device/multitool = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/storage/belt/utility/full = TRADE_GOOD_DATA(null, list(2, 6), 200, 0, null),
			/obj/item/clothing/glasses/meson = TRADE_GOOD_DATA(null, list(2, 6), 200, 0, null),
			/obj/item/extinguisher = TRADE_GOOD_DATA(null, list(4, 10), 50, 0, null),
			/obj/item/cell/high = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/cell/super = TRADE_GOOD_DATA(null, list(2, 6), 250, 0, null),
			/obj/item/module/power_control = TRADE_GOOD_DATA("APC power control module", list(4, 10), 125, 0, null),
			/obj/item/stock_parts/circuitboard/smes = TRADE_GOOD_DATA(null, list(2, 6), 250, 0, null),
			/obj/item/wrench = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/screwdriver = TRADE_GOOD_DATA(null, list(4, 10), 35, 0, null),
			/obj/item/crowbar = TRADE_GOOD_DATA(null, list(4, 10), 35, 0, null),
			/obj/item/wirecutters = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/singleton/hierarchy/supply_pack/engineering/air_dispenser = TRADE_PACK_DATA(null, list(2, 6), 525, null),
			/singleton/hierarchy/supply_pack/engineering/disposals_dispenser = TRADE_PACK_DATA(null, list(2, 6), 525, null),
			/singleton/hierarchy/supply_pack/engineering/electrical = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/engineering/firefighter = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/engineering/fueltank = TRADE_PACK_DATA(null, list(4, 10), 120, null),
			/singleton/hierarchy/supply_pack/engineering/mechanical = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/engineering/radsuit = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/engineering/shield_generator = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/engineering/smes_circuit = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/engineering/smescoil = TRADE_PACK_DATA(null, list(2, 6), 525, null),
			/singleton/hierarchy/supply_pack/engineering/smescoil_super_capacity = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/engineering/smescoil_super_io = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/engineering/smescoil_weak = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/engineering/solar = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/engineering/solar_assembly = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/engineering/voidsuit_engineering = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/machinery/sealgen = TRADE_PACK_DATA(null, list(2, 6), 900, null),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/hephaestus = TRADE_GOOD_DATA(null, list(2, 4), 800, 0, null),
			/singleton/hierarchy/supply_pack/prosthesis/hephaestus = TRADE_PACK_DATA(null, list(1, 3), 4200, null),
			/singleton/hierarchy/supply_pack/prosthesis/hephaestus_titan = TRADE_PACK_DATA(null, list(1, 3), 6000, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Cargo & Logistics" = list(
			/singleton/hierarchy/supply_pack/science/voidsuit = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/science/voidsuit_exploration = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/science/voidsuit_mining = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/science/voidsuit_pilot = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
		),
	)
#endif
	hidden_inventory = list(
		"Engineering" = list(
			/obj/item/rcd = TRADE_GOOD_DATA(null, list(1, 3), 750, 0, access_engine),
			/obj/item/rcd_ammo = TRADE_GOOD_DATA(null, list(2, 6), 120, 0, access_engine),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/hephaestus_titan = TRADE_GOOD_DATA(null, list(1, 2), 1100, 0, access_medical),
		),
	)
	offer_types = list(
		/obj/item/stack/material/plasteel = TRADE_OFFER_DATA("Refined plasteel (full stack)", 500, 3),
		/obj/item/ore/diamond = TRADE_OFFER_DATA("Diamond ore", 180, 3),
		/obj/item/ore/uranium = TRADE_OFFER_DATA("Uranium ore", 120, 5),
		/obj/item/ore/osmium = TRADE_OFFER_DATA("Platinum ore", 150, 5),
	)

/datum/trade_station/veymed
	tree_x = 80
	tree_y = 80
	icon_state = "heart"
	overmap_color = "#55ccaa"
	tree_label = "Vey-Med"
	desc = "A joint Vey-Med and Zeng-Hu medical convoy supporting remote expeditions between human and Skrell space. Field laboratories acquire xenobiology samples and synthesized medicine while distributing surgical and emergency supplies."
	uid = "medicine"
	name = "Vey-Med / Zeng-Hu Medical Convoy"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_WHOLESALE
	stations_recommended = list("morpheus")
	inventory = list(
		"Medical" = list(
			/obj/item/storage/firstaid/regular = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/storage/firstaid/fire = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/storage/firstaid/o2 = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/storage/firstaid/toxin = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/stack/medical/advanced/bruise_pack = TRADE_GOOD_DATA("Advanced trauma dressings", list(4, 10), 150, 10, null),
			/obj/item/stack/medical/advanced/ointment = TRADE_GOOD_DATA("Advanced burn dressings", list(4, 10), 150, 10, null),
			/obj/item/stack/medical/bruise_pack = TRADE_GOOD_DATA("Sterile bandages", list(5, 12), 75, 10, null),
			/obj/item/stack/medical/ointment = TRADE_GOOD_DATA("Ointment", list(5, 12), 75, 10, null),
			/obj/item/reagent_containers/ivbag = TRADE_GOOD_DATA("Empty IV bag", list(4, 10), 50, 0, null),
			/obj/item/device/scanner/health = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/bodybag/cryobag = TRADE_GOOD_DATA(null, list(2, 6), 300, 0, null),
			/obj/item/storage/box/syringes = TRADE_GOOD_DATA(null, list(4, 10), 75, 0, null),
			/obj/item/scalpel/basic = TRADE_GOOD_DATA(null, list(2, 6), 90, 0, access_medical),
			/obj/item/hemostat = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, access_medical),
			/obj/item/retractor = TRADE_GOOD_DATA(null, list(2, 6), 90, 0, access_medical),
			/obj/item/circular_saw = TRADE_GOOD_DATA(null, list(2, 6), 140, 0, access_medical),
			/obj/item/cautery = TRADE_GOOD_DATA(null, list(2, 6), 120, 0, access_medical),
			/obj/item/surgicaldrill = TRADE_GOOD_DATA(null, list(2, 6), 140, 0, access_medical),
			/obj/item/bonesetter = TRADE_GOOD_DATA(null, list(2, 6), 150, 0, access_medical),
			/obj/item/bonegel = TRADE_GOOD_DATA(null, list(2, 6), 200, 0, access_medical),
			/obj/item/FixOVein = TRADE_GOOD_DATA(null, list(2, 6), 250, 0, access_medical),
			/singleton/hierarchy/supply_pack/medical/abk = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/medical/atk = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/medical/autocomp = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/medical/autopsy = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/medical/beltdefib = TRADE_PACK_DATA(null, list(1, 3), 1125, null),
			/singleton/hierarchy/supply_pack/medical/bloodpack = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/bodybag = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/burn = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/chemistgear = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/cmogear = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/medical/defib = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/medical/doctorgear = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/medical/gloves = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/medical/glucose = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/human_oneg = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/medical = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/medical/medicalbiosuits = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/medical/medicalextragear = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/medicalscrubs = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/medicaluniforms = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/oxyloss = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/paramedicgear = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/medical/portablefreezers = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/medical/psychiatristgear = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/radiation = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/rescuebag = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/medical/scanner_module = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/medical/serpentid_oneg = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/medical/skrell_oneg = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/medical/stab = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/medical/sterile = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/medical/stretcher = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/surgery = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/medical/toxin = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/trauma = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/medical/unathi_oneg = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/medical/wheelchair = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/operations/voidsuit_medical = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/science/virus = TRADE_PACK_DATA(null, list(2, 6), 375, null),
		),
		"Chemistry & Cartridges" = list(
			/obj/item/reagent_containers/glass/bottle/inaprovaline = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/bicaridine = TRADE_GOOD_DATA(null, list(4, 10), 125, 0, null),
			/obj/item/reagent_containers/glass/bottle/kelotane = TRADE_GOOD_DATA(null, list(4, 10), 125, 0, null),
			/obj/item/reagent_containers/glass/bottle/dexalin = TRADE_GOOD_DATA(null, list(4, 10), 120, 0, null),
			/obj/item/reagent_containers/glass/bottle/dylovene = TRADE_GOOD_DATA(null, list(4, 10), 120, 0, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/acetone = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/acid = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/aluminium = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/ammonia = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/carbon = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/copper = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/ethanol = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/hydrazine = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/hydrochloric = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/iron = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/lithium = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/mercury = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/phosphorus = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/potassium = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/radium = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/silicon = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/sodium = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/sulfur = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/tungsten = TRADE_PACK_DATA(null, list(4, 10), 225, null),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/zenghu = TRADE_GOOD_DATA(null, list(2, 4), 800, 0, access_medical),
			/singleton/hierarchy/supply_pack/prosthesis/zenghu = TRADE_PACK_DATA(null, list(1, 3), 4200, null),
			/singleton/hierarchy/supply_pack/prosthesis/zenghu_spirit = TRADE_PACK_DATA(null, list(1, 3), 4200, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Medical" = list(
			/singleton/hierarchy/supply_pack/medical/blood = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/medical/cryobags = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
		),
	)
#endif
	hidden_inventory = list(
		"Medical" = list(
			/obj/item/defibrillator/loaded = TRADE_GOOD_DATA(null, list(1, 3), 550, 0, access_medical),
			/obj/item/slime_extract = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/obj/item/reagent_containers/hypospray/autoinjector = TRADE_GOOD_DATA(null, list(2, 5), 200, 0, access_medical),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/zenghu_spirit = TRADE_GOOD_DATA(null, list(1, 2), 800, 0, access_medical),
		),
	)
	offer_types = list(
		/obj/item/slime_extract = TRADE_OFFER_DATA("Xenobiology extracts", 350, 3),
		/datum/reagent/tricordrazine = TRADE_OFFER_DATA("Tricordrazine (60u per container)", 220, 3),
		/datum/reagent/dermaline = TRADE_OFFER_DATA("Dermaline (60u per container)", 280, 2),
		/datum/reagent/bicaridine = TRADE_OFFER_DATA("Bicaridine (60u per container)", 180, 3),
	)

/datum/trade_station/gilthari
	tree_x = 50
	tree_y = 85
	icon_state = "cart"
	overmap_color = "#ffcc55"
	tree_label = "Gilthari"
	desc = "Gilthari Exports and Free Trade Union merchants connect passing convoys with remote exploration ships. Food, everyday supplies, mining logistics and a full civilian apparel catalog keep long voyages comfortable."
	uid = "general"
	name = "Gilthari Exports / Free Trade Union"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_WHOLESALE
	stations_recommended = list("smugglers")
	inventory = list(
		"Food & Service" = list(
			/obj/item/reagent_containers/food/condiment/flour = TRADE_GOOD_DATA(null, list(4, 10), 35, 0, null),
			/obj/item/reagent_containers/food/condiment/sugar = TRADE_GOOD_DATA(null, list(4, 10), 35, 0, null),
			/obj/item/reagent_containers/food/drinks/milk = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/storage/fancy/egg_box/full = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/reagent_containers/food/snacks/meat = TRADE_GOOD_DATA(null, list(4, 10), 60, 0, null),
			/obj/item/material/knife/kitchen = TRADE_GOOD_DATA(null, list(4, 10), 50, 0, null),
			/obj/item/material/rollingpin = TRADE_GOOD_DATA(null, list(4, 10), 35, 0, null),
			/obj/item/reagent_containers/food/drinks/shaker = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/structure/reagent_dispensers/beerkeg = TRADE_GOOD_DATA(null, list(2, 6), 200, 0, null),
			/obj/item/reagent_containers/food/drinks/cans/cola = TRADE_GOOD_DATA(null, list(4, 10), 30, 0, null),
			/obj/item/reagent_containers/food/drinks/cans/sodawater = TRADE_GOOD_DATA(null, list(4, 10), 30, 0, null),
			/obj/item/storage/fancy/smokable/luckystars = TRADE_GOOD_DATA(null, list(4, 10), 75, 0, null),
			/obj/item/flame/lighter/zippo = TRADE_GOOD_DATA(null, list(4, 10), 50, 0, null),
			/obj/item/clothing/mask/smokable/cigarette/cigar = TRADE_GOOD_DATA(null, list(4, 10), 45, 0, null),
			/singleton/hierarchy/supply_pack/galley/barsupplies = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/galley/beef = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/galley/beer_dispenser = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/galley/bugmeat = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/galley/chicken = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/galley/donkpocket = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/galley/eggs = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/galley/food = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/galley/goat = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/galley/ham = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/galley/milk = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/galley/mre_dispenser = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/galley/party = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/galley/pizza = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/galley/premiumalcohol = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/galley/rations = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/galley/seafood = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/galley/silverware = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/galley/soda_dispenser = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/galley/thoom = TRADE_PACK_DATA(null, list(4, 10), 150, null),
		),
		"Cargo & Logistics" = list(
			/obj/item/hand_labeler = TRADE_GOOD_DATA(null, list(4, 10), 60, 0, null),
			/obj/item/paper_bin = TRADE_GOOD_DATA(null, list(4, 10), 55, 0, null),
			/obj/item/pen = TRADE_GOOD_DATA(null, list(4, 10), 25, 0, null),
			/obj/item/stamp = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/material/clipboard = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/device/scanner/price = TRADE_GOOD_DATA(null, list(4, 10), 150, 0, null),
			/obj/item/storage/backpack = TRADE_GOOD_DATA(null, list(4, 10), 80, 0, null),
			/obj/item/storage/backpack/dufflebag = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/storage/box = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/stack/material/cardboard = TRADE_GOOD_DATA("Cardboard sheets", list(4, 10), 75, 20, null),
			/obj/item/soap = TRADE_GOOD_DATA(null, list(4, 10), 35, 0, null),
			/obj/item/mop = TRADE_GOOD_DATA(null, list(4, 10), 45, 0, null),
			/obj/structure/mopbucket = TRADE_GOOD_DATA(null, list(2, 6), 75, 0, null),
			/obj/item/reagent_containers/glass/bucket = TRADE_GOOD_DATA(null, list(4, 10), 65, 0, null),
			/singleton/hierarchy/supply_pack/custodial/cleaning = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/custodial/janitor = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/custodial/janitorbiosuits = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/custodial/lightbulbs = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/custodial/mousetrap = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/operations/bureaucracy = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/operations/webbing = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/supply/bodavendor = TRADE_PACK_DATA(null, list(1, 3), 3000, null),
			/singleton/hierarchy/supply_pack/supply/bogrolls = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/boozevendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/canned = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/supply/cardboard_sheets = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/cigarettevendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/coffeevendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/dinnerwarevendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/eftpos = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/engineeringvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/fitnessvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/gamevendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/gpaper = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/lavatoryvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/roboticsvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/scanner_module = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/supply/snacks = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/snackvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/snixvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/sodas = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/sodavendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/solvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/spare_pda = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/stickies = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/taperolls = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/tapes = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/toner = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/supply/toolvendor = TRADE_PACK_DATA(null, list(1, 3), 2250, null),
			/singleton/hierarchy/supply_pack/supply/water = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/supply/weebvendor = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/supply/wpaper = TRADE_PACK_DATA(null, list(4, 10), 150, null),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/nanotrasen = TRADE_GOOD_DATA(null, list(2, 5), 400, 0, null),
			/obj/item/prosthetic_kit/frontier_trade/xion_econ = TRADE_GOOD_DATA(null, list(2, 5), 400, 0, null),
			/obj/item/prosthetic_kit/frontier_trade/resomi = TRADE_GOOD_DATA(null, list(2, 5), 500, 0, null),
			/singleton/hierarchy/supply_pack/prosthesis/nanotrasen = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/prosthesis/resomi = TRADE_PACK_DATA(null, list(1, 3), 2400, null),
			/singleton/hierarchy/supply_pack/prosthesis/xion_econ = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
		),
		"Clothing & Gear" = list(
			/singleton/hierarchy/supply_pack/clothes_uniforms/aether = TRADE_PACK_DATA(null, list(4, 10), 285, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/bishop = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/black = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/blackjumpshorts = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/blackjumpskirt = TRADE_PACK_DATA(null, list(4, 10), 210, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/blazer = TRADE_PACK_DATA(null, list(4, 10), 270, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/blue = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/bluesuit = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/burgundy = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/charcoal = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/checkered = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dais = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/det = TRADE_PACK_DATA(null, list(2, 6), 330, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/det_black = TRADE_PACK_DATA(null, list(2, 6), 345, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/det_grey = TRADE_PACK_DATA(null, list(2, 6), 345, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dress_fire = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dress_green = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dress_hr = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dress_orange = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dress_pink = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/dress_purple = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/female = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/focal = TRADE_PACK_DATA(null, list(4, 10), 285, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/frontier = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/gentlesuit = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/grayson = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/hazard = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/hephaestus = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/kilt = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/mbill = TRADE_PACK_DATA(null, list(4, 10), 285, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/morpheus = TRADE_PACK_DATA(null, list(4, 10), 285, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/navy = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/ntwork = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/oldman = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/pcrc = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/pcrcsuit = TRADE_PACK_DATA(null, list(4, 10), 270, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/pj_blue = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/pj_red = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/plain = TRADE_PACK_DATA(null, list(4, 10), 270, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/purpsuit = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/really_black = TRADE_PACK_DATA(null, list(4, 10), 255, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/red = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/roboticist_skirt = TRADE_PACK_DATA(null, list(4, 10), 210, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/saare = TRADE_PACK_DATA(null, list(4, 10), 285, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/scratch = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/skinner = TRADE_PACK_DATA(null, list(4, 10), 270, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/sl_suit = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/suit_jacket = TRADE_PACK_DATA(null, list(4, 10), 210, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/sundress = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/sundress_white = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/tan = TRADE_PACK_DATA(null, list(4, 10), 210, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/wardt = TRADE_PACK_DATA(null, list(4, 10), 285, null),
			/singleton/hierarchy/supply_pack/clothes_uniforms/zeng = TRADE_PACK_DATA(null, list(2, 6), 315, null),
			/singleton/hierarchy/supply_pack/flooring/carpetblack = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetblue = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetblue2 = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetblue3 = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetbrown = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetgreen = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetorange = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetpurple = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/carpetred = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/dark_tiles = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/freezer_tiles = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/linoleum = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/flooring/white_tiles = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/nonessent/aromatherapy = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/nonessent/artscrafts = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/card_packs = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/nonessent/chaplaingear = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/costume = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/costume_hats = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/dresses = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/nonessent/formal_wear = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/nonessent/hats = TRADE_PACK_DATA(null, list(1, 3), 2400, null),
			/singleton/hierarchy/supply_pack/nonessent/instruments = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/nonessent/lasertag = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/nonessent/llamps = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/officetoys = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/nonessent/painters = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/pins = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/nonessent/pronounbadges = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/witch = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/nonessent/wizard = TRADE_PACK_DATA(null, list(4, 10), 300, null),
		),
		"Chemistry & Cartridges" = list(
			/singleton/hierarchy/supply_pack/dispenser_cartridges/ale = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/beer = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/cafe_latte = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/chai_tea = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/coffee = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/cognac = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/cola = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/cream = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/decaf_cof = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/decaf_tea = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/dr_gibb = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/empty = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/espresso = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/gin = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/green_tea = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/hot_coco = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/ice = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/kahlua = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/lemon_lime = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/lime = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/mead = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/milk = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/orange = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/red_tea = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/rum = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/smw = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/sodawater = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/soy_latte = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/spaceup = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/sugar = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/syrup_caramel = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/syrup_chocolate = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/syrup_pumpkin = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/syrup_vanilla = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/tea = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/tequila = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/tonic = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/vermouth = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/vodka = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/water = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/watermelon = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/whiskey = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/dispenser_cartridges/wine = TRADE_PACK_DATA(null, list(4, 10), 225, null),
		),
		"Materials" = list(
			/singleton/hierarchy/supply_pack/materials/ebony25 = TRADE_PACK_DATA(null, list(1, 3), 1650, null),
			/singleton/hierarchy/supply_pack/materials/mahogany25 = TRADE_PACK_DATA(null, list(1, 3), 960, null),
			/singleton/hierarchy/supply_pack/materials/maple50 = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/materials/marble10 = TRADE_PACK_DATA(null, list(2, 6), 360, null),
			/singleton/hierarchy/supply_pack/materials/marble50 = TRADE_PACK_DATA(null, list(1, 3), 1080, null),
			/singleton/hierarchy/supply_pack/materials/walnut25 = TRADE_PACK_DATA(null, list(2, 6), 500, null),
			/singleton/hierarchy/supply_pack/materials/wood50 = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/materials/yew25 = TRADE_PACK_DATA(null, list(2, 6), 360, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Food & Service" = list(
			/singleton/hierarchy/supply_pack/galley/hookah = TRADE_PACK_DATA(null, list(4, 10), 300, null),
		),
	)
#endif
	hidden_inventory = list(
		"Food & Service" = list(
			/obj/item/storage/fancy/smokable/cigar = TRADE_GOOD_DATA(null, list(1, 3), 220, 0, null),
			/obj/item/clothing/mask/smokable/cigarette/cigar/havana = TRADE_GOOD_DATA(null, list(1, 3), 150, 0, null),
			/obj/item/reagent_containers/food/drinks/bottle/wine = TRADE_GOOD_DATA(null, list(1, 3), 180, 0, null),
		),
		"Clothing & Gear" = list(
			/obj/item/clothing/head/that = TRADE_GOOD_DATA(null, list(1, 3), 200, 0, null),
		),
	)
	offer_types = list(
		/obj/item/reagent_containers/food/snacks/grown = TRADE_OFFER_DATA("Hydroponics produce", 60, 5),
		/obj/item/reagent_containers/food/snacks/meatpie = TRADE_OFFER_DATA("Fresh baked meat pies", 90, 3),
		/obj/item/stack/material/wood/mahogany = TRADE_OFFER_DATA("Mahogany planks (full stack)", 750, 2),
		/obj/item/reagent_containers/food/snacks/vegetablesoup = TRADE_OFFER_DATA("Hot vegetable soup bowls", 85, 3),
	)

/datum/trade_station/dais
	tree_x = 38
	tree_y = 50
	icon_state = "gear"
	overmap_color = "#66ccff"
	tree_label = "DAIS"
	desc = "Ward-Takahashi and DAIS technicians maintain a frontier exchange for computer hardware, stock parts, robotics components and licensed research equipment. New sector survey data supports their remote communications projects."
	uid = "electronics"
	name = "Ward-Takahashi / DAIS Technical Exchange"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_COMMON
	stations_recommended = list("morpheus")
	inventory = list(
		"Science & Robotics" = list(
			/obj/item/stock_parts/manipulator = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/stock_parts/manipulator/nano = TRADE_GOOD_DATA(null, list(2, 6), 180, 0, null),
			/obj/item/stock_parts/matter_bin = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/stock_parts/matter_bin/adv = TRADE_GOOD_DATA(null, list(2, 6), 180, 0, null),
			/obj/item/stock_parts/micro_laser = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/stock_parts/micro_laser/high = TRADE_GOOD_DATA(null, list(2, 6), 180, 0, null),
			/obj/item/stock_parts/capacitor = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/stock_parts/capacitor/adv = TRADE_GOOD_DATA(null, list(2, 6), 180, 0, null),
			/obj/item/stock_parts/scanning_module = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/stock_parts/computer/hard_drive/portable/design/frontier_trade = TRADE_GOOD_DATA("Encrypted design disk", list(1, 3), 480, 0, null),
			/obj/item/stock_parts/computer/hard_drive = TRADE_GOOD_DATA(null, list(2, 6), 160, 0, null),
			/obj/item/stock_parts/computer/hard_drive/advanced = TRADE_GOOD_DATA(null, list(2, 6), 240, 0, null),
			/obj/item/stock_parts/computer/card_slot = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/stock_parts/computer/network_card = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/stock_parts/computer/hard_drive/portable = TRADE_GOOD_DATA(null, list(4, 10), 120, 0, null),
			/obj/item/device/radio = TRADE_GOOD_DATA(null, list(4, 10), 120, 0, null),
			/obj/item/device/mmi = TRADE_GOOD_DATA(null, list(2, 6), 480, 0, null),
			/obj/item/stack/nanopaste = TRADE_GOOD_DATA("Nanopaste", list(2, 6), 240, 10, null),
			/obj/item/device/assembly/prox_sensor = TRADE_GOOD_DATA(null, list(4, 10), 70, 0, null),
			/obj/item/device/assembly/timer = TRADE_GOOD_DATA(null, list(4, 10), 70, 0, null),
			/obj/item/airlock_electronics = TRADE_GOOD_DATA(null, list(4, 10), 160, 0, null),
			/singleton/hierarchy/supply_pack/engineering/bluespacerelay = TRADE_PACK_DATA(null, list(1, 3), 1125, null),
			/singleton/hierarchy/supply_pack/engineering/robotics = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/nonessent/mech_kit = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/science/anomaly_crate = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/science/chemistry_dispenser = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/science/coolanttank = TRADE_PACK_DATA(null, list(4, 10), 240, null),
			/singleton/hierarchy/supply_pack/science/flamps = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/science/illuminate = TRADE_PACK_DATA(null, list(4, 10), 300, null),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/wardtakahashi_econ = TRADE_GOOD_DATA(null, list(2, 5), 384, 0, null),
			/obj/item/prosthetic_kit/frontier_trade/wardtakahashi = TRADE_GOOD_DATA(null, list(2, 4), 576, 0, null),
			/obj/item/prosthetic_kit/frontier_trade/xion = TRADE_GOOD_DATA(null, list(2, 4), 576, 0, null),
			/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi = TRADE_PACK_DATA(null, list(1, 3), 3300, null),
			/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi_econ = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/prosthesis/xion = TRADE_PACK_DATA(null, list(1, 3), 3000, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Science & Robotics" = list(
			/singleton/hierarchy/supply_pack/engineering/ntnet_relay = TRADE_PACK_DATA(null, list(2, 6), 750, null),
		),
	)
#endif
	hidden_inventory = list(
		"Science & Robotics" = list(
			/obj/item/organ/internal/posibrain = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, null),
			/obj/item/stock_parts/manipulator/pico = TRADE_GOOD_DATA(null, list(1, 3), 320, 0, null),
			/obj/item/stock_parts/matter_bin/super = TRADE_GOOD_DATA(null, list(1, 3), 360, 0, null),
			/obj/item/stock_parts/computer/network_card/advanced = TRADE_GOOD_DATA(null, list(1, 3), 200, 0, null),
		),
	)
	offer_types = list(
		/obj/item/camera_assembly = TRADE_OFFER_MODS("Upgraded camera assembly", 500, 2, list(/obj/item/device/assembly/prox_sensor, /obj/item/stock_parts/scanning_module), 2),
		/obj/item/disk/survey = TRADE_OFFER_DATA("Sector survey disk", 350, 2),
		/obj/item/stock_parts/computer/hard_drive = TRADE_OFFER_DATA("Computer storage hardware", 100, 2),
	)

/datum/trade_station/engines
	tree_x = 14
	tree_y = 48
	icon_state = "power"
	overmap_color = "#ffbb33"
	tree_label = "Einstein"
	desc = "Einstein Engines and Aether Atmospherics operate a service tender for isolated research vessels. The tender supplies sealed industrial gas canisters, containment equipment and engine power components."
	uid = "engines"
	name = "Einstein Engines / Aether Service Tender"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_COMMON
	stations_recommended = list("skrell")
	inventory = list(
		"Atmospherics" = list(
			/obj/item/tank/oxygen_emergency_double = TRADE_GOOD_DATA(null, list(4, 10), 90, 0, null),
			/obj/item/device/scanner/gas = TRADE_GOOD_DATA(null, list(4, 10), 120, 0, null),
			/obj/item/device/paint_sprayer = TRADE_GOOD_DATA(null, list(2, 6), 90, 0, null),
			/obj/item/clothing/suit/radiation = TRADE_GOOD_DATA(null, list(2, 6), 200, 0, null),
			/obj/item/clothing/head/radiation = TRADE_GOOD_DATA(null, list(2, 6), 120, 0, null),
			/obj/item/clothing/suit/bio_suit = TRADE_GOOD_DATA(null, list(2, 6), 160, 0, null),
			/obj/item/clothing/head/bio_hood = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/clothing/mask/gas = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_air = TRADE_PACK_DATA(null, list(4, 10), 175, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_ammonia = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_argon = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_boron = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_carbon_dioxide = TRADE_PACK_DATA(null, list(2, 6), 500, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_chlorine = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_co = TRADE_PACK_DATA(null, list(4, 10), 175, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_deuterium = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_empty = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_helium = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_hydrogen = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_krypton = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_methane = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_methylbromide = TRADE_PACK_DATA(null, list(2, 6), 525, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_neon = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_nitrogen = TRADE_PACK_DATA(null, list(4, 10), 175, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_no = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_no2 = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_oxygen = TRADE_PACK_DATA(null, list(4, 10), 250, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_phoron = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_sleeping_agent = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_sulfurdioxide = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_tritium = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/atmospherics/canister_xenon = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/evacuation = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/atmospherics/fuel = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/atmospherics/inflatable = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/atmospherics/internals = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/atmospherics/phoron = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/atmospherics/rpd = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/atmospherics/scanner_module = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/atmospherics/voidsuit = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
		),
		"Engineering" = list(
			/obj/item/stock_parts/circuitboard/air_management/supermatter_core = TRADE_GOOD_DATA(null, list(1, 3), 400, 0, access_engine),
			/obj/item/stock_parts/circuitboard/tele_beacon = TRADE_GOOD_DATA(null, list(2, 6), 400, 0, access_engine),
			/obj/item/stock_parts/circuitboard/powermonitor = TRADE_GOOD_DATA(null, list(2, 6), 300, 0, access_engine),
			/obj/item/stock_parts/circuitboard/pacman = TRADE_GOOD_DATA(null, list(2, 6), 400, 0, access_engine),
			/obj/item/cell/super = TRADE_GOOD_DATA(null, list(2, 6), 240, 0, access_engine),
			/singleton/hierarchy/supply_pack/engineering/PA = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/engineering/circulator = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/engineering/collector = TRADE_PACK_DATA(null, list(4, 10), 120, null),
			/singleton/hierarchy/supply_pack/engineering/emitter = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/engineering/field_gen = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/engineering/pacman_parts = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/engineering/sing_gen = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/engineering/smbig = TRADE_PACK_DATA(null, list(1, 3), 6750, null),
			/singleton/hierarchy/supply_pack/engineering/smsmall = TRADE_PACK_DATA(null, list(1, 3), 1125, null),
			/singleton/hierarchy/supply_pack/engineering/super_pacman_parts = TRADE_PACK_DATA(null, list(2, 6), 825, null),
			/singleton/hierarchy/supply_pack/engineering/teg = TRADE_PACK_DATA(null, list(1, 3), 1125, null),
		),
		"Chemistry & Cartridges" = list(
			/singleton/hierarchy/supply_pack/dispenser_cartridges/boron = TRADE_PACK_DATA(null, list(2, 6), 600, null),
		),
	)
	hidden_inventory = list(
		"Atmospherics" = list(
			/obj/machinery/portable_atmospherics/powered/pump/filled = TRADE_GOOD_DATA(null, list(1, 3), 600, 0, access_atmospherics),
			/obj/machinery/portable_atmospherics/powered/scrubber = TRADE_GOOD_DATA(null, list(1, 3), 600, 0, access_atmospherics),
		),
	)
	offer_types = list(
		/obj/item/ore/phoron = TRADE_OFFER_DATA("Phoron ore", 180, 5),
		/obj/item/stack/material/uranium = TRADE_OFFER_DATA("Refined uranium (full stack)", 1800, 2),
		/obj/item/stack/material/glass/boron = TRADE_OFFER_DATA("Borosilicate glass (full stack)", 1100, 2),
	)

/datum/trade_station/xynergy
	tree_x = 86
	tree_y = 48
	icon_state = "search"
	overmap_color = "#66bb66"
	tree_label = "Xynergy"
	desc = "Xynergy field teams collect living specimens in the Locutus Sector. Their relay sells hydroponics, seeds, domestic and exotic fauna, and containment supplies while accepting captured fauna in stasis cages."
	uid = "fauna"
	name = "Xynergy Specimen Acquisition"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_COMMON
	stations_recommended = list("skrell")
	inventory = list(
		"Livestock & Fauna" = list(
			/obj/item/device/scanner/plant = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/material/minihoe = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/wirecutters/clippers = TRADE_GOOD_DATA(null, list(4, 10), 40, 0, null),
			/obj/item/reagent_containers/glass/bottle/eznutrient = TRADE_GOOD_DATA(null, list(4, 10), 80, 0, null),
			/obj/item/reagent_containers/glass/bottle/left4zed = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/reagent_containers/glass/bottle/robustharvest = TRADE_GOOD_DATA(null, list(4, 10), 100, 0, null),
			/obj/item/seeds/wheatseed = TRADE_GOOD_DATA("Wheat seeds", list(4, 10), 35, 0, null),
			/obj/item/seeds/tomatoseed = TRADE_GOOD_DATA("Tomato seeds", list(4, 10), 35, 0, null),
			/obj/item/seeds/potatoseed = TRADE_GOOD_DATA("Potato seeds", list(4, 10), 35, 0, null),
			/obj/item/seeds/appleseed = TRADE_GOOD_DATA("Apple seeds", list(4, 10), 40, 0, null),
			/obj/item/stack/material/cloth = TRADE_GOOD_DATA("Cotton cloth", list(4, 10), 120, 20, null),
			/obj/item/seeds/towermycelium = TRADE_GOOD_DATA("Tower-cap spores", list(4, 10), 60, 0, null),
			/obj/machinery/stasis_cage = TRADE_GOOD_DATA(null, list(2, 6), 240, 0, null),
			/obj/item/reagent_containers/food/snacks/monkeycube = TRADE_GOOD_DATA(null, list(4, 10), 80, 0, null),
			/obj/item/reagent_containers/food/snacks/liquidfood = TRADE_GOOD_DATA("Animal nutrient ration", list(4, 10), 60, 0, null),
			/obj/item/clothing/suit/bio_suit = TRADE_GOOD_DATA(null, list(2, 6), 160, 0, null),
			/obj/item/clothing/head/bio_hood = TRADE_GOOD_DATA(null, list(2, 6), 100, 0, null),
			/obj/item/reagent_containers/syringe = TRADE_GOOD_DATA(null, list(4, 10), 30, 0, null),
			/singleton/hierarchy/supply_pack/hydroponics/aquaculture = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/hydroponics/bee_keeper = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/hydroponics/exoticseeds = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/hydroponics/hydroponics = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/hydroponics/hydrotray = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/hydroponics/pottedplant = TRADE_PACK_DATA(null, list(4, 10), 120, null),
			/singleton/hierarchy/supply_pack/hydroponics/seeds = TRADE_PACK_DATA(null, list(4, 10), 180, null),
			/singleton/hierarchy/supply_pack/hydroponics/watertank = TRADE_PACK_DATA(null, list(4, 10), 120, null),
			/singleton/hierarchy/supply_pack/hydroponics/weedcontrol = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/livecargo/cat = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/livecargo/cat/floppa = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/livecargo/cat/maine_coon = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/livecargo/chicken = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/livecargo/corgi = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/livecargo/cow = TRADE_PACK_DATA(null, list(1, 3), 1200, null),
			/singleton/hierarchy/supply_pack/livecargo/farwa = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/livecargo/german = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/livecargo/goat = TRADE_PACK_DATA(null, list(1, 3), 1125, null),
			/singleton/hierarchy/supply_pack/livecargo/goose = TRADE_PACK_DATA(null, list(1, 3), 1125, null),
			/singleton/hierarchy/supply_pack/livecargo/monkey = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/livecargo/penguin = TRADE_PACK_DATA(null, list(1, 3), 1200, null),
			/singleton/hierarchy/supply_pack/livecargo/reindeer = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/livecargo/skrell = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/livecargo/stok = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/livecargo/turkey = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/science/stasiscage_crate = TRADE_PACK_DATA(null, list(4, 10), 300, null),
		),
	)
	hidden_inventory = list(
		"Livestock & Fauna" = list(
			/obj/item/seeds/ambrosiavulgarisseed = TRADE_GOOD_DATA("Ambrosia seeds", list(1, 3), 200, 0, null),
			/obj/item/seeds/nettleseed = TRADE_GOOD_DATA("Nettle seeds", list(1, 3), 180, 0, null),
			/obj/item/seeds/tobaccoseed = TRADE_GOOD_DATA("Tobacco seeds", list(1, 3), 150, 0, null),
			/obj/item/reagent_containers/food/snacks/egg = TRADE_GOOD_DATA("Chicken egg", list(2, 6), 60, 0, null),
		),
	)
	offer_types = list(
		/mob/living/simple_animal/hostile/carp = TRADE_OFFER_DATA("Live carp in a stasis cage", 750, 2),
		/obj/item/honey_frame = TRADE_OFFER_DATA("Filled honey frames", 50, 4),
		/obj/item/reagent_containers/food/snacks/grown = TRADE_OFFER_DATA("Fresh cultivated produce", 55, 5),
	)

/datum/trade_station/shellguard
	tree_x = 62
	tree_y = 50
	icon_state = "shield"
	overmap_color = "#cc5544"
	tree_label = "Shellguard"
	desc = "Shellguard Munitions and SCG defense contractors maintain a tactical logistics depot in the Locutus sector. Standard riot gear, forensic supplies, ammunition and ship munitions are available, with heavy weaponry released under elevated alert protocols."
	uid = "security"
	name = "Shellguard / SCG Defense Logistics"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_COMMON
	stations_recommended = list("morpheus", "skrell")
	inventory = list(
		"Security & Armory" = list(
			/obj/item/clothing/suit/armor/vest = TRADE_GOOD_DATA(null, list(2, 6), 360, 0, access_security),
			/obj/item/clothing/head/helmet = TRADE_GOOD_DATA(null, list(2, 6), 200, 0, access_security),
			/obj/item/handcuffs = TRADE_GOOD_DATA(null, list(4, 10), 60, 0, access_security),
			/obj/item/grenade/flashbang = TRADE_GOOD_DATA(null, list(2, 6), 160, 0, access_security),
			/obj/item/melee/baton/loaded = TRADE_GOOD_DATA(null, list(2, 6), 260, 0, access_security),
			/singleton/hierarchy/supply_pack/security/ablativearmor = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/security/armor = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/ballisticarmor = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/security/blackguards = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/blueguards = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/detectivegear = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/security/egun = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/security/flashbang = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/forensics = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/greenguards = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/ion = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/security/lightarmor = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/navyguards = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/riotarmor = TRADE_PACK_DATA(null, list(1, 3), 1200, null),
			/singleton/hierarchy/supply_pack/security/securitybarriers = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/securitybiosuit = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/shotgun = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/security/tacticalarmor = TRADE_PACK_DATA(null, list(2, 6), 675, null),
			/singleton/hierarchy/supply_pack/security/tanguards = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/tasers = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/teargas = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/voidsuit_security = TRADE_PACK_DATA(null, list(1, 3), 1800, null),
			/singleton/hierarchy/supply_pack/security/weapons = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/xenofauna = TRADE_PACK_DATA(null, list(2, 6), 600, null),
		),
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/shellguard = TRADE_GOOD_DATA(null, list(2, 4), 768, 0, access_security),
			/singleton/hierarchy/supply_pack/prosthesis/shellguard = TRADE_PACK_DATA(null, list(1, 3), 4200, null),
		),
		"Ammunition & Munitions" = list(
			/singleton/hierarchy/supply_pack/ammunition/p10_blank = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/p10_lethal = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/p10_ltl = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/p10_mag_heavy = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/p10_mag_light = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/p7_blank = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/p7_lethal = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/ammunition/p7_ltl = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/p7_mag_smg_top = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/r7_blank = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/ammunition/r7_heavy_mag = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/r7_lethal = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/r7_lethal_light = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/ammunition/r7_light_mag = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/sg12_blank = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/ammunition/sg12_lethal_shell = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/sg12_lethal_slug = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/sg12_ltl = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/ammunition/sg12_mag = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/munition/ap_slug = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/munition/emp = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/munition/explosive = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/munition/fire = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/munition/md_slug = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/munition/mining = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/munition/probes = TRADE_PACK_DATA(null, list(2, 6), 600, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Security & Armory" = list(
			/singleton/hierarchy/supply_pack/security/armory = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/security/armory/advancedlaser = TRADE_PACK_DATA(null, list(1, 3), 1650, null),
			/singleton/hierarchy/supply_pack/security/armory/c20a = TRADE_PACK_DATA(null, list(1, 3), 1050, null),
			/singleton/hierarchy/supply_pack/security/armory/laser = TRADE_PACK_DATA(null, list(1, 3), 1200, null),
			/singleton/hierarchy/supply_pack/security/armory/pdw = TRADE_PACK_DATA(null, list(1, 3), 1950, null),
			/singleton/hierarchy/supply_pack/security/holster = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/lightnanoarmor = TRADE_PACK_DATA(null, list(4, 10), 225, null),
			/singleton/hierarchy/supply_pack/security/nanoarmor = TRADE_PACK_DATA(null, list(2, 6), 375, null),
			/singleton/hierarchy/supply_pack/security/practicelasers = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/security/securityextragear = TRADE_PACK_DATA(null, list(2, 6), 900, null),
		),
		"Ammunition & Munitions" = list(
			/singleton/hierarchy/supply_pack/ammunition/p28_lethal = TRADE_PACK_DATA(null, list(4, 10), 300, null),
			/singleton/hierarchy/supply_pack/ammunition/p28_mag = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/p7_ap = TRADE_PACK_DATA(null, list(2, 6), 600, null),
			/singleton/hierarchy/supply_pack/ammunition/p7_mag_carbine = TRADE_PACK_DATA(null, list(4, 10), 150, null),
			/singleton/hierarchy/supply_pack/ammunition/sg12_manstopper_shell = TRADE_PACK_DATA(null, list(4, 10), 300, null),
		),
	)
#endif
	hidden_inventory = list(
		"Security & Armory" = list(
			/obj/item/clothing/glasses/hud/security/prot/sunglasses = TRADE_GOOD_DATA(null, list(1, 3), 240, 0, access_security),
			/obj/item/storage/belt/security = TRADE_GOOD_DATA(null, list(2, 5), 140, 0, access_security),
		),
	)
	offer_types = list(
		/obj/item/handcuffs/cable = TRADE_OFFER_DATA("Improvised cable restraints", 40, 5),
		/obj/item/device/assembly/signaler = TRADE_OFFER_DATA("Remote radio signalers", 65, 3),
		/obj/item/ammo_casing = TRADE_OFFER_DATA("Spent ammunition brass", 5, 5),
	)

/datum/trade_station/morpheus
	tree_x = 30
	tree_y = 18
	icon_state = "person"
	overmap_color = "#bb88ff"
	tree_label = "Morpheus"
	desc = "A Morpheus Cyberkinetics specialist serves frontier synthetics and prosthetic clinics. Trusted medical and technical partners can recommend this relay for neural interfaces, replacement organs and advanced augmentations."
	uid = "morpheus"
	name = "Morpheus Cyberkinetics Specialist Relay"
	spawn_chance = 100
	markup = TRADE_UNCOMMON
	recommendations_needed = 1
	inventory = list(
		"Prosthetics" = list(
			/obj/item/prosthetic_kit/frontier_trade/morpheus = TRADE_GOOD_DATA(null, list(1, 3), 514, 0, access_medical),
			/obj/item/prosthetic_kit/frontier_trade/morpheus_mantis = TRADE_GOOD_DATA(null, list(1, 3), 600, 0, access_medical),
			/obj/item/robot_parts/l_arm = TRADE_GOOD_DATA(null, list(1, 3), 180, 0, access_medical),
			/obj/item/robot_parts/r_arm = TRADE_GOOD_DATA(null, list(1, 3), 180, 0, access_medical),
			/obj/item/robot_parts/l_leg = TRADE_GOOD_DATA(null, list(1, 3), 180, 0, access_medical),
			/obj/item/robot_parts/r_leg = TRADE_GOOD_DATA(null, list(1, 3), 180, 0, access_medical),
			/obj/item/organ/internal/heart/frontier_trade = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, access_medical),
			/obj/item/organ/internal/lungs/frontier_trade = TRADE_GOOD_DATA(null, list(1, 3), 450, 0, access_medical),
			/obj/item/organ/internal/liver/frontier_trade = TRADE_GOOD_DATA(null, list(1, 3), 450, 0, access_medical),
			/obj/item/organ/internal/eyes/robot = TRADE_GOOD_DATA(null, list(1, 3), 400, 0, access_medical),
			/obj/item/organ/internal/augment/active/hud/health = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, access_medical),
			/singleton/hierarchy/supply_pack/prosthesis/morpheus = TRADE_PACK_DATA(null, list(1, 3), 3000, null),
			/singleton/hierarchy/supply_pack/prosthesis/morpheus_mantis = TRADE_PACK_DATA(null, list(1, 3), 3600, null),
		),
		"Science & Robotics" = list(
			/obj/item/device/mmi = TRADE_GOOD_DATA(null, list(1, 3), 480, 0, null),
			/obj/item/organ/internal/posibrain = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, null),
			/obj/item/stack/nanopaste = TRADE_GOOD_DATA("Nanopaste", list(1, 3), 240, 10, null),
		),
	)
	hidden_inventory = list(
		"Prosthetics" = list(
			/obj/item/organ/internal/augment/armor = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, access_medical),
			/obj/item/organ/internal/augment/active/polytool/engineer = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, access_medical),
			/obj/item/organ/internal/augment/active/polytool/surgical = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, access_medical),
		),
	)
	offer_types = list(
		/obj/item/stock_parts/computer/hard_drive/advanced = TRADE_OFFER_DATA("Advanced storage drives", 160, 2),
		/obj/item/organ/internal/posibrain = TRADE_OFFER_DATA("Positronic brain cores", 650, 1),
	)

/datum/trade_station/skrell
	tree_x = 70
	tree_y = 18
	icon_state = "star"
	overmap_color = "#6699ff"
	tree_label = "Skrell"
	desc = "A Skrellian frontier outpost monitors the border of unexplored Locutus space. Its quartermasters exchange specialized exploration equipment for unusual crystal samples and value introductions from partner relays."
	uid = "skrell"
	name = "Skrellian Frontier Outpost"
	spawn_chance = 100
	markup = TRADE_RARE
	recommendations_needed = 1
	inventory = list(
		"Science & Robotics" = list(
			/obj/item/clothing/suit/space/void/skrell = TRADE_GOOD_DATA(null, list(1, 3), 1000, 0, null),
			/obj/item/clothing/head/helmet/space/void/skrell = TRADE_GOOD_DATA(null, list(1, 3), 800, 0, null),
			/obj/item/device/gps = TRADE_GOOD_DATA(null, list(1, 3), 120, 0, null),
			/obj/item/device/gps/marker = TRADE_GOOD_DATA(null, list(1, 3), 100, 0, null),
			/obj/item/stock_parts/circuitboard/tele_beacon = TRADE_GOOD_DATA(null, list(1, 3), 600, 0, null),
			/obj/item/bluespace_crystal = TRADE_GOOD_DATA(null, list(1, 3), 400, 0, null),
			/obj/item/cell/skrell = TRADE_GOOD_DATA(null, list(1, 3), 300, 0, null),
			/obj/item/solar_assembly = TRADE_GOOD_DATA(null, list(1, 3), 120, 0, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Science & Robotics" = list(
			/obj/item/clothing/suit/space/void/exploration = TRADE_GOOD_DATA(null, list(1, 3), 1000, 0, null),
			/obj/item/clothing/head/helmet/space/void/exploration = TRADE_GOOD_DATA(null, list(1, 3), 700, 0, null),
		),
	)
#endif
	hidden_inventory = list(
		"Science & Robotics" = list(
			/obj/item/stock_parts/subspace/transmitter = TRADE_GOOD_DATA(null, list(1, 3), 500, 0, null),
			/obj/item/fossil/bone = TRADE_GOOD_DATA("Ancient fauna fossil", list(1, 3), 240, 0, null),
			/obj/item/gun/energy/laser = TRADE_GOOD_DATA(null, list(1, 3), 1800, 0, null),
		),
	)
	offer_types = list(
		/obj/item/ore/diamond = TRADE_OFFER_DATA("Anomalous crystal samples", 260, 3),
		/obj/item/fossil/bone = TRADE_OFFER_DATA("Excavated fauna fossils", 180, 2),
	)

/datum/trade_station/smugglers
	tree_x = 50
	tree_y = 8
	icon_state = "locked"
	overmap_color = "#ff5566"
	tree_label = "Two Hands"
	desc = "An unregistered freeport broker trading under the Two Hands name. Legitimate terminals filter out its encrypted transponder; a compromised trade terminal is required to access its black-market catalog."
	uid = "smugglers"
	name = "Frontier Freeport / Two Hands Broker"
	spawn_chance = 100
	start_discovered = TRUE
	markup = TRADE_RARE
	black_market = TRUE
	inventory = list(
		"Contraband" = list(
			/obj/item/gun/projectile/pistol = TRADE_GOOD_DATA(null, list(1, 3), 1000, 0, null),
			/obj/item/ammo_magazine/pistol = TRADE_GOOD_DATA(null, list(2, 5), 120, 0, null),
			/obj/item/gun/projectile/shotgun/pump/sawn = TRADE_GOOD_DATA(null, list(1, 3), 1000, 0, null),
			/obj/item/ammobox/shotgun = TRADE_GOOD_DATA(null, list(2, 5), 150, 0, null),
			/obj/item/material/knife/combat = TRADE_GOOD_DATA(null, list(1, 3), 180, 0, null),
			/obj/item/card/emag = TRADE_GOOD_DATA(null, list(1, 3), 900, 0, null),
			/obj/item/weapon/finger_lockpick = TRADE_GOOD_DATA(null, list(1, 3), 450, 0, null),
			/obj/item/device/radio/spy = TRADE_GOOD_DATA(null, list(1, 3), 300, 0, null),
			/obj/item/reagent_containers/hypospray/autoinjector/combatstim = TRADE_GOOD_DATA(null, list(1, 3), 450, 0, null),
			/singleton/hierarchy/supply_pack/galley/donkpocket_premium = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/livecargo/bear = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/livecargo/drones = TRADE_PACK_DATA(null, list(2, 6), 900, null),
			/singleton/hierarchy/supply_pack/livecargo/lion = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/livecargo/panter = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
			/singleton/hierarchy/supply_pack/livecargo/spidercubes = TRADE_PACK_DATA(null, list(2, 6), 750, null),
			/singleton/hierarchy/supply_pack/operations/contraband = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/egun/shady = TRADE_PACK_DATA(null, list(1, 3), 1200, null),
			/singleton/hierarchy/supply_pack/security/specialops = TRADE_PACK_DATA(null, list(2, 6), 600, null),
		),
	)
#ifdef SIERRA_MAP
	sierra_inventory = list(
		"Contraband" = list(
			/singleton/hierarchy/supply_pack/ammunition/sg12_dragon_shell = TRADE_PACK_DATA(null, list(2, 6), 450, null),
			/singleton/hierarchy/supply_pack/security/armory/laser/shady = TRADE_PACK_DATA(null, list(1, 3), 1500, null),
		),
	)
#endif
	hidden_inventory = list(
		"Contraband" = list(
			/obj/item/gun/energy/laser = TRADE_GOOD_DATA(null, list(1, 3), 1800, 0, null),
			/obj/item/clothing/glasses/thermal/syndi = TRADE_GOOD_DATA(null, list(1, 3), 1400, 0, null),
			/obj/item/grenade/empgrenade = TRADE_GOOD_DATA(null, list(1, 3), 300, 0, null),
		),
	)
	offer_types = list(
		/obj/item/gun/projectile/pistol = TRADE_OFFER_MODS("Pistol with an installed suppressor", 150, 2, list(/obj/item/silencer), 1),
		/obj/item/gun/energy/laser = TRADE_OFFER_DATA("Unregistered laser weapons", 50, 2),
	)

#undef TRADE_GOOD_DATA
#undef TRADE_OFFER_DATA
#undef TRADE_OFFER_MODS
#undef TRADE_MINERAL_OFFER
/datum/trade_station/hephaestus/setup()
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/supply/fueltank, /singleton/hierarchy/supply_pack/engineering/fueltank)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/supply/watertank, /singleton/hierarchy/supply_pack/hydroponics/watertank)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/supply/coolanttank, /singleton/hierarchy/supply_pack/science/coolanttank)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/custodial/bodybag, /singleton/hierarchy/supply_pack/medical/bodybag)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/operations/voidsuit_engineering, /singleton/hierarchy/supply_pack/engineering/voidsuit_engineering)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/operations/voidsuit_security, /singleton/hierarchy/supply_pack/security/voidsuit_security)
#ifdef SIERRA_MAP
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/medical/nanoblood, /singleton/hierarchy/supply_pack/medical/blood)
#endif
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/hephaestus/single, /obj/item/prosthetic_kit/frontier_trade/hephaestus)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/hephaestus_titan/single, /obj/item/prosthetic_kit/frontier_trade/hephaestus_titan)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/morpheus/single, /obj/item/prosthetic_kit/frontier_trade/morpheus)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/morpheus_mantis/single, /obj/item/prosthetic_kit/frontier_trade/morpheus_mantis)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/nanotrasen/single, /obj/item/prosthetic_kit/frontier_trade/nanotrasen)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/resomi/single, /obj/item/prosthetic_kit/frontier_trade/resomi)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/shellguard/single, /obj/item/prosthetic_kit/frontier_trade/shellguard)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi/single, /obj/item/prosthetic_kit/frontier_trade/wardtakahashi)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi_econ/single, /obj/item/prosthetic_kit/frontier_trade/wardtakahashi_econ)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/xion/single, /obj/item/prosthetic_kit/frontier_trade/xion)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/xion_econ/single, /obj/item/prosthetic_kit/frontier_trade/xion_econ)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/zenghu/single, /obj/item/prosthetic_kit/frontier_trade/zenghu)
	SStrade.register_pack_alias(/singleton/hierarchy/supply_pack/prosthesis/zenghu_spirit/single, /obj/item/prosthetic_kit/frontier_trade/zenghu_spirit)
	return ..()

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

// Branded single-part prosthetic kits matching PR #4994 manufacturers.
/obj/item/prosthetic_kit/frontier_trade
	name = "prosthetic kit"
	desc = "A sealed requisition case. Use it in hand to unpack a single prosthetic part."

/obj/item/prosthetic_kit/frontier_trade/nanotrasen
	name = "NanoTrasen prosthetic kit"
	desc = "A sealed requisition case from NanoTrasen. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "NanoTrasen"

/obj/item/prosthetic_kit/frontier_trade/xion_econ
	name = "Xion Econ prosthetic kit"
	desc = "A sealed requisition case from Xion Econ. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Xion Econ"

/obj/item/prosthetic_kit/frontier_trade/wardtakahashi_econ
	name = "Ward-Takahashi Econ. prosthetic kit"
	desc = "A sealed requisition case from Ward-Takahashi Econ. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Ward-Takahashi Econ."

/obj/item/prosthetic_kit/frontier_trade/xion
	name = "Xion prosthetic kit"
	desc = "A sealed requisition case from Xion. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Xion"

/obj/item/prosthetic_kit/frontier_trade/wardtakahashi
	name = "Ward-Takahashi prosthetic kit"
	desc = "A sealed requisition case from Ward-Takahashi. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Ward-Takahashi"

/obj/item/prosthetic_kit/frontier_trade/morpheus
	name = "Morpheus prosthetic kit"
	desc = "A sealed requisition case from Morpheus. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Morpheus"

/obj/item/prosthetic_kit/frontier_trade/morpheus_mantis
	name = "Morpheus Mantis prosthetic kit"
	desc = "A sealed requisition case from Morpheus Mantis. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Morpheus Mantis"

/obj/item/prosthetic_kit/frontier_trade/hephaestus
	name = "Hephaestus Industries prosthetic kit"
	desc = "A sealed requisition case from Hephaestus Industries. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Hephaestus Industries"

/obj/item/prosthetic_kit/frontier_trade/shellguard
	name = "Shellguard prosthetic kit"
	desc = "A sealed requisition case from Shellguard. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Shellguard"

/obj/item/prosthetic_kit/frontier_trade/zenghu
	name = "Zeng-Hu prosthetic kit"
	desc = "A sealed requisition case from Zeng-Hu. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Zeng-Hu"

/obj/item/prosthetic_kit/frontier_trade/zenghu_spirit
	name = "Zeng-Hu Spirit prosthetic kit"
	desc = "A sealed requisition case from Zeng-Hu Spirit. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Zeng-Hu Spirit"

/obj/item/prosthetic_kit/frontier_trade/hephaestus_titan
	name = "Hephaestus Titan prosthetic kit"
	desc = "A sealed requisition case from Hephaestus Titan. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Hephaestus Titan"

/obj/item/prosthetic_kit/frontier_trade/resomi
	name = "Small prosthetic kit"
	desc = "A sealed requisition case from Small prosthetic. Use it in hand to unpack a single prosthetic part of that brand."
	manufacturer = "Small prosthetic"

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
