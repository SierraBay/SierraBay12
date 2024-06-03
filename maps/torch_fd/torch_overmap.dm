
// --- BUBBLE --- //

/obj/overmap/visitable/ship/landable/bubble
	name = "Bubble"
	desc = "An SSE-U2 utility pod, broadcasting SCGEC codes and the callsign \"Torch-4 Bubble\"."
	shuttle = "Bubble"
	max_speed = 1/(3 SECONDS)
	burn_delay = 2 SECONDS
	vessel_mass = 3000 //very inefficient pod
	fore_dir = SOUTH
	dir = SOUTH
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_TINY

/obj/machinery/computer/shuttle_control/explore/bubble
	name = "Bubble control console"
	shuttle_tag = "Bubble"
	req_access = list(access_guppy_helm)

/datum/shuttle/autodock/overmap/bubble
	name = "Bubble"
	warmup_time = 5
	move_time = 30
	shuttle_area = /area/bubble_hangar/start
	dock_target ="bubble_shuttle"
	current_location = "nav_hangar_bubble"
	landmark_transition = "nav_transit_bubble"
	sound_takeoff = 'sound/effects/rocket.ogg'
	sound_landing = 'sound/effects/rocket_backwards.ogg'
	fuel_consumption = 2
	logging_home_tag = "nav_hangar_bubble"
	logging_access = access_guppy_helm
	skill_needed = SKILL_UNSKILLED
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/torch

/obj/shuttle_landmark/torch/hangar/bubble
	name = "Bubble Hangar"
	landmark_tag = "nav_hangar_bubble"
	base_area = /area/quartermaster/hangar
	base_turf = /turf/simulated/floor/plating

/obj/shuttle_landmark/torch/deck1/bubble
	name = "Space near Forth Deck"
	landmark_tag = "nav_deck1_bubble"

/obj/shuttle_landmark/torch/deck2/bubble
	name = "Space near Third Deck"
	landmark_tag = "nav_deck2_bubble"

/obj/shuttle_landmark/torch/deck3/bubble
	name = "Space near Second Deck"
	landmark_tag = "nav_deck3_bubble"

/obj/shuttle_landmark/torch/deck4/bubble
	name = "Space near First Deck"
	landmark_tag = "nav_deck4_bubble"

/obj/shuttle_landmark/torch/deck5/bubble
	name = "Space near Bridge"
	landmark_tag = "nav_bridge_bubble"

/obj/shuttle_landmark/transit/torch/bubble
	name = "In transit"
	landmark_tag = "nav_transit_bubble"

// --- BUBBLE END --- //


// --- BUTTERFLY --- //

/obj/overmap/visitable/ship/landable/butterfly
	name = "Butterfly"
	desc = "An SSE-U09 long range shuttle, broadcasting SCGEC codes and the callsign \"Torch-5 Butterfly\"."
	shuttle = "Butterfly"
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 4000
	fore_dir = SOUTH
	dir = SOUTH
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_TINY

/obj/machinery/computer/shuttle_control/explore/butterfly
	name = "Butterfly control console"
	shuttle_tag = "Butterfly"

/datum/shuttle/autodock/overmap/butterfly
	name = "Butterfly"
	warmup_time = 5
	move_time = 30
	shuttle_area = list(/area/butterfly_hangar,/area/butterfly_hangar/cockpit)
	dock_target ="butterfly_shuttle"
	current_location = "nav_hangar_butterfly"
	landmark_transition = "nav_transit_butterfly"
	sound_takeoff = 'sound/effects/rocket.ogg'
	sound_landing = 'sound/effects/rocket_backwards.ogg'
	fuel_consumption = 2
	logging_home_tag = "nav_hangar_butterfly"
	logging_access = access_guppy_helm
	skill_needed = SKILL_UNSKILLED
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/torch

/obj/shuttle_landmark/torch/hangar/butterfly
	name = "Butterfly Hangar"
	landmark_tag = "nav_hangar_butterfly"
	base_area = /area/quartermaster/hangar
	base_turf = /turf/simulated/floor/plating

/obj/shuttle_landmark/torch/deck1/butterfly
	name = "Space near Forth Deck"
	landmark_tag = "nav_deck1_butterfly"

/obj/shuttle_landmark/torch/deck2/butterfly
	name = "Space near Third Deck"
	landmark_tag = "nav_deck2_butterfly"

/obj/shuttle_landmark/torch/deck3/butterfly
	name = "Space near Second Deck"
	landmark_tag = "nav_deck3_butterfly"

/obj/shuttle_landmark/torch/deck4/butterfly
	name = "Space near First Deck"
	landmark_tag = "nav_deck4_butterfly"

/obj/shuttle_landmark/torch/deck5/butterfly
	name = "Space near Bridge"
	landmark_tag = "nav_bridge_butterfly"

/obj/shuttle_landmark/transit/torch/butterfly
	name = "In transit"
	landmark_tag = "nav_transit_butterfly"

// --- BUTTERFLY END --- //

/datum/shuttle/autodock/overmap/aquila
	shuttle_area = list(/area/aquila/cockpit, /area/aquila/maintenance, /area/aquila/storage, /area/aquila/secure_storage, /area/aquila/mess, /area/aquila/passenger, /area/aquila/medical, /area/aquila/head, /area/aquila/airlock)

/datum/shuttle/autodock/overmap/exploration_shuttle
	shuttle_area = list(/area/exploration_shuttle/cockpit, /area/exploration_shuttle/atmos, /area/exploration_shuttle/power, /area/exploration_shuttle/crew, /area/exploration_shuttle/cargo, /area/exploration_shuttle/airlock)
