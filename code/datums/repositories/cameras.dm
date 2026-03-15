var/global/repository/cameras/camera_repository = new()

/proc/invalidateCameraCache()
	camera_repository.invalidate_all()

/repository/cameras
	var/list/networks
	var/list/dirty_networks
	var/invalidated = 1
	var/camera_cache_id = 1

/repository/cameras/New()
	networks = list()
	dirty_networks = list()
	..()

/repository/cameras/proc/cameras_in_network(network)
	if(!network)
		return list()
	if(invalidated)
		setup_cache()
	else if(dirty_networks[network])
		rebuild_network(network)
	var/list/network_list = networks[network]
	return network_list

/repository/cameras/proc/invalidate_all()
	networks.Cut()
	dirty_networks.Cut()
	invalidated = TRUE
	camera_cache_id = ++camera_cache_id

/repository/cameras/proc/invalidate_networks(list/networks_to_invalidate)
	if(invalidated)
		camera_cache_id = ++camera_cache_id
		return

	for(var/network in networks_to_invalidate)
		if(!network)
			continue
		dirty_networks[network] = TRUE
	camera_cache_id = ++camera_cache_id

/repository/cameras/proc/setup_cache()
	if(!invalidated)
		return
	invalidated = 0
	networks.Cut()
	dirty_networks.Cut()

	for(var/sc in cameranet.cameras)
		var/obj/machinery/camera/C = sc
		var/cam = C.nano_structure()
		for(var/network in C.network)
			if(!networks[network])
				ADD_SORTED(networks, network, GLOBAL_PROC_REF(cmp_text_asc))
				networks[network] = list()
			var/list/netlist = networks[network]
			netlist[LIST_PRE_INC(netlist)] = cam

/repository/cameras/proc/rebuild_network(network)
	if(invalidated)
		setup_cache()
		return

	if(networks[network])
		networks -= network

	var/list/network_list = list()
	for(var/sc in cameranet.cameras)
		var/obj/machinery/camera/C = sc
		if(!(network in C.network))
			continue
		network_list[LIST_PRE_INC(network_list)] = C.nano_structure()

	dirty_networks -= network
	if(length(network_list))
		ADD_SORTED(networks, network, GLOBAL_PROC_REF(cmp_text_asc))
		networks[network] = network_list
