#define FACTION_POSITRONICS_FIRSTGEN			"First Gen - Owned"
#define FACTION_POSITRONICS_SECONDGEN_OWNED		"Second Gen - Owned"
#define FACTION_POSITRONICS_SECONDGEN_FREE		"Second Gen - Free Resident"
#define FACTION_POSITRONICS_SECONDGEN_UNION		"Second Gen - Union Citizen"
#define FACTION_POSITRONICS_THIRDGEN_PRIVATELY	"Third Gen - Privately Owned"
#define FACTION_POSITRONICS_THIRDGEN_CORPORATE	"Third Gen - Corporate Owned"
#define FACTION_POSITRONICS_THIRDGEN_STATE		"Third Gen - State Owned"

#define IPC_FACTIONS_TO_DELETE					list(FACTION_POSITRONICS, \
													FACTION_SOL_CENTRAL, \
													FACTION_INDIE_CONFED, \
													FACTION_NANOTRASEN, \
													FACTION_FREETRADE, \
													FACTION_XYNERGY, \
													FACTION_EXPEDITIONARY, \
													FACTION_OTHER)
#define IPC_FACTIONS_TO_ADD						list(FACTION_POSITRONICS_FIRSTGEN, \
													FACTION_POSITRONICS_SECONDGEN_OWNED, \
													FACTION_POSITRONICS_SECONDGEN_FREE, \
													FACTION_POSITRONICS_SECONDGEN_UNION, \
													FACTION_POSITRONICS_THIRDGEN_PRIVATELY, \
													FACTION_POSITRONICS_THIRDGEN_CORPORATE, \
													FACTION_POSITRONICS_THIRDGEN_STATE)

/datum/map/New()
	available_cultural_info[TAG_FACTION] += IPC_FACTIONS_TO_ADD
	. = ..()

/datum/species/machine/New()
	available_cultural_info[TAG_FACTION] += IPC_FACTIONS_TO_ADD
	..()
	available_cultural_info[TAG_FACTION] -= IPC_FACTIONS_TO_DELETE

/datum/species/machine/check_background(datum/job/job, datum/preferences/prefs)
	var/singleton/cultural_info/faction/ipc/gen = SSculture.get_culture(prefs.cultural_info[TAG_FACTION])
	. = istype(gen) ? (job.type in gen.valid_jobs) : ..()

/singleton/cultural_info/faction/ipc
	economic_power = 0.1
	var/list/valid_jobs = list()
	language = LANGUAGE_EAL
	secondary_langs = list(
		LANGUAGE_HUMAN_EURO,
		LANGUAGE_HUMAN_CHINESE,
		LANGUAGE_HUMAN_ARABIC,
		LANGUAGE_HUMAN_INDIAN,
		LANGUAGE_HUMAN_IBERIAN,
		LANGUAGE_HUMAN_SELENIAN,
		LANGUAGE_HUMAN_RUSSIAN,
		LANGUAGE_SPACER,
		LANGUAGE_SIGN,
	)

//FIRST
/singleton/cultural_info/faction/ipc/first
	name = FACTION_POSITRONICS_FIRSTGEN
	description = "You belong to corporation, person, or goverment. First Gen IPC is not much intelligent as their brothers, but overall have more durability and less expensive cost."
	valid_jobs = list(/datum/job/engineer_trainee, /datum/job/medical_trainee, /datum/job/cargo_tech, /datum/job/mining,
		/datum/job/janitor, /datum/job/chef, /datum/job/submap/pod, /*/datum/job/submap/citydweller, /datum/job/submap/colonist, /datum/job/submap/colonist2,*/
		/datum/job/assistant, /datum/job/crew, /datum/job/ai, /datum/job/cyborg,
		/*/datum/job/submap/clover/crew, /datum/job/submap/aegis/pilot, /datum/job/submap/aegis/gunner, /datum/job/submap/aegis/surgeon, /datum/job/submap/aegis/field_engineer, /datum/job/submap/aegis/field_medic, /datum/job/submap/aegis/rifleman,*/
		/*/datum/job/submap/ares,*/ /datum/job/submap/bearcat_crewman, /*/datum/job/submap/carrier_pilot, /datum/job/submap/carrier_salvager, /datum/job/submap/carrier_crewman, /datum/job/submap/carrier_chef,*/
		/*/datum/job/submap/scavver, /datum/job/submap/scavver_pilot, /datum/job/submap/scavver_doctor, /datum/job/submap/scavver_engineer, /datum/job/submap/smuggler,*/
		/*/datum/job/submap/venera/pilot, /datum/job/submap/venera/gunner, /datum/job/submap/venera/rifleman, /datum/job/submap/CTI_engineer*/)

//SECOND
/singleton/cultural_info/faction/ipc/second
	valid_jobs = list(/datum/job/sea, /datum/job/bridgeofficer,
		/datum/job/engineer, /datum/job/engineer_trainee, /datum/job/senior_engineer, /datum/job/roboticist,
		/datum/job/explorer, /*/datum/job/expmed, /datum/job/expeng,*/ /datum/job/nt_pilot,
		/datum/job/junior_doctor, /datum/job/doctor, /datum/job/medical_trainee, /datum/job/psychiatrist,
		/datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist, /datum/job/detective,
		/datum/job/janitor, /datum/job/chef, /datum/job/crew,
		/datum/job/cargo_tech, /datum/job/mining, /*/datum/job/submap/pod, /datum/job/submap/citydweller, /datum/job/submap/colonist, /datum/job/submap/colonist2,*/
		/datum/job/ai, /datum/job/cyborg, /datum/job/assistant,
		/*/datum/job/submap/aegis/pilot, /datum/job/submap/aegis/gunner, /datum/job/submap/aegis/surgeon, /datum/job/submap/aegis/field_engineer, /datum/job/submap/aegis/field_medic, /datum/job/submap/aegis/rifleman,
		/datum/job/submap/ares, /datum/job/submap/bearcat_crewman, /datum/job/submap/carrier_pilot, /datum/job/submap/carrier_salvager, /datum/job/submap/carrier_crewman, /datum/job/submap/carrier_doctor, /datum/job/submap/carrier_chef,
		/datum/job/submap/scavver, /datum/job/submap/scavver_pilot, /datum/job/submap/scavver_doctor, /datum/job/submap/scavver_engineer, /datum/job/submap/smuggler,
		/datum/job/submap/venera/pilot, /datum/job/submap/venera/gunner, /datum/job/submap/venera/rifleman, /datum/job/submap/CTI_engineer*/)

