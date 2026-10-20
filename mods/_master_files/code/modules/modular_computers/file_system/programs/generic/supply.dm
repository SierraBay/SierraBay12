// TRADE: legacy installations keep working without exposing the retired Sierra shuttle UI.
/datum/computer_file/program/supply/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	if(SStrade.enabled)
		nanomodule_path = /datum/nano_module/program/trade
	return ..()
