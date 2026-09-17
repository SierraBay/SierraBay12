/obj/machinery/power/supermatter/explode()
	if(exploded)
		return ..()

	playsound(src, 'mods/utility_items/sounds/sm_pnr_mixed.ogg', 100, FALSE)

	return ..()

/obj/machinery/power/supermatter/Destroy()
	if(exploded)
		var/turf/detonation_turf = get_turf(src)
		if(istype(detonation_turf))
			playsound(detonation_turf, 'mods/utility_items/sounds/smcombined.ogg', 100, FALSE)

			spawn(3 SECONDS)
				var/list/affected_z = GetConnectedZlevels(detonation_turf.z)
				for(var/mob/M in GLOB.player_list)
					if(!M || !M.client)
						continue
					var/turf/T = get_turf(M)
					if(T && (T.z in affected_z) && !istype(M, /mob/new_player) && !isdeaf(M))
						sound_to(M, 'mods/utility_items/sounds/sm_delam_echo.ogg')

	return ..()
