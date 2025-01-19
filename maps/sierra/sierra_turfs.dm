/turf/simulated/wall
	name = "bulkhead"

/turf/simulated/floor
	name = "bare deck"

/turf/simulated/floor/tiled
	name = "deck"


/obj/machinery/door/airlock/glass/research
	stripe_color = COLOR_NT_RED

/obj/machinery/door/airlock/research
	stripe_color = COLOR_NT_RED

/obj/machinery/door/airlock/multi_tile/research
	stripe_color = COLOR_NT_RED

/turf/simulated/floor/shuttle_ceiling/sierra
	color = COLOR_OFF_WHITE

/turf/simulated/floor/shuttle_ceiling/sierra/air
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)

/*
* Z-mimic space turf part
*/

/proc/GetBelowZlevels(z)
	RETURN_TYPE(/list)
	. = list()
	for(var/level = z, HasBelow(level), level--)
		. |= level - 1

/proc/GetAboveZlevels(z)
	RETURN_TYPE(/list)
	. = list()
	for(var/level = z, HasAbove(level), level++)
		. |= level + 1

/turf/space/Initialize()
	. = ..()
	update_starlight()

	set_extension(src, /datum/extension/support_lattice)

	if (z_eventually_space)
		appearance = SSskybox.space_appearance_cache[(((x + y) ^ ~(x * y) + z) % 25) + 1]

	if(!HasBelow(z))
		return
	var/turf/below = GetBelow(src)

	if(istype(below, /turf/space))
		return
	var/area/A = below.loc

	if(!below.density && (A.area_flags & AREA_FLAG_EXTERNAL))
		return

	return INITIALIZE_HINT_LATELOAD // oh no! we need to switch to being a different kind of turf!

// Turfs for the non-bottom layers of multi-z space areas
/turf/space/open
	icon_state = ""
	z_flags = ZM_MIMIC_DEFAULTS | ZM_MIMIC_OVERWRITE | ZM_MIMIC_NO_AO
	z_eventually_space = 0


/turf/space/open/Initialize()
	for (var/level in GetBelowZlevels(z))
		var/turf/below = locate(x, y, level)
		if (!istype(below, /turf/space))
			z_eventually_space = FALSE
			break
		if (below.z_eventually_space != 0)
			z_eventually_space = below.z_eventually_space
			break
	if (!z_eventually_space == 0)
		z_eventually_space = TRUE
	return ..()
