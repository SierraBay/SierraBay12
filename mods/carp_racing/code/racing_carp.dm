// ===========================
//   RACING CARP AI HOLDER
// ===========================

/// Custom AI holder for racing carps.
/// Never attacks. Moves only EAST during an active race, respecting movement_cooldown.
/datum/ai_holder/simple_animal/melee/racing_carp
	hostile    = FALSE
	wander     = FALSE
	speak_chance = 0

/datum/ai_holder/simple_animal/melee/racing_carp/find_target(list/possible_targets, has_targets_list)
	return null  // Racing carps never attack

// handle_special_strategical intentionally left empty — movement is addtimer-driven.
/datum/ai_holder/simple_animal/melee/racing_carp/handle_special_strategical()
	return


// ===========================
//   RACING CARP MOB
// ===========================

/**
 * A specially trained racing carp.
 * - Non-hostile: won't attack players.
 * - Moves EAST when the race is active.
 * - Each carp has a random speed offset via movement_cooldown.
 * - Colored by slot number (1=pink, 2=blue, 3=yellow, 4=grape, 5=rust, 6=teal).
 * - Detects finish line crossing via Move() override.
 */
/mob/living/simple_animal/hostile/carp/racing
	name        = "Carp #?"
	desc        = "A specially trained cosmic racing carp. It knows biting spectators is bad form."
	ai_holder   = /datum/ai_holder/simple_animal/melee/racing_carp
	icon = 'mods/carp_racing/icons/space_carp.dmi'
	faction     = "racing_carp"   // Never matches players or crew
	harm_intent_damage    = 0
	break_stuff_probability = 0

	/// Slot number in the race (1–RACE_CARP_COUNT)
	var/race_number = 0
	/// Reference to the race datum controlling this carp
	var/datum/carp_race/race = null
	/// The finish-line turf — carp wins when x >= finish_turf.x
	var/turf/finish_turf = null
	/// TRUE once this carp has crossed the finish line
	var/finished = FALSE
	/// Speed bias for this carp (-3 = fast, +3 = slow). Re-rolled every 8 tiles to keep the race dynamic.
	var/speed_bias = 0
	/// Steps taken so far — used to trigger random events every ~5 tiles
	var/step_counter = 0
	/// Remaining steps with a speed bonus after a confusion retreat.
	/// Set by resume_east() to help the carp recover lost ground.
	var/recovery_boost = 0
	/// Cached callback for do_race_step — created once, reused every step to avoid per-step datum allocation.
	var/datum/callback/step_cb = null


/mob/living/simple_animal/hostile/carp/racing/Initialize(mapload, num, datum/carp_race/R, turf/finish)
	race_number  = num
	race         = R
	finish_turf  = finish
	. = ..()

	name      = "Carp #[race_number]"
	real_name = name

	// Assign color by slot number (matches space_carp.dm icon_sets order)
	var/list/colors = list("pink", "blue", "yellow", "grape", "rust", "teal")
	if(race_number >= 1 && race_number <= RACE_CARP_COUNT)
		carp_color = colors[race_number]
	else
		carp_color = "black"
	icon_state  = "[carp_color]"
	icon_living = "[carp_color]"
	icon_dead   = "[carp_color]_dead"

	// Each carp gets a persistent speed personality: negative = faster, positive = slower.
	speed_bias = rand(-3, 3)
	step_cb    = new Callback(src, PROC_REF(do_race_step))

	update_icon()

/mob/living/simple_animal/hostile/carp/racing/carp_randomify()
	return  // Override: no random color/HP for racing carps

/mob/living/simple_animal/hostile/carp/racing/Move(atom/newloc, direct, glide_size, step_delay)
	. = ..()
	// After every successful step, check if we've crossed the finish x-coordinate
	if(. && !finished && race && race.state == RACE_STATE_RACING && finish_turf)
		if(x >= finish_turf.x)
			race.carp_finished(src)

/mob/living/simple_animal/hostile/carp/racing/Process_Spacemove(allow_movement)
	return TRUE  // Always free to move in space

// Racing carps don't fight back
/mob/living/simple_animal/hostile/carp/racing/attack_animal(mob/living/M)
	return

// ===========================
//   SELF-SCHEDULED MOVEMENT
// ===========================

/**
 * Kick off the movement timer for this carp at race start.
 * Called once per carp by datum/carp_race.start_race().
 * The optional start_offset staggers each carp's first step so
 * they don't all lurch forward simultaneously.
 */
/mob/living/simple_animal/hostile/carp/racing/proc/begin_racing(start_offset)
	if(QDELETED(src) || finished)
		return
	addtimer(step_cb, start_offset || 1)

/**
 * One movement tick.  Schedules itself for the next tick via addtimer.
 * Base step_delay matches glide duration so the carp always appears to swim.
 */
/mob/living/simple_animal/hostile/carp/racing/proc/do_race_step()
	if(QDELETED(src) || finished || !race || race.state != RACE_STATE_RACING)
		return

	// step_delay (ticks) = glide duration → no standing gap between steps
	// clamp to [2, 6]: 2 = ~0.2 s/tile (max speed), 6 = ~0.6 s/tile (slowest)
	var/step_delay = clamp(4 + speed_bias + rand(-1, 1), 2, 6)

	// Post-confusion recovery: move slightly faster for recovery_boost steps
	if(recovery_boost > 0)
		step_delay = max(2, step_delay - 1)
		recovery_boost--

	step_counter++

	// Every 8 tiles, re-roll the carp's speed bias to shuffle race positions
	if(step_counter % 8 == 0)
		speed_bias = rand(-3, 3)

	// Random event every 5 forward steps (10% confusion, 30% burst)
	if(step_counter % 5 == 0)
		var/roll = rand(1, 10)
		if(roll == 1)   // 10% chance — was roll <= 2 (20%)
			// Confusion: back up one tile, then return to east after a pause
			var/turf/back = get_step(src, WEST)
			if(back)
				dir = WEST
				set_glide_size(DELAY2GLIDESIZE(step_delay))
				Move(back)
			// Pause (glide back + tiny rest), then resume east
			addtimer(new Callback(src, PROC_REF(resume_east)), step_delay)
			return
		else if(roll <= 5)
			// Burst: shorter delay this step → faster glide
			step_delay = max(2, step_delay - 2)

	// Normal eastward step
	var/turf/next = get_step(src, EAST)
	if(next)
		dir = EAST
		set_glide_size(DELAY2GLIDESIZE(step_delay))
		Move(next)

	// Schedule next step so it fires exactly when glide finishes
	addtimer(step_cb, step_delay)

/**
 * After a confusion retreat, point the carp east and resume the normal cycle.
 * Grants a speed boost for the next few steps to help recover lost ground.
 * step_delay is passed so the return glide uses the same speed as the retreat.
 */
/mob/living/simple_animal/hostile/carp/racing/proc/resume_east()
	if(QDELETED(src) || finished || !race || race.state != RACE_STATE_RACING)
		return
	dir = EAST
	// Speed boost for the next 4 steps so the carp can catch up
	recovery_boost = 4
	addtimer(step_cb, 1)
