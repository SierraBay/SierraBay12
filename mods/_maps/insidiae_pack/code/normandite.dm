/obj/submap_landmark/joinable_submap/normandite
	name = "GTMS Normandite"
	archetype = /singleton/submap_archetype/away_normandite

/singleton/submap_archetype/away_normandite
	descriptor = "Grayson Terra Mining station"
	map = "Normandite"
	crew_jobs = list(
		/datum/job/submap/normandite,
		/datum/job/submap/normandite/leader
	)

/obj/overmap/visitable/ship/normandite
	name = "mining station"
	desc = "A stationary space object with wide of 79.5 meters, length of 72 meters and high near 12.7 meters."
	color = COLOR_BROWN_ORANGE
	vessel_mass = 23000
	known_ships = list(/obj/overmap/visitable/ship/landable/utyug)
	vessel_size = SHIP_SIZE_SMALL
	initial_restricted_waypoints = list("Mule" = list("nav_normandite_merchant"), "Utyug" = list("nav_utyug_start"))
	contact_class = /decl/ship_contact_class/normandite

	initial_generic_waypoints = list(
		"nav_normandite_north",
		"nav_normandite_east",
		"nav_normandite_south",
		"nav_normandite_west"
	)

/decl/ship_contact_class/normandite
	class_short = "DLC"
	class_long = "Dolomite-class small deep-space ore extraction facility"
	max_ship_mass = 26000

/obj/overmap/visitable/ship/normandite/New()
	name = "GTMS Normandite-[rand(3,19)]"
	scanner_desc = {"
<B>Property of Grayson Manufactories:</B><br>
<I>Registration</I>: [name]<br>
<I>Transponder</I>: Transmitting (IND), Grayson Terra<br>
<B>Notice</B>: A space object with wide of 79.5 meters, length of 72 meters and high near 12.7 meters. A Self Indentification Signal classifices the target as Grayson Terra Mining Station, a property of Grayson Manufactories."}
	..()

/datum/map_template/ruin/away_site/normandite
	name = "Normandite"
	id = "awaysite_normandite"
	description = ""
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("normandite.dmm")
	spawn_cost = 1
	player_cost = 4
	spawn_weight = 0.4
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/utyug)
	apc_test_exempt_areas = list(
		/area/normandite/exterior = NO_SCRUBBER|NO_VENT
	)
	area_usage_test_exempted_root_areas = list(/area/normandite)
	ban_ruins = list(
		/datum/map_template/ruin/away_site/salvage_ship,
		/datum/map_template/ruin/away_site/scavver_gantry
	)

	skip_main_unit_tests = TRUE

// utyug

