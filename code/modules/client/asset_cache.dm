/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(client/client, asset_name, verify = TRUE, check_cache = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(check_cache && (client.cache.Find(asset_name) || client.sending.Find(asset_name)))
		return 0

	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	send_rsc(client, asset_cache.cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += asset_name
		return 1
	if (!client)
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	show_browser(client, "<script>window.location.href=\"?asset_cache_confirm_arrival=[job]\"</script>", "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * length(client.sending)) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(client/client, list/asset_list, verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !length(unreceived))
		return 0
	if (length(unreceived) >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	for(var/asset in unreceived)
		if (asset in asset_cache.cache)
			send_rsc(client, asset_cache.cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += unreceived
		return 1
	if (!client)
		return 0
	client.sending |= unreceived
	var/job = ++client.last_asset_job

	show_browser(client, "<script>window.location.href=\"?asset_cache_confirm_arrival=[job]\"</script>", "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * length(client.sending)
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(client/client, list/files, register_asset = TRUE)
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file,files[file])
		send_asset(client,file)
		sleep(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(asset_name, asset)
	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	asset_cache.cache[asset_name] = asset

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src
	register()

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)

// For registering or sending multiple others at once
/datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		get_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		A.send(C)

//DEFINITIONS FOR ASSET DATUMS START HERE.
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
//[SIERRA-ADD] - ASSETS
	var/list/mod_dirs = list(
		"nano/templates/mods/"
	)
//[SIERRA-ADD] - ASSETS
//[SIERRA-EDIT] - ASSETS
/datum/asset/nanoui/register()
	// Crawl the directories to find files.
// МОДУЛЬНО АССЕТЫ НЕ РЕГИСТРИРУЕМ, ПРИ ВЫЗОВЕ ПРЕДКА, НАЧНЕТСЯ ПЕРЕРЕГИСТРАЦИЯ.
// С ОВЕРРАЙДАМИ Я УЖЕ ПОПАДАЛСЯ НА ТО ЧТО ПРОК НЕ ИСПОЛЬЗОВАЛСЯ ПОТОМУ ЧТО МОЙ ОВЕРРАЙД БЫЛ ПЕРЕОПРЕДЕЛЕН В ДРУГОМ МОДУЛЕ.
// ИЗ-ЗА ЭТОГО Я ПЕРЕПИСАЛ НАШИ В КОРКОД, ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ С ПЕРЕОПРЕДЕЛЕНИЕМ.
// ПЕРВЫМИ МЫ ЗАГРУЖАЕМ СТИЛИ И СТАТУС ИКОНКИ
	var/list/filenames
	for(var/path in common_dirs)
		filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])
//ЗАГРУЖАЕМ ОБЫЧНЫЕ ТЕМПЛЕЙЛЫ
	for(var/path in uncommon_dirs)
		filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset(filename, fcopy_rsc(path + filename))
//ЗАГРУЖАЕМ НАШИ МОДУЛЬНЫЕ ТЕМПЛЕЙЛЫ
	for(var/path as anything in mod_dirs)
		filenames = flist(path)
		for(var/filename as anything in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset("mods-[filename]", fcopy_rsc(path + filename))

	var/list/mapnames = list()
	for(var/z in GLOB.using_map.map_levels)
		mapnames += map_image_file_name(z)

	filenames = flist(MAP_IMAGE_PATH)
	for(var/filename in filenames)
		if(copytext(filename, -1) != "/") // Ignore directories.
			var/file_path = MAP_IMAGE_PATH + filename
			if((filename in mapnames) && fexists(file_path))
				common[filename] = fcopy_rsc(file_path)
				register_asset(filename, common[filename])

//ОБЯЗАТЕЛЬНО БЫТЬ В САМОМ КОНЦЕ, ЗАГРУЗКА ИКОНОК ДЛЯ ДИЗАЙНОВ
	for(var/D in SSresearch.all_designs)
		var/datum/design/design = D
		var/filename = sanitizeFileName("[design.build_path].png")
		var/atom/item = design.build_path
		var/icon_file = initial(item.icon)
		var/icon_state
		if(item in typesof(/obj/item/reagent_containers/food/drinks/glass2))
			var/obj/item/reagent_containers/food/drinks/glass2/glass = item
			icon_state = initial(glass.base_icon)
		else
			icon_state = initial(item.icon_state)
		if (!icon_file)
			icon_file = ""

		var/icon/I = icon(icon_file, icon_state, SOUTH)
		register_asset(filename, I)

		design.ui_data["icon"] = (sanitizeFileName("[design.build_path].png"))


//[//SIERRA-EDIT] - ASSETS
/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon, FALSE)
	send_asset_list(client, common, TRUE)

/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
	)

/datum/asset/simple/goonchat
	verify = TRUE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css"  = 'code/modules/goonchat/browserassets/css/browserOutput_white.css'
	)

/datum/asset/simple/fontawesome
	verify = FALSE
	// [SIERRA-EDIT] - LOBBYSCREEN - Приходится комментить всё ибо комменты в list'ах фейлят юнит-тесты
	// assets = list( // SIERRA-EDIT - ORIGINAL
	// 	"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',  // SIERRA-EDIT - ORIGINAL
	// 	"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff', // SIERRA-EDIT - ORIGINAL
	// 	"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',    // SIERRA-EDIT - ORIGINAL
	// 	"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',   // SIERRA-EDIT - ORIGINAL
	// 	"font-awesome.css"    = 'html/font-awesome/css/all.min.css',              // SIERRA-EDIT - ORIGINAL
	// 	"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'          // SIERRA-EDIT - ORIGINAL
	// ) // SIERRA-EDIT - ORIGINAL
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"fa-brands-400.eot"   = 'mods/lobbyscreen/html/font-awesome/fa-brands-400.eot',
		"fa-brands-400.woff"  = 'mods/lobbyscreen/html/font-awesome/fa-brands-400.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)
	// [/SIERRA-EDIT]

/*
	Asset cache
*/
/singleton/asset_cache
	var/list/cache = list()

/singleton/asset_cache/proc/load()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in GLOB.clients) // This is also called in client/New, but as we haven't initialized the cache until now, and it's possible the client is already connected, we risk doing it twice.
		// Doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps.
		spawn(10)
			getFilesSlow(C, cache, FALSE)
