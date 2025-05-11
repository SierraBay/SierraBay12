/obj/screen/movable/exosuit/advanced_heat
	name = "Heat"
	icon = 'mods/mechs_by_shegar/icons/mech_heat.dmi'
	icon_state = "fill"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | KEEP_TOGETHER | NO_CLIENT_COLOR
	plane = HUD_PLANE
	layer = HUD_BASE_LAYER
	var/obj/overheat
	var/obj/cutter
	var/tooltip = FALSE

/obj/overheat //Восклицательные занки
	icon = 'mods/mechs_by_shegar/icons/mech_heat.dmi'
	icon_state = "overheat"
	name = "overheat"
	layer = HUD_BASE_LAYER - 1
	pixel_y = 32
	plane = FLOAT_PLANE
	vis_flags = VIS_INHERIT_ID

/obj/mech_heat_cutter //Обрезатель цвета
	icon = 'mods/mechs_by_shegar/icons/mech_heat.dmi'
	icon_state = "mask"
	plane = FLOAT_PLANE
	layer = HUD_BASE_LAYER + 0.1
	vis_flags = VIS_INHERIT_ID
	blend_mode = BLEND_INSET_OVERLAY

/obj/obvodka //Обводка
	icon = 'mods/mechs_by_shegar/icons/mech_heat.dmi'
	icon_state = "obvodka"
	name = "obvodka"
	layer = HUD_BASE_LAYER + 0.2
	plane = FLOAT_PLANE
	vis_flags = VIS_INHERIT_ID

/obj/screen/movable/exosuit/advanced_heat/proc/Update()
	var/percent = owner.current_heat/owner.max_heat * 100
	percent = percent/1.58
	percent = clamp(percent, 0, 63)
	animate(cutter, time = 1 SECONDS, pixel_z = percent, flags = ANIMATION_LINEAR_TRANSFORM)
