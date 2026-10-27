// Donor TGUI dialogs, retaining Sierra character and loadout mechanics.
/datum/gear_tweak/color/get_metadata(user, metadata, title = CHARACTER_PREFERENCE_INPUT_TITLE)
	if(valid_colors)
		return tgui_input_list(user, "Choose a color.", title, valid_colors, metadata)
	return input(user, "Choose a color.", title, metadata) as color|null


/datum/gear_tweak/path/get_metadata(user, metadata, title)
	return tgui_input_list(user, "Choose a type.", CHARACTER_PREFERENCE_INPUT_TITLE, valid_paths, metadata)


/datum/gear_tweak/contents/get_metadata(user, list/metadata, title)
	. = list()
	for(var/i = length(metadata) to (length(valid_contents) - 1))
		metadata += "Random"
	for(var/i = 1 to length(valid_contents))
		var/entry = tgui_input_list(user, "Choose an entry.", CHARACTER_PREFERENCE_INPUT_TITLE, (valid_contents[i] + list("Random", "None")), metadata[i])
		if(entry)
			. += entry
		else
			return metadata


/datum/gear_tweak/reagents/get_metadata(user, list/metadata, title)
	. = tgui_input_list(user, "Choose an entry.", CHARACTER_PREFERENCE_INPUT_TITLE, (valid_reagents + list("Random", "None")), metadata)
	if(!.)
		return metadata


/datum/gear_tweak/custom_var/get_metadata(user, metadata, title)
	var/final_title = title || input_title || CHARACTER_PREFERENCE_INPUT_TITLE
	if(length(valid_list_options))
		return tgui_input_list(user, input_message + " Click cancel to use the default.", final_title, valid_list_options, metadata)
	var/default = html_decode(metadata)
	return call(src, input_method)(user, input_message + " Leave blank to use the default.", final_title, default)


/datum/gear_tweak/custom_var/InputNum(mob/user, message, title, default)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/num = tgui_input_number(user, message, title, default, max_value = INFINITY, min_value = -INFINITY, round_value = FALSE)
	if (isnum(min_input_value))
		num = max(min_input_value, num)
	if (isnum(max_input_value))
		num = min(max_input_value, num)
	return num


/datum/gear_tweak/custom_var/InputText(mob/user, message, title, default, max_length)
	SHOULD_NOT_OVERRIDE(TRUE)
	return sanitize(tgui_input_text(user, message, title, default, multiline = FALSE, encode = FALSE), max_input_length || MAX_MESSAGE_LEN, extra = FALSE)


/datum/gear_tweak/custom_var/InputMessage(mob/user, message, title, default, max_length)
	SHOULD_NOT_OVERRIDE(TRUE)
	return sanitize(tgui_input_text(user, message, title, default, multiline = TRUE, encode = FALSE), max_input_length || MAX_MESSAGE_LEN, extra = FALSE)


/datum/gear_tweak/custom_name/get_metadata(user, metadata, title)
	if(valid_custom_names)
		return tgui_input_list(user, "Choose an item name.", "Character Preference", valid_custom_names, metadata)
	metadata = html_decode(metadata)
	return sanitize(tgui_input_text(user, "Choose the item's name. Leave it blank to use the default name.", "Item Name", metadata, multiline = FALSE, encode = FALSE), MAX_LNAME_LEN, extra = FALSE)


/datum/gear_tweak/custom_desc/get_metadata(user, metadata, title)
	if(valid_custom_desc)
		return tgui_input_list(user, "Choose an item description.", "Character Preference", valid_custom_desc, metadata)
	metadata = html_decode(metadata)
	return sanitize(tgui_input_text(user, "Choose the item's description. Leave it blank to use the default description.", "Item Description", metadata, multiline = TRUE, encode = FALSE), MAX_DESC_LEN, extra = FALSE)


/datum/gear_tweak/tablet/get_metadata(mob/user, metadata, title)
	. = list()
	if(!istype(user))
		return

	var/list/names = list()
	var/counter = 1
	for(var/i in ValidProcessors)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	var/entry = tgui_input_list(user, "Choose a processor.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidBatteries)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = tgui_input_list(user, "Choose a battery.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidHardDrives)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = tgui_input_list(user, "Choose a hard drive.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNetworkCards)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = tgui_input_list(user, "Choose a network card.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNanoPrinters)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = tgui_input_list(user, "Choose a nanoprinter.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidCardSlots)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = tgui_input_list(user, "Choose a card slot.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidTeslaLinks)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = tgui_input_list(user, "Choose a tesla link.", CHARACTER_PREFERENCE_INPUT_TITLE, names, null)
	. += names[entry]

