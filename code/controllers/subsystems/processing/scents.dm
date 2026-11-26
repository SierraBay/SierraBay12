PROCESSING_SUBSYSTEM_DEF(scents)
	name = "Scents"
	priority = SS_PRIORITY_SCENTS
	wait = 2 SECONDS

	// [SIERRA-ADD] - Per-z map of eligible conscious human listeners for the active cycle
	var/list/smellers_by_z

/datum/controller/subsystem/processing/scents/Recover(datum/controller/subsystem/processing/P)
	..()
	smellers_by_z = null

/datum/controller/subsystem/processing/scents/fire(resumed = 0)
	if (!resumed)
		if (!length(processing) || !length(GLOB.living_players))
			return
		var/now = world.time
		var/max_z = world.maxz
		var/list/by_z = new /list(max_z)
		var/has_any = FALSE
		for (var/mob/living/carbon/human/H as anything in GLOB.living_players)
			if (!istype(H) || H.last_smelt >= now)
				continue
			if (H.species && !H.species.passive_scent_detection)
				continue
			if (H.stat != CONSCIOUS || H.failed_last_breath || H.wear_mask || (H.head && H.head.permeability_coefficient < 1))
				continue
			var/turf/HT = isturf(H.loc) ? H.loc : get_turf(H)
			if (!HT || !HT.return_air())
				continue
			var/hz = HT.z
			if (hz < 1 || hz > max_z)
				continue
			var/list/bucket = by_z[hz]
			if (!bucket)
				bucket = list()
				by_z[hz] = bucket
			bucket[H] = HT
			has_any = TRUE
		if (!has_any)
			return
		smellers_by_z = by_z
		current_run = processing.Copy()

	var/list/current_run = src.current_run
	var/list/by_z = src.smellers_by_z
	var/max_z = length(by_z)
	var/now = world.time

	while (length(current_run))
		var/datum/extension/scent/scent = current_run[length(current_run)]
		LIST_DEC(current_run)
		if (QDELETED(scent))
			if (scent)
				scent.is_processing = null
			processing -= scent
			continue
		var/atom/A = scent.holder
		if (!A)
			if (scent.Process() == PROCESS_KILL)
				scent.is_processing = null
				processing -= scent
			continue
		var/turf/ST = isturf(A.loc) ? A.loc : get_turf(A)
		var/sz = ST ? ST.z : 0
		var/list/z_smellers = (sz >= 1 && sz <= max_z) ? by_z[sz] : null
		if (length(z_smellers))
			var/r = scent.range
			var/sx = ST.x
			var/sy = ST.y
			var/near = FALSE
			for (var/mob/living/carbon/human/H as anything in z_smellers)
				var/turf/HT = z_smellers[H]
				if (abs(HT.x - sx) <= r && abs(HT.y - sy) <= r && H.last_smelt < now)
					near = TRUE
					break
			if (near)
				scent.emit_scent()
		if (MC_TICK_CHECK)
			return
// [/SIERRA-ADD]
