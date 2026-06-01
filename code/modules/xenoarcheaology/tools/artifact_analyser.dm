/obj/machinery/artifact_analyser
	name = "Anomaly Analyser"
	desc = "Studies the emissions of anomalous materials to discover their uses."
	icon = 'icons/obj/machines/research/xenoarcheology_scanner.dmi'
	icon_state = "xenoarch_console"
	anchored = TRUE
	density = TRUE
	var/scan_in_progress = FALSE
	var/scan_num = 0
	var/obj/scanned_obj
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/obj/scanned_object
	var/report_num = 0
	var/list/data = list("screen" = 1)
	// Scan progress mechanics (ported from radiocarbon_spectrometer)
	var/last_process_worldtime = 0
	var/scanner_progress = 0
	var/scanner_rate = 0.8				// ~125 seconds per scan at full efficiency
	var/scanner_rpm = 0
	var/scanner_rpm_dir = 1
	var/scanner_temperature = 0
	var/scanner_seal_integrity = 100
	// Coolant system
	var/coolant_usage_rate = 0
	var/fresh_coolant = 0
	var/coolant_purity = 0
	var/used_coolant = 0
	var/list/coolant_reagents_purity = list()
	// Maser wavelength tuning
	var/maser_wavelength = 0
	var/optimal_wavelength = 0
	var/optimal_wavelength_target = 0
	var/tleft_retarget_optimal_wavelength = 0
	var/maser_efficiency = 0
	// Radiation
	var/radiation = 0
	var/t_left_radspike = 0
	var/rad_shield = 0

/obj/machinery/artifact_analyser/Initialize()
	. = ..()
	create_reagents(500)
	coolant_reagents_purity[/datum/reagent/water] = 0.5
	coolant_reagents_purity[/datum/reagent/drink/coffee/icecoffee] = 0.6
	coolant_reagents_purity[/datum/reagent/drink/tea/icetea] = 0.6
	coolant_reagents_purity[/datum/reagent/drink/milkshake] = 0.6
	coolant_reagents_purity[/datum/reagent/leporazine] = 0.7
	coolant_reagents_purity[/datum/reagent/kelotane] = 0.7
	coolant_reagents_purity[/datum/reagent/sterilizine] = 0.7
	coolant_reagents_purity[/datum/reagent/dermaline] = 0.7
	coolant_reagents_purity[/datum/reagent/hyperzine] = 0.8
	coolant_reagents_purity[/datum/reagent/cryoxadone] = 0.9
	coolant_reagents_purity[/datum/reagent/coolant] = 1
	coolant_reagents_purity[/datum/reagent/adminordrazine] = 2
	sync_with_pad()

/obj/machinery/artifact_analyser/Destroy()
	stop_scanning()
	return ..()

/obj/machinery/artifact_analyser/proc/reconnect_scanner()
	sync_with_pad()

/obj/machinery/artifact_analyser/DefaultTopicState()
	return GLOB.physical_state

/obj/machinery/artifact_analyser/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/artifact_analyser/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(istype(I, /obj/item/stack/nanopaste))
		var/choice = alert("What do you want to do with the nanopaste?", "Anomaly Analyser", "Fix seal integrity", "Cancel")
		if(choice == "Fix seal integrity")
			var/obj/item/stack/nanopaste/N = I
			var/amount_used = min(N.get_amount(), 10 - scanner_seal_integrity / 10)
			if(amount_used <= 0)
				to_chat(user, SPAN_NOTICE("\The [src]'s seal is already in perfect condition."))
				return TRUE
			N.use(amount_used)
			scanner_seal_integrity = round(scanner_seal_integrity + amount_used * 10)
			to_chat(user, SPAN_NOTICE("You patch the seal of \the [src]. Seal integrity: [round(scanner_seal_integrity)]%."))
		return TRUE

	if(istype(I, /obj/item/reagent_containers/glass))
		var/choice = alert("What do you want to do with the container?", "Anomaly Analyser", "Add coolant", "Empty coolant", "Cancel")
		if(choice == "Add coolant")
			var/obj/item/reagent_containers/glass/G = I
			var/amount_transferred = min(reagents.maximum_volume - reagents.total_volume, G.reagents.total_volume)
			G.reagents.trans_to(src, amount_transferred)
			to_chat(user, SPAN_INFO("You add [amount_transferred]u of coolant to \the [src]."))
			update_coolant()
			return TRUE
		else if(choice == "Empty coolant")
			var/obj/item/reagent_containers/glass/G = I
			var/amount_transferred = min(G.reagents.maximum_volume - G.reagents.total_volume, src.reagents.total_volume)
			reagents.trans_to(G, amount_transferred)
			to_chat(user, SPAN_INFO("You remove [amount_transferred]u of coolant from \the [src]."))
			update_coolant()
			return TRUE

	return ..()

