// ===========================
//   RACE CONTROLLER MACHINE
// ===========================

/// Global reference — lets the betting terminal find the active race
var/global/obj/machinery/race_controller/carp_race_controller = null


// ---- Area ----

/area/carp_racing
	name        = "Carp Races"
	icon_state  = "yellow"
	requires_power  = 0
	dynamic_lighting = 0
// ---- Camera preset ----

/// Static camera placed by mappers to cover a specific spot in the arena.
/obj/machinery/camera/network/carp_race
	network = list(NETWORK_THUNDER)
	c_tag   = "Carp Races"

/// Auto-spawned tracking camera — spawns at race start and follows the lead carp.
/// Not placed in the map editor; the race controller creates it at runtime.
/obj/machinery/camera/network/carp_race/tracking
	c_tag        = "Carp Races - Live Broadcast"
	invisibility = INVISIBILITY_ABSTRACT  // not visible to players in world
	density      = FALSE
	anchored     = FALSE  // required so forceMove works without errors
	simulated    = FALSE

/obj/machinery/camera/network/carp_race/tracking/Initialize(mapload)
	. = ..()  // registers camera with cameranet and moved_event


// ---- Map landmarks (place these in the map editor) ----

/// Place this at the finish line of the race track
/obj/landmark/carp_race_finish
	name = RACE_FINISH_TAG

/// Place one at each of the 6 carp start positions.
/// Name format: "carp_race_start_N" where N is 1–6.
/obj/landmark/carp_race_start
	name = "carp_race_start"
	var/slot = 0

/obj/landmark/carp_race_start/Initialize(mapload)
	. = ..()
	// Parse slot from name suffix e.g. "carp_race_start_3" -> slot 3
	// Mappers may also set slot directly in the map editor
	if(!slot)
		var/suffix = copytext(name, length("carp_race_start_") + 1)
		slot = text2num(suffix)


// ---- Race Controller Machine ----

/**
 * The race controller manages the full race lifecycle automatically.
 *
 * Setup (in the map editor):
 *   1. Place /obj/machinery/race_controller somewhere in the race area.
 *   2. Place /obj/landmark/carp_race_finish at the finish line.
 *   3. Place /obj/landmark/carp_race_start_1 … _6 at the 6 start positions.
 *   4. Place /obj/machinery/camera/network/carp_race in the arena.
 *   5. Place /obj/machinery/betting_terminal near the audience area.
 *
 * Race cycle (automatic):
 *   Idle (10 s) → Betting (60 s) → Countdown (15 s) → Racing → Finished (30 s) → repeat
 *
 * Admins can click the controller to manually override any phase.
 */
/obj/machinery/race_controller
	name        = "Carp Race Controller"
	desc        = "Controls the carp race process. Do not touch without admin permission!"
	icon        = 'icons/obj/machines/terminals.dmi'
	icon_state  = "mechcomp_frame"
	anchored    = TRUE
	idle_power_usage = 10

	/// Active race datum
	var/datum/carp_race/race = null
	/// Start turfs indexed 1–RACE_CARP_COUNT
	var/list/turf/start_turfs = list()
	/// Finish-line turf
	var/turf/finish_turf = null
	/// Countdown announcement flags (reset each betting phase)
	var/announced_3 = FALSE
	var/announced_2 = FALSE
	var/announced_1  = FALSE
	/// Set TRUE once the mid-race (50%) announcement fires
	var/announced_halfpoint = FALSE
	/// Tracking camera that follows the lead carp during the race
	var/obj/machinery/camera/network/carp_race/tracking/tracking_cam = null
	/// Fixed Y coordinate for the tracking camera (centre of the race lane). Set once at landmark discovery.
	var/cam_center_y = 0


/obj/machinery/race_controller/Initialize(mapload)
	. = ..()
	carp_race_controller = src
	race = new /datum/carp_race(src)
	// Schedule first betting phase after startup delay
	addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/race_controller, find_landmarks_and_begin)), 10 SECONDS)


/obj/machinery/race_controller/Destroy()
	if(carp_race_controller == src)
		carp_race_controller = null
	QDEL_NULL(race)
	. = ..()


// ---- Landmark discovery ----

