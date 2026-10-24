/obj/item/device/gps/tgui_state(mob/user)
	return GLOB.tgui_physical_state


/obj/item/device/gps/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GPS")
		ui.open()


/obj/item/device/gps/tgui_data(mob/user, ui_key)
	var/list/data = list()
	var/turf/curr = get_turf(src)
	var/area/my_area = get_area(src)
	if(!curr || !my_area)
		return list("gps_list" = list())
	var/z_level_detection

	data["tracking"] = tracking
	data["gps_tag"] = gps_tag
	data["area"] = strip_improper(my_area.name)
	data["can_hide_signal"] = can_hide_signal
	data["hide_signal"] = hide_signal
	data["curr_x"] = curr.x
	data["curr_y"] = curr.y
	data["curr_z"] = curr.z
	data["local_mode"] = local_mode
	data["emped"] = emped

	if(long_range)
		z_level_detection = (GLOB.using_map.station_levels | GLOB.using_map.contact_levels | GLOB.using_map.player_levels)
	else
		z_level_detection = GetConnectedZlevels(curr.z)

	var/list/gps_list = list()
	for(var/obj/item/device/gps/gps as anything in global.all_gps_units)
		if(gps == src || !can_track(gps, z_level_detection))
			continue
		var/gps_ref = "[TGUI_REF(gps)]"
		var/area/area = get_area(gps)
		var/turf/turf = get_turf(gps)
		gps_list += list(list(
			"gps_ref" = gps_ref,
			"gps_tag" = gps.gps_tag,
			"gps_area" = strip_improper(area.name),
			"being_tracked" = !!(gps_ref in tracking_devices),
			"degrees" = round(Get_Angle(curr,turf)),
			"distance" = round(get_dist(curr, turf), 10),
			"local" = curr.z == turf.z,
			"x" = turf.x,
			"y" = turf.y,
		))
	data["gps_list"] = gps_list

	return data


/obj/item/device/gps/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("toggle_power")
			toggle_tracking(usr)
			return TRUE
		if("stop_track")
			var/gps_ref = params["stop_track"]
			var/obj/item/device/gps/gps = locate(gps_ref)
			if(!istype(gps) || QDELETED(gps))
				return
			compass.clear_waypoint(gps_ref)
			LAZYREMOVE(tracking_devices, gps_ref)
			LAZYREMOVE(showing_tracked_names, gps_ref)
			update_compass()
			return TRUE
		if("start_track")
			var/gps_ref = params["start_track"]
			var/obj/item/device/gps/gps = locate(gps_ref)
			if(!istype(gps) || QDELETED(gps))
				return
			var/turf/current = get_turf(src)
			if(!current || !(gps in global.all_gps_units))
				return FALSE
			var/list/detection = long_range ? (GLOB.using_map.station_levels | GLOB.using_map.contact_levels | GLOB.using_map.player_levels) : GetConnectedZlevels(current.z)
			if(!can_track(gps, detection))
				return FALSE
			LAZYSET(tracking_devices, gps_ref, COLOR_SILVER)
			LAZYSET(showing_tracked_names, gps_ref, TRUE)
			update_compass()
			return TRUE
		if("track_color")
			var/obj/item/device/gps/gps = locate(params["track_color"])
			if(!istype(gps) || QDELETED(gps) || !(params["track_color"] in tracking_devices))
				return
			var/new_colour = input("Enter a new tracking color.", "GPS Waypoint Color") as color|null
			if(!new_colour || !istype(gps) || QDELETED(gps) || QDELETED(src) || holder != usr || usr.incapacitated())
				return
			to_chat(usr, SPAN_NOTICE("You adjust the colour \the [src] is using to highlight [gps.gps_tag]."))
			LAZYSET(tracking_devices, params["track_color"], new_colour)
			update_compass()
			return TRUE
		if("tag")
			var/new_tag = uppertext(tgui_input_text(usr, "Please enter desired tag.", "GPS Tag", gps_tag, 11))
			if(!new_tag || QDELETED(src) || !usr?.client || !in_range(src, usr))
				return
			gps_tag = copytext(sanitize(new_tag), 1, 11)
			name = "[initial(name)] ([gps_tag])"
			return TRUE
		if("range")
			local_mode = !local_mode
			return TRUE
		if("hide")
			if(!can_hide_signal)
				return FALSE
			hide_signal = !hide_signal
			return TRUE


/obj/item/device/gps/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, master_ui = null, datum/topic_state/state = GLOB.default_state)
	return tgui_interact(user)
