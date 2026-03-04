/datum
	var/list/filter_data


// Compare filter data priority for sorting (height_system)
/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]


/// Filter procs for height system (migrated from PR #4641)
/datum/proc/add_filter(name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/datum/proc/update_filters()
	var/atom/A = src // Works with both atoms and images
	A.filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		A.filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/datum/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return
	var/list/old_filter_data = filter_data[name]
	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]
	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/datum/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return
	filter_data[name]["priority"] = new_priority
	update_filters()

/datum/proc/get_filter(name)
	var/atom/A = src // Works with both atoms and images
	if(filter_data && filter_data[name])
		return A.filters[filter_data.Find(name)]

/datum/proc/remove_filter(name_or_names)
	if(!filter_data)
		return
	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)
	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/datum/proc/clear_filters()
	var/atom/A = src // Works with both atoms and images
	filter_data = null
	A.filters = null



/datum/preferences/proc/get_preview_bgcolor()
	switch(bgstate)
		if("000")
			return COLOR_BLACK
		if("FFF")
			return COLOR_WHITE
		if("white")
			return COLOR_WHITE
		else
			return COLOR_GRAY

/datum/preferences/proc/get_preview_floor_state()
	switch(bgstate)
		if("000")
			return "dark"
		if("FFF", "white")
			return "white"
		else
			return "steel"

/proc/flatten_appearance_planes(mutable_appearance/M)
	switch(M.plane)
		if(FLOAT_PLANE)
			EMPTY_BLOCK_GUARD // already float-plane, keep as-is
		if(DEFAULT_PLANE, EFFECTS_ABOVE_LIGHTING_PLANE, GAME_PLANE_FOV_HIDDEN, GAME_PLANE_ABOVE_FOV)
			M.plane = FLOAT_PLANE
		else
			return FALSE // EMISSIVE_PLANE, LIGHTING_PLANE, BLACKNESS_PLANE, etc.
	if(length(M.overlays))
		var/list/new_overlays = list()
		for(var/overlay in M.overlays)
			var/mutable_appearance/child = new(overlay)
			if(flatten_appearance_planes(child))
				new_overlays += child
		M.overlays = new_overlays
	if(length(M.underlays))
		var/list/new_underlays = list()
		for(var/underlay in M.underlays)
			var/mutable_appearance/child = new(underlay)
			if(flatten_appearance_planes(child))
				new_underlays += child
		M.underlays = new_underlays
	return TRUE

#define PREVIEW_PLANE 50
/client/proc/show_character_previews(mutable_appearance/MA, is_tall = FALSE, floor_state = "steel")
	var/map_id = is_tall ? "tall" : "compact"
	var/map_name = is_tall ? "character_preview_map" : "character_preview_map_compact"

	// If switching between maps, clear everything and rebuild
	if(preview_active_map != map_id)
		clear_character_previews()
		preview_active_map = map_id
		// Toggle MAP visibility
		if(is_tall)
			winshow(src, "character_preview_map", TRUE)
			winshow(src, "character_preview_map_compact", FALSE)
		else
			winshow(src, "character_preview_map", FALSE)
			winshow(src, "character_preview_map_compact", TRUE)


	if(!LAZYACCESS(char_render_holders, "pm"))
		var/obj/screen/PM = new /obj/screen()
		PM.name = "Preview PM"
		PM.appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
		PM.plane = PREVIEW_PLANE
		PM.blend_mode = BLEND_OVERLAY
		PM.mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
		PM.screen_loc = "[map_name]:CENTER"
		LAZYSET(char_render_holders, "pm", PM)
		screen += PM


	var/pos = 0
	for(var/D in GLOB.cardinal)
		var/obj/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new /obj/screen()
			LAZYSET(char_render_holders, "[D]", O)
			screen |= O
		O.appearance = MA
		O.plane = PREVIEW_PLANE
		O.transform = null
		var/list/fixed_overlays = list()
		for(var/overlay in O.overlays)
			var/mutable_appearance/M = new(overlay)
			if(flatten_appearance_planes(M))
				fixed_overlays += M
		O.overlays = fixed_overlays
		var/list/fixed_underlays = list()
		for(var/underlay in O.underlays)
			var/mutable_appearance/M = new(underlay)
			if(flatten_appearance_planes(M))
				fixed_underlays += M
		O.underlays = fixed_underlays
		O.set_dir(D)
		var/mutable_appearance/floor = new /mutable_appearance()
		floor.icon = 'icons/turf/floors.dmi'
		floor.icon_state = floor_state
		floor.plane = FLOAT_PLANE
		O.underlays += floor
		var/tile_y
		if(is_tall)
			tile_y = 1 + pos * 2 // y = 1, 3, 5, 7
		else
			tile_y = 1 + pos     // y = 1, 2, 3, 4
		O.screen_loc = "[map_name]:1,[tile_y]"
		pos++

/client/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/obj/screen/S = char_render_holders[index]
		screen -= S
		qdel(S)
	char_render_holders = null


/datum/preferences/proc/refresh_preview_map_visibility()
	if(!client)
		return
	switch(client.preview_active_map)
		if("tall")
			winshow(client, "character_preview_map", TRUE)
			winshow(client, "character_preview_map_compact", FALSE)
		if("compact")
			winshow(client, "character_preview_map", FALSE)
			winshow(client, "character_preview_map_compact", TRUE)

/datum/preferences/proc/refresh_preview_map_contents()
	// Always call update_preview_icon() here — this runs AFTER the window is shown,
	// so screen objects are properly bound to the MAP element.
	if(!client)
		return
	update_preview_icon()
