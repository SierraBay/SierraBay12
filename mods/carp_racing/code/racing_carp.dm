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

// handle_special_strategical intentionally left empty.
// Carp movement is driven by race_controller/Process() which runs on SSobj
// (not subject to the run_empty_levels z-level player check that SSai uses).
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
 * - Colored by slot number (1=purple, 2=blue, 3=yellow, 4=grape, 5=rust, 6=teal).
 * - Detects finish line crossing via Move() override.
 */
/mob/living/simple_animal/hostile/carp/racing
	name        = "Carp #?"
	desc        = "A specially trained cosmic racing carp. It knows biting spectators is bad form."
	ai_holder   = /datum/ai_holder/simple_animal/melee/racing_carp
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
	/// world.time when this carp is allowed to take its next step (randomised in Initialize)
	var/next_step_time = 0
	/// Persistent speed bias for this carp (-3 = fast, +3 = slow). Set at spawn, stays fixed all race.
	var/speed_bias = 0
	/// Steps taken so far — used to trigger random events every ~5 tiles
	var/step_counter = 0


/mob/living/simple_animal/hostile/carp/racing/Initialize(mapload, num, datum/carp_race/R, turf/finish)
	race_number  = num
	race         = R
	finish_turf  = finish
	. = ..()

	name      = "Carp #[race_number]"
	real_name = name

	// Assign color by slot number (matches space_carp.dm icon_sets order)
	var/list/colors = list("carp", "blue", "yellow", "grape", "rust", "teal")
	if(race_number >= 1 && race_number <= RACE_CARP_COUNT)
		carp_color = colors[race_number]
	else
		carp_color = "carp"
	icon_state  = "[carp_color]"
	icon_living = "[carp_color]"
	icon_dead   = "[carp_color]_dead"

	// Each carp gets a persistent speed personality: negative = faster, positive = slower.
	// Range: ±4 ticks per step → fastest ~5.1s/tile, slowest ~1.3s/tile on avg vs base 9
	speed_bias = rand(-4, 4)
	// Stagger start times so carps don't all take their first step simultaneously.
	next_step_time = world.time + rand(0, 20)  // 0–2 second random head-start spread

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
