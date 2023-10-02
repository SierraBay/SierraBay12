// OVERWRITE
/obj/machinery/camera
	icon = 'packs/infinity/icons/obj/monitors.dmi'

/obj/machinery/hologram/holopad
	icon = 'packs/infinity/icons/obj/stationobjs.dmi'

/obj/machinery/door/blast/shutters/open
	icon_state = "shutter0"

/obj/machinery/door/blast/regular/open
	icon_state = "pdoor0"

// ADD
/obj/machinery/door/airlock/glass/engineering/no_stripe
	stripe_color = null

/obj/machinery/power/apc/high/critical
	is_critical = 1

/obj/machinery/door/window/phoronreinforced
	color = GLASS_COLOR_BORON
	health_max = 300

/obj/machinery/disposal/small
	icon = 'packs/infinity/icons/obj/machinery/disposal_small.dmi'
	density = FALSE

/obj/machinery/disposal/small/on_update_icon()
	ClearOverlays()
	if(MACHINE_IS_BROKEN(src))
		mode = 0
		flush = 0
		return

	// flush handle
	if(flush)
		AddOverlays(image(icon, "dispover-handle"))

	// only handle is shown if no power
	if(!is_powered() || mode == -1)
		return

	// 	check for items/vomit in disposal - occupied light
	if(length(contents) > LAZYLEN(component_parts) || reagents.total_volume)
		AddOverlays(image(icon, "dispover-full"))

	// charging and ready light
	if(mode == 1)
		AddOverlays(image(icon, "dispover-charge"))
	else if(mode == 2)
		AddOverlays(image(icon, "dispover-ready"))
