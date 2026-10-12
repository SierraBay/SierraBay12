// TGUI
/client
	var/connection_time
	/// Native window dimensions use display pixels rather than CSS pixels.
	var/window_scaling = 1

/client/New(TopicData)
	connection_time = world.time
	. = ..()
	invoke_async(src, PROC_REF(acquire_dpi))

/client/proc/acquire_dpi()
	var/scaling = text2num(winget(src, null, "dpi"))
	window_scaling = scaling > 0 ? scaling : 1

/client/getFiles()
	var/list/assets = list()
	for(var/resource in args)
		var/resource_path = "[resource]"
		var/replacement = "mods/tgui/resources/[resource_path]"
		if(copytext(resource_path, 1, 6) == "html/" && fexists(replacement))
			resource = fcopy_rsc(replacement)
		var/list/path_parts = splittext(resource_path, "/")
		var/asset_name = path_parts[length(path_parts)]
		assets[asset_name] = register_asset(asset_name, resource)
	SSassets.transport.send_assets(src, assets)

/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)
		return
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		return
	if(href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return
	if(href_list["tgui"] && user_acted(src) && tgui_Topic(href_list))
		return
	return ..()

/client/Del()
	SStgui?.close_user_uis(mob, logout = TRUE)
	for(var/window_id in tgui_windows.Copy())
		qdel(tgui_windows[window_id])
	QDEL_NULL(tgui_credits)
	tgui_windows = null
	sent_assets = null
	completed_asset_jobs = null
	pending_asset_jobs = null
	return ..()

