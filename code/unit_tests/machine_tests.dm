/datum/unit_test/machines_shall_obey_part_maximum
	name = "MACHINE: All mapped machines shall respect their own maximum component limit."

/datum/unit_test/machines_shall_obey_part_maximum/start_test()
	var/failed = list()
	var/passed = list()
	for(var/obj/machinery/machine as anything in SSmachines.get_all_machinery())
		if(passed[machine.type] || failed[machine.type])
			continue
		for(var/path in machine.maximum_component_parts)
			if(machine.number_of_components(path) > machine.maximum_component_parts[path])
				failed[machine.type] = TRUE
				log_bad("[log_info_line(machine)] had too many components of type [path].")
		if(!failed[machine.type])
			passed[machine.type] = TRUE

	if(length(failed))
		fail("One or more machines had too many components.")
	else
		pass("All machines respected component limits.")
	return  1

/datum/unit_test/machines_with_circuits_shall_have_construct_states
	name = "MACHINE: All mapped machines with corresponding circuits shall use construct states."

/datum/unit_test/machines_with_circuits_shall_have_construct_states/start_test()
	var/failed = list()
	var/passed = list()
	for(var/obj/machinery/machine in SSmachines.get_all_machinery())
		if(passed[machine.type] || failed[machine.type])
			continue
		var/path = machine.base_type || machine.type
		var/circuit_type = GLOB.machine_path_to_circuit_type[path]
		if(circuit_type && !machine.construct_state)
			failed[machine.type] = TRUE
			log_bad("[log_info_line(machine)] had an associated circuit of type [circuit_type] but no construction state.")
		else
			passed[machine.type] = TRUE

	if(length(failed))
		fail("One or more machines lacked a construction state despite having a circuit.")
	else
		pass("All machines with circuits had construction states.")
	return  1

/datum/unit_test/machine_construct_states_shall_be_valid
	name = "MACHINE: All mapped machines with construct states shall meet state requirements."

/datum/unit_test/machine_construct_states_shall_be_valid/start_test()
	var/failed = list()
	for(var/obj/machinery/machine as anything in SSmachines.get_all_machinery())
		if(failed[machine.type])
			continue
		if(!machine.construct_state)
			continue
		var/fail = machine.construct_state.fail_unit_test(machine)
		if(fail)
			failed[machine.type] = TRUE
			log_bad(fail)

	if(length(failed))
		fail("One or more machines had an invalid construction state.")
	else
		pass("All machines had valid construction states.")
	return  1


/datum/unit_test/portable_connector_active_processing
	name = "MACHINE: Portables connector stays on fast cadence while connected"

/datum/unit_test/portable_connector_active_processing/start_test()
	var/turf/T = get_safe_turf()
	var/obj/machinery/atmospherics/portables_connector/connector = new(T)
	var/obj/machinery/portable_atmospherics/portable = new(T)
	var/datum/pipe_network/network = new
	connector.network = network

	if(connector.is_processing != "SSmachines_lazy")
		fail("Idle connector should start in lazy processing, got [connector.is_processing].")
		qdel(network)
		qdel(portable)
		qdel(connector)
		return 1

	if(!portable.connect(connector))
		fail("Portable atmos device failed to connect to test connector.")
		qdel(network)
		qdel(portable)
		qdel(connector)
		return 1

	if(connector.is_processing != "SSmachines")
		fail("Connected connector should move to fast processing, got [connector.is_processing].")
		qdel(network)
		qdel(portable)
		qdel(connector)
		return 1

	network.update = FALSE
	connector.Process()
	if(!network.update)
		fail("Active connector did not request a pipe-network update on first fast tick.")
		qdel(network)
		qdel(portable)
		qdel(connector)
		return 1

	network.update = FALSE
	connector.Process()
	if(!network.update)
		fail("Active connector did not keep requesting network updates on subsequent fast ticks.")
		qdel(network)
		qdel(portable)
		qdel(connector)
		return 1

	portable.disconnect()
	if(connector.is_processing != "SSmachines_lazy")
		fail("Idle connector should return to lazy processing after disconnect, got [connector.is_processing].")
		qdel(network)
		qdel(portable)
		qdel(connector)
		return 1

	qdel(network)
	qdel(portable)
	qdel(connector)
	pass("Connected portables connector stays on fast cadence and falls back to lazy only when idle.")
	return 1


/datum/unit_test/supply_display_custom_redraw_invalidation
	name = "MACHINE: Supply display invalidates custom render cache on power-loss and border changes"

/datum/unit_test/supply_display_custom_redraw_invalidation/start_test()
	var/turf/T = get_safe_turf()
	var/obj/machinery/status_display/supply_display/display = new(T)
	var/datum/shuttle/autodock/ferry/supply/original_shuttle = SSsupply.shuttle
	SSsupply.shuttle = null

	display.mode = display.STATUS_DISPLAY_CUSTOM
	display.status_display_show_alert_border = FALSE
	display.update()
	var/initial_maptext = display.maptext
	if(!length(initial_maptext))
		fail("Supply display did not render custom text.")
		SSsupply.shuttle = original_shuttle
		qdel(display)
		return 1

	display.remove_display()
	if(length(display.maptext))
		fail("Supply display remove_display() did not clear rendered text.")
		SSsupply.shuttle = original_shuttle
		qdel(display)
		return 1

	display.update()
	if(display.maptext != initial_maptext)
		fail("Supply display did not redraw the same custom text after display invalidation.")
		SSsupply.shuttle = original_shuttle
		qdel(display)
		return 1

	var/base_overlay_count = length(display.overlays)
	display.status_display_show_alert_border = TRUE
	display.update()
	if(length(display.overlays) <= base_overlay_count)
		fail("Supply display did not refresh alert border when only the border signature changed.")
		SSsupply.shuttle = original_shuttle
		qdel(display)
		return 1

	SSsupply.shuttle = original_shuttle
	qdel(display)
	pass("Supply display redraws after invalidation and refreshes borders even when text stays the same.")
	return 1


