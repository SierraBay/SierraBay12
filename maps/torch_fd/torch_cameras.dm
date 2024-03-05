var/const/NETWORK_EXPLO		= "Exploration"
var/const/NETWORK_PETROV	= "Petrov"
var/const/NETWORK_GUPS		= "General Utility Pods" // 2 for the price of 1! :p
var/const/NETWORK_SUPPLY	= "Supply"
var/const/NETWORK_YACHT		= "Private Catamaran"

/datum/map/torch/get_network_access(network)
	switch(network)
		if(NETWORK_AQUILA)
			return access_aquila
		if(NETWORK_BRIDGE)
			return access_heads
		if(NETWORK_CHARON)
			return access_expedition_shuttle
		if(NETWORK_HELMETS)
			return access_solgov_crew
		if(NETWORK_PETROV)
			return access_petrov
		if(NETWORK_GUPS)
			return access_guppy
		if(NETWORK_SECURITY)
			return access_security
		if(NETWORK_SUPPLY)
			return access_mailsorting
	return get_shared_network_access(network) || ..()

/datum/map/torch
	// Networks that will show up as options in the camera monitor program
	station_networks = list(
		NETWORK_BRIDGE,
		NETWORK_COMMAND,
		NETWORK_FIRST_DECK,
		NETWORK_SECOND_DECK,
		NETWORK_THIRD_DECK,
		NETWORK_FOURTH_DECK,
		NETWORK_FIFTH_DECK,
		NETWORK_ENGINEERING,
		NETWORK_MEDICAL,
		NETWORK_RESEARCH,
		NETWORK_SECURITY,
		NETWORK_SUPPLY,
		NETWORK_EXPLO,
		NETWORK_AQUILA,
		NETWORK_GUPS,
		NETWORK_YACHT,
		NETWORK_CHARON,
		NETWORK_HELMETS,
		NETWORK_PETROV,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
	)

//
// Cameras
//

// Networks
/obj/machinery/camera/network/command
	network = list(NETWORK_COMMAND)

/obj/machinery/camera/network/exploration
	network = list(NETWORK_EXPLO)

/obj/machinery/camera/network/petrov
	network = list(NETWORK_PETROV)

/obj/machinery/camera/network/gups
	network = list(NETWORK_GUPS)

/obj/machinery/camera/network/supply
	network = list(NETWORK_SUPPLY)

/obj/machinery/camera/network/yacht
	network = list(NETWORK_YACHT)
