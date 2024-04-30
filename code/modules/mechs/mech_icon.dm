/proc/get_mech_image(decal, cache_key, cache_icon, image_colour, overlay_layer = FLOAT_LAYER)
	RETURN_TYPE(/image)
	var/use_key = "[cache_key]-[cache_icon]-[overlay_layer]-[decal ? decal : "none"]-[image_colour ? image_colour : "none"]"
	if(!GLOB.mech_image_cache[use_key])
		var/image/I = image(icon = cache_icon, icon_state = cache_key)
		if(image_colour)
			var/image/masked_color = image(icon = cache_icon, icon_state = "[cache_key]_mask")
			masked_color.color = image_colour
			masked_color.blend_mode = BLEND_MULTIPLY
			I.AddOverlays(masked_color)
		if(decal)
			var/decal_key = "[decal]-[cache_key]"
			if(!GLOB.mech_icon_cache[decal_key])
				var/template_key = "template-[cache_key]"
				if(!GLOB.mech_icon_cache[template_key])
					GLOB.mech_icon_cache[template_key] = icon(cache_icon, "[cache_key]_mask")
				var/icon/decal_icon = icon('icons/mecha/mech_decals.dmi',decal)
				decal_icon.AddAlphaMask(GLOB.mech_icon_cache[template_key])
				GLOB.mech_icon_cache[decal_key] = decal_icon
			var/image/decal_image = get_mech_image(null, decal_key, GLOB.mech_icon_cache[decal_key])
			decal_image.blend_mode = BLEND_MULTIPLY
			I.AddOverlays(decal_image)
		I.appearance_flags |= RESET_COLOR
		I.layer = overlay_layer
		I.plane = FLOAT_PLANE
		GLOB.mech_image_cache[use_key] = I
	return GLOB.mech_image_cache[use_key]

/proc/get_mech_images(list/components = list(), overlay_layer = FLOAT_LAYER)
	RETURN_TYPE(/list)
	var/list/all_images = list()
	for(var/obj/item/mech_component/comp in components)
		all_images += get_mech_image(comp.decal, comp.icon_state, comp.on_mech_icon, comp.color, overlay_layer)
	return all_images

/mob/living/exosuit/on_update_icon()
	var/list/new_overlays = get_mech_images(list(body, head), MECH_BASE_LAYER)
	if(body)
		new_overlays += back_passengers_overlays
		new_overlays += left_back_passengers_overlays
		new_overlays += right_back_passengers_overlays
		new_overlays += get_mech_image(body.decal, "[body.icon_state]_cockpit", body.on_mech_icon, overlay_layer = MECH_INTERMEDIATE_LAYER)
	update_pilots(FALSE)
	if(LAZYLEN(pilot_overlays))
		new_overlays += pilot_overlays
	if(body)
		new_overlays += get_mech_image(body.decal, "[body.icon_state]_overlay[hatch_closed ? "" : "_open"]", body.on_mech_icon, body.color, MECH_COCKPIT_LAYER)
	if(arms)
		new_overlays += get_mech_image(arms.decal, arms.icon_state, arms.on_mech_icon, arms.color, MECH_ARM_LAYER)
	if(legs)
		new_overlays += get_mech_image(legs.decal, legs.icon_state, legs.on_mech_icon, legs.color, MECH_LEG_LAYER)
	for(var/hardpoint in hardpoints)
		var/obj/item/mech_equipment/hardpoint_object = hardpoints[hardpoint]
		if(hardpoint_object)
		//
			if(hardpoint in list(HARDPOINT_LEFT_HAND, HARDPOINT_LEFT_SHOULDER))
				if(dir == WEST || dir == SOUTHWEST || dir == NORTHWEST)
					hardpoint_object.mech_layer = MECH_GEAR_LAYER
				else if(dir == EAST || dir == SOUTHEAST || dir == NORTHEAST)
					hardpoint_object.mech_layer = MECH_BACK_LAYER
			if(hardpoint in list(HARDPOINT_RIGHT_HAND,HARDPOINT_RIGHT_SHOULDER))
				if(dir == WEST || dir == SOUTHWEST || dir == NORTHWEST)
					hardpoint_object.mech_layer = MECH_BACK_LAYER
				else if(dir == EAST || dir == SOUTHEAST || dir == NORTHEAST || dir == SOUTH)
					hardpoint_object.mech_layer = MECH_GEAR_LAYER
			var/use_icon_state = "[hardpoint_object.icon_state]_[hardpoint]"
		//
			if(use_icon_state in GLOB.mech_weapon_overlays)
				var/color = COLOR_WHITE
				var/decal = null
				if(hardpoint in list(HARDPOINT_BACK, HARDPOINT_RIGHT_SHOULDER, HARDPOINT_LEFT_SHOULDER))
					color = body.color
					decal = body.decal
				else if(hardpoint in list(HARDPOINT_RIGHT_HAND, HARDPOINT_LEFT_HAND))
					color = arms.color
					decal = arms.decal
				else
					color = head.color
					decal = head.decal
				if(power == MECH_POWER_ON)
					if(use_icon_state in GLOB.mech_weapon_overlays)
						new_overlays += get_mech_image(decal, use_icon_state, 'icons/mecha/mech_weapon_overlays.dmi', color, hardpoint_object.mech_layer )
				else
					new_overlays += get_mech_image(decal, use_icon_state, 'icons/mecha/mech_weapon_overlays_off.dmi', color, hardpoint_object.mech_layer )
		//
	SetOverlays(new_overlays)

