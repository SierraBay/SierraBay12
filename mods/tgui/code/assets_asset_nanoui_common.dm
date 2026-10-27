/datum/asset/simple/nanoui_common
	legacy = TRUE
	keep_local_name = TRUE
	var/list/asset_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/",
		"mods/tgui/resources/nano/css/",
		"mods/tgui/resources/nano/images/",
		"mods/tgui/resources/nano/images/status_icons/",
		"mods/tgui/resources/nano/images/modular_computers/",
		"mods/tgui/resources/nano/js/"
	)

/datum/asset/simple/nanoui_common/register()
	for (var/path in asset_dirs)
		for(var/filename in flist(path))
			var/is_directory = copytext(filename, length(filename)) == "/"
			// Sierra's helpers, styles and callbacks take priority over donor copies.
			if(is_directory || assets[filename])
				continue

			assets[filename] = fcopy_rsc("[path][filename]")

	var/list/mapnames = list()
	for(var/z in GLOB.using_map.map_levels)
		var/map_image_filename = map_image_file_name(z)
		if(map_image_filename)
			mapnames[map_image_filename] = TRUE

	for(var/filename in flist(MAP_IMAGE_PATH))
		if(copytext(filename, length(filename)) == "/")
			continue

		var/file_path = "[MAP_IMAGE_PATH][filename]"
		if(!(mapnames[filename]))
			continue

		assets[filename] = fcopy_rsc(file_path)

	. = ..()
