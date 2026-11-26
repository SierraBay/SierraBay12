SUBSYSTEM_DEF(ai)
	name = "AI"
	init_order = SS_INIT_AI
	priority = SS_PRIORITY_AI
	wait = 2 SECONDS
#ifdef UNIT_TEST
	flags = SS_NO_INIT | SS_NO_FIRE
#else
	flags = SS_NO_INIT
#endif

	/// The set of all ai_holders currently being updated
	var/static/list/datum/ai_holder/ai_holders = list()

	/// The current queue of ai_holder instances to update
	var/static/list/datum/ai_holder/queue = list()

	/// If the queue was not finished, the index to read from on the next run
	var/static/saved_index

	// [SIERRA-ADD] - Tracked non-hearer / special AI targets (turrets, exosuits, blobs)
	var/static/list/atom/special_targets = list()
	// [/SIERRA-ADD]


/datum/controller/subsystem/ai/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"\
		Active AI: [length(ai_holders)] \
		Run Empty Levels: [config.run_empty_levels ? "Y" : "N"]\
	"})


/datum/controller/subsystem/ai/fire(resumed, no_mc_tick)
	if (!resumed)
		queue = ai_holders.Copy()
		saved_index = 1
	var/queue_length = length(queue)
	if (!queue_length)
		return
	// [SIERRA-EDIT] - Cache presence config flag and fast-path turf z lookup
	var/check_presence = !config.run_empty_levels
	var/datum/ai_holder/ai
	for (var/i = saved_index to queue_length)
		ai = queue[i]
		if (QDELETED(ai) || ai.busy || !ai.holder)
			continue
		if (check_presence)
			var/az = ai.holder.z || get_z(ai.holder)
			if (!SSpresence.population(az))
				continue
		// [/SIERRA-EDIT]
		ai.handle_strategicals()
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			saved_index = i + 1
			return
	queue.Cut()
