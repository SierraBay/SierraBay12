/client/proc/set_chat_output(use_browser)
	// Separate panes prevent BYOND 516 from revealing legacy output over the chat.
	if(winexists(src, "legacy_output_selector"))
		winset(src, "legacy_output_selector", use_browser ? "left=output_browser" : "left=output_legacy")
		return
	// Preserve chat switching for custom skins using the original layout.
	winset(src, "output", use_browser ? "is-visible=false" : "is-visible=true;is-disabled=false")
	winset(src, "browseroutput", use_browser ? "is-disabled=false;is-visible=true" : "is-disabled=true;is-visible=false")

/proc/log_tgui(user_or_client, text, context)
	if(!text)
		return
	log_debug("TGUI[context ? " ([context])" : ""] [key_name(user_or_client)]: [text]")

/// Return HTML to load an asset URL, including assets hosted on a CDN.
/proc/url2htmlloader(url)
	return {"<html><head><meta http-equiv="refresh" content="0;URL='[url]'"/></head><body onLoad="parent.location='[url]'"></body></html>"}

/// Donor list inputs distinguish objects sharing the same display name.
/proc/avoid_assoc_duplicate_keys(input_key, list/used_key_list)
	if(!input_key || !istype(used_key_list))
		return
	if(used_key_list[input_key])
		used_key_list[input_key]++
		input_key = "[input_key] ([used_key_list[input_key]])"
	else
		used_key_list[input_key] = 1
	return input_key

/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length = MAX_MESSAGE_LEN, no_trim = FALSE)
	var/user_input = input(user, message, title, default) as text|null
	if(isnull(user_input))
		return
	user_input = html_encode(user_input)
	return copytext_char(no_trim ? user_input : trimtext(user_input), 1, max_length + 1)

/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length = MAX_MESSAGE_LEN, no_trim = FALSE)
	var/user_input = input(user, message, title, default) as message|null
	if(isnull(user_input))
		return
	user_input = html_encode(user_input)
	return copytext_char(no_trim ? user_input : trimtext(user_input), 1, max_length + 1)

/datum/tgui/Destroy()
	if(!closing)
		close(can_be_suspended = FALSE)
	user = null
	src_object = null
	window = null
	state = null
	parent_ui = null
	children = null
	return ..()

/datum/tgui_window/Destroy()
	clear_oversized_payloads()
	if(locked_by && !QDELETED(locked_by))
		locked_by.close(can_be_suspended = FALSE)
	if(client?.tgui_windows?[id] == src)
		client.tgui_windows -= id
	client = null
	locked_by = null
	subscriber_object = null
	subscriber_delegate = null
	message_queue = null
	sent_assets = null
	initial_assets = null
	return ..()

/datum/tgui_module/Destroy()
	host = null
	return ..()

/proc/tgui_product_image(item_path)
	if(!ispath(item_path, /atom))
		return null
	var/static/list/product_images = list()
	if(!product_images[item_path])
		var/atom/item_type = item_path
		if(!initial(item_type.icon))
			return null
		product_images[item_path] = icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), SOUTH, 1))
	return product_images[item_path]

