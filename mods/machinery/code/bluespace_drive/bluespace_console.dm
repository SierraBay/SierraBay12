/obj/item/stock_parts/circuitboard/bluespace_drive_console
	name = "circuit board (bluespace drive control console)"
	build_path = /obj/machinery/computer/bluespace_drive_console
	origin_tech = list(TECH_DATA = 6, TECH_BLUESPACE = 9)

/datum/design/circuit/bluespace_drive_console
	name = "bluespace drive control console"
	id = "bluespace drive control console"
	req_tech = list(TECH_DATA = 6, TECH_BLUESPACE = 6)
	build_path = /obj/item/stock_parts/circuitboard/bluespace_drive_console
	sort_string = "BASAD"


/**
 * # Bluespace Drive Control Console
 *
 * A computer that controls the linked bluespace drive.
 * Must be placed in the same area as the drive.
 */
/obj/machinery/computer/bluespace_drive_console
	name = "bluespace drive control console"
	desc = "A console used to control the bluespace drive. Displays drive status, fuel levels, and jump parameters."
	icon_keyboard = "generic_key"
	icon_screen = "teleport"
	light_color = "#0e3b69"
	uncreated_component_parts = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)


	/// The bluespace drive this console controls
	var/obj/machinery/bluespace_drive/linked_drive

/obj/machinery/computer/bluespace_drive_console/Initialize()
	. = ..()
	find_drive()

/obj/machinery/computer/bluespace_drive_console/proc/find_drive()
	linked_drive = locate(/obj/machinery/bluespace_drive) in get_area(src)

/obj/machinery/computer/bluespace_drive_console/Destroy()
	linked_drive = null
	. = ..()

/obj/machinery/computer/bluespace_drive_console/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/computer/bluespace_drive_console/attack_hand(mob/user)
	if(..())
		return TRUE
	if(!linked_drive)
		find_drive()
	if(!linked_drive)
		to_chat(user, SPAN_WARNING("No bluespace drive detected in this area!"))
		return
	ui_interact(user)

/obj/machinery/computer/bluespace_drive_console/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!linked_drive)
		return

	var/list/data = list()

	data["energized"] = linked_drive.energized
	data["jumping"] = linked_drive.jumping
	data["rotation"] = linked_drive.rotation
	data["angle"] = linked_drive.angle
	data["jump_power"] = round(linked_drive.power_from_gas / 1000, 0.1)
	data["min_fuel"] = linked_drive.minimum_phoron_moles_per_jump
	data["emergency_min_fuel"] = linked_drive.emergency_jump_min_moles
	data["emergency_jump"] = linked_drive.emergency_jump
	data["rift_open"] = linked_drive.rift_open
	data["has_destination"] = !!linked_drive.get_jump_destination()
	data["linked"] = !!linked_drive.linked
	data["jump_locked"] = linked_drive.jump_locked
	data["on_cooldown"] = linked_drive.on_cooldown
	data["cooldown_remaining"] = linked_drive.on_cooldown ? max(0, round((linked_drive.cooldown_end_time - world.time) / 10, 1)) : 0
	data["overcharged"] = (linked_drive.power_from_gas >= linked_drive.overcharge_threshold)
	data["near_overcharge"] = (linked_drive.power_from_gas >= linked_drive.overcharge_threshold * 0.75 && linked_drive.power_from_gas < linked_drive.overcharge_threshold)
	data["overcharge_threshold"] = round(linked_drive.overcharge_threshold / 1000, 0.1)
	data["intake_rate"] = linked_drive.intake_rate

	// Fuel tank contents
	var/datum/gas_mixture/fg = linked_drive.fuel_gas
	var/list/fuel_parts = list()
	if(fg && fg.total_moles > 0)
		for(var/gas_id in fg.gas)
			fuel_parts += "[gas_data.name[gas_id]] [round(fg.gas[gas_id], 0.1)] mol ([round(fg.gas[gas_id] / fg.total_moles * 100, 1)]%)"
	data["fuel_contents_str"] = fuel_parts.Join(", ")
	data["fuel_total_moles"] = round(fg ? fg.total_moles : 0, 0.1)
	data["fuel_temp_k"]      = (fg && fg.total_moles > 0) ? round(fg.temperature) : 0
	data["fuel_pres"]        = round(fg ? fg.return_pressure() : 0, 1)

	if(linked_drive.linked)
		data["ship_name"] = linked_drive.linked.name
		data["ship_x"] = linked_drive.linked.x
		data["ship_y"] = linked_drive.linked.y

	var/turf/dest = linked_drive.get_jump_destination()
	if(dest)
		data["dest_x"] = dest.x
		data["dest_y"] = dest.y

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "bluespace_drive.tmpl", "Bluespace Drive Control", 500, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/bluespace_drive_console/OnTopic(mob/user, list/href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(!linked_drive)
		return TOPIC_HANDLED

	if(href_list["toggle_energized"])
		if(!linked_drive.powered())
			to_chat(user, SPAN_WARNING("The drive has no power!"))
			return TOPIC_HANDLED
		linked_drive.toggle_energized()
		return TOPIC_REFRESH

	if(href_list["purge"])
		linked_drive.purge_charge(forced = TRUE)
		return TOPIC_REFRESH

	if(href_list["set_rotation"])
		var/new_rot = input(user, "Enter jump rotation (0-359 degrees):", "Set Rotation", linked_drive.rotation) as num|null
		if(!isnull(new_rot))
			linked_drive.set_rotation(new_rot)
		return TOPIC_REFRESH

	if(href_list["set_angle"])
		var/new_ang = input(user, "Enter jump angle (1-89 degrees):", "Set Angle", linked_drive.angle) as num|null
		if(!isnull(new_ang))
			linked_drive.set_angle(new_ang)
		return TOPIC_REFRESH

	if(href_list["jump"])
		if(!linked_drive.energized)
			to_chat(user, SPAN_WARNING("The drive must be energized first!"))
			return TOPIC_HANDLED
		var/success = linked_drive.initiate_jump(user)
		if(!success)
			to_chat(user, SPAN_WARNING("Unable to initiate jump! Check fuel levels ([linked_drive.fuel_gas.total_moles]/[linked_drive.minimum_phoron_moles_per_jump] moles phoron required), destination validity, cooldown, or if a jump is already in progress."))
		return TOPIC_REFRESH

	if(href_list["abort"])
		if(linked_drive.jump_locked)
			to_chat(user, SPAN_WARNING("The jump sequence is locked \u2014 too late to abort!"))
			return TOPIC_HANDLED
		linked_drive.abort_jump(user)
		return TOPIC_REFRESH
	if(href_list["set_intake"])
		if(linked_drive.jumping || linked_drive.jump_locked)
			to_chat(user, SPAN_WARNING("Cannot adjust intake during an active jump sequence."))
			return TOPIC_HANDLED
		var/new_rate = text2num(href_list["set_intake"])
		if(new_rate && new_rate >= 1 && new_rate <= 3)
			linked_drive.intake_rate = new_rate
		return TOPIC_REFRESH
	return TOPIC_HANDLED
