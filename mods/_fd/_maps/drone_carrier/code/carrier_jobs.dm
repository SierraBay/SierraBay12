/datum/job/submap/carrier_pilot
	title = "Bigsby Corporate Pilot"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/carrier/pilot
	supervisors = "Captain and FTU itself."
	info = "You are the pilot of your meagre Scavenger Crew. Keep your metal buddy safe, don't left it, try not to get bored."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN)
	min_skill = list(
		SKILL_HAULING = SKILL_BASIC,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_MECH = SKILL_MAX,
		SKILL_SCIENCE = SKILL_BASIC,
		SKILL_PILOT = SKILL_EXPERIENCED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_WEAPONS = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_MAX,
		SKILL_FINANCE = SKILL_MAX,
		SKILL_EVA = SKILL_MAX,
		SKILL_PILOT = SKILL_MAX,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_MAX,
		SKILL_BOTANY = SKILL_MAX,
		SKILL_COOKING = SKILL_MAX,
		SKILL_COMBAT = SKILL_MAX,
		SKILL_WEAPONS = SKILL_MAX,
		SKILL_FORENSICS = SKILL_MAX,
		SKILL_CONSTRUCTION = SKILL_MAX,
		SKILL_ELECTRICAL = SKILL_EXPERIENCED,
		SKILL_ATMOS = SKILL_EXPERIENCED,
		SKILL_ENGINES = SKILL_EXPERIENCED,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
		SKILL_MEDICAL = SKILL_EXPERIENCED,
		SKILL_ANATOMY = SKILL_EXPERIENCED,
		SKILL_CHEMISTRY = SKILL_EXPERIENCED
	)
	skill_points = 20

/datum/job/submap/carrier_captain
	title = "Bigsby Captain"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/carrier/captain
	supervisors = "FTU itself."
	info = "You are the captain of your meagre Scavenger Crew. Keep your crew safe, make money, try not to die from rebelios hands."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN)
	min_skill = list(
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_MECH = SKILL_MAX,
		SKILL_SCIENCE = SKILL_BASIC,
		SKILL_PILOT = SKILL_EXPERIENCED,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_WEAPONS = SKILL_EXPERIENCED,
		SKILL_MEDICAL = SKILL_TRAINED,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
		SKILL_ELECTRICAL = SKILL_TRAINED,
	)

	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_MAX,
		SKILL_FINANCE = SKILL_MAX,
		SKILL_EVA = SKILL_MAX,
		SKILL_PILOT = SKILL_MAX,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_MAX,
		SKILL_BOTANY = SKILL_MAX,
		SKILL_COOKING = SKILL_MAX,
		SKILL_COMBAT = SKILL_MAX,
		SKILL_WEAPONS = SKILL_MAX,
		SKILL_FORENSICS = SKILL_MAX,
		SKILL_CONSTRUCTION = SKILL_MAX,
		SKILL_ELECTRICAL = SKILL_MAX,
		SKILL_ATMOS = SKILL_EXPERIENCED,
		SKILL_ENGINES = SKILL_EXPERIENCED,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
		SKILL_MEDICAL = SKILL_MAX,
		SKILL_ANATOMY = SKILL_MAX,
		SKILL_CHEMISTRY = SKILL_MAX
	)
	skill_points = 20

/datum/job/submap/carrier_salvager
	title = "Bigsby Salvager"
	total_positions = 6
	outfit_type = /singleton/hierarchy/outfit/job/carrier/salvager
	supervisors = "Captain and FTU itself."
	info = "You are a part of your meagre Scavenger Crew. Keep yourself safe, and seek goodies for your ship and company. \
	Your weapons are limited; trade, salvage, but avoid conflict as a matter of course."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN)
	min_skill = list(
		SKILL_HAULING = SKILL_BASIC,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_SCIENCE = SKILL_BASIC,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_PILOT = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_MAX,
		SKILL_FINANCE = SKILL_MAX,
		SKILL_EVA = SKILL_MAX,
		SKILL_MECH = SKILL_MAX,
		SKILL_PILOT = SKILL_MAX,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_MAX,
		SKILL_BOTANY = SKILL_MAX,
		SKILL_COOKING = SKILL_MAX,
		SKILL_COMBAT = SKILL_MAX,
		SKILL_WEAPONS = SKILL_MAX,
		SKILL_FORENSICS = SKILL_MAX,
		SKILL_CONSTRUCTION = SKILL_MAX,
		SKILL_ELECTRICAL = SKILL_TRAINED,
		SKILL_ATMOS = SKILL_TRAINED,
		SKILL_ENGINES = SKILL_EXPERIENCED,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
		SKILL_MEDICAL = SKILL_MAX,
		SKILL_ANATOMY = SKILL_TRAINED,
		SKILL_CHEMISTRY = SKILL_TRAINED
	)
	skill_points = 20

