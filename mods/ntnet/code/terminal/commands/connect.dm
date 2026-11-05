/datum/terminal_command/connect
	name = "connect"
	man_entry = list(
		"Format: connect \[REMOTE id].",
		"Standard format show you data about REMOTE, it needn't access of REMOTE.",
		"Open format: connect \[REMOTE id] -open. To close REMOTE, replace '-open' by '-close'. Need airlock accessible",
		"Locking (bolting) format: connect \[REMOTE id] -lock. To unlock use -unlock. Need airlock access.",
		"In red and orange code you can override airlock access by using override key. Like this: 'connect y421 -open -override Yota11'"
	)
	pattern = "^connect"
	skill_needed = SKILL_TRAINED
	/// Air alarm mode set by each mode flag
	var/static/list/air_alarm_modes_by_flag = list(
		"-mode-scrub" = AALARM_MODE_SCRUBBING,
		"-mode-replace" = AALARM_MODE_REPLACEMENT,
		"-mode-siphon" = AALARM_MODE_PANIC,
		"-mode-cycle" = AALARM_MODE_CYCLE,
		"-mode-fill" = AALARM_MODE_FILL,
		"-mode-off" = AALARM_MODE_OFF
	)

/datum/terminal_command/connect/proper_input_entered(text, mob/user, datum/terminal/terminal)
	var/list/arguments = get_arguments(text)
	if(!length(arguments) || length(arguments) > 2)
		return syntax_error()
	var/datum/extension/interactive/ntos/os = terminal.computer
	if(!os.get_ntnet_status())
		return network_error()
	var/obj/machinery/device = get_ntnet_machine(uppertext(arguments[1]))
	if(!device)
		return "[name]: <font color = '#ff0000'>ERROR 404</font>: Unknown ID."
	var/flag = LAZYACCESS(arguments, 2)
	if(istype(device, /obj/machinery/door/airlock))
		return connect_airlock(device, flag, user, os)
	if(istype(device, /obj/machinery/power/apc))
		return connect_apc(device, flag, user, os)
	if(istype(device, /obj/machinery/alarm))
		return connect_air_alarm(device, flag, user, os)
	if(istype(device, /obj/machinery/firealarm))
		return connect_fire_alarm(device, flag, os)
	if(istype(device, /obj/machinery/camera))
		return connect_camera(device, flag, os)
	return syntax_error()

/// Writes a command that reached the device to the NTNet log, under the network tag of the computer that sent it.
/datum/terminal_command/connect/proc/log_remote_command(datum/extension/interactive/ntos/os, obj/machinery/device, flag)
	os.add_log("Remote command '[flag]' sent to [device] ([device.NTNet_id]).")

/datum/terminal_command/connect/proc/log_denied_command(datum/extension/interactive/ntos/os, obj/machinery/device, flag)
	os.add_log("Remote command '[flag]' to [device] ([device.NTNet_id]) rejected: access denied.")

/// The device's network wire is cut or pulsed, or the device has no power.
/datum/terminal_command/connect/proc/link_error(obj/machinery/device)
	return "[name]: <font color = '#ff0000'>ERROR</font>: no response from [device.NTNet_id]. Device network link is down."

/datum/terminal_command/connect/proc/access_error()
	return "[name]: <font color = '#ff0000'>ACCESS ERROR.</font>"

/datum/terminal_command/connect/proc/unknown_flag_error(flag)
	return "[flag]: <font color = '#ff0000'>ERROR</font>: Unknown parameter."

// AIRLOCK