/// Scans landmarks_list for race start/finish landmarks (lazy-loaded for safety)
/obj/machinery/race_controller/proc/find_landmarks()
	if(!finish_turf)
		for(var/obj/landmark/carp_race_finish/L in landmarks_list)
			finish_turf = get_turf(L)
			break

	// Pre-size to RACE_CARP_COUNT so positional LAZYSET writes (L.slot = 1–6) are always in-bounds
	if(!LAZYLEN(start_turfs))
		start_turfs = list()
		for(var/i = 1 to RACE_CARP_COUNT)
			start_turfs += null
	for(var/obj/landmark/carp_race_start/L in landmarks_list)
		if(L.slot >= 1 && L.slot <= RACE_CARP_COUNT)
			LAZYSET(start_turfs, L.slot, get_turf(L))

/// Called once after startup to find landmarks then begin the first race
/obj/machinery/race_controller/proc/find_landmarks_and_begin()
	find_landmarks()
	if(!finish_turf)
		log_debug("[type] at ([x],[y],[z]): no [RACE_FINISH_TAG] landmark found — races disabled.")
		return
	if(!length(start_turfs))
		log_debug("[type] at ([x],[y],[z]): no carp_race_start_N landmarks found — races disabled.")
		return
	// Compute center Y once — average of all start turfs
	if(!cam_center_y)
		var/sum_y = 0
		var/count_y = 0
		var/turf/fallback = get_turf(src)
		for(var/turf/T in start_turfs)
			if(T)
				sum_y += T.y
				count_y++
		if(count_y > 0)
			cam_center_y = round(sum_y / count_y)
		else
			cam_center_y = fallback.y
	// Spawn the tracking camera at the start line midpoint
	if(!tracking_cam || QDELETED(tracking_cam))
		// Walk the list instead of hardcoding [1] to avoid OOB if slot 1 is absent
		var/turf/spawn_turf = get_turf(src)
		for(var/turf/T in start_turfs)
			if(T)
				spawn_turf = T
				break
		var/turf/cam_spawn = locate(spawn_turf.x, cam_center_y, spawn_turf.z) || spawn_turf
		tracking_cam = new /obj/machinery/camera/network/carp_race/tracking(cam_spawn)
	begin_betting_phase()


// ---- Race lifecycle management ----

/// Start the betting phase
/obj/machinery/race_controller/proc/begin_betting_phase()
	find_landmarks()  // Re-check in case landmarks were placed late
	if(!finish_turf || !length(start_turfs))
		return
	announced_3 = FALSE
	announced_2 = FALSE
	announced_1  = FALSE
	announced_halfpoint = FALSE
	// Return tracking camera to start line center so viewers see carps lining up
	if(tracking_cam && !QDELETED(tracking_cam) && cam_center_y)
		for(var/turf/T in start_turfs)
			if(T)
				var/turf/start_view = locate(T.x, cam_center_y, T.z)
				if(start_view)
					tracking_cam.forceMove(start_view)
				break
	race.start_betting(start_turfs, finish_turf)

/// Transition from betting to countdown
/obj/machinery/race_controller/proc/start_countdown_phase()
	race.start_countdown()

/**
 * Force-end a race that has run beyond RACE_MAX_DURATION.
 * Unfinished carps are ranked by current X position (further east = better placement)
 * and appended to finish_order before the result announcement fires.
 */
/obj/machinery/race_controller/proc/force_end_race()
	if(race.state != RACE_STATE_RACING)
		return

	// Gather all carps that haven't crossed the line yet
	var/list/remaining = list()
	for(var/mob/living/simple_animal/hostile/carp/racing/C in race.racers)
		if(!QDELETED(C) && !C.finished)
			remaining += C

	if(!length(remaining))
		// All carps already finished; push the race to FINISHED if somehow stuck
		race.state          = RACE_STATE_FINISHED
		race.phase_end_time = world.time + RACE_RESET_DELAY
		race.announce_and_payout()
		return

	// Sort remaining carps by X descending (bubble sort; at most RACE_CARP_COUNT entries)
	for(var/i = 1 to length(remaining))
		for(var/j = 1 to length(remaining) - i)
			var/mob/living/simple_animal/hostile/carp/racing/A = remaining[j]
			var/mob/living/simple_animal/hostile/carp/racing/B = remaining[j + 1]
			if(A.x < B.x)
				remaining.Swap(j, j + 1)

	// Append them to finish_order in positional rank (leading carp = best placement)
	for(var/mob/living/simple_animal/hostile/carp/racing/C in remaining)
		C.finished        = TRUE
		race.finish_order += C
		if(!race.winner)
			race.winner = C  // First in sorted list is the de-facto winner

	race.state          = RACE_STATE_FINISHED
	race.phase_end_time = world.time + RACE_RESET_DELAY
	race.radio_announce("Race time limit reached! Standings determined by final position.")
	race.announce_and_payout()

