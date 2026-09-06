/obj/item/stock_parts/computer/network_card/get_signal_direct()
	var/turf/T = get_turf(src)

	if(!istype(T))
		return

	if(!(T.z in GLOB.using_map.station_levels) && !(T.z in GLOB.using_map.contact_levels))
		. = 0
		if(!check_functionality() || !ntnet_global || is_banned())
			return
		if(!ntnet_global.check_function() && !ethernet)
			return
		for(var/obj/machinery/ntnet_relay/R in ntnet_global.relays)
			if((R.z in GetConnectedZlevels(T.z)) && R.operable())
				var/strength = 1
				if(ethernet)
					strength = 3
				else if(long_range)
					strength = 2

				. = strength
				return
		return

	. = ..()