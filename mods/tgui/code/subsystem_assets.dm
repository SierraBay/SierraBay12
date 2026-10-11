SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = SS_INIT_ASSETS
	flags = SS_NO_FIRE
	var/list/datum/asset_cache_item/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Initialize(timeofday)
	load_assets()
	apply_configuration()

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload
	qdel(transport)
	transport = SSassets.transport

/datum/controller/subsystem/assets/proc/apply_configuration()
	var/newtransporttype = /datum/asset_transport
	if(config.asset_transport == "webroot")
		newtransporttype = /datum/asset_transport/webroot

	if(newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype
	if(newtransport.validate_config())
		qdel(transport)
		transport = newtransport
	else
		qdel(newtransport)

	transport.Initialize(cache)

/datum/controller/subsystem/assets/proc/load_assets()
	for(var/datum/asset/asset_type as anything in typesof(/datum/asset))
		if(asset_type == initial(asset_type._abstract))
			continue

		get_asset_datum(asset_type)

	transport.Initialize(cache)