/obj/machinery/artifact_analyser/proc/update_coolant()
	var/total_purity = 0
	fresh_coolant = 0
	coolant_purity = 0
	var/num_reagent_types = 0
	for(var/datum/reagent/current_reagent in src.reagents.reagent_list)
		if(!current_reagent)
			continue
		var/cur_purity = coolant_reagents_purity[current_reagent.type]
		if(!cur_purity)
			cur_purity = 0.1
		else if(cur_purity > 1)
			cur_purity = 1
		total_purity += cur_purity * current_reagent.volume
		fresh_coolant += current_reagent.volume
		num_reagent_types += 1
	if(total_purity && fresh_coolant)
		coolant_purity = total_purity / fresh_coolant

/obj/machinery/artifact_analyser/interact(mob/user)
	if(!owned_scanner)
		reconnect_scanner()

	var/pad_status = "No scan pad linked."
	var/target_name = "None"
	if(owned_scanner)
		pad_status = "Pad linked."
		for(var/obj/O in owned_scanner.loc)
			if(O == owned_scanner || O.invisibility)
				continue
			target_name = O.name
			break

	var/dat = "<b>Anomalous Material Analyser</b><hr>"

	// Status
	dat += "<b>Scan pad:</b> [pad_status]<br>"
	dat += "<b>Scan target:</b> [target_name]<br>"
	dat += "<b>Seal integrity:</b> [round(scanner_seal_integrity)]% "
	if(scanner_seal_integrity < 30)
		dat += "<font color='red'>(CRITICAL - use nanopaste)</font>"
	else if(scanner_seal_integrity < 60)
		dat += "<font color='orange'>(degraded)</font>"
	dat += "<br>"
	dat += "<hr>"

	// Scan progress
	dat += "<b>Scan progress:</b> [round(scanner_progress)]%<br>"
	if(scan_in_progress)
		dat += "<b>Scanner RPM:</b> [round(scanner_rpm)]<br>"
		dat += "<b>Temperature:</b> [round(scanner_temperature)] K<br>"
		dat += "<b>Radiation:</b> [round(radiation)] mSv<br>"
		dat += "<hr>"
	dat += "<hr>"

	// Maser controls
	dat += "<b>Maser wavelength:</b> [round(maser_wavelength)] nm "
	dat += "(<a href='byond://?src=\ref[src];maserWavelength=-1'>-1000</a> | <a href='byond://?src=\ref[src];maserWavelength=1'>+1000</a>)<br>"
	if(scan_in_progress)
		dat += "<b>Optimal wavelength:</b> [round(optimal_wavelength)] nm<br>"
		dat += "<b>Maser efficiency:</b> [round(maser_efficiency * 100)]%<br>"
	dat += "<hr>"

	// Coolant controls
	dat += "<b>Coolant:</b> [round(fresh_coolant)]u / [reagents.maximum_volume]u"
	if(fresh_coolant > 0)
		dat += " (purity: [round(coolant_purity * 100)]%)"
	dat += "<br>"
	dat += "<b>Coolant flow rate:</b> [coolant_usage_rate] u/s "
	dat += "(<a href='byond://?src=\ref[src];coolantRate=-1'>-1</a> | <a href='byond://?src=\ref[src];coolantRate=1'>+1</a> | <a href='byond://?src=\ref[src];coolantRate=-10'>-10</a> | <a href='byond://?src=\ref[src];coolantRate=10'>+10</a>)<br>"
	dat += "<hr>"

	// Rad shield
	dat += "<b>Radiation shield:</b> [rad_shield ? "<font color='green'>ON</font> (slows scan)" : "<font color='red'>OFF</font>"] "
	dat += "(<a href='byond://?src=\ref[src];toggle_rad_shield=1'>Toggle</a>)<br>"
	dat += "<hr>"

	// Main action
	if(scan_in_progress)
		dat += "<a href='byond://?src=\ref[src];halt_scan=1'><b>Halt scanning</b></a><br>"
	else
		if(scanner_seal_integrity > 0)
			dat += "<a href='byond://?src=\ref[src];begin_scan=1'><b>Begin scanning</b></a><br>"
		else
			dat += "<font color='red'>Cannot scan: seal requires replacement (use nanopaste).</font><br>"

	dat += "<br><a href='byond://?src=\ref[src];syncpads=1'>Sync with nearby pad</a><br>"
	dat += "<a href='byond://?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "artanalyser", "Anomaly Analyser", 450, 550)
	popup.set_content(dat)
	popup.open()
	user.set_machine(src)
	onclose(user, "artanalyser")

