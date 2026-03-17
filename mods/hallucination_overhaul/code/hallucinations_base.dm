/proc/load_hallucination_config(filename, list/fallback)
	var/list/loaded = file2list(filename)
	if(islist(loaded) && length(loaded))
		var/list/sanitized = list()
		for(var/entry in loaded)
			if(istext(entry) && length(entry))
				sanitized += entry
		if(length(sanitized))
			return sanitized
	return islist(fallback) ? fallback.Copy() : list()

var/global/list/hallucinated_phrases = load_hallucination_config("config/hallucination/hallucinated_phrases.txt", list(
	"Give it back!",
	"Don't worry, we'll never be apart.",
	"Wait, who are you?",
	"You are not safe here.",
	"We know who you are. Expect us.",
	"Where is your ID?",
	"You know nobody wants you here, right?"
))
var/global/list/hallucinated_actions = load_hallucination_config("config/hallucination/hallucinated_actions.txt", list(
	"stares at you without blinking.",
	"whispers your name into an unseen headset.",
	"looks past you like something is standing behind you.",
	"points at you and quickly looks away.",
	"mimes a warning you cannot quite hear.",
	"tightens their grip on something that is not there."
))
var/global/list/hallucinated_thoughts = load_hallucination_config("config/hallucination/hallucinated_thoughts.txt", list(
	"Someone is behind you.",
	"This is not where you left your ID.",
	"You are sure you heard your name.",
	"Something is wrong with your blood.",
	"You feel like you are being watched.",
	"One of these doors opened a second ago."
))
var/global/list/hallucination_observed_tells = load_hallucination_config("config/hallucination/hallucinated_tells.txt", list(
	"shivers suddenly.",
	"looks over their shoulder.",
	"mutters under their breath.",
	"blinks rapidly.",
	"stares at nothing for a second.",
	"flinches at something unseen."
))

/mob/living/carbon/var/hallucination_power = 0
/mob/living/carbon/var/hallucination_duration = 0
/mob/living/carbon/var/next_hallucination
/mob/living/carbon/var/list/hallucinations = list()
/mob/living/carbon/var/list/hallucination_actors = list()
/mob/living/carbon/var/list/hallucination_recent_types = list()
/mob/living/carbon/var/list/hallucination_recent_categories = list()
/mob/living/carbon/var/list/hallucination_type_cooldowns = list()
/mob/living/carbon/var/list/hallucination_category_cooldowns = list()
/mob/living/carbon/var/hallucination_active_theme
/mob/living/carbon/var/hallucination_theme_expires = 0
/mob/living/carbon/var/hallucination_theme_hits = 0
/mob/living/carbon/var/list/hallucination_forced_themes = list()
/mob/living/carbon/var/hallucination_last_process_tick = 0

/datum/hallucination_context
	var/power = 0
	var/tier = "none"
	var/darkness = 1
	var/is_maintenance = FALSE
	var/nearby_living = 0
	var/airlock_count = 0
	var/apc_count = 0
	var/alarm_count = 0
	var/firealarm_count = 0
	var/can_hear = FALSE
	var/brute = 0
	var/fire = 0
	var/oxy = 0
	var/tox = 0
	var/hal = 0
	var/total_damage = 0
	var/shock = 0
	var/active_theme
	var/theme_time_left = 0

/datum/hallucination_candidate
	var/type_path
	var/type_name
	var/category
	var/theme_text = "-"
	var/eligible = FALSE
	var/weight = 0
	var/base_weight = 0
	var/reason = "Not evaluated."
	var/picked = FALSE

/proc/get_hallucination_datums()
	var/static/list/hallucination_datums
	if(!hallucination_datums)
		hallucination_datums = list()
		for(var/T in subtypesof(/datum/hallucination))
			var/datum/hallucination/test_hallucination = new T
			if(!test_hallucination.abstract_hallucination)
				hallucination_datums += T
			qdel(test_hallucination)
	return hallucination_datums