/datum/unit_test/portable_turret_dormant_rescan
	name = "MACHINE: Dormant turret wakes on delayed non-movement threat rescan"

/datum/unit_test/portable_turret_dormant_rescan/start_test()
	var/turf/T = get_safe_turf()
	var/obj/machinery/porta_turret/turret = new(T)
	var/mob/living/carbon/human/target = get_named_instance(/mob/living/carbon/human, T, SPECIES_HUMAN)

	turret.check_access = FALSE
	turret.check_records = FALSE
	turret.check_arrest = FALSE
	turret.check_weapons = TRUE
	turret.use_power = POWER_USE_OFF
	turret.set_stat(MACHINE_STAT_NOPOWER, FALSE)

	var/process_result = turret.Process()
	if(process_result != PROCESS_KILL)
		fail("Unthreatening target should leave turret dormant, got [process_result].")
		qdel(target)
		qdel(turret)
		return 1

	if(!turret.dormant_rescan_pending || !turret.prox_trigger?.is_active())
		fail("Dormant turret did not arm delayed rescan and proximity monitoring.")
		qdel(target)
		qdel(turret)
		return 1

	var/obj/item/melee/baton/weapon = new(T)
	if(!target.put_in_hands(weapon))
		fail("Test target could not equip a weapon for threat escalation.")
		qdel(target)
		qdel(turret)
		return 1
	turret.dormant_rescan_wake()

	if(turret.is_processing != "SSmachines")
		fail("Dormant rescan did not wake turret back into fast processing.")
		qdel(target)
		qdel(turret)
		return 1

	if(turret.assess_living(target) == TURRET_NOT_TARGET)
		fail("Turret still does not consider the stationary armed target a valid threat after wake-up.")
		qdel(target)
		qdel(turret)
		return 1

	qdel(target)
	qdel(turret)
	pass("Dormant turret performs a delayed rescan and wakes for non-movement threat changes.")
	return 1


/datum/unit_test/holopad_active_processing_registration
	name = "MACHINE: Holopad keeps active or incoming sessions on fast processing"

/datum/unit_test/holopad_active_processing_registration/start_test()
	var/turf/T = get_safe_turf()
	var/obj/machinery/hologram/holopad/source = new(T)
	var/obj/machinery/hologram/holopad/target = new(T)
	var/mob/living/carbon/human/caller = get_named_instance(/mob/living/carbon/human, T, SPECIES_HUMAN)

	if(source.is_processing != "SSmachines_lazy" || target.is_processing != "SSmachines_lazy")
		fail("Idle holopads should initialize in lazy processing. Source=[source.is_processing] Target=[target.is_processing]")
		qdel(caller)
		qdel(target)
		qdel(source)
		return 1

	source.make_call(target, caller)
	if(target.is_processing != "SSmachines")
		fail("Incoming holopad call did not move target pad to fast processing.")
		qdel(caller)
		qdel(target)
		qdel(source)
		return 1

	target.incoming_connection = FALSE
	target.refresh_processing_registration()
	if(target.is_processing != "SSmachines")
		fail("Accepted/active holopad session should remain on fast processing.")
		qdel(caller)
		qdel(target)
		qdel(source)
		return 1

	target.caller_id = null
	target.sourcepad = null
	target.refresh_processing_registration()
	if(target.is_processing != "SSmachines_lazy")
		fail("Idle holopad should return to lazy processing after session cleanup, got [target.is_processing].")
		qdel(caller)
		qdel(target)
		qdel(source)
		return 1

	qdel(caller)
	qdel(target)
	qdel(source)
	pass("Holopads switch to fast processing for incoming/active sessions and fall back to lazy when idle.")
	return 1

/* [SIERRA-REMOVE] - MODPACK_RND
/datum/unit_test/fabricator_recipes_shall_be_buildable
	name = "MACHINE: All fabricators will be able to produce all of their recipes"
/datum/unit_test/fabricator_recipes_shall_be_buildable/start_test()
	var/failed = list()
	for(var/thing in typesof(/obj/machinery/fabricator))
		var/obj/machinery/fabricator/fab = new thing
		for(var/datum/fabricator_recipe/recipe in SSfabrication.get_recipes(fab.fabricator_class))
			for(var/mat in recipe.resources)
				if(isnull(fab.storage_capacity[mat]))
					log_bad("[fab.name] ([fab.type]) could not print [recipe.name] due to lacking [mat].")
					failed += thing
					break
		qdel(fab)
	if(length(failed))
		fail("One or more fabricators could not produce an associated recipe.")
	else
		pass("All fabricators could produce their associated recipes.")
	return  1
*/
