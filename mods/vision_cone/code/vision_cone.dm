/// Field of vision defines.
#define FOV_90_DEGREES 90
#define FOV_180_DEGREES 180
#define FOV_270_DEGREES 270

/mob/var/list/atom/movable/renderer/renderers

/atom/movable/renderer/fov_hidden
	name = "game world fov hidden plane master"
	plane = GAME_PLANE_FOV_HIDDEN
	group = RENDER_GROUP_SCENE
	renderer_flags = RENDERER_MAIN | RENDERER_SHARED

/atom/movable/renderer/fov_hidden/Initialize()
	. = ..()
	filters += filter(type="alpha", render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE)

/atom/movable/renderer/field_of_vision_blocker
	name = "field of vision blocker plane master"
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	render_target_name = FIELD_OF_VISION_BLOCKER_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	renderer_flags = RENDERER_MAIN | RENDERER_SHARED
	appearance_flags = PLANE_MASTER


/atom/movable/renderer/nearsight_blur
	name = "nearsight blur"
	plane = DEFAULT_PLANE
	group = RENDER_GROUP_SCENE
	renderer_flags = RENDERER_MAIN | RENDERER_SHARED


/atom/movable/renderer/above_fov
	name = "above fov"
	plane = GAME_PLANE_ABOVE_FOV
	group = RENDER_GROUP_SCENE
	renderer_flags = RENDERER_MAIN | RENDERER_SHARED

/client
	var/obj/screen/fullscreen/fov_blocker/fov_mask
	var/obj/screen/fullscreen/fov_shadow/fov_shadow
	var/usefov = FALSE
	var/hasmask = FALSE
	var/fovangle

/mob/living/SelfMove(direction)
	. = ..()
	update_fov_dir()


/mob/set_dir()
	if(facing_dir)
		if(!canface() || lying || restrained())
			facing_dir = null
		else if(buckled)
			if(buckled.obj_flags & OBJ_FLAG_ROTATABLE)
				buckled.set_dir(facing_dir)
				return ..(facing_dir)
			else
				facing_dir = null
		else if(dir != face_dir_click)
			return ..(face_dir_click)
	else
		return ..()


/mob/living/set_dir()
	. = ..()
	update_fov_dir()


/mob/living/exosuit/set_dir(ndir)
	if(pilots)
		for(var/mob/living/thing in pilots)
			thing.set_dir(ndir)
	..()


/mob/living/UpdateLyingBuckledAndVerbStatus()
	. = ..()
	check_fov()

/mob/living/proc/update_fov_dir()
	if(client && client.usefov)
		client.fov_mask.dir = src.dir
		client.fov_shadow.dir = src.dir

/mob/living/proc/check_fov()
	var/mob/eyepath
	if(client)
		if(resting || lying)
			client.hide_cone()
		//Trying to make FOV works for Mechs
		else if(client.eye != client.mob)
			eyepath = client.eye
			if(ispath(eyepath.type, /mob/living/exosuit))
				if(client.usefov)
					client.show_cone()
					client.fov_mask.dir = eyepath.dir
					client.fov_shadow.dir = eyepath.dir
				else
					client.hide_cone()
			else
				client.hide_mask()
		//////////
		else if(client.usefov)
			client.show_cone()
		else
			client.hide_cone()

/mob/living/proc/toggle_fov(usefov, fovangle)
	if(client)
		client.usefov = usefov
		client.fovangle = fovangle
		src.check_fov()

// //Making these generic procs so you can call them anywhere.
/client/proc/show_cone()
	if(usefov && !hasmask)
		fov_shadow = mob.overlay_fullscreen("FOV_shadow", /obj/screen/fullscreen/fov_shadow)
		fov_mask = mob.overlay_fullscreen("FOV_mask", /obj/screen/fullscreen/fov_blocker)
		hasmask = TRUE
		fov_shadow.icon_state = "[fovangle]_v"
		fov_mask.icon_state = "[fovangle]"
		fov_mask.dir = mob.dir
		fov_shadow.dir = mob.dir

