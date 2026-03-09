#define SSPOWERNETS_POWERNETS 1
#define SSPOWERNETS_POWER_OBJECTS 2

SUBSYSTEM_DEF(powernets)
	name = "Powernets"
	init_order = SS_INIT_MACHINES
	priority = SS_PRIORITY_POWERNETS
	flags = SS_KEEP_TIMING
	var/static/current_step = SSPOWERNETS_POWERNETS
	var/static/cost_powernets = 0
	var/static/cost_power_objects = 0
	var/static/powernet_last_snapshot_size = 0
	var/static/powernet_last_processed = 0
	var/static/powernet_last_skipped_null = 0
	var/static/powernet_last_removed_qdeleted = 0
	var/static/powernet_next_anomaly_log_time = 0
	/// When TRUE, runtime powernet processing uses only batch snapshots for native solving.
	/// Networks without batch data fall back directly to DM solver (single FFI call is skipped).
	var/static/power_shadow_batch_only_runtime = TRUE
	var/static/power_shadow_native_autogate_enabled = TRUE
	var/static/power_shadow_native_autogate_probe_interval = 100
	var/static/power_shadow_native_autogate_loss_streak = 0
	var/static/power_shadow_native_autogate_trip_threshold = 5
	var/static/power_shadow_native_autogate_cooldown_ticks = 1200
	var/static/power_shadow_native_autogate_suspended_until = 0
	var/static/power_shadow_native_autogate_next_probe_tick = 0
	var/static/power_shadow_native_autogate_last_probe_dm_us = 0
	var/static/power_shadow_native_autogate_last_probe_batch_us = 0
	var/static/power_shadow_native_last_batch_expected = 0
	var/static/power_shadow_native_batch_perf_samples = 0
	var/static/power_shadow_native_batch_perf_build_us_sum = 0
	var/static/power_shadow_native_batch_perf_encode_us_sum = 0
	var/static/power_shadow_native_batch_perf_call_us_sum = 0
	var/static/power_shadow_native_batch_perf_decode_us_sum = 0
	var/static/list/powernets = list()
	var/static/list/power_objects = list()

/datum/controller/subsystem/powernets/Recover()
	current_step = SSPOWERNETS_POWERNETS

