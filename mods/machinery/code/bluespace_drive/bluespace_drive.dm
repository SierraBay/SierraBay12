/// How much each mole of a given gas contributes to jump power.
/// Multiplied by the logarithm of the gas temperature, incentivizing heating gases.
var/global/list/bluespace_gas_power_factor = list(
	GAS_PHORON     = 1,
	GAS_CO2        = 0.24,
	GAS_NITROGEN   = 0.3,
	GAS_N2O        = 0.32,
	GAS_HELIUM     = 0.4,
	GAS_HYDROGEN   = 0.8,
	GAS_OXYGEN     = 0.85,
	GAS_SULFUR     = 1.2,
	GAS_BORON      = 1.5,
	GAS_CHLORINE   = 2.75,
	GAS_DEUTERIUM  = 3,
	GAS_TRITIUM    = 4
)



//Just for test
/area/bluespace_interlude/platform
	name = "Bluespace Interlude - Platform"


/turf/simulated/floor/bluespace/interlude
	name = "\improper bluespace"



/obj/machinery/bluespace_drive
	name = "Bluespace Drive"
	desc = "A complex piece of machinery designed to fold space using Bluespace physics, powered by Phoron. \
			One of the most advanced propulsion technologies in existence, allowing instant jumps through bluespace."
	icon = 'mods/machinery/icons/bluespace-drive.dmi'
	icon_state = "drive_base"
	anchored = TRUE
	density = TRUE
	use_power = POWER_USE_IDLE
	idle_power_usage = 100
	active_power_usage = 50 KILOWATTS

	/// The overmap ship this drive is linked to
	var/obj/overmap/visitable/ship/linked

	/// Internal gas tank for moderator gases (fed from atmos pipe)
	var/datum/gas_mixture/internal_gas

	/// Fuel gas tank for phoron (fed from atmos pipe)
	var/datum/gas_mixture/fuel_gas

	/// How many phoron moles we need for a normal jump minimum.
	var/minimum_phoron_moles_per_jump = 500

	/// Minimum phoron moles for an emergency jump (unreliable destination, doubled cooldown).
	var/emergency_jump_min_moles = 50

	/// Whether the current jump is an emergency jump (low fuel).
	var/emergency_jump = FALSE

	/// The accumulated power from consumed gases
	var/power_from_gas = 0

	/// The rotation in degrees (0-359) for the jump direction on overmap
	var/rotation = 0

	/// The angle of the jump (affects distance calculation)
	var/angle = 60

	/// Whether the drive is energized (actively consuming gas)
	var/energized = FALSE

	/// Timer ID for jump countdown
	var/jump_timer_id

	/// Whether a jump is currently in progress
	var/jumping = FALSE

	/// Seconds before jump executes after initiation
	var/jump_delay = 30 SECONDS

	/// Whether jump is locked in final 5 seconds before execution (abort disabled)
	var/jump_locked = FALSE

	/// Timer ID for pre-jump overlay application (fires 5s before jump)
	var/pre_jump_timer_id

	/// Current orb overlay phase: null / "create_orb" / "drive_orb" / "decons_orb"
	var/orb_state = null

	/// Timer ID for orb animation transitions
	var/orb_timer_id

	/// Whether the drive is on post-jump cooldown (cannot initiate a new jump)
	var/on_cooldown = FALSE

	/// Timer ID for cooldown expiry
	var/cooldown_timer_id

	/// world.time tick when the cooldown expires (for UI countdown)
	var/cooldown_end_time = 0

	/// Duration of post-jump cooldown in ticks
	var/jump_cooldown_duration = 20 MINUTES

	/// Power level (in power_from_gas units) above which a jump is considered overcharged.
	/// Default: 150000 = 150 BSU (Bluespace Units) displayed in the UI.
	var/overcharge_threshold = 150000

	/// Whether the current/last jump was an overcharge jump
	var/overcharged = FALSE

	/// Rotation scatter (degrees) applied at jump initiation based on operator skill
	var/rotation_error = 0

	/// Current gas intake rate: 1=Low, 2=Medium, 3=High
	/// Low  = 5  mol/tick, Med = 20 mol/tick, High = 60 mol/tick
	var/intake_rate = 2

	/// Whether a bsd_instability event is currently active
	var/instability_event_active = FALSE

	/// Cumulative moles of each gas consumed during the current jump cycle.
	/// Used to determine gas modifier effects on jump exit.
	/// Reset on purge/abort, null when not tracking.
	var/list/gas_consumed_totals = null

	/// Figments spawned by the rift. Cleaned up when the rift closes.
	var/list/rift_mobs = list()

	/// Doppelgangers spawned by the rift. Cleaned up when the original player returns (or in Destroy).
	var/list/rift_doppelgangers = list()

	/// TRUE while the rift is open (between open_rift and close_rift).
	var/rift_open = FALSE

	/// BSD state flags used by endgame/event systems
	var/const/STATE_BROKEN = FLAG_01
	var/const/STATE_UNSTABLE = FLAG_02
	var/state = FLAGS_OFF

	/// Looping idle sound token, active while energized
	var/datum/sound_token/drive_sound

	/// TRUE while the drive is passively draining stored gas after de-energizing
	var/draining = FALSE

	pixel_x = -80
	pixel_y = -80

/obj/machinery/bluespace_drive/Initialize()
	. = ..()
	internal_gas = new /datum/gas_mixture
	internal_gas.volume = 200
	fuel_gas = new /datum/gas_mixture
	fuel_gas.volume = 200
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/bluespace_drive/LateInitialize(mapload)
	. = ..()
	// map_sectors is populated by the time LateInitialize runs
	if(GLOB.using_map.use_overmap)
		var/my_sector = map_sectors["[z]"]
		if(istype(my_sector, /obj/overmap/visitable/ship))
			linked = my_sector

