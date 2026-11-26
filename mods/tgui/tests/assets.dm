/datum/unit_test/tgui_assets
	name = "TGUI: shared asset cache, frontend bundles and legacy consumers"

/datum/asset_transport/tgui_test
	var/invalid_asset_names = 0
	var/send_batches = 0
	var/list/sent_names = list()

/datum/asset_transport/tgui_test/send_assets(client/client, list/asset_list)
	send_batches++
	for(var/asset_name in asset_list)
		if(!istext(asset_name) || !length(asset_name))
			invalid_asset_names++
		else
			sent_names[asset_name] = TRUE
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
	var/datum/asset/simple/designs = get_asset_datum(/datum/asset/simple/sierra_designs)
	var/list/preload_assets = length(SSassets.transport.preload) ? SSassets.transport.preload : SSassets.build_preload_assets()
	if(!preload_assets["libraries.min.js"] || !preload_assets["layout_default.tmpl"])
		fail("Lightweight connection preload lost core NanoUI libraries or layout templates.")
	if(preload_assets["vending_machine.tmpl"])
		fail("Connection preload should exclude non-layout NanoUI machine templates.")
	for(var/design_icon in designs.assets)
		if(preload_assets[design_icon])
			fail("Connection preload should exclude R&D design icon [design_icon].")
			break

	var/datum/asset_transport/original_transport = SSassets.transport
	var/datum/asset_transport/tgui_test/test_transport = new
	SSassets.transport = test_transport
	var/datum/asset/nanoui/nanoui_asset = get_asset_datum(/datum/asset/nanoui)
	nanoui_asset.send(null)
	if(test_transport.invalid_asset_names || test_transport.send_batches != 1 || !test_transport.sent_names["libraries.min.js"] || test_transport.sent_names["vending_machine.tmpl"])
		SSassets.transport = original_transport
		qdel(test_transport)
		fail("NanoUI without uncommon assets sent unexpected templates or missed shared core resources.")

	test_transport.sent_names.Cut()
	test_transport.send_batches = 0
	nanoui_asset.send(null, list("vending_machine.tmpl"))
	SSassets.transport = original_transport
	if(test_transport.invalid_asset_names || test_transport.send_batches != 2 || !test_transport.sent_names["vending_machine.tmpl"] || !test_transport.sent_names["libraries.min.js"])
		qdel(test_transport)
		fail("NanoUI with an uncommon template lost requested template or shared resources.")
	for(var/design_icon in designs.assets)
		if(test_transport.sent_names[design_icon])
			qdel(test_transport)
			fail("NanoUI send unexpectedly included bulk R&D design icon [design_icon].")
			break
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
	var/list/webroot_legacy = cdn.extract_legacy_assets(list("tgui.bundle.js", "libraries.min.js", "layout_default.tmpl"), include_missing = FALSE)
	if(webroot_legacy["tgui.bundle.js"] || !webroot_legacy["libraries.min.js"] || !webroot_legacy["layout_default.tmpl"])
		qdel(cdn)
		fail("Webroot legacy preload filtering leaked CDN assets or dropped NanoUI legacy core assets.")
	if(cdn.send_assets_slow(null, list("tgui.bundle.js")) != FALSE)
		qdel(cdn)
		fail("Webroot slow preload attempted to send non-legacy CDN assets.")
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