/datum/terminal_command/connect/proc/connect_airlock(obj/machinery/door/airlock/airlock, flag, mob/user, datum/extension/interactive/ntos/os)
	if(!flag)
		return airlock_report(airlock, user)
	if(!airlock.canAIControl())
		return link_error(airlock)
	if(!has_access(airlock.req_access, user.GetAccess()))
		log_denied_command(os, airlock, flag)
		return access_error()
	switch(flag)
		if("-open")
			. = airlock.open() ? "[name]: Airlock with id([airlock.NTNet_id]) was opened." : "[name]: unable to open airlock, maybe it is bolted, already open or lacks power."
		if("-close")
			airlock.close()
			. = airlock.density ? "[name]: Airlock with id([airlock.NTNet_id]) was closed." : "[name]: unable to close airlock, maybe it is bolted, blocked or lacks power."
		if("-lock")
			. = airlock.lock() ? "[name]: Airlock with id([airlock.NTNet_id]) was bolted." : "[name]: unable to bolt airlock, maybe it is already bolted or its bolts are cut."
		if("-unlock")
			. = airlock.unlock() ? "[name]: Airlock with id([airlock.NTNet_id]) was unbolted." : "[name]: unable to unbolt airlock, maybe it is already unbolted or lacks power."
		else
			return unknown_flag_error(flag)
	log_remote_command(os, airlock, flag)

/datum/terminal_command/connect/proc/airlock_report(obj/machinery/door/airlock/airlock, mob/user)
	var/electrified_state
	switch(airlock.electrified_until)
		if(-1)
			electrified_state = "<font color = '#fffa29'>PERMANENT</font>"
		if(0)
			electrified_state = "<font color ='#00ff00'>FALSE</font>"
		else
			electrified_state = "<font color = '#ff0000'>TRUE</font>"
	. = "Outputting data about airlock([airlock.NTNet_id]):<hr>"
	. += "Name:   [airlock.name]<br>"
	. += "Energy: [airlock.main_power_lost_until ? "<font color = '#ff0000'>OFFLINE</font>" : "<font color = '#00ff00'>ONLINE</font>"]"
	. += "<pre>Network data:<br>"
	. += "	NTNet connection: [airlock.canAIControl() ? "<font color = '#00ff00'>STABLE</font>" : "<font color = '#ff0000'>ERROR</font>"].<br>"
	. += "<pre>Local functional data:<br>"
	. += "	Electrified: [electrified_state].<br>"
	. += "	Bolts: [airlock.locked ? "<font color = '#ff0000'>LOCKED DOWN</font>" : "<font color = '#00ff00'>OUT OF SERVICE</font>"].<br>"
	. += "	Lights: [airlock.lights ? "<font color = '#00ff00'>STABLE</font>" : "<font color = '#ff0000'>OUT OF SERVICE</font>"].<br><hr>"
	. += "SAFETY DATA:<br>"
	. += "	Airlock timing: [airlock.normalspeed ? "<font color = '#00ff00'>STABLE</font>" : "<font color = '#ff0000'>OVERRIDEN</font>"].<br>"
	. += "	Safety protocols: [airlock.safe ? "<font color = '#00ff00'>STABLE</font>" : "<font color = '#ff0000'>OVERRIDEN</font>"].<br></pre>"
	. += "Required Access: [length(airlock.req_access)>=1 ? "([jointext(airlock.req_access, ", ") ])" : "ACCESS NOT REQUIRED"].<hr>"
	. += "Access check: [has_access(airlock.req_access, user.GetAccess()) ? "<font color = '#00ff00'>GRANTED</font>" : "<font color = '#ff0000'>DENIED</font>"]."

// APC

