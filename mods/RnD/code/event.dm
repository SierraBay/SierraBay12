
/datum/event/rnd_design_leak
	announceWhen	= 21

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine
	var/nid
	var/tries_count = 20
	var/datum/extension/interactive/ntos/os

/datum/event/rnd_design_leak/start()
	var/ndesigns = rand(3,12)
	var/nidislegal = FALSE
	while(tries_count > 0 && !nidislegal)
		tries_count--
		nid = pick(ntnet_global.registered_nids)
		os = ntnet_global.registered_nids[nid]
		if(os.get_ntnet_status_incoming())
			if(os.get_hardware_flag() & !PROGRAM_PDA)
				nidislegal = TRUE

	command_announcement.Announce("Unusual activity has been detected in Research and Development network. A design leak has been detected in [nid]. Please investigate.", "Research and Development Network")
	var/area/A = get_area(os.get_physical_host())
	for(var/obj/machinery/r_n_d/server/S in rnd_server_list)
		if(GLOB.using_map.use_overmap && !(A.z in GetConnectedZlevels(S.z)))
			break
		if(S.stat & MACHINE_STAT_NOPOWER)
			continue
		if(!istype(S, /obj/machinery/r_n_d/server/centcom))
			while(ndesigns > 0)
				ndesigns--
				var/datum/design/D = pick(S.files.known_designs)
				os.create_file(D)
				S.produce_heat(400)
