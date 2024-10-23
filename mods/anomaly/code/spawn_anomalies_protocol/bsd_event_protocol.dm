/datum/event/bsd_instability
	var/list/all_spawned_anomalies = list()
	var/list/possible_anomalies = list(
		/obj/anomaly/electra/three_and_three = 5,
		/obj/anomaly/electra/three_and_three/tesla = 3,
		/obj/anomaly/electra/three_and_three/tesla_second = 1,
		/obj/anomaly/vspishka = 3,
		/obj/anomaly/cooler/two_and_two = 2
	)


/datum/event/bsd_instability/start()
	set background = 1
	.=..()
	var/started_in = world.time
	var/list/turfs_for_spawn = list()
	for(var/obj/machinery/bluespacedrive/picked_drive in drives)
		for(var/turf/picked_turf in RANGE_TURFS(picked_drive.loc, 30))
			if(!TurfBlocked(picked_turf, space_allowed = FALSE) || TurfBlockedByAnomaly(picked_turf))
				LAZYADD(turfs_for_spawn, picked_turf)
	all_spawned_anomalies = generate_anomalies_in_turfs(possible_anomalies, turfs_for_spawn, 25, 40, 0, 0, 9, 9, "BSD event", started_in)


/datum/event/bsd_instability/end()
	.=..()
	for(var/obj/anomaly/picked_anomaly in all_spawned_anomalies)
		picked_anomaly.delete_anomaly()
