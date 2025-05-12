#define FOV_270	1
#define FOV_180	2
#define FOV_90	3

/mob
	var/obj/screen/vision_cone_overlay = null
	var/can_have_vision_cone = FALSE

/mob/is_invisible_to(mob/viewer)
	return ..() || (viewer.client && (src in viewer.client.hidden_mobs))


/*
/mob/proc/face_atom(atom/A)
	if(!A || !x || !y || !A.x || !A.y) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)	direction = NORTH
		else		direction = SOUTH
	else
		if(dx > 0)	direction = EAST
		else		direction = WEST
	if(direction != dir)
		facedir(direction, TRUE)
*/

/datum/hud/human/FinalizeInstantiation(ui_style='icons/mob/screen1_White.dmi', ui_color = "#ffffff", ui_alpha = 255)
	.=..()
	var/mob/living/carbon/human/target = mymob
	var/datum/hud_data/hud_data
	var/list/hud_elements = list()
	if(target.can_have_vision_cone)
		var/mob/living/carbon/human/H = mymob
		H.vision_cone_overlay = new /obj/screen/fullscreen/fov()
		hud_elements |= H.vision_cone_overlay


/obj/item/showoff(mob/user)
	for (var/mob/M in view(user))
		if(!user.is_invisible_to(M))
			M.show_message("<b>[user]</b> holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)


/obj/item/zoom(mob/user, tileoffset = 14,viewsize = 9)
	.=..()
	var/mob/living/carbon/human/H = user
	if(H.vision_cone_overlay)
		var/mob/living/vision_cone_mob = H
		vision_cone_mob.hide_cone()


/obj/item/holder/update_state()
	if(last_holder != loc)
		for(var/mob/M in contents)
			unregister_all_movement(last_holder, M)

	if(istype(loc,/turf) || !(length(contents)))
		for(var/mob/M in contents)
			var/atom/movable/mob_container = M
			mob_container.dropInto(loc)
			M.reset_view()
			if(isliving(M))
				var/mob/living/L = M
				L.can_have_vision_cone = TRUE
				L.update_vision_cone()
		qdel(src)
	else if(last_holder != loc)
		for(var/mob/M in contents)
			register_all_movement(loc, M)

	last_holder = loc


/mob/living/Move(a, b, flag)
	. = ..()
	// Other viewers only need to update their vision for this moving mob, not their entire cone, as they are stationary
	for(var/viewer in oviewers(world.view, src))
		var/mob/living/M = viewer
		if(M.client && istype(M) && M.can_have_vision_cone)
			var/turf/T = get_turf(M)
			var/turf/Ts = get_turf(src)
			if(Ts.InConeDirection(T, reverse_direction(M.dir)))
				if(!(src in M.client.hidden_mobs))
					if(M.InCone(T, M.dir))
						M.add_to_mobs_hidden_atoms(src)
				Ts.show_footsteps(M, T, src)
			else
				if(src in M.client.hidden_mobs)
					M.client.hidden_mobs -= src
					for(var/image in M.client.hidden_atoms)
						var/image/I = image
						if(I.loc == src)
							I.override = FALSE
							M.client.hidden_atoms -= I
							M.client.images -= I
							QDEL_IN(I, 1 SECONDS)
							break

	update_vision_cone()



/obj/screen/fullscreen/fov
	icon = 'mods/vision_cone/icons/vision_cone.dmi'
	icon_state = "combat"
	mouse_opacity = 0
	layer = FULLSCREEN_LAYER
	scale_to_view = TRUE


/obj/item/clothing/head/
	var/vision_cone = FALSE

/obj/item/clothing/head/helmet/
	vision_cone = TRUE

/mob/living/update_sight()
	. = ..()
	can_have_vision_cone = FALSE
	var/obj/item/clothing/head/I = get_equipped_item(slot_head)
	if(I && I.vision_cone)
		can_have_vision_cone = TRUE
