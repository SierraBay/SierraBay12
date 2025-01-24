/datum/event/rnd_design_leak
	announceWhen	= 21

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine
	var/nid


/datum/event/rnd_design_leak/announce()
	command_announcement.Announce("Unusual activity has been detected in Research and Development network. A design leak has been detected in [nid]. Please investigate.", "Research and Development Network")


/datum/event/rnd_design_leak/start()
	var/ndesigns = rand(1,10)
	nid = pick(ntnet_global.registered_nids)
	var/datum/extension/interactive/ntos/os = ntnet_global.registered_nids[nid]
	var/area/A = get_area(os.get_physical_host())
	for(var/obj/machinery/r_n_d/server/S in rnd_server_list)
		if(GLOB.using_map.use_overmap && !(A.z in GetConnectedZlevels(S.z)))
			break
		if(S.disabled)
			continue
		if((!istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
			while(ndesigns > 0)
				ndesigns--
				var/datum/design/D = pick(S.files)
				os.create_file(D)
				S.produce_heat(500)