/obj/overmap/visitable/ship/landable/utyug
	shuttle = "Utyug"
	name = "GTSS Utyug"
	scanner_desc = {"
<B>Property of Grayson Manufactories:</B><br>
<I>Registration</I>: GTSS Utyug<br>
<I>Transponder</I>: Transmitting (IND), Grayson Terra<br>
<B>Notice</B>: A Self Indentification Signal classifices the target as Grayson Terra Small Shuttle"}
	max_speed = 1/(2 SECONDS)
	burn_delay = 3 SECONDS
	vessel_mass = 5000
	fore_dir = NORTH
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_SMALL
	contact_class = /decl/ship_contact_class/shuttle

/datum/shuttle/autodock/overmap/utyug
	name = "Utyug"
	warmup_time = 10
	current_location = "nav_utyug_start"
	range = 1
	shuttle_area = list(/area/normandite/utyug)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	fuel_consumption = 5

/obj/machinery/computer/shuttle_control/explore/utyug
	name = "shuttle control console"
	shuttle_tag = "Utyug"

/obj/shuttle_landmark/utyug
	name = "Utyug Dock"
	landmark_tag = "nav_utyug_start"
	base_area = /area/space
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

// jobs

/datum/job/submap/normandite
	title = "Normandite Miner"
	info = "Вы шахтёр на мелкой добывающей станции в глубоком не освоенном космосе. \
	Вы целыми днями копаетесь в астероидах для терранского подразделения Grayson Manufactories. \
	Из-за нахватки рабочих рук и разбитой астероидом второй каюты вам приходиться работать за двоих, как бы трудно это не было. \
	До прибытия баржи которая привезет следующую смену и заберет вас с рудой на большую землю осталось семь недель. \
	Копайте руду, не разбейте Утюг, не спивайтесь, не делайте из нескольких экзокостюмов один большой, не ищите неизвестные науке формы жизни."
	total_positions = 3
	spawn_positions = 3
	supervisors = "авторитетом Бригадира"
	selection_color = "#47361d"
	ideal_character_age = 30
	minimal_player_age = 0
	create_record = FALSE
	whitelisted_species = list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_TRITONIAN, SPECIES_SPACER, SPECIES_VATGROWN, SPECIES_GRAVWORLDER, SPECIES_TAJARA)
	outfit_type = /singleton/hierarchy/outfit/job/normandite
	latejoin_at_spawnpoints = TRUE
	required_language = LANGUAGE_HUMAN_RUSSIAN
	loadout_allowed = TRUE
	access = list(access_normandite)
	announced = FALSE
	min_skill = list(
		SKILL_EVA = SKILL_BASIC,
		SKILL_HAULING = SKILL_BASIC,
		SKILL_CONSTRUCTION = SKILL_BASIC
	)
	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_EXPERIENCED,
		SKILL_FINANCE = SKILL_EXPERIENCED,
		SKILL_EVA = SKILL_MAX,
		SKILL_MECH = SKILL_MAX,
		SKILL_PILOT = SKILL_EXPERIENCED,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_EXPERIENCED,
		SKILL_BOTANY = SKILL_EXPERIENCED,
		SKILL_COOKING = SKILL_EXPERIENCED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_WEAPONS = SKILL_EXPERIENCED,
		SKILL_FORENSICS = SKILL_EXPERIENCED,
		SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
		SKILL_ELECTRICAL = SKILL_EXPERIENCED,
		SKILL_ATMOS = SKILL_EXPERIENCED,
		SKILL_ENGINES = SKILL_EXPERIENCED,
		SKILL_DEVICES = SKILL_EXPERIENCED,
		SKILL_SCIENCE = SKILL_EXPERIENCED,
		SKILL_MEDICAL = SKILL_TRAINED,
		SKILL_ANATOMY = SKILL_TRAINED,
		SKILL_CHEMISTRY = SKILL_TRAINED
	)
	economic_power = 2
	skill_points = 20

/datum/job/submap/normandite/leader
	title = "Normandite Brigadir"
	info = "Вы главный среди шахтёров на мелкой добывающей станции в глубоком не освоенном космосе. \
	Вы целыми днями копаетесь в астероидах для терранского подразделения Grayson Manufactories. \
	Из-за нахватки рабочих рук и разбитой астероидом второй каюты вам всем приходиться работать за двоих, как бы трудно это не было. \
	До прибытия баржи которая привезет следующую смену и заберет вас с рудой на большую землю осталось семь недель. \
	Следите что бы шахтёры копали руду, не разбили Утюг, не спивались, не делали из нескольких экзокостюмов один большой, не нашли неизвестные науке формы жизни."
	total_positions = 1
	spawn_positions = 1
	supervisors = "поставленным планом"
	ideal_character_age = 45

// spawnpoint

/obj/submap_landmark/spawnpoint/normandite
	name = "Normandite Miner"

/obj/submap_landmark/spawnpoint/normandite/leader
	name = "Normandite Brigadir"

// outfit

/singleton/hierarchy/outfit/job/normandite
	name = OUTFIT_JOB_NAME("Miner")
	l_ear = /obj/item/device/radio/headset/normandite
	l_pocket = /obj/item/device/radio
	uniform = /obj/item/clothing/under/grayson
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/thick/duty
	id_types = list(/obj/item/card/id/normandite)

/obj/item/card/id/normandite
	desc = "An identification card issued to Grayson Terra employees."
	job_access_type = /datum/job/submap/normandite
	color = COLOR_BRONZE
	detail_color = COLOR_BROWN

