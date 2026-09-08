/obj/machinery/radiocarbon_spectrometer
	name = "radiocarbon spectrometer"
	desc = "A specialised, complex scanner for gleaning information on all manner of small things."
	anchored = TRUE
	density = TRUE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	icon = 'icons/obj/machines/research/virology.dmi'
	icon_state = "analyser"

	idle_power_usage = 20
	active_power_usage = 300

	var/scanning = 0
	var/last_scan_data = "No scans on record."
	//
	var/last_process_worldtime = 0
	//
	var/scanner_progress = 0
	var/scanner_rate = 1.25			//80 seconds per scan
	var/scanner_rpm = 0
	var/scanner_rpm_dir = 1
	var/scanner_temperature = 0
	var/scanner_seal_integrity = 100
	//
	var/coolant_usage_rate = 0		//measured in u/microsec
	var/fresh_coolant = 0
	var/coolant_purity = 0
	var/used_coolant = 0
	var/list/coolant_reagents_purity = list()
	//
	var/maser_wavelength = 0
	var/optimal_wavelength = 0
	var/optimal_wavelength_target = 0
	var/tleft_retarget_optimal_wavelength = 0
	var/maser_efficiency = 0
	//
	var/radiation = 0				//0-100 mSv
	var/t_left_radspike = 0
	var/rad_shield = 0
	// Scan mode — controlled by a remote console (artifact_analyser)
	var/scan_mode = "idle"			// "idle" or "external" (object on linked pad)
	var/obj/machinery/artifact_scanpad/linked_pad
	var/obj/machinery/artifact_analyser/remote_console
	var/obj/scanned_object			// object on the pad being scanned externally

/obj/machinery/radiocarbon_spectrometer/New()
	..()
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

/obj/machinery/radiocarbon_spectrometer/Destroy()
	if(remote_console)
		remote_console.linked_spectrometer = null
		remote_console = null
	linked_pad = null
	return ..()

/obj/machinery/radiocarbon_spectrometer/proc/sync_with_pad()
	for(var/obj/machinery/artifact_scanpad/pad in range(2, src))
		linked_pad = pad
		return TRUE
	return FALSE

/obj/machinery/radiocarbon_spectrometer/proc/start_external_scan(obj/target)
	if(scanning)
		return FALSE
	if(scanner_seal_integrity <= 0)
		return FALSE
	if(!target)
		return FALSE
	scanned_object = target
	scan_mode = "external"
	scanning = 1
	scanner_progress = 0
	t_left_radspike = pick(5, 10, 15)
	last_process_worldtime = world.time
	return TRUE

/obj/machinery/radiocarbon_spectrometer/proc/halt_external_scan()
	if(scan_mode != "external")
		return
	stop_scanning()

/obj/machinery/radiocarbon_spectrometer/proc/on_external_scan_complete()
	if(remote_console)
		remote_console.complete_scan()
	stop_scanning()

