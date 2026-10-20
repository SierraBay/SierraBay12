/datum/unit_test/tgui_assets
	name = "TGUI: shared asset cache, frontend bundles and legacy consumers"

/datum/asset_transport/tgui_test
	var/invalid_asset_names = 0
	var/send_batches = 0

/datum/asset_transport/tgui_test/send_assets(client/client, list/asset_list)
	send_batches++
	for(var/asset_name in asset_list)
		if(!istext(asset_name) || !length(asset_name))
			invalid_asset_names++
	return FALSE

/datum/unit_test/tgui_assets/start_test()
	var/datum/asset/simple/tgui/frontend = get_asset_datum(/datum/asset/simple/tgui)
	var/list/mappings = frontend.get_url_mappings()
	for(var/asset_name in list("tgui.bundle.js", "tgui.bundle.css"))
		var/datum/asset_cache_item/item = SSassets.cache[asset_name]
		if(!item?.resource || !item.hash || !mappings[asset_name])
			fail("Frontend resource [asset_name] is missing from the shared cache.")
	var/datum/asset/simple/common = get_asset_datum(/datum/asset/simple/nanoui_common)
	var/datum/asset/simple/templates = get_asset_datum(/datum/asset/simple/nanoui_templates)
	if(!length(common.assets) || !length(templates.assets))
		fail("NanoUI assets were not registered.")
	check_nanoui_sources()
	check_modular_templates(templates)
	var/datum/asset/simple/maps = get_asset_datum(/datum/asset/simple/nanomaps)
	for(var/asset_name in maps.assets)
		if(!text_ends_with(asset_name, ".png"))
			fail("Native map mappings contain a legacy library instead of an image.")
	var/datum/asset/simple/goonchat/chat = get_asset_datum(/datum/asset/simple/goonchat)
	if(!chat.assets["browserOutput.js"] || !chat.legacy)
		fail("The existing chat renderer lost its legacy browser resources.")
	var/datum/asset_transport/original_transport = SSassets.transport
	var/datum/asset_transport/tgui_test/test_transport = new
	SSassets.transport = test_transport
	get_asset_datum(/datum/asset/nanoui).send(null)
	SSassets.transport = original_transport
	if(test_transport.invalid_asset_names || test_transport.send_batches != 3)
		fail("NanoUI without an optional asset sends an invalid name or loses shared resources.")
	qdel(test_transport)
	var/datum/asset_cache_item/first = register_asset("tgui_unit_test.txt", 'mods/tgui/frontend/public/tgui.html')
	var/datum/asset_cache_item/second = register_asset("tgui_unit_test.txt", 'mods/tgui/frontend/public/tgui.html')
	if(first != second || SSassets.cache["tgui_unit_test.txt"] != first)
		fail("Compatibility registration created a second cache entry.")
	if(!first.legacy || !first.keep_local_name || SSassets.transport.get_asset_url("tgui_unit_test.txt") != "tgui_unit_test.txt")
		fail("Fixed-name browser assets lost their compatibility name.")
	var/datum/asset_transport/webroot/cdn = new
	if(cdn.get_asset_suffex(first) != "asset.[first.hash].txt")
		fail("CDN URLs do not use the registered content hash.")
	qdel(cdn)
	SSassets.cache -= "tgui_unit_test.txt"
	qdel(first)
	if(!reported)
		pass("TGUI, NanoUI and existing chat share registered assets.")
	return TRUE

/datum/unit_test/tgui_assets/proc/check_nanoui_sources()
	var/list/paths = list(
		"nano/js/libraries.min.js", "nano/js/nano_base_helpers.js", "nano/js/nano_base_callbacks.js", "nano/js/nano_state.js",
		"nano/css/icons.css", "nano/css/shared.css", "nano/css/layout_default.css",
		"nano/images/uiBackground-NTengi.png", "nano/images/uiBackground-NTmed.png", "nano/images/uiBackground-NTsci.png",
		"nano/templates/geoscanner.tmpl", "nano/templates/rdservercontrol.tmpl"
	)
	for(var/path in paths)
		var/filename = copytext(path, findlasttext(path, "/") + 1)
		var/datum/asset_cache_item/item = SSassets.cache[filename]
		if(!item?.resource || item.hash != md5(fcopy_rsc(path)))
			fail("NanoUI resource [filename] does not use Sierra's version of [path].")
		if(!item?.legacy || !item.keep_local_name)
			fail("NanoUI resource [filename] lost its fixed browser filename or CDN fallback.")

/datum/unit_test/tgui_assets/proc/check_modular_templates(datum/asset/simple/templates)
	for(var/filename in flist("nano/templates/mods/"))
		if(copytext(filename, -1) == "/")
			continue
		var/datum/asset_cache_item/item = templates.assets["mods-[filename]"]
		if(!item?.resource || item.hash != md5(fcopy_rsc("nano/templates/mods/[filename]")))
			fail("Modular NanoUI template [filename] is missing or has incorrect content.")
		if(!item?.legacy || !item.keep_local_name)
			fail("Modular NanoUI template [filename] lost its mods- browser filename or CDN fallback.")