var/global/const/access_normandite = "ACCESS_NORMANDITE"
/datum/access/normandite
	id = access_normandite
	desc = "GTMS Employee"
	region = ACCESS_REGION_NONE

/obj/item/device/radio/headset/normandite
	name = "mining bowman radio headset"
	desc = "A headset used by tough space miners."
	icon_state = "mine_headset_alt"
	item_state = "mine_headset_alt"

// nav points

/obj/shuttle_landmark/nav_normandite/north
	name = "Normandite North"
	landmark_tag = "nav_normandite_north"

/obj/shuttle_landmark/nav_normandite/east
	name = "Normandite East"
	landmark_tag = "nav_normandite_east"

/obj/shuttle_landmark/nav_normandite/south
	name = "Normandite South"
	landmark_tag = "nav_normandite_south"

/obj/shuttle_landmark/nav_normandite/west
	name = "Normandite West"
	landmark_tag = "nav_normandite_west"

/obj/shuttle_landmark/nav_normandite/merchant
	name = "Docking Bay"
	landmark_tag = "nav_normandite_merchant"
	docking_controller = "merchant_shuttle_normandite"

// mechs

/mob/living/exosuit/premade/normandite
	name = "jerry-rigged exosuit"
	desc = "An old jerry-rigged exosuit for asteroid mining."

/mob/living/exosuit/premade/normandite/Initialize()
	var/c = pick(COLOR_BROWN_ORANGE, COLOR_DARK_ORANGE, COLOR_YELLOW_GRAY, COLOR_PALE_YELLOW, COLOR_WARM_YELLOW, COLOR_RED_GRAY, COLOR_BROWN, COLOR_DARK_GREEN_GRAY, COLOR_BOTTLE_GREEN, COLOR_DARK_GUNMETAL, COLOR_ASTEROID_ROCK)

	if(!head)
		var/headtype = pick(/obj/item/mech_component/sensors/light, /obj/item/mech_component/sensors/powerloader)
		head = new headtype(src)
		head.color = c

	if(!body)
		var/bodytype = pick(/obj/item/mech_component/chassis/light, /obj/item/mech_component/chassis/pod, /obj/item/mech_component/chassis/powerloader)
		body = new bodytype(src)
		body.color = c

	if(!R_arm)
		var/rarmtype = pick(/obj/item/mech_component/manipulators/light, /obj/item/mech_component/manipulators/powerloader)
		R_arm = new rarmtype(src)
		R_arm.color = c
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_arm)
		var/larmtype = pick(/obj/item/mech_component/manipulators/light, /obj/item/mech_component/manipulators/powerloader)
		L_arm = new larmtype(src)
		L_arm.color = c
		L_arm.side = LEFT
		L_arm.setup_side()

	var/legstype = pick(/obj/item/mech_component/propulsion/light, /obj/item/mech_component/propulsion/powerloader, /obj/item/mech_component/propulsion/spider, /obj/item/mech_component/propulsion/tracks)
	if(!R_leg)
		R_leg = new legstype(src)
		R_leg.color = c
		R_leg.side = RIGHT
		R_leg.setup_side()
	if(!L_leg)
		L_leg = new legstype(src)
		L_leg.color = c
		L_leg.side = LEFT
		L_leg.setup_side()
	. = ..()

/mob/living/exosuit/premade/normandite/spawn_mech_equipment()
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_HEAD)
	install_system(new /obj/item/mech_equipment/clamp(src), HARDPOINT_LEFT_HAND)
	switch(rand(1,2))
		if(1)
			install_system(new /obj/item/mech_equipment/mounted_system/taser/plasma(src), HARDPOINT_RIGHT_HAND)
		if(2)
			install_system(new /obj/item/mech_equipment/drill/steel(src), HARDPOINT_RIGHT_HAND)
	var/r = rand(1,3)
	if(r == 1)
		install_system(new /obj/item/mech_equipment/ionjets(src), HARDPOINT_BACK)

// areas

/area/normandite
	req_access = list(access_normandite)

