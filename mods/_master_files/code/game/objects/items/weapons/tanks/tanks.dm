// TGUI
/obj/item/tank/tgui_state(mob/user)
	return GLOB.tgui_inventory_state


/obj/item/tank/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank", name)
		ui.open()


/obj/item/tank/tgui_data(mob/user)
	var/list/data = list()

	data["tankPressure"] = round(air_contents && air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(initial(distribute_pressure))
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["maximumPressure"] = round(10 * ONE_ATMOSPHERE)
	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc?.loc
	if(!istype(C))
		return data
	data["has_mask"] = !!(C.wear_mask?.item_flags & ITEM_FLAG_AIRTIGHT)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		data["has_mask"] ||= !!(H.head?.item_flags & ITEM_FLAG_AIRTIGHT)
	data["connected"] = (C.internal && C.internal == src) ? TRUE : FALSE

	return data


/obj/item/tank/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	user.set_machine(src)
	return tgui_interact(user)

/obj/item/tank/tgui_act(action, list/params)
	if(..())
		return
	add_fingerprint(usr)
	switch(action)
		if("pressure")
			if(params["pressure"] == "reset")
				distribute_pressure = initial(distribute_pressure)
			else if(isnum(params["pressure"]))
				distribute_pressure = clamp(round(params["pressure"]), 0, TANK_MAX_RELEASE_PRESSURE)
			else
				return FALSE
		if("internals")
			toggle_valve(usr)
		else
			return FALSE
	return TRUE
