/// Sierra shuttles that must be on the ship at save or they are left behind.
#define ODYSSEY_TRACKED_SHUTTLE_NAMES list("Guppy", "Charon", "Petrov", "Phaethon")


/proc/odyssey_shuttle_is_tracked(datum/shuttle/S)
	if (!istype(S))
		return FALSE
	if (istype(S, /datum/shuttle/autodock/ferry/escape_pod))
		return TRUE
	return S.name in ODYSSEY_TRACKED_SHUTTLE_NAMES


/proc/odyssey_shuttle_is_on_sierra(datum/shuttle/S)
	if (!istype(S))
		return FALSE
	var/datum/shuttle/autodock/ferry/escape_pod/pod = S
	if (istype(pod) && pod.location)
		return FALSE
	var/obj/shuttle_landmark/landmark = S.current_location
	if (istype(landmark))
		var/turf/landmark_turf = get_turf(landmark)
		if (istype(landmark_turf) && (landmark_turf.z in GLOB.using_map.station_levels))
			return TRUE
	for (var/area/shuttle_area in S.shuttle_area)
		for (var/turf/area_turf in shuttle_area)
			if (area_turf.z in GLOB.using_map.station_levels)
				return TRUE
			break
	return FALSE


/proc/odyssey_shuttle_abandon_destination(datum/shuttle/S)
	if (!istype(S))
		return null
	if (istype(S, /datum/shuttle/autodock/ferry))
		var/datum/shuttle/autodock/ferry/ferry = S
		if (istype(ferry.waypoint_offsite) && S.current_location != ferry.waypoint_offsite)
			return ferry.waypoint_offsite
	if (istype(S, /datum/shuttle/autodock))
		var/datum/shuttle/autodock/dock = S
		if (istype(dock.landmark_transition) && S.current_location != dock.landmark_transition)
			return dock.landmark_transition
	return null


/// Rough structural/machinery damage inside shuttle areas (cheap; no nested inventories).
/proc/odyssey_shuttle_damage_score(datum/shuttle/S)
	if (!istype(S) || !islist(S.shuttle_area))
		return 0
	var/score = 0
	for (var/area/A in S.shuttle_area)
		if (!istype(A))
			continue
		for (var/turf/T in A)
			if (istype(T, /turf/simulated/wall))
				var/turf/simulated/wall/W = T
				var/wall_max = W.get_max_health()
				var/wall_cur = W.get_current_health()
				if (wall_max > 0 && wall_cur < wall_max)
					score += 1 + round((wall_max - wall_cur) / max(wall_max * 0.25, 1))
			else if (istype(T, /turf/simulated/floor))
				var/turf/simulated/floor/F = T
				if (F.broken || F.burnt)
					score += 1
			for (var/obj/machinery/M in T)
				if (QDELETED(M))
					continue
				if (M.reason_broken)
					score += 3
				else
					var/max_health = M.get_max_health()
					var/cur_health = M.get_current_health()
					if (max_health > 0 && cur_health < max_health)
						score += 1
			CHECK_TICK
	return score


/proc/odyssey_shuttle_repair_cost(damage_score)
	return max(0, damage_score) * ODYSSEY_SHUTTLE_REPAIR_CREDITS_PER_POINT


/proc/odyssey_sync_abandoned_shuttle_names()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/names = list()
	for (var/shuttle_name in state.shuttle_reports)
		var/list/report = state.shuttle_reports[shuttle_name]
		if (islist(report) && report["status"] == ODYSSEY_SHUTTLE_STATUS_ABANDONED)
			names += shuttle_name
	state.abandoned_shuttles = names


/proc/odyssey_load_shuttle_reports(list/meta)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/reports = meta?["shuttle_reports"]
	if (islist(reports))
		state.shuttle_reports = reports.Copy()
		odyssey_sync_abandoned_shuttle_names()
		return
	// Legacy: only a flat abandoned name list.
	state.shuttle_reports = list()
	var/list/legacy = meta?["abandoned_shuttles"]
	if (islist(legacy))
		for (var/shuttle_name in legacy)
			state.shuttle_reports[shuttle_name] = list("status" = ODYSSEY_SHUTTLE_STATUS_ABANDONED)
	odyssey_sync_abandoned_shuttle_names()


