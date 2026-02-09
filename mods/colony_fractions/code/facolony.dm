// Frontier Alliance: Blockade Runners Extension (Playable Colony) by GarryFlint
/datum/map_template/ruin/exoplanet/facolony
	name = "FA Blockade Runners Outpost"
	id = "facolony"
	description = "FA Blockade Runners Outpost"
	mappaths = list('mods/colony_fractions/maps/facolony.dmm')
	spawn_cost = 2
	player_cost = 0
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS | TEMPLATE_FLAG_NO_RADS
	ruin_tags = RUIN_HUMAN|RUIN_HABITAT
	ban_ruins = list(
		/datum/map_template/ruin/exoplanet/playablecolony,
		/datum/map_template/ruin/exoplanet/playablecolony2
	)
	apc_test_exempt_areas = list(
		/area/map_template/facolony/mineralprocessing = NO_SCRUBBER|NO_VENT
	)
	spawn_weight = 0.6

/singleton/submap_archetype/facolony
	descriptor = "FA Blockade Runners Outpost"
	crew_jobs = list(
		/datum/job/submap/facolony/colonist,
		/datum/job/submap/facolony/colonist/scientist,
		/datum/job/submap/facolony/colonist/medic,
		/datum/job/submap/facolony/colonist/engineer,
		/datum/job/submap/facolony/colonist/leader
	)

/singleton/hierarchy/outfit/job/facolony
	name = OUTFIT_JOB_NAME("facolony")
	id_types = list(/obj/item/card/id/facolony)
	pda_type = null
	l_ear = /obj/item/device/radio/headset/map_preset/facolony

/datum/job/submap/facolony/colonist
	title = "Crewman"
	supervisors = "Ship Captain"
	info = "You are a colonist living on the rim of explored space. Keep the outpost running and protect its interests."
	total_positions = 8
	max_skill = list(
		SKILL_PILOT			= SKILL_MAX,
		SKILL_CONSTRUCTION	= SKILL_MAX,
		SKILL_ELECTRICAL	= SKILL_MAX,
		SKILL_ATMOS			= SKILL_MAX,
		SKILL_ENGINES		= SKILL_MAX,
		SKILL_CHEMISTRY		= SKILL_MAX,
		SKILL_SCIENCE		= SKILL_MAX,
		SKILL_DEVICES		= SKILL_MAX,
		SKILL_COMBAT		= SKILL_MAX,
		SKILL_FORENSICS		= SKILL_MAX,
		SKILL_WEAPONS		= SKILL_MAX
	)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/datum/job/submap/facolony/colonist/leader
	title = "Ship Captain"
	supervisors = "Frontier Alliance Operational Сell Supervisor"
	info = "Вы - Капитан грузового судна IPV Celeste Hauler. На самом деле - это лишь прикрытие для ваших контрабандистских дел в качестве командира одной из ячеек Блокадных Беглецов Альянса Фронтира. Выживайте, торгуйте, извлекайте прибыль. Не всегда законными методами."
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/datum/job/submap/facolony/colonist/scientist
	title = "Systems Technician"
	supervisors = "Ship Captain"
	info = "Support the outpost with research and field analysis."
	total_positions = 1
	min_skill = list(
		SKILL_SCIENCE	= SKILL_TRAINED,
		SKILL_DEVICES	= SKILL_TRAINED,
		SKILL_CONSTRUCTION	= SKILL_BASIC,
		SKILL_ELECTRICAL	= SKILL_BASIC
	)
	max_skill = list(
		SKILL_SCIENCE	= SKILL_MAX,
		SKILL_DEVICES	= SKILL_MAX,
		SKILL_CONSTRUCTION	= SKILL_MAX,
		SKILL_ELECTRICAL	= SKILL_MAX,
		SKILL_CHEMISTRY	= SKILL_MAX,
		SKILL_COMPUTER	= SKILL_MAX
	)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/datum/job/submap/facolony/colonist/medic
	title = "Crew Medic"
	supervisors = "Ship Captain"
	info = "Keep the outpost alive. Patch people up and handle emergencies."
	total_positions = 1
	min_skill = list(
		SKILL_MEDICAL = SKILL_TRAINED,
		SKILL_CHEMISTRY = SKILL_BASIC,
		SKILL_ANATOMY = SKILL_EXPERIENCED
	)
	max_skill = list(
		SKILL_MEDICAL	= SKILL_MAX,
		SKILL_ANATOMY	= SKILL_MAX,
		SKILL_CHEMISTRY = SKILL_MAX,
		SKILL_VIROLOGY	= SKILL_MAX
	)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/datum/job/submap/facolony/colonist/engineer
	title = "Ship Mechanic"
	supervisors = "Ship Captain"
	info = "Maintain power, atmos, and repairs to keep the outpost operational."
	total_positions = 2
	min_skill = list(
		SKILL_COMPUTER		= SKILL_BASIC,
		SKILL_EVA			= SKILL_BASIC,
		SKILL_CONSTRUCTION	= SKILL_TRAINED,
		SKILL_ELECTRICAL	= SKILL_BASIC,
		SKILL_ATMOS			= SKILL_BASIC,
		SKILL_ENGINES		= SKILL_BASIC
	)

	max_skill = list(
		SKILL_CONSTRUCTION	= SKILL_MAX,
		SKILL_ELECTRICAL	= SKILL_MAX,
		SKILL_ATMOS			= SKILL_MAX,
		SKILL_ENGINES		= SKILL_MAX
	)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/obj/submap_landmark/spawnpoint/facolony/leader_spawn
	name = "Ship Captain"

