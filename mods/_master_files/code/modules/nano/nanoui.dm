// Keep Sierra's templates, Topic checks and processing inside a TGUI window.
/datum/nanoui
	var/datum/tgui/tgui_ui
	var/list/tgui_update_data
	var/tgui_closing = FALSE

/datum/nanoui/open()
	// Legacy callers do not await a result; browser acknowledgements must not block Initialize().
	set waitfor = FALSE
	if(tgui_closing || !user?.client || QDELETED(src_object))
		close()
		return FALSE
	if(update_status())
		return FALSE
	// Send legacy resources directly: TGUI mappings auto-load JS/CSS into the parent.
	get_asset_datum(/datum/asset/nanoui).send(user)
	user.client.browse_queue_flush()
	if(tgui_closing || !user?.client || QDELETED(src_object))
		close()
		return FALSE
	tgui_update_data = get_send_data(initial_data)
	if(tgui_ui && !tgui_ui.closing)
		tgui_ui.send_full_update(force = TRUE)
		return TRUE
	var/datum/tgui/parent = master_ui?.tgui_ui
	tgui_ui = new(user, src, "NanoUI", title, parent)
	tgui_ui.window_key = "[TGUI_REF(src_object)]-[ui_key]"
	tgui_ui.set_autoupdate(FALSE)
	if(!tgui_ui.open())
		close()
		return FALSE
	window_id = tgui_ui.window.id
	SSnano.ui_opened(src)
	return TRUE

/datum/nanoui/tgui_status(mob/user, datum/tgui_state/state)
	if(tgui_closing || src.user != user || QDELETED(src_object) || !user?.client)
		return STATUS_CLOSE
	if(update_status())
		return STATUS_CLOSE
	return status

/datum/nanoui/tgui_data(mob/user)
	var/multiplier = (text2num(user.client?.prefs?.window_size) || 100) / 100
	return list("nanoData" = tgui_update_data || get_send_data(initial_data), "width" = round(width * multiplier), "height" = round(height * multiplier))

/datum/nanoui/tgui_static_data(mob/user)
	return list("html" = get_html())

/datum/nanoui/push_data(data, force_push = FALSE)
	if(tgui_closing || update_status())
		return
	if(status == STATUS_DISABLED && !force_push)
		return
	tgui_update_data = get_send_data(data)
	tgui_ui?.send_update(force = TRUE)

/datum/nanoui/on_close_winset()
	// TGUI's uiclose callback owns the enclosing window.
	return

/datum/nanoui/tgui_close(mob/user)
	if(tgui_closing)
		return
	var/atom/close_ref = ref
	var/datum/topic_state/close_state = state
	var/close_logic = on_close_logic
	close()
	if(usr == user && user?.client && !QDELETED(close_ref))
		close_ref.Topic("", list("close" = "1"), close_state)
	if(close_logic && usr == user && user?.client)
		user.unset_machine()

/datum/nanoui/close()
	if(tgui_closing)
		return
	tgui_closing = TRUE
	is_auto_updating = FALSE
	SSnano.ui_closed(src)
	for(var/datum/nanoui/child in children.Copy())
		child.close()
	children.Cut()
	if(master_ui)
		master_ui.children -= src
	master_ui = null
	if(tgui_ui && !tgui_ui.closing)
		tgui_ui.close(can_be_suspended = FALSE)
	tgui_ui = null
	state = null
	tgui_update_data = null
	qdel(src)

/datum/nanoui/Destroy()
	if(!tgui_closing)
		close()
	children = null
	ref = null
	return ..()

/datum/nanoui/Topic(href, href_list)
	if(tgui_closing || user != usr || !user?.client || QDELETED(src_object))
		return
	return ..()