/obj/machinery/bluespace_drive/Destroy()
	if(pre_jump_timer_id)
		deltimer(pre_jump_timer_id)
		pre_jump_timer_id = null
	if(jump_timer_id)
		deltimer(jump_timer_id)
		jump_timer_id = null
	if(orb_timer_id)
		deltimer(orb_timer_id)
		orb_timer_id = null
	if(cooldown_timer_id)
		deltimer(cooldown_timer_id)
		cooldown_timer_id = null
	QDEL_NULL(drive_sound)
	if(energized)
		energized = FALSE
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
	for(var/mob/M in rift_mobs + rift_doppelgangers)
		if(!QDELETED(M))
			qdel(M)
	rift_mobs = list()
	rift_doppelgangers = list()
	QDEL_NULL(internal_gas)
	QDEL_NULL(fuel_gas)
	linked = null
	. = ..()

/obj/machinery/bluespace_drive/Process()
	if(!energized)
		return

	if(!powered())
		if(energized)
			toggle_energized()
		return

	// Pull gases from connected atmos network via adjacent pipes
	pull_gases_from_environment()

	// Consume internal gases to build power
	consume_internal_gasses()

	use_power_oneoff(active_power_usage)

	// Passive radiation source while the rift is open
	if(rift_open)
		SSradiation.flat_radiate(src, 15, 5)

/obj/machinery/bluespace_drive/on_update_icon()
	ClearOverlays()
	. = ..()

	if(inoperable())
		set_light(0)
		return

	if(energized)
		AddOverlays("drive_glow")
		// Range 14: covers the full 192px (6-tile) sprite + surroundings
		set_light(14, 1.5, "#1a4fae")
		if(on_cooldown)
			AddOverlays("drive_cooldown")

	if(orb_state)
		AddOverlays(orb_state)
		if(orb_state == "drive_orb")
			set_light(22, 3, "#4c8cff")
		else
			set_light(18, 2, "#4c8cff")

/obj/machinery/bluespace_drive/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("The drive is [energized ? "energized and humming" : "powered down"]."))
	if(fuel_gas && fuel_gas.total_moles > 0)
		to_chat(user, SPAN_NOTICE("Phoron fuel level: [round(fuel_gas.total_moles, 0.1)] moles."))
	if(power_from_gas > 0)
		to_chat(user, SPAN_NOTICE("Accumulated jump power: [round(power_from_gas / 1000, 0.1)] BSU."))
	if(jumping)
		to_chat(user, SPAN_WARNING("WARNING: Jump sequence is active!"))


//   1 = Low (~5 mol/tick), 2 = Medium (~20 mol/tick), 3 = High (~60 mol/tick)

/obj/machinery/bluespace_drive/proc/pull_gases_from_environment()
	var/mol_limit
	switch(intake_rate)
		if(1) mol_limit = 5
		if(2) mol_limit = 20
		if(3) mol_limit = 60

	for(var/obj/machinery/atmospherics/portables_connector/connector in range(1, src))
		var/datum/gas_mixture/source = null

		// Prefer a connected canister, fall back to a connected pipe network
		if(connector.connected_device)
			source = connector.connected_device.air_contents
		else if(connector.node)
			source = connector.node.return_air()

		if(!source || source.total_moles < MINIMUM_MOLES_TO_PUMP)
			continue

		// Scrub phoron into the fuel tank, capped by intake_rate
		if(source.gas[GAS_PHORON] && source.gas[GAS_PHORON] >= MINIMUM_MOLES_TO_PUMP)
			scrub_gas(src, list(GAS_PHORON), source, fuel_gas, mol_limit)

		// Pump moderator gases — also capped by intake_rate
		if(source.total_moles >= MINIMUM_MOLES_TO_PUMP)
			var/available = source.total_moles - (source.gas[GAS_PHORON] || 0)
			if(available >= MINIMUM_MOLES_TO_PUMP)
				pump_gas(src, source, internal_gas, mol_limit)

/**
 * Compute the power from the gases that we received, and consume them.
 * Non-recognized gases are simply wasted.
 */
/obj/machinery/bluespace_drive/proc/consume_internal_gasses()
	if(!gas_consumed_totals)
		gas_consumed_totals = list()
	for(var/gas_type in internal_gas.gas)
		if(gas_type in bluespace_gas_power_factor)
			var/moles = internal_gas.gas[gas_type]
			power_from_gas += moles * (bluespace_gas_power_factor[gas_type] * log(max(internal_gas.temperature, 1.1)))
			// Track cumulative gas usage for modifier effects
			gas_consumed_totals[gas_type] = (gas_consumed_totals[gas_type] || 0) + moles

	// Reset internal gases - they have been consumed
	internal_gas = new /datum/gas_mixture
	internal_gas.volume = 200

/**
 * Returns the destination turf on the overmap for the jump, based on current configuration.
 * Returns null if the jump cannot be performed.
 */