/obj/machinery/artifact_analyser/Process()
	if(scan_in_progress)
		if(!owned_scanner)
			reconnect_scanner()
		if(!owned_scanner || !scanned_object || scanned_object.loc != owned_scanner.loc)
			stop_scanning()
			src.visible_message("<b>[name]</b> states, \"Scan target lost. Scanning aborted.\"")
			last_process_worldtime = world.time
			return

		if(scanner_progress >= 100)
			complete_scan()
			last_process_worldtime = world.time
			return

		var/deltaT = (world.time - last_process_worldtime) * 0.1

		// RPM fluctuation
		scanner_rpm += scanner_rpm_dir * 50 * deltaT
		if(scanner_rpm > 1000)
			scanner_rpm = 1000
			scanner_rpm_dir = -1 * pick(0.5, 2.5, 5.5)
		else if(scanner_rpm < 1)
			scanner_rpm = 1
			scanner_rpm_dir = 1 * pick(0.5, 2.5, 5.5)

		// Heat up from RPM
		scanner_temperature += scanner_rpm * deltaT * 0.05

		// Radiation spikes
		t_left_radspike -= deltaT
		if(t_left_radspike > 0)
			radiation = rand() * 15
		else
			if(t_left_radspike > -5)
				radiation = rand() * 15 + 85
				if(!rad_shield)
					SSradiation.radiate(src, radiation / 12.5)
			else
				t_left_radspike = pick(10, 15, 25)

		// Coolant consumption
		if(coolant_usage_rate > 0)
			var/coolant_used = min(fresh_coolant, coolant_usage_rate * deltaT)
			if(coolant_used > 0)
				fresh_coolant -= coolant_used
				used_coolant += coolant_used
				scanner_temperature = max(scanner_temperature - coolant_used * coolant_purity * 20, 0)

		// Shift optimal wavelength periodically
		tleft_retarget_optimal_wavelength -= deltaT
		if(tleft_retarget_optimal_wavelength <= 0)
			tleft_retarget_optimal_wavelength = pick(4, 8, 15)
			optimal_wavelength_target = rand() * 9900 + 100
		if(optimal_wavelength < optimal_wavelength_target)
			optimal_wavelength = min(optimal_wavelength + 700 * deltaT, optimal_wavelength_target)
		else if(optimal_wavelength > optimal_wavelength_target)
			optimal_wavelength = max(optimal_wavelength - 700 * deltaT, optimal_wavelength_target)
		maser_efficiency = 1 - max(min(10000, abs(optimal_wavelength - maser_wavelength) * 3), 1) / 10000

		// Make progress (rad shield blocks scanning)
		if(!rad_shield)
			scanner_progress = min(100, scanner_progress + scanner_rate * maser_efficiency * deltaT)
			scanner_seal_integrity -= (max(scanner_temperature, 1) / 1000) * deltaT

		// Emergency stop on critical failure
		if(scanner_seal_integrity <= 0 || (scanner_temperature >= 1273 && !rad_shield))
			stop_scanning()
			src.visible_message("<b>[name]</b> states, \"Critical containment failure. Scanning aborted.\"")
			last_process_worldtime = world.time
			return

		if(prob(5))
			src.visible_message("<b>[name]</b> [pick("whirrs","chuffs","clicks")][pick(" excitedly"," energetically"," busily")].")
	else
		// Idle: gradually cool down
		if(scanner_temperature > 0)
			scanner_temperature = max(scanner_temperature - 5 - 10 * rand(), 0)
		if(prob(0.75))
			src.visible_message("<b>[name]</b> [pick("plinks","hisses")][pick(" quietly"," softly"," plaintively")].")

	last_process_worldtime = world.time

