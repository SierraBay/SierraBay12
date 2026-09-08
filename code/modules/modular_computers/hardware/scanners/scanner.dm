/// This is the generic parent class, which doesn't actually do anything.
/obj/item/stock_parts/computer/scanner
	name = "scanner module"
	desc = "A generic scanner module. This one doesn't seem to do anything."
	power_usage = 50
	icon_state = "printer"
	hardware_size = 1
	critical = FALSE
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)

	/// A program type that the scanner interfaces with and attempts to install on insertion.
	var/datum/computer_file/program/scanner/driver_type = /datum/computer_file/program/scanner
	/// A driver program which has been set up to interface with the scanner.
	var/datum/computer_file/program/scanner/driver
	/// Whether scans can be run from the program directly.
	var/can_run_scan = FALSE
	/// Whether the scan output can be viewed in the program.
	var/can_view_scan = TRUE
	/// Whether the scan output can be saved to disk.
	var/can_save_scan = TRUE
	/// Color of the scan beam effect (null = no tint).
	var/scan_beam_color = null

/obj/item/stock_parts/computer/scanner/Destroy()
	do_before_uninstall()
	. = ..()

/obj/item/stock_parts/computer/scanner/proc/do_after_install(user, atom/device)
	var/datum/extension/interactive/ntos/os = get_extension(device, /datum/extension/interactive/ntos)
	if(!driver_type || !device || !os)
		return FALSE
	if(!os.has_component(PART_HDD))
		to_chat(user, "Driver installation for \the [src] failed: \the [device] lacks a hard drive.")
		return FALSE
	var/datum/computer_file/program/scanner/old_driver = os.get_file(initial(driver_type.filename))
	if(istype(old_driver))
		to_chat(user, "Drivers found on \the [device]; \the [src] has been installed.")
		old_driver.connect_scanner()
		return TRUE
	var/datum/computer_file/program/scanner/driver_file = new driver_type
	if(!os.save_file(driver_file))
		to_chat(user, "Driver installation for \the [src] failed: file could not be written to the hard drive.")
		return FALSE
	to_chat(user, "Driver software for \the [src] has been installed on \the [device].")
	driver_file.computer = os
	driver_file.connect_scanner()
	return TRUE

/obj/item/stock_parts/computer/scanner/proc/do_before_uninstall()
	if(driver)
		driver.disconnect_scanner()
	if(driver)	//In case the driver doesn't find it.
		driver = null

/obj/item/stock_parts/computer/scanner/proc/run_scan(mob/user, datum/computer_file/program/scanner/program) //For scans done from the software.

/obj/item/stock_parts/computer/scanner/proc/do_scan_animation(mob/user, atom/target)
	var/atom/beam_origin = loc ? loc : user
	var/turf/origin_turf = get_turf(beam_origin)
	var/turf/target_turf = get_turf(target)
	var/dx = (target_turf.x - origin_turf.x) * WORLD_ICON_SIZE
	var/dy = (target_turf.y - origin_turf.y) * WORLD_ICON_SIZE
	var/dist = sqrt(dx * dx + dy * dy)
	if(dist < 1)
		dist = WORLD_ICON_SIZE

	var/obj/effect/scan_effect = new /obj/effect(origin_turf)
	scan_effect.icon = 'mods/RnD/icons/device.dmi'
	scan_effect.icon_state = "scan_med"
	scan_effect.mouse_opacity = 0
	scan_effect.layer = ABOVE_OBJ_LAYER
	if(scan_beam_color)
		scan_effect.color = scan_beam_color
	var/angle = Get_Angle(origin_turf, target_turf)
	var/matrix/M = matrix()
	M.Scale(1, dist / WORLD_ICON_SIZE)
	M.Turn(angle)
	M.Translate(dx / 2, dy / 2)
	scan_effect.transform = M

	playsound(src, 'sound/effects/scanbeep.ogg', 30)
	to_chat(user, SPAN_NOTICE("Сканирование [target]..."))
	if(!do_after(user, 1 SECONDS, target))
		qdel(scan_effect)
		return FALSE
	qdel(scan_effect)
	return TRUE

/obj/item/stock_parts/computer/scanner/proc/do_on_afterattack(mob/user, atom/target, proximity)

/obj/item/stock_parts/computer/scanner/use_tool(obj/item/W, mob/living/user, list/click_params)
	do_on_attackby(user, W)
	// Nanopaste. Repair all damage if present for a single unit.
	var/obj/item/stack/S = W
	if (istype(S, /obj/item/stack/nanopaste))
		if (!health_damaged())
			to_chat(user, "\The [src] doesn't seem to require repairs.")
			return TRUE
		if (S.use(1))
			to_chat(user, "You apply a bit of \the [W] to \the [src]. It immediately repairs all damage.")
			revive_health()
		return TRUE
	// Cable coil. Works as repair method, but will probably require multiple applications and more cable.
	if (isCoil(S))
		if (!health_damaged())
			to_chat(user, "\The [src] doesn't seem to require repairs.")
			return TRUE
		if (S.use(1))
			to_chat(user, "You patch up \the [src] with a bit of \the [W].")
			restore_health(10)
		return TRUE
	return ..()

/obj/item/stock_parts/computer/scanner/proc/do_on_attackby(mob/user, atom/target)

/obj/item/stock_parts/computer/scanner/proc/can_use_scanner(mob/user, atom/target, proximity = TRUE)
	if(!check_functionality())
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!user.IsAdvancedToolUser())
		return FALSE
	if(!proximity)
		return FALSE
	return TRUE
