// TGUI
/datum/configuration
	var/tgui_max_chunk_count = 32
	var/asset_transport = "simple"
	var/asset_simple_preload = FALSE
	var/asset_cdn_webroot = "data/asset-store/"
	var/asset_cdn_url = ""

/datum/configuration/read_config(filename)
	. = ..()
	if(filename != "config/config.txt" || !islist(.))
		return
	var/list/settings = .
	if(istext(settings["tgui_max_chunk_count"]))
		tgui_max_chunk_count = clamp(round(text2num(settings["tgui_max_chunk_count"])), 1, 128)
	if(settings["asset_transport"])
		asset_transport = settings["asset_transport"]
	asset_simple_preload = !!settings["asset_simple_preload"]
	if(settings["asset_cdn_webroot"])
		asset_cdn_webroot = settings["asset_cdn_webroot"]
	if(settings["asset_cdn_url"])
		asset_cdn_url = settings["asset_cdn_url"]
	if(length(asset_cdn_url) && copytext(asset_cdn_url, -1) != "/")
		asset_cdn_url += "/"
	if(length(asset_cdn_webroot) && copytext(asset_cdn_webroot, -1) != "/")
		asset_cdn_webroot += "/"
	// These entries are handled here rather than by the core configuration switch.
	settings -= list("tgui_max_chunk_count", "asset_transport", "asset_simple_preload", "asset_cdn_webroot", "asset_cdn_url")

