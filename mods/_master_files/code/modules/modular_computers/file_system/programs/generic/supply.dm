// TRADE: legacy supply installations keep working via Frontier Trade TGUI without exposing the retired Sierra shuttle UI.
/datum/computer_file/program/supply/New()
	..()
	if(GLOB.using_map?.path == "sierra" && GLOB.using_map?.use_overmap)
		available_on_ntnet = FALSE

/datum/computer_file/program/supply/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	if(SStrade.enabled)
		nanomodule_path = null
		. = ..()
		if(.)
			trade_ui = new /datum/tgui_module/trade(new_host, src)
		return
	return ..()

/datum/computer_file/program/supply/on_shutdown(forced = 0)
	if(trade_ui)
		SStgui.close_uis(trade_ui)
		QDEL_NULL(trade_ui)
	return ..()

/datum/computer_file/program/supply/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!SStrade.enabled)
		return ..()
	if(program_state != PROGRAM_STATE_ACTIVE)
		if(trade_ui)
			SStgui.close_uis(trade_ui)
		return computer?.ui_interact(user, ui_key, null, force_open)
	if(!trade_ui && computer)
		trade_ui = new /datum/tgui_module/trade(computer, src)
	if(trade_ui)
		trade_ui.tgui_interact(user)
		return FALSE
	return TRUE
