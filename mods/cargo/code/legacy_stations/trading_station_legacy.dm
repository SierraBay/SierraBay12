/datum/trading_station/legacy
	faction = FACTION_INDEPENDENT
	spawn_always = FALSE
	markup = 1.2
	start_hidden = FALSE
	var/legacy_station_group_type = null

/datum/trading_station/legacy/operations
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/operations
	name_pool = list(
		"FTB \"Quartermaster\"" = "Free Trade Beacon \"Quartermaster\": tools, mining gear, office stock, and surplus cargo essentials.",
		"FTB \"Longhaul\"" = "Free Trade Beacon \"Longhaul\": practical freight and expedition logistics."
	)
	uid = "legacy_operations"
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
		"FTB \"Gridline\"" = "Free Trade Beacon \"Gridline\": power and construction stock for hard jobs."
	)
	uid = "legacy_engineering"
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/engineering,
		/singleton/hierarchy/supply_pack/flooring
	)

/datum/trading_station/legacy/atmospherics
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/atmospherics
	name_pool = list(
		"FTB \"Blue Lung\"" = "Free Trade Beacon \"Blue Lung\": atmospherics gear, tanks, canisters, and emergency response stock."
	)
	uid = "legacy_atmospherics"
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/atmospherics)

/datum/trading_station/legacy/materials
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/materials
	name_pool = list(
		"FTB \"Bulkhead\"" = "Free Trade Beacon \"Bulkhead\": sheet goods, wood, and industrial construction materials."
	)
	uid = "legacy_materials"
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/materials)

/datum/trading_station/legacy/security
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/security
	name_pool = list(
		"TTB \"Bulwark\"" = "Terran Trade Beacon \"Bulwark\": armor, security tools, and authorized weapons stock."
	)
	uid = "legacy_security"
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
		"FTB \"Trauma Bay\"" = "Free Trade Beacon \"Trauma Bay\": medical replenishment, triage stock, and dispenser cartridges."
	)
	uid = "legacy_medicine"
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/medical,
		/singleton/hierarchy/supply_pack/dispenser_cartridges
	)

/datum/trading_station/legacy/science
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/science
	name_pool = list(
		"FTB \"Peer Review\"" = "Free Trade Beacon \"Peer Review\": research consumables, lab gear, and anomaly support stock."
	)
	uid = "legacy_science"
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/science)

/datum/trading_station/legacy/service
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/service
	name_pool = list(
		"FTB \"Mess Hall\"" = "Free Trade Beacon \"Mess Hall\": hydroponics, galley supplies, and janitorial support."
	)
	uid = "legacy_service"
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/hydroponics,
		/singleton/hierarchy/supply_pack/galley,
		/singleton/hierarchy/supply_pack/custodial
	)

/datum/trading_station/legacy/civilian
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/civilian
	name_pool = list(
		"FTB \"Wardrobe\"" = "Free Trade Beacon \"Wardrobe\": leisure goods, uniforms, and non-essential comforts."
	)
	uid = "legacy_civilian"
	legacy_supply_roots = list(
		/singleton/hierarchy/supply_pack/nonessent,
		/singleton/hierarchy/supply_pack/clothes_uniforms
	)

/datum/trading_station/legacy/munitions
	spawn_always = TRUE
	legacy_station_group_type = /datum/legacy_station_group/munitions
	name_pool = list(
		"TTB \"Palisade\"" = "Terran Trade Beacon \"Palisade\": heavy ordnance, munitions, and battlefield support cargo."
	)
	uid = "legacy_munitions"
	faction = FACTION_INDIE_CONFED
	markup = 1.35
	legacy_supply_roots = list(/singleton/hierarchy/supply_pack/munition)
