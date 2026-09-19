/proc/odyssey_ensure_data_dir()
	// Snapshot names are flat under the already-existing data/ directory.
	return "data"


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
	var/version = meta["version"] || 1
	if (version == ODYSSEY_VERSION)
		return meta
	if (version == 1)
		return odyssey_migrate_meta_v1(meta)
	log_error("ODYSSEY: unsupported save version [version] (current [ODYSSEY_VERSION])")
	return null


/proc/odyssey_migrate_meta_v1(list/old_meta)
	var/list/meta = old_meta.Copy()
	var/seed = "[old_meta["campaign_id"] || odyssey_map_key()]"
	var/list/graph = odyssey_generate_sector_graph(seed)
	var/shift = clamp(old_meta["shift_number"] || 1, 1, ODYSSEY_MAX_SHIFTS)
	var/current_id = ODYSSEY_SECTOR_START
	if (shift == 2)
		current_id = "route_2_long"
	else if (shift == 3)
		current_id = "route_3_long"
	else if (shift == 4)
		current_id = "route_4_long"
	else if (shift >= 5)
		current_id = "finish_5"
	meta["version"] = ODYSSEY_VERSION
	meta["status"] = old_meta["active"] ? ODYSSEY_STATUS_ACTIVE : ODYSSEY_STATUS_ADMIN_ABORTED
	meta["campaign_seed"] = seed
	meta["min_shifts"] = ODYSSEY_MIN_SHIFTS
	meta["max_shifts"] = ODYSSEY_MAX_SHIFTS
	meta["sector_graph"] = graph
	meta["current_sector_id"] = current_id
	meta["selected_sector_id"] = null
	meta["transition_committed"] = FALSE
	meta["route_history"] = list(ODYSSEY_SECTOR_START)
	meta["migrated_from"] = 1
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
