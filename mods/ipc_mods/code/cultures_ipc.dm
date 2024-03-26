/singleton/cultural_info/culture/ipc
	var/list/valid_jobs = list()
	name = CULTURE_POSITRONICS_GEN1
	valid_jobs = list(/datum/job/engineer_trainee, /datum/job/doctor_trainee, /datum/job/cargo_tech, /datum/job/cargo_assistant, /datum/job/mining,
	/datum/job/janitor, /datum/job/chef, /datum/job/scientist_assistant, /datum/job/assistant, /datum/job/steward, /datum/job/ai, /datum/job/cyborg)
	language = LANGUAGE_EAL
	secondary_langs = list(
		LANGUAGE_HUMAN_EURO,
		LANGUAGE_HUMAN_CHINESE,
		LANGUAGE_HUMAN_ARABIC,
		LANGUAGE_HUMAN_INDIAN,
		LANGUAGE_HUMAN_IBERIAN,
		LANGUAGE_HUMAN_RUSSIAN,
		LANGUAGE_SPACER,
		LANGUAGE_SIGN
	)
	economic_power = 0.1

/singleton/cultural_info/culture/ipc/gen2
	name = CULTURE_POSITRONICS_GEN2
	nickname = "ИПС второго поколения"
	valid_jobs = list(/datum/job/adjutant,
		/datum/job/exploration_leader, /datum/job/explorer, /datum/job/explorer_pilot, /datum/job/explorer_medic, /datum/job/explorer_engineer,
		/datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys, /datum/job/engineer_trainee,
		/datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/chemist, /datum/job/chaplain,
		/datum/job/qm, /datum/job/cargo_tech,  /datum/job/cargo_assistant, /datum/job/mining,
		/datum/job/janitor, /datum/job/chef, /datum/job/bartender, /datum/job/steward, /datum/job/chief_steward,
		/datum/job/senior_scientist, /datum/job/scientist, /datum/job/roboticist, /datum/job/scientist_assistant,
		/datum/job/ai, /datum/job/cyborg, /datum/job/assistant,
		/datum/job/submap/bearcat_captain, /datum/job/submap/bearcat_crewman,
		/datum/job/submap/scavver_pilot, /datum/job/submap/scavver_doctor, /datum/job/submap/scavver_engineer
		)
	economic_power = 0.75

/singleton/cultural_info/culture/ipc/gen3
	name = CULTURE_POSITRONICS_GEN3
	nickname = "ИПС третьего поколения"
	valid_jobs = list(/datum/job/hop, /datum/job/rd, /datum/job/cmo, /datum/job/chief_engineer,
		/datum/job/iaa, /datum/job/adjutant,
		/datum/job/exploration_leader, /datum/job/explorer, /datum/job/explorer_pilot, /datum/job/explorer_medic, /datum/job/explorer_engineer,
		/datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys, /datum/job/engineer_trainee,
		/datum/job/warden, /datum/job/detective, /datum/job/officer,
		/datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/chemist,
		/datum/job/qm, /datum/job/cargo_tech,  /datum/job/cargo_assistant, /datum/job/mining,
		/datum/job/janitor, /datum/job/chef, /datum/job/bartender, /datum/job/steward, /datum/job/chief_steward,
		/datum/job/senior_scientist, /datum/job/scientist, /datum/job/roboticist, /datum/job/scientist_assistant,
		/datum/job/ai, /datum/job/cyborg, /datum/job/assistant
)
	economic_power = 0.45
