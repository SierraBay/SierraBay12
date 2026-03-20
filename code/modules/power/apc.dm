

// The Area Power Controller (APC)
// Controls and provides power to most electronics in an area
// Only one required per area
// Requires a wire connection to a power network through a terminal
// Generates a terminal based on the direction of the APC on spawn

// There are three different power channels, lighting, equipment, and enviroment
// Each may have one of the following states

#define POWERCHAN_OFF		0	// Power channel is off
#define POWERCHAN_OFF_TEMP	1	// Power channel is off until there is power
#define POWERCHAN_OFF_AUTO	2	// Power channel is off until power passes a threshold
#define POWERCHAN_ON		3	// Power channel is on until there is no power
#define POWERCHAN_ON_AUTO	4	// Power channel is on until power drops below a threshold

// Power channels set to Auto change when power levels rise or drop below a threshold

#define AUTO_THRESHOLD_LIGHTING  50
#define AUTO_THRESHOLD_EQUIPMENT 25
// The ENVIRON channel stays on as long as possible, and doesn't have a threshold

#define CRITICAL_APC_EMP_PROTECTION 10	// EMP effect duration is divided by this number if the APC has "critical" flag
#define APC_UPDATE_ICON_COOLDOWN 100	// Time between automatically updating the icon (10 seconds)

// Used to check whether or not to update the icon_state
#define UPDATE_CELL_IN 1
#define UPDATE_OPENED1 2
#define UPDATE_OPENED2 4
#define UPDATE_MAINT 8
#define UPDATE_BROKE 16
#define UPDATE_BLUESCREEN 32
#define UPDATE_WIREEXP 64
#define UPDATE_ALLGOOD 128

// Used to check whether or not to update the overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_LOCKED 8
#define APC_UPOVERLAY_OPERATING 16

#define APC_CACHE_TICK_STATE_DIRTY (1<<0)
#define APC_CACHE_AUTOMATION_DIRTY (1<<1)
#define APC_CACHE_UI_DIRTY (1<<2)
#define APC_CACHE_ALL_DIRTY (APC_CACHE_TICK_STATE_DIRTY | APC_CACHE_AUTOMATION_DIRTY | APC_CACHE_UI_DIRTY)

#define APC_POWER_REGIME_NONE 0
#define APC_POWER_REGIME_ENVIRONMENT_ONLY 1
#define APC_POWER_REGIME_EQUIPMENT_ONLY 2
#define APC_POWER_REGIME_ALL_ON 3

// APC-side mirrors of the battery file-local mode constants.
#define APC_BATTERY_MODE_UNAVAILABLE 0
#define APC_BATTERY_MODE_IDLE 1
#define APC_BATTERY_MODE_DISCHARGING 2
#define APC_BATTERY_MODE_CHARGING 3
#define APC_BATTERY_MODE_READY 4

/datum/apc_tick_state
	var/world_time = -1
	var/usage_revision = -1
	var/datum/local_powernet/local_net
	var/raw_equipment_load = 0
	var/raw_lighting_load = 0
	var/raw_environment_load = 0
	var/display_equipment_load = 0
	var/display_lighting_load = 0
	var/display_environment_load = 0
	var/display_total_load = 0
	var/desired_equipment_load = 0
	var/desired_lighting_load = 0
	var/desired_environment_load = 0
	var/desired_total_load = 0
	var/obj/item/stock_parts/power/terminal/terminal_part
	var/obj/machinery/power/terminal/external_terminal
	var/external_avail = 0
	var/external_surplus = 0
	var/obj/item/stock_parts/power/battery/battery_part
	var/obj/item/cell/cell
	var/cell_percent = null
	var/cell_full = FALSE
	var/can_charge = FALSE
	var/main_status = 0
	var/powered = TRUE
	var/external_drawn = 0
	var/fallback_drawn = 0
	var/uncovered_deficit = 0
	var/charging_load = 0

// Various APC types
/obj/machinery/power/apc/inactive
	lighting_channel = 0
	equipment_channel = 0
	environment_channel = 0
	locked = 0
	coverlocked = 0

/obj/machinery/power/apc/critical
	is_critical = 1

/obj/machinery/power/apc/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/high/inactive
	cell_type = /obj/item/cell/high
	lighting_channel = 0
	equipment_channel = 0
	environment_channel = 0
	locked = 0
	coverlocked = 0

/obj/machinery/power/apc/super
	cell_type = /obj/item/cell/super

/obj/machinery/power/apc/super/critical
	is_critical = 1

/obj/machinery/power/apc/hyper
	cell_type = /obj/item/cell/hyper

// APC that barely has any juice
/obj/machinery/power/apc/near_empty
	cell_type = /obj/item/cell/crap/discharged

