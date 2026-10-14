#define NEWSCAST_HOME 1
#define NEWSCAST_VIEW_CHANNEL 2
#define NEWSCAST_SECTOR_MAP 3

/datum/computer_file/program/newscast
	filename = "newscast"
	filedesc = "Newscast"
	program_icon_state = "generic"
	program_menu_icon = "image"
	extended_desc = "A newsfeed browser that connects to standard channels, including personalized recommendations that you can't turn off! Requires a connection to NTNet."
	size = 4 // Cloud-based, but requires the software to actually fetch the data
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_ALL
	nanomodule_path = /datum/nano_module/program/newscast

/datum/nano_module/program/newscast
	name = "Newscast"
	var/prog_state = NEWSCAST_HOME
	var/notifs_enabled = TRUE
	var/datum/feed_channel/active_channel
	var/datum/feed_network/connected_group
	/// Sector currently opened in the optional Sector Map panel.
	var/viewed_sector_id

/datum/nano_module/program/newscast/proc/news_alert(announcement)
	if (!notifs_enabled || !announcement)
		return
	program.computer.visible_notification(announcement)
	program.computer.audible_notification("sound/machines/twobeep.ogg")

/// Mods may override to expose an expedition / sector map tab.
/datum/nano_module/program/newscast/proc/newscast_has_sector_map()
	return FALSE

/datum/nano_module/program/newscast/proc/newscast_append_sector_data(list/data, mob/user)
	return

/datum/nano_module/program/newscast/proc/newscast_ui_template()
	return "newscast.tmpl"

/datum/nano_module/program/newscast/Destroy()
	if (connected_group)
		LAZYREMOVE(connected_group.news_programs, src)
	. = ..()

/datum/nano_module/program/newscast/Topic(href, href_list)
	if(..())
		return TRUE

	if (href_list["view_channel"])
		// We cache a byond text ref of the selected channel, and use it here to get a proper DM pointer to that channel
		var/datum/feed_channel/new_feed = locate(href_list["view_channel"]) in connected_group.network_channels
		if (istype(new_feed))
			active_channel = new_feed // and then if it's valid, it becomes our new active channel
			prog_state = NEWSCAST_VIEW_CHANNEL
		return TRUE

	else if (href_list["view_photo"])
		var/datum/feed_message/story = locate(href_list["view_photo"]) in active_channel.messages
		if (istype(story) && story.img)
			send_rsc(usr, story.img, "tmp_photo.png")
			var/output = "<html><head><title>photo - [story.author]</title></head>"
			output += "<body style='overflow:hidden; margin:0; text-align:center'>"
			output += "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor;image-rendering:pixelated;' />"
			output += "</body></html>"
			show_browser(usr, output, "window=book; size=192x192]")
		return TRUE

	else if (href_list["toggle_notifs"])
		notifs_enabled = !notifs_enabled
		return TRUE

	else if (href_list["view_sector_map"])
		if (!newscast_has_sector_map())
			return TRUE
		prog_state = NEWSCAST_SECTOR_MAP
		active_channel = null
		return TRUE

	else if (href_list["return_to_home"])
		active_channel = null
		prog_state = NEWSCAST_HOME
		return TRUE

	else if (href_list["odyssey_inspect"] || href_list["action"] == "odyssey_inspect")
		if (!newscast_has_sector_map())
			return TRUE
		var/sector_id = href_list["odyssey_inspect"] || href_list["target"]
		if (sector_id)
			viewed_sector_id = sector_id
			prog_state = NEWSCAST_SECTOR_MAP
		return TRUE

	return FALSE

/datum/nano_module/program/newscast/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = host.initial_data(program)

	var/datum/computer_file/program/newscast/prog = program
	var/turf/T = get_turf(prog.computer.get_physical_host())
	if (!connected_group) // Look for a network connected to these z-levels
		for (var/datum/feed_network/G in news_network)
			if (T.z in G.z_levels)
				connected_group = G
				LAZYADD(G.news_programs, src)
				break
	else if (!(T.z in connected_group.z_levels)) // Lose our tracked group if we leave the network range but still have a connection
		prog.computer.visible_error("Newscaster connection lost. Attempting to re-establish.")
		LAZYREMOVE(connected_group.news_programs, src)
		connected_group = null

	if (!connected_group) // If we still fail to find a network, throw an error with no other data
		data["has_network"] = FALSE
	else // Otherwise, gather the data from the network
		data["has_network"] = TRUE
		data["notifs_enabled"] = notifs_enabled
		data["prog_state"] = prog_state
		data["time_blurb"] = "The date is <b>[stationdate2text()]</b> at <b>[stationtime2text()]</b>."
		data["notifs_blurb"] = "New story notifications are <b>[notifs_enabled ? "enabled" : "disabled"]</b>."
		data["dnotice_blurb"] = "<h2 style='font-color: red'>CHANNEL LOCKED</h2><br>\
		<span style='font-color: red'>This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<br><br> \
		Stories may not be published or viewed while the D-Notice is in effect. For further information, please contact the network administrator or a security representative.</span>"

		data["channels"] = list()
		data["active_channels"] = list() // There will only ever be one active channel, but we use this for unified handling in nanoUI
		for(var/datum/feed_channel/channel in connected_group.network_channels)
			var/list/channel_data = list()
			channel_data["name"] = channel.channel_name
			channel_data["admin"] = channel.is_admin_channel
			channel_data["censored"] = channel.censored
			channel_data["author"] = channel.author
			channel_data["ref"] = "\ref[channel]"

			data["channels"] += list(channel_data)
			if (channel == active_channel)
				data["active_channels"] += list(channel_data)

		if (active_channel)
			var/datum/feed_channel/feed = active_channel
			data["active_channel"] = feed
			data["active_stories"] = list()
			for (var/i = 1 to length(feed.messages))
				var/datum/feed_message/message = feed.messages[i]
				var/list/story = list()
				story["author"] = message.author
				story["body"] = message.body
				story["timestamp"] = message.time_stamp
				story["has_photo"] = message.img != null
				if (user && message.img) // user check here to avoid runtimes
					var/resource_name = "newscaster_photo_[feed.channel_id]_[i].png"
					send_asset(user.client, resource_name)
					story["photo_dat"] = "<img src='[resource_name]' width='180'><br>"
				story["story_ref"] = "\ref[message]"
				data["active_stories"] += list(story)

	data["prog_state"] = prog_state
	newscast_append_sector_data(data, user)
	if (prog_state == NEWSCAST_SECTOR_MAP && !data["odyssey_active"])
		prog_state = NEWSCAST_HOME
		data["prog_state"] = NEWSCAST_HOME
	data["show_sector_map"] = (prog_state == NEWSCAST_SECTOR_MAP && data["odyssey_active"])
	var/compact_map = FALSE
	if (program?.computer)
		compact_map = !!(program.computer.get_hardware_flag() & (PROGRAM_PDA | PROGRAM_TABLET))
	data["odyssey_compact"] = compact_map

	var/width = compact_map ? 540 : 450
	var/height = compact_map ? 680 : 600
	if (prog_state == NEWSCAST_SECTOR_MAP)
		if (compact_map)
			width = 560
			height = 740
		else
			width = 1000
			height = 720

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (ui)
		ui.set_window_size(width, height)
	else
		ui = new(user, src, ui_key, newscast_ui_template(), name, width, height, state = state)
		ui.auto_update_layout = 1
		ui.set_auto_update(1)
		ui.set_initial_data(data)
		ui.open()