/datum/job/submap/carrier_doctor
	title = "Bigsby Doctor"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/carrier/doctor
	supervisors = "Captain and FTU itself."
	info = "You are the doctor aboard your meagre Salvage team. Keep everyone alive. Try not to get bored while waiting for salvagers to return."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN,SPECIES_SKRELL,SPECIES_RESOMI)
	min_skill = list(
		SKILL_HAULING = SKILL_BASIC,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_MEDICAL = SKILL_EXPERIENCED,
		SKILL_ANATOMY = SKILL_EXPERIENCED,
		SKILL_CHEMISTRY = SKILL_BASIC,
		SKILL_DEVICES = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_MAX,
		SKILL_FINANCE = SKILL_MAX,
		SKILL_EVA = SKILL_MAX,
		SKILL_MECH = SKILL_MAX,
		SKILL_PILOT = SKILL_MAX,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_MAX,
		SKILL_BOTANY = SKILL_MAX,
		SKILL_COOKING = SKILL_MAX,
		SKILL_COMBAT = SKILL_MAX,
		SKILL_WEAPONS = SKILL_MAX,
		SKILL_FORENSICS = SKILL_MAX,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
		SKILL_ELECTRICAL = SKILL_TRAINED,
		SKILL_ATMOS = SKILL_TRAINED,
		SKILL_ENGINES = SKILL_TRAINED,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
		SKILL_MEDICAL = SKILL_MAX,
		SKILL_ANATOMY = SKILL_MAX,
		SKILL_CHEMISTRY = SKILL_MAX
	)
	skill_points = 20

/datum/job/submap/carrier_crewman
	title = "Bigsby Crewman"
	total_positions = 2
	outfit_type = /singleton/hierarchy/outfit/job/carrier/crewman
	supervisors = "Captain, other crewmates and FTU itself."
	info = "You are an young crewman aboard FTU-SV Bigsby. Try to help anyone around - you have just enough skills for everything! Probably... \
	Also, some spare hands on the salvage mission will be helpful too!"
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN,SPECIES_UNATHI,SPECIES_RESOMI)
	min_skill = list(
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_COMPUTER = SKILL_BASIC,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
		SKILL_ELECTRICAL = SKILL_BASIC,
		SKILL_ATMOS = SKILL_BASIC,
		SKILL_ENGINES = SKILL_BASIC,
		SKILL_MEDICAL = SKILL_BASIC,
		SKILL_ANATOMY = SKILL_BASIC,
		SKILL_CHEMISTRY = SKILL_BASIC,
		SKILL_PILOT = SKILL_BASIC,
		SKILL_BOTANY = SKILL_BASIC,
		SKILL_COOKING = SKILL_BASIC,
		SKILL_ATMOS = SKILL_BASIC,
		SKILL_ENGINES = SKILL_BASIC,

	)

	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_MAX,
		SKILL_FINANCE = SKILL_MAX,
		SKILL_EVA = SKILL_MAX,
		SKILL_MECH = SKILL_MAX,
		SKILL_PILOT = SKILL_MAX,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_MAX,
		SKILL_BOTANY = SKILL_MAX,
		SKILL_COOKING = SKILL_MAX,
		SKILL_COMBAT = SKILL_MAX,
		SKILL_WEAPONS = SKILL_MAX,
		SKILL_FORENSICS = SKILL_MAX,
		SKILL_CONSTRUCTION = SKILL_MAX,
		SKILL_ELECTRICAL = SKILL_MAX,
		SKILL_ATMOS = SKILL_MAX,
		SKILL_ENGINES = SKILL_MAX,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
		SKILL_MEDICAL = SKILL_MAX,
		SKILL_ANATOMY = SKILL_MAX,
		SKILL_CHEMISTRY = SKILL_MAX
	)
	skill_points = 10

/datum/job/submap/carrier_chef
	title = "Bigsby Cook"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/carrier/cook
	supervisors = "Captain and FTU itself"
	info = "You are the cook onboard salvagers vessel. Keep your crew in good mood and well-fed."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN,SPECIES_DIONA,SPECIES_UNATHI,SPECIES_RESOMI)
	min_skill = list(
		SKILL_HAULING = SKILL_BASIC,
		SKILL_EVA = SKILL_EXPERIENCED,
		SKILL_WEAPONS = SKILL_BASIC,
		SKILL_COOKING = SKILL_EXPERIENCED,
		SKILL_BOTANY    = SKILL_EXPERIENCED,
		SKILL_CHEMISTRY = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_BUREAUCRACY = SKILL_MAX,
		SKILL_FINANCE = SKILL_MAX,
		SKILL_EVA = SKILL_MAX,
		SKILL_PILOT = SKILL_MAX,
		SKILL_HAULING = SKILL_MAX,
		SKILL_COMPUTER = SKILL_MAX,
		SKILL_BOTANY = SKILL_MAX,
		SKILL_COOKING = SKILL_MAX,
		SKILL_COMBAT = SKILL_TRAINED,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_FORENSICS = SKILL_MAX,
		SKILL_CONSTRUCTION = SKILL_MAX,
		SKILL_ELECTRICAL = SKILL_EXPERIENCED,
		SKILL_ATMOS = SKILL_EXPERIENCED,
		SKILL_ENGINES = SKILL_EXPERIENCED,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
		SKILL_MEDICAL = SKILL_EXPERIENCED,
		SKILL_ANATOMY = SKILL_EXPERIENCED,
		SKILL_CHEMISTRY = SKILL_MAX
	)
	skill_points = 15

