/// Wire Odyssey Sector Map into the public Newscast program (read-only).

/datum/computer_file/program/newscast/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	extended_desc = "Newsfeed browser with NTNet channels. During an Odyssey, also publishes the public Sector Map for crew review."


/datum/nano_module/program/newscast/newscast_has_sector_map()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return state.active


/datum/nano_module/program/newscast/newscast_append_sector_data(list/data, mob/user)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	data["odyssey_active"] = state.active
	if (!state.active)
		return
	if (!viewed_sector_id && state.current_sector_id)
		viewed_sector_id = state.current_sector_id
	data["odyssey"] = odyssey_build_map_ui_data(viewed_sector_id, FALSE)
