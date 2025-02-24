#define MINIMUM_SCIENCE_INTERVAL 120
#define MAXIMUM_SCIENCE_INTERVAL 180
#define MINIMUM_FOLDING_EVENT_INTERVAL 90
#define MAXIMUM_FOLDING_EVENT_INTERVAL 150
#define PROGRAM_STATUS_CRASHED 0
#define PROGRAM_STATUS_RUNNING 1
#define PROGRAM_STATUS_RUNNING_WARM 2
#define PROGRAM_STATUS_RUNNING_SCALDING 3

/datum/computer_file/program/folding
	filename = "fldng"
	filedesc = "FOLDING@SCIENCE"
	extended_desc = "This program uses processor cycles for science"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	size = 6
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_ALL
	nanomodule_path = /datum/nano_module/program/folding
	category = PROG_UTIL
	requires_ntnet = TRUE
	required_access = access_research

	var/started_on 			= 0 	// When the program started some science.
	var/current_interval 	= 1		// How long the current interval will be.
	var/next_event 			= 0 	// in world timeofday, when the next event is scheduled to pop.
	var/program_status		= PROGRAM_STATUS_RUNNING		// Program periodically needs a restart, increases crash chance slightly over time.
	var/crashed_at			= 0		// When the program crashed.
	var/message = ""
	var/saved_file_num = 0
	var/percentage
	processing_size = 1
	var/GQ = 1

/datum/ntnet
	var/active_miners = 0

/datum/computer_file/program/folding/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	var/obj/item/stock_parts/computer/processor_unit/C = computer.get_component(PART_CPU)
	processing_size = C.processing_power
	ntnet_global.active_miners += 1

