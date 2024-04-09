
/* JOBS */

/*	 	Command		 */

/datum/job/submap/airfield/command/instructor
	title = "Instructor"
	info = "You are Senior Enlisted Advisor. You assigned to teach new officers in academy as a Flight Instructor."
	supervisors = "Fleet Command, Senior Officers, Senior Enlisted Advisor"
	outfit_type = /singleton/hierarchy/outfit/job/airfield/command/instructor
	total_positions = 1
	spawn_positions = 1
	branch = /datum/mil_branch/fleet
	rank = /datum/mil_rank/fleet/e9_alt1
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e9_alt1
	)
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_PILOT = SKILL_EXPERIENCED,
		SKILL_EVA     = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_DEVICES = SKILL_BASIC,
		SKILL_BUREAUCRACY = SKILL_BASIC,
	)

	max_skill = list(	SKILL_PILOT        = SKILL_MAX,
	                    SKILL_COMBAT       = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS      = SKILL_EXPERIENCED,
	                    SKILL_CONSTRUCTION = SKILL_MAX,
	                    SKILL_ELECTRICAL   = SKILL_MAX,
	                    SKILL_ENGINES      = SKILL_MAX,
	                    SKILL_ARMAMENT     = SKILL_TRAINED,
	                    SKILL_ATMOS        = SKILL_MAX)
	skill_points = 20

/datum/job/submap/airfield/command/assistant
	title = "Assistant of Instructor"
	info = "You are right hand of Senior Enlisted Advisor. You are sufficiently trained to be considered proficient in your station, however, you have not yet passed the training courses and Senior Non-Commissioned Officer Commission to become one of them. Who knows, maybe working at this base will lead you to that?"
	supervisors = "Fleet Command, Senior Officers, Senior Enlisted Advisor"
	outfit_type = /singleton/hierarchy/outfit/job/airfield/command/assistant
	total_positions = 1
	spawn_positions = 1
	branch = /datum/mil_branch/fleet
	rank = /datum/mil_rank/fleet/e6
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e6
	)
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_PILOT = SKILL_EXPERIENCED,
		SKILL_EVA     = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_DEVICES = SKILL_BASIC,
		SKILL_BUREAUCRACY = SKILL_BASIC,
	)

	max_skill = list(	SKILL_PILOT        = SKILL_MAX,
	                    SKILL_COMBAT       = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS      = SKILL_EXPERIENCED,
	                    SKILL_CONSTRUCTION = SKILL_MAX,
	                    SKILL_ELECTRICAL   = SKILL_MAX,
	                    SKILL_ENGINES      = SKILL_MAX,
	                    SKILL_ATMOS        = SKILL_MAX)
	skill_points = 20

/* 		Technics/NPC	 */

/datum/job/submap/airfield/engineer
	title = "Ground Service"
	info = "You are part of ground service. Repair this basement and do other shit with it! ."
	supervisors = "Fleet Command, Senior Officers, Senior Enlisted Advisor"
	outfit_type = /singleton/hierarchy/outfit/job/airfield/engineers
	total_positions = 100
	spawn_positions = 100
	branch = /datum/mil_branch/fleet
	rank = /datum/mil_rank/fleet/e6
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e6
	)
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_WEAPONS = SKILL_BASIC,
		SKILL_COMBAT = SKILL_BASIC,
		SKILL_COMPUTER     = SKILL_BASIC,
		SKILL_EVA          = SKILL_BASIC,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
		SKILL_ELECTRICAL   = SKILL_TRAINED,
		SKILL_ATMOS        = SKILL_BASIC,
		SKILL_ENGINES      = SKILL_BASIC)

	max_skill = list(   SKILL_CONSTRUCTION = SKILL_MAX,
	                    SKILL_ELECTRICAL   = SKILL_MAX,
	                    SKILL_ATMOS        = SKILL_MAX,
	                    SKILL_ENGINES      = SKILL_MAX)
	skill_points = 20

/* 		Recruits		 */

/datum/job/submap/airfield/cadet
	title = "Cadet of Flight School"
	info = "You are a cadet at the Officer's Academy. Unlike the others, you have chosen to walk the thin line between the void and the earth. As a pilot, you will face many challenges, but all of them are just the beginning of your thorny journey.."
	supervisors = "Fleet Command, Senior Officers, Senior Enlisted Advisor"
	outfit_type = /singleton/hierarchy/outfit/job/airfield/cadet
	total_positions = 15
	spawn_positions = 15
	branch = /datum/mil_branch/fleet
	rank = /datum/mil_rank/fleet/o0
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o0
	)
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_PILOT = SKILL_EXPERIENCED,
		SKILL_EVA     = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_ARMAMENT = SKILL_BASIC
	)

	max_skill = list(
		SKILL_PILOT = SKILL_MAX,
		SKILL_WEAPONS = SKILL_MAX,
		SKILL_COMBAT = SKILL_MAX,
	)
	skill_points = 20



/* 		Spawns 		*/

/obj/submap_landmark/spawnpoint/airfield
	name = "Cadet of Flight School"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/airfield/instructor
	name = "Instructor"

/obj/submap_landmark/spawnpoint/airfield/assistant
	name = "Assistant of Instructor"

/obj/submap_landmark/spawnpoint/airfield/engineer
	name = "Ground Service"

/* 		Outfit		 */
/singleton/hierarchy/outfit/job/airfield/command/instructor
	name = OUTFIT_JOB_NAME("Rubicon - SEA")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/command
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = null
	id_types = list(/obj/item/card/id/torch/crew/sea)
	pda_type = /obj/item/modular_computer/pda/heads
	head = /obj/item/clothing/head/beret/solgov/fleet/branch/third

/singleton/hierarchy/outfit/job/airfield/command/assistant
	name = OUTFIT_JOB_NAME("Rubicon - Assistant")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/command
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = null
	id_types = list(/obj/item/card/id/torch/crew/bridgeofficer)
	pda_type = /obj/item/modular_computer/pda/heads
	head = /obj/item/clothing/head/beret/solgov/fleet/branch/third

/singleton/hierarchy/outfit/job/airfield/engineers
	name = OUTFIT_JOB_NAME("Rubicon - Ground Service")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/engineering
	shoes = /obj/item/clothing/shoes/dutyboots
	suit = /obj/item/clothing/suit/storage/hazardvest
	belt = /obj/item/storage/belt/utility/full
	r_pocket = /obj/item/device/multitool
	l_ear = null
	id_types = list(/obj/item/card/id/torch/crew/engineering)
	pda_type = /obj/item/modular_computer/pda/engineering
	head = /obj/item/clothing/head/beret/solgov/fleet/branch/third

/singleton/hierarchy/outfit/job/airfield/cadet
	name = OUTFIT_JOB_NAME("Rubicon - Cadet")
	uniform = /obj/item/clothing/under/solgov/utility/fleet
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = null
	id_types = list(/obj/item/card/id/torch/crew/bridgeofficer)
	pda_type = /obj/item/modular_computer/pda
	head = /obj/item/clothing/head/beret/solgov/fleet/branch/third