/datum/terminal_command/connect/proc/connect_apc(obj/machinery/power/apc/apc, flag, mob/user, datum/extension/interactive/ntos/os)
	if(!flag)
		return apc_report(apc)
	if(apc.aidisabled)
		return link_error(apc)
	if(apc.locked && !has_access(apc.req_access, user.GetAccess()))
		log_denied_command(os, apc, flag)
		return access_error()
	switch(flag)
		//lock-unlock panel
		if("-lock")
			apc.locked = TRUE
			apc.update_icon()
			. = "APC panel <font color = '#00ff00'>BLOCKED</font>"
		if("-unlock")
			apc.locked = FALSE
			apc.update_icon()
			. = "APC panel <font color = '#ff0000'>OPEN</font>"
		//lock-unlock cover
		if("-lock-cover")
			apc.coverlocked = TRUE
			. = "APC cover <font color = '#00ff00'>BLOCKED</font>"
		if("-unlock-cover")
			apc.coverlocked = FALSE
			. = "APC cover <font color = '#ff0000'>OPEN</font>"
		//light control, with the same values as the lighting buttons in the APC window
		if("-light-up")
			set_apc_lighting(apc, 1)
			. = "Light up"
		if("-light-down")
			set_apc_lighting(apc, 0)
			. = "Light down"
		if("-light-auto")
			set_apc_lighting(apc, 2)
			. = "Light automated"
		else
			return unknown_flag_error(flag)
	log_remote_command(os, apc, flag)

/// Takes the value of the APC window's lighting buttons: 0 is off, 1 is on, 2 is auto.
/datum/terminal_command/connect/proc/set_apc_lighting(obj/machinery/power/apc/apc, button_value)
	apc.lighting = apc.setsubsystem(button_value)
	apc.force_update_channels()

/datum/terminal_command/connect/proc/apc_report(obj/machinery/power/apc/apc)
	var/obj/item/cell/battery = apc.get_cell()
	. = "Outputting data about APC([apc.NTNet_id]):<hr>"
	. += "Name:[copytext(apc.name,2)]<br>"
	. += "Batery:[battery ? num2text(battery.percent())+"%" : "<font color = '#ff0000'>NONE</font>"]<br>"
	. += "Status:[apc.locked ? "<font color = '#00ff00'>BLOCKED</font>" : "<font color = '#ff0000'>OPEN</font>"]<br><hr>"

// Atmospheric Alarm

/datum/terminal_command/connect/proc/connect_air_alarm(obj/machinery/alarm/alarm, flag, mob/user, datum/extension/interactive/ntos/os)
	if(!flag)
		return air_alarm_report(alarm)
	if(alarm.aidisabled)
		return link_error(alarm)
	if(alarm.locked && !has_access(alarm.req_access, user.GetAccess()))
		log_denied_command(os, alarm, flag)
		return access_error()
	switch(flag)
		//lock-unlock panel
		if("-lock")
			alarm.locked = TRUE
			alarm.update_icon()
			. = "Atmospheric Alarm panel <font color = '#00ff00'>BLOCKED</font>"
		if("-unlock")
			alarm.locked = FALSE
			alarm.update_icon()
			. = "Atmospheric Alarm <font color = '#ff0000'>OPEN</font>"
		else
			var/new_mode = air_alarm_modes_by_flag[flag]
			if(!new_mode)
				return unknown_flag_error(flag)
			alarm.mode = new_mode
			alarm.apply_mode()
			. = "Atmospheric Alarm mode set to [air_alarm_mode_text(new_mode)]"
	log_remote_command(os, alarm, flag)

/datum/terminal_command/connect/proc/air_alarm_mode_text(mode)
	switch(mode)
		if(AALARM_MODE_OFF)
			return "<font color = '#fffa29'>OFF</font>"
		if(AALARM_MODE_FILL)
			return "<font color = '#fffa29'>FILL</font>"
		if(AALARM_MODE_CYCLE)
			return "<font color = '#fffa29'>CYCLE</font>"
		if(AALARM_MODE_PANIC)
			return "<font color = '#ff0000'>SIPHONING</font>"
		if(AALARM_MODE_REPLACEMENT)
			return "<font color = '#fffa29'>REPLACEMENT</font>"
		if(AALARM_MODE_SCRUBBING)
			return "<font color = '#00ff00'>SCRUBBING</font>"
	return "<font color = '#ff0000'>NO DATA</font>"

