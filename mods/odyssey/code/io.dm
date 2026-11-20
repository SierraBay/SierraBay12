/proc/odyssey_ensure_data_dir()
	// Snapshot names are flat under the already-existing data/ directory.
	return "data"


/// Filename prefix for this map's Odyssey files inside data/ (e.g. odyssey_sierra_).
/proc/odyssey_map_disk_prefix()
	return "odyssey_[odyssey_map_key()]_"


/// Deletes one generation's JSON + photo savefiles. Returns how many paths were removed.
/proc/odyssey_delete_generation(generation)
	if (!generation)
		return 0
	var/deleted = 0
	var/list/kinds = list(
		"turfs", "machinery", "structures", "mechs", "economy", "research",
		"roster", "newscast", "corpses", "materials", "papers", "remains",
		"cleanables", "chronicle", odyssey_items_manifest_kind()
	)
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		kinds += odyssey_item_snapshot_kind(bucket)
	for (var/kind in kinds)
		var/path = odyssey_snapshot_path(kind, generation)
		if (fexists(path))
			fdel(path)
			deleted++
	var/papers_photos = odyssey_papers_photos_path(generation)
	if (fexists(papers_photos))
		fdel(papers_photos)
		deleted++
	var/news_photos = odyssey_newscast_photos_path(generation)
	if (fexists(news_photos))
		fdel(news_photos)
		deleted++
	if (deleted)
		log_game("ODYSSEY: deleted generation=[generation] files=[deleted]")
	return deleted


/// Removes Odyssey snapshot files for this map. Keeps campaign.json.
/// If keep_generation is set, files belonging to that generation are retained.
/proc/odyssey_purge_map_snapshots(keep_generation = null)
	var/map_key = odyssey_map_key()
	var/prefix = odyssey_map_disk_prefix()
	var/meta_name = "[prefix]campaign.json"
	var/deleted = 0
	for (var/fname in flist("data/"))
		if (!dd_hasprefix_case(fname, prefix))
			continue
		if (fname == meta_name)
			continue
		if (keep_generation && findtextEx(fname, keep_generation))
			continue
		var/full = "data/[fname]"
		if (!fexists(full))
			continue
		fdel(full)
		deleted++
	if (deleted)
		log_game("ODYSSEY: purged [deleted] snapshot file(s) map=[map_key] keep=[keep_generation || "none"]")
	return deleted


/proc/odyssey_read_json(path)
	if (!path || !fexists(path))
		return null
	var/text = file2text(path)
	if (!text)
		return null
	var/list/data = json_decode(text)
	if (!islist(data))
		return null
	return data


/proc/odyssey_write_json(path, list/data)
	if (!path || !islist(data))
		return FALSE
	var/text = json_encode(data)
	if (isnull(text))
		log_error("ODYSSEY: failed to encode [path]")
		return FALSE
	var/error = rustg_file_write(text, path)
	if (error)
		log_error("ODYSSEY: failed to write [path]: [error]")
		return FALSE
	return TRUE


/proc/odyssey_campaign_exists()
	var/list/meta = odyssey_load_meta()
	if (!islist(meta))
		return FALSE
	return !!meta["active"] && (!meta["status"] || meta["status"] == ODYSSEY_STATUS_ACTIVE)


/proc/odyssey_load_meta()
	var/list/meta = odyssey_read_json(odyssey_meta_path())
	if (!islist(meta))
		return null
	var/version = meta["version"] || 0
	if (version != ODYSSEY_VERSION)
		log_error("ODYSSEY: unsupported save version [version] (current [ODYSSEY_VERSION])")
		return null
	return meta


/proc/odyssey_write_meta(list/meta)
	odyssey_ensure_data_dir()
	return odyssey_write_json(odyssey_meta_path(), meta)


/// Clears the active campaign flag so the next lobby will not offer continue.
/proc/odyssey_archive_campaign(reason, status = ODYSSEY_STATUS_ADMIN_ABORTED)
	var/list/meta = odyssey_load_meta() || list()
	meta["active"] = FALSE
	meta["status"] = status
	meta["outcome_reason"] = reason
	meta["archived_at"] = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	meta["archive_reason"] = reason
	odyssey_write_meta(meta)
	log_game("ODYSSEY: campaign archived status=[status] reason=[reason]")
	odyssey_refresh_lobby_titlescreens()


/// Admin-only: mark an archived campaign active again so continue can load it.
/proc/odyssey_reactivate_campaign_meta()
	var/list/meta = odyssey_load_meta()
	if (!islist(meta))
		return FALSE
	meta["active"] = TRUE
	meta["status"] = ODYSSEY_STATUS_ACTIVE
	meta["outcome_reason"] = null
	meta["archived_at"] = null
	meta["archive_reason"] = null
	if (!odyssey_write_meta(meta))
		return FALSE
	log_game("ODYSSEY: campaign reactivated id=[meta["campaign_id"]]")
	odyssey_refresh_lobby_titlescreens()
	return TRUE


/proc/odyssey_continue_fail_reason()
	var/list/meta = odyssey_load_meta()
	if (!islist(meta))
		return "нет файла [odyssey_meta_path()]"
	if (!meta["active"])
		return "кампания неактивна: [meta["status"] || "?"] ([meta["archive_reason"] || meta["outcome_reason"] || "без причины"])"
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (length(state.validation_errors))
		return json_encode(state.validation_errors)
	return "сейв отклонён при загрузке (status=[state.status])"
