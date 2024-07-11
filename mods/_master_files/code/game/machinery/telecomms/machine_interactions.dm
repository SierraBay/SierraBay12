/obj/machinery/telecomms/interact(mob/user)
	ui_interact(user)
	return

/obj/machinery/telecomms/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/telecomms/proc/compile_data(mob/user)
	var/data[0]
	data["toggled"] = toggled
	data["id"] = id
	data["network"] = network
	data["prefabrication"] = LAZYLEN(autolinkers) > 0
	data["toggled"] = toggled
	data["temp"] = temp
	data["links"] = list()

	var/i = 1
	var/dataLinks[0]
	for(var/obj/machinery/telecomms/T in links)
		if(T.hide && !src.hide)
			continue
		dataLinks[LIST_PRE_INC(dataLinks)] = list("name" = T.name, "id" = T.id, "index" = i)
		i++
	data["links"] = dataLinks

	var/dataFreq[0]
	for(var/freq in freq_listening)
		var/list/tagRule
		var/tag_index = 1
		for(var/rule in channel_tags)
			if(rule[1] == freq)
				tagRule = list("name" = rule[2], "color" = rule[3])
		dataFreq[LIST_PRE_INC(dataFreq)] = list( "freq" = freq, "freq_format" = format_frequency(freq), "tag_rule" = tagRule, "tag_index" = tag_index)

	data["frequencies"] = dataFreq

	data["buffer"] = 0
	if(user)
		var/obj/item/device/multitool/multitool = get_multitool(user)
		if(multitool)
			var/obj/machinery/telecomms/device = multitool.get_buffer()
			if(istype(device))
				data["buffer"] = list("device" = device.name, "id" = device.id)

	return data

/obj/machinery/telecomms/

/obj/machinery/telecomms/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.outside_state)
	var/data = compile_data(user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-telecomms.tmpl", id, 400, 600, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/telecomms/Topic(href, href_list)
	return OnTopic(usr, href_list)

/obj/machinery/telecomms/OnTopic(user, href_list)
	if(..())
		return TRUE
	temp = ""

	if(href_list["toggle"])
		src.toggled = !src.toggled
		temp = "[src] has been [src.toggled ? "activated" : "deactivated"]."
		update_power()

	if(href_list["id"])
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
		if(newid && canAccess(usr))
			id = newid
			temp = "New ID assigned: \"[id]\""

	if(href_list["network"])
		var/newnet = input(usr, "Specify the new network for this machine. This will break all current links.", src, network) as null|text
		if(newnet && canAccess(usr))
			if(length(newnet) > 15)
				temp = "Too many characters in new network tag"
			else
				for(var/obj/machinery/telecomms/T in links)
					T.links.Remove(src)
				network = newnet
				links = list()
				temp = "New network tag assigned: \"[network]\""

	if(href_list["unlink"])
		if(text2num(href_list["unlink"]) <= length(links))
			var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
			temp = "Removed \ref[T] [T.name] from linked entities."

			// Remove link entries from both T and src.
			if(src in T.links)
				T.links.Remove(src)
			links.Remove(T)

	if(href_list["delete"])
		var/x = text2num(href_list["delete"])
		temp = "Removed frequency filter [x]"
		var/rule_delete
		for(var/list/rule in channel_tags)
			if(rule[1] == x)
				rule_delete = rule
				to_chat(user, "found [rule[1]] [rule[2]] [rule[3]]")
				break
		if(rule_delete)
			to_chat(user, "found2 [rule_delete[1]] [rule_delete[2]] [rule_delete[3]]")
			channel_tags.Remove(list(rule_delete))
		freq_listening.Remove(x)

	if(href_list["add_freq"])
		var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
		if(newfreq && canAccess(usr))
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(!(newfreq in freq_listening) && newfreq < 10000)
				freq_listening.Add(newfreq)
				temp = "New frequency filter assigned: \"[newfreq] GHz\""

	if(href_list["tagrule"])
		var/freq = input(usr, "Specify frequency to tag (GHz). Decimals assigned automatically.", src, network) as null|num
		if(freq && canAccess(usr))
			if(findtext(num2text(freq), "."))
				freq *= 10

			if(!(freq in freq_listening))
				temp = "Not filtering specified frequency"
				updateUsrDialog()
				return

			for(var/list/rule in channel_tags)
				if(rule[1] == freq)
					temp = "Tagging rule already defined"
					updateUsrDialog()
					return

			var/tag = input(usr, "Specify tag.", src, "") as null|text
			var/color = input(usr, "Select color.", src, "") as null|anything in (channel_color_presets + "Custom color")

			if(color == "Custom color")
				color = input("Select color.", src, rgb(0, 128, 0)) as null|color
			else
				color = channel_color_presets[color]

			if(freq < 10000)
				channel_tags.Add(list(list(freq, tag, color)))
				temp = "New tagging rule assigned:[freq] GHz -> \"[tag]\" ([color])"

	/// Multitool interactions

	var/obj/item/device/multitool/multitool = get_multitool(user)
	if(href_list["link"])
		if(multitool)
			var/obj/machinery/telecomms/device = multitool.get_buffer()
			if(istype(device) && device != src)
				if(!(src in device.links))
					device.links.Add(src)

				if(!(device in src.links))
					src.links.Add(device)

				temp = "Successfully linked with \ref[device] [device.name]"

			else
				temp = "Unable to acquire buffer"

	if(href_list["buffer"])
		multitool.set_buffer(src)
		var/atom/buffer = multitool.get_buffer()
		temp = "Successfully stored \ref[buffer] [buffer.name] in buffer"

	if(href_list["flush_buffer"])
		temp = "Buffer successfully flushed."
		multitool.set_buffer(null)

	return TRUE

/obj/machinery/telecomms/use_tool(obj/item/P, mob/living/user, list/click_params)
	// Using a multitool lets you access the receiver's interface
	if(isMultitool(P))
		ui_interact(user)
		return TRUE

	// REPAIRING: Use Nanopaste to repair 10-20 integrity points.
	if(istype(P, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/T = P
		if (integrity < 100)
			if (T.use(1))
				integrity = clamp(integrity + rand(10, 20), 0, 100)
				to_chat(usr, "You apply the Nanopaste to [src], repairing some of the damage.")
		else
			to_chat(usr, "This machine is already in perfect condition.")
		return TRUE

	return ..()