/obj/machinery/bluespace_drive/proc/get_jump_destination()
	if(!linked)
		return null
	if(!fuel_gas.total_moles || !power_from_gas)
		return null

	var/turf/ship_turf = get_turf(linked)
	var/jump_power = power_from_gas / 1000

	var/effective_rotation = ((rotation + rotation_error) % 360 + 360) % 360
	var/datum/projectile_data/proj_data = projectile_trajectory(linked.x, linked.y, effective_rotation, angle, max(jump_power, 1))

	// Wrap-around: space is toroidal — coordinates wrap within 2..osize-1 (non-edge tiles).
	var/osize = GLOB.using_map.overmap_size
	var/dest_x = round(proj_data.dest_x)
	var/dest_y = round(proj_data.dest_y)
	dest_x = ((dest_x - 2) % (osize - 2) + (osize - 2)) % (osize - 2) + 2
	dest_y = ((dest_y - 2) % (osize - 2) + (osize - 2)) % (osize - 2) + 2

	var/turf/target_turf = locate(dest_x, dest_y, linked.z)

	// Validate destination
	if(!target_turf)
		return null
	if(!istype(target_turf, /turf/unsimulated/map))
		return null
	if(istype(target_turf, /turf/unsimulated/map/edge))
		return null
	if(target_turf == ship_turf)
		return null

	return target_turf

/**
 * Toggles the energized state of the drive
 */
/obj/machinery/bluespace_drive/proc/toggle_energized()
	// Cannot power down while jump is locked (final 5 seconds before execution)
	if(energized && jump_locked)
		return
	energized = !energized

	if(energized)
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		visible_message(SPAN_NOTICE("\The [src] hums to life, bluespace field coils energizing."))
		playsound(src, 'sound/machines/engine.ogg', 50, TRUE)
		drive_sound = GLOB.sound_player.PlayLoopingSound(src, "\ref[src]", 'sound/machines/BSD_idle.ogg', 50, 10)
	else
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		QDEL_NULL(drive_sound)
		visible_message(SPAN_NOTICE("\The [src] powers down, the hum fading away."))
		set_light(0)

		// If we're jumping, abort first (instant purge on abort is intentional)
		if(jump_timer_id)
			abort_jump()
		// Otherwise, passively drain stored gas over time
		else if(internal_gas.total_moles || fuel_gas.total_moles || power_from_gas > 0)
			if(!draining)
				invoke_async(src, PROC_REF(start_gradual_drain))

	update_icon()

/**
 * Passively drains stored gas and accumulated power at 2% per 2 seconds after de-energizing.
 * Stops if the drive is re-energized or deleted.
 */
/obj/machinery/bluespace_drive/proc/start_gradual_drain()
	draining = TRUE
	while(!energized && !QDELETED(src))
		if(fuel_gas.total_moles <= 0 && internal_gas.total_moles <= 0 && power_from_gas <= 0)
			break
		sleep(2 SECONDS)
		if(QDELETED(src))
			break
		if(energized)
			// Re-energized — stop draining without clearing gas
			break
		fuel_gas.remove_ratio(0.01)
		internal_gas.remove_ratio(0.01)
		power_from_gas = max(0, power_from_gas * 0.98)
		update_icon()
	// If still de-energized after drain loop, finalize cleanup
	if(!energized && !QDELETED(src))
		gas_consumed_totals = null
		fuel_gas = new /datum/gas_mixture
		fuel_gas.volume = 200
		internal_gas = new /datum/gas_mixture
		internal_gas.volume = 200
		power_from_gas = 0
		update_icon()
	draining = FALSE

/**
 * Purges all stored gas and power from the drive.
 * @param forced If TRUE, produces a visible flash/sound effect.
 */
/obj/machinery/bluespace_drive/proc/purge_charge(forced = FALSE)
	var/had_fuel = (fuel_gas.total_moles >= minimum_phoron_moles_per_jump)

	if(forced)
		playsound(src, 'sound/effects/supermatter.ogg', 80, TRUE)

		// Flash and deafen nearby people
		for(var/mob/living/carbon/human/H in viewers(world.view, src))
			H.eye_blurry = max(H.eye_blurry, 10)
			H.ear_deaf = max(H.ear_deaf, 5)

		// Phoron tank was full: trigger a strong EMP pulse
		if(had_fuel)
			playsound(src, 'sound/effects/EMPulse.ogg', 100, TRUE)
			empulse(src, 8, 20)

	power_from_gas = 0
	gas_consumed_totals = null

	fuel_gas = new /datum/gas_mixture
	fuel_gas.volume = 200
	internal_gas = new /datum/gas_mixture
	internal_gas.volume = 200

	update_icon()

/**
 * Sets the rotation angle for the jump direction
 */
/obj/machinery/bluespace_drive/proc/set_rotation(new_rotation)
	if(jumping)
		return
	if(!isnum(new_rotation) || new_rotation < 0 || new_rotation > 359)
		return
	rotation = new_rotation

/**
 * Sets the angle for the jump power
 */
/obj/machinery/bluespace_drive/proc/set_angle(new_angle)
	if(jumping)
		return
	if(!isnum(new_angle) || new_angle < 1 || new_angle > 89)
		return
	angle = new_angle

/*
 * ===========================
 *    JUMP SEQUENCE PROCS
 * ===========================
 */

/**
 * Initiates the jump sequence.
 * Returns FALSE if the jump cannot be performed, TRUE otherwise.
 */
