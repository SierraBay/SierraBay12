/obj/spawner_helper
	var/obj/mob_spawner/core
	icon = 'mods/anomaly/icons/effects.dmi'
	icon_state = "none"
	invisibility = 100

/obj/mob_spawner/proc/deploy_helper_parts()
	var/turf/my_turf = get_turf(src)
	for(var/turf/T in RANGE_TURFS(my_turf, detection_range))
		var/obj/spawner_helper/spawned = new /obj/spawner_helper(T)
		spawned.core = src
		LAZYADD(list_of_helpers, src)

/obj/spawner_helper/Cross(O)
	. = ..()
	core.spawn_mobs(O)

/obj/spawner_helper/Destroy()
	. = ..()
	LAZYREMOVE(core.list_of_helpers, src)