/proc/odyssey_collect_abandoned_shuttles()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/previous_reports = islist(state.shuttle_reports) ? state.shuttle_reports.Copy() : list()
	var/list/previous_abandoned = islist(state.abandoned_shuttles) ? state.abandoned_shuttles.Copy() : list()
	state.shuttle_reports = list()
	if (!SSshuttle)
		odyssey_sync_abandoned_shuttle_names()
		return
	for (var/shuttle_name in SSshuttle.shuttles)
		var/datum/shuttle/S = SSshuttle.shuttles[shuttle_name]
		if (!odyssey_shuttle_is_tracked(S))
			continue
		if (!odyssey_shuttle_is_on_sierra(S))
			state.shuttle_reports[S.name] = list("status" = ODYSSEY_SHUTTLE_STATUS_ABANDONED)
			if (!(S.name in previous_abandoned))
				odyssey_chronicle_append(
					ODYSSEY_CHRONICLE_KIND_SHUTTLE,
					"Утерян шаттл: [S.name]",
					"На момент смены шаттл не находился на Сьерре. Док останется пустым.",
					ODYSSEY_CHRONICLE_VIS_PUBLIC,
					list("shuttle" = S.name)
				)
			log_game("ODYSSEY: shuttle left behind name=[S.name] loc=[S.current_location]")
			continue

		// Docked on Sierra — check if it came back (or stayed) damaged.
		var/damage = odyssey_shuttle_damage_score(S)
		if (damage < ODYSSEY_SHUTTLE_DAMAGE_THRESHOLD)
			continue
		var/cost = odyssey_shuttle_repair_cost(damage)
		var/list/prev = previous_reports[S.name]
		var/fee_pending = TRUE
		if (islist(prev) && prev["status"] == ODYSSEY_SHUTTLE_STATUS_DAMAGED && !prev["fee_pending"])
			var/prev_damage = text2num(prev["damage"]) || 0
			if (damage <= prev_damage + ODYSSEY_SHUTTLE_REPAIR_REBILL_DELTA)
				fee_pending = FALSE
		state.shuttle_reports[S.name] = list(
			"status" = ODYSSEY_SHUTTLE_STATUS_DAMAGED,
			"damage" = damage,
			"repair_cost" = cost,
			"fee_pending" = fee_pending
		)
		var/was_damaged = islist(prev) && prev["status"] == ODYSSEY_SHUTTLE_STATUS_DAMAGED
		if (!was_damaged || fee_pending)
			odyssey_chronicle_append(
				ODYSSEY_CHRONICLE_KIND_SHUTTLE_DAMAGED,
				"Шаттл повреждён: [S.name]",
				"Оценка повреждений: [damage]. Ориентировочный ремонт: [cost] таллеров (Engineering).",
				ODYSSEY_CHRONICLE_VIS_PUBLIC,
				list("shuttle" = S.name, "damage" = damage, "repair_cost" = cost)
			)
		log_game("ODYSSEY: shuttle damaged name=[S.name] damage=[damage] cost=[cost] fee_pending=[fee_pending]")
		CHECK_TICK
	odyssey_sync_abandoned_shuttle_names()


/proc/odyssey_hide_abandoned_overmap(datum/shuttle/S)
	if (!istype(S))
		return
	for (var/obj/overmap/visitable/ship/landable/landable in world)
		if (landable.shuttle == S.name)
			qdel(landable)


/proc/odyssey_shuttle_repair_account()
	var/datum/money_account/A = department_accounts["Engineering"]
	if (istype(A))
		return A
	if (istype(station_account))
		return station_account
	return null


