/obj/machinery/shield_diffuser
	name = "shield diffuser"
	desc = "A small underfloor device specifically designed to disrupt energy barriers."
	icon = 'icons/obj/machines/shielding.dmi'
	icon_state = "fdiffuser_on"
	use_power = POWER_USE_ACTIVE
	idle_power_usage = 100
	active_power_usage = 2000
	anchored = TRUE
	density = FALSE
	level = ATOM_LEVEL_UNDER_TILE
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0

	machine_name = "shield diffuser"
	machine_desc = "These floor-mounted devices prevent formation of shields above them, and are typically placed near front of external airlocks."

	var/alarm = 0
	var/enabled = 1
	var/process_delay_ds = 2
	var/diffuse_duration_ds = 5
	var/list/diffuse_turfs

	init_flags = INIT_MACHINERY_START_PROCESSING

/obj/machinery/shield_diffuser/Initialize()
	. = ..()
	rebuild_diffuse_turfs()

/obj/machinery/shield_diffuser/Destroy()
	diffuse_turfs = null
	. = ..()

/obj/machinery/shield_diffuser/proc/rebuild_diffuse_turfs()
	diffuse_turfs = list()
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return

	for(var/direction in GLOB.cardinal)
		var/turf/shielded_tile = get_step(source_turf, direction)
		if(shielded_tile)
			diffuse_turfs += shielded_tile

/obj/machinery/shield_diffuser/Process()
	if(alarm)
		alarm = max(0, alarm - process_delay_ds)
		if(!alarm)
			update_icon()
		request_process_in(process_delay_ds)
		return

	if(!enabled && !alarm)
		return PROCESS_KILL

	if(enabled)
		if(!length(diffuse_turfs))
			rebuild_diffuse_turfs()
		for(var/turf/shielded_tile as anything in diffuse_turfs)
			if(!shielded_tile)
				continue
			for(var/obj/shield/S in shielded_tile)
				S.diffuse(diffuse_duration_ds)

	request_process_in(process_delay_ds)
	return

/obj/machinery/shield_diffuser/on_update_icon()
	if(alarm)
		icon_state = "fdiffuser_emergency"
		return
	if(inoperable() || !enabled)
		icon_state = "fdiffuser_off"
	else
		icon_state = "fdiffuser_on"

/obj/machinery/shield_diffuser/interface_interact(mob/user)
	if(!CanInteract(user, DefaultTopicState()))
		return FALSE
	if(alarm)
		to_chat(user, "You press an override button on \the [src], re-enabling it.")
		alarm = 0
		update_icon()
		if(enabled)
			START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		else
			STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		return TRUE
	enabled = !enabled
	update_use_power(enabled + 1)
	update_icon()
	if(enabled)
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
	else
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
	to_chat(user, "You turn \the [src] [enabled ? "on" : "off"].")
	return TRUE

/obj/machinery/shield_diffuser/proc/meteor_alarm(duration)
	if(!duration)
		return
	alarm = round(max(alarm, duration))
	update_icon()
	START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/shield_diffuser/examine(mob/user)
	. = ..()
	to_chat(user, "It is [enabled ? "enabled" : "disabled"].")
	if(alarm)
		to_chat(user, "A red LED labeled \"Proximity Alarm\" is blinking on the control panel.")
