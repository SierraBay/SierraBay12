/datum/legacy_station_group
	var/uid = null
	var/display_name = null
	var/list/root_categories = list()

/datum/legacy_station_group/operations
	uid = "legacy_operations"
	display_name = "Legacy Operations"
	root_categories = list(
		/singleton/hierarchy/supply_pack/operations,
		/singleton/hierarchy/supply_pack/supply,
		/singleton/hierarchy/supply_pack/livecargo
	)

/datum/legacy_station_group/engineering
	uid = "legacy_engineering"
	display_name = "Legacy Engineering"
	root_categories = list(
		/singleton/hierarchy/supply_pack/engineering,
		/singleton/hierarchy/supply_pack/flooring
	)

/datum/legacy_station_group/atmospherics
	uid = "legacy_atmospherics"
	display_name = "Legacy Atmospherics"
	root_categories = list(/singleton/hierarchy/supply_pack/atmospherics)

/datum/legacy_station_group/materials
	uid = "legacy_materials"
	display_name = "Legacy Materials"
	root_categories = list(/singleton/hierarchy/supply_pack/materials)

/datum/legacy_station_group/security
	uid = "legacy_security"
	display_name = "Legacy Security"
	root_categories = list(
		/singleton/hierarchy/supply_pack/security,
		/singleton/hierarchy/supply_pack/ammunition
	)

/datum/legacy_station_group/medicine
	uid = "legacy_medicine"
	display_name = "Legacy Medicine"
	root_categories = list(
		/singleton/hierarchy/supply_pack/medical,
		/singleton/hierarchy/supply_pack/dispenser_cartridges
	)

/datum/legacy_station_group/science
	uid = "legacy_science"
	display_name = "Legacy Science"
	root_categories = list(/singleton/hierarchy/supply_pack/science)

/datum/legacy_station_group/service
	uid = "legacy_service"
	display_name = "Legacy Service"
	root_categories = list(
		/singleton/hierarchy/supply_pack/hydroponics,
		/singleton/hierarchy/supply_pack/galley,
		/singleton/hierarchy/supply_pack/custodial
	)

/datum/legacy_station_group/civilian
	uid = "legacy_civilian"
	display_name = "Legacy Civilian"
	root_categories = list(
		/singleton/hierarchy/supply_pack/nonessent,
		/singleton/hierarchy/supply_pack/clothes_uniforms
	)

/datum/legacy_station_group/munitions
	uid = "legacy_munitions"
	display_name = "Legacy Munitions"
	root_categories = list(/singleton/hierarchy/supply_pack/munition)