/datum/terminal_command/connect/proc/air_alarm_report(obj/machinery/alarm/alarm)
	var/alarm_level
	switch(alarm.danger_level)
		if(1)
			alarm_level = "<font color = '#fffa29'>MINOR</font>"
		if(0)
			alarm_level = "<font color ='#00ff00'>CLEAR</font>"
		else
			alarm_level = "<font color = '#ff0000'>SEVERE</font>"
	. = "Outputting data about Atmospheric Alarm([alarm.NTNet_id]):<hr>"
	. += "Name:[copytext(alarm.name,2)]<br>"
	. += "Status:[alarm.locked ? "<font color = '#00ff00'>BLOCKED</font>" : "<font color = '#ff0000'>OPEN</font>"]<br><hr>"
	. += "AI control:[alarm.aidisabled ? "<font color = '#ff0000'>OUT OF SERVICE</font>" : "<font color = '#00ff00'>ACTIVE</font>"]<br><hr>"
	. += "<pre>Local functional data:<br>"
	. += "	Current alarm level: [alarm_level].<br>"
	. += "	Current operating mode: [air_alarm_mode_text(alarm.mode)].<br>"

// FIREALARM

/datum/terminal_command/connect/proc/connect_fire_alarm(obj/machinery/firealarm/alarm, flag, datum/extension/interactive/ntos/os)
	if(!flag)
		return fire_alarm_report(alarm)
	switch(flag)
		if("-alarm")
			alarm.alarm()
			. = "Activated"
		if("-reset")
			alarm.reset()
			. = "Deactivated"
		if("-detect")
			alarm.detecting = !alarm.detecting
			. = "Automatic switched to: [alarm.detecting  ? "<font color = '#00ff00'>ON</font>" : "<font color = '#ff0000'>OFF</font>"]."
		else
			return unknown_flag_error(flag)
	log_remote_command(os, alarm, flag)

/datum/terminal_command/connect/proc/fire_alarm_report(obj/machinery/firealarm/alarm)
	. = "Outputting data about firealarm([alarm.NTNet_id]):<hr>"
	. += "Name:   [alarm.name]<br> <hr>"
	. += "Status:   [alarm.detecting  ? "<font color = '#00ff00'>Automatic</font>" : "<font color = '#ff0000'>OFF</font>"].<br><hr>"

// SECURITY CAMERA

/datum/terminal_command/connect/proc/connect_camera(obj/machinery/camera/camera, flag, datum/extension/interactive/ntos/os)
	if(!flag)
		return camera_report(camera)
	// Cameras have no AI control wire; their network port is the wire that shows the NTNet ID (mods/utility_items/code/wires.dm)
	if(camera.wires?.IsIndexCut(CAMERA_WIRE_NOTHING1))
		return link_error(camera)
	switch(flag)
		// triggering camera alarm
		if("-alarm")
			camera.alarm_on = TRUE
			. = "Alarm Triggered"
		// camera lights (can AI toggle it?)
		if("-light_up")
			camera.light_disabled = FALSE
			. = "Light up"
		if("-light_down")
			camera.light_disabled = TRUE
			. = "Light down"
		// camera focus (AI vision range)
		if("-defocus")
			camera.setViewRange(2)
			. = "Camera defocused"
		if("-focus")
			camera.setViewRange(7)
			. = "Camera focused"
		else
			return unknown_flag_error(flag)
	log_remote_command(os, camera, flag)

/datum/terminal_command/connect/proc/camera_report(obj/machinery/camera/camera)
	var/camera_focus
	switch(camera.view_range)
		if(2)
			camera_focus = "<font color = '#fffa29'>DEFOCUSED</font>"
		if(7)
			camera_focus = "<font color ='#00ff00'>NOMINAL</font>"
		else
			camera_focus = "<font color = '#ff0000'>MISMATCHED</font>"
	. = "Outputting data about security camera([camera.NTNet_id]):<hr>"
	. += "Name:   [camera.name]<br> <hr>"
	. += "Camera Alarm:   [camera.alarm_on  ? "<font color = '#ff0000'>ON</font>" : "<font color = '#00ff00'>OFF</font>"]<br> <hr>"
	. += "	Focus: [camera_focus].<br>"