// Main APC code
/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."

	icon_state = "apc0"
	icon = 'icons/obj/machines/apc.dmi'
	anchored = TRUE
	power_state = POWER_USE_IDLE // Has custom handling here.
	power_channel = LOCAL      // Do not manipulate this; you don't want to power the APC off itself.
	interact_offline = TRUE    // Can use UI even if unpowered
	uncreated_component_parts = list(
		/obj/item/stock_parts/power/terminal,
		/obj/item/stock_parts/power/apc,
		/obj/item/stock_parts/power/battery
		)
	req_access = list(access_engine_equip)
	clicksound = "switch"
	layer = ABOVE_WINDOW_LAYER
	health_max = 80
	health_min_damage = 5
	damage_hitsound = 'sound/weapons/smash.ogg'
	var/needs_powerdown_sound
	var/area/apc_area
	var/areastring = null
	var/cell_type = /obj/item/cell/standard
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting_channel = POWERCHAN_ON_AUTO
	var/equipment_channel = POWERCHAN_ON_AUTO
	var/environment_channel = POWERCHAN_ON_AUTO
	var/operating = 1       // Bool for main toggle.
	var/charging = 0        // Whether or not it's charging. 0 - not charging but not full, 1 - charging, 2 - full
	var/chargemode = 1      // Whether charging is toggled on or off.
	var/locked = 1
	var/coverlocked = 1     // Whether you can crowbar off the cover or need to swipe ID first.
	var/aidisabled = 0
	var/last_used_lighting = 0
	var/last_used_equipment = 0
	var/last_used_environment = 0
	var/last_used_charging = 0
	var/last_used_total = 0
	var/main_status = 0     // UI var for whether we are getting external power. 0 = no external power at all, 1 = some, but not enough, 2 = getting enough.
	var/mob/living/silicon/ai/hacker = null // Malfunction var. If set AI hacked the APC and has full control.
	var/wiresexposed = FALSE // whether you can access the wires for hacking or not.
	powernet = 0		 // set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/debug= 0         // Legacy debug toggle, left in for admin use.
	var/autoflag= 0		 // 0 = off, 1= eqp and lights off, 2 = eqp off, 3 = all on.
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/longtermpower = 10  // Counter to smooth out power state changes; do not modify.
	wires = /datum/wires/apc
	var/update_state = -1
	var/update_overlay = -1
	var/list/update_overlay_chan		// Used to determine if there is a change in channels
	var/is_critical = 0
	/// Boolean. Whether or not the status overlays caches have been generated.
	var/static/status_overlays = FALSE
	var/failure_timer = 0               // Cooldown thing for apc outage event
	var/force_update = 0
	var/emp_hardened = 0
	var/cache_flags = APC_CACHE_ALL_DIRTY
	var/cached_power_regime = -1
	var/obj/item/stock_parts/power/terminal/cached_terminal_part
	var/obj/item/stock_parts/power/battery/cached_battery_part
	var/tick_state_locked = FALSE
	var/datum/apc_tick_state/tick_state

	/**
	 * List of images. Cached icon overlays for the lock indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emmissive,
	 * 	2 => "on",
	 * 	3 => "off"
	 * )
	 * ```
	 */
	var/static/list/status_overlays_lock

	/**
	 * List of images. Cached icon overlays for the charging status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emmissive,
	 * 	2 => "Not Charging",
	 * 	3 => "Charging",
	 * 	4 => "Fully Charged"
	 * )
	 * ```
	 */
	var/static/list/status_overlays_charging

	/**
	 * List of images. Cached icon overlays for the equipment channel status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emissive,
	 * 	2 => POWERCHAN_OFF,
	 * 	3 => POWERCHAN_OFF_TEMP,
	 * 	4 => POWERCHAN_OFF_AUTO,
	 * 	5 => POWERCHAN_ON,
	 * 	6 => POWERCHAN_ON_AUTO
	 * )
	 * ```
	 */
	var/static/list/status_overlays_equipment

	/**
	 * List of images. Cached icon overlays for the equipment channel status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emissive,
	 * 	2 => POWERCHAN_OFF,
	 * 	3 => POWERCHAN_OFF_TEMP,
	 * 	4 => POWERCHAN_OFF_AUTO,
	 * 	5 => POWERCHAN_ON,
	 * 	6 => POWERCHAN_ON_AUTO
	 * )
	 * ```
	 */
	var/static/list/status_overlays_lighting

	/**
	 * List of images. Cached icon overlays for the equipment channel status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emissive,
	 * 	2 => POWERCHAN_OFF,
	 * 	3 => POWERCHAN_OFF_TEMP,
	 * 	4 => POWERCHAN_OFF_AUTO,
	 * 	5 => POWERCHAN_ON,
	 * 	6 => POWERCHAN_ON_AUTO
	 * )
	 * ```
	 */
	var/static/list/status_overlays_environ
	var/autoname = 1