/obj/machinery/bluespace_drive/proc/initiate_jump(mob/user = null)
	// Already jumping
	if(jump_timer_id)
		return FALSE

	// On cooldown
	if(on_cooldown)
		return FALSE

	// Check phoron levels: normal jump requires minimum_phoron_moles_per_jump,
	// emergency jump requires only emergency_jump_min_moles (with severe penalties).
	emergency_jump = FALSE
	if(fuel_gas.total_moles < minimum_phoron_moles_per_jump)
		if(fuel_gas.total_moles < emergency_jump_min_moles)
			return FALSE
		emergency_jump = TRUE

	// No valid destination (checked at nominal rotation before scatter is applied)
	if(!get_jump_destination())
		return FALSE

	rotation_error = 0
	if(emergency_jump)
		// Emergency jump: navigation is unreliable regardless of operator skill
		rotation_error = rand(-45, 45)
		if(user?.client)
			to_chat(user, SPAN_DANGER("WARNING: Insufficient phoron for stable jump! Navigation systems are compromised — destination is unreliable!"))
	else if(user)
		var/skill = user.get_skill_value(SKILL_ENGINES)
		if(skill >= SKILL_MASTER)
			rotation_error = 0
		else if(skill >= SKILL_EXPERIENCED)
			rotation_error = rand(-5, 5)
		else if(skill >= SKILL_TRAINED)
			rotation_error = rand(-10, 10)
		else if(skill >= SKILL_BASIC)
			rotation_error = rand(-20, 20)
		else
			rotation_error = rand(-30, 30)
		if(rotation_error != 0 && user.client)
			to_chat(user, SPAN_WARNING("Navigation systems report a [abs(rotation_error)]\u00b0 deviation in the bluespace field alignment."))
	else
		rotation_error = rand(-15, 15)

	// Flag overcharge before the jump begins
	overcharged = (power_from_gas >= overcharge_threshold)

	jumping = TRUE

	// Admin logging
	log_admin("BSD [src] ([x],[y],[z]): jump initiated by [user ? "[user.name]([user.ckey])" : "automated"]. Power: [round(power_from_gas/1000,0.1)] BSU. Overcharged: [overcharged ? "YES" : "no"]. Emergency: [emergency_jump ? "YES" : "no"]")

	// Announce the jump
	if(emergency_jump)
		command_announcement.Announce("EMERGENCY ALERT! Bluespace drive is initiating an emergency jump with insufficient fuel. \
			Navigation accuracy cannot be guaranteed. All hands brace for uncontrolled bluespace transition. \
			[jump_delay / 10] seconds to space warping.", \
			"EMERGENCY JUMP SEQUENCE INITIATED")
	else
		command_announcement.Announce("Attention all hands! Bluespace field generation arrays are being energized. \
			Assume jump action stations - bluespace transition procedures are now in effect. \
			Severe risk of death or serious injury to all personnel outside of the vessel. \
			[jump_delay / 10] seconds to space warping.", \
			"Bluespace Drive Jump Sequence Initiated")

	// Play create_orb animation (0.5s), then switch to looping drive_orb
	orb_state = "create_orb"
	if(orb_timer_id)
		deltimer(orb_timer_id)
	orb_timer_id = addtimer(new Callback(src, PROC_REF(orb_set_active)), 0.5 SECONDS, TIMER_STOPPABLE)

	// Start jump countdown
	jump_timer_id = addtimer(new Callback(src, PROC_REF(execute_jump)), jump_delay, TIMER_UNIQUE|TIMER_STOPPABLE)

	// 5 seconds before jump: apply overlay to all crew and lock abort
	if(jump_delay > 5 SECONDS)
		pre_jump_timer_id = addtimer(new Callback(src, PROC_REF(pre_jump_prepare)), jump_delay - 5 SECONDS, TIMER_STOPPABLE)
	else
		pre_jump_prepare()

	update_icon()
	return TRUE

/**
 * Called 5 seconds before jump: locks abort and applies bluespace overlay to all crew on ship.
 */
/obj/machinery/bluespace_drive/proc/pre_jump_prepare()
	pre_jump_timer_id = null
	jump_locked = TRUE
	for(var/mob/living/L in GLOB.player_list)
		if(!AreConnectedZLevels(L.z, z))
			continue
		apply_bluespace_effect(L)
		L.playsound_local(L, 'sound/magic/ethereal_enter.ogg', 60)
	update_icon()

/**
 * Switches orb overlay from create_orb to the looping drive_orb.
 */
/obj/machinery/bluespace_drive/proc/orb_set_active()
	orb_timer_id = null
	orb_state = "drive_orb"
	update_icon()

/**
 * Starts the decons_orb animation then clears the orb overlay entirely.
 */
/obj/machinery/bluespace_drive/proc/orb_start_decons()
	orb_state = "decons_orb"
	if(orb_timer_id)
		deltimer(orb_timer_id)
	orb_timer_id = addtimer(new Callback(src, PROC_REF(orb_set_inactive)), 0.5 SECONDS, TIMER_STOPPABLE)
	update_icon()

/**
 * Clears the orb overlay after decons animation finishes.
 */
/obj/machinery/bluespace_drive/proc/orb_set_inactive()
	orb_timer_id = null
	orb_state = null
	update_icon()

/**
 * Executes the actual jump after the countdown.
 */
/obj/machinery/bluespace_drive/proc/execute_jump()
	if(!linked)
		exit_bluespace()
		return

	// Kill anyone still outside the ship during jump
	for(var/mob/living/L in GLOB.player_list)
		if(!AreConnectedZLevels(L.z, z))
			continue
		if(istype(get_area(L), /area/space))
			to_chat(L, SPAN_DANGER("Space completely warps around you, turning your body into something that a mind can barely comprehend..."))
			L.death()

	// Open the bluespace rift — pull nearby crew and spawn figments
	// (passive radiation is handled by Process() while rift_open is TRUE)
	open_rift()

	// Perform the jump
	move_ship()

	// Exit bluespace
	exit_bluespace()

/**
 * Moves the ship to the calculated overmap destination.
 */
