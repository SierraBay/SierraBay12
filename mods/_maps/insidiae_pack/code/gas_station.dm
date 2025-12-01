/obj/overmap/visitable/sector/gas_station
	name = "Abandoned Fuelling Station"
	desc = "Sensors detect a damaged unpowered station with radiation hotspots. The highest level of radiation hazard is found in the center of the fore section."
	icon_state = "object"

	initial_restricted_waypoints = list(
		"Mule" = list("nav_gas_station_port_a"),
		"Hyena GM Tug-2" = list("nav_gas_station_port_b"),
		"Exploration Shuttle" = list("nav_gas_station_port_c"),
		"Reaper Gunboat" = list("nav_gas_station_port_d"),
		"EE S-class 18-24-2" = list("nav_gas_station_port_e"),
		"Hyena GM Tug-1" = list("nav_gas_station_port_f"),
		"SRV Venerable Catfish" = list("nav_gas_station_port_j"),
		// "" = list("nav_gas_station_starboard_a"),
		"EE S-class 18-24-1" = list("nav_gas_station_starboard_b"),
		"Charon" = list("nav_gas_station_starboard_c"),
		// "" = list("nav_gas_station_starboard_d"),
		"ITV Vulcan" = list("nav_gas_station_starboard_e"),
		"ITV Spiritus" = list("nav_gas_station_starboard_f"),
		"SNZ Speedboat" = list("nav_gas_station_starboard_j")
		)

	initial_generic_waypoints = list(
		"nav_gas_station_1",
		"nav_gas_station_2",
		"nav_gas_station_3",
		"nav_gas_station_4",
	)

/datum/map_template/ruin/away_site/gas_station
	name = "Gas Station"
	id = "awaysite_gas_station"
	description = ""
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("gas_station.dmm")
	spawn_cost = 1
	area_usage_test_exempted_root_areas = list(/area/gas_station)



/obj/shuttle_landmark/nav_gas_station/port_a // mule
	name = "Dock Port A"
	landmark_tag = "nav_gas_station_port_a"
	docking_controller = "gas_station_port_a"

/obj/shuttle_landmark/nav_gas_station/port_b // hand tug 2
	name = "Dock Port B"
	landmark_tag = "nav_gas_station_port_b"
	docking_controller = "gas_station_port_b"

/obj/shuttle_landmark/nav_gas_station/port_c // kitten
	name = "Dock Port C"
	landmark_tag = "nav_gas_station_port_c"
	docking_controller = "gas_station_port_c"

/obj/shuttle_landmark/nav_gas_station/port_d // reaper
	name = "Dock Port D"
	landmark_tag = "nav_gas_station_port_d"
	docking_controller = "gas_station_port_d"

/obj/shuttle_landmark/nav_gas_station/port_e // hand 2
	name = "Dock Port E"
	landmark_tag = "nav_gas_station_port_e"
	docking_controller = "gas_station_port_e"

/obj/shuttle_landmark/nav_gas_station/port_f // hand tug 1
	name = "Dock Port F"
	landmark_tag = "nav_gas_station_port_f"
	docking_controller = "gas_station_port_f"

/obj/shuttle_landmark/nav_gas_station/port_j // catfish
	name = "Dock Port J"
	landmark_tag = "nav_gas_station_port_j"
	docking_controller = "gas_station_port_j"


// /obj/shuttle_landmark/nav_gas_station/starboard_a
// 	name = "Dock Starboard A"
// 	landmark_tag = "nav_gas_station_starboard_a"
// 	docking_controller = "gas_station_starboard_a"

/obj/shuttle_landmark/nav_gas_station/starboard_b // hand 1
	name = "Dock Starboard B"
	landmark_tag = "nav_gas_station_starboard_b"
	docking_controller = "gas_station_starboard_b"

/obj/shuttle_landmark/nav_gas_station/starboard_c // charon
	name = "Dock Starboard C"
	landmark_tag = "nav_gas_station_starboard_c"
	docking_controller = "gas_station_starboard_c"

// /obj/shuttle_landmark/nav_gas_station/starboard_d
// 	name = "Dock Starboard D"
// 	landmark_tag = "nav_gas_station_starboard_d"
// 	docking_controller = "gas_station_starboard_d"

/obj/shuttle_landmark/nav_gas_station/starboard_e // vulcan
	name = "Dock Starboard E"
	landmark_tag = "nav_gas_station_starboard_e"
	docking_controller = "gas_station_starboard_e"

/obj/shuttle_landmark/nav_gas_station/starboard_f // spiritus
	name = "Dock Starboard F"
	landmark_tag = "nav_gas_station_starboard_f"
	docking_controller = "gas_station_starboard_f"

/obj/shuttle_landmark/nav_gas_station/starboard_j // snz
	name = "Dock Starboard J"
	landmark_tag = "nav_gas_station_starboard_j"
	docking_controller = "gas_station_starboard_j"



/obj/shuttle_landmark/nav_gas_station/nav1
	name = "Navpoint #1"
	landmark_tag = "nav_gas_station_1"

/obj/shuttle_landmark/nav_gas_station/nav2
	name = "Navpoint #2"
	landmark_tag = "nav_gas_station_2"

/obj/shuttle_landmark/nav_gas_station/nav3
	name = "Navpoint #3"
	landmark_tag = "nav_gas_station_3"

/obj/shuttle_landmark/nav_gas_station/nav4
	name = "Navpoint #4"
	landmark_tag = "nav_gas_station_4"



/area/gas_station/hall
	name = "Hall"

/area/gas_station/office
	name = "Office"

/area/gas_station/cashier
	name = "Cashier Area"

/area/gas_station/staff
	name = "Staff Quarters"

/area/gas_station/medbay
	name = "MedBay"

/area/gas_station/storage
	name = "Storage"

/area/gas_station/engineering
	name = "Engineering"

/area/gas_station/hallway
	name = "Hallway"

/area/gas_station/wc
	name = "WC"

/area/gas_station/port
	name = "Port Wing"

/area/gas_station/starboard
	name = "Starboard Wing"



/obj/radiation_spot
	name = "radiation spot"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	var/radiation_power = 10 // +-25%
	var/range = 5
	var/chance = 40

/obj/radiation_spot/Initialize()
	. = ..()
	if(prob(chance))
		var/turf/simulated/T = get_turf(src)
		if(T)
			var/v = radiation_power/4
			var/datum/radiation_source/S = new(T, radiation_power + rand(-v, v), FALSE)
			S.range = range
			SSradiation.add_source(S)

	return INITIALIZE_HINT_QDEL



/obj/structure/closet/fridge/empty/WillContain()
	return list()
