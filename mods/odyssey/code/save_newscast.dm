/// Persists station Newscast channels, stories, and photos across Odyssey shifts.
/// Photos live in a BYOND savefile next to newscast.json — icons cannot go through JSON.


/proc/odyssey_newscast_photos_path(generation)
	if (generation)
		return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_[generation]_newscast_photos.sav"
	return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_newscast_photos.sav"


/proc/odyssey_station_feed_network()
	for (var/datum/feed_network/G as anything in news_network)
		if (!istype(G))
			continue
		for (var/z in GLOB.using_map.station_levels)
			if (z in G.z_levels)
				return G
	return null


/proc/odyssey_ensure_station_feed_network()
	var/datum/feed_network/G = odyssey_station_feed_network()
	if (istype(G))
		return G
	G = new /datum/feed_network
	G.z_levels = GLOB.using_map.station_levels.Copy()
	LAZYADD(news_network, G)
	return G


/proc/odyssey_write_newscast_photo(savefile/photos, photo_id, icon/img)
	if (!photos || !photo_id || !isicon(img))
		return FALSE
	to_save(photos[photo_id], img)
	return TRUE


/proc/odyssey_read_newscast_photo(savefile/photos, photo_id)
	if (!photos || !photo_id)
		return null
	if (!(photo_id in photos.dir))
		return null
	var/icon/img
	from_save(photos[photo_id], img)
	if (!isicon(img))
		return null
	return img


/proc/odyssey_collect_newscast(generation)
	var/datum/feed_network/G = odyssey_station_feed_network()
	if (!istype(G))
		return list("channels" = list(), "wanted" = null)
	var/savefile/photos
	if (generation)
		var/photo_path = odyssey_newscast_photos_path(generation)
		if (fexists(photo_path))
			fdel(photo_path)
		photos = new /savefile(photo_path)
	var/list/channels = list()
	var/channel_index = 0
	for (var/datum/feed_channel/FC in G.network_channels)
		if (!istype(FC))
			continue
		channel_index += 1
		var/list/stories = list()
		var/story_index = 0
		for (var/datum/feed_message/M in FC.messages)
			if (!istype(M))
				continue
			story_index += 1
			stories += list(odyssey_newscast_message_entry(M, photos, "c[channel_index]_m[story_index]"))
		channels += list(list(
			"channel_name" = FC.channel_name,
			"author" = FC.author,
			"locked" = !!FC.locked,
			"censored" = !!FC.censored,
			"is_admin_channel" = !!FC.is_admin_channel,
			"announcement" = FC.announcement,
			"views" = FC.views,
			"messages" = stories
		))
	return list(
		"channels" = channels,
		"wanted" = odyssey_newscast_message_entry(G.wanted_issue, photos, "wanted")
	)


/proc/odyssey_newscast_message_entry(datum/feed_message/M, savefile/photos, photo_id)
	if (!istype(M))
		return null
	var/list/entry = list(
		"author" = M.author,
		"body" = M.body,
		"message_type" = M.message_type,
		"time_stamp" = M.time_stamp,
		"is_admin_message" = !!M.is_admin_message,
		"caption" = "[M.caption]",
		"backup_body" = M.backup_body,
		"backup_author" = M.backup_author,
		"has_photo" = isicon(M.img)
	)
	if (isicon(M.img) && odyssey_write_newscast_photo(photos, photo_id, M.img))
		entry["photo_id"] = photo_id
	if (isicon(M.backup_img) && odyssey_write_newscast_photo(photos, "[photo_id]_backup", M.backup_img))
		entry["backup_photo_id"] = "[photo_id]_backup"
	return entry


/proc/odyssey_restore_newscast_message(list/data, savefile/photos)
	if (!islist(data))
		return null
	var/datum/feed_message/M = new /datum/feed_message
	M.author = data["author"] || ""
	M.body = data["body"] || ""
	M.message_type = data["message_type"] || "Story"
	M.time_stamp = data["time_stamp"] || ""
	M.is_admin_message = !!data["is_admin_message"]
	M.caption = data["caption"] || ""
	M.backup_body = data["backup_body"] || ""
	M.backup_author = data["backup_author"] || ""
	if (data["photo_id"])
		M.img = odyssey_read_newscast_photo(photos, data["photo_id"])
	if (data["backup_photo_id"])
		M.backup_img = odyssey_read_newscast_photo(photos, data["backup_photo_id"])
	return M


/proc/odyssey_newscast_has_story(datum/feed_channel/FC, list/data)
	if (!istype(FC) || !islist(data))
		return FALSE
	var/body = data["body"]
	var/author = data["author"]
	var/stamp = data["time_stamp"]
	for (var/datum/feed_message/M in FC.messages)
		if (M.body == body && M.author == author && M.time_stamp == stamp)
			return TRUE
	return FALSE


/proc/odyssey_find_feed_channel(datum/feed_network/G, channel_name)
	if (!istype(G) || !channel_name)
		return null
	for (var/datum/feed_channel/FC in G.network_channels)
		if (FC.channel_name == channel_name)
			return FC
	return null


/proc/odyssey_apply_newscast(list/data, generation)
	if (!islist(data))
		return
	var/datum/feed_network/G = odyssey_ensure_station_feed_network()
	if (!istype(G))
		return
	var/savefile/photos
	if (generation)
		var/photo_path = odyssey_newscast_photos_path(generation)
		if (fexists(photo_path))
			photos = new /savefile(photo_path)
	var/restored = 0
	var/photo_count = 0
	for (var/list/channel_data in data["channels"])
		if (!islist(channel_data))
			continue
		var/channel_name = channel_data["channel_name"]
		if (!channel_name)
			continue
		var/datum/feed_channel/FC = odyssey_find_feed_channel(G, channel_name)
		if (!FC)
			G.CreateFeedChannel(channel_name, channel_data["author"] || "Unknown", !!channel_data["locked"], !!channel_data["is_admin_channel"], channel_data["announcement"])
			FC = odyssey_find_feed_channel(G, channel_name)
		if (!istype(FC))
			continue
		FC.author = channel_data["author"] || FC.author
		FC.locked = !!channel_data["locked"]
		FC.censored = !!channel_data["censored"]
		FC.is_admin_channel = !!channel_data["is_admin_channel"]
		if (channel_data["announcement"])
			FC.announcement = channel_data["announcement"]
		if (!isnull(channel_data["views"]))
			FC.views = channel_data["views"]
		for (var/list/story in channel_data["messages"])
			if (!islist(story) || odyssey_newscast_has_story(FC, story))
				continue
			var/datum/feed_message/M = odyssey_restore_newscast_message(story, photos)
			if (!M)
				continue
			FC.messages += M
			M.parent_channel = FC
			if (isicon(M.img))
				register_asset("newscaster_photo_[FC.channel_id]_[length(FC.messages)].png", M.img)
				photo_count++
			restored++
		FC.update()
	var/list/wanted = data["wanted"]
	if (islist(wanted) && wanted["body"] && !G.wanted_issue)
		G.wanted_issue = odyssey_restore_newscast_message(wanted, photos)
		if (isicon(G.wanted_issue?.img))
			photo_count++
	log_debug("ODYSSEY: apply_newscast stories=[restored] photos=[photo_count] channels=[length(data["channels"])]")
