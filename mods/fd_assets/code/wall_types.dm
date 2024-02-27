/turf/simulated/wall/r_wall/invincible
	icon_state = "r_invinsible"
	floor_type = /turf/simulated/floor/reinforced
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

/turf/simulated/wall/r_wall/invincible/New(newloc)
	..(newloc, MATERIAL_PLASTEEL,MATERIAL_TITANIUM)

/turf/simulated/wall/r_wall/invincible/Initialize()
	. = ..()
	desc = "A huge chunk of metal used to separate rooms. This one looks very durable."

/turf/simulated/wall/r_wall/invincible/bullet_act()
	return

/turf/simulated/wall/r_wall/invincible/can_damage_health()
	SHOULD_CALL_PARENT(FALSE)
	return FALSE

/turf/simulated/wall/r_wall/invincible/attack_hand()
	return

/turf/simulated/wall/r_wall/invincible/attackby()
	return

/turf/simulated/wall/r_wall/invincible/can_melt()
	return

/turf/simulated/wall/r_wall/invincible/ex_act()
	return

/turf/simulated/wall/r_wall/invincible/hitby()
	return

/turf/simulated/wall/r_wall/invincible/prepainted
	paint_color = COLOR_GUNMETAL
