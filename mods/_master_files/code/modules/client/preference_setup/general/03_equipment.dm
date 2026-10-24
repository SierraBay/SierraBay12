// Donor TGUI dialogs, retaining Sierra character and loadout mechanics.
/datum/category_item/player_setup_item/physical/equipment/OnTopic(href,list/href_list, mob/user)
	if(href_list["change_underwear"])
		var/datum/category_group/underwear/UWC = GLOB.underwear.categories_by_name[href_list["change_underwear"]]
		if(!UWC)
			return TOPIC_NOACTION
		var/datum/category_item/underwear/selected_underwear = tgui_input_list(user, "Choose underwear:", CHARACTER_PREFERENCE_INPUT_TITLE, UWC.items, pref.all_underwear[UWC.name])
		if(selected_underwear && CanUseTopic(user))
			pref.all_underwear[UWC.name] = selected_underwear.name
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["underwear"] && href_list["tweak"])
		var/underwear = href_list["underwear"]
		if(!(underwear in pref.all_underwear))
			return TOPIC_NOACTION
		var/datum/gear_tweak/gt = locate(href_list["tweak"])
		if(!gt)
			return TOPIC_NOACTION
		var/new_metadata = gt.get_metadata(user, get_underwear_metadata(underwear, gt))
		if(new_metadata)
			set_underwear_metadata(underwear, gt, new_metadata)
			return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["change_backpack"])
		var/new_backpack = tgui_input_list(user, "Choose backpack style:", CHARACTER_PREFERENCE_INPUT_TITLE, backpacks_by_name, pref.backpack)
		if(!isnull(new_backpack) && CanUseTopic(user))
			pref.backpack = backpacks_by_name[new_backpack]
			return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["backpack"] && href_list["tweak"])
		var/backpack_name = href_list["backpack"]
		if(!(backpack_name in backpacks_by_name))
			return TOPIC_NOACTION
		var/singleton/backpack_outfit/bo = backpacks_by_name[backpack_name]
		var/datum/backpack_tweak/bt = locate(href_list["tweak"]) in bo.tweaks
		if(!bt)
			return TOPIC_NOACTION
		var/new_metadata = bt.get_metadata(user, get_backpack_metadata(bo, bt))
		if(new_metadata)
			set_backpack_metadata(bo, bt, new_metadata)
			return TOPIC_REFRESH_UPDATE_PREVIEW
	else if(href_list["change_sensor_setting"])
		var/switchMode = tgui_input_list(user, "Select a sensor mode:", "Suit Sensor Mode", SUIT_SENSOR_MODES, pref.sensor_setting)
		if(!switchMode || !CanUseTopic(user))
			return TOPIC_NOACTION
		pref.sensor_setting = switchMode
		return TOPIC_REFRESH
	else if(href_list["toggle_sensors_locked"])
		pref.sensors_locked = !pref.sensors_locked
		return TOPIC_REFRESH

	return ..()
