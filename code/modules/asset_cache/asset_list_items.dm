/datum/asset/nanoui
	var/list/common = list()

	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"nano/templates/"
	)

/datum/asset/nanoui/register()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])

	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset(filename, fcopy_rsc(path + filename))

	var/list/mapnames = list()
	for(var/z in GLOB.using_map.map_levels)
		mapnames += map_image_file_name(z)

	var/list/filenames = flist(MAP_IMAGE_PATH)
	for(var/filename in filenames)
		if(copytext(filename, length(filename)) != "/") // Ignore directories.
			var/file_path = MAP_IMAGE_PATH + filename
			if((filename in mapnames) && fexists(file_path))
				common[filename] = fcopy_rsc(file_path)
				register_asset(filename, common[filename])

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon)
	send_asset_list(client, common)




/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	assets = list(
		"jquery.min.js"            = file("code/modules/goonchat/browserassets/js/jquery.min.js")
	)

/datum/asset/simple/goonchat
	assets = list(
		"json2.min.js"             = file("code/modules/goonchat/browserassets/js/json2.min.js"),
		"browserOutput.js"         = file("code/modules/goonchat/browserassets/js/browserOutput.js"),
		"browserOutput.css"	       = file("code/modules/goonchat/browserassets/css/browserOutput.css"),
		"browserOutput_white.css"  = file("code/modules/goonchat/browserassets/css/browserOutput_white.css")
	)

/datum/asset/simple/fontawesome
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"fa-brands-400.eot"  = 'html/font-awesome/webfonts/fa-brands-400.eot',
		"fa-brands-400.woff" = 'html/font-awesome/webfonts/fa-brands-400.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

/datum/asset/simple/lobby
	assets = list(
		"courierprime-code.woff" = 'html/lobby/courierprime-code.woff',
		"round-control.woff" = 'html/lobby/round-control.woff',
		"light_left.png" = 'html/lobby/light_left.png',
		"light_right.png" = 'html/lobby/light_right.png',
		"smallbutton.png" = 'html/lobby/smallbutton.png',
		"buttons.mp4" = 'html/lobby/buttons.mp4'
	)

/datum/asset/simple/lobby_loop
	assets = list(
		"loop.mp4" = 'html/lobby/loop.mp4'
	)

/datum/asset/simple/changelog
	assets = list(
		"admin.png" = 'html/changelog-static/admin.png',
		"balance.png" = 'html/changelog-static/balance.png',
		"bugfix.png" = 'html/changelog-static/bugfix.png',
		"experiment.png" = 'html/changelog-static/experiment.png',
		"imageadd.png" = 'html/changelog-static/imageadd.png',
		"imagedel.png" = 'html/changelog-static/imagedel.png',
		"maptweak.png" = 'html/changelog-static/maptweak.png',
		"rscadd.png" = 'html/changelog-static/rscadd.png',
		"rscdel.png" = 'html/changelog-static/rscdel.png',
		"wip.png" = 'html/changelog-static/wip.png',
		"soundadd.png" = 'html/changelog-static/soundadd.png',
		"sounddel.png" = 'html/changelog-static/sounddel.png',
		"spellcheck.png" = 'html/changelog-static/spellcheck.png',
		"tweak.png" = 'html/changelog-static/tweak.png',
		"changelog.css" = 'html/changelog.css',
		"changelog.html" = 'html/changelog.html'
	)
