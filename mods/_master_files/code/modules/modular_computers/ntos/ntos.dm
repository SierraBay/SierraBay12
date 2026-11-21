// TRADE: ensure TGUI trade windows close when minimizing or closing NTOS program windows.
/datum/extension/interactive/ntos/minimize_program(datum/computer_file/program/program_to_minimize, mob/user = null)
	if(program_to_minimize?.trade_ui)
		SStgui.close_uis(program_to_minimize.trade_ui)
	return ..()

/datum/extension/interactive/ntos/close_extra_window(datum/computer_file/program/program)
	if(program?.trade_ui)
		SStgui.close_uis(program.trade_ui)
	return ..()

/datum/extension/interactive/ntos/close_extra_windows()
	for(var/datum/computer_file/program/program as anything in running_program_windows)
		if(program?.trade_ui)
			SStgui.close_uis(program.trade_ui)
	return ..()
