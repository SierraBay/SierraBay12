/mob
	plane = GAME_PLANE_FOV_HIDDEN
	var/face_dir_click

// All objects default to FOV-hidden plane to preserve layer ordering with mobs.
// Specific subtypes (e.g. /obj/screen) override this with their own explicit plane.
/obj
	plane = GAME_PLANE_FOV_HIDDEN

/obj/machinery/door/blast/force_open()
	. = ..()
	plane = GAME_PLANE_FOV_HIDDEN
/obj/machinery/door/blast/force_close()
	. = ..()
	plane = GAME_PLANE_ABOVE_FOV

/image/hud_overlay
	plane = GAME_PLANE_FOV_HIDDEN
