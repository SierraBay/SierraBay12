// HAND TODO BELOW

#define WEBHOOK_SUBMAP_LOADED_HAND	"webhook_submap_hand"

/obj/submap_landmark/joinable_submap/away_scg_hand
	name = "hand Ship"
	archetype = /singleton/submap_archetype/away_scg_hand

/singleton/submap_archetype/away_scg_hand
	descriptor = "SCGF hand Ship"
	map = "hand Ship"
	crew_jobs = list(
		/datum/job/submap/hand,
		/datum/job/submap/hand/captain,
		/datum/job/submap/hand/surgeon
	)
	call_webhook = WEBHOOK_SUBMAP_LOADED_HAND

/obj/submap_landmark/spawnpoint/away_hand
	name = "Salvage Technican"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/away_hand/captain
	name = "Captain"



/obj/submap_landmark/spawnpoint/away_hand/surgeon
	name = "Corpsman"


/* ACCESS
 * =======
 */

var/global/const/access_hand = "ACCESS_CAVALRY"
var/global/const/access_hand_fleet_armory = "ACCESS_CAVALRY_EMERG_ARMORY"
var/global/const/access_hand_ops = "ACCESS_CAVALRY_OPS"
var/global/const/access_hand_pilot = "ACCESS_CAVALRY_PILOT"
var/global/const/access_hand_captain = "ACCESS_CAVALRY_CAPTAIN"
var/global/const/access_hand_commander = "ACCESS_CAVALRY_COMMANDER"

/datum/access/access_hand_hand
	id = access_hand
	desc = "SPS Main"
	region = ACCESS_REGION_NONE

/datum/access/access_hand_ops
	id = access_hand_ops
	desc = "SPS Army"
	region = ACCESS_REGION_NONE

/datum/access/access_hand_captain
	id = access_hand_captain
	desc = "SPS Captain"
	region = ACCESS_REGION_NONE

/datum/access/access_away_hand_commander
	id = access_hand_commander
	desc = "SPS Commander"
	region = ACCESS_REGION_NONE

/* JOBS
 * =======
 */

/datum/job/submap/hand
	title = "Army SCGSO Trooper"
	total_positions = 2
	outfit_type = /singleton/hierarchy/outfit/job/hand/army_ops
	allowed_branches = list(/datum/mil_branch/scga)
	allowed_ranks = list(
		/datum/mil_rank/scga/e4,
		/datum/mil_rank/scga/e5
		)
	supervisors = "Army Captain"
	loadout_allowed = TRUE
	is_semi_antagonist = TRUE
	info = "Вы просыпаетесь и выходите из криосна, ощущая прохладный воздух на своём лице, а также лёгкую тошноту. \
	Являясь одним из членов экипажа патрульного корабля 5-го флота ЦПСС, вы - член группы 'Буря', разведовательных войск СОЦПСС. \
	По данным бортового компьютера, поступал сигнал о неизвестных нападениях в этом регионе.\
	\
	 Вам крайне нежелательно приближаться к кораблям и станциям с опозновательными знаками без разрешения от командования группировкой. \
	 Исключением являются те ситуации, когда вы терпите бедствие или на вашем судне аварийная ситуация."
	whitelisted_species = list(SPECIES_VATGROWN, SPECIES_SPACER, SPECIES_GRAVWORLDER, SPECIES_MULE)
	min_skill = list(
		SKILL_COMBAT  = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_BASIC,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_ATMOS   = SKILL_BASIC,
		SKILL_ENGINES = SKILL_TRAINED,
		SKILL_EVA     = SKILL_TRAINED,
		SKILL_ELECTRICAL   = SKILL_TRAINED,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
	)
	access = list(access_hand, access_hand_ops)

/datum/job/submap/hand/captain
	title = "Captain"
	total_positions = 1
	alt_titles = (
		"Guardsman"
	)
	outfit_type = /singleton/hierarchy/outfit/job/hand/captain
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 27
	allowed_branches = list(
		/datum/mil_branch/fleet
		/datum/mil_branch/civilian
		/datum/mil_branch/contractor
		/datum/mil_branch/employee
	)
	allowed_ranks = list(
		/datum/mil_rank/scga/o2,
		/datum/mil_rank/scga/o3
	)
	supervisors = "Lieutenant Commander, Command of the Battle Group Bravo of the 5th fleet, SCGDF"
	loadout_allowed = TRUE
	is_semi_antagonist = TRUE
	info = "Вы просыпаетесь и выходите из криосна, ощущая прохладный воздух на своём лице, а также лёгкую тошноту. \
	Являясь одним из членов соединения, входящего в экипаж патрульного корабля 5-го флота ЦПСС, ваша задача состоит в руководстве группой 'Буря', разведовательных войск СОЦПСС. \
	По данным бортового компьютера, поступал сигнал о неизвестных нападениях в этом регионе.\
	\
	 Вам крайне нежелательно приближаться к кораблям и станциям с опозновательными знаками без разрешения от командования группировкой. \
	 Исключением являются те ситуации, когда вы терпите бедствие или на вашем судне аварийная ситуация."
	required_language = list(LANGUAGE_HUMAN_EURO, LANGUAGE_SPACER)
	whitelisted_species = list(SPECIES_HUMAN)
	min_skill = list(
		SKILL_COMBAT  = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_BASIC,
		SKILL_HAULING = SKILL_BASIC,
		SKILL_MEDICAL = SKILL_BASIC,
		SKILL_PILOT   = SKILL_TRAINED,
		SKILL_EVA     = SKILL_BASIC
	)
	access = list(access_hand, access_hand_ops, access_hand_fleet_armory, access_hand_captain)

