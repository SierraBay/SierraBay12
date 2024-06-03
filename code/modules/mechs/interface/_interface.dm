#define BAR_CAP 12

/mob/living/exosuit/proc/refresh_hud()
	if(LAZYLEN(pilots))
		for(var/thing in pilots)
			var/mob/pilot = thing
			if(pilot.client)
				pilot.client.screen |= hud_elements
				//[SIERRA-ADD] - Mechs-by-Shegar
				//pilot.client.screen -= menu_hud_elements?
				//[SIERRA-ADD]
	if(client)
		client.screen |= hud_elements

/mob/living/exosuit/InitializeHud()
	zone_sel = new
	if(!LAZYLEN(hud_elements))
		var/i = 1
		for(var/hardpoint in hardpoints)
			var/obj/screen/movable/exosuit/hardpoint/H = new(src, hardpoint)
			H.screen_loc = "1:6,[15-i]" //temp
			hud_elements |= H
			hardpoint_hud_elements[hardpoint] = H
			i++
		//[SIERRA-EDIT] - Mechs-by-Shegar
		/*
		var/list/additional_hud_elements = list(
			/obj/screen/exosuit/toggle/power_control,
			/obj/screen/exosuit/toggle/maint,
			/obj/screen/exosuit/eject,
			/obj/screen/exosuit/toggle/hardpoint,
			/obj/screen/exosuit/toggle/hatch,
			/obj/screen/exosuit/toggle/hatch_open,
			/obj/screen/exosuit/radio,
			/obj/screen/exosuit/rename,
			/obj/screen/exosuit/toggle/camera
			)
		*/
		var/list/main_hud_elements = list(
			/obj/screen/movable/exosuit/toggle/power_control,
			/obj/screen/movable/exosuit/eject,
			/obj/screen/movable/exosuit/toggle/hatch,
			/obj/screen/movable/exosuit/toggle/hatch_open,
			/obj/screen/movable/exosuit/toggle/menu,
			)
		if(body && body.pilot_coverage >= 100)
			main_hud_elements += /obj/screen/movable/exosuit/toggle/air
		var/list/additional_hud_elements = list(
			/obj/screen/movable/exosuit/toggle/camera,
			/obj/screen/movable/exosuit/rename,
			/obj/screen/movable/exosuit/radio,
			/obj/screen/movable/exosuit/toggle/hardpoint,
			/obj/screen/movable/exosuit/toggle/maint,
			/obj/screen/movable/exosuit/toggle/megaspeakers,
			/obj/screen/movable/exosuit/toggle/gps,
			/obj/screen/movable/exosuit/toggle/medscan,
		)
		//[SIERRA-EDIT]
		i = 0
		var/pos = 8
		for(var/additional_hud in main_hud_elements)
			var/obj/screen/movable/exosuit/M = new additional_hud(src)
			M.screen_loc = "1:6,[pos]:[i]"
			hud_elements |= M
			i -= M.height
		//[SIERRA-ADD] - Mechs-by-Shegar - отрисовка menu кнопачек
		i = 0
		for(var/additional_hud in additional_hud_elements)
			var/obj/screen/movable/exosuit/M = new additional_hud(src)
			M.screen_loc = "2:6,[pos]:[i]"
			menu_hud_elements |= M
			i -= M.height
		//[SIERRA-ADD] - Mechs-by-Shegar
		hud_health = new /obj/screen/movable/exosuit/health(src)
		hud_health.screen_loc = "EAST-1:28,CENTER-3:11"
		hud_elements |= hud_health
		hud_open = locate(/obj/screen/movable/exosuit/toggle/hatch_open) in hud_elements
		hud_power = new /obj/screen/movable/exosuit/power(src)
		hud_power.screen_loc = "EAST-1:24,CENTER-4:25"
		hud_elements |= hud_power
		hud_power_control = locate(/obj/screen/movable/exosuit/toggle/power_control) in hud_elements
		hud_camera = locate(/obj/screen/movable/exosuit/toggle/camera) in menu_hud_elements
		hud_heat = new /obj/screen/movable/exosuit/heat(src)
		hud_heat.screen_loc = "EAST-1:28,CENTER-4"
		hud_elements |= hud_heat

	refresh_hud()
	refresh_menu_hud()

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

/mob/living/exosuit/handle_hud_icons_health()

	hud_health.ClearOverlays()

	if(!body || !get_cell() || (get_cell().charge <= 0))
		return

	if(!body.diagnostics || !body.diagnostics.is_functional() || ((emp_damage>EMP_GUI_DISRUPT) && prob(emp_damage*2)))
		if(!GLOB.mech_damage_overlay_cache["critfail"])
			GLOB.mech_damage_overlay_cache["critfail"] = image(icon='icons/mecha/mech_hud.dmi',icon_state="dam_error")
		hud_health.AddOverlays(GLOB.mech_damage_overlay_cache["critfail"])
		return

	var/list/part_to_state = list("legs" = legs,"body" = body,"head" = head,"arms" = arms)
	for(var/part in part_to_state)
		var/state = 0
		var/obj/item/mech_component/MC = part_to_state[part]
		if(MC)
			if((emp_damage>EMP_GUI_DISRUPT) && prob(emp_damage*3))
				state = rand(0,4)
			else
				state = MC.damage_state
		if(!GLOB.mech_damage_overlay_cache["[part]-[state]"])
			var/image/I = image(icon='icons/mecha/mech_hud.dmi',icon_state="dam_[part]")
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
	addtimer(new Callback(src, PROC_REF(reset_hardpoint_color)), timeout)
