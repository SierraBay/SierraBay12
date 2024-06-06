

/obj/wallframe_spawn/reinforced/crescent
	name = "reinforced wall frame crescent window spawner"
	win_path = /obj/structure/window/reinforced/crescent/full
	frame_path = /obj/structure/wall_frame/invincible

/obj/structure/window/reinforced/crescent/full
	dir = 5
	icon_state = "rwindow_full"

/obj/structure/wall_frame/invincible
	paint_color = COLOR_WALL_GUNMETAL

/obj/structure/wall_frame/invincible/attack_hand()
	return

/obj/structure/wall_frame/invincible/use_tool()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/structure/wall_frame/invincible/ex_act()
	return

/obj/structure/wall_frame/invincible/hitby()
	return

/obj/structure/wall_frame/invincible/can_damage_health()
	SHOULD_CALL_PARENT(FALSE)
	return FALSE