/proc/hallucination_seconds_left(target_time)
	return round(max(target_time - world.time, 0) / 10, 0.1)

/proc/hallucination_reason_text(list/reasons)
	if(!islist(reasons) || !length(reasons))
		return "Eligible."
	return reasons.Join(", ")

/mob/living/carbon/hallucinating()
	return hallucination_power > 0 && hallucination_duration > 0

/mob/living/carbon/proc/hallucination(duration, power)
	hallucination_duration = max(hallucination_duration, duration)
	hallucination_power = max(hallucination_power, power)

/mob/living/carbon/proc/adjust_hallucination(duration, power)
	var/resistance = GET_TRAIT_LEVEL(src, /singleton/trait/boon/clear_mind) * 3
	hallucination_duration = max(0, hallucination_duration + duration - resistance)
	hallucination_power = max(0, hallucination_power + power - resistance)

/mob/living/carbon/proc/clear_hallucination_theme()
	hallucination_active_theme = null
	hallucination_theme_expires = 0
	hallucination_theme_hits = 0

/mob/living/carbon/proc/set_forced_hallucination_theme(theme, duration)
	if(!theme || duration <= 0)
		return
	if(!islist(hallucination_forced_themes))
		hallucination_forced_themes = list()
	hallucination_forced_themes[theme] = max(hallucination_forced_themes[theme] || 0, world.time + duration)

/mob/living/carbon/proc/get_forced_hallucination_theme()
	if(!islist(hallucination_forced_themes) || !length(hallucination_forced_themes))
		return null

	var/selected_theme
	var/selected_expiry = 0
	for(var/theme in hallucination_forced_themes)
		var/expiry = hallucination_forced_themes[theme]
		if(expiry > selected_expiry)
			selected_theme = theme
			selected_expiry = expiry
	return selected_theme

/mob/living/carbon/proc/prune_hallucination_runtime_state()
	if(!islist(hallucination_recent_types))
		hallucination_recent_types = list()
	if(!islist(hallucination_recent_categories))
		hallucination_recent_categories = list()
	if(!islist(hallucination_type_cooldowns))
		hallucination_type_cooldowns = list()
	if(!islist(hallucination_category_cooldowns))
		hallucination_category_cooldowns = list()
	if(!islist(hallucination_forced_themes))
		hallucination_forced_themes = list()

	while(length(hallucination_recent_types) > 5)
		hallucination_recent_types.Cut(1, 2)
	while(length(hallucination_recent_categories) > 5)
		hallucination_recent_categories.Cut(1, 2)

	for(var/key in hallucination_type_cooldowns.Copy())
		if(hallucination_type_cooldowns[key] <= world.time)
			hallucination_type_cooldowns -= key
	for(var/key in hallucination_category_cooldowns.Copy())
		if(hallucination_category_cooldowns[key] <= world.time)
			hallucination_category_cooldowns -= key
	for(var/key in hallucination_forced_themes.Copy())
		if(hallucination_forced_themes[key] <= world.time)
			hallucination_forced_themes -= key

	if(hallucination_active_theme && (hallucination_theme_expires <= world.time || hallucination_theme_hits >= 3))
		clear_hallucination_theme()

/mob/living/carbon/proc/clear_hallucination_runtime_state()
	hallucination_recent_types = list()
	hallucination_recent_categories = list()
	hallucination_type_cooldowns = list()
	hallucination_category_cooldowns = list()
	hallucination_forced_themes = list()
	next_hallucination = 0
	if(islist(hallucination_actors))
		for(var/datum/hallucination_actor/actor in hallucination_actors.Copy())
			qdel(actor)
	hallucination_actors = list()
	clear_hallucination_theme()

/mob/living/carbon/proc/register_hallucination_actor(datum/hallucination_actor/actor)
	if(!actor)
		return
	if(!islist(hallucination_actors))
		hallucination_actors = list()
	hallucination_actors += actor

/mob/living/carbon/proc/unregister_hallucination_actor(datum/hallucination_actor/actor)
	if(!actor || !islist(hallucination_actors))
		return
	hallucination_actors -= actor

