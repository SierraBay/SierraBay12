/// CDN Webroot asset transport.
/datum/asset_transport/webroot
	name = "CDN Webroot asset transport"
	/// Successful checks, scoped to this transport and full destination path.
	var/list/verified_assets = list()

/datum/asset_transport/webroot/Load()
	if(validate_config(log = FALSE))
		load_existing_assets()

/// Processes thru any assets that were registered before we were loaded as a transport.
/datum/asset_transport/webroot/proc/load_existing_assets()
	verified_assets.Cut()
	for(var/asset_name in SSassets.cache)
		var/datum/asset_cache_item/ACI = SSassets.cache[asset_name]
		save_asset_to_webroot(ACI)
		CHECK_TICK

/// Register a browser asset with the asset cache system
/// We also save it to the CDN webroot at this step instead of waiting for send_assets()
/// asset_name - the identifier of the asset
/// asset - the actual asset file or an asset_cache_item datum.
/datum/asset_transport/webroot/register_asset(asset_name, asset)
	. = ..()
	var/datum/asset_cache_item/ACI = .

	if(istype(ACI) && ACI.hash)
		save_asset_to_webroot(ACI)

/// Saves the asset to the webroot taking into account namespaces and hashes.
/datum/asset_transport/webroot/proc/save_asset_to_webroot(datum/asset_cache_item/ACI)
	var/webroot = config.asset_cdn_webroot
	var/suffix = get_asset_suffex(ACI)
	if(!suffix)
		log_debug("ERROR: Webroot rejected an invalid asset path for [ACI?.name]")
		return FALSE
	var/newpath = "[webroot][suffix]"
	if(fexists(newpath))
		if(verified_assets[newpath] == ACI.hash || md5(file(newpath)) == ACI.hash)
			verified_assets[newpath] = ACI.hash
			return TRUE
	// A gzip sidecar alone does not guarantee delivery to clients requesting identity.
	if(!fcopy(ACI.resource, newpath))
		verified_assets -= newpath
		log_debug("ERROR: Webroot could not publish [ACI.name] to [newpath]")
		return FALSE
	verified_assets[newpath] = ACI.hash
	return TRUE

/// Returns a url for a given asset.
/// asset_name - Name of the asset.
/// asset_cache_item - asset cache item datum for the asset, optional, overrides asset_name
/datum/asset_transport/webroot/get_asset_url(asset_name, datum/asset_cache_item/asset_cache_item)
	if(!istype(asset_cache_item))
		asset_cache_item = SSassets.cache[asset_name]
	var/url = config.asset_cdn_url //config loading will handle making sure this ends in a /
	var/suffix = get_asset_suffex(asset_cache_item)
	return suffix ? "[url][suffix]" : null

/datum/asset_transport/webroot/proc/get_asset_suffex(datum/asset_cache_item/asset_cache_item)
	if(!istype(asset_cache_item) || !asset_cache_item.hash)
		return null
	var/base = ""
	var/filename = "asset.[asset_cache_item.hash][asset_cache_item.ext]"
	if(length(asset_cache_item.namespace))
		if(!safe_path_component(asset_cache_item.namespace))
			return null
		base = "namespaces/[asset_cache_item.namespace]/"
		if(!asset_cache_item.namespace_parent)
			filename = "[asset_cache_item.name]"
	if(!safe_path_component(filename))
		return null
	return base + filename

/// Published components are literal URL-safe filenames, never relative paths.
/datum/asset_transport/webroot/proc/safe_path_component(component)
	var/static/regex/safe_component = regex("^\[a-zA-Z0-9_.-]+$")
	return istext(component) && component != "." && component != ".." && safe_component.Find(component)


/// webroot asset sending - does nothing unless passed legacy assets
/datum/asset_transport/webroot/send_assets(client/client, list/asset_list)
	. = FALSE
	var/list/legacy_assets = list()
	if(!islist(asset_list))
		asset_list = list(asset_list)
	for(var/asset_name in asset_list)
		var/datum/asset_cache_item/ACI = asset_list[asset_name]
		if(!istype(ACI))
			ACI = SSassets.cache[asset_name]
		if(!ACI)
			legacy_assets += asset_name //pass it on to base send_assets so it can output an error
			continue
		if(ACI.legacy)
			legacy_assets[asset_name] = ACI
	if(length(legacy_assets))
		. = ..(client, legacy_assets)


/// webroot slow asset sending - does nothing.
/datum/asset_transport/webroot/send_assets_slow(client/client, list/files, filerate)
	return FALSE

/datum/asset_transport/webroot/validate_config(log = TRUE)
	if(!config.asset_cdn_url)
		if(log)
			log_debug("ERROR: [type]: Invalid Config: asset_cdn_url")
		return FALSE
	if(!config.asset_cdn_webroot)
		if(log)
			log_debug("ERROR: [type]: Invalid Config: asset_cdn_webroot")
		return FALSE
	return TRUE
