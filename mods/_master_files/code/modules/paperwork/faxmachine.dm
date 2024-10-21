/obj/machinery/photocopier/faxmachine/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/photocopier/faxmachine/Topic(href, href_list)
	return OnTopic(usr, href_list)

/obj/machinery/photocopier/faxmachine/OnTopic(mob/user, href_list, state)
	if(..())
		return TRUE

	if(href_list["send"])
		if(copyitem)
			if (destination in GLOB.admin_departments)
				send_admin_fax(user, destination)
			else
				sendfax(destination)
		return TOPIC_REFRESH

	if(href_list["remove"])
		OnRemove(user)
		return TOPIC_REFRESH

	if(href_list["scan_card"])
		if (scan)
			if(ishuman(user))
				user.put_in_hands(scan)
			else
				scan.dropInto(loc)
			scan = null
			playsound(src, 'mods/newUI/sound/card_insert.ogg', 40)
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/card/id) && user.unEquip(I, src))
				scan = I
				playsound(src, 'mods/newUI/sound/card_insert.ogg', 40)
		authenticated = 0
		return TOPIC_REFRESH

	if(href_list["dept"])
		var/desired_destination = input(user, "Which department?", "Choose a department", "") as null|anything in (GLOB.alldepartments + GLOB.admin_departments)
		if(desired_destination && CanInteract(user, state))
			destination = desired_destination
		return TOPIC_REFRESH

	if(href_list["auth"])
		if (!authenticated && scan)
			if (has_access(send_access, scan.GetAccess()))
				authenticated = 1
		return TOPIC_REFRESH

	if(href_list["logout"])
		authenticated = 0
		return TOPIC_REFRESH

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/topic_state/state)
	var/data[0]
	data["name"] = department
	data["pdas"] = LAZYLEN(linked_pdas)
	data["authenticated"] = authenticated
	if(scan)
		data["scan"] = "[scan.registered_name ? scan.registered_name : "Unknown"] ([scan.assignment ? scan.assignment : "Unknown"])"
	data["network"] =  "[GLOB.using_map.boss_name] Network"
	if(copyitem)
		data["paper"] = copyitem.name
	data["destination"] = destination ? destination : "Nobody"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-faxmachine.tmpl", "Fax", 340, 400, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