/mob/living/carbon/proc/get_hallucination_tier()
	if(hallucination_power <= 0)
		return "none"
	if(hallucination_power < 30)
		return "subtle"
	if(hallucination_power < 50)
		return "uneasy"
	if(hallucination_power < 80)
		return "severe"
	return "break"

/mob/living/carbon/proc/get_hallucination_type_cooldown_remaining(hallucination_type)
	if(!islist(hallucination_type_cooldowns) || !hallucination_type_cooldowns[hallucination_type])
		return 0
	return max(hallucination_type_cooldowns[hallucination_type] - world.time, 0)

/mob/living/carbon/proc/get_hallucination_category_cooldown_remaining(category)
	if(!category || !islist(hallucination_category_cooldowns) || !hallucination_category_cooldowns[category])
		return 0
	return max(hallucination_category_cooldowns[category] - world.time, 0)

/mob/living/carbon/proc/build_hallucination_context()
	prune_hallucination_runtime_state()

	var/datum/hallucination_context/context = new
	context.power = hallucination_power
	context.tier = get_hallucination_tier()
	context.can_hear = can_hear()
	context.brute = getBruteLoss()
	context.fire = getFireLoss()
	context.oxy = getOxyLoss()
	context.tox = getToxLoss()
	context.hal = getHalLoss()
	context.total_damage = context.brute + context.fire + context.oxy + context.tox + context.hal
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		context.shock = H.get_shock()
	context.active_theme = get_forced_hallucination_theme() || hallucination_active_theme
	if(context.active_theme && islist(hallucination_forced_themes) && hallucination_forced_themes[context.active_theme])
		context.theme_time_left = max(hallucination_forced_themes[context.active_theme] - world.time, 0)
	else
		context.theme_time_left = max(hallucination_theme_expires - world.time, 0)

	var/turf/my_turf = get_turf(src)
	if(isturf(my_turf))
		// Lower values are darker, matching the requested thresholds.
		context.darkness = clamp(my_turf.get_lumcount(), 0, 1)

	var/area/current_area = get_area(src)
	context.is_maintenance = istype(current_area, /area/maintenance)

	for(var/mob/living/M in view(src, 7))
		if(M == src || M.stat == DEAD)
			continue
		context.nearby_living++

	for(var/obj/machinery/door/airlock/door in view(src, 7))
		context.airlock_count++
	for(var/obj/machinery/power/apc/apc in view(src, 7))
		if(MACHINE_IS_BROKEN(apc) || GET_FLAGS(apc.stat, MACHINE_STAT_MAINT))
			continue
		if(!apc.area || !apc.area.requires_power || apc.opened)
			continue
		context.apc_count++
	for(var/obj/machinery/alarm/alarm in view(src, 7))
		context.alarm_count++
	for(var/obj/machinery/firealarm/firealarm in view(src, 7))
		context.firealarm_count++

	return context

/mob/living/carbon/proc/can_cause_hallucination(hallucination_type, datum/hallucination_context/context = null)
	if(!ispath(hallucination_type, /datum/hallucination))
		return FALSE

	var/datum/hallucination/test_hallucination = new hallucination_type
	var/can_affect = !test_hallucination.get_blocking_reason(src, context)
	qdel(test_hallucination)
	return can_affect

/mob/living/carbon/proc/get_hallucination_candidates(debug = FALSE, datum/hallucination_context/context = null)
	if(!context)
		context = build_hallucination_context()

	var/list/candidates = list()
	for(var/T in get_hallucination_datums())
		var/datum/hallucination/hallucination = new T
		var/datum/hallucination_candidate/candidate = new
		var/list/reasons = list()

		candidate.type_path = T
		candidate.type_name = "[T]"
		candidate.category = hallucination.category || "uncategorized"
		candidate.theme_text = islist(hallucination.theme_tags) && length(hallucination.theme_tags) ? hallucination.theme_tags.Join(", ") : "-"
		candidate.base_weight = hallucination.base_weight

		var/blocking_reason = hallucination.get_blocking_reason(src, context)
		if(blocking_reason)
			reasons += blocking_reason
			candidate.reason = hallucination_reason_text(reasons)
		else
			var/weight = hallucination.get_weight(src, context, reasons)
			candidate.weight = round(weight, 0.01)
			candidate.eligible = weight > 0
			candidate.reason = hallucination_reason_text(reasons)

		if(debug || candidate.eligible)
			candidates += candidate
		else
			qdel(candidate)

		qdel(hallucination)

	return candidates