/obj/machinery/bluespace_drive/proc/move_ship()
	if(!linked)
		return

	var/turf/target_turf = get_jump_destination()
	if(!target_turf)
		visible_message(SPAN_DANGER("\The [src] fails to lock onto a valid bluespace path!"))
		purge_charge(forced = TRUE)
		return

	// Stop the ship's current velocity
	linked.speed[1] = 0
	linked.speed[2] = 0
	linked.position[1] = 0
	linked.position[2] = 0

	// Move the ship on the overmap
	linked.forceMove(target_turf)
	linked.update_icon()

	playsound(src, 'sound/magic/ethereal_exit.ogg', 100, TRUE)
	visible_message(SPAN_NOTICE("\The [src] shudders as the ship exits bluespace!"))

/**
 * Cleans up after a jump; crew overlay is removed after a 5-second delay.
 */
/obj/machinery/bluespace_drive/proc/exit_bluespace()
	for(var/mob/living/L in GLOB.player_list)
		if(!AreConnectedZLevels(L.z, z))
			continue
		L.playsound_local(L, 'sound/magic/ethereal_exit.ogg', 60)

	jump_timer_id = null
	jumping = FALSE
	jump_locked = FALSE
	rotation_error = 0
	// Close the rift — may pull any crew still in the danger zone, then clean up rift mobs
	close_rift()
	// Apply gas modifier effects before purging (uses gas_consumed_totals)
	var/cooldown_reduction = apply_gas_modifier_effects()
	// Emergency jump doubles the cooldown (negative reduction = added time)
	if(emergency_jump)
		cooldown_reduction -= jump_cooldown_duration
		emergency_jump = FALSE
	purge_charge()
	// Play decons_orb animation before removing the orb
	orb_start_decons()
	// Start post-jump cooldown, reduced (or extended) by modifiers
	start_cooldown(cooldown_reduction)
	// Overcharge consequences: extended crew effects + power cascade failure
	if(overcharged)
		apply_overcharge_effects()
	// Keep the bluespace overlay for 5 seconds after the jump completes
	addtimer(new Callback(src, PROC_REF(clear_all_bluespace_effects)), 5 SECONDS)
	update_icon()

/**
 * Removes the bluespace overlay from all crew after the post-jump delay.
 */
/obj/machinery/bluespace_drive/proc/clear_all_bluespace_effects()
	for(var/mob/living/L in GLOB.player_list)
		if(!AreConnectedZLevels(L.z, z))
			continue
		remove_bluespace_effect(L)

/**
 * Aborts an in-progress jump sequence. Blocked in the final 5 seconds.
 */
/obj/machinery/bluespace_drive/proc/abort_jump(mob/user = null)
	if(jump_locked)
		visible_message(SPAN_WARNING("\The [src]'s jump sequence is locked \u2014 too late to abort!"))
		return
	if(pre_jump_timer_id)
		deltimer(pre_jump_timer_id)
		pre_jump_timer_id = null
	if(jump_timer_id)
		deltimer(jump_timer_id)
		jump_timer_id = null
	jumping = FALSE
	rotation_error = 0
	overcharged = FALSE
	emergency_jump = FALSE
	if(power_from_gas > 0 || internal_gas.total_moles || fuel_gas.total_moles)
		purge_charge(forced = TRUE)
	// Play decons_orb animation before removing the orb
	orb_start_decons()
	log_admin("BSD [src] ([x],[y],[z]): jump ABORTED by [user ? "[user.name]([user.ckey])" : "automated"]")
	visible_message(SPAN_DANGER("\The [src]'s bluespace warp bubble falters, discharging!"))
	command_announcement.Announce("Bluespace jump sequence has been aborted. Bluespace field is dissipating.", \
		"Bluespace Drive Jump Aborted")

/**
 * Apply visual and gameplay effects to a mob during bluespace travel.
 */
/obj/machinery/bluespace_drive/proc/apply_bluespace_effect(mob/living/L)
	if(L.client)
		to_chat(L, SPAN_NOTICE("You feel oddly light, and somewhat disoriented as everything around you shimmers and warps ever so slightly."))
		L.flash_eyes()
	L.set_confused(20)

/**
 * Remove visual and gameplay effects from a mob after bluespace travel.
 */
/obj/machinery/bluespace_drive/proc/remove_bluespace_effect(mob/living/L)
	if(L.client)
		to_chat(L, SPAN_NOTICE("You feel rooted in the material world again."))

/*
 * ===========================
 *     UI / INTERACTION
 * ===========================
 */

