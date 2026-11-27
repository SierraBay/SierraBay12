#define AUTOLATHE_PRINT_LOG_MAX 50

/obj/machinery/fabricator
	/// Recent print jobs: list of assoc lists (at, user, item, materials).
	var/list/print_log = list()
	/// TRUE while the journal can be read remotely over NTNet.
	var/print_log_network = TRUE
	/// TRUE after a destructive wipe — remote/local UI shows corruption notice until new entries appear.
	var/print_log_corrupt = FALSE


/obj/machinery/fabricator/proc/print_log_user_label(mob/user)
	if (!istype(user))
		return "Unknown"
	var/label = user.real_name || user.name || "Unknown"
	var/obj/item/card/id/id = user.GetIdCard()
	if (istype(id) && id.registered_name)
		label = id.registered_name
		if (id.assignment)
			label += " ([id.assignment])"
	return label


/obj/machinery/fabricator/proc/print_log_format_materials(datum/design/design)
	if (!istype(design))
		return "—"
	var/list/parts = list()
	for (var/mat in design.materials)
		var/amount = get_design_material_cost(design, mat)
		if (amount <= 0)
			continue
		parts += "[mat]: [round(amount)]"
	if (LAZYLEN(design.chemicals))
		for (var/reagent in design.chemicals)
			parts += "[reagent]: [design.chemicals[reagent]]"
	if (!length(parts))
		return "—"
	return jointext(parts, ", ")


/obj/machinery/fabricator/proc/record_print_log(datum/design/design, ordered_by)
	if (!istype(design))
		return
	var/list/entry = list(
		"at" = "[stationdate2text()] [stationtime2text()]",
		"user" = ordered_by || "Unknown",
		"item" = design.name || "Unknown design",
		"materials" = print_log_format_materials(design)
	)
	print_log += list(entry)
	print_log_corrupt = FALSE
	while (length(print_log) > AUTOLATHE_PRINT_LOG_MAX)
		print_log.Cut(1, 2)


/obj/machinery/fabricator/proc/wipe_print_log(reason)
	print_log.Cut()
	print_log_corrupt = TRUE
	print_log += list(list(
		"at" = "[stationdate2text()] [stationtime2text()]",
		"user" = "SYSTEM",
		"item" = reason || "Journal wiped",
		"materials" = "—"
	))


/obj/machinery/fabricator/proc/set_print_log_network(enabled)
	print_log_network = !!enabled
	if (print_log_network)
		fab_status_flags &= ~FAB_OFFLINE
	else
		fab_status_flags |= FAB_OFFLINE


/obj/machinery/fabricator/proc/is_print_log_remote_visible()
	if (!print_log_network || (fab_status_flags & FAB_OFFLINE))
		return FALSE
	if ((stat & MACHINE_STAT_NOPOWER) || MACHINE_IS_BROKEN(src))
		return FALSE
	var/turf/T = get_turf(src)
	if (!istype(T) || !(T.z in GLOB.using_map.station_levels))
		return FALSE
	return TRUE


/obj/machinery/fabricator/proc/print_log_ui_entries(limit = AUTOLATHE_PRINT_LOG_MAX)
	var/list/out = list()
	if (!length(print_log))
		return out
	var/start = 1
	var/total = length(print_log)
	if (total > limit)
		start = total - limit + 1
	for (var/i = total; i >= start; i--)
		var/list/entry = print_log[i]
		if (!islist(entry))
			continue
		out += list(entry)
	return out


/obj/machinery/fabricator/proc/print_log_status_label()
	if (stat & MACHINE_STAT_NOPOWER)
		return "No power"
	if (fab_status_flags & FAB_DISABLED)
		return "Disabled"
	if (!print_log_network || (fab_status_flags & FAB_OFFLINE))
		return "Offline (telemetry)"
	if (print_log_corrupt && length(print_log) <= 1)
		return "Journal damaged"
	if (working)
		return "Printing"
	return "Online"


#undef AUTOLATHE_PRINT_LOG_MAX