/datum/job/submap/carrier_cyborg
	title = "Salvage Drone"
	department_flag = MSC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Your crew and FTU itself"
	minimal_player_age = 7
	account_allowed = 0
	economic_power = 0
	loadout_allowed = FALSE
	outfit_type = /singleton/hierarchy/outfit/job/silicon/cyborg
	hud_icon = "hudblank"
	skill_points = 0
	no_skill_buffs = TRUE

/datum/job/submap/carrier_cyborg/handle_variant_join(mob/living/carbon/human/H, alt_title)
	return H && H.Robotize(SSrobots.get_mob_type_by_title(alt_title || title))

/datum/job/submap/carrier_cyborg/equip(mob/living/carbon/human/H)
	return !!H

/datum/job/submap/carrier_cyborg/New(datum/submap/_owner, abstract_job = FALSE)
	..()
	alt_titles = SSrobots.robot_alt_titles.Copy()
	alt_titles -= title // So the unit test doesn't flip out if a mob or mmi type is declared for our main title.

/obj/submap_landmark/spawnpoint/carrier_pilot
	name = "Bigsby Corporate Pilot"

/obj/submap_landmark/spawnpoint/carrier_salvager
	name = "Bigsby Salvager"

/obj/submap_landmark/spawnpoint/carrier_captain
	name = "Bigsby Captain"

/obj/submap_landmark/spawnpoint/carrier_chef
	name = "Bigsby Cook"

/obj/submap_landmark/spawnpoint/carrier_doctor
	name = "Bigsby Doctor"

/obj/submap_landmark/spawnpoint/carrier_crewman
	name = "Bigsby Crewman"

/obj/submap_landmark/spawnpoint/carrier_cyborg
	name = "Salvage Drone"

//ID'S

/var/const/access_bigsbyarmory = "ACCESS_BIGSBY_ARMORY"
/datum/access/bigsbyarmory
	id = access_bigsbyarmory
	desc = "Weapons Access"
	region = ACCESS_REGION_NONE

/obj/item/card/id/bigsby_captain
	access = list(access_bigsbyarmory)

/obj/item/card/id/bigsby

// OUTFITS

/singleton/hierarchy/outfit/job/carrier
	name = "Bigsby"
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	r_ear = null
	uniform = /obj/item/clothing/under/ftu/official
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/thick
	hierarchy_type = /singleton/hierarchy/outfit/job/carrier
	belt = /obj/item/storage/belt/utility/full
	id_types = list(/obj/item/card/id/bigsby)
	pda_type = null

/singleton/hierarchy/outfit/job/carrier/crewman
	name = "Bigsby Crewman"
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	r_ear = null
	uniform = /obj/item/clothing/under/ftu/official
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/thick
	belt = /obj/item/storage/belt/utility/full
	id_types = null
	pda_type = null

/singleton/hierarchy/outfit/job/carrier/salvager
	name = "Bigsby Salvager"
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	r_ear = null
	uniform = /obj/item/clothing/under/ftu/worker
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/thick
	belt = null

/singleton/hierarchy/outfit/job/carrier/pilot
	name = "Bigsby Pilot"
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	head = /obj/item/clothing/head/soft/black
	uniform = /obj/item/clothing/under/ftu/official
	suit = /obj/item/clothing/suit/armor/pcarrier/light
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	shoes = /obj/item/clothing/shoes/jackboots
	belt = null

/singleton/hierarchy/outfit/job/carrier/captain
	name = "Bigsby Captain"
	head = /obj/item/clothing/head/cowboy_hat
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	uniform = /obj/item/clothing/under/ftu/official
	suit = /obj/item/clothing/suit/storage/toggle/bomber
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	shoes = /obj/item/clothing/shoes/jackboots
	id_types = list(/obj/item/card/id/bigsby_captain)
	belt = null

/singleton/hierarchy/outfit/job/carrier/doctor
	name = "Bigsby Doctor"
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	uniform = /obj/item/clothing/under/ftu/medical
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	suit = /obj/item/clothing/suit/storage/toggle/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	belt = null

/singleton/hierarchy/outfit/job/carrier/cook
	name = "Bigsby Cook"
	l_ear = /obj/item/device/radio/headset/map_preset/carrier
	uniform = /obj/item/clothing/under/rank/chef
	r_pocket = /obj/item/device/radio/map_preset/carrier
	l_pocket = /obj/item/crowbar/prybar
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/thick/duty
	belt = null