/mob/living/carbon/proc/pick_contextual_hallucination(datum/hallucination_context/context = null, list/candidates = null)
	if(!context)
		context = build_hallucination_context()
	if(!islist(candidates))
		candidates = get_hallucination_candidates(FALSE, context)

	var/list/weighted_candidates = list()
	for(var/datum/hallucination_candidate/candidate in candidates)
		if(candidate.eligible && candidate.weight > 0)
			weighted_candidates[candidate.type_path] = candidate.weight

	if(!length(weighted_candidates))
		return null
	return pickweight(weighted_candidates)

/mob/living/carbon/proc/register_hallucination_result(hallucination_type, datum/hallucination/hallucination)
	prune_hallucination_runtime_state()

	hallucination_recent_types += hallucination_type
	while(length(hallucination_recent_types) > 5)
		hallucination_recent_types.Cut(1, 2)

	if(hallucination.category)
		hallucination_recent_categories += hallucination.category
		while(length(hallucination_recent_categories) > 5)
			hallucination_recent_categories.Cut(1, 2)
		hallucination_category_cooldowns[hallucination.category] = world.time + hallucination.category_cooldown

	hallucination_type_cooldowns[hallucination_type] = world.time + hallucination.type_cooldown

	if(hallucination_active_theme && (hallucination_theme_expires <= world.time || hallucination_theme_hits >= 3))
		clear_hallucination_theme()

	if(hallucination_active_theme)
		if(islist(hallucination.theme_tags) && (hallucination_active_theme in hallucination.theme_tags))
			hallucination_theme_hits++
			if(hallucination_theme_hits >= 3)
				clear_hallucination_theme()
	else if(islist(hallucination.theme_tags) && length(hallucination.theme_tags) && prob(35))
		hallucination_active_theme = pick(hallucination.theme_tags)
		hallucination_theme_expires = world.time + 45 SECONDS
		hallucination_theme_hits = 1

	maybe_emit_hallucination_tell(hallucination)

/mob/living/carbon/proc/cause_hallucination(hallucination_type, hallucination_source = "hallucination tick", bypass_requirements = FALSE)
	if(!ispath(hallucination_type, /datum/hallucination))
		return FALSE

	var/datum/hallucination/new_hallucination = new hallucination_type
	if(!bypass_requirements && new_hallucination.get_blocking_reason(src))
		qdel(new_hallucination)
		return FALSE

	new_hallucination.holder = src
	if(!new_hallucination.activate())
		qdel(new_hallucination)
		return FALSE

	register_hallucination_result(hallucination_type, new_hallucination)
	investigate_log("was afflicted with a hallucination of type [hallucination_type] by [hallucination_source].[new_hallucination.feedback_details ? " [new_hallucination.feedback_details]" : ""]", "hallucinations")
	return TRUE

/mob/living/carbon/proc/random_non_sec_crewmember_name(min_distance = 8)
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H == src || !H.client || H.stat == DEAD)
			continue
		if(H.z != z || get_dist(H, src) < min_distance)
			continue

		var/datum/job/job = H.mind?.assigned_role ? SSjobs.get_by_title(H.mind.assigned_role) : null
		if(job && (job.department_flag & SEC))
			continue

		candidates += H.real_name

	return length(candidates) ? pick(candidates) : null