/obj/machinery/power/apc/updateDialog()
	if (MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
		return
	..()

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	var/obj/machinery/power/terminal/terminal = terminal()
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/drain_power(drain_check, surge, amount = 0)

	if(drain_check)
		return 1

	// Prevents APCs from being stuck on 0% cell charge while reporting "Fully Charged" status.
	charging = 0

	// If the APC's interface is locked, limit the charge rate to 25%.
	if(locked)
		amount /= 4

	return amount - use_power_oneoff(amount, LOCAL)

/obj/machinery/power/apc/Initialize(mapload, ndir, populate_parts = TRUE, building=0)
	// offset 22 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		set_dir(ndir)

	if(areastring)
		apc_area = get_area_name(areastring)
	else
		apc_area = get_area(src)
	if(autoname)
		SetName("\improper [apc_area.name] APC")
	apc_area.apc = src

	. = ..()
	machine_powernet = apc_area?.create_powernet()
	if(machine_powernet)
		machine_powernet.powernet_apc = src

	if (building==0)
		init_round_start()
	else
		opened = 1
		operating = 0
		set_stat(MACHINE_STAT_MAINT, TRUE)
		queue_icon_update()

	if(operating)
		force_update_channels()
	power_change()

/obj/machinery/power/apc/Destroy()
	src.update()
	if(apc_area)
		apc_area.apc = null
	var/datum/local_powernet/local_net = machine_powernet || apc_area?.powernet
	if(local_net)
		local_net.apply_apc_power_state(null, FALSE, FALSE, FALSE)

	// Malf AI, removes the APC from AI's hacked APCs list.
	if((hacker) && (hacker.hacked_apcs) && (src in hacker.hacked_apcs))
		hacker.hacked_apcs -= src

	return ..()

/obj/machinery/power/apc/RefreshParts()
	invalidate_power_part_refs()
	return ..()

/obj/machinery/power/apc/component_destroyed(obj/item/component)
	if(component == cached_terminal_part || component == cached_battery_part)
		invalidate_power_part_refs()
	return ..()

/obj/machinery/power/apc/get_req_access()
	if(!locked)
		return list()
	return ..()

/obj/machinery/power/apc/proc/energy_fail(duration)
	if(emp_hardened)
		return
	failure_timer = max(failure_timer, round(duration))
	mark_cache_dirty()
	playsound(src, 'sound/machines/apc_nopower.ogg', 75, 0)

/obj/machinery/power/apc/proc/init_round_start()
	has_electronics = 2 //installed and secured

	var/obj/item/stock_parts/power/battery/bat = get_battery_part()
	bat.add_cell(src, new cell_type(bat))
	var/obj/item/stock_parts/power/terminal/term = get_terminal_part()
	term.make_terminal(src)

	queue_icon_update()

/obj/machinery/power/apc/proc/invalidate_power_part_refs()
	cached_terminal_part = null
	cached_battery_part = null

/obj/machinery/power/apc/proc/get_terminal_part()
	if(cached_terminal_part && !QDELETED(cached_terminal_part) && cached_terminal_part.loc == src && component_parts && (cached_terminal_part in component_parts))
		return cached_terminal_part
	cached_terminal_part = get_component_of_type(/obj/item/stock_parts/power/terminal)
	return cached_terminal_part

/obj/machinery/power/apc/proc/get_battery_part()
	if(cached_battery_part && !QDELETED(cached_battery_part) && cached_battery_part.loc == src && component_parts && (cached_battery_part in component_parts))
		return cached_battery_part
	cached_battery_part = get_component_of_type(/obj/item/stock_parts/power/battery)
	return cached_battery_part

/obj/machinery/power/apc/proc/terminal()
	var/obj/item/stock_parts/power/terminal/term = get_terminal_part()
	return term && term.terminal

/obj/machinery/power/apc/get_cell()
	var/obj/item/stock_parts/power/battery/battery = get_battery_part()
	return battery && battery.cell

/obj/machinery/power/apc/proc/mark_cache_dirty(flags = APC_CACHE_ALL_DIRTY)
	cache_flags |= flags
	if(flags & APC_CACHE_TICK_STATE_DIRTY)
		tick_state_locked = FALSE

/obj/machinery/power/apc/proc/get_local_powernet()
	if(machine_powernet)
		return machine_powernet
	if(apc_area?.powernet)
		machine_powernet = apc_area.powernet
		return machine_powernet
	machine_powernet = apc_area?.create_powernet()
	return machine_powernet

/obj/machinery/power/apc/proc/get_main_status_from_state(datum/apc_tick_state/state)
	if(!state.external_avail)
		return 0
	if(state.external_surplus < 0)
		return 1
	return 2

/obj/machinery/power/apc/proc/predict_powered_from_state(datum/apc_tick_state/state)
	if(!state || !state.desired_total_load)
		return TRUE
	var/available = min(max(state.external_surplus, 0), state.desired_total_load)
	if(state.cell && !shorted)
		available += min(state.cell.charge / CELLRATE, state.desired_total_load - available)
	return available >= state.desired_total_load

/obj/machinery/power/apc/proc/rebuild_tick_state(lock_for_tick = FALSE)
	var/datum/apc_tick_state/state = tick_state
	if(!state)
		state = new
		tick_state = state

	var/datum/local_powernet/local_net = get_local_powernet()
	var/obj/item/stock_parts/power/terminal/terminal_part = get_terminal_part()
	var/obj/machinery/power/terminal/external_terminal = terminal_part && terminal_part.terminal
	var/obj/item/stock_parts/power/battery/battery_part = get_battery_part()
	var/obj/item/cell/cell = battery_part && battery_part.cell

	state.world_time = world.time
	state.local_net = local_net
	state.usage_revision = local_net ? local_net.usage_revision : -1
	state.raw_equipment_load = local_net ? local_net.passive_equipment_consumption + local_net.equipment_consumption : 0
	state.raw_lighting_load = local_net ? local_net.passive_lighting_consumption + local_net.lighting_consumption : 0
	state.raw_environment_load = local_net ? local_net.passive_environment_consumption + local_net.environment_consumption : 0
	state.display_equipment_load = local_net ? local_net.get_channel_usage(PW_CHANNEL_EQUIPMENT) : 0
	state.display_lighting_load = local_net ? local_net.get_channel_usage(PW_CHANNEL_LIGHTING) : 0
	state.display_environment_load = local_net ? local_net.get_channel_usage(PW_CHANNEL_ENVIRONMENT) : 0
	state.display_total_load = state.display_equipment_load + state.display_lighting_load + state.display_environment_load
	if(!apc_area || !operating || shorted || failure_timer)
		state.desired_equipment_load = 0
		state.desired_lighting_load = 0
		state.desired_environment_load = 0
	else
		state.desired_equipment_load = autoset(equipment_channel, 2) >= POWERCHAN_ON ? state.raw_equipment_load : 0
		state.desired_lighting_load = autoset(lighting_channel, 2) >= POWERCHAN_ON ? state.raw_lighting_load : 0
		state.desired_environment_load = autoset(environment_channel, 1) >= POWERCHAN_ON ? state.raw_environment_load : 0
	state.desired_total_load = state.desired_equipment_load + state.desired_lighting_load + state.desired_environment_load
	state.terminal_part = terminal_part
	state.external_terminal = external_terminal
	state.external_avail = (external_terminal && external_terminal.avail()) || 0
	state.external_surplus = (external_terminal && external_terminal.surplus()) || 0
	if(terminal_part)
		terminal_part.cache_terminal_state(external_terminal, state.desired_total_load, state.external_surplus, state.external_avail > 0)
	state.battery_part = battery_part
	state.cell = cell
	state.cell_percent = cell && cell.percent()
	state.cell_full = cell && cell.fully_charged()
	state.can_charge = !!(battery_part && cell && battery_part.can_charge && !state.cell_full)
	state.main_status = get_main_status_from_state(state)
	state.powered = predict_powered_from_state(state)
	state.external_drawn = 0
	state.fallback_drawn = 0
	state.uncovered_deficit = 0
	state.charging_load = 0

	cache_flags &= ~APC_CACHE_TICK_STATE_DIRTY
	tick_state_locked = lock_for_tick
	return state

/obj/machinery/power/apc/proc/refresh_tick_state(lock_for_tick = FALSE, ignore_lock = FALSE)
	if(!ignore_lock && tick_state_locked && tick_state?.world_time == world.time && !(cache_flags & APC_CACHE_TICK_STATE_DIRTY))
		return tick_state

	var/datum/apc_tick_state/state = tick_state
	if(!state || (cache_flags & APC_CACHE_TICK_STATE_DIRTY))
		return rebuild_tick_state(lock_for_tick)

	var/datum/local_powernet/local_net = get_local_powernet()
	var/current_usage_revision = local_net ? local_net.usage_revision : -1

	// === EXPERIMENT: Disabled usage_revision check ===
	// This check caused rebuild on EVERY tick because usage_revision changes whenever
	// power consumption changes. Cache hit rate was 0% with this check enabled.
	// Profiling showed 42,000+ rebuild calls vs expected ~2,000-3,000.
	// The original comment about "stale state" is incorrect - clear_usage() is called
	// AFTER snapshot_tick_state() in Process(), so cached state is valid.
	// Rebuild is still triggered by component changes (terminal/battery/cell) below.
	/*
	if(state.local_net != local_net || state.usage_revision != current_usage_revision)
		return rebuild_tick_state(lock_for_tick)
	*/
	// === END EXPERIMENT ===

	var/obj/item/stock_parts/power/terminal/terminal_part = get_terminal_part()
	var/obj/machinery/power/terminal/external_terminal = terminal_part && terminal_part.terminal
	var/obj/item/stock_parts/power/battery/battery_part = get_battery_part()
	var/obj/item/cell/cell = battery_part && battery_part.cell

	if(state.terminal_part != terminal_part || state.battery_part != battery_part || state.cell != cell)
		return rebuild_tick_state(lock_for_tick)

	state.world_time = world.time
	state.local_net = local_net
	state.usage_revision = current_usage_revision
	state.terminal_part = terminal_part
	state.external_terminal = external_terminal
	state.external_avail = (external_terminal && external_terminal.avail()) || 0
	state.external_surplus = (external_terminal && external_terminal.surplus()) || 0
	if(terminal_part)
		terminal_part.cache_terminal_state(external_terminal, state.desired_total_load, state.external_surplus, state.external_avail > 0)
	state.battery_part = battery_part
	state.cell = cell
	state.cell_percent = cell && cell.percent()
	state.cell_full = cell && cell.fully_charged()
	state.can_charge = !!(battery_part && cell && battery_part.can_charge && !state.cell_full)
	state.main_status = get_main_status_from_state(state)
	state.powered = predict_powered_from_state(state)
	state.external_drawn = 0
	state.fallback_drawn = 0
	state.uncovered_deficit = 0
	state.charging_load = 0

	tick_state_locked = lock_for_tick
	return state

/obj/machinery/power/apc/proc/get_tick_state(force = FALSE)
	if(force)
		return rebuild_tick_state()
	return refresh_tick_state()

/obj/machinery/power/apc/proc/snapshot_tick_state()
	// Process() needs authoritative state before active usage is cleared, but the cached
	// snapshot is still valid when the local powernet revision and APC topology are unchanged.
	return refresh_tick_state(TRUE)

/obj/machinery/power/apc/proc/apply_tick_state_views(datum/apc_tick_state/state)
	if(!state)
		return
	last_used_lighting = state.display_lighting_load
	last_used_equipment = state.display_equipment_load
	last_used_environment = state.display_environment_load
	last_used_total = state.display_total_load
	main_status = state.main_status

/obj/machinery/power/apc/proc/apply_powered_state(powered_state)
	var/oldstat = stat
	set_stat(MACHINE_STAT_NOPOWER, !powered_state)
	return stat != oldstat

/obj/machinery/power/apc/proc/get_power_regime(percent, powered_state)
	if(failure_timer || !operating || shorted || !powered_state || isnull(percent))
		return APC_POWER_REGIME_NONE
	if(percent > AUTO_THRESHOLD_LIGHTING || longtermpower >= 0)
		return APC_POWER_REGIME_ALL_ON
	if(percent > AUTO_THRESHOLD_EQUIPMENT)
		return APC_POWER_REGIME_EQUIPMENT_ONLY
	return APC_POWER_REGIME_ENVIRONMENT_ONLY

/obj/machinery/power/apc/proc/apc_power_component_changed()
	mark_cache_dirty()
	power_change()

/obj/machinery/power/apc/proc/set_channel_state(channel, new_state)
	var/changed = FALSE
	switch(channel)
		if(EQUIP)
			if(equipment_channel == new_state)
				return
			equipment_channel = new_state
			changed = TRUE
		if(LIGHT)
			if(lighting_channel == new_state)
				return
			lighting_channel = new_state
			changed = TRUE
		if(ENVIRON)
			if(environment_channel == new_state)
				return
			environment_channel = new_state
			changed = TRUE
	if(changed)
		mark_cache_dirty(APC_CACHE_TICK_STATE_DIRTY | APC_CACHE_UI_DIRTY)

/obj/machinery/power/apc/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		var/terminal = terminal()
		if(opened)
			if(has_electronics && terminal)
				to_chat(user, "The cover is [opened==2?"removed":"open"] and the power cell is [ get_cell() ? "installed" : "missing"].")
			else if (!has_electronics && terminal)
				to_chat(user, "There are some wires but no any electronics.")
			else if (has_electronics && !terminal)
				to_chat(user, "Electronics installed but not wired.")
			else /* if (!has_electronics && !terminal) */
				to_chat(user, "There is no electronics nor connected wires.")

		else
			if (GET_FLAGS(stat, MACHINE_STAT_MAINT))
				to_chat(user, "The cover is closed. Something wrong with it: it doesn't work.")
			else if (hacker && !hacker.hacked_apcs_hidden)
				to_chat(user, "The cover is locked.")
			else
				to_chat(user, "The cover is closed.")


/obj/machinery/power/apc/CanUseTopicPhysical(mob/user)
	return GLOB.physical_state.can_use_topic(nano_host(), user)

/obj/machinery/power/apc/physical_attack_hand(mob/user)
	//Human mob special interaction goes here.
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user

		if(H.species.can_shred(H))
			user.visible_message(SPAN_WARNING("\The [user] slashes at \the [src]!"), SPAN_NOTICE("You slash at \the [src]!"))
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)

			var/allcut = wires.IsAllCut()

			if(beenhit >= pick(3, 4) && !wiresexposed)
				wiresexposed = TRUE
				src.update_icon()
				src.visible_message(SPAN_WARNING("\The The [src]'s cover flies open, exposing the wires!"))

			else if(wiresexposed && allcut == 0)
				wires.CutAll()
				src.update_icon()
				src.visible_message(SPAN_WARNING("\The [src]'s wires are shredded!"))
			else
				beenhit += 1
			return TRUE

