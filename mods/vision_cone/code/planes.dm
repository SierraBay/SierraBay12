/mob
	plane = GAME_PLANE_FOV_HIDDEN
	var/face_dir_click

/obj/item/
	plane = GAME_PLANE_FOV_HIDDEN

/obj/aura/
	plane = GAME_PLANE_FOV_HIDDEN

/obj/effect/
	plane = GAME_PLANE_FOV_HIDDEN

/obj/decal/point
	plane = GAME_PLANE_FOV_HIDDEN


/obj/machinery/door/blast/force_open()
	. = ..()
	plane = DEFAULT_PLANE
/obj/machinery/door/blast/force_close()
	. = ..()
	plane = GAME_PLANE_ABOVE_FOV

/obj/structure/bed
	plane = GAME_PLANE_FOV_HIDDEN

/obj/structure/curtain
	plane = GAME_PLANE_FOV_HIDDEN

/obj/structure/roller_bed
	plane = GAME_PLANE_FOV_HIDDEN

/obj/structure/iv_stand
	plane = GAME_PLANE_FOV_HIDDEN

/obj/aiming_overlay
	plane = GAME_PLANE_FOV_HIDDEN

/obj/fluid
	plane = GAME_PLANE_FOV_HIDDEN

/obj/machinery/light
	plane = GAME_PLANE_FOV_HIDDEN

/image/hud_overlay
	plane = GAME_PLANE_FOV_HIDDEN

/obj/structure/flora/pottedplant
	plane = GAME_PLANE_FOV_HIDDEN
