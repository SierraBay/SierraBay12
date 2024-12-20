/datum/gear/accessory/tags
	display_name = "dog tags"
	path = /obj/item/clothing/accessory/badge/dog_tags

/datum/gear/accessory/pilot_pin
	display_name = "pilot's qualification pin"
	path = /obj/item/clothing/accessory/solgov/specialty/pilot
	allowed_skills = list(SKILL_PILOT = SKILL_EXPERIENCED)

/datum/gear/accessory/armband_security
	allowed_roles = SECURITY_ROLES

/datum/gear/accessory/armband_cargo
	allowed_roles = SUPPLY_ROLES

/datum/gear/accessory/armband_medical
	allowed_roles = MEDICAL_ROLES

/datum/gear/accessory/armband_emt
	allowed_roles = list(/datum/job/doctor, /datum/job/doctor_trainee, /datum/job/explorer_medic)

/datum/gear/accessory/armband_engineering
	allowed_roles = ENGINEERING_ROLES

/datum/gear/accessory/armband_hydro
	allowed_roles = list(/datum/job/rd, /datum/job/senior_scientist, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/assistant)

/datum/gear/accessory/ntaward
	allowed_roles = NANOTRASEN_ROLES
	allowed_branches = list(/datum/mil_branch/employee)

/datum/gear/accessory/stethoscope
	allowed_roles = STERILE_ROLES

/datum/gear/passport/scg
	display_name = "passports selection - SCG"
	description = "A selection of SCG passports."
	path = /obj/item/passport/scg
	flags = GEAR_HAS_TYPE_SELECTION
	custom_setup_proc = TYPE_PROC_REF(/obj/item/passport, set_info)
	cost = 0

/datum/gear/passport/iccg
	display_name = "passports selection - ICCG"
	description = "A selection of ICCG passports."
	path = /obj/item/passport/iccg
	flags = GEAR_HAS_TYPE_SELECTION
	custom_setup_proc = TYPE_PROC_REF(/obj/item/passport, set_info)
	cost = 0

/datum/gear/passport
	display_name = "passports selection - independent"
	description = "A selection of independent regions passports."
	path = /obj/item/passport/independent
	flags = GEAR_HAS_SUBTYPE_SELECTION
	custom_setup_proc = TYPE_PROC_REF(/obj/item/passport, set_info)
	cost = 0

/datum/gear/workvisa
	display_name = "work visa"
	description = "A work visa issued by the Sol Central Government for the purpose of work."
	path = /obj/item/paper/workvisa
	cost = 0

/datum/gear/travelvisa
	display_name = "travel visa"
	description = "A travel visa issued by the Sol Central Government for the purpose of recreation."
	path = /obj/item/paper/travelvisa
	cost = 0

/datum/gear/utility/holster_belt
	display_name = "holser belt"
	path = /obj/item/storage/belt/holster/general
	allowed_roles = list(/datum/job/captain, /datum/job/hop, /datum/job/rd, /datum/job/cmo, /datum/job/chief_engineer, /datum/job/hos, /datum/job/iaa, /datum/job/adjutant)

/datum/gear/accessory/corpbadge
	display_name = "investigator holobadge (IAA)"
	path = /obj/item/clothing/accessory/badge/holo/investigator
	allowed_roles = list(/datum/job/iaa)

/datum/gear/accessory/stole
	allowed_roles = list(/datum/job/chaplain)

/datum/gear/accessory/solgov
	display_name = "Solgov command insignia"
	path = /obj/item/clothing/accessory/solgov/department/command
	allowed_roles = list(/datum/job/captain, /datum/job/hop, /datum/job/rd, /datum/job/cmo, /datum/job/chief_engineer, /datum/job/hos, /datum/job/iaa, /datum/job/adjutant)
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/solgov/engineering
	display_name = "Solgov engineering insignia"
	path = /obj/item/clothing/accessory/solgov/department/engineering
	allowed_roles = list(/datum/job/chief_engineer, /datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys, /datum/job/roboticist, /datum/job/engineer_trainee, /datum/job/explorer_engineer)
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/solgov/exploration
	display_name = "Solgov exploration insignia"
	path = /obj/item/clothing/accessory/solgov/department/exploration
	allowed_roles = list(/datum/job/explorer, /datum/job/explorer_medic, /datum/job/explorer_engineer, /datum/job/explorer_pilot, /datum/job/exploration_leader)
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/solgov/medical
	display_name = "Solgov medical insignia"
	path = /obj/item/clothing/accessory/solgov/department/medical
	allowed_roles = list(/datum/job/cmo, /datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/explorer_medic, /datum/job/psychiatrist, /datum/job/chemist, /datum/job/roboticist)
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/solgov/security
	display_name = "Solgov security insignia"
	path = /obj/item/clothing/accessory/solgov/department/security
	allowed_roles = list(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer, /datum/job/security_assistant)
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/solgov/supply
	display_name = "Solgov supply insignia"
	path = /obj/item/clothing/accessory/solgov/department/supply
	allowed_roles = list(/datum/job/qm,/datum/job/cargo_tech,/datum/job/cargo_assistant)
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/armband_corpsman
	display_name = "medical armband"
	path = /obj/item/clothing/accessory/armband/medblue
	allowed_roles = list(/datum/job/cmo, /datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/explorer_medic, /datum/job/psychiatrist, /datum/job/chemist)
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 0

/datum/gear/accessory/cross_blue
	display_name = "Cross blue"
	path = /obj/item/clothing/accessory/cross_blue
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 2

/datum/gear/accessory/cross_red
	display_name = "Cross red"
	path = /obj/item/clothing/accessory/cross_red
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 2

/datum/gear/accessory/flower_gold
	display_name = "Flower gold"
	path = /obj/item/clothing/accessory/flower_gold
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 2

/datum/gear/accessory/flower_silver
	display_name = "Flower silver"
	path = /obj/item/clothing/accessory/flower_silver
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 2

/datum/gear/accessory/flower_bronze
	display_name = "Flower bronze"
	path = /obj/item/clothing/accessory/flower_bronze
	flags = GEAR_HAS_NO_CUSTOMIZATION
	cost = 2
