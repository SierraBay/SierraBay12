/obj/overlay
	name = "overlay"
	unacidable = TRUE
	anchored = TRUE

	/// If set, the time in deciseconds before the effect is deleted
	var/delete_delay


/obj/overlay/Initialize()
	. = ..()
	if (delete_delay)
		QDEL_IN(src, delete_delay)


/obj/overlay/beam
	name = "beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "b_beam"
	delete_delay = 1 SECOND


/obj/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = TRUE
	layer = ABOVE_HUMAN_LAYER


/obj/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = TRUE
	layer = ABOVE_HUMAN_LAYER


/obj/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"


/obj/overlay/bluespacify
	name = "Bluespace"
	icon = 'icons/turf/space.dmi'
	icon_state = "bluespacify"
	layer = SUPERMATTER_WALL_LAYER


/obj/overlay/wallrot
	name = "wallrot"
	desc = "Ick..."
	icon = 'icons/effects/wallrot.dmi'
	density = TRUE
	layer = ABOVE_TILE_LAYER
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE


/obj/overlay/wallrot/Initialize()
	. = ..()
	pixel_x += rand(-10, 10)
	pixel_y += rand(-10, 10)


/obj/overlay/emp_pulse
	name = "emp pulse"
	icon = 'icons/effects/effects.dmi'
	icon_state = "emppulse"
	delete_delay = 2 SECONDS


/obj/overlay/bullet_hole
	name = "bullet hole"
	icon = 'icons/effects/effects.dmi'
	layer = DECAL_LAYER
	icon_state = "scorch"
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