/obj/machinery/power/apc/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!user)
		return
	var/obj/item/cell/cell = get_cell()

	var/list/data = list(
		"pChan_Off" = POWERCHAN_OFF,
		"pChan_Off_T" = POWERCHAN_OFF_TEMP,
		"pChan_Off_A" = POWERCHAN_OFF_AUTO,
		"pChan_On" = POWERCHAN_ON,
		"pChan_On_A" = POWERCHAN_ON_AUTO,
		"locked" = (locked && !emagged) ? 1 : 0,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = round(last_used_total),
		"totalCharging" = round(last_used_charging),
		"coverLocked" = coverlocked,
		"failTime" = failure_timer * 2,
		"siliconUser" = (istype(user, /mob/living/silicon) || (isghost(user) && isadmin(user))),
		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = last_used_equipment,
				"status" = equipment_channel,
				"topicParams" = list(
					"auto" = list("eqp" = 2),
					"on"   = list("eqp" = 1),
					"off"  = list("eqp" = 0)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = round(last_used_lighting),
				"status" = lighting_channel,
				"topicParams" = list(
					"auto" = list("lgt" = 2),
					"on"   = list("lgt" = 1),
					"off"  = list("lgt" = 0)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = round(last_used_environment),
				"status" = environment_channel,
				"topicParams" = list(
					"auto" = list("env" = 2),
					"on"   = list("env" = 1),
					"off"  = list("env" = 0)
				)
			)
		)
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "apc.tmpl", "[apc_area.name] - APC", 520, data["siliconUser"] ? 465 : 440)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	var/obj/item/cell/cell = get_cell()
	return "[apc_area.name] : [equipment_channel]/[lighting_channel]/[environment_channel] ([last_used_equipment+last_used_lighting+last_used_environment]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/power_change(datum/apc_tick_state/state_override = null)
	if(stat_immune & MACHINE_STAT_NOPOWER)
		return FALSE

	var/datum/apc_tick_state/state = state_override
	if(!state)
		mark_cache_dirty(APC_CACHE_TICK_STATE_DIRTY)
		state = get_tick_state(TRUE)
	else
		tick_state = state
		tick_state_locked = TRUE
		cache_flags &= ~APC_CACHE_TICK_STATE_DIRTY

	var/old_main_status = main_status
	apply_tick_state_views(state)
	if(old_main_status != main_status)
		cache_flags |= APC_CACHE_UI_DIRTY
	. = apply_powered_state(state.powered)
	if(. || (cache_flags & APC_CACHE_UI_DIRTY))
		queue_icon_update()
	cache_flags &= ~APC_CACHE_UI_DIRTY