/mob/living/exosuit/proc/update_pilots(update_overlays = TRUE)
	if(update_overlays && LAZYLEN(pilot_overlays))
		CutOverlays(pilot_overlays)
	pilot_overlays = null
	if(body && !(body.hide_pilot))
		for(var/i = 1 to LAZYLEN(pilots))
			var/mob/pilot = pilots[i]
			var/image/draw_pilot = new
			draw_pilot.appearance = pilot
			var/rel_pos = dir == NORTH ? -1 : 1
			draw_pilot.layer = MECH_PILOT_LAYER + (body ? ((LAZYLEN(body.pilot_positions)-i)*0.001 * rel_pos) : 0)
			draw_pilot.plane = FLOAT_PLANE
			draw_pilot.appearance_flags = KEEP_TOGETHER
			if(body && i <= LAZYLEN(body.pilot_positions))
				var/list/offset_values = body.pilot_positions[i]
				var/list/directional_offset_values = offset_values["[DIR_TO_CARDINAL(dir)]"]
				draw_pilot.pixel_x = pilot.default_pixel_x + directional_offset_values["x"]
				draw_pilot.pixel_y = pilot.default_pixel_y + directional_offset_values["y"]
				draw_pilot.pixel_z = 0
				draw_pilot.ClearTransform()

			//Mask pilots!
			//Masks are 48x48 and pilots 32x32 (in theory at least) so some math is required for centering
			var/diff_x = 8 - draw_pilot.pixel_x
			var/diff_y = 8 - draw_pilot.pixel_y
			draw_pilot.filters = filter(type = "alpha", icon = icon(body.on_mech_icon, "[body.icon_state]_pilot_mask[hatch_closed ? "" : "_open"]", DIR_TO_CARDINAL(dir)), x = diff_x, y = diff_y)

			LAZYADD(pilot_overlays, draw_pilot)
		if(update_overlays && LAZYLEN(pilot_overlays))
			AddOverlays(pilot_overlays)