/obj/submap_landmark/spawnpoint/facolony/crewman_spawn
	name = "Crewman"

/obj/submap_landmark/spawnpoint/facolony/scientist_spawn
	name = "Systems Technician"

/obj/submap_landmark/spawnpoint/facolony/medic_spawn
	name = "Crew Medic"

/obj/submap_landmark/spawnpoint/facolony/engineer_spawn
	name = "Ship Mechanic"

/obj/submap_landmark/joinable_submap/facolony
	name = "FA Blockade Runners Outpost"
	archetype = /singleton/submap_archetype/facolony

var/global/const/access_facolony = "ACCESS_FACOLONY"
/datum/access/facolony
	id = access_facolony

/area/map_template/facolony
	req_access = list(access_facolony)

/area/map_template/facolony/command
	name = "\improper IPV Celeste Hauler - Bridge"
	icon_state = "A"

/area/map_template/facolony/airlock
	name = "\improper Base Primary External Airlock"
	icon_state = "A"

/area/map_template/facolony/armory
	name = "\improper Ship Armory"
	icon_state = "A"

/area/map_template/facolony/bathroom
	name = "\improper Base Lavatory"
	icon_state = "A"

/area/map_template/facolony/dorms
	name = "\improper Base Dormitories"
	icon_state = "A"

/area/map_template/facolony/engineering
	name = "\improper Ship Engineering"
	icon_state = "processing"

/area/map_template/facolony/atmospherics
	name = "\improper Ship Atmospherics"
	icon_state = "shipping"

/area/map_template/facolony/atmospherics2
	name = "\improper Base Atmospherics"
	icon_state = "shipping"

/area/map_template/facolony/cargo
	name = "\improper Ship Mid Cargo Area"
	icon_state = "A"

/area/map_template/facolony/cargo2
	name = "\improper Ship Aft Cargo Area"
	icon_state = "A"

/area/map_template/facolony/cargohatch
	name = "\improper Ship Cargo Hatch"
	icon_state = "B"

/area/map_template/facolony/unspecified
	name = "\improper Unspecified Compartment"
	icon_state = "A"

/area/map_template/facolony/tcomms
	name = "\improper Base Telecommunications"
	icon_state = "B2"

/area/map_template/facolony/medbay
	name = "\improper Ship Infirmary"
	icon_state = "A"

/area/map_template/facolony/surgery
	name = "\improper Ship Operating Theatre"
	icon_state = "A"

/area/map_template/facolony/messhall
	name = "\improper Ship Mess Hall"
	icon_state = "B"

/area/map_template/facolony/mineralprocessing
	name = "\improper Base Mining Site"
	icon_state = "A"

/area/map_template/facolony/science
	name = "\improper Base R&D"
	icon_state = "A"

/area/map_template/facolony/warehouse
	name = "\improper Base warehouse"
	icon_state = "shipping"

/area/map_template/facolony/outsidewarehouse
	name = "\improper Trade Zone warehouse"
	icon_state = "shipping"

/area/map_template/facolony/tradezone
	name = "\improper Trade Zone"
	icon_state = "shipping"

/obj/item/card/id/facolony
	name = "Crew access card"
	desc = "Old worn-out access card."
	access = list(access_facolony)
	color = COLOR_OFF_WHITE
	detail_color = "#000000"

/obj/floor_decal/falogo
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "falogo"

/obj/structure/sign/double/faflag/left
	name = "Frontier Alliance flag"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "faflag_l"

/obj/structure/sign/double/faflag/right
	name = "Frontier Alliance flag"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "faflag_r"

/obj/structure/sign/double/falogo/
	name = "Frontier Alliance logo"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "falogo"

/obj/machinery/telecomms/hub/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/receiver/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/bus/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/processor/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/server/map_preset/facolony
	preset_name = "Internal"
	preset_color = "#4a869f"

/obj/machinery/telecomms/broadcaster/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/radio/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/radio/intercom/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/encryptionkey/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/radio/headset/map_preset/facolony
	preset_name = "Internal"
	encryption_key = /obj/item/device/encryptionkey/map_preset/facolony

/obj/machinery/door/airlock/facolony/command
	name = "Airlock"
	door_color = COLOR_COMMAND_BLUE
	stripe_color = "#545c68"

/obj/machinery/door/airlock/facolony/mining
	name = "Airlock"
	door_color = COLOR_PALE_ORANGE
	stripe_color = "#545c68"

/obj/machinery/door/airlock/multi_tile/facolony/general
	name = "Airlock"
	stripe_color = "#3E3D3D"

/obj/machinery/door/airlock/facolony/general
	name = "Airlock"
	stripe_color = "#3E3D3D"

/obj/machinery/door/airlock/glass/facolony/jail
	name = "Temporary Detention"
	stripe_color = "#9d2300"
