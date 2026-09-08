// Netspace turfs

/turf/simulated/floor/holofloor/netspace
	name = "netspace floor"
	icon = 'mods/vr/icons/netspace_turfs.dmi'
	icon_state = "netfloor"
	initial_flooring = null

/turf/unsimulated/wall/netspace
	name = "netspace wall"
	icon = 'mods/vr/icons/netspace_turfs.dmi'
	icon_state = "netwall"


// Netspace objects


// Doors core
/obj/machinery/door/airlock/netspace
	name = "netspace blockade"
	icon = 'mods/vr/icons/netspace_obj.dmi'
	icon_state = "barrier"
	var/icon_base = "barrier"
	bolts_file = 'icons/obj/doors/elevator/lights_bolts.dmi'
	deny_file = 'icons/obj/doors/elevator/lights_deny.dmi'
	lights_file = 'icons/obj/doors/elevator/lights_green.dmi'

	layer = ABOVE_HUMAN_LAYER
	plane = GAME_PLANE_FOV_HIDDEN

/obj/machinery/door/airlock/netspace/on_update_icon()
	update_dir()
	if(density && !locked)
		icon_state = "[icon_base]"
	else if(locked)
		icon_state = "[icon_base]_locked"
	else
		icon_state = "[icon_base]_open"
	return


// Doors variants

/obj/machinery/door/airlock/netspace/dojo
	icon_state = "door_dojo"
	icon_base = "door_dojo"

/obj/machinery/door/airlock/netspace/firewall
	icon_state = "firewall"
	icon_base = "firewall"

// Level
/obj/machinery/button/alternate/door/bolts/netspace
	name = "access switch"
	icon = 'mods/vr/icons/netspace_obj.dmi'
	icon_state = "level"
	stock_part_presets = list(/singleton/stock_part_preset/radio/basic_transmitter/button/netspace_bolt)

/obj/machinery/button/alternate/door/on_update_icon()
	if(operating)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]"

/singleton/stock_part_preset/radio/basic_transmitter/button/netspace_bolt
	frequency = AIRLOCK_FREQ
	transmit_on_change = list("toggle_bolts" = /singleton/public_access/public_variable/button_active)
