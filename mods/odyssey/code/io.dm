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
