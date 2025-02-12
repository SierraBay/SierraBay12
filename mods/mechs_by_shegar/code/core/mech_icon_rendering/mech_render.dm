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
		//Данный участок кода в зависимости от положения помещает модуль за мех или перед мехом, это выглядит красиво.
			if(hardpoint in list(HARDPOINT_LEFT_HAND, HARDPOINT_LEFT_SHOULDER))
				if(dir == WEST || dir == SOUTHWEST || dir == NORTHWEST || dir == SOUTH || dir == NORTH)
					hardpoint_object.mech_layer = MECH_GEAR_LAYER
				else if(dir == EAST || dir == SOUTHEAST || dir == NORTHEAST)
					hardpoint_object.mech_layer = MECH_BACK_LAYER
			else if(hardpoint in list(HARDPOINT_RIGHT_HAND, HARDPOINT_RIGHT_SHOULDER))
				if(dir == WEST || dir == SOUTHWEST || dir == NORTHWEST)
					hardpoint_object.mech_layer = MECH_BACK_LAYER
				else if(dir == EAST || dir == SOUTHEAST || dir == NORTHEAST || dir == SOUTH)
					hardpoint_object.mech_layer = MECH_GEAR_LAYER
			else if(hardpoint in list(HARDPOINT_BACK, HARDPOINT_HEAD))
				if(dir == SOUTH)
					hardpoint_object.mech_layer = MECH_BACK_LAYER
				else
					hardpoint_object.mech_layer = MECH_GEAR_LAYER

			var/use_icon_state = "[hardpoint_object.icon_state]_[hardpoint]"
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
//Если мех ВЫКЛЮЧЕН - модули имеют другие спрайты
				if(power == MECH_POWER_ON)
					if(use_icon_state in GLOB.mech_weapon_overlays)
						new_overlays += get_mech_image(decal, use_icon_state, 'mods/mechs_by_shegar/icons/mech_weapon_overlays.dmi', color, hardpoint_object.mech_layer )
				else
					new_overlays += get_mech_image(decal, use_icon_state, 'mods/mechs_by_shegar/icons/mech_weapon_overlays_off.dmi', color, hardpoint_object.mech_layer )

	SetOverlays(new_overlays)

///Функция генерирующая изображение модулей меха. Применяется в радиальном меню при ремонте
/mob/living/exosuit/proc/generate_icons()
	LAZYCLEARLIST(parts_list)
	LAZYCLEARLIST(parts_list_images)
	parts_list = list(head, body, arms, legs)
	parts_list_images = make_item_radial_menu_choices(parts_list)
	//bam

/mob/living/exosuit/regenerate_icons()
	return
