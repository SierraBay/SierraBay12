/obj/item/stock_parts/computer/hard_drive/install_default_programs()
	..()
	create_file(new /datum/computer_file/program/mars(src))

/datum/extension/interactive/ntos/proc/try_autorun_mars()
	if(!on)
		return
	var/datum/computer_file/program/mars/mars_prog = get_file("mars")
	if(!istype(mars_prog))
		return
	if(mars_prog.program_state != PROGRAM_STATE_KILLED)
		return
	run_program_remote("mars")

/obj/item/modular_computer/enable_computer(mob/user = null)
	enabled = TRUE
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(os)
		os.system_boot()
		os.try_autorun_mars()

	update_icon()

	if(user)
		ui_interact(user)

/datum/extension/interactive/ntos/console/system_boot()
	..()
	var/obj/machinery/M = holder
	M.update_use_power(POWER_USE_ACTIVE)
	try_autorun_mars()
