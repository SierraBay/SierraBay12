SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = SS_INIT_ASSETS
	flags = SS_NO_FIRE
	var/list/datum/asset_cache_item/cache = list()
	var/list/preload = list()
	/// Only the explicit connection manifest, keyed by compiled resource identity (not basename).
	/// Rebuilt on world restart; mutable paths and generated assets are not cached here.
	var/list/client_resources = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Initialize(timeofday)
	load_assets()
	apply_configuration()
	prepare_client_resources()
	transport.preload = cache.Copy()
	log_debug("Asset transport active: [transport.type] (requested: [config.asset_transport])")

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload
	client_resources = SSassets.client_resources
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

/datum/controller/subsystem/assets/proc/prepare_client_resources()
	for(var/resource in client_resource_files() + changelog_resource_files())
		var/resource_path = "[resource]"
		if(client_resources[resource])
			continue
		var/source = resource
		var/replacement = "mods/tgui/resources/[resource_path]"
		if(copytext(resource_path, 1, 6) == "html/" && fexists(replacement))
			resource = fcopy_rsc(replacement)
		var/asset_name = copytext(resource_path, findlasttext(resource_path, "/") + 1)
		client_resources[source] = register_asset(asset_name, resource)

/datum/controller/subsystem/assets/proc/load_assets()
	for(var/datum/asset/asset_type as anything in typesof(/datum/asset))
		if(asset_type == initial(asset_type._abstract))
			continue

		get_asset_datum(asset_type)

	transport.Initialize(cache)
