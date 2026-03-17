/datum/hallucination_actor
	var/mob/living/carbon/holder
	var/image/visual
	var/turf/current_turf
	var/turf/target_turf
	var/icon
	var/icon_state
	var/actor_name = "hallucination"
	var/visual_layer = FLOAT_LAYER
	var/lifetime = 4 SECONDS
	var/step_delay = 0.5 SECONDS
	var/max_steps = 3
	var/steps_taken = 0
	var/vanish_when_seen = FALSE
	var/start_time = 0
	var/stopped = FALSE
	var/datum/hallucination_actor_behavior/behavior

/datum/hallucination_actor/Destroy()
	stop()
	QDEL_NULL(behavior)
	visual = null
	current_turf = null
	target_turf = null
	holder = null
	. = ..()

/datum/hallucination_actor/proc/create_visual()
	if(visual || !icon || !current_turf)
		return
	visual = image(icon, current_turf, icon_state, visual_layer)
	visual.loc = current_turf

/datum/hallucination_actor/proc/show_visual()
	if(holder?.client && visual)
		holder.client.images += visual

/datum/hallucination_actor/proc/hide_visual()
	if(holder?.client && visual)
		holder.client.images -= visual

/datum/hallucination_actor/proc/start()
	if(!holder?.client || !behavior)
		return FALSE
	behavior.setup(src)
	if(!current_turf)
		return FALSE
	create_visual()
	if(!visual)
		return FALSE
	start_time = world.time
	holder.register_hallucination_actor(src)
	show_visual()
	schedule_next_tick()
	return TRUE

/datum/hallucination_actor/proc/stop()
	if(stopped)
		return
	stopped = TRUE
	hide_visual()
	holder?.unregister_hallucination_actor(src)

/datum/hallucination_actor/proc/schedule_next_tick()
	if(stopped)
		return
	spawn(step_delay)
		process()

/datum/hallucination_actor/proc/process()
	if(stopped)
		return
	if(!holder?.client || !visual || !behavior)
		stop()
		return
	if(world.time >= start_time + lifetime || steps_taken >= max_steps || behavior.should_end(src))
		stop()
		return
	behavior.tick(src)
	if(!stopped)
		schedule_next_tick()

/datum/hallucination_actor/proc/move_to(turf/T)
	if(!istype(T) || T.density)
		return FALSE
	current_turf = T
	if(visual)
		visual.loc = T
	return TRUE

/datum/hallucination_actor/proc/is_holder_looking_at_me()
	if(!holder || !current_turf)
		return FALSE
	var/look_dir = holder.dir || NORTH
	var/target_dir = get_dir(holder, current_turf)
	return target_dir == look_dir || target_dir == turn(look_dir, 45) || target_dir == turn(look_dir, -45)

/datum/hallucination_actor/proc/get_candidate_turfs(min_distance = 2, max_distance = 6, require_floor = FALSE, prefer_edge = FALSE, list/preferred_dirs = null)
	var/list/candidates = list()
	for(var/turf/T in view(holder, max_distance))
		if(T == holder.loc || T.density)
			continue
		if(get_dist(holder, T) < min_distance)
			continue
		if(require_floor && !istype(T, /turf/simulated/floor))
			continue
		if(prefer_edge && get_dist(holder, T) < max(2, max_distance - 1))
			continue
		if(islist(preferred_dirs) && length(preferred_dirs) && !(get_dir(holder, T) in preferred_dirs))
			continue
		candidates += T
	return candidates

/datum/hallucination_actor/proc/choose_candidate_turf(min_distance = 2, max_distance = 6, require_floor = FALSE, prefer_edge = FALSE, list/preferred_dirs = null)
	var/list/candidates = get_candidate_turfs(min_distance, max_distance, require_floor, prefer_edge, preferred_dirs)
	return length(candidates) ? pick(candidates) : null

/datum/hallucination_actor/proc/choose_adjacent_turf(list/preferred_dirs = null)
	var/list/dirs_to_check = list()
	if(islist(preferred_dirs) && length(preferred_dirs))
		dirs_to_check = preferred_dirs.Copy()
		for(var/direction in GLOB.alldirs)
			if(!(direction in dirs_to_check))
				dirs_to_check += direction
	else
		dirs_to_check = shuffle(GLOB.alldirs.Copy())

	for(var/direction in dirs_to_check)
		var/turf/next = get_step(current_turf, direction)
		if(!istype(next) || next.density)
			continue
		return next
	return null

/datum/hallucination_actor_behavior
/datum/hallucination_actor_behavior/proc/setup(datum/hallucination_actor/A)
/datum/hallucination_actor_behavior/proc/tick(datum/hallucination_actor/A)
/datum/hallucination_actor_behavior/proc/should_end(datum/hallucination_actor/A)
	if(A.vanish_when_seen && A.is_holder_looking_at_me())
		return TRUE
	return FALSE

/datum/hallucination_actor_behavior/peek_and_hide/setup(datum/hallucination_actor/A)
	var/base_dir = A.holder?.dir || NORTH
	var/list/preferred_dirs = list(turn(base_dir, 180), turn(base_dir, 135), turn(base_dir, -135))
	A.current_turf = A.choose_candidate_turf(2, 5, TRUE, TRUE, preferred_dirs)
	if(!A.current_turf)
		A.current_turf = A.choose_candidate_turf(2, 5, TRUE, FALSE)
	A.vanish_when_seen = TRUE

/datum/hallucination_actor_behavior/peek_and_hide/tick(datum/hallucination_actor/A)
	if(!A.current_turf || !A.holder)
		A.stop()
		return
	if(A.is_holder_looking_at_me())
		A.stop()
		return
	var/away_dir = get_dir(get_turf(A.holder), A.current_turf)
	var/list/preferred_dirs = list(away_dir, turn(away_dir, 45), turn(away_dir, -45))
	var/turf/next = A.choose_adjacent_turf(preferred_dirs)
	if(!next || !A.move_to(next))
		A.stop()
		return
	A.steps_taken++

/datum/hallucination_actor_behavior/approach_then_vanish/setup(datum/hallucination_actor/A)
	A.current_turf = A.choose_candidate_turf(3, 6, TRUE, TRUE)
	if(!A.current_turf)
		A.current_turf = A.choose_candidate_turf(3, 6, TRUE, FALSE)

/datum/hallucination_actor_behavior/approach_then_vanish/tick(datum/hallucination_actor/A)
	if(!A.current_turf || !A.holder)
		A.stop()
		return
	var/turf/next = get_step_towards(A.current_turf, get_turf(A.holder))
	if(!istype(next) || next.density)
		A.stop()
		return
	if(get_dist(next, A.holder) <= 1)
		A.stop()
		return
	if(!A.move_to(next))
		A.stop()
		return
	A.steps_taken++