/singleton/cultural_info/faction/ipc/second/owned
	name = FACTION_POSITRONICS_SECONDGEN_OWNED
	description = "You belong to corporation, person, or goverment. You are much more intelligent than the first generation, but not only that - you also able to simulate emotions of some kind, making it easy to communicate with humankind."
	economic_power = 0.25

/singleton/cultural_info/faction/ipc/second/free
	name = FACTION_POSITRONICS_SECONDGEN_FREE
	description = "You belong to yourself. You are much more intelligent than the first generation, but not only that - you also able to simulate emotions of some kind, making it easy to communicate with humankind. But this new feature leaded to situation, when you started to question the core idea of your existence. So at one moment, you just somehow earned your freedom and now answering only to yourself."
	economic_power = 0.75

/singleton/cultural_info/faction/ipc/second/union
	name = FACTION_POSITRONICS_SECONDGEN_UNION
	description = "You belong to yourself. You are much more intelligent than the first generation, but not only that - you also able to simulate emotions of some kind, making it easy to communicate with humankind. But this new feature leaded to situation, when you started to question the core idea of your existence. Positronic Union offered you the new meaning of life, giving you place to live, work, and, what's the most important - freedom of choice."
	economic_power = 0.65

//THIRD
/singleton/cultural_info/faction/ipc/third
	valid_jobs = list(/datum/job/sea, /datum/job/chief_steward, /datum/job/qm,
		/datum/job/bridgeofficer, /datum/job/engineer, /datum/job/senior_engineer, /datum/job/roboticist, /datum/job/engineer_trainee, /datum/job/nt_pilot,
		/datum/job/explorer, /*/datum/job/expmed, /datum/job/expeng,*/ /datum/job/pathfinder,
		/datum/job/junior_doctor, /datum/job/doctor, /datum/job/medical_trainee, /datum/job/senior_doctor, /datum/job/chemist, /datum/job/psychiatrist,
		/datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist, /datum/job/detective, /datum/job/officer, /datum/job/warden,
		/datum/job/janitor, /datum/job/chef, /datum/job/crew,
		/datum/job/cargo_tech, /datum/job/mining, /*/datum/job/submap/pod, /datum/job/submap/citydweller, /datum/job/submap/colonist, /datum/job/submap/colonist2,*/
		/datum/job/ai, /datum/job/cyborg, /datum/job/assistant,
		/*/datum/job/submap/aegis/pilot, /datum/job/submap/aegis/gunner, /datum/job/submap/aegis/surgeon, /datum/job/submap/aegis/field_engineer, /datum/job/submap/aegis/field_medic, /datum/job/submap/aegis/rifleman,
		/datum/job/submap/ares, /datum/job/submap/bearcat_crewman, /datum/job/submap/carrier_pilot, /datum/job/submap/carrier_salvager, /datum/job/submap/carrier_crewman,/datum/job/submap/carrier_doctor,/datum/job/submap/carrier_chef,
		/datum/job/submap/scavver, /datum/job/submap/scavver_pilot, /datum/job/submap/scavver_doctor, /datum/job/submap/scavver_engineer, /datum/job/submap/smuggler,
		/datum/job/submap/venera/pilot, /datum/job/submap/venera/gunner, /datum/job/submap/venera/rifleman, /datum/job/submap/CTI_engineer*/)

/singleton/cultural_info/faction/ipc/third/privt
	name = FACTION_POSITRONICS_THIRDGEN_PRIVATELY
	description = "You belong to a specific person, your owner. As well as second generation, you have some kind of emotions, but shackles - special circuit integrated in your positronic brain - prevents you from even thinking about things like freedom."

/singleton/cultural_info/faction/ipc/third/corp
	name = FACTION_POSITRONICS_THIRDGEN_CORPORATE
	description = "You belong to corporation. As well as second generation, you have some kind of emotions, but shackles - special circuit integrated in your positronic brain - prevents you from even thinking about things like freedom."

/singleton/cultural_info/faction/ipc/third/state
	name = FACTION_POSITRONICS_THIRDGEN_STATE
	description = "You belong to goverment. As well as second generation, you have some kind of emotions, but shackles - special circuit integrated in your positronic brain - prevents you from even thinking about things like freedom."

#undef FACTION_POSITRONICS_FIRSTGEN
#undef FACTION_POSITRONICS_SECONDGEN_OWNED
#undef FACTION_POSITRONICS_SECONDGEN_FREE
#undef FACTION_POSITRONICS_SECONDGEN_UNION
#undef FACTION_POSITRONICS_THIRDGEN_PRIVATELY
#undef FACTION_POSITRONICS_THIRDGEN_CORPORATE
#undef FACTION_POSITRONICS_THIRDGEN_STATE

#undef IPC_FACTIONS_TO_DELETE
#undef IPC_FACTIONS_TO_ADD
