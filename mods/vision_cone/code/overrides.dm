/datum/hud/human/FinalizeInstantiation(ui_style='icons/mob/screen1_White.dmi', ui_color = "#ffffff", ui_alpha = 255)
	.=..()
	var/mob/living/carbon/human/target = mymob
	if(target.client && target.client.usefov)
		target.client.fov_mask = new /obj/screen/fullscreen/fov_blocker
		target.client.fov_shadow = new /obj/screen/fullscreen/fov_shadow
		target.check_fov()

/atom/movable/do_attack_animation(atom/A, fov_effect = TRUE)
	.=..()
	if(fov_effect)
		play_fov_effect(A, 5, "attack")

//called to launch a projectile
/obj/item/projectile/launch(atom/target, target_zone, x_offset=0, y_offset=0, angle_offset=0)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return 1

	if(targloc == curloc) //Shooting something in the same turf
		target.bullet_act(src, target_zone)
		on_impact(target)
		QDEL_NULL_LIST(segments)
		qdel(src)
		return 0

	original = target
	def_zone = target_zone

	addtimer(new Callback(src, PROC_REF(finalize_launch), curloc, targloc, x_offset, y_offset, angle_offset),0)
	starting = curloc
	play_fov_effect(starting, 6, "gunfire", dir = NORTH, angle = angle_offset)
	return 0


/mob/reset_layer()
	if(lying)
		layer = LYING_MOB_LAYER
	else
		reset_plane_and_layer()


/mob/living/carbon/human/handle_footsteps()
	..()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		var/footsound = T.get_footstep_sound(src)
		if(footsound)
			play_fov_effect(src.loc, world.view, "footstep", src.dir, ignore_self=TRUE)

/singleton/species/handle_vision(mob/living/carbon/human/H)
	var/list/vision = H.get_accumulated_vision_handlers()
	H.update_sight()
	H.set_sight(H.sight|get_vision_flags(H)|H.equipment_vision_flags|vision[1])
	H.change_light_colour(H.getDarkvisionTint())

	if(H.stat == DEAD)
		return 1

	if(!H.druggy)
		H.set_see_in_dark((H.sight == (SEE_TURFS|SEE_MOBS|SEE_OBJS)) ? 8 : min(H.getDarkvisionRange() + H.equipment_darkness_modifier, 8))
		if(H.equipment_see_invis)
			H.set_see_invisible(max(min(H.see_invisible, H.equipment_see_invis), vision[2]))

	if(H.equipment_tint_total >= TINT_BLIND)
		H.eye_blind = max(H.eye_blind, 1)

	if(!H.client)//no client, no screen to update
		return 1

	if(!H.isSynthetic())
		H.set_fullscreen(H.eye_blurry, "blurry", /obj/screen/fullscreen/blurry)
		H.set_fullscreen(H.eye_blind && !H.equipment_prescription, "blind", /obj/screen/fullscreen/blind)
		H.set_fullscreen(H.stat == UNCONSCIOUS, "blackout", /obj/screen/fullscreen/blackout)

	else
		if(H.stat == !UNCONSCIOUS)
			H.set_fullscreen(H.eye_blind && !H.equipment_prescription, "glitch_monitor", /obj/screen/fullscreen/glitch_bw/alpha)
		H.set_fullscreen(H.stat == UNCONSCIOUS, "no_power", /obj/screen/fullscreen/no_power)
		H.set_fullscreen(H.eye_blurry, "blurry", /obj/screen/fullscreen/glitch_bw)

	if(config.welder_vision)
		H.set_fullscreen(H.equipment_tint_total, "welder", /obj/screen/fullscreen/impaired, H.equipment_tint_total)
	var/how_nearsighted = get_how_nearsighted(H)
	H.set_fullscreen(how_nearsighted, "nearsighted", /obj/screen/fullscreen/oxy, how_nearsighted)
	H.set_fullscreen(H.druggy, "high", /obj/screen/fullscreen/high)

	for(var/atom/movable/renderer/nearsight_blur/blur in H.renderers)
		if(how_nearsighted)
			blur.filters = list(filter(type="blur", size=2))
		else
			blur.filters = list()

	for(var/atom/movable/renderer/fov_hidden/blur in H.renderers)
		if(how_nearsighted)
			blur.filters = list(filter(type="blur", size=2), filter(type="alpha", render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE))
		else
			blur.filters = list(filter(type="alpha", render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE))

	for(var/overlay in H.equipment_overlays)
		H.client.screen |= overlay

	return 1


/mob/face_direction()

	set name = "Face Direction"
	set category = "IC"
	set src = usr

	set_face_dir()

	if(!facing_dir)
		to_chat(usr, "You are now not facing anything.")
		face_dir_click = null
	else
		to_chat(usr, "You are now facing [dir2text(facing_dir)].")


/mob/living/facedir(ndir)
	if(!canface() || moving || (buckled && !buckled.buckle_movable))
		return 0
	if(buckled && buckled.buckle_movable)
		buckled.set_dir(ndir)
	if(facing_dir)
		face_dir_click = ndir
	set_dir(ndir)
	SetMoveCooldown(movement_delay())
	return 1

/mob/reload_fullscreen()
	.=..()
	if(client)
		client.reload_fov()

/mob/living/carbon/human/reset_view(atom/A)
	..()
	if(machine_visual && machine_visual != A)
		machine_visual.remove_visual(src)
	src.check_fov()