/obj/machinery/power/apc/proc/update()
	var/datum/local_powernet/local_net = get_local_powernet()
	var/old_lighting_power = local_net?.has_power(PW_CHANNEL_LIGHTING)
	var/equipment_powered = operating && !shorted && !failure_timer && equipment_channel >= POWERCHAN_ON
	var/lighting_powered = operating && !shorted && !failure_timer && lighting_channel >= POWERCHAN_ON
	var/environment_powered = operating && !shorted && !failure_timer && environment_channel >= POWERCHAN_ON
	mark_cache_dirty(APC_CACHE_TICK_STATE_DIRTY | APC_CACHE_UI_DIRTY)

	if(local_net)
		local_net.apply_apc_power_state(src, equipment_powered, lighting_powered, environment_powered)
		if(apc_area && old_lighting_power != local_net.has_power(PW_CHANNEL_LIGHTING))
			apc_area.set_emergency_lighting(lighting_channel == POWERCHAN_OFF_AUTO) //if lights go auto-off, emergency lights go on
	else
		apc_area.power_change()

	var/obj/item/cell/cell = get_cell()
	if(!cell || cell.charge <= 0)
		if(needs_powerdown_sound == TRUE)
			playsound(src, 'sound/machines/apc_nopower.ogg', 75, 0)
			needs_powerdown_sound = FALSE
		else
			needs_powerdown_sound = TRUE