/mob/living/carbon/proc/random_station_area_name()
	var/static/list/area_names
	if(!area_names)
		area_names = list()
		for(var/area/A)
			if(!A.name || istype(A, /area/space))
				continue
			area_names += A.name

	var/area/current_area = get_area(src)
	var/list/candidates = area_names.Copy()
	if(current_area?.name)
		candidates -= current_area.name

	return length(candidates) ? pick(candidates) : "the station"

/mob/living/carbon/proc/random_crewmember_name(min_distance = 0)
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H == src || !H.client || H.stat == DEAD)
			continue
		if(H.z != z || get_dist(H, src) < min_distance)
			continue
		candidates += H.real_name
	return length(candidates) ? pick(candidates) : null

/mob/living/carbon/proc/random_hallucination_turf(min_distance = 1, max_distance = 7, require_floor = FALSE)
	var/list/candidates = list()
	for(var/turf/T in view(src, max_distance))
		if(T == loc || get_dist(src, T) < min_distance)
			continue
		if(require_floor && !istype(T, /turf/simulated/floor))
			continue
		candidates += T
	return length(candidates) ? pick(candidates) : get_turf(src)

/mob/living/carbon/proc/random_radio_channel()
	return pick("Common", "Engineering", "Medical", "Security", "Command", "Science", "Supply", "Service", "Hailing")

/mob/living/carbon/proc/random_hallucinated_phrase()
	var/list/phrases = hallucinated_phrases.Copy()
	if(hallucination_power >= 50)
		phrases += list(
			"Do not let them find you.",
			"Do not go into maintenance alone.",
			"Why are they staring at you?",
			"You should have left when you had the chance."
		)
	return length(phrases) ? pick(phrases) : "Something is very wrong."

/mob/living/carbon/proc/random_hallucinated_action()
	var/list/actions = hallucinated_actions.Copy()
	if(hallucination_power >= 45)
		actions += list(
			"rests a hand on a weapon that is not there.",
			"mouths your name in silence.",
			"smiles at you like they know something you do not.",
			"takes a half-step toward you, then freezes."
		)
	return length(actions) ? pick(actions) : "watches you strangely."

/mob/living/carbon/proc/random_hallucinated_thought()
	var/list/thoughts = hallucinated_thoughts.Copy()
	var/datum/hallucination_context/context = build_hallucination_context()
	if(context.darkness < 0.35)
		thoughts += list("Something in the dark just moved.", "There is definitely a silhouette at the edge of the room.")
	if(context.is_maintenance)
		thoughts += list("Maintenance is not empty.", "You should not be here alone.")
	if(context.total_damage > 40 || context.shock >= 30)
		thoughts += list("Your body is failing you.", "Something under your skin is moving the wrong way.")
	if(context.nearby_living <= 1)
		thoughts += list("No one would hear you if you screamed.", "You are alone with it.")
	return length(thoughts) ? pick(thoughts) : "Something feels wrong."

/mob/living/carbon/proc/maybe_emit_hallucination_tell(datum/hallucination/hallucination)
	if(!hallucination || stat || !length(hallucination_observed_tells))
		return
	var/chance = clamp(round(hallucination_power / 6), 6, 20)
	if(hallucination.category == "social" || hallucination.category == "body")
		chance += 4
	if(!prob(chance))
		return
	var/message = pick(hallucination_observed_tells)
	for(var/mob/M in oviewers(world.view, src))
		to_chat(M, SPAN_NOTICE("[src] [message]"))