/mob/living/exosuit/proc/update_passengers(update_overlays = TRUE)
	var/local_dir = dir // <- Для того чтоб не руинить направление передвижения меха, мы применим эту переменную
	if(update_overlays && LAZYLEN(back_passengers_overlays))
		overlays -= back_passengers_overlays
	if(update_overlays && LAZYLEN(left_back_passengers_overlays))
		overlays -= left_back_passengers_overlays
	if(update_overlays && LAZYLEN(right_back_passengers_overlays))
		overlays -= right_back_passengers_overlays
	back_passengers_overlays = null
	left_back_passengers_overlays = null
	right_back_passengers_overlays = null
	var/passenger_back_layer
	var/passenger_left_back_layer
	var/passenger_right_back_layer
	// Дабы исключить момент когда при боковом движении пассажиров не видно, помимо обычных направлений, будут прописаны следующие:

	if(local_dir == EAST || local_dir == NORTHEAST || local_dir == SOUTHEAST)
		local_dir = EAST
		passenger_back_layer = MECH_BACK_LAYER
		passenger_left_back_layer = MECH_BACK_LAYER - 0.01
		passenger_right_back_layer = MECH_GEAR_LAYER
	else if(local_dir == WEST || local_dir == NORTHWEST || local_dir == SOUTHWEST)
		local_dir = WEST
		passenger_back_layer = MECH_BACK_LAYER
		passenger_left_back_layer = MECH_GEAR_LAYER
		passenger_right_back_layer = MECH_BACK_LAYER - 0.01
	else if(local_dir == SOUTH)
		passenger_back_layer  = MECH_BACK_LAYER
		passenger_left_back_layer = MECH_BACK_LAYER
		passenger_right_back_layer = MECH_BACK_LAYER
	else if(local_dir == NORTH)
		passenger_back_layer  = MECH_GEAR_LAYER + 0.01
		passenger_left_back_layer = MECH_GEAR_LAYER + 0.01
		passenger_right_back_layer = MECH_GEAR_LAYER + 0.01
	//
	//
	if(LAZYLEN(passenger_compartment.back_passengers) > 0) // Отрисовка среднего пассажирка
		var/mob/passenger_back = passenger_compartment.back_passengers[1]
		var/image/draw_passenger_back = new
		draw_passenger_back.appearance = passenger_back
		draw_passenger_back.plane = FLOAT_PLANE
		var/list/back_offset_values = body.back_passengers_positions
		var/list/back_directional_offset_values = back_offset_values["[local_dir]"]
		draw_passenger_back.pixel_x = passenger_back.default_pixel_x + back_directional_offset_values["x"]
		draw_passenger_back.pixel_y = passenger_back.default_pixel_y + back_directional_offset_values["y"]
		draw_passenger_back.pixel_z = 0
		draw_passenger_back.transform = null
		draw_passenger_back.layer = passenger_back_layer
		LAZYADD(back_passengers_overlays, draw_passenger_back)
	//
	if(LAZYLEN(passenger_compartment.left_back_passengers) > 0) // Отрисовка левого пассажира
		var/mob/passenger_left_back = passenger_compartment.left_back_passengers[1]
		var/image/draw_passenger_left_back = new
		draw_passenger_left_back.appearance = passenger_left_back
		draw_passenger_left_back.plane = FLOAT_PLANE
		var/list/left_offset_values = body.left_back_passengers_positions
		var/list/left_directional_offset_values = left_offset_values["[local_dir]"]
		draw_passenger_left_back.pixel_x = passenger_left_back.default_pixel_x + left_directional_offset_values["x"]
		draw_passenger_left_back.pixel_y = passenger_left_back.default_pixel_y + left_directional_offset_values["y"]
		draw_passenger_left_back.pixel_z = 0
		draw_passenger_left_back.transform = null
		draw_passenger_left_back.layer = passenger_left_back_layer
		LAZYADD(left_back_passengers_overlays, draw_passenger_left_back)
	//
	if(LAZYLEN(passenger_compartment.right_back_passengers) > 0) // Отрисовка правого пассажира
		var/mob/passenger_right_back = passenger_compartment.right_back_passengers[1]
		var/image/draw_passenger_right_back = new
		draw_passenger_right_back.layer = passenger_right_back_layer
		draw_passenger_right_back.appearance = passenger_right_back
		draw_passenger_right_back.plane = FLOAT_PLANE
		var/list/right_offset_values = body.right_back_passengers_positions
		var/list/right_directional_offset_values = right_offset_values["[local_dir]"]
		draw_passenger_right_back.pixel_x = passenger_right_back.default_pixel_x + right_directional_offset_values["x"]
		draw_passenger_right_back.pixel_y = passenger_right_back.default_pixel_y + right_directional_offset_values["y"]
		draw_passenger_right_back.pixel_z = 0
		draw_passenger_right_back.transform = null
		draw_passenger_right_back.layer = passenger_right_back_layer
		LAZYADD(right_back_passengers_overlays, draw_passenger_right_back)
	//
	if(update_overlays && LAZYLEN(back_passengers_overlays))
		overlays += back_passengers_overlays
	if(update_overlays && LAZYLEN(left_back_passengers_overlays))
		overlays += left_back_passengers_overlays
	if(update_overlays && LAZYLEN(right_back_passengers_overlays))
		overlays += right_back_passengers_overlays
/mob/living/exosuit/regenerate_icons()
	return