/datum/controller/subsystem/powernets/fire(resumed, no_mc_tick)
	var/timer
	if(!resumed)
		current_step = SSPOWERNETS_POWERNETS
	if(current_step == SSPOWERNETS_POWERNETS)
		timer = world.tick_usage
		process_powernets(resumed, no_mc_tick)
		cost_powernets = MC_AVERAGE(cost_powernets, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSPOWERNETS_POWER_OBJECTS
		resumed = FALSE
	if(current_step == SSPOWERNETS_POWER_OBJECTS)
		timer = world.tick_usage
		process_power_objects(resumed, no_mc_tick)
		cost_power_objects = MC_AVERAGE(cost_power_objects, (world.tick_usage - timer) * world.tick_lag)
		if(state != SS_RUNNING)
			return
		current_step = SSPOWERNETS_POWERNETS

/datum/controller/subsystem/powernets/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	var/autogate_state = "off"
	if(power_shadow_native_autogate_enabled)
		if(world.time < power_shadow_native_autogate_suspended_until)
			autogate_state = "cooldown [power_shadow_native_autogate_suspended_until - world.time]"
		else
			autogate_state = "armed"
	..({"\
		Queues: \
		Networks [length(powernets)] \
		Objects [length(power_objects)]\n\
		Costs: \
		Networks [Round(cost_powernets)] \
		Objects [Round(cost_power_objects)]\n\
		PowerLoop: \
		Snap [powernet_last_snapshot_size] \
		Done [powernet_last_processed] \
		Null [powernet_last_skipped_null] \
		QDel [powernet_last_removed_qdeleted]\n\
		NativeGate [autogate_state] \
		Loss [power_shadow_native_autogate_loss_streak] \
		ProbeDM [round(power_shadow_native_autogate_last_probe_dm_us, 0.1)] \
		ProbeBatch [round(power_shadow_native_autogate_last_probe_batch_us, 0.1)]
	"})

/// Rebuilds power networks from scratch. Called by world initialization and elevators.
/datum/controller/subsystem/powernets/proc/makepowernets()
	for(var/datum/powernet/powernet as anything in powernets)
		qdel(powernet)
	powernets.Cut()
	power_shadow_native_autogate_loss_streak = 0
	power_shadow_native_autogate_suspended_until = 0
	power_shadow_native_autogate_next_probe_tick = world.time + max(power_shadow_native_autogate_probe_interval, 1)
	power_shadow_native_autogate_last_probe_dm_us = 0
	power_shadow_native_autogate_last_probe_batch_us = 0
	power_shadow_native_last_batch_expected = 0
	reset_power_shadow_native_batch_perf()
	rustg_power_shadow_stateful_reset()
	setup_powernets_for_cables(GLOB.cable_list)


/datum/controller/subsystem/powernets/proc/setup_powernets_for_cables(list/cables)
	for (var/obj/structure/cable/cable as anything in cables)
		if (cable.powernet)
			continue
		var/datum/powernet/network = new
		network.add_cable(cable)
		propagate_network(cable, cable.powernet)

/datum/controller/subsystem/powernets/proc/reset_power_shadow_native_batch_perf()
	power_shadow_native_batch_perf_samples = 0
	power_shadow_native_batch_perf_build_us_sum = 0
	power_shadow_native_batch_perf_encode_us_sum = 0
	power_shadow_native_batch_perf_call_us_sum = 0
	power_shadow_native_batch_perf_decode_us_sum = 0


/datum/controller/subsystem/powernets/proc/record_power_shadow_native_batch_perf(build_us, encode_us, call_us, decode_us, samples = 1)
	samples = max(round(samples), 0)
	if(!samples)
		return

	power_shadow_native_batch_perf_samples += samples
	power_shadow_native_batch_perf_build_us_sum += max(build_us, 0)
	power_shadow_native_batch_perf_encode_us_sum += max(encode_us, 0)
	power_shadow_native_batch_perf_call_us_sum += max(call_us, 0)
	power_shadow_native_batch_perf_decode_us_sum += max(decode_us, 0)


/datum/controller/subsystem/powernets/proc/get_power_shadow_native_batch_perf_data()
	var/samples = max(power_shadow_native_batch_perf_samples, 0)
	return list(
		"samples" = samples,
		"avg_build_us" = samples ? power_shadow_native_batch_perf_build_us_sum / samples : 0,
		"avg_encode_us" = samples ? power_shadow_native_batch_perf_encode_us_sum / samples : 0,
		"avg_call_us" = samples ? power_shadow_native_batch_perf_call_us_sum / samples : 0,
		"avg_decode_us" = samples ? power_shadow_native_batch_perf_decode_us_sum / samples : 0
	)


/datum/controller/subsystem/powernets/proc/power_shadow_native_make_snapshot_entry(list/snapshot, reuse_mode = null)
	if(!islist(snapshot))
		return null
	var/list/entry = list("snapshot" = snapshot)
	if(reuse_mode)
		entry["reuse_mode"] = reuse_mode
	return entry

/datum/controller/subsystem/powernets/proc/power_shadow_native_make_batch_metadata(datum/powernet/PN, numapc = -1)
	if(!istype(PN))
		return null
	if(numapc < 0)
		numapc = PN.get_apc_terminal_count()
	return list(
		"numapc" = numapc,
		"use_minimal_decode" = (PN.shadow_solver_write_mode == "fea_only"),
		"decode_write_fields" = PN.should_decode_shadow_solver_native_write_fields(numapc)
	)

/datum/controller/subsystem/powernets/proc/power_shadow_native_precompute_batch_target(datum/powernet/PN, list/snapshot_by_network)
	if(!istype(PN))
		return FALSE
	var/numapc = PN.get_apc_terminal_count()
	var/list/reusable_entry = PN.try_get_reusable_shadow_solver_snapshot(numapc)
	if(!islist(reusable_entry))
		return TRUE

	var/list/snapshot = reusable_entry["snapshot"]
	if(islist(snapshot) && islist(snapshot_by_network))
		snapshot_by_network[PN] = power_shadow_native_make_snapshot_entry(snapshot, reusable_entry["reuse_mode"])
	return FALSE

/datum/controller/subsystem/powernets/proc/power_shadow_native_should_skip_batch_target(datum/powernet/PN)
	if(!istype(PN))
		return TRUE
	if(!PN.shadow_solver_enabled || !PN.shadow_solver_native_enabled)
		return TRUE
	var/numapc = PN.get_apc_terminal_count()
	return islist(PN.try_get_reusable_shadow_solver_snapshot(numapc))


/datum/controller/subsystem/powernets/proc/power_shadow_native_autogate_is_suspended()
	if(!power_shadow_native_autogate_enabled)
		return FALSE
	return world.time < power_shadow_native_autogate_suspended_until


/datum/controller/subsystem/powernets/proc/power_shadow_native_solve_batch_stateful(list/batch_targets, list/batch_dynamic_payload, list/phase_accumulator = null, use_compact_payload = TRUE, use_legacy_id = FALSE, list/batch_decode_metadata = null)
	var/static/native_stateful_supported = TRUE
	var/static/native_stateful_failure_streak = 0
	var/static/timer_id = "power_shadow_native_batch_phase_stateful"
	if(!native_stateful_supported || !islist(batch_targets) || !length(batch_targets))
		return null
	if(!islist(batch_dynamic_payload) || length(batch_dynamic_payload) != length(batch_targets))
		return null

	var/list/register_payload = list()
	if(islist(phase_accumulator))
		rustg_time_reset(timer_id)
	for(var/datum/powernet/PN in batch_targets)
		if(PN.shadow_solver_native_stateful_registered_revision != PN.shadow_solver_native_topology_revision)
			var/datum/power_solver/solver = PN.ensure_shadow_solver()
			if(!istype(solver))
				continue
			var/list/register_item = PN.build_shadow_solver_native_stateful_register_payload(solver, TRUE, FALSE)
			if(islist(register_item))
				register_payload += list(register_item)
	if(islist(phase_accumulator))
		phase_accumulator["build_us"] += max(rustg_time_microseconds(timer_id), 0)

	var/payload_json
	if(islist(phase_accumulator))
		rustg_time_reset(timer_id)
	var/register_json = json_encode(register_payload)
	if(!istext(register_json) || !length(register_json))
		return null
	var/solve_json = "\[\]"
	if(length(batch_dynamic_payload))
		solve_json = "\[[jointext(batch_dynamic_payload, ",")]\]"
	payload_json = "{\"register\":" + register_json + ",\"solve\":" + solve_json + "}"
	if(islist(phase_accumulator))
		phase_accumulator["encode_us"] += max(rustg_time_microseconds(timer_id), 0)
	if(!istext(payload_json) || !length(payload_json))
		return null

	if(islist(phase_accumulator))
		rustg_time_reset(timer_id)
	var/raw = rustg_power_shadow_stateful_apply(payload_json)
	if(islist(phase_accumulator))
		phase_accumulator["call_us"] += max(rustg_time_microseconds(timer_id), 0)
	if(!istext(raw) || !length(raw))
		native_stateful_failure_streak++
		if(native_stateful_failure_streak >= 5)
			native_stateful_supported = FALSE
			log_debug("Power shadow native stateful batch disabled after repeated failures.")
		return null

	if(islist(phase_accumulator))
		rustg_time_reset(timer_id)
	var/list/decoded = json_decode(raw)
	if(islist(decoded) && islist(decoded["results"]))
		decoded = decoded["results"]
	if(!islist(decoded))
		if(islist(phase_accumulator))
			phase_accumulator["decode_us"] += max(rustg_time_microseconds(timer_id), 0)
		native_stateful_failure_streak++
		if(findtext(raw, "power_shadow_stateful_apply") || findtext(raw, "not found"))
			native_stateful_supported = FALSE
			log_debug("Power shadow native stateful batch disabled: rust-g power_shadow_stateful_apply is unavailable.")
		else if(native_stateful_failure_streak >= 5)
			native_stateful_supported = FALSE
			log_debug("Power shadow native stateful batch disabled after repeated decode failures.")
		return null

	native_stateful_failure_streak = 0
	var/list/snapshot_by_network = list()
	var/index = 1
	for(var/datum/powernet/PN in batch_targets)
		if(index > length(decoded))
			break
		var/list/decode_metadata = islist(batch_decode_metadata) ? batch_decode_metadata[PN] : null
		var/numapc = islist(decode_metadata) ? decode_metadata["numapc"] : PN.get_apc_terminal_count()
		var/use_minimal_decode = islist(decode_metadata) ? decode_metadata["use_minimal_decode"] : (PN.shadow_solver_write_mode == "fea_only")
		var/decode_write_fields = islist(decode_metadata) ? decode_metadata["decode_write_fields"] : PN.should_decode_shadow_solver_native_write_fields(numapc)
		var/list/snapshot = PN.decode_shadow_solver_native_snapshot(decoded[index], use_minimal_decode, decode_write_fields)
		if(islist(snapshot))
			snapshot_by_network[PN] = snapshot
			PN.shadow_solver_native_stateful_registered_revision = PN.shadow_solver_native_topology_revision
		index++
	if(islist(phase_accumulator))
		phase_accumulator["decode_us"] += max(rustg_time_microseconds(timer_id), 0)

	return snapshot_by_network


/datum/controller/subsystem/powernets/proc/power_shadow_native_solve_batch(list/powernets_snapshot, collect_phase_perf = TRUE)
	var/static/native_many_supported = TRUE
	var/static/native_many_failure_streak = 0
	var/static/timer_id = "power_shadow_native_batch_phase_main"
	power_shadow_native_last_batch_expected = 0
	if(!islist(powernets_snapshot) || !length(powernets_snapshot))
		return null

	var/list/phase_accumulator
	if(collect_phase_perf)
		phase_accumulator = list(
			"build_us" = 0,
			"encode_us" = 0,
			"call_us" = 0,
			"decode_us" = 0
		)

	var/list/snapshot_by_network = list()
	var/list/batch_targets = list()
	var/list/batch_dynamic_payload = list()
	var/list/batch_decode_metadata = list()
	if(islist(phase_accumulator))
		rustg_time_reset(timer_id)
	for(var/datum/powernet/PN in powernets_snapshot)
		if(!PN || QDELETED(PN))
			continue
		if(!PN.shadow_solver_enabled || !PN.shadow_solver_native_enabled)
			continue
		if(!power_shadow_native_precompute_batch_target(PN, snapshot_by_network))
			continue
		var/numapc = PN.get_apc_terminal_count()
		var/list/decode_metadata = power_shadow_native_make_batch_metadata(PN, numapc)
		if(!islist(decode_metadata))
			continue
		var/dynamic_payload = PN.build_shadow_solver_native_stateful_dynamic_payload_json()
		if(!istext(dynamic_payload) || !length(dynamic_payload))
			continue
		batch_targets += PN
		batch_dynamic_payload += list(dynamic_payload)
		batch_decode_metadata[PN] = decode_metadata
	if(islist(phase_accumulator))
		phase_accumulator["build_us"] += max(rustg_time_microseconds(timer_id), 0)

	var/reused_snapshots = length(snapshot_by_network)
	power_shadow_native_last_batch_expected = length(batch_targets)
	if(!power_shadow_native_last_batch_expected)
		return snapshot_by_network

	var/list/stateful_snapshots = power_shadow_native_solve_batch_stateful(batch_targets, batch_dynamic_payload, phase_accumulator, TRUE, FALSE, batch_decode_metadata)

	if(islist(stateful_snapshots))
		for(var/datum/powernet/PN in batch_targets)
			var/list/snapshot = stateful_snapshots[PN]
			if(islist(snapshot))
				snapshot_by_network[PN] = power_shadow_native_make_snapshot_entry(snapshot)

	var/list/fallback_targets = list()
	for(var/datum/powernet/PN in batch_targets)
		if(!islist(snapshot_by_network[PN]))
			fallback_targets += PN

	if(length(fallback_targets) && native_many_supported)
		var/list/fallback_batch_targets = list()
		var/list/fallback_payload = list()
		if(islist(phase_accumulator))
			rustg_time_reset(timer_id)
		for(var/datum/powernet/PN in fallback_targets)
			var/datum/power_solver/solver = PN.ensure_shadow_solver()
			if(!istype(solver))
				continue
			var/list/fallback_item = PN.build_shadow_solver_native_payload_compact(solver)
			if(!islist(fallback_item))
				continue
			fallback_batch_targets += PN
			fallback_payload += list(fallback_item)
		if(islist(phase_accumulator))
			phase_accumulator["build_us"] += max(rustg_time_microseconds(timer_id), 0)

		if(length(fallback_batch_targets))
			if(islist(phase_accumulator))
				rustg_time_reset(timer_id)
			var/payload_json = json_encode(fallback_payload)
			if(islist(phase_accumulator))
				phase_accumulator["encode_us"] += max(rustg_time_microseconds(timer_id), 0)
			if(istext(payload_json) && length(payload_json))
				if(islist(phase_accumulator))
					rustg_time_reset(timer_id)
				var/raw = rustg_power_shadow_solve_many(payload_json)
				if(islist(phase_accumulator))
					phase_accumulator["call_us"] += max(rustg_time_microseconds(timer_id), 0)
				if(istext(raw) && length(raw))
					if(islist(phase_accumulator))
						rustg_time_reset(timer_id)
					var/list/decoded = json_decode(raw)
					if(islist(decoded) && islist(decoded["results"]))
						decoded = decoded["results"]
					if(islist(decoded))
						native_many_failure_streak = 0
						var/index = 1
						for(var/datum/powernet/PN in fallback_batch_targets)
							if(index > length(decoded))
								break
							var/list/decode_metadata = islist(batch_decode_metadata) ? batch_decode_metadata[PN] : null
							var/numapc = islist(decode_metadata) ? decode_metadata["numapc"] : PN.get_apc_terminal_count()
							var/use_minimal_decode = islist(decode_metadata) ? decode_metadata["use_minimal_decode"] : (PN.shadow_solver_write_mode == "fea_only")
							var/decode_write_fields = islist(decode_metadata) ? decode_metadata["decode_write_fields"] : PN.should_decode_shadow_solver_native_write_fields(numapc)
							var/list/snapshot = PN.decode_shadow_solver_native_snapshot(decoded[index], use_minimal_decode, decode_write_fields)
							if(islist(snapshot))
								snapshot_by_network[PN] = power_shadow_native_make_snapshot_entry(snapshot)
							index++
					else
						native_many_failure_streak++
						if(findtext(raw, "power_shadow_solve_many") || findtext(raw, "not found"))
							native_many_supported = FALSE
							log_debug("Power shadow native batch disabled: rust-g power_shadow_solve_many is unavailable.")
						else if(native_many_failure_streak >= 5)
							native_many_supported = FALSE
							log_debug("Power shadow native batch disabled after repeated decode failures.")
					if(islist(phase_accumulator))
						phase_accumulator["decode_us"] += max(rustg_time_microseconds(timer_id), 0)
				else
					native_many_failure_streak++
					if(native_many_failure_streak >= 5)
						native_many_supported = FALSE
						log_debug("Power shadow native batch disabled after repeated failures.")

	var/native_solved = max(length(snapshot_by_network) - reused_snapshots, 0)
	if(islist(phase_accumulator) && native_solved)
		record_power_shadow_native_batch_perf(phase_accumulator["build_us"], phase_accumulator["encode_us"], phase_accumulator["call_us"], phase_accumulator["decode_us"], native_solved)
	if(length(snapshot_by_network) || !power_shadow_native_last_batch_expected)
		return snapshot_by_network
	return null


/datum/controller/subsystem/powernets/proc/power_shadow_native_get_runtime_batch_entry(datum/powernet/PN, list/batch_snapshots, force_dm_fallback = FALSE)
	var/list/result = list(
		"snapshot" = null,
		"reuse_mode" = null,
		"allow_native_fallback" = !power_shadow_batch_only_runtime
	)
	if(force_dm_fallback || !istype(PN) || !islist(batch_snapshots))
		return result

	var/list/entry = batch_snapshots[PN]
	if(!islist(entry))
		return result

	var/list/snapshot = entry["snapshot"]
	if(!islist(snapshot))
		snapshot = entry
	if(!islist(snapshot))
		return result

	result["snapshot"] = snapshot
	result["reuse_mode"] = entry["reuse_mode"]
	result["allow_native_fallback"] = FALSE
	return result


/datum/controller/subsystem/powernets/proc/power_shadow_native_autogate_probe(list/powernets_snapshot)
	if(!power_shadow_native_autogate_enabled)
		return
	if(!islist(powernets_snapshot) || !length(powernets_snapshot))
		return
	if(power_shadow_native_autogate_is_suspended())
		return
	if(world.time < power_shadow_native_autogate_next_probe_tick)
		return

	power_shadow_native_autogate_next_probe_tick = world.time + max(power_shadow_native_autogate_probe_interval, 1)
	var/list/sample_targets = list()
	for(var/datum/powernet/PN in powernets_snapshot)
		if(!PN || QDELETED(PN))
			continue
		if(!PN.shadow_solver_enabled || !PN.shadow_solver_native_enabled)
			continue
		sample_targets += PN
		if(length(sample_targets) >= 16)
			break
	if(!length(sample_targets))
		return

	var/timer_dm = "power_shadow_autogate_dm_[world.time]"
	rustg_time_reset(timer_dm)
	var/dm_samples = 0
	for(var/datum/powernet/PN in sample_targets)
		var/datum/power_solver/solver = PN.ensure_shadow_solver()
		if(!istype(solver))
			continue
		var/list/dm_snapshot = PN.get_shadow_solver_snapshot(solver, FALSE, FALSE)
		if(islist(dm_snapshot))
			dm_samples++
	var/dm_total_us = max(rustg_time_microseconds(timer_dm), 0)
	if(!dm_samples || dm_total_us <= 0)
		return
	var/dm_us = dm_total_us / dm_samples

	var/timer_batch = "power_shadow_autogate_batch_[world.time]"
	rustg_time_reset(timer_batch)
	var/list/batch_snapshot = power_shadow_native_solve_batch(sample_targets, FALSE)
	var/batch_total_us = max(rustg_time_microseconds(timer_batch), 0)
	var/batch_samples = islist(batch_snapshot) ? length(batch_snapshot) : 0
	if(!batch_samples || batch_total_us <= 0)
		return
	var/batch_us = batch_total_us / batch_samples

	power_shadow_native_autogate_last_probe_dm_us = dm_us
	power_shadow_native_autogate_last_probe_batch_us = batch_us
	if(batch_us > dm_us)
		power_shadow_native_autogate_loss_streak++
	else
		power_shadow_native_autogate_loss_streak = 0

	if(power_shadow_native_autogate_loss_streak < max(power_shadow_native_autogate_trip_threshold, 1))
		return

	power_shadow_native_autogate_loss_streak = 0
	power_shadow_native_autogate_suspended_until = world.time + max(power_shadow_native_autogate_cooldown_ticks, 1)
	log_debug("Power shadow native autogate tripped: suspended native batch for [power_shadow_native_autogate_cooldown_ticks] ticks (probe dm_avg=[round(dm_us, 0.1)]us/sample, batch_avg=[round(batch_us, 0.1)]us/sample, sample_count=[dm_samples]).")


/datum/controller/subsystem/powernets/proc/process_powernets(resumed, no_mc_tick)
	var/static/powernets_index = 0
	var/static/list/powernets_snapshot = list()
	var/static/list/power_shadow_batch_snapshots
	var/static/power_shadow_force_dm_fallback = FALSE
	if (!resumed)
		if(!length(powernets))
			powernet_last_snapshot_size = 0
			powernet_last_processed = 0
			powernet_last_skipped_null = 0
			powernet_last_removed_qdeleted = 0
			power_shadow_native_last_batch_expected = 0
			powernets_index = 0
			powernets_snapshot.Cut()
			if(islist(power_shadow_batch_snapshots))
				power_shadow_batch_snapshots.Cut()
			power_shadow_batch_snapshots = null
			power_shadow_force_dm_fallback = FALSE
			if(world.time >= power_shadow_native_autogate_suspended_until && power_shadow_native_autogate_suspended_until)
				power_shadow_native_autogate_suspended_until = 0
				log_debug("Power shadow native autogate re-armed.")
			return
		powernets_snapshot.Cut()
		power_shadow_batch_snapshots = null
		power_shadow_force_dm_fallback = FALSE
		powernet_last_snapshot_size = 0
		powernet_last_processed = 0
		powernet_last_skipped_null = 0
		powernet_last_removed_qdeleted = 0
		power_shadow_native_last_batch_expected = 0
		var/native_capable = 0
		for(var/datum/powernet/network as anything in powernets)
			if(!network)
				continue
			powernets_snapshot += network
			if(!network.shadow_solver_enabled || !network.shadow_solver_native_enabled)
				continue
			// Pre-classify tier; coarse networks are excluded from native batch
			network.select_shadow_solver_tier()
			if(network.shadow_solver_tier == "coarse")
				continue
			native_capable++
		powernet_last_snapshot_size = length(powernets_snapshot)
		if(native_capable)
			if(power_shadow_native_autogate_is_suspended())
				power_shadow_force_dm_fallback = TRUE
			else
				power_shadow_native_autogate_probe(powernets_snapshot)
				power_shadow_batch_snapshots = power_shadow_native_solve_batch(powernets_snapshot)
				if(isnull(power_shadow_batch_snapshots))
					power_shadow_force_dm_fallback = TRUE
		else
			power_shadow_batch_snapshots = null
		if(world.time >= power_shadow_native_autogate_suspended_until && power_shadow_native_autogate_suspended_until)
			power_shadow_native_autogate_suspended_until = 0
			log_debug("Power shadow native autogate re-armed.")
		powernets_index = length(powernets_snapshot)
	var/powernets_snapshot_len = length(powernets_snapshot)
	var/datum/powernet/network
	for (var/i = powernets_index to 1 step -1)
		if(i > powernets_snapshot_len)
			powernets_snapshot_len = length(powernets_snapshot)
			if(i > powernets_snapshot_len)
				continue
		network = powernets_snapshot[i]
		if(!network)
			powernet_last_skipped_null++
			continue
		if (QDELETED(network))
			if (network)
				network.is_processing = null
			powernets -= network
			powernet_last_removed_qdeleted++
			continue
		var/list/runtime_batch_entry = power_shadow_native_get_runtime_batch_entry(network, power_shadow_batch_snapshots, power_shadow_force_dm_fallback)
		var/list/precomputed_shadow_snapshot = runtime_batch_entry["snapshot"]
		var/precomputed_shadow_snapshot_reuse_mode = runtime_batch_entry["reuse_mode"]
		var/allow_single_native_fallback = runtime_batch_entry["allow_native_fallback"]
		network.reset(wait, precomputed_shadow_snapshot, (!power_shadow_force_dm_fallback && allow_single_native_fallback), precomputed_shadow_snapshot_reuse_mode)
		powernet_last_processed++
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			powernets_index = i - 1
			return
	powernets_index = 0
	powernets_snapshot.Cut()
	if(islist(power_shadow_batch_snapshots))
		power_shadow_batch_snapshots.Cut()
	power_shadow_batch_snapshots = null
	power_shadow_force_dm_fallback = FALSE
	if((powernet_last_skipped_null || powernet_last_removed_qdeleted) && world.time >= powernet_next_anomaly_log_time)
		log_debug("SSpowernets powernet loop anomalies: snapshot=[powernet_last_snapshot_size], processed=[powernet_last_processed], null_skips=[powernet_last_skipped_null], qdeleted_removed=[powernet_last_removed_qdeleted]")
		powernet_next_anomaly_log_time = world.time + 600


/datum/controller/subsystem/powernets/proc/process_power_objects(resumed, no_mc_tick)
	var/static/power_objects_index = 0
	var/power_objects_len = length(power_objects)
	if (!resumed)
		power_objects_index = power_objects_len
	if(!power_objects_index)
		return
	var/obj/item/item
	for (var/i = power_objects_index to 1 step -1)
		if(i > power_objects_len)
			power_objects_len = length(power_objects)
			if(i > power_objects_len)
				continue
		item = power_objects[i]
		if(!item)
			continue
		if (QDELETED(item))
			if (item)
				item.is_processing = null
			power_objects -= item
			power_objects_len = max(power_objects_len - 1, 0)
			continue
		if (!item.pwr_drain(wait))
			item.is_processing = null
			power_objects -= item
			power_objects_len = max(power_objects_len - 1, 0)
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			power_objects_index = i - 1
			return
	power_objects_index = 0
/datum/controller/subsystem/powernets/proc/power_shadow_collect_anomalies(delta_threshold, unserved_threshold, list/target_powernets = null)
	var/list/powernets_to_check = islist(target_powernets) ? target_powernets : powernets
	var/list/problem_refs = list()
	var/list/problem_nets = list()
	var/problem_count = 0
	var/networks = 0

	for(var/datum/powernet/PN in powernets_to_check)
		networks++
		var/abs_delta = abs(PN.shadow_solver_avail_delta) + abs(PN.shadow_solver_load_delta)
		var/is_problem = FALSE
		if(PN.shadow_solver_mismatch)
			is_problem = TRUE
		if(abs_delta >= delta_threshold)
			is_problem = TRUE
		if(PN.is_shadow_solver_unserved_persistent(unserved_threshold))
			is_problem = TRUE
		if(!PN.evaluate_shadow_solver_acceptance() && PN.shadow_solver_acceptance_last_reason != "insufficient_samples")
			is_problem = TRUE

		if(!is_problem)
			continue

		problem_count++
		problem_nets += PN
		if(length(problem_refs) < 10)
			problem_refs += "\ref[PN]"

	return list(
		"networks" = networks,
		"problem_count" = problem_count,
		"problem_refs" = problem_refs,
		"problem_nets" = problem_nets
	)


/datum/controller/subsystem/powernets/proc/power_shadow_apply_auto_repair(delta_threshold, unserved_threshold, do_rebuild = FALSE, list/target_powernets = null)
	var/list/collected = power_shadow_collect_anomalies(delta_threshold, unserved_threshold, target_powernets)
	var/list/problem_nets = collected["problem_nets"]
	var/list/problem_refs = collected["problem_refs"]
	var/problem_count = collected["problem_count"]
	var/networks = collected["networks"]

	var/retuned = 0
	var/backend_switched = 0
	for(var/datum/powernet/PN in problem_nets)
		var/abs_delta = abs(PN.shadow_solver_avail_delta) + abs(PN.shadow_solver_load_delta)
		var/scale_base = max(max(PN.avail, PN.shadow_solver_last_avail), max(PN.load, PN.shadow_solver_last_load))
		scale_base = max(scale_base, 10000)
		var/adaptive_threshold = max(PN.shadow_solver_mismatch_threshold, round(scale_base * 0.2), 5000)

		PN.shadow_solver_mismatch_threshold = adaptive_threshold
		PN.shadow_solver_guard_mismatch_threshold_override = adaptive_threshold
		PN.shadow_solver_acceptance_max_avg_load_delta = max(PN.shadow_solver_acceptance_max_avg_load_delta, round(adaptive_threshold * 1.5))
		PN.shadow_solver_acceptance_max_avg_avail_delta = max(PN.shadow_solver_acceptance_max_avg_avail_delta, round(adaptive_threshold * 1.5))
		PN.shadow_solver_acceptance_max_avg_unserved = max(PN.shadow_solver_acceptance_max_avg_unserved, round(adaptive_threshold * 0.8))

		if(abs_delta > adaptive_threshold * 2 && PN.shadow_solver_last_unserved > unserved_threshold)
			var/datum/power_solver/adaptive_shadow/solver = PN.ensure_shadow_solver()
			if(istype(solver) && !solver.conservative_mode)
				solver.conservative_mode = TRUE
				backend_switched++
		PN.shadow_solver_tier_locked = FALSE

		PN.reset_shadow_solver_guard_state()
		PN.reset_shadow_solver_stats()
		if(hascall(PN, "mark_shadow_solver_topology_dirty"))
			call(PN, "mark_shadow_solver_topology_dirty")()
		retuned++

	var/rebuilt = 0
	var/rebuild_applied = FALSE
	if(do_rebuild && !islist(target_powernets))
		makepowernets()
		rebuild_applied = TRUE
		for(var/datum/powernet/NewPN in powernets)
			NewPN.reset_shadow_solver_stats()
			if(hascall(NewPN, "mark_shadow_solver_topology_dirty"))
				call(NewPN, "mark_shadow_solver_topology_dirty")()
			rebuilt++

	return list(
		"networks" = networks,
		"problem_count" = problem_count,
		"problem_refs" = problem_refs,
		"retuned" = retuned,
		"backend_switched" = backend_switched,
		"rebuilt" = rebuilt,
		"rebuild_applied" = rebuild_applied
	)

#undef SSPOWERNETS_POWERNETS
#undef SSPOWERNETS_POWER_OBJECTS
