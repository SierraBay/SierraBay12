#define WEBHOOK_SUBMAP_LOADED_PHOBOS	"webhook_submap_phobos"

/obj/submap_landmark/joinable_submap/phobos
	name = "Third Fleet Patrol Craft"
	archetype = /singleton/submap_archetype/phobos

/singleton/submap_archetype/phobos
	descriptor = "SCG Third Fleet Patrol Craft"
	map = "Third Fleet Patrol Craft"
	crew_jobs = list(
		/datum/job/submap/lieutenant,
		/datum/job/submap/pilot,
		/datum/job/submap/sergeant,
		/datum/job/submap/officer,
		/datum/job/submap/senior_doctor,
		/datum/job/submap/doctor,
		/datum/job/submap/engineer
	)
	call_webhook = WEBHOOK_SUBMAP_LOADED_PHOBOS

/obj/submap_landmark/spawnpoint/phobos
	name = "Patrol Commanding Officer"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/phobos/pilot
	name = "Patrol Bridge Officer"

/obj/submap_landmark/spawnpoint/phobos/sergeant
	name = "Patrol Brig Chief"

/obj/submap_landmark/spawnpoint/phobos/officer
	name = "Patrol Master at Arms"

/obj/submap_landmark/spawnpoint/phobos/senior_doctor
	name = "Patrol Physician"

/obj/submap_landmark/spawnpoint/phobos/doctor
	name = "Patrol Medical Technician"

/obj/submap_landmark/spawnpoint/phobos/engineer
	name = "Patrol Engineer"

/datum/job/submap/lieutenant
	title = "Patrol Commanding Officer"
	supervisors = "Third Fleet HQ, the Sol Central Government and the Sol Code of Uniform Justice"
	selection_color = "#2f2f7f"
	outfit_type = /singleton/hierarchy/outfit/job/phobos/command
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_VATGROWN)
	allowed_branches = list(/datum/mil_branch/fleet)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o3,
		/datum/mil_rank/fleet/o4
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_SCIENCE     = SKILL_TRAINED,
	                    SKILL_PILOT       = SKILL_TRAINED)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX)
	skill_points = 30

/datum/job/submap/pilot
	title = "Patrol Bridge Officer"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commanding Officer and heads of staff"
	selection_color = "#2f2f7f"
	economic_power = 8
	outfit_type = /singleton/hierarchy/outfit/job/phobos/command/pilot
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,HUMAN_SPECIES)
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o1
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_PILOT       = SKILL_TRAINED)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX)
	skill_points = 20

/datum/job/submap/sergeant
	title = "Patrol Brig Chief"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Commanding Officer"
	economic_power = 5
	selection_color = "#601c1c"
	outfit_type = /singleton/hierarchy/outfit/job/phobos/security/sergeant
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,HUMAN_SPECIES)
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e6,
		/datum/mil_rank/fleet/e7,
		/datum/mil_rank/fleet/e8,
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_TRAINED,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_TRAINED,
	                    SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX,
	                    SKILL_FORENSICS   = SKILL_MAX)
	skill_points = 20

/datum/job/submap/officer
	title = "Patrol Master at Arms"
	total_positions = 3
	spawn_positions = 3
	supervisors = "Brig Chief"
	economic_power = 4
	selection_color = "#601c1c"
	outfit_type = /singleton/hierarchy/outfit/job/phobos/security
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,HUMAN_SPECIES)
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e3,
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_TRAINED,
	                    SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX,
	                    SKILL_FORENSICS   = SKILL_EXPERIENCED)

/datum/job/submap/senior_doctor
	title = "Patrol Physician"
	department = "Medical"
	department_flag = MED
	total_positions = 1
	spawn_positions = 1
	supervisors = "Commanding Officer"
	selection_color = "#013d3b"
	economic_power = 10
	outfit_type = /singleton/hierarchy/outfit/job/phobos/medical/senior
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,HUMAN_SPECIES)
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o1,
		/datum/mil_rank/fleet/o2,
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_MEDICAL     = SKILL_EXPERIENCED,
	                    SKILL_ANATOMY     = SKILL_EXPERIENCED,
	                    SKILL_CHEMISTRY   = SKILL_BASIC,
						SKILL_DEVICES     = SKILL_TRAINED)

	max_skill = list(   SKILL_MEDICAL     = SKILL_MAX,
	                    SKILL_ANATOMY     = SKILL_MAX,
	                    SKILL_CHEMISTRY   = SKILL_MAX)
	skill_points = 20

/datum/job/submap/doctor
	title = "Patrol Medical Technician"
	total_positions = 1
	spawn_positions = 1
	supervisors = "physician and Commanding Officer"
	economic_power = 7
	selection_color = "#013d3b"
	outfit_type = /singleton/hierarchy/outfit/job/phobos/medical
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e3,
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5,
		/datum/mil_rank/fleet/e6,
	)
	min_skill = list(   SKILL_EVA     = SKILL_BASIC,
	                    SKILL_MEDICAL = SKILL_BASIC,
	                    SKILL_ANATOMY = SKILL_BASIC)

	max_skill = list(   SKILL_MEDICAL     = SKILL_MAX,
	                    SKILL_CHEMISTRY   = SKILL_MAX)
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,HUMAN_SPECIES)
	skill_points = 22

