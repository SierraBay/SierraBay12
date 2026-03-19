/*
This is /obj/machinery level code to properly manage power usage from the area.
*/

// Note that we update the area even if the area is unpowered.
#define REPORT_POWER_CONSUMPTION_CHANGE(old_power, new_power)\
	if(old_power != new_power){\
		var/area/A = get_area(src);\
		if(A) A.power_use_change(old_power, new_power, power_channel)}

/**
 * Returns `TRUE` if the area has power on given channel (or doesn't require power), defaults to `power_channel`.
 * May also optionally specify an area, otherwise defaults to `loc.loc`.
 */
/obj/machinery/proc/powered(chan = POWER_CHAN, area/check_area = null)
	if(!requires_power)
		return TRUE

	if(!loc)
		return FALSE

	//Don't do this. It allows machines that set power_state to 0 when off (many machines) to
	//be turned on again and used after a power failure because they never gain the MACHINE_STAT_NOPOWER flag.
	//if(!power_state)
	//	return 1

	if(!check_area)
		check_area = get_area(src)	// make sure it's in an area
	if(!check_area || !isarea(check_area))
		return FALSE					// if not, then not powered
	if(chan == POWER_CHAN)
		chan = power_channel
	return check_area.powered(chan)			// return power status of the area

// called whenever the power settings of the containing area change
// by default, check equipment channel & set flag can override if needed
// This is NOT for when the machine's own status changes; use change_power_mode for that.
/obj/machinery/proc/power_change()
	if(stat_immune & MACHINE_STAT_NOPOWER)
		return FALSE
	var/oldstat = stat
	set_stat(MACHINE_STAT_NOPOWER, TRUE)
	for(var/thing in power_components)
		var/obj/item/stock_parts/power/power = thing
		if((!is_powered()) && power.can_provide_power(src))
			set_stat(MACHINE_STAT_NOPOWER, FALSE)
		else
			power.not_needed(src)

	. = (stat != oldstat)
	if(.)
		queue_icon_update()

/// Returns the current power usage draw, based on the state of `power_state`.
/obj/machinery/proc/get_power_usage()
	switch(power_state)
		if(POWER_USE_IDLE)
			return idle_power_consumption
		if(POWER_USE_ACTIVE)
			return active_power_consumption
		else
			return 0

/**
 *  This will have this machine have its area eat this much power next tick, and not afterwards. Do not use for continued power draw.
 * `chan` can be one of the possible values for `power_channel`, or `POWER_CHAN` to use the machine's current configured power channel.
 */
/obj/machinery/proc/use_power_oneoff(amount, chan = POWER_CHAN)
	if(chan == POWER_CHAN)
		chan = power_channel
	. = amount
	for(var/thing in power_components)
		var/obj/item/stock_parts/power/power = thing
		var/used = power.use_power_oneoff(src, ., chan)
		. -= used
		if(. <= 0)
			return

// Same as `use_power_oneoff()`, but dry run; doesn't actually do it. Useful for pre-operation checks.
/obj/machinery/proc/can_use_power_oneoff(amount, chan = POWER_CHAN)
	if(chan == POWER_CHAN)
		chan = power_channel
	. = amount
	for(var/thing in power_components)
		var/obj/item/stock_parts/power/power = thing
		var/used = power.can_use_power_oneoff(src, ., chan)
		. -= used
		if(. <= 0)
			return

// Do not do power stuff in New/Initialize until after ..()
/obj/machinery/Initialize()
	REPORT_POWER_CONSUMPTION_CHANGE(0, get_power_usage())
	GLOB.moved_event.register(src, src, PROC_REF(update_power_on_move))
	power_init_complete = TRUE
	. = ..()
	var/area/A = get_area(src)
	if(A)
		var/datum/local_powernet/local_net = A.create_powernet()
		local_net.register_machine(src)

// Or in Destroy at all, but especially after the ..().
/obj/machinery/Destroy()
	GLOB.moved_event.unregister(src, src, PROC_REF(update_power_on_move))
	machine_powernet?.unregister_machine(src)
	REPORT_POWER_CONSUMPTION_CHANGE(get_power_usage(), 0)
	. = ..()

/// Handles updating machinery power whenever the machine is moved. Calls `area_changed()` by default.
/obj/machinery/proc/update_power_on_move(atom/movable/mover, atom/old_loc, atom/new_loc)
	area_changed(get_area(old_loc), get_area(new_loc))

/// Handles machinery power updates if the area the machine is in changes. Called by `update_power_on_move()`.
/obj/machinery/proc/area_changed(area/old_area, area/new_area)
	if(old_area == new_area)
		return
	var/power = get_power_usage()
	if(!power)
		if(old_area?.powernet)
			old_area.powernet.unregister_machine(src)
		if(new_area)
			var/datum/local_powernet/new_local_net = new_area.create_powernet()
			new_local_net.register_machine(src)
		power_change()
		return // This is the most likely case anyway.

	if(old_area)
		old_area.power_use_change(power, 0, power_channel)
		old_area.powernet?.unregister_machine(src)
	if(new_area)
		var/datum/local_powernet/new_local_net = new_area.create_powernet()
		new_local_net.register_machine(src)
		new_area.power_use_change(0, power, power_channel)
	power_change() // Force check in case the old area was powered and the new one isn't or vice versa.

// The three procs below are the only allowed ways of modifying the corresponding variables.
/// Updates the machine's `power_state` and the area's power grid.
/obj/machinery/proc/change_power_mode(new_power_state = POWER_USE_IDLE)
	if(!power_init_complete)
		power_state = new_power_state
		return // We'll be retallying anyway.
	if(power_state == new_power_state)
		return
	var/old_power = get_power_usage()
	power_state = new_power_state
	var/new_power = get_power_usage()
	REPORT_POWER_CONSUMPTION_CHANGE(old_power, new_power)

/// Updates the machine's `power_channel` to the new value and updates the machine's area's power grid.
/obj/machinery/proc/update_power_channel(new_channel)
	if(power_channel == new_channel)
		return
	if(!power_init_complete)
		power_channel = new_channel
		return
	var/power = get_power_usage()
	REPORT_POWER_CONSUMPTION_CHANGE(power, 0)
	power_channel = new_channel
	REPORT_POWER_CONSUMPTION_CHANGE(0, power)

/// Updates the machine's power draw for the given state and updates the area's power grid if it is active.
/obj/machinery/proc/set_power_consumption(new_power_consumption, power_mode = POWER_USE_IDLE)
	var/old_power
	switch(power_mode)
		if(POWER_USE_IDLE)
			old_power = idle_power_consumption
			idle_power_consumption = new_power_consumption
		if(POWER_USE_ACTIVE)
			old_power = active_power_consumption
			active_power_consumption = new_power_consumption
		else
			return
	if(power_init_complete && (power_mode == power_state))
		REPORT_POWER_CONSUMPTION_CHANGE(old_power, new_power_consumption)

/obj/machinery/proc/has_power(channel = POWER_CHAN)
	return powered(channel)

/obj/machinery/proc/use_power(channel, amount)
	if(isnull(amount))
		amount = channel
		channel = POWER_CHAN
	return use_power_oneoff(amount, channel) <= 0

/obj/machinery/proc/add_static_power(channel, amount)
	var/area/A = get_area(src)
	if(!A)
		return FALSE
	var/datum/local_powernet/local_net = A.create_powernet()
	return local_net.adjust_static_power(channel, amount)

/obj/machinery/proc/remove_static_power(channel, amount)
	return add_static_power(channel, -amount)

#undef REPORT_POWER_CONSUMPTION_CHANGE
