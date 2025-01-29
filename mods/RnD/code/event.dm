
/datum/event/rnd_design_leak
	announceWhen	= 21

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine
	var/nid
	var/tries_count = 5
	var/datum/extension/interactive/ntos/os
	var/area/loc
	var/turf/zos

/datum/event/rnd_design_leak/start()
	var/ndesigns = rand(3,12)
	var/nidislegal = FALSE

	while(tries_count > 0 && !nidislegal)
		tries_count--
		nid = pick(ntnet_global.registered_nids)
		os = ntnet_global.registered_nids[nid]
		if(os.get_ntnet_status_incoming())
			if(os.get_hardware_flag() != PROGRAM_PDA)
				loc = get_area(os.get_physical_host())
				zos = get_turf(os.get_physical_host())
				nidislegal = TRUE
	for(var/obj/machinery/r_n_d/server/server in rnd_server_list)
		if(!(zos.z in GetConnectedZlevels(server.z)))
			break
		if(server.stat & MACHINE_STAT_NOPOWER)
			break
		if(!istype(server, /obj/machinery/r_n_d/server/centcom))
			while(ndesigns > 0)
				ndesigns--
				var/datum/design/D = pick(server.files.known_designs)
				var/datum/computer_file/binary/design/design_file = D.file
				os.save_file(design_file)
				server.produce_heat(400)
	command_announcement.Announce("Unusual activity has been detected in Research and Development network. A design leak has been detected in [nid]: Searching ... estimated location: [(loc ? sanitize(loc.name) : "Unknown")]. Please investigate.", "Research and Development Network")
