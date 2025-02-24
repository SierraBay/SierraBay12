
/datum/event/rnd_design_leak
	announceWhen	= 21
	var/list/nids
	var/tries_count = 35
	var/datum/extension/interactive/ntos/os
	var/area/loc
	var/turf/zos
	var/nid_leak
	var/list/server_leaked


/datum/event/rnd_design_leak/start()
	var/ndesigns = rand(3,12)

	for (var/nid in ntnet_global.registered_nids)
		var/datum/extension/interactive/ntos/comp = ntnet_global.get_os_by_nid(nid)
		if (comp && comp.get_ntnet_status_incoming())
			if(comp.get_hardware_flag() & (PROGRAM_CONSOLE | PROGRAM_LAPTOP |  PROGRAM_TELESCREEN))
				nids += list(nid)
	nid_leak = pick(nids)
	if(!nid_leak)
		return
	os = ntnet_global.registered_nids[nid_leak]
	loc = get_area(os.get_physical_host())
	zos = get_turf(os.get_physical_host())
	if(!zos)
		return
	for(var/obj/machinery/r_n_d/server/server in rnd_server_list)
		if(server.stat & MACHINE_STAT_NOPOWER)
			continue
		if(server.z in GetConnectedZlevels(zos.z))
			server_leaked += list(server)
	var/obj/machinery/r_n_d/server/download_from_server = pick(server_leaked)
	while(ndesigns > 0)
		ndesigns--
		var/datum/design/D = pick(download_from_server.files.known_designs)
		var/datum/computer_file/binary/design/design_file = D.file
		os.save_file(design_file)
		download_from_server.produce_heat(400)
	command_announcement.Announce("Unusual activity has been detected in Research and Development network. A design leak has been detected. Possible design leak in [nid_leak] nid: estimated location: [(loc ? sanitize(loc.name) : "Unknown")]. Please investigate.", "Research and Development Network")