/obj/machinery/artifact_analyser/proc/complete_scan()
	src.visible_message("<b>[name]</b> states, \"Scanning complete.\"")

	var/results = ""
	if(!owned_scanner)
		reconnect_scanner()
	if(!owned_scanner)
		results = "Error communicating with scanner."
	else if(!scanned_object || scanned_object.loc != owned_scanner.loc)
		results = "Unable to locate scanned object. Ensure it was not moved during the process."
	else
		results = get_scan_info(scanned_object)

	var/obj/item/paper/anomaly_scan/P = new(src.loc)
	P.SetName("[src] report #[++report_num]")
	P.info = "<b>[src] analysis report #[report_num]</b><br>"
	P.info += "<br>"
	P.info += "\icon[scanned_object] [results]"
	P.stamped = list(/obj/item/stamp)
	P.queue_icon_update()
	P.is_copy = FALSE

	if(scanned_object && istype(scanned_object, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = scanned_object
		//[SIERRA-ADD] - MODPACK_RND
		P.artifact = A.name
		if(A.my_effect)
			P.my_effect = A.my_effect.name
		if(A.secondary_effect)
			P.secondary_effect = A.secondary_effect.name
		if(istype(A, /obj/machinery/artifact/mission))
			var/obj/machinery/artifact/mission/MA = A
			MA.on_analysis_complete()
		//[/SIERRA-ADD] - MODPACK_RND
		A.being_used = 0
	stop_scanning()
	updateDialog()

/obj/machinery/artifact_analyser/proc/stop_scanning()
	scan_in_progress = FALSE
	scanner_rpm_dir = 1
	scanner_rpm = 0
	scanner_progress = 0
	optimal_wavelength = 0
	maser_efficiency = 0
	maser_wavelength = 0
	coolant_usage_rate = 0
	radiation = 0
	t_left_radspike = 0
	if(used_coolant)
		src.reagents.remove_any(used_coolant)
		used_coolant = 0
	if(!scanned_object)
		return
	if(istype(scanned_object, /obj/machinery/artifact))
		var/obj/machinery/artifact/artifact = scanned_object
		artifact.anchored = FALSE
		artifact.being_used = FALSE
	scanned_object = null

/obj/machinery/artifact_analyser/OnTopic(user, href_list)
	if(href_list["begin_scan"])
		if(!owned_scanner)
			reconnect_scanner()
		if(owned_scanner)
			var/artifact_in_use = FALSE
			for(var/obj/O in owned_scanner.loc)
				if(O == owned_scanner)
					continue
				if(O.invisibility)
					continue
				if(istype(O, /obj/machinery/artifact))
					var/obj/machinery/artifact/artifact = O
					if(artifact.being_used)
						artifact_in_use = TRUE
					else
						artifact.anchored = TRUE
						artifact.being_used = TRUE

				if(artifact_in_use)
					src.visible_message("<b>[name]</b> states, \"Cannot scan. Too much interference.\"")
				else
					scanned_object = O
					scan_in_progress = TRUE
					scanner_progress = 0
					t_left_radspike = pick(5, 10, 15)
					last_process_worldtime = world.time
					src.visible_message("<b>[name]</b> states, \"Scanning begun.\"")
				break
			if(!scanned_object)
				src.visible_message("<b>[name]</b> states, \"Unable to isolate scan target.\"")
		. = TOPIC_REFRESH

	else if(href_list["halt_scan"])
		stop_scanning()
		src.visible_message("<b>[name]</b> states, \"Scanning halted.\"")
		. = TOPIC_REFRESH

	else if(href_list["maserWavelength"])
		maser_wavelength = max(min(maser_wavelength + 1000 * text2num(href_list["maserWavelength"]), 10000), 1)
		. = TOPIC_REFRESH

	else if(href_list["coolantRate"])
		coolant_usage_rate = max(min(coolant_usage_rate + text2num(href_list["coolantRate"]), 10000), 0)
		. = TOPIC_REFRESH

	else if(href_list["toggle_rad_shield"])
		rad_shield = !rad_shield
		. = TOPIC_REFRESH

	else if(href_list["syncpads"])
		sync_with_pad()
		. = TOPIC_REFRESH

	else if(href_list["close"])
		close_browser(user, "window=artanalyser")
		return TOPIC_HANDLED

	if(. == TOPIC_REFRESH)
		interact(user)

/obj/machinery/artifact_analyser/proc/sync_with_pad()
	for(var/obj/machinery/artifact_scanpad/scanner in range(5, src))
		owned_scanner = scanner
		src.visible_message("<b>[name]</b> states, \"Pad located, commencing sync.\"")
		return
	src.visible_message("<b>[name]</b> states, \"Scan unsuccessful, could not locate pad.\"")
	return

//hardcoded responses, oh well
/obj/machinery/artifact_analyser/proc/get_scan_info(obj/scanned_obj)
	switch(scanned_obj.type)
		if(/obj/machinery/auto_cloner)
			return "Automated cloning pod - appears to rely on an artificial ecosystem formed by semi-organic nanomachines and the contained liquid.<br>The liquid resembles protoplasmic residue supportive of unicellular organism developmental conditions.<br>The structure is composed of a titanium alloy."
		if(/obj/machinery/power/supermatter)
			return "Superdense phoron clump - appears to have been shaped or hewn, structure is composed of matter aproximately 20 times denser than ordinary refined phoron."
		if(/obj/structure/constructshell)
			return "Tribal idol - subject resembles statues/emblems built by superstitious pre-warp civilisations to honour their gods. Material appears to be a rock/plastcrete composite."
		if(/obj/machinery/giga_drill)
			return "Automated mining drill - structure composed of titanium-carbide alloy, with tip and drill lines edged in an alloy of diamond and phoron."
		if(/obj/structure/cult/pylon)
			return "Tribal pylon - subject resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."
		if(/obj/machinery/replicator)
			return "Automated construction unit - subject appears to be able to synthesize various objects given a material, some with simple internal circuitry. Method unknown."
		if(/obj/machinery/artifact)
			var/obj/machinery/artifact/A = scanned_obj
			var/out = "Anomalous alien device - composed of an unknown alloy.<br><br>"

			if(A.my_effect)
				out += A.my_effect.getDescription()

			if(A.secondary_effect)
				out += "<br><br>Internal scans indicate ongoing secondary activity operating independently from primary systems.<br><br>"
				out += A.secondary_effect.getDescription()

			if (A.damage_desc)
				out += "<br><br>[A.damage_desc]"

			return out
		else
			//[SIERRA-ADD] - MODPACK_RND - switch() matches exact type only; handle /obj/machinery/artifact subtypes here
			if(istype(scanned_obj, /obj/machinery/artifact))
				var/obj/machinery/artifact/A = scanned_obj
				var/out = "Anomalous alien device - composed of an unknown alloy.<br><br>"
				if(A.my_effect)
					out += A.my_effect.getDescription()
				if(A.secondary_effect)
					out += "<br><br>Internal scans indicate ongoing secondary activity operating independently from primary systems.<br><br>"
					out += A.secondary_effect.getDescription()
				if(A.damage_desc)
					out += "<br><br>[A.damage_desc]"
				return out
			//[/SIERRA-ADD] - MODPACK_RND
			return "[scanned_obj.name] - mundane application."