/datum/job/submap/hand/surgeon
	title = "Fleet Corpsman"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/hand/surgeon
	allowed_branches = list(/datum/mil_branch/fleet)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o1,
		/datum/mil_rank/fleet/o2
	)
	supervisors = "Fleet Commander"
	loadout_allowed = TRUE
	info = "Вы просыпаетесь и выходите из криосна, ощущая прохладный воздух на своём лице, а также лёгкую тошноту. \
	Являясь одним из членов экипажа патрульного корабля 5-го флота ЦПСС, ваша задача состоит в медицинской поддержке экипажа. \
	\
	Хоть вы и являетесь офицером, в ваши обязанности НЕ входит командование экипажем - это всего лишь показатель вашего профессионализма в медицинской сфере. \
	\
	 Вам крайне нежелательно приближаться к кораблям и станциям с опозновательными знаками без разрешения от командования группировкой. \
	 Исключением являются те ситуации, когда вы терпите бедствие или на вашем судне аварийная ситуация."
	whitelisted_species = list(HUMAN_SPECIES)
	min_skill = list(
		SKILL_COMBAT    = SKILL_BASIC,
		SKILL_WEAPONS   = SKILL_BASIC,
		SKILL_HAULING   = SKILL_TRAINED,
		SKILL_MEDICAL   = SKILL_EXPERIENCED,
		SKILL_ANATOMY   = SKILL_BASIC,
		SKILL_CHEMISTRY = SKILL_BASIC,
		SKILL_EVA       = SKILL_BASIC
	)
	access = list(access_hand)


/* BRANCH & RANKS
 * =======
 */

/datum/mil_branch/fleet
	name = "SCG Fleet"
	name_short = "SCGF"
	email_domain = "fleet.mil"
	rank_types = list(
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5,
		/datum/mil_rank/fleet/e6,
		/datum/mil_rank/fleet/o1,
		/datum/mil_rank/fleet/o2,
		/datum/mil_rank/fleet/o3,
		/datum/mil_rank/fleet/o4,
		/datum/mil_rank/fleet/o6,
		/datum/mil_rank/fleet/o7,
		/datum/mil_rank/fleet/o8
	)
	spawn_rank_types = list(
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5,
		/datum/mil_rank/fleet/e6,
		/datum/mil_rank/fleet/o1,
		/datum/mil_rank/fleet/o2,
		/datum/mil_rank/fleet/o3,
		/datum/mil_rank/fleet/o4,
		/datum/mil_rank/fleet/o6,
		/datum/mil_rank/fleet/o7,
		/datum/mil_rank/fleet/o8
	)

/datum/mil_rank/grade()
	. = ..()
	if(!sort_order)
		return ""
	if(sort_order <= 10)
		return "E[sort_order]"
	return "O[sort_order - 10]"

/datum/mil_rank/fleet/e4
	name = "Petty Officer Third Class"
	name_short = "PO3"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/enlisted/e4, /obj/item/clothing/accessory/solgov/specialty/enlisted)
	sort_order = 4

/datum/mil_rank/fleet/e5
	name = "Petty Officer Second Class"
	name_short = "PO2"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/enlisted/e5, /obj/item/clothing/accessory/solgov/specialty/enlisted)
	sort_order = 5

/datum/mil_rank/fleet/e6
	name = "Petty Officer First Class"
	name_short = "PO1"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/enlisted/e6, /obj/item/clothing/accessory/solgov/specialty/enlisted)
	sort_order = 6

/datum/mil_rank/fleet/o1
	name = "Ensign"
	name_short = "ENS"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/officer, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 11

/datum/mil_rank/fleet/o2
	name = "Sub-lieutenant"
	name_short = "SLT"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/officer/o2, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 12

/datum/mil_rank/fleet/o3
	name = "Lieutenant"
	name_short = "LT"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/officer/o3, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 13

