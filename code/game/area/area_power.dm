/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/
/area
	var/list/machinery_list

/// Returns boolean. Whether or not the area is considered to have power for the given power channel. See `requires_power` and `always_unpowered` for some area-level overrides.
/area/proc/powered(chan)
	if(!powernet)
		create_powernet()
	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	if(chan == LOCAL)
		return FALSE // if you're running on local power, don't come begging for help here.
	switch(chan)
		if(EQUIP)
			return powernet.has_power(PW_CHANNEL_EQUIPMENT)
		if(LIGHT)
			return powernet.has_power(PW_CHANNEL_LIGHTING)
		if(ENVIRON)
			return powernet.has_power(PW_CHANNEL_ENVIRONMENT)
	return FALSE

/// Called whenever the area's power or power usage state should change.
/area/proc/power_change()
	if(!powernet)
		create_powernet()
	powernet.power_change()
	if (fire || eject || party)
		update_icon()

/// Returns Integer. The total amount of power usage queued for the area from both `used_*` and `oneoff_*` for the given power channel, or all channels if `TOTAL` is passed instead.
/area/proc/usage(chan)
	if(!powernet)
		create_powernet()
	switch(chan)
		if(LIGHT)
			return powernet.passive_lighting_consumption + powernet.lighting_consumption
		if(EQUIP)
			return powernet.passive_equipment_consumption + powernet.equipment_consumption
		if(ENVIRON)
			return powernet.passive_environment_consumption + powernet.environment_consumption
		if(TOTAL)
			return powernet.get_total_usage()

/// Sets all `oneoff_*` vars to `0`. Helper for APCs. Called every machinery process tick.
/area/proc/clear_usage()
	if(!powernet)
		create_powernet()
	powernet.clear_usage()

/**
 * Adds the given amount of power to the `used_*` var for the given power channel, effectively increasing continuous power usage.
 *
 * **Generally, you probably do not want to use this directly. See `power_use_change()` and `use_power_oneoff()` instead.**
 *
 * **Parameters**:
 * - `amount` Integer. The amount of power to add to the given channel. Use negative numbers to subtract instead.
 * - `chan` Integer (`EQUIP`, `LIGHT`, or `ENVIRON`). The power channel to add the power to.
 */
/area/proc/use_power(amount, chan)
	if(!powernet)
		create_powernet()
	powernet.adjust_static_power(chan, amount)

/**
 * Updates the area's continuous power use (See the `used_*` vars) for the given channel.
 * This is used by machines to properly update the area of power use changes.
 *
 * **If calling this from a `/obj/machine`, you should probably use `REPORT_POWER_CONSUMPTION_CHANGE()` instead.**
 *
 * **Parameters**:
 * - `old_amount` Integer. The amount of power being used before the change.
 * - `new_amount` Integer. The amount of power being used after the change.
 * - `chan` Integer (`ENVIRON`, `EQUIP`, or `LIGHT`). The channel to update.
 */
/area/proc/power_use_change(old_amount, new_amount, chan)
	if(!powernet)
		create_powernet()
	powernet.power_use_change(old_amount, new_amount, chan)

/**
 * Adds the given amount of power to the `oneoff_*` var for the given power channel. This results in a single spike in power usage that is reset on the next power tick.
 * Use this for a one-time power draw from the area, typically for non-machines.
 *
 * **Parameters**:
 * - `amount` Integer. The amount of power to add to the given channel. Use negative numbers to subtract instead.
 * - `chan` Integer (`EQUIP`, `LIGHT`, or `ENVIRON`). The power channel to add the power to.
 */
/area/proc/use_power_oneoff(amount, chan)
	if(!powernet)
		create_powernet()
	powernet.use_power_oneoff(amount, chan)

/// Recomputes the continued power usage; can be used for testing or error recovery, but is not called under normal conditions.
/area/proc/retally_power()
	if(!powernet)
		create_powernet()
	powernet.retally_passive_usage()