/proc/odyssey_apply_shuttle_repair_fees()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!islist(state.shuttle_reports) || !length(state.shuttle_reports))
		return
	var/datum/money_account/account = odyssey_shuttle_repair_account()
	var/total_charged = 0
	var/list/charged_names = list()
	for (var/shuttle_name in state.shuttle_reports)
		var/list/report = state.shuttle_reports[shuttle_name]
		if (!islist(report) || report["status"] != ODYSSEY_SHUTTLE_STATUS_DAMAGED)
			continue
		if (!report["fee_pending"])
			continue
		var/cost = text2num(report["repair_cost"]) || 0
		var/damage = text2num(report["damage"]) || 0
		if (cost < 1)
			report["fee_pending"] = FALSE
			state.shuttle_reports[shuttle_name] = report
			continue
		var/charged = 0
		if (!istype(account))
			report["fee_pending"] = FALSE
			report["fee_charged"] = 0
			state.shuttle_reports[shuttle_name] = report
			log_game("ODYSSEY: shuttle repair fee skipped (no account) name=[shuttle_name] cost=[cost]")
			continue
		charged = min(cost, max(0, account.money))
		if (charged < 1)
			report["fee_pending"] = FALSE
			report["fee_charged"] = 0
			state.shuttle_reports[shuttle_name] = report
			log_game("ODYSSEY: shuttle repair fee skipped (empty account) name=[shuttle_name] cost=[cost]")
			continue
		var/purpose = "Odyssey deck: shuttle repair / spare parts — [shuttle_name] (damage [damage], assessed [cost])"
		if (!account.withdraw(charged, purpose, "Odyssey Campaign Systems"))
			log_error("ODYSSEY: shuttle repair withdraw failed name=[shuttle_name] charged=[charged] money=[account.money]")
			continue // leave fee_pending so a later continue can retry
		report["fee_pending"] = FALSE
		report["fee_charged"] = charged
		state.shuttle_reports[shuttle_name] = report
		total_charged += charged
		charged_names += shuttle_name
		log_game("ODYSSEY: shuttle repair fee name=[shuttle_name] cost=[cost] charged=[charged]")
	if (!length(charged_names))
		return
	var/account_label = istype(account) ? (account == station_account ? "счёта станции" : "счёта Engineering") : "резерва (счёт недоступен)"
	priority_announcement.Announce(
		"Deck reports: shuttle damage assessment for [english_list(charged_names)]. Spare parts / repair allocation: [total_charged] thaler drawn from the [account_label].",
		"Odyssey Deck Report"
	)
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_SHUTTLE_DAMAGED,
		"Списание на ремонт шаттлов",
		"Списано [total_charged] таллеров ([account_label]): [english_list(charged_names)].",
		ODYSSEY_CHRONICLE_VIS_COMMAND,
		list("charged" = total_charged, "shuttles" = charged_names)
	)
	// Persist cleared fee_pending so a crash/rejoin cannot double-bill the same report.
	var/list/meta = odyssey_load_meta()
	if (islist(meta))
		meta["shuttle_reports"] = state.shuttle_reports
		meta["abandoned_shuttles"] = state.abandoned_shuttles
		odyssey_write_meta(meta)


/proc/odyssey_apply_abandoned_shuttles()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!islist(state.abandoned_shuttles) || !length(state.abandoned_shuttles) || !SSshuttle)
		return
	var/moved = 0
	for (var/shuttle_name in state.abandoned_shuttles)
		var/datum/shuttle/S = SSshuttle.shuttles[shuttle_name]
		if (!istype(S) || !odyssey_shuttle_is_on_sierra(S))
			continue
		var/obj/shuttle_landmark/destination = odyssey_shuttle_abandon_destination(S)
		if (!istype(destination))
			log_error("ODYSSEY: cannot abandon shuttle [shuttle_name]: no offsite/transit landmark")
			continue
		var/old_knockdown = S.knockdown
		S.knockdown = FALSE
		var/ok = S.attempt_move(destination)
		S.knockdown = old_knockdown
		if (!ok)
			log_error("ODYSSEY: abandon move failed for [shuttle_name] to [destination]")
			continue
		odyssey_hide_abandoned_overmap(S)
		moved++
	log_debug("ODYSSEY: apply_abandoned_shuttles moved=[moved]/[length(state.abandoned_shuttles)]")


#undef ODYSSEY_TRACKED_SHUTTLE_NAMES
