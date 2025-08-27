/obj/paint/LateInitialize(mapload)
	var/turf/simulated/wall/W = get_turf(src)
	if(istype(W))
		W.paint_color = color
		W.update_icon()
	var/obj/structure/wall_frame/WF = locate() in loc
	if(WF)
		WF.paint_color = color
		WF.update_icon()
	qdel(src)

/material/plasteel/titanium
	wall_flags = MATERIAL_PAINTABLE_MAIN|MATERIAL_PAINTABLE_STRIPE

/turf/simulated/wall
	var/list/blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall/wood, /turf/simulated/wall/walnut, /turf/simulated/wall/maple, /turf/simulated/wall/mahogany, /turf/simulated/wall/ebony)
	var/list/blend_objects = list(/obj/machinery/door, /obj/structure/wall_frame, /obj/structure/grille, /obj/structure/window/reinforced/full, /obj/structure/window/reinforced/polarized/full, /obj/structure/window/shuttle, ,/obj/structure/window/boron_basic/full, /obj/structure/window/boron_reinforced/full) // Objects which to blend with
	var/list/noblend_objects = list(/obj/machinery/door/window) //Objects to avoid blending with (such as children of listed blend objects.)

/turf/simulated/wall/wood
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)

/turf/simulated/wall/mahogany
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)

/turf/simulated/wall/maple
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)

/turf/simulated/wall/ebony
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)

/turf/simulated/wall/walnut
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)

/turf/simulated/wall/alium
	blend_objects = newlist()

/turf/simulated/wall/cult
	blend_turfs = list(/turf/simulated/wall)

/obj/structure/wall_frame/standard
	stripe_color = null

/obj/structure/wall_frame/hull
	stripe_color = null

/obj/structure/wall_frame/hull/vox
	stripe_color = null

/obj/structure/wall_frame/hull/verne
	stripe_color = null

/turf/simulated/wall/r_wall/hull
	paint_color = null
	stripe_color = null

/turf/simulated/wall/prepainted
	color = null
	stripe_color = null

/turf/simulated/wall/r_wall/prepainted
	color = null
	stripe_color = null

/turf/simulated/wall/r_wall/hull/Initialize()
	paint_color = color
	stripe_color = color
	. = ..()

/obj/structure/wall_frame/on_update_icon()
	ClearOverlays()
	var/image/I

	var/new_color = (paint_color ? paint_color : material.icon_colour)
	color = new_color

	for(var/i = 1 to 4)
		if(other_connections[i] != "0")
			I = image('icons/obj/structures/wall_frame.dmi', "frame_other[connections[i]]", dir = SHIFTL(1, i - 1))
		else
			I = image('icons/obj/structures/wall_frame.dmi', "frame[connections[i]]", dir = SHIFTL(1, i - 1))
		AddOverlays(I)

	if(stripe_color)
		for(var/i = 1 to 4)
			if(other_connections[i] != "0")
				I = image('icons/obj/structures/wall_frame.dmi', "stripe_other[connections[i]]", dir = SHIFTL(1, i - 1))
			else
				I = image('icons/obj/structures/wall_frame.dmi', "stripe[connections[i]]", dir = SHIFTL(1, i - 1))
			I.color = stripe_color
			AddOverlays(I)

/turf/simulated/wall/on_update_icon()

	..()

	if(!material)
		return

	if(!damage_overlays[1]) //list hasn't been populated; note that it is always of fixed length, so we must check for membership.
		generate_overlays()

	ClearOverlays()

	var/image/I
	var/base_color = paint_color ? paint_color : material.icon_colour
	if(!density)
		I = image('icons/turf/wall_masks.dmi', "[material.wall_icon_base]fwall_open")
		I.color = base_color
		AddOverlays(I)
		return

	for(var/i = 1 to 4)
		I = image('icons/turf/wall_masks.dmi', "[material.wall_icon_base][wall_connections[i]]", dir = SHIFTL(1, i - 1))
		I.color = base_color
		AddOverlays(I)
		if(other_connections[i] != "0")
			I = image('icons/turf/wall_masks.dmi', "[material.wall_icon_base]_other[wall_connections[i]]", dir = SHIFTL(1, i - 1))
			I.color = base_color
			AddOverlays(I)

	if(reinf_material)
		var/reinf_color = paint_color ? paint_color : reinf_material.icon_colour
		if(construction_stage != null && construction_stage < 6)
			I = image('icons/turf/wall_masks.dmi', "reinf_construct-[construction_stage]")
			I.color = reinf_color
			AddOverlays(I)
		else
			if("[material.wall_icon_reinf]0" in icon_states('icons/turf/wall_masks.dmi'))
				// Directional icon
				for(var/i = 1 to 4)
					I = image('icons/turf/wall_masks.dmi', "[material.wall_icon_reinf][wall_connections[i]]", dir = SHIFTL(1, i - 1))
					I.color = reinf_color
					AddOverlays(I)
			else
				I = image('icons/turf/wall_masks.dmi', material.wall_icon_reinf)
				I.color = reinf_color
				AddOverlays(I)
	var/image/texture = material.get_wall_texture()
	if(texture)
		AddOverlays(texture)
	if(stripe_color)
		for(var/i = 1 to 4)
			if(other_connections[i] != "0")
				I = image('icons/turf/wall_masks.dmi', "stripe_other[wall_connections[i]]", dir = SHIFTL(1, i - 1))
			else
				I = image('icons/turf/wall_masks.dmi', "stripe[wall_connections[i]]", dir = SHIFTL(1, i - 1))
			I.color = stripe_color
			AddOverlays(I)

	if(get_damage_value() != 0)
		var/overlay = round((get_damage_percentage() / 100) * length(damage_overlays)) + 1
		overlay = clamp(overlay, 1, length(damage_overlays))

		AddOverlays(damage_overlays[overlay])
	return

/turf/simulated/wall/update_connections(propagate = 0)
	if(!material)
		return
	var/list/wall_dirs = list()
	var/list/other_dirs = list()

	for(var/turf/simulated/wall/W in orange(src, 1))
		switch(can_join_with(W))
			if(0)
				continue
			if(1)
				wall_dirs += get_dir(src, W)
			if(2)
				wall_dirs += get_dir(src, W)
				other_dirs += get_dir(src, W)
		if(propagate)
			W.update_connections()
			W.update_icon()

	for(var/turf/T in orange(src, 1))
		var/success = 0
		for(var/obj/O in T)
			for(var/b_type in blend_objects)
				if(istype(O, b_type))
					success = 1
				for(var/nb_type in noblend_objects)
					if(istype(O, nb_type))
						success = 0
				if(success)
					break
			if(success)
				break

		if(success)
			wall_dirs += get_dir(src, T)
			if(get_dir(src, T) in GLOB.cardinal)
				other_dirs += get_dir(src, T)

	wall_connections = dirs_to_corner_states(wall_dirs)
	other_connections = dirs_to_corner_states(other_dirs)

/turf/simulated/wall/can_join_with(turf/simulated/wall/W)
	if(material && W.material && material.wall_icon_base == W.material.wall_icon_base)
		if((reinf_material && W.reinf_material) || (!reinf_material && !W.reinf_material))
			return 1
		return 2
	for(var/wb_type in blend_turfs)
		if(istype(W, wb_type))
			return 2
	return 0