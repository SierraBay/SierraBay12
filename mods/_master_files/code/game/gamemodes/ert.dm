/datum/map_template/ruin/antag_spawn/ert
	name = "ERT Base"
	prefix = "mods/_antagonists/maps/"
	suffixes = list("ert_base.dmm")
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/multi/antag/rescue)
	apc_test_exempt_areas = list(
		/area/map_template/rescue_base = NO_SCRUBBER|NO_VENT|NO_APC
	)


/datum/shuttle/autodock/multi/antag/rescue
	name = "Rescue"
	warmup_time = 0
	defer_initialisation = TRUE
	destination_tags = list(
		"nav_ert_deck1",
		"nav_ert_deck2",
		"nav_ert_deck3",
		"nav_ert_deck4",
		"nav_ert_deck5",
		"nav_ert_dock",
		"nav_ert_start"
		)
	shuttle_area = /area/map_template/rescue_base/start
	dock_target = "rescue_shuttle"
	current_location = "nav_ert_start"
	landmark_transition = "nav_ert_transition"
	home_waypoint = "nav_ert_start"
	announcer = "Proximity Sensor Array"
	arrival_message = "Attention, vessel detected entering vessel proximity."
	departure_message = "Attention, vessel detected leaving vessel proximity."

/obj/shuttle_landmark/ert/start
	name = "Response Team Base"
	landmark_tag = "nav_ert_start"
	docking_controller = "rescue_base"

/obj/shuttle_landmark/ert/internim
	name = "In transit"
	landmark_tag = "nav_ert_transition"

/obj/shuttle_landmark/ert/dock
	name = "Docking Port"
	landmark_tag = "nav_ert_dock"
	docking_controller = "rescue_shuttle_dock_airlock"

// Areas

/area/map_template/rescue_base
	name = "\improper Response Team Base"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED

/area/map_template/rescue_base/base
	name = "\improper Barracks"
	icon_state = "yellow"
	dynamic_lighting = 0

/area/map_template/rescue_base/start
	name = "\improper Response Team Base"
	icon_state = "shuttlered"
	base_turf = /turf/unsimulated/floor/techfloor

//Objects

/obj/item/device/radio/headset/ert
	name = "emergency response team radio headset"
	desc = "The headset of the boss's boss."
	icon_state = "com_headset"
	item_state = "headset"
	ks1type = /obj/item/device/encryptionkey/ert

/obj/item/device/radio/headset/ert/Initialize()
	. = ..()
	set_frequency(ERT_FREQ)

/obj/item/stock_parts/circuitboard/telecomms/allinone/ert
	build_path = /obj/machinery/telecomms/allinone/ert

/obj/machinery/telecomms/allinone/ert
	listening_freqs = list(ERT_FREQ)
	channel_color = COMMS_COLOR_CENTCOMM
	channel_name = "Response Team"
	circuitboard = /obj/item/stock_parts/circuitboard/telecomms/allinone/ert

// Hardsuit

/obj/item/rig/ert/assetprotection
	name = "heavy emergency response suit control module"
	desc = "A heavy, modified version of a common emergency response hardsuit. Has blood red highlights.  Armoured and space ready."
	suit_type = "heavy emergency response"
	icon_state = "asset_protection_rig"
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)

	glove_type = /obj/item/clothing/gloves/rig/ert/assetprotection

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/vision/multi,
		/obj/item/rig_module/mounted/energy/egun,
		/obj/item/rig_module/chem_dispenser/combat,
		/obj/item/rig_module/mounted/energy/plasmacutter,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/cooling_unit
		)

/obj/item/clothing/gloves/rig/ert/assetprotection
	siemens_coefficient = 0