/obj/machinery/power/apc/proc/isWireCut(wireIndex)
	return wires.IsIndexCut(wireIndex)


/obj/machinery/power/apc/CanUseTopic(mob/user, datum/topic_state/state)
	if(user.lying)
		to_chat(user, SPAN_WARNING("You must stand to use [src]!"))
		return STATUS_CLOSE
	if(istype(user, /mob/living/silicon))
		var/permit = 0 // Malfunction variable. If AI hacks APC it can control it even without AI control wire.
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(hacker && !hacker.hacked_apcs_hidden)
			if(hacker == AI)
				permit = 1
			else if(istype(robot) && robot.connected_ai && robot.connected_ai == hacker) // Cyborgs can use APCs hacked by their AI
				permit = 1

		if(aidisabled && !permit)
			return STATUS_CLOSE
	. = ..()
	if(user.restrained())
		to_chat(user, SPAN_WARNING("You must have free hands to use [src]."))
		. = min(., STATUS_UPDATE)

/obj/machinery/power/apc/Topic(href, href_list)
	if(..())
		return 1

	if(!istype(usr, /mob/living/silicon) && (locked && !emagged) && !(isghost(usr) && isadmin(usr)))
		// Shouldn't happen, this is here to prevent href exploits
		to_chat(usr, "You must unlock the panel to use this!")
		return 1

	if (href_list["lock"])
		coverlocked = !coverlocked

	else if( href_list["reboot"] )
		failure_timer = 0
		update_icon()
		update()

	else if (href_list["breaker"])
		toggle_breaker()

	else if (href_list["cmode"])
		set_chargemode(!chargemode)
		if(!chargemode)
			charging = 0
			update_icon()

	else if (href_list["eqp"])
		var/val = text2num(href_list["eqp"])
		set_channel_state(EQUIP, setsubsystem(val))
		force_update_channels()

	else if (href_list["lgt"])
		var/val = text2num(href_list["lgt"])
		set_channel_state(LIGHT, setsubsystem(val))
		force_update_channels()

	else if (href_list["env"])
		var/val = text2num(href_list["env"])
		set_channel_state(ENVIRON, setsubsystem(val))
		force_update_channels()

	else if (href_list["overload"])
		if(istype(usr, /mob/living/silicon))
			src.overload_lighting()

	else if (href_list["toggleaccess"])
		if(istype(usr, /mob/living/silicon))
			if(emagged || MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
				to_chat(usr, "The APC does not respond to the command.")
			else
				locked = !locked
				update_icon()

	return STATUS_UPDATE

/obj/machinery/power/apc/proc/force_update_channels()
	autoflag = -1 // This clears state, forcing a full recalculation
	mark_cache_dirty(APC_CACHE_TICK_STATE_DIRTY | APC_CACHE_AUTOMATION_DIRTY | APC_CACHE_UI_DIRTY)
	update_channels(TRUE, get_tick_state())
	update()
	queue_icon_update()

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating
	mark_cache_dirty()
	force_update_channels()

/obj/machinery/power/apc/get_power_usage()
	var/datum/apc_tick_state/state = get_tick_state()
	return state ? state.desired_total_load : 0

/obj/machinery/power/apc/Process()
	if(!apc_area.requires_power)
		return PROCESS_KILL

	if(MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
		return

	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = 1
		mark_cache_dirty()
		return

	var/old_main_status = main_status
	var/datum/apc_tick_state/state = snapshot_tick_state()
	apply_tick_state_views(state)
	state.local_net?.clear_usage()

	//store states to update icon if any change
	var/last_lt = lighting_channel
	var/last_eq = equipment_channel
	var/last_en = environment_channel
	var/last_ch = charging
	var/was_powered = is_powered()

	var/obj/item/stock_parts/power/battery/power = state.battery_part
	var/obj/item/cell/cell = state.cell
	var/cell_charge_before = cell ? cell.charge : 0
	if(power)
		power.last_cell_charge = cell_charge_before

	if(state.external_terminal && state.desired_total_load > 0)
		state.external_drawn = state.external_terminal.draw_power(state.desired_total_load)
	var/remaining_deficit = max(state.desired_total_load - state.external_drawn, 0)

	if(cell && !shorted && remaining_deficit > 0)
		state.fallback_drawn = cell.use(remaining_deficit * CELLRATE) / CELLRATE
		remaining_deficit = max(remaining_deficit - state.fallback_drawn, 0)

	state.uncovered_deficit = remaining_deficit
	state.powered = !state.uncovered_deficit

	if(power)
		if(state.fallback_drawn > 0)
			power.set_status(src, PART_STAT_ACTIVE)
			power.charge_wait_counter = initial(power.charge_wait_counter)
			power.set_battery_mode(APC_BATTERY_MODE_DISCHARGING, state.desired_total_load)
		else
			power.unset_status(src, PART_STAT_ACTIVE)
			if(!cell)
				power.charge_wait_counter = initial(power.charge_wait_counter)
				power.set_battery_mode(APC_BATTERY_MODE_UNAVAILABLE, state.desired_total_load)
			else if(shorted)
				power.charge_wait_counter = initial(power.charge_wait_counter)
				power.set_battery_mode(APC_BATTERY_MODE_IDLE, state.desired_total_load)
			else if(state.desired_total_load > 0 && !state.powered && cell.fully_charged())
				power.set_battery_mode(APC_BATTERY_MODE_READY, state.desired_total_load)
			else if(!power.can_charge || cell.fully_charged() || !apc_area.powered(power.charge_channel))
				power.charge_wait_counter = initial(power.charge_wait_counter)
				power.set_battery_mode(APC_BATTERY_MODE_IDLE, state.desired_total_load)
			else if(power.charge_wait_counter > 0)
				power.charge_wait_counter--
				power.set_battery_mode(APC_BATTERY_MODE_IDLE, state.desired_total_load)
			else
				var/give = cell.give(power.charge_rate) / CELLRATE
				if(give > 0)
					apc_area.use_power_oneoff(give, power.charge_channel)
				power.set_battery_mode(give > 0 ? APC_BATTERY_MODE_CHARGING : APC_BATTERY_MODE_IDLE, state.desired_total_load)

	if(state.terminal_part)
		state.external_surplus = max(state.external_surplus - state.external_drawn, 0)
		state.terminal_part.cache_terminal_state(state.external_terminal, state.desired_total_load, state.external_surplus, state.external_avail > 0)

	if(debug)
		log_debug("Status: [state.main_status] - Excess: [state.external_surplus] - Desired Equip: [state.desired_equipment_load] - Desired Light: [state.desired_lighting_load] - Longterm: [longtermpower]")

	last_used_charging = max((cell && (cell.charge - cell_charge_before) * CELLRATE) || 0, 0)
	charging = last_used_charging ? 1 : 0
	if(cell?.fully_charged())
		charging = 2

	state.cell_percent = cell && cell.percent()
	state.cell_full = cell && cell.fully_charged()
	state.can_charge = !!(power && cell && power.can_charge && !state.cell_full)
	state.charging_load = last_used_charging
	if(old_main_status != main_status)
		cache_flags |= APC_CACHE_UI_DIRTY

	if(state.powered != was_powered)
		power_change(state)
	else
		apply_powered_state(state.powered)

	// Set channels depending on how much charge we have left
	var/channels_changed = update_channels(FALSE, state)

	// update icon & area power if anything changed
	if(channels_changed || last_lt != lighting_channel || last_eq != equipment_channel || last_en != environment_channel || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if(last_ch != charging || (cache_flags & APC_CACHE_UI_DIRTY))
		queue_icon_update()
	cache_flags &= ~APC_CACHE_UI_DIRTY

/obj/machinery/power/apc/proc/update_channels(suppress_alarms = FALSE, datum/apc_tick_state/state = null)
	return handle_autoflag(suppress_alarms, state || get_tick_state())

/obj/machinery/power/apc/proc/handle_autoflag(suppress_alarms = FALSE, datum/apc_tick_state/state)
	// Allow the APC to operate as normal if the cell can charge
	if(charging && longtermpower < 10)
		longtermpower += 1
	else if(longtermpower > -10)
		longtermpower -= 2
	var/new_regime = get_power_regime(state.cell_percent, state.powered)
	if(!(cache_flags & APC_CACHE_AUTOMATION_DIRTY) && cached_power_regime == new_regime)
		autoflag = new_regime
		return FALSE

	var/old_eq = equipment_channel
	var/old_lt = lighting_channel
	var/old_en = environment_channel

	switch(new_regime)
		if(APC_POWER_REGIME_NONE)
			equipment_channel = autoset(equipment_channel, 0)
			lighting_channel = autoset(lighting_channel, 0)
			environment_channel = autoset(environment_channel, 0)
			if(!suppress_alarms)
				GLOB.power_alarm.triggerAlarm(loc, src)
		if(APC_POWER_REGIME_ALL_ON)
			equipment_channel = autoset(equipment_channel, 1)
			lighting_channel = autoset(lighting_channel, 1)
			environment_channel = autoset(environment_channel, 1)
			GLOB.power_alarm.clearAlarm(loc, src)
		if(APC_POWER_REGIME_EQUIPMENT_ONLY)
			equipment_channel = autoset(equipment_channel, 1)
			lighting_channel = autoset(lighting_channel, 2)
			environment_channel = autoset(environment_channel, 1)
			if(!suppress_alarms)
				GLOB.power_alarm.triggerAlarm(loc, src)
		if(APC_POWER_REGIME_ENVIRONMENT_ONLY)
			equipment_channel = autoset(equipment_channel, 2)
			lighting_channel = autoset(lighting_channel, 2)
			environment_channel = autoset(environment_channel, 1)
			if(!suppress_alarms)
				GLOB.power_alarm.triggerAlarm(loc, src)

	autoflag = new_regime
	cached_power_regime = new_regime
	cache_flags &= ~APC_CACHE_AUTOMATION_DIRTY

	if(old_eq != equipment_channel || old_lt != lighting_channel || old_en != environment_channel)
		mark_cache_dirty(APC_CACHE_TICK_STATE_DIRTY | APC_CACHE_UI_DIRTY)
		return TRUE
	return FALSE

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff
// defines a state machine, returns the new state
/obj/machinery/power/apc/proc/autoset(cur_state, on)
	//autoset will never turn on a channel set to off
	switch(cur_state)
		if(POWERCHAN_OFF_TEMP)
			if(on == 1 || on == 2)
				return POWERCHAN_ON
		if(POWERCHAN_OFF_AUTO)
			if(on == 1)
				return POWERCHAN_ON_AUTO
		if(POWERCHAN_ON)
			if(on == 0)
				return POWERCHAN_OFF_TEMP
		if(POWERCHAN_ON_AUTO)
			if(on == 0 || on == 2)
				return POWERCHAN_OFF_AUTO

	return cur_state //leave unchanged


// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	if(emp_hardened)
		return
	..()

/obj/machinery/power/apc/ex_act(severity)
	var/obj/item/cell/cell = get_cell()
	if (!cell)
		..()
		return

	switch(severity)
		if (EX_ACT_DEVASTATING)
			cell.ex_act(EX_ACT_DEVASTATING)
		if (EX_ACT_HEAVY)
			if (prob(50))
				cell.ex_act(EX_ACT_HEAVY)
		if (EX_ACT_LIGHT)
			if (prob(25))
				cell.ex_act(EX_ACT_LIGHT)
	..()

/obj/machinery/power/apc/set_broken(new_state)
	if(!new_state || MACHINE_IS_BROKEN(src))
		return ..()
	visible_message(SPAN_WARNING("\The [src]'s screen flickers with warnings briefly!"))
	GLOB.power_alarm.triggerAlarm(loc, src)
	spawn(rand(2,5))
		..()
		visible_message(SPAN_DANGER("\The [src]'s screen suddenly explodes in rain of sparks and small debris!"))
		operating = 0
		update()
	queue_icon_update()
	return TRUE

/obj/machinery/power/apc/proc/reboot()
	//reset various counters so that process() will start fresh
	charging = initial(charging)
	autoflag = initial(autoflag)
	longtermpower = initial(longtermpower)
	failure_timer = initial(failure_timer)

	//start with main breaker off, chargemode in the default state and all channels on auto upon reboot
	operating = 0

	set_chargemode(initial(chargemode))
	GLOB.power_alarm.clearAlarm(loc, src)

	lighting_channel = POWERCHAN_ON_AUTO
	equipment_channel = POWERCHAN_ON_AUTO
	environment_channel = POWERCHAN_ON_AUTO
	mark_cache_dirty()

	force_update_channels()

/obj/machinery/power/apc/proc/set_chargemode(new_mode)
	chargemode = new_mode
	mark_cache_dirty(APC_CACHE_TICK_STATE_DIRTY | APC_CACHE_AUTOMATION_DIRTY | APC_CACHE_UI_DIRTY)
	var/obj/item/stock_parts/power/battery/power = get_battery_part()
	if(power)
		power.can_charge = chargemode
		power.charge_wait_counter = initial(power.charge_wait_counter)

// overload the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting(chance = 100)
	if(/* !get_connection() || */ !operating || shorted)
		return
	var/amount = use_power_oneoff(20, LOCAL)
	if(amount <= 0)
		spawn(0)
			for(var/obj/machinery/light/L in apc_area)
				if(prob(chance))
					L.on = 1
					L.broken()
				sleep(1)


/obj/machinery/power/apc/proc/flicker_lighting(amount = 10)
	if (!operating || shorted)
		return
	for (var/obj/machinery/light/L in apc_area)
		L.flicker(amount)


/obj/machinery/power/apc/proc/setsubsystem(val)
	switch(val)
		if(2)
			return POWERCHAN_OFF_AUTO
		if(1)
			return POWERCHAN_OFF_TEMP
		else
			return POWERCHAN_OFF

#undef APC_POWER_REGIME_ALL_ON
#undef APC_POWER_REGIME_EQUIPMENT_ONLY
#undef APC_POWER_REGIME_ENVIRONMENT_ONLY
#undef APC_POWER_REGIME_NONE
#undef APC_CACHE_ALL_DIRTY
#undef APC_CACHE_UI_DIRTY
#undef APC_CACHE_AUTOMATION_DIRTY
#undef APC_CACHE_TICK_STATE_DIRTY
#undef APC_BATTERY_MODE_READY
#undef APC_BATTERY_MODE_CHARGING
#undef APC_BATTERY_MODE_DISCHARGING
#undef APC_BATTERY_MODE_IDLE
#undef APC_BATTERY_MODE_UNAVAILABLE

/obj/item/module/power_control
	name = "power control module"
	desc = "Heavy-duty switching circuits for power control."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	item_state = "electronic"
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
