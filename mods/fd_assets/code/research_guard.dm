/// Access
/var/const/access_research_security = "ACCESS_RESEARCH_SECURITY" //97
/datum/access/rnd_guard
	id = access_research_security
	desc = "Research Checkpoint"
	region = ACCESS_REGION_RESEARCH

/obj/item/card/id/torch/crew/research/research_guard
	job_access_type = /datum/job/research_guard

/// Headsets
/obj/item/device/radio/headset/research_guard
	name = "research guard's headset"
	desc = "A headset of the servants to the corporate overlords."
	icon_state = "nt_headset"
	item_state = "headset"
	ks1type = /obj/item/device/encryptionkey/headset_research_guard

/obj/item/device/radio/headset/research_guard/alt
	name = "research guard's bowman headset"
	icon_state = "nt_headset_alt"
	item_state = "nt_headset_alt"

/obj/item/device/encryptionkey/headset_research_guard
	name = "research_guard's encryption key"
	icon_state = "nt_cypherkey"
	channels = list("Science" = 1)

//Uniform
/obj/item/clothing/under/rank/guard/research_guard
	accessories = list(/obj/item/clothing/accessory/corptie)

/// Locker
/obj/structure/closet/secure_closet/research_guard/WillContain()
	return list(
		/obj/item/clothing/under/rank/guard/research_guard,
		/obj/item/clothing/suit/armor/pcarrier/medium/nt,
		/obj/item/clothing/head/helmet/nt/guard,
		/obj/item/clothing/head/soft/sec/corp/guard,
		/obj/item/clothing/head/beret/guard,
		/obj/item/clothing/accessory/armband/whitered,
		/obj/item/device/radio/headset/research_guard,
		/obj/item/device/radio/headset/research_guard/alt,
		/obj/item/clothing/mask/gas/half,
		/obj/item/material/clipboard,
		/obj/item/folder,
		/obj/item/device/taperecorder,
		/obj/item/device/tape/random = 3,
		/obj/item/storage/belt/holster/security,
		/obj/item/device/flash,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/melee/baton/loaded,
		/obj/item/handcuffs = 2,
		/obj/item/device/flashlight/maglight,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/glasses/tacgoggles,
		/obj/item/clothing/mask/balaclava,
		/obj/item/taperoll/research,
		/obj/item/device/hailer,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/accessory/badge/holo/NT,
		/obj/item/device/megaphone,
		/obj/item/gun/energy/stunrevolver/secure,
		/obj/item/clothing/shoes/jackboots,
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/security/exo, /obj/item/storage/backpack/satchel/sec/exo)),
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/dufflebag/sec, /obj/item/storage/backpack/messenger/sec/exo))
	)

/// Outfits
/singleton/hierarchy/outfit/job/torch/passenger/research_guard
	name = OUTFIT_JOB_NAME("Research Guard")
	l_ear = /obj/item/device/radio/headset/research_guard
	uniform = /obj/item/clothing/under/rank/guard/research_guard
	shoes = /obj/item/clothing/shoes/jackboots
	id_types = list(/obj/item/card/id/torch/crew/research/research_guard)
	pda_type = /obj/item/modular_computer/pda/science

/singleton/hierarchy/outfit/job/torch/passenger/research_guard/ec
	name = OUTFIT_JOB_NAME("Research Guard - Expeditionary Corps")
	uniform = /obj/item/clothing/under/solgov/utility/expeditionary/research

/// EC Guard Exosuit
/obj/item/rig/hazard/research_guard
	name = "EXO hardsuit control module"
	suit_type = "hazard hardsuit"
	desc = "A security hardsuit designed for prolonged EVA in dangerous environments."
	icon_state = "hazard_rig"
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_RESISTANT,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	online_slowdown = 2
	offline_slowdown = 3
	offline_vision_restriction = TINT_BLIND

	chest_type = /obj/item/clothing/suit/space/rig/hazard
	helm_type = /obj/item/clothing/head/helmet/space/rig/hazard
	boot_type = /obj/item/clothing/shoes/magboots/rig/hazard
	glove_type = /obj/item/clothing/gloves/rig/hazard

	allowed = list(/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/handcuffs,/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/melee/baton)

	req_access = list(access_research_security)

/obj/item/rig/hazard/research_guard/equipped
	initial_modules = list(
		/obj/item/rig_module/vision/sechud,
		/obj/item/rig_module/mounted/energy/taser,
		/obj/item/rig_module/cooling_unit)

///Job
/datum/job/research_guard
	title = "Research Guard"
	department = "Science"
	department_flag = SCI
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Science Officer"
	selection_color = "#473d63"
	economic_power = 5
	minimal_player_age = 0
	minimum_character_age = list(SPECIES_HUMAN = 26)
	outfit_type = /singleton/hierarchy/outfit/job/torch/passenger/research_guard
	allowed_branches = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/expeditionary_corps = /singleton/hierarchy/outfit/job/torch/passenger/research_guard/ec
	)

	allowed_ranks = list(
		/datum/mil_rank/civ/contractor,
		/datum/mil_rank/ec/e3,
		/datum/mil_rank/ec/e5
	)
	min_skill = list(SKILL_BUREAUCRACY	= SKILL_TRAINED,
						SKILL_EVA		= SKILL_BASIC,
						SKILL_COMBAT	= SKILL_BASIC,
						SKILL_WEAPONS	= SKILL_TRAINED
						)

	max_skill = list(	SKILL_COMBAT	= SKILL_EXPERIENCED,
						SKILL_WEAPONS	= SKILL_EXPERIENCED)
	skill_points = 20

	access = list(
		access_research_security, access_tox, access_tox_storage, access_maint_tunnels, access_research, access_xenobiology, access_xenoarch, access_nanotrasen, access_solgov_crew,
		access_expedition_shuttle, access_guppy, access_hangar, access_petrov, access_petrov_helm, access_guppy_helm,
		access_petrov_analysis, access_petrov_phoron, access_petrov_toxins, access_petrov_chemistry, access_petrov_maint, access_radio_sci
	)

	software_on_spawn = list(/datum/computer_file/program/camera_monitor)

/datum/job/research_guard/get_description_blurb()
	return "You are a security guard from the Organization of the Expeditionary Corps, which must protect the scientific department and its employees from various threats. Eat donuts, call scientists \"eggheads\"."

/datum/map/torch/New()
	. = ..()
	var/index = allowed_jobs.Find(/datum/job/scientist_assistant)
	if(index)
		index++
		allowed_jobs.Insert(index, /datum/job/research_guard)
