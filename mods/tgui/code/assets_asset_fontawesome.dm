/datum/asset/simple/namespaced/fontawesome
	legacy = TRUE
	assets = list(
		"fa-brands-400.ttf" = 'mods/tgui/resources/html/font-awesome/webfonts/fa-brands-400.ttf',
		"fa-solid-900.ttf" = 'mods/tgui/resources/html/font-awesome/webfonts/fa-solid-900.ttf',
		"fa-regular-400.ttf" = 'mods/tgui/resources/html/font-awesome/webfonts/fa-regular-400.ttf',
		"fa-v4compatibility.ttf" = 'mods/tgui/resources/html/font-awesome/webfonts/fa-v4compatibility.ttf',
		"v4shim.css" = 'mods/tgui/resources/html/font-awesome/css/v4-shims.min.css'
	)
	parents = list(
		"font-awesome.css" = 'mods/tgui/resources/html/font-awesome/css/all.min.css'
	)

// Keep the stylesheet beside its legacy fonts in the BYOND cache, avoiding CDN CORS.
/datum/asset/simple/namespaced/fontawesome/get_url_mappings()
	. = list()
	for(var/asset_name in assets)
		.[asset_name] = url_encode(asset_name)