/obj/machinery/radiocarbon_spectrometer/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/radiocarbon_spectrometer/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(scanning)
		to_chat(user, SPAN_WARNING("You can't do that while [src] is scanning!"))
		return TRUE

	if ((. = ..()))
		return

	if (istype(I, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = I
		var/amount_used = min(N.get_amount(), 10 - scanner_seal_integrity / 10)
		N.use(amount_used)
		scanner_seal_integrity = round(scanner_seal_integrity + amount_used * 10)
		to_chat(user, SPAN_NOTICE("You apply nanopaste to \the [src]'s seal. Integrity: [round(scanner_seal_integrity)]%"))
		return TRUE

	if (istype(I, /obj/item/reagent_containers/glass))
		var/choice = alert("What do you want to do with the container?","Radiometric Scanner","Add coolant","Empty coolant")
		if(choice == "Add coolant")
			var/obj/item/reagent_containers/glass/G = I
			var/amount_transferred = min(reagents.maximum_volume - reagents.total_volume, G.reagents.total_volume)
			G.reagents.trans_to(src, amount_transferred)
			to_chat(user, SPAN_INFO("You empty [amount_transferred]u of coolant into \the [src]."))
			update_coolant()
			return TRUE
		else if(choice == "Empty coolant")
			var/obj/item/reagent_containers/glass/G = I
			var/amount_transferred = min(G.reagents.maximum_volume - G.reagents.total_volume, src.reagents.total_volume)
			reagents.trans_to(G, amount_transferred)
			to_chat(user, SPAN_INFO("You remove [amount_transferred]u of coolant from \the [src]."))
			update_coolant()
			return TRUE

/obj/machinery/radiocarbon_spectrometer/proc/update_coolant()
	var/total_purity = 0
	fresh_coolant = 0
	coolant_purity = 0
	for (var/datum/reagent/current_reagent in src.reagents.reagent_list)
		if (!current_reagent)
			continue
		var/cur_purity = coolant_reagents_purity[current_reagent.type]
		if(!cur_purity)
			cur_purity = 0.1
		else if(cur_purity > 1)
			cur_purity = 1
		total_purity += cur_purity * current_reagent.volume
		fresh_coolant += current_reagent.volume
	if(total_purity && fresh_coolant)
		coolant_purity = total_purity / fresh_coolant

/obj/machinery/radiocarbon_spectrometer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)

	if(user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["last_scan_data"] = last_scan_data
	//
	data["scan_progress"] = round(scanner_progress)
	data["scanning"] = scanning
	//
	data["scanner_seal_integrity"] = round(scanner_seal_integrity)
	data["scanner_rpm"] = round(scanner_rpm)
	data["scanner_temperature"] = round(scanner_temperature)
	//
	data["coolant_usage_rate"] = "[coolant_usage_rate]"
	data["unused_coolant_abs"] = round(fresh_coolant)
	data["unused_coolant_per"] = round(fresh_coolant / reagents.maximum_volume * 100)
	data["coolant_purity"] = "[coolant_purity * 100]"
	//
	data["optimal_wavelength"] = round(optimal_wavelength)
	data["maser_wavelength"] = round(maser_wavelength)
	data["maser_efficiency"] = round(maser_efficiency * 100)
	//
	data["radiation"] = round(radiation)
	data["t_left_radspike"] = round(t_left_radspike)
	data["rad_shield_on"] = rad_shield
	//
	data["pad_linked"] = !!linked_pad
	// Find target name on pad
	var/pad_target_name = ""
	if(linked_pad)
		for(var/obj/O in linked_pad.loc)
			if(O == linked_pad || O.invisibility)
				continue
			if(istype(O, /obj/machinery) && !istype(O, /obj/machinery/artifact))
				continue
			pad_target_name = O.name
			break
		if(!pad_target_name)
			for(var/obj/item/I in linked_pad.loc)
				pad_target_name = I.name
				break
	data["pad_target"] = pad_target_name

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "geoscanner.tmpl", "High Res Radiocarbon Spectrometer", 900, 825)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/radiocarbon_spectrometer/Process()
	if(scanning)
		// Validate scan target on pad
		if(!linked_pad || !scanned_object || scanned_object.loc != linked_pad.loc)
			if(remote_console)
				remote_console.on_scan_lost()
			stop_scanning()
			last_process_worldtime = world.time
			return
		if(scanner_progress >= 100)
			on_external_scan_complete()
			last_process_worldtime = world.time
			return

		do_scan_tick()
	else
		//gradually cool down over time
		if(scanner_temperature > 0)
			scanner_temperature = max(scanner_temperature - 5 - 10 * rand(), 0)
		if(prob(0.75))
			src.visible_message(SPAN_NOTICE("[icon2html(src, viewers(get_turf(src)))] [pick("plinks","hisses")][pick(" quietly"," softly"," sadly"," plaintively")]."), 2)
	last_process_worldtime = world.time

/obj/machinery/radiocarbon_spectrometer/proc/do_scan_tick()
	var/deltaT = (world.time - last_process_worldtime) * 0.1

	//modify the RPM over time
	scanner_rpm += scanner_rpm_dir * 50 * deltaT
	if(scanner_rpm > 1000)
		scanner_rpm = 1000
		scanner_rpm_dir = -1 * pick(0.5, 2.5, 5.5)
	else if(scanner_rpm < 1)
		scanner_rpm = 1
		scanner_rpm_dir = 1 * pick(0.5, 2.5, 5.5)

	//heat up according to RPM
	scanner_temperature += scanner_rpm * deltaT * 0.05

	//radiation
	t_left_radspike -= deltaT
	if(t_left_radspike > 0)
		radiation = rand() * 15
	else
		if(t_left_radspike > -5)
			radiation = rand() * 15 + 85
			if(!rad_shield)
				SSradiation.radiate(src, radiation / 12.5)
		else
			t_left_radspike = pick(10,15,25)

	//use some coolant to cool down
	if(coolant_usage_rate > 0)
		var/coolant_used = min(fresh_coolant, coolant_usage_rate * deltaT)
		if(coolant_used > 0)
			fresh_coolant -= coolant_used
			used_coolant += coolant_used
			scanner_temperature = max(scanner_temperature - coolant_used * coolant_purity * 20, 0)

	//modify the optimal wavelength
	tleft_retarget_optimal_wavelength -= deltaT
	if(tleft_retarget_optimal_wavelength <= 0)
		tleft_retarget_optimal_wavelength = pick(4,8,15)
		optimal_wavelength_target = rand() * 9900 + 100
	if(optimal_wavelength < optimal_wavelength_target)
		optimal_wavelength = min(optimal_wavelength + 700 * deltaT, optimal_wavelength_target)
	else if(optimal_wavelength > optimal_wavelength_target)
		optimal_wavelength = max(optimal_wavelength - 700 * deltaT, optimal_wavelength_target)
	maser_efficiency = 1 - max(min(10000, abs(optimal_wavelength - maser_wavelength) * 3), 1) / 10000

	//make some scan progress
	if(!rad_shield)
		scanner_progress = min(100, scanner_progress + scanner_rate * maser_efficiency * deltaT)
		//degrade the seal over time according to temperature
		scanner_seal_integrity -= (max(scanner_temperature, 1) / 1000) * deltaT

	//emergency stop if seal integrity reaches 0
	if(scanner_seal_integrity <= 0 || (scanner_temperature >= 1273 && !rad_shield))
		if(remote_console)
			remote_console.on_scan_lost()
		stop_scanning()
		src.visible_message(SPAN_NOTICE("[icon2html(src, viewers(get_turf(src)))] buzzes unhappily. It has failed mid-scan!"), 2)
		return

	if(prob(5))
		src.visible_message(SPAN_NOTICE("[icon2html(src, viewers(get_turf(src)))] [pick("whirrs","chuffs","clicks")][pick(" excitedly"," energetically"," busily")]."), 2)

/obj/machinery/radiocarbon_spectrometer/proc/stop_scanning()
	scanning = 0
	scan_mode = "idle"
	scanner_rpm_dir = 1
	scanner_rpm = 0
	scanner_progress = 0
	optimal_wavelength = 0
	maser_efficiency = 0
	maser_wavelength = 0
	coolant_usage_rate = 0
	radiation = 0
	t_left_radspike = 0
	scanned_object = null
	if(used_coolant)
		src.reagents.remove_any(used_coolant)
		used_coolant = 0

/obj/machinery/radiocarbon_spectrometer/OnTopic(user, href_list)
	if(href_list["maserWavelength"])
		maser_wavelength = max(min(maser_wavelength + 1000 * text2num(href_list["maserWavelength"]), 10000), 1)
		. = TOPIC_REFRESH

	else if(href_list["coolantRate"])
		coolant_usage_rate = max(min(coolant_usage_rate + text2num(href_list["coolantRate"]), 10000), 0)
		. = TOPIC_REFRESH

	else if(href_list["toggle_rad_shield"])
		if(rad_shield)
			rad_shield = 0
		else
			rad_shield = 1
		. = TOPIC_REFRESH

	else if(href_list["begin_external_scan"])
		if(remote_console)
			remote_console.begin_scan()
		. = TOPIC_REFRESH

	else if(href_list["halt_external_scan"])
		if(remote_console)
			remote_console.halt_scan()
		. = TOPIC_REFRESH

	else if(href_list["sync_pad"])
		sync_with_pad()
		. = TOPIC_REFRESH