/datum/computer_file/program/folding/on_shutdown(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	processing_size = 1
	ntnet_global.active_miners -= 1

/datum/computer_file/program/folding/Topic(href, href_list)
	. = ..()
	if(.)
		return
	. = TOPIC_REFRESH

	if(href_list["fix_crash"] && program_status == PROGRAM_STATUS_CRASHED)
		started_on += world.timeofday - crashed_at
		program_status = PROGRAM_STATUS_RUNNING

	if(href_list["start"] && started_on == 0)
		var/totalminersmodifier = 1
		started_on = world.timeofday
		if(ntnet_global.active_miners > 2 * LAZYLEN(ntnet_global.relays))
			totalminersmodifier = ntnet_global.active_miners
			current_interval = ((rand(MINIMUM_SCIENCE_INTERVAL, MAXIMUM_SCIENCE_INTERVAL) * GQ) / get_speed() * (totalminersmodifier/2)) SECONDS
			next_event = ((rand(MINIMUM_FOLDING_EVENT_INTERVAL, MAXIMUM_FOLDING_EVENT_INTERVAL) * get_speed() / (totalminersmodifier/2)) SECONDS) + world.timeofday
		else
			current_interval = ((rand(MINIMUM_SCIENCE_INTERVAL, MAXIMUM_SCIENCE_INTERVAL) * GQ) / get_speed()) SECONDS
			next_event = ((rand(MINIMUM_FOLDING_EVENT_INTERVAL, MAXIMUM_FOLDING_EVENT_INTERVAL) * get_speed()) SECONDS) + world.timeofday

	if(href_list["save"] && started_on > 0 && program_status != PROGRAM_STATUS_CRASHED)
		if(started_on + current_interval > world.timeofday)
			return TOPIC_HANDLED
		var/obj/item/stock_parts/computer/hard_drive/HDD = computer.get_component(PART_HDD)
		var/datum/computer_file/binary/sci/file = new
		file.uniquekey = (rand(0,999) + rand(0,999) + rand(0,999) + rand(0,999))
		file.size = GQ
		file.set_filename(++saved_file_num)
		HDD.create_file(file)

		started_on = 0
		current_interval = 1

	if(href_list["gq"] && started_on == 0)
		var/a = input("Please input preferable GQ size for computing. Between 1 and 16") as num
		if(!a)
			GQ = 1
		if(a > 16)
			GQ = 16
			return
		if(a < 1)
			GQ = 1
			return
		else
			GQ = a


/datum/computer_file/program/folding/process_tick() //Every 50-100 seconds, gives you a 1/3 chance of the program crashing.
	. = ..()
	if(!started_on)
		return
	var/obj/item/stock_parts/computer/processor_unit/CPU = computer.get_component(PART_CPU)
	var/obj/item/stock_parts/computer/network_card/NTCARD = computer.get_component(PART_NETWORK)
	var/obj/item/stock_parts/computer/hard_drive/HDD = computer.get_component(PART_HDD)
	if(!istype(CPU) || !CPU.check_functionality() || !istype(HDD) || !HDD.check_functionality())
		message = "A fatal hardware error has been detected."
		return
	if(!istype(NTCARD))
		message = "Network card not connected to the device. Operation aborted."
		return

	if(world.timeofday < next_event) //Checks if it's time for the next crash chance.
		return

	var/host = computer.get_physical_host()

	var/mob/living/h = holder.loc.loc

	if(program_status > PROGRAM_STATUS_CRASHED)
		if(PROGRAM_STATUS_RUNNING_SCALDING >= program_status)
			switch(rand(PROGRAM_STATUS_RUNNING,program_status))
				if(PROGRAM_STATUS_RUNNING) //Guaranteed 1 tick without crashing.
					to_chat(h, SPAN_WARNING("\The [host] starts to get very warm."))
					if (program_status == PROGRAM_STATUS_RUNNING)
						program_status = PROGRAM_STATUS_RUNNING_WARM
				if(PROGRAM_STATUS_RUNNING_WARM) //50% chance on subsequent ticks to make the program able to crash.
					to_chat(h, SPAN_WARNING("\The [host] gets scaldingly hot"))
					if(h.type in typesof(/mob/living/carbon/human))
						h.take_overall_damage(0, 0.45) //It checks holder? so that it doesn't cause a runtime error if no one is holding it.
					if (program_status == PROGRAM_STATUS_RUNNING_WARM)
						program_status = PROGRAM_STATUS_RUNNING_SCALDING
				if(PROGRAM_STATUS_RUNNING_SCALDING) //1/3 chance on all following ticks for the program to crash.
					to_chat(h, SPAN_WARNING("\The [host] pings an error chime."))
					program_status = PROGRAM_STATUS_CRASHED
					HDD.damage_health(rand (5, 15))
					CPU.damage_health(rand (10, 25))
					crashed_at = world.timeofday
		else
			program_status = PROGRAM_STATUS_CRASHED
			crashed_at = world.timeofday
	next_event = (rand(MINIMUM_FOLDING_EVENT_INTERVAL, MAXIMUM_FOLDING_EVENT_INTERVAL) SECONDS) + world.timeofday //Sets the next crash chance 50-100 seconds from now


/datum/computer_file/program/folding/on_shutdown()
	started_on = 0
	current_interval = 0
	program_status = PROGRAM_STATUS_RUNNING
	. = ..()

/datum/nano_module/program/folding
	name = "FOLDING@SCIENCE"
	var/static/list/science_strings = list(
		"Extruding Mesh Terrain",
		"Virtualizing Microprocessor",
		"Reticulating Splines",
		"Inserting Chaos Generator",
		"Reversing Polarity",
		"Unfolding Proteins",
		"Simulating Alien Abductions",
		"Scanning Pigeons",
		"Iterating Chaos Array",
		"Abstracting Supermatter",
		"Adjusting Social Network",
		"Quantizing Gravity Wells",
		"Embedding Quantum Flux",
		"Decompressing Hypercubes",
		"Regenerating Fractal Forests",
		"Optimizing Meta-Paths",
		"Coding Celestial Bodies",
		"Surfing Wave Functions",
		"Folding Orbital Trajectories",
		"Reconfiguring Crystal Lattices",
		"Iterating Temporal Loops",
		"Projecting Sonic Landscapes",
		"Transcribing Quantum Entanglements",
		"Polarizing Helical Structures",
		"Calibrating Orbital Resonance",
		"Encoding Fractal Algorithms",
		"Inverting Quantum Flux Capacitors",
		"Decoding Sonic Blueprints",
		"Disentangling Quantum Foils",
		"Tessellating Crystalline Arrays",
		"Stabilizing Wormhole Dynamics",
		"Quantizing Psycho-Social Fields",
		"Rerouting Neural Pathways",
	)

/datum/computer_file/program/folding/proc/get_speed()
	var/skill_speed_modifier = 1 + (operator_skill - SKILL_TRAINED)/(SKILL_MAX - SKILL_MIN)
	var/obj/item/stock_parts/computer/processor_unit/CPU = computer.get_component(PART_CPU)
	return CPU.processing_power * skill_speed_modifier

/datum/nano_module/program/folding/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = host.initial_data()
	var/datum/computer_file/program/folding/PRG = program
	PRG.operator_skill = user.get_skill_value(SKILL_COMPUTER)
	if(!PRG.computer)
		return

	if(PRG.message)
		data["message"] = PRG.message
	data["computing"] = !!PRG.started_on
	data["time_remaining"] = ((PRG.started_on + PRG.current_interval) - world.timeofday) / 10
	data["completed"] = PRG.started_on + PRG.current_interval <= world.timeofday
	data["crashed"] = (PRG.program_status <= PROGRAM_STATUS_CRASHED)
	data["gq"] = PRG.GQ
	data["paspmin"] = (500 * PRG.GQ)
	data["paspmax"] = (1000 * PRG.GQ)
	var/time_left = ((PRG.started_on + PRG.current_interval) - world.timeofday)
	if(time_left > 1)
		data["science_string"] = pick(science_strings)
	if(PRG.current_interval > 0)
		PRG.percentage = ((PRG.current_interval-time_left) / PRG.current_interval) * 100
	var/list/strings[0]
	for(var/j, j<10, j++)
		var/string = ""
		for(var/i, i<20, i++)
			string = "[string][prob(PRG.percentage)]"
		strings.Add(string)
	data["dos_strings"] = strings

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-sciencefolding.tmpl", name, 550, 400)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.set_auto_update(1)
		ui.open()
