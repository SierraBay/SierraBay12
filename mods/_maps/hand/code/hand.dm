// HAND TODO BELOW


	///////////
	//OVERMAP//
	///////////

/obj/overmap/visitable/ship/hand
	name = "Salvage Vessel"
	desc = "Hyena-class salvage vessel used by countless independent prospectors and corporates alike"
	color = "#990000"
	fore_dir = WEST
	vessel_mass = 1000
	known_ships = list(/obj/overmap/visitable/ship/landable/reaper)
	vessel_size = SHIP_SIZE_SMALL
	start_x = 1
	start_y = 1

	initial_generic_waypoints = list(
		"nav_hand_1",
		"nav_hand_2",
		"nav_hand_3",
		"nav_hand_4",
		"nav_hangar_reaper"
	)

	initial_restricted_waypoints = list(
		"Reaper" = list("nav_hangar_reaper")
	)


#define HAND_SHIP_PREFIX pick("FTU Freeman", "SFV Adrian", "NTV Calhoun", "HIV-T Tapir", "GrM Carrion", "SAV Kilo", "EE T-class 36-78")
/obj/overmap/visitable/ship/hand/New()
	name = "[HAND_SHIP_PREFIX], \a [name]"
	for(var/area/ship/hand/A)
		A.name = "\improper [name] - [A.name]"
		GLOB.using_map.area_purity_test_exempt_areas += A.type
	..()
#undef HAND_SHIP_PREFIX


/datum/map_template/ruin/away_site/hand
	name = "Hearer's Hand Vessel"
	id = "awaysite_hand_ship"
	description = "Hyena-class salvage vessel."
	prefix = "mods/_maps/sentinel/maps/"
	suffixes = list("hand-1.dmm", "hand-2.dmm")
	ban_ruins = list(/datum/map_template/ruin/away_site/farfleet)
	spawn_cost = 0.5
	player_cost = 7
	spawn_weight = 1
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/reaper)

	area_usage_test_exempted_areas = list(
		/area/turbolift/sentinel_first,
		/area/turbolift/sentinel_second
	)

/obj/shuttle_landmark/nav_hand/nav1
	name = "hand Ship Fore"
	landmark_tag = "nav_hand_1"

/obj/shuttle_landmark/nav_hand/nav2
	name = "hand Ship Aft"
	landmark_tag = "nav_hand_2"

/obj/shuttle_landmark/nav_hand/nav3
	name = "hand Ship Port"
	landmark_tag = "nav_hand_3"

/obj/shuttle_landmark/nav_hand/nav4
	name = "hand Ship Starboard"
	landmark_tag = "nav_hand_4"

/obj/submap_landmark/joinable_submap/hand
	name = "Hearer's Hand Chorus"
	archetype = /singleton/submap_archetype/away_hand

/* TCOMMS
 * ======


/obj/machinery/telecomms/allinone/away_hand
	listening_freqs = list(HAND_FREQ)
	channel_color = COMMS_COLOR_CENTCOMM
	channel_name = "SCG hand"
	circuitboard = /obj/item/stock_parts/circuitboard/telecomms/allinone/away_hand

/obj/item/stock_parts/circuitboard/telecomms/allinone/away_hand
	build_path = /obj/machinery/telecomms/allinone/away_hand

/obj/item/device/radio/headset/away_hand
	name = "SCG hand headset"
	icon_state = "mine_headset"
	ks1type = /obj/item/device/encryptionkey/away_hand

/obj/item/device/radio/headset/away_hand/Initialize()
	. = ..()
	set_frequency(SFV_FREQ)	//Not going to be random or just set to the common frequency, but can be set later.

/obj/item/device/encryptionkey/away_hand
	name = "SCG hand radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list("SCG hand" = 1)
 */
