/**
 * # local_powernet
 *
 * Tracks per-area passive and active power usage and channel state for APC-backed machinery.
 * This datum is the source of truth for area-local machine power.
 */
/datum/local_powernet
	/// The area this local powernet belongs to.
	var/area/powernet_area
	/// The APC currently governing this local powernet.
	var/obj/machinery/power/apc/powernet_apc

	/// Bitflags controlling special powernet behaviour.
	var/power_flags = FLAGS_OFF

	/// Whether each APC-backed channel is enabled.
	var/equipment_powered = TRUE
	var/lighting_powered = TRUE
	var/environment_powered = TRUE

	/// Passive per-channel draw.
	var/passive_equipment_consumption = 0
	var/passive_lighting_consumption = 0
	var/passive_environment_consumption = 0

	/// Active, one-tick per-channel draw.
	var/equipment_consumption = 0
	var/lighting_consumption = 0
	var/environment_consumption = 0

	/// Registered machinery in the owning area.
	var/list/registered_machines = list()

/datum/local_powernet/proc/register_machine(obj/machinery/machine)
	if(!machine)
		return
	if(machine in registered_machines)
		machine.machine_powernet = src
		machine.power_change()
		return
	machine.machine_powernet = src
	registered_machines += machine
	machine.power_change()

/datum/local_powernet/proc/unregister_machine(obj/machinery/machine)
	if(!(machine in registered_machines))
		return
	machine.machine_powernet = null
	registered_machines -= machine
	machine.power_change()

/datum/local_powernet/proc/power_change()
	for(var/obj/machinery/M as anything in registered_machines)
		M.power_change()
	SEND_SIGNAL(src, COMSIG_POWERNET_POWER_CHANGE)

/datum/local_powernet/proc/set_power_channel(channel, new_state)
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			if(equipment_powered == new_state)
				return
			equipment_powered = new_state
		if(PW_CHANNEL_LIGHTING)
			if(lighting_powered == new_state)
				return
			lighting_powered = new_state
		if(PW_CHANNEL_ENVIRONMENT)
			if(environment_powered == new_state)
				return
			environment_powered = new_state
		else
			return
	power_change()

/datum/local_powernet/proc/has_power(channel)
	if(channel == LOCAL || channel == TOTAL)
		return FALSE
	if(power_flags & PW_ALWAYS_UNPOWERED)
		return FALSE
	if(power_flags & PW_ALWAYS_POWERED)
		return TRUE
	if(!powernet_apc && powernet_area?.requires_power)
		return FALSE
	if(powernet_apc && (MACHINE_IS_BROKEN(powernet_apc) || GET_FLAGS(powernet_apc.stat, MACHINE_STAT_MAINT)))
		return FALSE
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			return equipment_powered
		if(PW_CHANNEL_LIGHTING)
			return lighting_powered
		if(PW_CHANNEL_ENVIRONMENT)
			return environment_powered
	return FALSE

/datum/local_powernet/proc/use_active_power(channel, amount)
	if(!has_power(channel))
		return FALSE
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			equipment_consumption += amount
		if(PW_CHANNEL_LIGHTING)
			lighting_consumption += amount
		if(PW_CHANNEL_ENVIRONMENT)
			environment_consumption += amount
		else
			return FALSE
	return TRUE

/datum/local_powernet/proc/adjust_static_power(channel, amount)
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			passive_equipment_consumption += amount
		if(PW_CHANNEL_LIGHTING)
			passive_lighting_consumption += amount
		if(PW_CHANNEL_ENVIRONMENT)
			passive_environment_consumption += amount
		else
			return FALSE
	return TRUE

/datum/local_powernet/proc/power_use_change(old_amount, new_amount, channel)
	return adjust_static_power(channel, new_amount - old_amount)

/datum/local_powernet/proc/use_power_oneoff(amount, channel)
	return use_active_power(channel, amount)

/datum/local_powernet/proc/get_total_usage()
	return get_channel_usage(PW_CHANNEL_EQUIPMENT) + get_channel_usage(PW_CHANNEL_LIGHTING) + get_channel_usage(PW_CHANNEL_ENVIRONMENT)

/datum/local_powernet/proc/get_channel_usage(channel)
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			return has_power(channel) ? passive_equipment_consumption + equipment_consumption : 0
		if(PW_CHANNEL_LIGHTING)
			return has_power(channel) ? passive_lighting_consumption + lighting_consumption : 0
		if(PW_CHANNEL_ENVIRONMENT)
			return has_power(channel) ? passive_environment_consumption + environment_consumption : 0
	return 0

/datum/local_powernet/proc/clear_usage()
	equipment_consumption = 0
	lighting_consumption = 0
	environment_consumption = 0

/datum/local_powernet/proc/retally_passive_usage()
	passive_equipment_consumption = 0
	passive_lighting_consumption = 0
	passive_environment_consumption = 0
	for(var/obj/machinery/M as anything in registered_machines)
		switch(M.power_channel)
			if(EQUIP)
				passive_equipment_consumption += M.get_power_usage()
			if(LIGHT)
				passive_lighting_consumption += M.get_power_usage()
			if(ENVIRON)
				passive_environment_consumption += M.get_power_usage()

/datum/local_powernet/proc/handle_flicker()
	if(prob(MACHINE_FLICKER_CHANCE))
		powernet_apc?.flicker_lighting()
	if(prob(MACHINE_FLICKER_CHANCE * 3))
		var/list/lights = list()
		for(var/obj/machinery/light/L in powernet_area)
			lights += L
		if(length(lights))
			var/obj/machinery/light/picked_light = pick(lights)
			if(istype(picked_light))
				picked_light.flicker()
