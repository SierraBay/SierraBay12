/obj/submap_landmark/joinable_submap/bearcat
	name = "FTV Bearcat"
	archetype = /singleton/submap_archetype/derelict/bearcat

/singleton/submap_archetype/derelict/bearcat
	descriptor = "derelict cargo vessel"
	map = "Bearcat Wreck"
	crew_jobs = list(
		/datum/job/submap/bearcat_captain,
		/datum/job/submap/bearcat_crewman
	)

/obj/overmap/visitable/ship/bearcat
	name = "light freighter"
	color = "#00ffff"
	vessel_mass = 19000 //было 20000, 1000 в пользу шаттла ушло
	max_speed = 1/(5 SECONDS) //соответствие параметру ниже
	burn_delay = 5 SECONDS //было 10 секунд. нерезонно огромный кд для ускорения трастеров
	initial_restricted_waypoints = list(
		"Exploration Shuttle" = list("nav_bearcat_port_dock_shuttle"),
	)

/obj/overmap/visitable/ship/landable/bearcat
	name = "Exploration Shuttle"
	shuttle = "Exploration Shuttle"
	color = "#00ffff"
	vessel_mass = 1500
	fore_dir = NORTH
	vessel_size = SHIP_SIZE_SMALL

/obj/overmap/visitable/ship/bearcat/New()
	name = "[pick("FTV","ITV","IEV")] [pick("Bearcat", "Firebug", "Defiant", "Unsinkable","Horizon","Vagrant")]"
	for(var/area/ship/scrap/A)
		A.name = "\improper [name] - [A.name]"
		GLOB.using_map.area_purity_test_exempt_areas += A.type
	name = "[name], \a [initial(name)]"
	..()

/datum/map_template/ruin/away_site/bearcat_wreck
	name = "Bearcat Wreck"
	id = "awaysite_bearcat_wreck"
	description = "A wrecked light freighter."
	prefix = "mods/_maps/bearcat_revived/maps/"
	suffixes = list("bearcat_rev-1.dmm", "bearcat_rev-2.dmm")
	spawn_cost = 1
	player_cost = 4
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/ferry/lift,
		/datum/shuttle/autodock/overmap/exploration
		)
	area_usage_test_exempted_root_areas = list(/area/ship)
	apc_test_exempt_areas = list(
		/area/ship/scrap/maintenance/engine/port = NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/maintenance/engine/starboard = NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/crew/hallway/port= NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/crew/hallway/starboard= NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/maintenance/hallway = NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/maintenance/lower = NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/maintenance/atmos = NO_SCRUBBER,
		/area/ship/scrap/escape_port = NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/escape_star = NO_SCRUBBER|NO_VENT,
		/area/ship/scrap/shuttle/lift = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/ship/scrap/command/hallway = NO_SCRUBBER|NO_VENT
	)
	spawn_weight = 0.67

//перенос старых тайлов для биркета
/turf/simulated/floor/usedup
	initial_gas = list(GAS_CO2 = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)

/turf/simulated/floor/tiled/usedup
	initial_gas = list(GAS_CO2 = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)

/turf/simulated/floor/tiled/dark/usedup
	initial_gas = list(GAS_CO2 = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)

/turf/simulated/floor/tiled/white/usedup
	initial_gas = list(GAS_CO2 = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)

/turf/simulated/floor/reinforced/airless
	initial_gas = null

/turf/simulated/floor/tiled/airless
	initial_gas = null

/datum/shuttle/autodock/ferry/lift
	name = "Cargo Lift"
	shuttle_area = /area/ship/scrap/shuttle/lift
	warmup_time = 3	//give those below some time to get out of the way
	waypoint_station = "nav_bearcat_lift_bottom"
	waypoint_offsite = "nav_bearcat_lift_top"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0
	defer_initialisation = TRUE

/obj/machinery/computer/shuttle_control/lift
	name = "cargo lift controls"
	shuttle_tag = "Cargo Lift"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = FALSE

/obj/shuttle_landmark/lift/top
	name = "Top Deck"
	landmark_tag = "nav_bearcat_lift_top"
	flags = SLANDMARK_FLAG_AUTOSET

/obj/shuttle_landmark/lift/bottom
	name = "Lower Deck"
	landmark_tag = "nav_bearcat_lift_bottom"
	base_area = /area/ship/scrap/cargo/lower
	base_turf = /turf/simulated/floor

/obj/machinery/power/apc/derelict
	cell_type = /obj/item/cell/crap/empty
	locked = 0
	coverlocked = 0

/obj/machinery/door/airlock/autoname/command
	door_color = COLOR_COMMAND_BLUE

/obj/machinery/door/airlock/autoname/engineering
	door_color = COLOR_AMBER

/obj/landmark/deadcap
	name = "Dead Captain"

/obj/landmark/deadcap/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/landmark/deadcap/LateInitialize(mapload)
	var/turf/T = get_turf(src)
	var/mob/living/carbon/human/corpse = new(T)
	scramble(1, corpse, 100)
	corpse.real_name = "Captain"
	corpse.name = "Captain"
	var/singleton/hierarchy/outfit/outfit = outfit_by_type(/singleton/hierarchy/outfit/deadcap)
	outfit.equip(corpse)
	corpse.adjustOxyLoss(corpse.maxHealth)
	corpse.setBrainLoss(corpse.maxHealth)
	var/obj/structure/bed/chair/C = locate() in T
	if (C)
		C.buckle_mob(corpse)
	qdel(src)

/singleton/hierarchy/outfit/deadcap
	name = "Derelict Captain"
	uniform = /obj/item/clothing/under/casual_pants/classicjeans
	suit = /obj/item/clothing/suit/storage/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/black
	r_pocket = /obj/item/device/radio/map_preset/bearcat

/singleton/hierarchy/outfit/deadcap/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/uniform = H.w_uniform
	if(uniform)
		var/obj/item/clothing/accessory/toggleable/hawaii/random/eyegore = new()
		if(uniform.can_attach_accessory(eyegore))
			uniform.attach_accessory(null, eyegore)
		else
			qdel(eyegore)
	var/obj/item/cell/super/C = new()
	H.put_in_any_hand_if_possible(C)

//Bearcat's exploration
/datum/shuttle/autodock/overmap/exploration
	name = "Exploration Shuttle"
	shuttle_area = list(/area/ship/scrap/shuttle/outgoing)
	dock_target = "bearcat_shuttle"
	current_location = "nav_bearcat_port_dock_shuttle"
	logging_access = access_bearcat
	range = 1
	fuel_consumption = 3
	warmup_time = 7
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	ceiling_type = /turf/simulated/floor/shuttle_ceiling

/obj/machinery/computer/shuttle_control/explore/bearcat
	name = "shuttle console"
	shuttle_tag = "Exploration Shuttle"
	req_access = list(access_bearcat)

/obj/shuttle_landmark/bearcat_shuttle
	name = "Port Shuttle Dock"
	landmark_tag = "nav_bearcat_port_dock_shuttle"
	docking_controller = "bearcat_dock_port"
