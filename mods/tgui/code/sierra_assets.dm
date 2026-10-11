/// Compatibility entry points delegate to the single donor cache and transport.
/proc/register_asset(asset_name, asset)
	var/datum/asset_cache_item/item = SSassets.transport.register_asset(asset_name, asset)
	item.legacy = TRUE
	item.keep_local_name = TRUE
	return item

/proc/send_asset(client/client, asset_name, verify = TRUE, check_cache = TRUE)
	if(!check_cache)
		if(ismob(client))
			var/mob/user = client
			client = user.client
		if(isclient(client))
			var/datum/asset_cache_item/item = SSassets.cache[asset_name]
			if(item)
				// sent_assets uses browse_rsc filenames even with a CDN transport.
				var/keep_local_name = SSassets.transport.dont_mutate_filenames \
					|| item.legacy \
					|| item.keep_local_name \
					|| (item.namespace && !item.namespace_parent)
				var/local_name = keep_local_name ? asset_name : "asset.[item.hash][item.ext]"
				client.sent_assets -= local_name
	return send_asset_list(client, list(asset_name), verify)

/proc/send_asset_list(client/client, list/asset_list, verify = TRUE)
	if(ismob(client))
		var/mob/user = client
		client = user.client
	if(!isclient(client))
		return FALSE
	. = SSassets.transport.send_assets(client, asset_list)
	if(. && verify)
		client.browse_queue_flush()

/proc/getFilesSlow(client/client, list/files, register_asset = TRUE)
	if(register_asset)
		for(var/name in files)
			register_asset(name, files[name])
	SSassets.transport.send_assets_slow(client, files)

/// Preserve the existing chat's fixed JS/CSS filenames through the donor transport.
/datum/asset/simple/jquery
	legacy = TRUE
	keep_local_name = TRUE
	assets = list("jquery.min.js" = 'code/modules/goonchat/browserassets/js/jquery.min.js')

/datum/asset/simple/goonchat
	legacy = TRUE
	keep_local_name = TRUE
	assets = list(
		"json2.min.js" = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js" = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"browserOutput.css" = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css" = 'code/modules/goonchat/browserassets/css/browserOutput_white.css'
	)

/datum/asset/group/goonchat
	children = list(/datum/asset/simple/jquery, /datum/asset/simple/goonchat, /datum/asset/simple/namespaced/fontawesome)

/datum/asset/simple/fontawesome
	parent_type = /datum/asset/simple/namespaced/fontawesome
	_abstract = /datum/asset/simple/fontawesome

/datum/asset/nanoui
	parent_type = /datum/asset/group
	children = list(/datum/asset/simple/nanoui_common, /datum/asset/simple/nanoui_templates, /datum/asset/simple/sierra_designs)

/datum/asset/nanoui/send(client, uncommon)
	var/datum/asset/simple/common = get_asset_datum(/datum/asset/simple/nanoui_common)
	var/datum/asset/simple/templates = get_asset_datum(/datum/asset/simple/nanoui_templates)
	var/datum/asset/simple/designs = get_asset_datum(/datum/asset/simple/sierra_designs)
	if(length(uncommon))
		if(!islist(uncommon))
			uncommon = list(uncommon)
		SSassets.transport.send_assets(client, uncommon)
	common.send(client)
	templates.send(client)
	designs.send(client)

/datum/asset/simple/sierra_designs
	legacy = TRUE
	keep_local_name = TRUE

/// Map-only mappings avoid loading NanoUI's libraries into native TGUI pages.
/datum/asset/simple/nanomaps
	legacy = TRUE
	keep_local_name = TRUE

/datum/asset/simple/nanomaps/register()
	for(var/z in GLOB.using_map.map_levels)
		var/filename = map_image_file_name(z)
		var/file_path = "[MAP_IMAGE_PATH][filename]"
		if(fexists(file_path))
			assets[filename] = fcopy_rsc(file_path)
	return ..()

/datum/asset/simple/sierra_designs/register()
	for(var/datum/design/design as anything in SSresearch.all_designs)
		var/atom/item = design.build_path
		var/icon_file = initial(item.icon)
		var/icon_state = initial(item.icon_state)
		if(ispath(item, /obj/item/reagent_containers/food/drinks/glass2))
			var/obj/item/reagent_containers/food/drinks/glass2/glass = item
			icon_state = initial(glass.base_icon)
		var/filename = sanitizeFileName("[design.build_path].png")
		assets[filename] = icon(icon_file || "", icon_state, SOUTH)
		design.ui_data["icon"] = filename
	return ..()

