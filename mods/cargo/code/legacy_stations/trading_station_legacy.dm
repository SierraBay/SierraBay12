/datum/trading_station/legacy
	faction = FACTION_INDEPENDENT
	spawn_always = FALSE
	spawn_probability = 0
	markup = 1.2
	start_hidden = FALSE
	legacy_station_group_type = null

/datum/trading_station/legacy/operations
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/operations
	name_pool = list(
		"FTB \"Quartermaster\"" = "Free Trade Beacon \"Quartermaster\": tools, mining gear, office stock, and surplus cargo essentials.",
		"FTB \"Longhaul\"" = "Free Trade Beacon \"Longhaul\": practical freight and expedition logistics.",
		"FTB \"Crossroads\"" = "Free Trade Beacon \"Crossroads\": regional transit depot for supply exchange and freight dispatch.",
		"FTB \"Waypoint Nine\"" = "Free Trade Beacon \"Waypoint Nine\": automated waystation for mining crews and long-range haulers.",
		"FTB \"Cargo Core\"" = "Free Trade Beacon \"Cargo Core\": bulk crating facility handling standard supply manifests."
	)
	uid = "legacy_operations"
	icon_states = list("operations")
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/operations,
		/singleton/hierarchy/supply_pack/supply,
		/singleton/hierarchy/supply_pack/livecargo
	)

/datum/trading_station/legacy/engineering
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/engineering
	name_pool = list(
		"FTB \"Arc Weld\"" = "Free Trade Beacon \"Arc Weld\": engineering machinery, floor stock, and field repairs.",
		"FTB \"Gridline\"" = "Free Trade Beacon \"Gridline\": power and construction stock for hard jobs.",
		"FTB \"Dyno Relay\"" = "Free Trade Beacon \"Dyno Relay\": substation equipment, electrical components, and heavy wiring.",
		"FTB \"Conduit Point\"" = "Free Trade Beacon \"Conduit Point\": industrial pipeline fittings and machinery surplus.",
		"FTB \"Scaffold\"" = "Free Trade Beacon \"Scaffold\": modular structural frames, floor plating, and maintenance supplies."
	)
	uid = "legacy_engineering"
	icon_states = list("engineering")
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/engineering,
		/singleton/hierarchy/supply_pack/flooring
	)

/datum/trading_station/legacy/atmospherics
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/atmospherics
	name_pool = list(
		"FTB \"Blue Lung\"" = "Free Trade Beacon \"Blue Lung\": atmospherics gear, tanks, canisters, and emergency response stock.",
		"FTB \"Zephyr\"" = "Free Trade Beacon \"Zephyr\": pure breathing gas supplies and pressurized canister distribution.",
		"FTB \"Vortex Tank\"" = "Free Trade Beacon \"Vortex Tank\": atmospheric pump manifolds and high-pressure canister exchange.",
		"FTB \"Aero Hub\"" = "Free Trade Beacon \"Aero Hub\": life support gas filtration and environmental emergency units."
	)
	uid = "legacy_atmospherics"
	icon_states = list("atmospherics")
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/atmospherics)

/datum/trading_station/legacy/materials
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/materials
	name_pool = list(
		"FTB \"Bulkhead\"" = "Free Trade Beacon \"Bulkhead\": sheet goods, wood, and industrial construction materials.",
		"FTB \"Bauxite Drift\"" = "Free Trade Beacon \"Bauxite Drift\": industrial ores, raw smelting feed, and composite polymers.",
		"FTB \"Ferrous Gate\"" = "Free Trade Beacon \"Ferrous Gate\": reinforced metallic sheeting and construction grade ingots.",
		"FTB \"Bedrock\"" = "Free Trade Beacon \"Bedrock\": heavy planetary mining yields and raw foundational materials."
	)
	uid = "legacy_materials"
	icon_states = list("materials")
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/materials)

/datum/trading_station/legacy/security
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/security
	name_pool = list(
		"TTB \"Bulwark\"" = "Terran Trade Beacon \"Bulwark\": armor, security tools, and authorized weapons stock.",
		"TTB \"Hoplon\"" = "Terran Trade Beacon \"Hoplon\": heavy personal protection gear and defensive riot control surplus.",
		"TTB \"Redoubt\"" = "Terran Trade Beacon \"Redoubt\": fortified outpost offering defensive armaments and tactical equipment.",
		"TTB \"Iron Sentry\"" = "Terran Trade Beacon \"Iron Sentry\": planetary defense auxiliary cache providing authorized security stock."
	)
	uid = "legacy_security"
	icon_states = list("weapons")
	faction = FACTION_INDIE_CONFED
	markup = 1.3
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/security,
		/singleton/hierarchy/supply_pack/ammunition
	)

