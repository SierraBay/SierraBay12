/datum/extension/interactive/ntos/ai
	expected_type = /mob/living/silicon/ai

/datum/extension/interactive/ntos/ai/get_hardware_flag()
	return PROGRAM_CONSOLE

/datum/extension/interactive/ntos/ai/get_component(part_type)
	var/mob/living/silicon/ai/AI = holder
	var/obj/machinery/computer/modular/C = AI.internal_computer
	if(C)
		return C.get_component_of_type(part_type)

/datum/extension/interactive/ntos/ai/get_all_components()
	var/mob/living/silicon/ai/AI = holder
	var/obj/machinery/computer/modular/C = AI.internal_computer
	if(C)
		return C.component_parts.Copy()
	return list()

/datum/extension/interactive/ntos/ai/host_status()
	var/mob/living/silicon/ai/AI = holder
	return AI.has_power() && !AI.stat

/datum/extension/interactive/ntos/ai/get_power_usage()
	var/mob/living/silicon/ai/AI = holder
	var/obj/machinery/computer/modular/C = AI.internal_computer
	if(C)
		return C.get_power_usage()
	return 0

/datum/extension/interactive/ntos/ai/recalc_power_usage()
	var/mob/living/silicon/ai/AI = holder
	var/obj/machinery/computer/modular/C = AI.internal_computer
	if(C)
		C.RefreshParts()

/datum/extension/interactive/ntos/ai/emagged()
	var/mob/living/silicon/ai/AI = holder
	return AI.malfunctioning
