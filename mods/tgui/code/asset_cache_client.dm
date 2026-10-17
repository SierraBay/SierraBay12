/client
	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Jobs currently waiting for a client acknowledgement.
	var/list/pending_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

/// Process asset cache client topic calls for "asset_cache_confirm_arrival=[INT]"
/client/proc/asset_cache_confirm_arrival(job_id)
	var/asset_cache_job = round(text2num(job_id))

	// because we skip the limiter, we have to make sure this is a valid arrival and
	// not somebody tricking us into letting them append to a list without limit.
	if (pending_asset_jobs?["[asset_cache_job]"] && !(completed_asset_jobs["[asset_cache_job]"]))
		completed_asset_jobs["[asset_cache_job]"] = TRUE
		last_completed_asset_job = max(last_completed_asset_job, asset_cache_job)
	else
		return asset_cache_job || TRUE


/// Process asset cache client topic calls for "asset_cache_preload_data=[HTML+JSON_STRING]
/client/proc/asset_cache_preload_data(data)
	if(!istext(data) || length(data) > 1048576)
		return
	var/list/preloaded_assets
	try
		preloaded_assets = json_decode(data)
	catch(var/exception/error)
		log_tgui(src, "Invalid asset preload JSON: [error]")
		return
	if(!islist(preloaded_assets))
		return
	// Accept only cache entries known to this server; executable resources reload.
	for(var/asset_name in SSassets.cache)
		var/datum/asset_cache_item/item = SSassets.cache[asset_name]
		if(lowertext(item.ext) in list(".js", ".jsm", ".htm", ".html"))
			continue
		var/local_name = (item.legacy || item.keep_local_name || (item.namespace && !item.namespace_parent) || SSassets.transport.dont_mutate_filenames) ? item.name : "asset.[item.hash][item.ext]"
		if(preloaded_assets[local_name] == item.hash)
			sent_assets[local_name] = item.hash



/// Updates the client side stored html/json combo file used to keep track of what assets the client has between restarts/reconnects.
/client/proc/asset_cache_update_json(verify = FALSE, list/new_assets = list())
	if (world.time - connection_time < 10 SECONDS) //don't override the existing data file on a new connection
		return
	if (!islist(new_assets))
		new_assets = list("[new_assets]" = md5(SSassets.cache[new_assets]))

	// JSON must bypass show_browser's UTF-8 HTML wrapper.
	to_target(src, browse(json_encode(new_assets|sent_assets), "file=asset_data.json&display=0"))

/// Blocks until all currently sending browser assets have been sent.
/// Due to byond limitations, this proc will sleep for 1 client round trip even if the client has no pending asset sends.
/// This proc will return an untrue value if it had to return before confirming the send, such as timeout or the client going away.
/client/proc/browse_queue_flush(timeout = 50)
	var/job = ++last_asset_job
	pending_asset_jobs["[job]"] = TRUE
	var/t = 0
	var/timeout_time = timeout
	show_browser(src, {"<script>window.location.href='?asset_cache_confirm_arrival=[job]'</script>"}, "window=asset_cache_browser")

	while(src && completed_asset_jobs && !completed_asset_jobs["[job]"] && t < timeout_time) // Reception is handled in Topic()
		stoplag(1) // Lock up the caller until this is received.
		t++
	var/confirmed = !!completed_asset_jobs?["[job]"]
	if(completed_asset_jobs)
		completed_asset_jobs -= "[job]"
	if(pending_asset_jobs)
		pending_asset_jobs -= "[job]"
	return confirmed
