/mob/living/silicon/pai/paiInterface()
	ui_interact(src)

/mob/living/silicon/pai/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(user != src)
		if(ui) ui.set_status(STATUS_CLOSE, 0)
		return

	if(ui_key != "main")
		var/datum/pai_software/S = software[ui_key]
		if(S && !S.toggle)
			S.on_ui_interact(src, ui, force_open)
		else
			if(ui) ui.set_status(STATUS_CLOSE, 0)
		return

	var/data[0]

	// Software we have bought
	var/bought_software[0]
	// Software we have not bought
	var/not_bought_software[0]

	for(var/key in pai_software_by_key)
		var/datum/pai_software/S = pai_software_by_key[key]
		var/software_data[0]
		software_data["name"] = S.name
		software_data["id"] = S.id
		if(key in software)
			software_data["on"] = S.is_active(src)
			bought_software[LIST_PRE_INC(bought_software)] = software_data
		else
			software_data["ram"] = S.ram_cost
			not_bought_software[LIST_PRE_INC(not_bought_software)] = software_data

	data["bought"] = bought_software
	data["not_bought"] = not_bought_software
	data["available_ram"] = ram
	data["holoproj"] = is_advanced_holo
	data["hackcover"] = is_hack_covered
	data["hackspeed"] = hack_speed

	// Emotions
	var/emotions[0]
	for(var/name in pai_emotions)
		var/emote[0]
		emote["name"] = name
		emote["id"] = pai_emotions[name]
		emotions[LIST_PRE_INC(emotions)] = emote

	data["emotions"] = emotions
	data["current_emotion"] = card.current_emotion

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "pai_interface.tmpl", "pAI Software Interface", 450, 600)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
