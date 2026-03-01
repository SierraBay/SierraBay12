/mob/living/exosuit/proc/update_pilots(update_overlays = TRUE)
	//Сперва мы проверяем - а нам вообще надо обновлять пилота? Если кабина закрытого типа,то в этом нет никакого смысла
	if(!body || (body.hide_pilot))
		return
	var/local_dir = dir
	if(local_dir == NORTHEAST || local_dir == SOUTHEAST)
		local_dir = EAST
	else if(local_dir == NORTHWEST || local_dir == SOUTHWEST)
		local_dir = WEST
	if(update_overlays && LAZYLEN(pilot_overlays))
		CutOverlays(pilot_overlays)
	pilot_overlays = null
	for(var/i = 1 to LAZYLEN(pilots))
		var/mob/pilot = pilots[i]
		var/image/draw_pilot = new
		draw_pilot.appearance = pilot
		var/rel_pos = local_dir == NORTH ? -1 : 1
		draw_pilot.layer = MECH_PILOT_LAYER + (body ? ((LAZYLEN(body.pilot_positions)-i)*0.001 * rel_pos) : 0)
		draw_pilot.plane = FLOAT_PLANE
		draw_pilot.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
		if(body && i <= LAZYLEN(body.pilot_positions))
			var/list/offset_values = body.pilot_positions[i]
			var/list/directional_offset_values = offset_values["[local_dir]"]
			draw_pilot.pixel_x = pilot.default_pixel_x + directional_offset_values["x"]
			draw_pilot.pixel_y = pilot.default_pixel_y + directional_offset_values["y"]
			draw_pilot.pixel_z = 0
			draw_pilot.ClearTransform()

		//Mask pilots!
		//Masks are 48x48 and pilots 32x32 (in theory at least) so some math is required for centering
		var/diff_x = 8 - draw_pilot.pixel_x
		var/diff_y = 8 - draw_pilot.pixel_y
		draw_pilot.filters = filter(type = "alpha", icon = icon(body.on_mech_icon, "[body.icon_state]_pilot_mask[hatch_closed ? "" : "_open"]", local_dir), x = diff_x, y = diff_y)

		LAZYADD(pilot_overlays, draw_pilot)
	if(update_overlays && LAZYLEN(pilot_overlays))
		AddOverlays(pilot_overlays)
