#define BAR_CAP 12

/mob/living/exosuit/proc/refresh_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				pilot.client.screen |= hud_elements
	if(client)
		client.screen |= hud_elements


/mob/living/exosuit/handle_hud_icons()
	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		if(H) H.update_system_info()
	handle_hud_icons_health()
	var/obj/item/cell/C = get_cell()
	if(istype(C))
		hud_power.maptext_x = initial(hud_power.maptext_x)
		hud_power.maptext_y = initial(hud_power.maptext_y)
		hud_power.maptext = STYLE_SMALLFONTS_OUTLINE("[round(get_cell().charge)]/[round(get_cell().maxcharge)]", 7, COLOR_WHITE, COLOR_BLACK)
	else
		hud_power.maptext_x = 16
		hud_power.maptext_y = -8
		hud_power.maptext = STYLE_SMALLFONTS_OUTLINE("CHECK POWER", 7, COLOR_WHITE, COLOR_BLACK)

	refresh_hud()

///Работает ли система диагностики: меху нужны питание и исправный блок диагностики
/mob/living/exosuit/proc/has_working_diagnostics()
	var/obj/item/cell/cell = get_cell()
	if(!body || !cell || cell.charge <= 0)
		return FALSE
	return body.diagnostics?.is_functional() ? TRUE : FALSE

///Сообщение пилотам от системы диагностики. Без неё мех молчит
/mob/living/exosuit/proc/diagnostics_alert(message)
	if(!has_working_diagnostics())
		return
	for(var/mob/living/pilot in pilots)
		to_chat(pilot, SPAN_WARNING("Diagnostics: [message]"))

/mob/living/exosuit/handle_hud_icons_health()

	hud_health.ClearOverlays()

	if(!body || !get_cell() || (get_cell().charge <= 0))
		return

	if(!body.diagnostics || !body.diagnostics.is_functional() || ((emp_damage>EMP_GUI_DISRUPT) && prob(emp_damage*2)))
		if(!GLOB.mech_damage_overlay_cache["critfail"])
			GLOB.mech_damage_overlay_cache["critfail"] = image(icon='icons/mecha/mech_hud.dmi',icon_state="dam_error")
		hud_health.AddOverlays(GLOB.mech_damage_overlay_cache["critfail"])
		return

	var/list/part_to_state = list("body" = body,"head" = head, "right_arm" = R_arm, "left_arm" = L_arm, "right_leg" = R_leg, "left_leg" = L_leg)
	for(var/part in part_to_state)
		var/state = 0
		var/obj/item/mech_component/MC = part_to_state[part]
		if(MC)
			if((emp_damage>EMP_GUI_DISRUPT) && prob(emp_damage*3))
				state = rand(0,4)
			else
				state = MC.damage_state
		if(!GLOB.mech_damage_overlay_cache["[part]-[state]"])
			var/image/I = image(icon='mods/mechs_by_shegar/icons/mech_hud.dmi',icon_state="dam_[part]")
			switch(state)
				if(1)
					I.color = "#00ff00"
				if(2)
					I.color = "#f2c50d"
				if(3)
					I.color = "#ea8515"
				if(4)
					I.color = "#ff0000"
				else
					I.color = "#f5f5f0"
			GLOB.mech_damage_overlay_cache["[part]-[state]"] = I
		hud_health.AddOverlays(GLOB.mech_damage_overlay_cache["[part]-[state]"])

/mob/living/exosuit/proc/reset_hardpoint_color()
	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		if(H)
			H.color = COLOR_WHITE

/mob/living/exosuit/setClickCooldown(timeout)
	. = ..()
	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		if(H)
			H.color = "#a03b3b"
			animate(H, color = COLOR_WHITE, time = timeout, easing = CUBIC_EASING | EASE_IN)
	addtimer(new Callback(src, .proc/reset_hardpoint_color), timeout)
