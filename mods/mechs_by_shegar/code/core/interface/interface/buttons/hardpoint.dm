#define BAR_CAP 12

/obj/screen/movable/exosuit/hardpoint
	name = "hardpoint"
	var/hardpoint_tag
	var/obj/item/holding
	icon_state = "hardpoint"

	maptext_x = 34
	maptext_y = 3
	maptext_width = 72

/obj/screen/movable/exosuit/hardpoint/proc/update_system_info()

	// No point drawing it if we have no item to use or nobody to see it.
	if(!owner)
		return FALSE
	if(!holding)
		maptext = null
		if(LAZYLEN(overlays))
			ClearOverlays()
		return FALSE

	var/has_pilot_with_client = owner.client
	if(!has_pilot_with_client && LAZYLEN(owner.pilots))
		for(var/thing in owner.pilots)
			var/mob/pilot = thing
			if(pilot.client)
				has_pilot_with_client = TRUE
				break
	if(!has_pilot_with_client)
		return

	var/list/new_overlays = list()
	if(!owner.get_cell() || (owner.get_cell().charge <= 0))
		ClearOverlays()
		maptext = ""
		return

	maptext =  SPAN_STYLE("font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 7px;", "[holding.get_hardpoint_maptext()]")

	var/ui_damage = (!owner.body.diagnostics || !owner.body.diagnostics.is_functional() || ((owner.emp_damage>EMP_GUI_DISRUPT) && prob(owner.emp_damage)))

	var/value = holding.get_hardpoint_status_value()
	if(isnull(value))
		ClearOverlays()
		return

	if(ui_damage)
		value = -1
		maptext = SPAN_STYLE("font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 7px;", "ERROR")
	else
		if((owner.emp_damage>EMP_GUI_DISRUPT) && prob(owner.emp_damage*2))
			if(prob(10))
				value = -1
			else
				value = rand(1,BAR_CAP)
		else
			value = round(value * BAR_CAP)

	// Draw background.
	if(!GLOB.default_hardpoint_background)
		GLOB.default_hardpoint_background = image(icon = 'icons/mecha/mech_hud.dmi', icon_state = "bar_bkg")
		GLOB.default_hardpoint_background.pixel_x = 34
	new_overlays += GLOB.default_hardpoint_background

	if(value == 0)
		if(!GLOB.hardpoint_bar_empty)
			GLOB.hardpoint_bar_empty = image(icon='icons/mecha/mech_hud.dmi',icon_state="bar_flash")
			GLOB.hardpoint_bar_empty.pixel_x = 24
			GLOB.hardpoint_bar_empty.color = "#ff0000"
		new_overlays += GLOB.hardpoint_bar_empty
	else if(value < 0)
		if(!GLOB.hardpoint_error_icon)
			GLOB.hardpoint_error_icon = image(icon='icons/mecha/mech_hud.dmi',icon_state="bar_error")
			GLOB.hardpoint_error_icon.pixel_x = 34
		new_overlays += GLOB.hardpoint_error_icon
	else
		value = min(value, BAR_CAP)
		// Draw statbar.
		if(!LAZYLEN(GLOB.hardpoint_bar_cache))
			for(var/i=0;i<BAR_CAP;i++)
				var/image/bar = image(icon='icons/mecha/mech_hud.dmi',icon_state="bar")
				bar.pixel_x = 24+(i*2)
				if(i>5)
					bar.color = "#00ff00"
				else if(i>1)
					bar.color = "#ffff00"
				else
					bar.color = "#ff0000"
				GLOB.hardpoint_bar_cache += bar
		for(var/i=1;i<=value;i++)
			new_overlays += GLOB.hardpoint_bar_cache[i]
	SetOverlays(new_overlays)

/obj/screen/movable/exosuit/hardpoint/MouseDrop()
	..()
	if(holding)
		holding.screen_loc = screen_loc



/obj/screen/movable/exosuit/hardpoint/Initialize(mapload, newtag)
	. = ..()
	hardpoint_tag = newtag
	name = "hardpoint ([hardpoint_tag])"

/obj/screen/movable/exosuit/hardpoint/Click(location, control, params)
	if(!owner?.hatch_closed)
		to_chat(usr, SPAN_WARNING("Error: Hardpoint interface disabled while cockpit is open."))
		return

	var/modifiers = params2list(params)
	if(modifiers["ctrl"])
		if(owner.remove_system(hardpoint_tag))
			to_chat(usr, SPAN_NOTICE("You disengage and discard the system mounted to your [hardpoint_tag] hardpoint."))
		else
			to_chat(usr, SPAN_DANGER("You fail to remove the system mounted to your [hardpoint_tag] hardpoint."))
		return

	if(owner.selected_hardpoint == hardpoint_tag)
		icon_state = "hardpoint"
		owner.clear_selected_hardpoint()
	else
		if(owner.set_hardpoint(hardpoint_tag))
			icon_state = "hardpoint_selected"

#undef BAR_CAP


/mob/living/exosuit/proc/clear_selected_hardpoint()
	if(selected_hardpoint)
		for(var/hardpoint in hardpoints)
			if(hardpoint != selected_hardpoint)
				continue
			var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
			if(istype(H))
				H.icon_state = "hardpoint"
				break
		selected_system = null
	selected_hardpoint = null

/mob/living/exosuit/proc/set_hardpoint(hardpoint_tag)
	clear_selected_hardpoint()
	if(hardpoints[hardpoint_tag])
		// Set the new system.
		selected_system = hardpoints[hardpoint_tag]
		selected_hardpoint = hardpoint_tag
		if(selected_hardpoint == HARDPOINT_RIGHT_HAND)
			active_arm = R_arm
		else
			active_arm = L_arm
		return 1 // The element calling this proc will set its own icon.
	return 0

//Функция обновляет спрайты у выбранных модулей(спрайты хардпоинтов)
/mob/living/exosuit/proc/update_selected_hardpoint(do_sound = FALSE, obj/screen/movable/exosuit/hardpoint, obj/screen/movable/exosuit/prev_hardpoint)
	if(hardpoint == prev_hardpoint)
		return
	if(!hardpoint)
		hardpoint = hardpoint_hud_elements[selected_hardpoint]
	if(hardpoint)
		hardpoint.icon_state = "hardpoint_selected"
	if(prev_hardpoint)
		prev_hardpoint.icon_state = "hardpoint"
	if(do_sound)
		playsound(src, 'mods/mechs_by_shegar/sounds/mech_swap_weapon.ogg', 50, 0)
