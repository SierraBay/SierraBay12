/datum/asset/simple/namespaced/tgfont
	legacy = TRUE
	assets = list(
		"tgfont.eot" = file("mods/tgui/frontend/packages/tgfont/static/tgfont.eot"),
		"tgfont.woff2" = file("mods/tgui/frontend/packages/tgfont/static/tgfont.woff2"),
	)
	parents = list(
		"tgfont.css" = file("mods/tgui/frontend/packages/tgfont/static/tgfont.css"),
	)

// Keep the stylesheet beside its legacy fonts in the BYOND cache, avoiding CDN CORS.
/datum/asset/simple/namespaced/tgfont/get_url_mappings()
	. = list()
	for(var/asset_name in assets)
		.[asset_name] = url_encode(asset_name)