/area/normandite/exterior
	name = "GTMS Normandite - Exterior"
	icon_state = "away1"
	has_gravity = 0
	area_flags = AREA_FLAG_EXTERNAL
	ambience = list('sound/ambience/ambispace1.ogg','sound/ambience/ambispace2.ogg','sound/ambience/ambispace3.ogg','sound/ambience/ambispace4.ogg','sound/ambience/ambispace5.ogg')

/area/normandite/exterior/aft

/area/normandite/center
	name = "GTMS Normandite - Control Room"
	icon_state = "bridge"

/area/normandite/dining
	name = "GTMS Normandite - Dining Room"

/area/normandite/bathroom
	name = "GTMS Normandite - Bathroom"
	icon_state = "dk_yellow"

/area/normandite/water
	name = "GTMS Normandite - Water Storage"
	icon_state = "purple"

/area/normandite/cabin_a
	name = "GTMS Normandite - Cabin A"
	icon_state = "crew_quarters"

/area/normandite/cabin_b
	name = "GTMS Normandite - Cabin B"
	icon_state = "crew_quarters"

/area/normandite/medbay
	name = "GTMS Normandite - Medbay"
	icon_state = "medbay"

/area/normandite/workshop
	name = "GTMS Normandite - Workshop"
	icon_state = "engineering_workshop"

/area/normandite/storage
	name = "GTMS Normandite - Storage"
	icon_state = "primarystorage"

/area/normandite/food_storage
	name = "GTMS Normandite - Food Warehouse"
	icon_state = "emergencystorage"

/area/normandite/ore_storage
	name = "GTMS Normandite - Ore Warehouse"
	icon_state = "storage"

/area/normandite/engineering
	name = "GTMS Normandite - Engineering"
	icon_state = "engine"

/area/normandite/dock
	name = "GTMS Normandite - Dock"
	icon_state = "entry_1"

/area/normandite/hallway_fore
	name = "GTMS Normandite - Fore Hallway"
	icon_state = "hallC1"

/area/normandite/hallway_aft
	name = "GTMS Normandite - Aft Hallway"
	icon_state = "hallC1"

/area/normandite/hallway_starboard
	name = "GTMS Normandite - Stardord Hallway"
	icon_state = "hallC1"

/area/normandite/hallway_port
	name = "GTMS Normandite - Port Hallway"
	icon_state = "hallC1"

/area/normandite/utyug
	name = "Utyug"
	icon_state = "shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

// paint

/obj/paint/normandite/a
	color = COLOR_BRONZE

/obj/paint/normandite/b
	color = COLOR_DARK_BROWN

// sensors

/obj/machinery/computer/modular/preset/sensors/russian/normandite

/obj/machinery/computer/modular/preset/sensors/russian/normandite/verb/sector_info()
	set name = "Scan sector"
	set category = "Object"
	set src in oview(1)
	sector_scan()

/obj/machinery/computer/modular/preset/sensors/russian/normandite/proc/sector_scan()
	var/text = "Сканирование сектора от [stationdate2text()], [stationtime2text()]<br />Обнаруженные объекты:<br />"

	var/list/space_things = list()
	var/obj/overmap/normandite = map_sectors["[get_z(src)]"]
	for(var/zlevel in map_sectors)
		var/obj/overmap/visitable/O = map_sectors[zlevel]
		if(O.name == normandite.name)
			continue
		if(istype(O, /obj/overmap/visitable/ship/landable))
			continue
		if(O.hide_from_reports)
			continue
		space_things |= O

	for(var/obj/overmap/visitable/O in space_things)
		var/bearing = get_bearing(normandite, O)
		var/location_desc = ", по азимуту [bearing]."
		text += "<li>\A <b>[O.name]</b>[location_desc]</li>"

	playsound(src, pick('sound/effects/compbeep4.ogg', 'sound/effects/compbeep5.ogg'), 25, 1, 10)
	sleep(2 SECONDS)

	new/obj/item/paper(loc, text, "Sensor Readings", null, LANGUAGE_HUMAN_RUSSIAN)

// nanomed

/obj/machinery/vending/medical/normandite
	req_access = list()