/// Reset race datum and schedule next betting phase
/obj/machinery/race_controller/proc/reset_race()
	race.reset_to_idle()
	// Brief pause before next race
	addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/race_controller, begin_betting_phase)), 10 SECONDS)


// ---- Process loop (drives all timing) ----

/obj/machinery/race_controller/Process()
	if(!race || !is_powered())
		return

	switch(race.state)
		if(RACE_STATE_BETTING)
			var/time_left = race.phase_end_time - world.time

			if(!announced_3 && time_left <= (10 MINUTES))
				announced_3 = TRUE
				race.radio_announce("10 minutes until betting closes!", "Carp Races")
			if(!announced_2 && time_left <= (5 MINUTES))
				announced_2 = TRUE
				race.radio_announce("5 minutes until betting closes!", "Carp Races")
			if(!announced_1 && time_left <= (30 SECONDS))
				announced_1 = TRUE
				race.radio_announce("Bets close in 30 seconds!", "Carp Races")
			if(world.time >= race.phase_end_time)
				start_countdown_phase()

		if(RACE_STATE_COUNTDOWN)
			if(world.time >= race.phase_end_time)
				race.start_race()

		if(RACE_STATE_RACING)
			// Carp movement is now driven by per-carp addtimers (see racing_carp.dm).
			// Process() only handles camera tracking and announcements.
			var/mob/living/simple_animal/hostile/carp/racing/leader = null
			for(var/mob/living/simple_animal/hostile/carp/racing/C in race.racers)
				if(!QDELETED(C) && (!leader || C.x > leader.x))
					leader = C
			// Move the tracking camera to the lead carp (X = leader, Y = fixed track center)
			if(leader && tracking_cam && !QDELETED(tracking_cam))
				var/turf/cam_target = locate(leader.x, cam_center_y, leader.z)
				if(cam_target && cam_target != get_turf(tracking_cam))
					tracking_cam.forceMove(cam_target)
			// Announcement at halfway point
			if(leader && !announced_halfpoint && finish_turf && length(start_turfs))
				var/turf/start1 = start_turfs[1]
				if(start1)
					var/half_x = round((start1.x + finish_turf.x) / 2)
					if(leader.x >= half_x)
						announced_halfpoint = TRUE
						var/lnum = leader.race_number
						var/lcol = get_carp_color_name(lnum)
						race.radio_announce("Halfway point reached! Leading is Carp #[lnum] ([lcol])!")
			// Safety: force-end a race that has been going too long
			if(world.time >= race.phase_end_time)
				force_end_race()

		if(RACE_STATE_FINISHED)
			if(world.time >= race.phase_end_time)
				reset_race()


// ---- Admin control ----

/obj/machinery/race_controller/attack_hand(mob/user)
	if(!check_rights(R_ADMIN, 0, user.client))
		to_chat(user, SPAN_WARNING("Only administrators may control the race controller."))
		return

	var/choice = input(user, "Race Control", name) as null|anything in list(
		"Start betting phase",
		"Jump to countdown",
		"Start race immediately",
		"End race (refund bets)",
		"Full reset"
	)
	if(!choice)
		return

	switch(choice)
		if("Start betting phase")
			race.reset_to_idle()
			begin_betting_phase()
		if("Jump to countdown")
			if(race.state == RACE_STATE_BETTING)
				race.phase_end_time = world.time  // Expire betting phase now
		if("Start race immediately")
			if(race.state == RACE_STATE_BETTING || race.state == RACE_STATE_COUNTDOWN)
				race.state = RACE_STATE_COUNTDOWN
				race.phase_end_time = world.time
		if("End race (refund bets)")
			race.state          = RACE_STATE_FINISHED
			race.phase_end_time = world.time + RACE_RESET_DELAY
			race.radio_announce("Race cancelled by administrator. Bets refunded.", "Carp Races")
			race.refund_all()
		if("Full reset")
			race.reset_to_idle()
			begin_betting_phase()
