SUBSYSTEM_DEF(xenoarch)
	name = "Xenoarcheology"
	flags = SS_NO_FIRE
	init_order = SS_INIT_XENOARCH
	var/static/list/xeno_artifact_turfs = list()
	var/static/list/xeno_digsite_turfs = list()

/datum/controller/subsystem/xenoarch/Initialize(start_uptime)
	var/datum/map/map = GLOB.using_map
	if (!map)
		return

	var/list/artifact_turfs = list()
	var/static/excavation_turf_chance = 0.5
	var/list/banned_levels = map.admin_levels + map.escape_levels
	for(var/z_level_index in mining_walls)
		if(text2num(z_level_index) in banned_levels)
			continue

		var/list/mining_turfs = mining_walls[z_level_index]
		if(!length(mining_turfs))
			continue

		for(var/turf/simulated/mineral/mineral_turf as anything in mining_turfs)
			if (!mineral_turf.density)
				continue

			if (!mineral_turf.geologic_data)
				mineral_turf.geologic_data = new(mineral_turf)

			if(!prob(excavation_turf_chance))
				continue

			xeno_digsite_turfs += mineral_turf
			var/list/possible_site_turfs = list()
			for(var/turf/simulated/mineral/T in RANGE_TURFS(mineral_turf, 2))
				if(!T.density)
					continue

				if(T.finds)
					continue

				possible_site_turfs += T

			possible_site_turfs = shuffle(possible_site_turfs)
			LIST_RESIZE(possible_site_turfs, min(rand(4, 12), length(possible_site_turfs)))

			var/site_type = get_random_digsite_type()
			for(var/turf/simulated/mineral/T as anything in possible_site_turfs)
				if(!T.finds)
					var/list/finds = list()
					if (prob(50))
						finds += new /datum/find (site_type, rand(10, 190))
					else if (prob(75))
						finds += new /datum/find (site_type, rand(10, 90))
						finds += new /datum/find (site_type, rand(110, 190))
					else
						finds += new /datum/find (site_type, rand(10, 50))
						finds += new /datum/find (site_type, rand(60, 140))
						finds += new /datum/find (site_type, rand(150, 190))
					var/datum/find/F = finds[1]
					if (F.excavation_required <= F.view_range)
						T.archaeo_overlay = "overlay_archaeo[rand(1, 3)]"
						T.update_icon()
					T.finds = finds

				if(site_type == DIGSITE_GARDEN)
					continue

				if(site_type == DIGSITE_ANIMAL)
					continue

				artifact_turfs += T

			CHECK_TICK

	var/xeno_artifact_turfs_amount = min(rand(6, 12), length(artifact_turfs))
	for (var/i = 1 to xeno_artifact_turfs_amount)
		var/turf/simulated/mineral/selected_mineral = pick_n_take(artifact_turfs)
		// Failsafe for invalid turf types
		if (!istype(selected_mineral))
			continue

		xeno_artifact_turfs += selected_mineral
		selected_mineral.artifact_find = new
