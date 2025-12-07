/obj/machinery/suit_storage_unit
	icon = 'maps/sierra/icons/obj/suitstorage.dmi'
	icon_state = "industrial"
	var/base_icon_state = "industrial"
	var/ssu_color = "color_overlay_colorable"

/obj/machinery/suit_storage_unit/on_update_icon()
	ClearOverlays()
	if(ssu_color)
		var/image/I = image(icon = icon, icon_state = "[base_icon_state]_colorable")
		I.appearance_flags |= RESET_COLOR
		I.color = ssu_color
		AddOverlays(I)
	//if things arent powered, these show anyways
	if(panelopen)
		AddOverlays(image(icon,"[base_icon_state]_panel"))

	if(isopen)
		AddOverlays(image(icon,"[base_icon_state]_open"))
		if(suit)
			AddOverlays(image(icon,"[base_icon_state]_suit"))
		if(helmet)
			AddOverlays(image(icon,"[base_icon_state]_helm"))
		if(boots || tank || mask)
			AddOverlays(image(icon,"[base_icon_state]_storage"))
		if(isUV && issuperUV)
			AddOverlays(image(icon,"[base_icon_state]_super"))

	if(!MACHINE_IS_BROKEN(src))
		if(isopen)
			AddOverlays(image(icon,"[base_icon_state]_lights_open"))
		else
			if(isUV)
				AddOverlays(image(icon,"[base_icon_state]_lights_red"))
			else
				AddOverlays(image(icon,"[base_icon_state]_lights_closed"))
		//top lights
		if(isUV)
			if(issuperUV)
				AddOverlays(overlay_image(icon,"[base_icon_state]_uvstrong", plane = EFFECTS_ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER))
			else
				AddOverlays(overlay_image(icon,"[base_icon_state]_uv", plane = EFFECTS_ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER))
		if(islocked)
			AddOverlays(overlay_image(icon, "[base_icon_state]_locked", plane = EFFECTS_ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER))
		else
			AddOverlays(overlay_image(icon, "[base_icon_state]_ready", plane = EFFECTS_ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER))

/obj/machinery/suit_storage_unit/toggle_lock(mob/user)
	if(!is_powered())
		to_chat(user, SPAN_NOTICE("The unit is offline."))
		return
	if(!allowed(user))
		FEEDBACK_ACCESS_DENIED(user, src)
		return
	if(occupant && safetieson)
		to_chat(user, SPAN_WARNING("The Unit's safety protocols disallow locking when a biological form is detected inside its compartments."))
		return
	if(isopen)
		return
	islocked = !islocked
	playsound(src, 'sound/machines/suitstorage_lockdoor.ogg', 50, 0)
	update_icon()