/client/proc/hide_cone()
	if(!usefov && hasmask)
		fov_shadow = mob.clear_fullscreen("FOV_shadow")
		fov_mask = mob.clear_fullscreen("FOV_mask")
		hasmask = FALSE
		usefov = FALSE

/client/proc/remove_cone()
	fov_shadow = mob.clear_fullscreen("FOV_shadow")
	fov_mask = mob.clear_fullscreen("FOV_mask")
	hasmask = FALSE
	usefov = FALSE
	fovangle = 0

/client/proc/hide_mask()
	fov_shadow = mob.clear_fullscreen("FOV_shadow")
	fov_mask = mob.clear_fullscreen("FOV_mask")
	hasmask = FALSE


/mob/living/proc/in_fov(atom/observed_atom, ignore_self = FALSE)
	if(ignore_self && observed_atom == src)
		return TRUE
	if(is_blind())
		return FALSE
	. = FALSE
	var/turf/my_turf = get_turf(src) //Because being inside contents of something will cause our x,y to not be updated
	// If turf doesn't exist, then we wouldn't get a fov check called by `play_fov_effect` or presumably other new stuff that might check this.
	//  ^ If that case has changed and you need that check, add it.
	var/rel_x = observed_atom.x - my_turf.x
	var/rel_y = observed_atom.y - my_turf.y
	if(client?.fovangle)
		if(rel_x >= -1 && rel_x <= 1 && rel_y >= -1 && rel_y <= 1) //Cheap way to check inside that 3x3 box around you
			return TRUE //Also checks if both are 0 to stop division by zero

		// Get the vector length so we can create a good directional vector
		var/vector_len = sqrt(abs(rel_x) ** 2 + abs(rel_y) ** 2)

		/// Getting a direction vector
		var/dir_x
		var/dir_y
		switch(dir)
			if(SOUTH)
				dir_x = 0
				dir_y = -vector_len
			if(NORTH)
				dir_x = 0
				dir_y = vector_len
			if(EAST)
				dir_x = vector_len
				dir_y = 0
			if(WEST)
				dir_x = -vector_len
				dir_y = 0

		///Calculate angle
		var/angle = arccos((dir_x * rel_x + dir_y * rel_y) / (sqrt(dir_x**2 + dir_y**2) * sqrt(rel_x**2 + rel_y**2)))

		/// Calculate vision angle and compare
		var/vision_angle = (360 - client.fovangle) / 2
		if(angle < vision_angle)
			. = TRUE
	else
		. = TRUE

/proc/remove_image_from_client(image/image_to_remove, client/remove_from)
	remove_from?.images -= image_to_remove

/// Plays a visual effect representing a sound cue for people with vision obstructed by FOV or blindness
/proc/play_fov_effect(atom/center, range, icon_state, dir = SOUTH, ignore_self = FALSE, angle = 0)
	var/turf/anchor_point = get_turf(center)
	var/image/fov_image
	for(var/mob/living/living_mob in view(range, center))
		var/client/mob_client = living_mob.client
		if(!mob_client)
			continue
		if(living_mob.in_fov(center, ignore_self))
			continue
		if(!fov_image) //Make the image once we found one recipient to receive it
			fov_image = image(icon = 'mods/vision_cone/icons/fov_effects.dmi', icon_state = icon_state, loc = anchor_point)
			fov_image.plane = FULLSCREEN_PLANE
			fov_image.layer = 10000
			fov_image.dir = dir
			fov_image.appearance_flags = RESET_COLOR | RESET_TRANSFORM
			if(angle)
				var/matrix/matrix = new
				matrix.Turn(angle)
				fov_image.transform = matrix
			fov_image.mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
		mob_client.images += fov_image
		addtimer(new Callback(GLOBAL_PROC, .proc/remove_image_from_client, fov_image, mob_client), 30)

/obj/screen/fullscreen/fov_blocker
	icon = 'mods/vision_cone/icons/field_of_view.dmi'
	icon_state = "90"
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	scale_to_view = TRUE

/obj/screen/fullscreen/fov_shadow
	icon = 'mods/vision_cone/icons/field_of_view.dmi'
	icon_state = "90_v"
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	scale_to_view = TRUE
