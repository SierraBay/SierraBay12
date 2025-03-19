/obj/item/storage/mirror
	/// Visual object for handling the viscontents
	var/weakref/ref
	vis_flags = VIS_HIDE
	var/timerid = null

/obj/item/storage/mirror/Initialize()
	. = ..()
	var/obj/effect/reflection/reflection = new(src.loc)
	reflection.setup_visuals(src)
	ref = weakref(reflection)

/obj/item/storage/mirror/moved(mob/user, old_loc)
	. = ..()
	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		reflection.forceMove(loc)
		reflection.update_mirror_filters() //Mirrors shouldnt move but if they do so should reflection

/obj/item/storage/mirror/proc/reset_alpha()
	var/obj/effect/reflection/reflection = ref.resolve()
	reflection.reset_alpha()

/obj/item/storage/mirror/proc/on_flick() //Have to hide the effect
	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		reflection.alpha = 0
		if(timerid)
			deltimer(timerid)
			timerid = null
		timerid = addtimer(new Callback(src, PROC_REF(reset_alpha)), 15)

/obj/item/storage/mirror/MouseDrop(obj/over_object as obj)
	..()
	on_flick()

/obj/item/storage/mirror/use_tool(obj/item/W as obj, mob/user as mob)
	..()
	on_flick()

/obj/item/storage/mirror/shatter()
	..()
	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		reflection.alpha_icon_state = "mirror_mask_broken"
		reflection.update_mirror_filters()

/obj/item/storage/mirror/Destroy()
	..()
	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		QDEL_NULL(reflection)

/obj/effect/reflection
	name = "reflection"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	mouse_opacity = 0
	vis_flags = VIS_HIDE
	layer = ABOVE_OBJ_LAYER
	var/alpha_icon = 'mods/_master_files/icons/obj/mirror_mask.dmi'
	var/alpha_icon_state = "mirror_mask"
	var/obj/mirror
	desc = "Why are you locked in the bathroom?"
	anchored = TRUE
	unacidable = TRUE

/obj/effect/reflection/proc/setup_visuals(target)
	mirror = target

	if(abs(mirror.pixel_x) >= abs(mirror.pixel_y))
		if(mirror.pixel_x > 0)
			dir = WEST
		else if (mirror.pixel_x < 0)
			dir = EAST
	else
		if(mirror.pixel_y > 0)
			dir = NORTH
		else if (mirror.pixel_y < 0)
			dir = SOUTH

	pixel_x = mirror.pixel_x
	pixel_y = mirror.pixel_y

	update_mirror_filters()

/obj/effect/reflection/proc/reset_visuals()
	mirror = null
	update_mirror_filters()

/obj/effect/reflection/proc/reset_alpha()
	alpha = initial(alpha)

/obj/effect/reflection/proc/update_mirror_filters()
	filters = null

	vis_contents = null

	if(!mirror)
		return

	/*
	A way to disable North mirrors
	if(dir == NORTH)
		return
	*/

	var/additional_y_offset = 0
	var/matrix/M = matrix()
	if(dir == WEST || dir == EAST)
		M.Scale(-1, 1)
	else if(dir == SOUTH)
		M.Scale(1, -1)
		//Center of mirror sprite is at 19, meaning we will be some pixels off when pointing down
		additional_y_offset = -5

	transform = M

	filters += filter("type" = "alpha", "icon" = icon(alpha_icon, alpha_icon_state), "x" = 0, "y" = additional_y_offset)

	vis_contents += get_turf(mirror)