/obj/machinery/bluespace_drive/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/bluespace_drive/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = list()

	data["energized"] = energized
	data["jumping"] = jumping
	data["rotation"] = rotation
	data["angle"] = angle
	data["jump_power"] = round(power_from_gas / 1000, 0.1)
	data["min_fuel"] = minimum_phoron_moles_per_jump
	data["emergency_min_fuel"] = emergency_jump_min_moles
	data["emergency_jump"] = emergency_jump
	data["rift_open"] = rift_open
	data["has_destination"] = !!get_jump_destination()
	data["linked"] = !!linked
	data["jump_locked"] = jump_locked
	data["on_cooldown"] = on_cooldown
	data["cooldown_remaining"] = on_cooldown ? max(0, round((cooldown_end_time - world.time) / 10, 1)) : 0
	data["overcharged"] = (power_from_gas >= overcharge_threshold)
	data["near_overcharge"] = (power_from_gas >= overcharge_threshold * 0.75 && power_from_gas < overcharge_threshold)
	data["overcharge_threshold"] = round(overcharge_threshold / 1000, 0.1)
	data["intake_rate"] = intake_rate

	// Fuel tank contents
	var/list/fuel_parts = list()
	if(fuel_gas && fuel_gas.total_moles > 0)
		for(var/gas_id in fuel_gas.gas)
			fuel_parts += "[gas_data.name[gas_id]] [round(fuel_gas.gas[gas_id], 0.1)] mol ([round(fuel_gas.gas[gas_id] / fuel_gas.total_moles * 100, 1)]%)"
	data["fuel_contents_str"] = fuel_parts.Join(", ")
	data["fuel_total_moles"] = round(fuel_gas ? fuel_gas.total_moles : 0, 0.1)
	data["fuel_temp_k"]      = (fuel_gas && fuel_gas.total_moles > 0) ? round(fuel_gas.temperature) : 0
	data["fuel_pres"]        = round(fuel_gas ? fuel_gas.return_pressure() : 0, 1)

	if(linked)
		data["ship_name"] = linked.name
		data["ship_x"] = linked.x
		data["ship_y"] = linked.y

	var/turf/dest = get_jump_destination()
	if(dest)
		data["dest_x"] = dest.x
		data["dest_y"] = dest.y

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "bluespace_drive.tmpl", "Bluespace Drive Control", 700, 800)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/bluespace_drive/OnTopic(mob/user, list/href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(href_list["toggle_energized"])
		if(!powered())
			to_chat(user, SPAN_WARNING("The drive has no power!"))
			return TOPIC_HANDLED
		toggle_energized()
		return TOPIC_REFRESH

	if(href_list["purge"])
		purge_charge(forced = TRUE)
		return TOPIC_REFRESH

	if(href_list["set_rotation"])
		var/new_rot = input(user, "Enter jump rotation (0-359 degrees):", "Set Rotation", rotation) as num|null
		if(!isnull(new_rot))
			set_rotation(new_rot)
		return TOPIC_REFRESH

	if(href_list["set_angle"])
		var/new_ang = input(user, "Enter jump angle (1-89 degrees):", "Set Angle", angle) as num|null
		if(!isnull(new_ang))
			set_angle(new_ang)
		return TOPIC_REFRESH

	if(href_list["jump"])
		if(!energized)
			to_chat(user, SPAN_WARNING("The drive must be energized first!"))
			return TOPIC_HANDLED
		var/success = initiate_jump(user)
		if(!success)
			to_chat(user, SPAN_WARNING("Unable to initiate jump! Check fuel levels, destination, cooldown status, or if a jump is already in progress."))
		return TOPIC_REFRESH

	if(href_list["abort"])
		if(jump_locked)
			to_chat(user, SPAN_WARNING("The jump sequence is locked \u2014 too late to abort!"))
			return TOPIC_HANDLED
		abort_jump(user)
		return TOPIC_REFRESH

	if(href_list["set_intake"])
		if(jumping || jump_locked)
			to_chat(user, SPAN_WARNING("Cannot adjust intake during an active jump sequence."))
			return TOPIC_HANDLED
		var/new_rate = text2num(href_list["set_intake"])
		if(new_rate && new_rate >= 1 && new_rate <= 3)
			intake_rate = new_rate
		return TOPIC_REFRESH

	return TOPIC_HANDLED

/**
 * Creates a bluespace pulse on all connected z-levels. Used by the bsd_instability event.
 */
/obj/machinery/bluespace_drive/proc/do_pulse()
	playsound(src, 'sound/effects/EMPulse.ogg', 100, TRUE)
	for(var/level in GetConnectedZlevels(z))
		new /datum/bubble_effect/bluespace_pulse(x, y, level, 1, 1, src)

/*
 * ===========================
 *   COOLDOWN & OVERCHARGE
 * ===========================
 */

/**
 * Starts the post-jump cooldown, blocking a new jump for jump_cooldown_duration.
 * @param cooldown_reduction How many ticks to subtract from the cooldown (e.g. from gas modifier effects).
 */
/obj/machinery/bluespace_drive/proc/start_cooldown(cooldown_reduction = 0)
	on_cooldown = TRUE
	if(cooldown_timer_id)
		deltimer(cooldown_timer_id)
	var/actual_duration = max(30 SECONDS, jump_cooldown_duration - cooldown_reduction)
	cooldown_end_time = world.time + actual_duration
	cooldown_timer_id = addtimer(new Callback(src, PROC_REF(end_cooldown)), actual_duration, TIMER_STOPPABLE)
	update_icon()

/**
 * Clears the post-jump cooldown.
 */
/obj/machinery/bluespace_drive/proc/end_cooldown()
	cooldown_timer_id = null
	on_cooldown = FALSE
	cooldown_end_time = 0
	overcharged = FALSE
	update_icon()

/**
 * Applies overcharge consequences:
 * - Extended sensory impairment to all crew on z-level
 * - Cascade power failure: emags all APCs on z-level, which reboot after a
 *   randomized delay (30s - 2min) to simulate a power system overload.
 */
/obj/machinery/bluespace_drive/proc/apply_overcharge_effects()
	command_announcement.Announce("WARNING: Bluespace field overload detected! Power systems are experiencing a cascade failure!", \
		"CRITICAL SYSTEM ALERT", new_sound = 'sound/misc/aldensaraspovajump.ogg')

	for(var/mob/living/L in GLOB.player_list)
		if(!AreConnectedZLevels(L.z, z))
			continue
		L.eye_blurry = max(L.eye_blurry, 80)
		L.ear_deaf = max(L.ear_deaf, 30)
		if(L.client)
			to_chat(L, SPAN_DANGER("The ship shudders violently as the bluespace field overloads! The lights flicker and die!"))

	// Cascade power failure: disable all APCs on all z-levels of the ship
	for(var/obj/machinery/power/apc/A in world)
		var/turf/T = get_turf(A)
		if(!T || !AreConnectedZLevels(T.z, z)) continue
		if(A.emagged) continue
		A.emagged = TRUE
		A.update_icon()
		addtimer(new Callback(src, PROC_REF(reboot_apc_delayed), A), rand(30 SECONDS, 2 MINUTES), TIMER_STOPPABLE)

/**
 * Reboots an APC after an overcharge power failure.
 * Safe to call on a deleted BSD - QDELETED check on APC is sufficient.
 */
/obj/machinery/bluespace_drive/proc/reboot_apc_delayed(obj/machinery/power/apc/apc)
	if(!apc || QDELETED(apc))
		return
	if(!apc.emagged)
		return // Already manually repaired by crew
	apc.emagged = FALSE
	apc.update_icon()

/**
 * Applies special effects based on which gases were consumed during the jump.
 * Returns a cooldown reduction in ticks (for tritium effect).
 *
 * Effects:
 * - Tritium  : reduces post-jump cooldown by 30s per 100 moles, up to 5 min total.
 * - N2O      : crew experiences N2O euphoria — confusion and mild disorientation.
 * - Chlorine : crew near the drive receives a brief toxic flash (minor damage).
 * - Hydrogen : flavor announcement — faster field dissipation.
 */
/obj/machinery/bluespace_drive/proc/apply_gas_modifier_effects()
	if(!gas_consumed_totals)
		return 0

	var/cooldown_reduction = 0

	// Tritium — reduces cooldown by 30s per 100 moles, capped at 5 minutes
	var/tritium_moles = gas_consumed_totals[GAS_TRITIUM] || 0
	if(tritium_moles >= 50)
		cooldown_reduction = min(5 MINUTES, round(tritium_moles / 100) * 30 SECONDS)
		command_announcement.Announce("Tritium moderator stabilization successful — bluespace field dissipated ahead of schedule. Jump cooldown reduced.", \
			"Bluespace Drive Diagnostics")

	// N2O — crew gets euphoric/confused from nitrous oxide bleeding into the field
	var/n2o_moles = gas_consumed_totals[GAS_N2O] || 0
	if(n2o_moles >= 30)
		for(var/mob/living/L in GLOB.player_list)
			if(!AreConnectedZLevels(L.z, z))
				continue
			if(L.client)
				to_chat(L, SPAN_NOTICE("A faint sweet odor fills your lungs as residual N2O bleeds through the jump field..."))
			L.set_confused(15)
			if(istype(L, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = L
				H.reagents.add_reagent("n2o", min(n2o_moles * 0.002, 3))

	// Chlorine — brief toxic flash to crew within 5 tiles of the drive
	var/chlorine_moles = gas_consumed_totals[GAS_CHLORINE] || 0
	if(chlorine_moles >= 20)
		visible_message(SPAN_WARNING("\The [src] vents a sharp-smelling chemical discharge as the chlorine moderator dissipates!"))
		for(var/mob/living/L in range(5, src))
			if(L.client)
				to_chat(L, SPAN_DANGER("You feel a burning sensation as chlorine gas briefly floods the area!"))
			L.apply_damage(min(chlorine_moles * 0.05, 15), DAMAGE_TOXIN)

	// Hydrogen — flavor effect, no mechanical change
	var/hydrogen_moles = gas_consumed_totals[GAS_HYDROGEN] || 0
	if(hydrogen_moles >= 100)
		visible_message(SPAN_NOTICE("\The [src]'s field coils cool rapidly — hydrogen moderator provided efficient heat dissipation."))

	gas_consumed_totals = null
	return cooldown_reduction

/*
 * ===========================
 *   RIFT MECHANICS
 * ===========================
 */

/**
 * Opens the bluespace rift at the start of a jump.
 * Pulls any crew within range 2 into the interlude and spawns figments.
 * Called from execute_jump() before move_ship().
 */
/obj/machinery/bluespace_drive/proc/open_rift()
	rift_open = TRUE
	playsound(src, 'sound/magic/ethereal_enter.ogg', 100, TRUE)
	visible_message(SPAN_DANGER("\The [src] tears open a bluespace rift!"))

	// Pull nearby crew into the rift
	for(var/mob/living/L in range(2, src))
		if(!L.client || L.stat == DEAD)
			continue
		if(!AreConnectedZLevels(L.z, z))
			continue
		if(istype(get_area(L), /area/bluespace_interlude/platform))
			continue
		if(prob(50))
			pull_player_into_rift(L)

	// Spawn figments
	spawn_rift_figments()

/**
 * Closes the bluespace rift at the end of a jump.
 * May pull any crew still in the danger zone, then destroys all rift mobs.
 * Called from exit_bluespace() before purge_charge().
 */
/obj/machinery/bluespace_drive/proc/close_rift()
	// Pull any lingering crew before the rift snaps shut
	for(var/mob/living/L in range(2, src))
		if(!L.client || L.stat == DEAD)
			continue
		if(!AreConnectedZLevels(L.z, z))
			continue
		if(istype(get_area(L), /area/bluespace_interlude/platform))
			continue
		if(prob(50))
			pull_player_into_rift(L)

	// Figments live until their individual timer fires (20-60s) — do not delete here
	// rift_mobs list will be cleaned naturally by despawn_rift_mob()
	rift_open = FALSE

/**
 * Teleports a living player into the bluespace interlude for 3-5 minutes.
 * Spawns a hostile doppelganger at their original location.
 * After the timer expires, the player is returned to a random floor tile near the BSD.
 */
/obj/machinery/bluespace_drive/proc/pull_player_into_rift(mob/living/L)
	if(!istype(L) || !L.client)
		return

	// Find the interlude map via the first interlude turf
	var/turf/anchor = locate(/turf/simulated/floor/bluespace/interlude)
	if(!anchor)
		return

	var/list/interlude_options = list()
	for(var/turf/simulated/floor/bluespace/interlude/T in range(50, anchor))
		if(!T.density)
			interlude_options += T
	if(!length(interlude_options))
		interlude_options += anchor

	// Pick a return turf: random open floor near the BSD
	var/list/return_options = list()
	for(var/turf/simulated/floor/T in range(25, src))
		if(!T.density && !istype(T, /turf/simulated/floor/bluespace))
			return_options += T
	var/turf/return_turf = length(return_options) ? pick(return_options) : get_turf(src)

	// Spawn doppelganger immediately at victim's location
	var/turf/victim_turf = get_turf(L)
	var/mob/living/simple_animal/hostile/bluespace/doppelganger/clone = new(victim_turf)
	clone.appearance = L.appearance
	clone.name = L.name
	rift_doppelgangers += clone
	playsound(victim_turf, 'sound/machines/BSD_interact.ogg', 80, TRUE)
	visible_message(SPAN_DANGER("[L] is torn into the bluespace rift! Something steps out in their place..."))

	// Async: play pull animation then teleport
	invoke_async(src, PROC_REF(do_pull_animation), L, pick(interlude_options), return_turf, clone)

/**
 * Plays the pull-into-rift animation, then teleports the mob to the interlude.
 * Called async from pull_player_into_rift so it can sleep without blocking.
 */
/obj/machinery/bluespace_drive/proc/do_pull_animation(mob/living/L, turf/dest, turf/return_turf, mob/clone)
	if(!L || QDELETED(L))
		return
	var/turf/victim_turf = get_turf(L)

	playsound(victim_turf, 'sound/magic/ethereal_enter.ogg', 80, TRUE)

	if(L.client)
		L.flash_eyes(FLASH_PROTECTION_MAJOR)

	L.phase_out(victim_turf)

	var/matrix/shrink = matrix()
	shrink.Scale(0.1, 0.1)
	animate(L, transform = shrink, alpha = 0, time = 8)
	sleep(8)

	if(!L || QDELETED(L))
		return

	L.transform = matrix()
	L.alpha = 255

	L.forceMove(dest)
	apply_bluespace_effect(L)
	to_chat(L, SPAN_DANGER("Reality shatters around you — you're pulled into the rift!"))
	to_chat(L, SPAN_NOTICE("You'll be expelled back in [round(rand(3 MINUTES, 5 MINUTES) / (1 MINUTE), 0.5)] minutes."))

	addtimer(new Callback(src, PROC_REF(return_from_rift), L, return_turf, clone), rand(3 MINUTES, 5 MINUTES), TIMER_STOPPABLE)

/**
 * Returns a mob from the bluespace interlude back to the ship.
 * Also removes the associated doppelganger if it still exists.
 * Safe if the BSD or clone have already been deleted.
 */
/obj/machinery/bluespace_drive/proc/return_from_rift(mob/living/L, turf/return_turf, mob/doppelganger)
	if(!L || QDELETED(L))
		return
	if(!return_turf)
		return

	playsound(get_turf(L), 'sound/magic/ethereal_exit.ogg', 80, TRUE)
	L.forceMove(return_turf)
	L.phase_in(return_turf)
	remove_bluespace_effect(L)

	// Clean up the doppelganger if it survived
	if(doppelganger && !QDELETED(doppelganger))
		visible_message(SPAN_NOTICE("[doppelganger] dissolves as the real [L.name] returns."))
		qdel(doppelganger)
	rift_doppelgangers -= doppelganger

/**
 * Spawns 1-3 bluespace figments near the drive when the rift opens.
 * Figments disappear automatically after 30 seconds.
 *
 * Chances:
 * - 30% → 3 figments
 * - 40% → 2 figments
 * - 30% → 1 figment
 */
/obj/machinery/bluespace_drive/proc/spawn_rift_figments()
	var/roll = rand(1, 100)
	var/count = 0
	if(roll <= 15)
		count = 2
	else if(roll <= 50)
		count = 1

	if(!count)
		return

	var/list/nearby = list()
	for(var/turf/T in range(3, src))
		if(!T.density && AreConnectedZLevels(T.z, z))
			nearby += T

	for(var/i = 1 to count)
		if(!length(nearby))
			break
		var/turf/spawn_turf = pick(nearby)
		var/mob/living/simple_animal/hostile/bluespace/figment = new(spawn_turf)
		rift_mobs += figment
		visible_message(SPAN_DANGER("A bluespace figment tears through the rift!"))
		playsound(spawn_turf, 'sound/magic/ethereal_enter.ogg', 70, TRUE)
		playsound(src, 'sound/machines/BSD_interact.ogg', 80, TRUE)
		// Individual despawn timer — 30 seconds
		addtimer(new Callback(src, PROC_REF(despawn_rift_mob), figment), 30 SECONDS, TIMER_STOPPABLE)

/**
 * Despawns a single rift mob (figment) after its timer expires.
 * Safe to call on deleted BSD.
 */
/obj/machinery/bluespace_drive/proc/despawn_rift_mob(mob/M)
	if(!M || QDELETED(M))
		return
	rift_mobs -= M
	visible_message(SPAN_NOTICE("[M] flickers and fades back into bluespace."))
	playsound(get_turf(M), 'sound/magic/ethereal_exit.ogg', 50, TRUE)
	qdel(M)