/mob/living/carbon/proc/handle_hallucinations()
	if(hallucination_last_process_tick == world.time)
		return
	hallucination_last_process_tick = world.time

	hallucination_duration = max(0, hallucination_duration - 1)
	if(chem_effects[CE_MIND] > 0)
		hallucination_duration = max(0, hallucination_duration - 1)

	if(chem_effects[CE_MIND] < 0)
		hallucination_power = min(hallucination_power + 1, 50)
	if(chem_effects[CE_MIND] < -1)
		hallucination_power += 1
	if(chem_effects[CE_MIND] > 0)
		hallucination_power = max(hallucination_power - chem_effects[CE_MIND], 0)

	if(!hallucination_power)
		hallucination_duration = 0
		return
	if(!hallucination_duration)
		hallucination_power = 0
		return

	prune_hallucination_runtime_state()

	if(!client || stat || world.time < next_hallucination)
		return
	if(chem_effects[CE_MIND] > 0 && prob(chem_effects[CE_MIND] * 40))
		return

	var/datum/hallucination_context/context = build_hallucination_context()
	var/list/candidates = get_hallucination_candidates(FALSE, context)
	if(!length(candidates))
		return

	var/hall_delay = rand(10, 20) SECONDS
	if(hallucination_power < 50)
		hall_delay *= 2
	if(context.active_theme)
		hall_delay = max(round(hall_delay * 0.8), 6 SECONDS)
	next_hallucination = world.time + hall_delay

	var/selected = pick_contextual_hallucination(context, candidates)
	if(selected)
		cause_hallucination(selected)

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Hallucination effect datums
//////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/hallucination
	var/mob/living/carbon/holder
	var/allow_duplicates = TRUE
	var/duration = 0
	var/min_power = 0
	var/max_power = INFINITY
	var/feedback_details
	var/category = "ambient"
	var/base_weight = 10
	var/type_cooldown = 25 SECONDS
	var/category_cooldown = 8 SECONDS
	var/list/theme_tags
	var/abstract_hallucination = FALSE

/datum/hallucination/proc/start()

/datum/hallucination/proc/end()

/datum/hallucination/proc/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	return null

/datum/hallucination/proc/get_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C?.client)
		return "no client"
	if(C.stat >= UNCONSCIOUS)
		return "stat"
	if(min_power > C.hallucination_power || max_power < C.hallucination_power)
		return "power range"
	if(!allow_duplicates && (locate(type) in C.hallucinations))
		return "duplicate"
	return extra_blocking_reason(C, context)

/datum/hallucination/proc/can_affect(mob/living/carbon/C, datum/hallucination_context/context = null)
	return !get_blocking_reason(C, context)

/datum/hallucination/proc/get_tier_multiplier(datum/hallucination_context/context)
	switch(context?.tier)
		if("subtle")
			switch(category)
				if("ambient") return 1.5
				if("machinery") return 1.3
				if("social") return 1.2
				if("evidence") return 1.2
				if("body") return 1.0
				if("threat") return 0.25
				if("announcement") return 0
		if("uneasy")
			switch(category)
				if("ambient") return 1.1
				if("machinery") return 1.3
				if("social") return 1.1
				if("evidence") return 1.2
				if("body") return 1.2
				if("threat") return 0.7
				if("announcement") return 0.15
		if("severe")
			switch(category)
				if("ambient") return 0.9
				if("machinery") return 1.1
				if("social") return 1.0
				if("evidence") return 1.0
				if("body") return 1.3
				if("threat") return 1.4
				if("announcement") return 0.45
		if("break")
			switch(category)
				if("ambient") return 0.8
				if("machinery") return 1.0
				if("social") return 0.9
				if("evidence") return 0.9
				if("body") return 1.4
				if("threat") return 1.7
				if("announcement") return 0.75
	return 1

/datum/hallucination/proc/get_context_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	var/multiplier = 1

	if(context.darkness < 0.15)
		if(category == "threat" || category == "evidence")
			multiplier *= 1.75
			debug_factors += "very dark x1.75"
		if(category == "social" || category == "announcement")
			multiplier *= 0.8
			debug_factors += "very dark x0.8"
	else if(context.darkness < 0.35 && (category == "threat" || category == "evidence"))
		multiplier *= 1.3
		debug_factors += "dim x1.3"

	if(context.is_maintenance)
		if(category == "machinery")
			multiplier *= 1.6
			debug_factors += "maintenance x1.6"
		if(category == "threat")
			multiplier *= 1.4
			debug_factors += "maintenance x1.4"

	if(context.nearby_living <= 1)
		if(category == "social")
			multiplier *= 0.55
			debug_factors += "alone x0.55"
		if(category == "threat")
			multiplier *= 1.25
			debug_factors += "alone x1.25"
	else if(context.nearby_living >= 2)
		if(category == "social")
			multiplier *= 1.5
			debug_factors += "crowd x1.5"
		if(category == "threat")
			multiplier *= 0.8
			debug_factors += "crowd x0.8"

	if(context.total_damage > 40 || context.shock >= 30)
		if(category == "body")
			multiplier *= 1.7
			debug_factors += "stress x1.7"
		if(category == "evidence")
			multiplier *= 1.4
			debug_factors += "stress x1.4"
		if(category == "threat")
			multiplier *= 1.2
			debug_factors += "stress x1.2"

	if((context.total_damage > 80 || context.shock >= 60) && category == "announcement")
		multiplier *= 1.2
		debug_factors += "critical stress x1.2"

	return multiplier