/datum/trading_station/legacy/medicine
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/medicine
	name_pool = list(
		"FTB \"Trauma Bay\"" = "Free Trade Beacon \"Trauma Bay\": medical replenishment, triage stock, and dispenser cartridges.",
		"FTB \"Caduceus\"" = "Free Trade Beacon \"Caduceus\": pharmaceutical restock and field medical emergency trauma kits.",
		"FTB \"Panacea\"" = "Free Trade Beacon \"Panacea\": chemical synthesizer supplies and surgical dispensary cart packages.",
		"FTB \"Bio-Pulse\"" = "Free Trade Beacon \"Bio-Pulse\": biological diagnostic aids and clinical replenishment goods."
	)
	uid = "legacy_medicine"
	icon_states = list("medical")
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/medical,
		/singleton/hierarchy/supply_pack/dispenser_cartridges
	)

/datum/trading_station/legacy/science
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/science
	name_pool = list(
		"FTB \"Peer Review\"" = "Free Trade Beacon \"Peer Review\": research consumables, lab gear, and anomaly support stock.",
		"FTB \"Synapse\"" = "Free Trade Beacon \"Synapse\": advanced sensor probes, data storage media, and circuit fabrication feed.",
		"FTB \"Observatory Six\"" = "Free Trade Beacon \"Observatory Six\": astronomical surveying packages and high-energy physics supplies.",
		"FTB \"Collider\"" = "Free Trade Beacon \"Collider\": research grade apparatus, laser diodes, and laboratory test cartridges."
	)
	uid = "legacy_science"
	icon_states = list("science")
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/science)

/datum/trading_station/legacy/service
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/service
	name_pool = list(
		"FTB \"Mess Hall\"" = "Free Trade Beacon \"Mess Hall\": hydroponics, galley supplies, and janitorial support.",
		"FTB \"Pantry Post\"" = "Free Trade Beacon \"Pantry Post\": nutritional staples, food processing packs, and mess supplies.",
		"FTB \"Cornucopia\"" = "Free Trade Beacon \"Cornucopia\": hydroponic seeds, nutrient canisters, and botanical gardening tools.",
		"FTB \"Hydro-Haven\"" = "Free Trade Beacon \"Hydro-Haven\": agricultural supplies, cleaning agents, and station service essentials."
	)
	uid = "legacy_service"
	icon_states = list("service")
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/hydroponics,
		/singleton/hierarchy/supply_pack/galley,
		/singleton/hierarchy/supply_pack/custodial
	)

/datum/trading_station/legacy/civilian
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/civilian
	name_pool = list(
		"FTB \"Wardrobe\"" = "Free Trade Beacon \"Wardrobe\": leisure goods, uniforms, and non-essential comforts.",
		"FTB \"Bazaar\"" = "Free Trade Beacon \"Bazaar\": merchant goods, passenger clothing, and civilian trade items.",
		"FTB \"Comfort Line\"" = "Free Trade Beacon \"Comfort Line\": off-duty apparel, comfort accessories, and leisure supplies.",
		"FTB \"Mercantile\"" = "Free Trade Beacon \"Mercantile\": recreational wares, uniform replacements, and general civilian comforts."
	)
	uid = "legacy_civilian"
	icon_states = list("trade")
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/nonessent,
		/singleton/hierarchy/supply_pack/clothes_uniforms
	)

/datum/trading_station/legacy/munitions
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/munitions
	name_pool = list(
		"TTB \"Palisade\"" = "Terran Trade Beacon \"Palisade\": heavy ordnance, munitions, and battlefield support cargo.",
		"TTB \"Armory VII\"" = "Terran Trade Beacon \"Armory VII\": military-spec ballistic ammunition and tactical warhead reserves.",
		"TTB \"Siege Works\"" = "Terran Trade Beacon \"Siege Works\": defensive artillery ammunition and high-yield munitions crates.",
		"TTB \"High Caliber\"" = "Terran Trade Beacon \"High Caliber\": combat ordnance, heavy cartridge magazines, and weapon caches."
	)
	uid = "legacy_munitions"
	icon_states = list("munitions")
	faction = FACTION_INDIE_CONFED
	markup = 1.35
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/munition)