/datum/mil_rank/fleet/o4
	name = "Lieutenant Commander"
	name_short = "LCDR"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/officer/o4, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 14

/datum/mil_rank/fleet/o6
	name = "Captain"
	name_short = "CAPT"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/officer/o6, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 16

/datum/mil_rank/fleet/o7
	name = "Commodore"
	name_short = "CDRE"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/flag, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 17

/datum/mil_rank/fleet/o8
	name = "Rear Admiral"
	name_short = "RADM"
	accessory = list(/obj/item/clothing/accessory/solgov/rank/fleet/flag/o8, /obj/item/clothing/accessory/solgov/specialty/officer)
	sort_order = 18

/datum/mil_branch/scga
	name = "SCG Army"
	name_short = "SCGA"
	email_domain = "army.mil"
	rank_types = list(
		/datum/mil_rank/scga/e4,
		/datum/mil_rank/scga/e5,
		/datum/mil_rank/scga/o2,
		/datum/mil_rank/scga/o3
	)
	spawn_rank_types = list(
		/datum/mil_rank/scga/e4,
		/datum/mil_rank/scga/e5,
		/datum/mil_rank/scga/o2,
		/datum/mil_rank/scga/o3
	)

/datum/mil_rank/scga/e4
	name = "Corporal"
	name_short = "Cpl"
	accessory = list(
		/obj/item/clothing/accessory/scga_rank/e4,
		/obj/item/clothing/accessory/scga_badge/enlisted
	)
	sort_order = 4

/datum/mil_rank/scga/e5
	name = "Sergeant"
	name_short = "SGT"
	accessory = list(
		/obj/item/clothing/accessory/scga_rank/e5,
		/obj/item/clothing/accessory/scga_badge/enlisted
	)
	sort_order = 5

/datum/mil_rank/scga/o2
	name = "First Lieutenant"
	name_short = "1Lt"
	accessory = list(
		/obj/item/clothing/accessory/scga_rank/o2,
		/obj/item/clothing/accessory/scga_badge/officer
	)
	sort_order = 12

/datum/mil_rank/scga/o3
	name = "Captain"
	name_short = "CAPT"
	accessory = list(
		/obj/item/clothing/accessory/scga_rank/o3,
		/obj/item/clothing/accessory/scga_badge/officer
		)
	sort_order = 13

/* OUTFITS
 * =======
 */

#define HAND_OUTFIT_JOB_NAME(job_name) ("Hearer's Hand Chorus - Job - " + job_name)

/singleton/hierarchy/outfit/job/hand
	hierarchy_type = /singleton/hierarchy/outfit/job/hand
	uniform = /obj/item/clothing/under/solgov/utility/fleet/away_solhand
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset/away_scg_hand
	l_pocket = /obj/item/device/radio
	r_pocket = /obj/item/crowbar/prybar
	suit_store = /obj/item/tank/oxygen
	id_types = list(/obj/item/card/id/awaycavalry/fleet)
	id_slot = slot_wear_id
	pda_type = null
	belt = null
	back = /obj/item/storage/backpack/satchel/leather/navy
	backpack_contents = null
	flags = OUTFIT_EXTENDED_SURVIVAL

/singleton/hierarchy/outfit/job/hand/captain
	name = hand_OUTFIT_JOB_NAME("Captain")
	head = /obj/item/clothing/head/scga/utility
	uniform = /obj/item/clothing/under/scga/utility
	id_types = list(/obj/item/card/id/awaycavalry/ops/captain)
	gloves = /obj/item/clothing/gloves/thick/combat

/singleton/hierarchy/outfit/job/hand/captain/guardsman
	name = hand_OUTFIT_JOB_NAME("Guardsman")
	head = /obj/item/clothing/head/scga/utility
	uniform = /obj/item/clothing/under/scga/utility
	id_types = list(/obj/item/card/id/awaycavalry/ops/captain)
	gloves = /obj/item/clothing/gloves/thick/combat

/singleton/hierarchy/outfit/job/hand/captain/pilot
	name = hand_OUTFIT_JOB_NAME("Captain")
	head = /obj/item/clothing/head/scga/utility
	uniform = /obj/item/clothing/under/scga/utility
	id_types = list(/obj/item/card/id/awaycavalry/ops/captain)
	gloves = /obj/item/clothing/gloves/thick/combat

/singleton/hierarchy/outfit/job/hand/surgeon
	name = hand_OUTFIT_JOB_NAME("Doctor")
	uniform = /obj/item/clothing/under/solgov/utility/fleet/medical/hand
	belt = /obj/item/storage/belt/holster/security/tactical
	gloves = /obj/item/clothing/gloves/latex/nitrile



#undef HAND_OUTFIT_JOB_NAME
#undef WEBHOOK_SUBMAP_LOADED_HAND
