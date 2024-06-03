/turf/simulated/wall/invincible
	icon_state = "r_invinsible"
	floor_type = /turf/simulated/floor/reinforced
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	icon = 'mods/_fd/fd_assets/icons/wall_masks.dmi'

/turf/simulated/wall/invincible/New(newloc)
	..(newloc, MATERIAL_PLASTEEL,MATERIAL_TITANIUM)

/turf/simulated/wall/invincible/Initialize()
	. = ..()
	desc = "A huge chunk of metal used to separate rooms. This one looks very durable."

/turf/simulated/wall/invincible/bullet_act()
	return

/turf/simulated/wall/invincible/can_damage_health()
	SHOULD_CALL_PARENT(FALSE)
	return FALSE

/turf/simulated/wall/invincible/attack_hand()
	return

/turf/simulated/wall/invincible/attackby()
	return

/turf/simulated/wall/invincible/can_melt()
	return

/turf/simulated/wall/invincible/ex_act()
	return

/turf/simulated/wall/invincible/hitby()
	return

/turf/simulated/wall/invincible/prepainted
	paint_color = COLOR_GUNMETAL
