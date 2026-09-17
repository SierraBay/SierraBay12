/obj/machinery/power/supermatter/explode()
	if(exploded)
		return ..()

	// The core has crossed the point of no return: delamination is now unavoidable and it starts pulling everything into itself.
	playsound(src, 'mods/utility_items/sounds/sm_pnr_mixed.ogg', 100, FALSE)

	return ..()

/obj/machinery/power/supermatter/Destroy()
	if(exploded)
		var/turf/detonation_turf = get_turf(src)
		if(istype(detonation_turf))
			// The detonation itself, only audible near the supermatter.
			playsound(detonation_turf, 'mods/utility_items/sounds/smcombined.ogg', 100, FALSE)

			// Give the blast itself time to play out before its echo reaches the rest of the ship.
			spawn(3 SECONDS)
				var/list/affected_z = GetConnectedZlevels(detonation_turf.z)
				for(var/mob/M in GLOB.player_list)
					if(!M || !M.client)
						continue
					var/turf/T = get_turf(M)
					if(T && (T.z in affected_z) && !istype(M, /mob/new_player) && !isdeaf(M))
						sound_to(M, 'mods/utility_items/sounds/sm_delam_echo.ogg')

	return ..()