/datum/job/submap/engineer
	title = "Patrol Engineer"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Commanding Officer"
	economic_power = 5
	selection_color = "#5b4d20"
	outfit_type = /singleton/hierarchy/outfit/job/phobos/engineering
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e3,
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5,
	)
	required_language = LANGUAGE_HUMAN_EURO
	whitelisted_species = list(SPECIES_HUMAN,HUMAN_SPECIES)
	min_skill = list(   SKILL_COMPUTER     = SKILL_BASIC,
	                    SKILL_EVA          = SKILL_BASIC,
	                    SKILL_CONSTRUCTION = SKILL_TRAINED,
	                    SKILL_ELECTRICAL   = SKILL_BASIC,
	                    SKILL_ATMOS        = SKILL_BASIC,
	                    SKILL_ENGINES      = SKILL_BASIC)

	max_skill = list(   SKILL_CONSTRUCTION = SKILL_MAX,
	                    SKILL_ELECTRICAL   = SKILL_MAX,
	                    SKILL_ATMOS        = SKILL_MAX,
	                    SKILL_ENGINES      = SKILL_MAX)
	skill_points = 20

/* ACCESS
 * =======
 */

var/global/const/access_away_phobos = "ACCESS_PHOBOS"
var/global/const/access_away_phobos_armory = "ACCESS_PHOBOS_ARMORY"
var/global/const/access_away_phobos_security = "ACCESS_PHOBOS_BRIG"
var/global/const/access_away_phobos_bridge = "ACCESS_PHOBOS_BRIDGE"
var/global/const/access_away_phobos_commander = "ACCESS_PHOBOS_COMMANDER"

/datum/access/access_away_phobos
	id = access_away_phobos
	desc = "Third Fleet Main"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_armory
	id = access_away_phobos_armory
	desc = "Third Fleet Armory"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_security
	id = access_away_phobos_security
	desc = "Third Fleet Brig"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_bridge
	id = access_away_phobos_bridge
	desc = "Third Fleet Bridge"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_commander
	id = access_away_phobos_commander
	desc = "Third Fleet Commander"
	region = ACCESS_REGION_NONE

// Patching-up //

/obj/item/clothing/under/solgov/utility/fleet/command/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/command/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/command/pilot/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/specialty/pilot,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/security/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/security/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/medical/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/medical/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/engineering/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/engineering/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/* OUTFITS
 * =======
 */

#define PHOBOS_OUTFIT_JOB_NAME(job_name) ("SCG Third Fleet Patrol - Job - " + job_name)

/singleton/hierarchy/outfit/job/phobos
	hierarchy_type = /singleton/hierarchy/outfit/job/phobos
	uniform = /obj/item/clothing/under/solgov/utility/fleet
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset/map_preset/phobos
	l_pocket = /obj/item/device/radio
	r_pocket = /obj/item/crowbar/prybar
	id_types = list(/obj/item/card/id/phobos)
	id_slot = slot_wear_id
	pda_type = null
	belt = null
	back = /obj/item/storage/backpack
	backpack_contents = null
	flags = OUTFIT_EXTENDED_SURVIVAL

/singleton/hierarchy/outfit/job/phobos/command
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Commanding Officer")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/command/phobos
	suit = /obj/item/clothing/suit/storage/solgov/service/fleet/officer
	head = /obj/item/clothing/head/solgov/dress/fleet
	id_types = list(/obj/item/card/id/phobos/commander)
	id_pda_assignment = "Commanding Officer"

/singleton/hierarchy/outfit/job/phobos/command/New()
	..()
	BACKPACK_OVERRIDE_COMMAND

/singleton/hierarchy/outfit/job/phobos/command/pilot
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Bridge Officer")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/command/pilot/phobos
	suit = /obj/item/clothing/suit/storage/solgov/service/fleet/officer
	head = /obj/item/clothing/head/solgov/dress/fleet
	id_types = list(/obj/item/card/id/phobos/pilot)
	id_pda_assignment = "Bridge Officer"

/singleton/hierarchy/outfit/job/phobos/security
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Master at Arms")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/security/phobos
	head = /obj/item/clothing/head/beret/solgov/fleet/security
	id_types = list(/obj/item/card/id/phobos/security)
	id_pda_assignment = "Master at Arms"

/singleton/hierarchy/outfit/job/phobos/security/New()
	..()
	BACKPACK_OVERRIDE_SECURITY

/singleton/hierarchy/outfit/job/phobos/security/sergeant
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Brig Chief")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/security/phobos
	suit = /obj/item/clothing/suit/storage/solgov/service/fleet/snco
	id_types = list(/obj/item/card/id/phobos/security/sergeant)
	id_pda_assignment = "Brig Chief"

/singleton/hierarchy/outfit/job/phobos/medical
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Medical Technician")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/medical/phobos
	head = /obj/item/clothing/head/beret/solgov/fleet/medical
	id_types = list(/obj/item/card/id/phobos/medical)
	id_pda_assignment = "Medical Technician"

/singleton/hierarchy/outfit/job/phobos/medical/New()
	..()
	BACKPACK_OVERRIDE_MEDICAL

/singleton/hierarchy/outfit/job/phobos/medical/senior
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Physician")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/medical/phobos
	suit = /obj/item/clothing/suit/storage/solgov/service/fleet/officer
	head = /obj/item/clothing/head/solgov/dress/fleet
	id_types = list(/obj/item/card/id/phobos/medical)
	id_pda_assignment = "Physician"

/singleton/hierarchy/outfit/job/phobos/engineering
	name = PHOBOS_OUTFIT_JOB_NAME("Patrol Engineer")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/engineering/phobos
	id_types = list(/obj/item/card/id/phobos/engineer)
	id_pda_assignment = "Engineer"

/singleton/hierarchy/outfit/job/phobos/engineering/New()
	..()
	BACKPACK_OVERRIDE_ENGINEERING

#undef PHOBOS_OUTFIT_JOB_NAME
#undef WEBHOOK_SUBMAP_LOADED_PHOBOS
