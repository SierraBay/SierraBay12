/obj/machinery/photocopier/interact(mob/user)
	ui_interact(user)
	return

/obj/machinery/photocopier/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/photocopier/
	var/max_toner = 30

/obj/machinery/photocopier/proc/compile_data(mob/user)
	var/data[0]
	if(copyitem)
		data["copyitem"] = TRUE
		data["copies"] = copies
	var/max_toner_capacity = toner <= max_toner ? max_toner : toner
	data["toner"] = toner
	data["toner_capacity"] = round(toner / max_toner_capacity * 100)
	data["max_toner"] = max_toner_capacity
	data["ai"] = istype(user,/mob/living/silicon)

	return data

/obj/machinery/photocopier/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.outside_state)
	var/data = compile_data(user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-photocopier.tmpl", "Photocopier", 400, 250, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/photocopier/Topic(href, href_list)
	return OnTopic(usr, href_list)

/obj/machinery/photocopier/OnTopic(mob/user, href_list)
	if(..())
		return TRUE

	if(href_list["copy_item"])
		for(var/i = 0, i < copies, i++)
			if(toner <= 0)
				break
			if (istype(copyitem, /obj/item/paper))
				playsound(src, 'mods/newUI/sound/printer.ogg', 40)
				copy(copyitem, 1)
				sleep(15)
			else if (istype(copyitem, /obj/item/photo))
				playsound(src, 'mods/newUI/sound/printer.ogg', 40)
				photocopy(copyitem)
				sleep(15)
			else if (istype(copyitem, /obj/item/paper_bundle))
				playsound(src, 'mods/newUI/sound/printer.ogg', 40)
				var/obj/item/paper_bundle/B = bundlecopy(copyitem)
				sleep(15*length(B.pages))
			else if (istype(copyitem, /obj/item/sample/print))
				playsound(src, 'mods/newUI/sound/printer.ogg', 40)
				fpcopy(copyitem)
				sleep(15)
			else
				to_chat(user, SPAN_WARNING("\The [copyitem] can't be copied by \the [src]."))
				break

			use_power_oneoff(active_power_usage)
		return TOPIC_REFRESH

	if(href_list["eject_item"])
		OnRemove(user)
		return TOPIC_REFRESH

	if(href_list["eject_toner"])
		if(toner)
			var/obj/item/device/toner/newToner = new()
			newToner.toner_amount = toner
			user.put_in_hands(newToner)
			toner = 0
			to_chat(user, SPAN_NOTICE("You take toner out of [src]."))
			return TOPIC_REFRESH


	if(href_list["set_count"])
		var/new_count = input(usr, "Set new copies count.", "New copies value") as null|num
		if(new_count && new_count > 0 && new_count <= maxcopies)
			copies = new_count
		else
			to_chat(user, "Value must be between 1 and 10")
		return TOPIC_REFRESH

	if(href_list["aipic"])
		if(!istype(user,/mob/living/silicon))
			return

		if(toner >= 5)
			var/mob/living/silicon/tempAI = user
			var/obj/item/device/camera/siliconcam/camera = tempAI.silicon_camera

			if(!camera)
				return
			var/obj/item/photo/selection = camera.selectpicture()
			if (!selection)
				return

			var/obj/item/photo/p = photocopy(selection)
			if (p.desc == "")
				p.desc += "Copied by [tempAI.name]"
			else
				p.desc += " - Copied by [tempAI.name]"
			toner -= 5
			sleep(15)
		return TOPIC_REFRESH