/datum/hallucination/proc/get_history_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	var/multiplier = 1
	var/list/recent_types = C.hallucination_recent_types
	if(islist(recent_types) && length(recent_types))
		var/last_type = recent_types[length(recent_types)]
		if(last_type == type)
			debug_factors += "same as last successful"
			return 0
		if(type in recent_types)
			multiplier *= 0.25
			debug_factors += "suppressed by recent history x0.25"

	var/list/recent_categories = C.hallucination_recent_categories
	if(category && islist(recent_categories) && length(recent_categories))
		var/start_index = max(1, length(recent_categories) - 1)
		for(var/i = start_index to length(recent_categories))
			if(recent_categories[i] == category)
				multiplier *= 0.6
				debug_factors += "recent category x0.6"
				break

	return multiplier

/datum/hallucination/proc/get_theme_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	if(!context?.active_theme)
		return 1
	if(islist(theme_tags) && (context.active_theme in theme_tags))
		debug_factors += "theme [context.active_theme] x2.25"
		return 2.25
	debug_factors += "theme mismatch x0.6"
	return 0.6

/datum/hallucination/proc/get_weight(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	if(get_blocking_reason(C, context))
		return 0

	var/type_cooldown_remaining = C.get_hallucination_type_cooldown_remaining(type)
	if(type_cooldown_remaining > 0)
		debug_factors += "type cooldown [hallucination_seconds_left(world.time + type_cooldown_remaining)]s"
		return 0

	var/category_cooldown_remaining = C.get_hallucination_category_cooldown_remaining(category)
	if(category && category_cooldown_remaining > 0)
		debug_factors += "category cooldown [hallucination_seconds_left(world.time + category_cooldown_remaining)]s"
		return 0

	var/weight = max(base_weight, 0)
	if(weight <= 0)
		debug_factors += "no base weight"
		return 0

	var/tier_multiplier = get_tier_multiplier(context)
	if(tier_multiplier <= 0)
		debug_factors += "tier suppresses [category]"
		return 0
	if(tier_multiplier != 1)
		debug_factors += "tier [context.tier] x[tier_multiplier]"
	weight *= tier_multiplier

	var/context_multiplier = get_context_multiplier(C, context, debug_factors)
	if(context_multiplier <= 0)
		return 0
	weight *= context_multiplier

	var/history_multiplier = get_history_multiplier(C, context, debug_factors)
	if(history_multiplier <= 0)
		return 0
	weight *= history_multiplier

	var/theme_multiplier = get_theme_multiplier(C, context, debug_factors)
	if(theme_multiplier <= 0)
		return 0
	weight *= theme_multiplier

	return weight

/datum/hallucination/Destroy()
	. = ..()
	holder = null

/datum/hallucination/proc/activate()
	if(!holder || !holder.client)
		return FALSE
	holder.hallucinations += src
	var/start_result = start()
	if(start_result == FALSE)
		holder?.hallucinations -= src
		return FALSE
	if(QDELETED(src))
		holder?.hallucinations -= src
		return FALSE
	spawn(duration)
		if(holder)
			end()
			holder.hallucinations -= src
		qdel(src)
	return TRUE
