/obj/sctructure/titan_ghost
	anchored = TRUE
	layer = 500
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

/obj/sctructure/titan_ghost/proc/delete_ghost()
	return

/obj/sctructure/titan_ghost/human_ghost
	icon = 'mods/cut_scenes/icons/ghost.dmi'
	icon_state = "man_ghost"

/obj/sctructure/titan_ghost/human_ghost/delete_ghost()
	set waitfor = FALSE
	flick("ghost_destroing", src)
	sleep(1.5 SECONDS)
	qdel(src)

/obj/sctructure/titan_ghost/human_ghost/woman
	icon_state = "woman_ghost"
