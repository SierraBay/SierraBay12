#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_SUPPLY "Supply"
#define ASSIGNMENT_SECURITY "Security"

/datum/map/sierra/setup_events()
	map_event_container = list(
		num2text(EVENT_LEVEL_MODERATE)	= new/datum/event_container/moderate/sierra,
		num2text(EVENT_LEVEL_MAJOR)	= new/datum/event_container/major/sierra,
	)

/datum/event/prison_break
	areaType = list(
		/area/security/sierra/hallway/port,
		/area/security/sierra/brig,
		/area/security/sierra/prison
	)

/datum/event/prison_break/xenobiology
	eventDept = "Science"
	areaName = list("Xenobiology")
	areaType = list(
		/area/rnd/xenobiology,
		/area/rnd/xenobiology/level1,
		/area/rnd/xenobiology/entry,
		/area/rnd/xenobiology/level2,
		/area/rnd/xenobiology/entry2,
		/area/rnd/xenobiology/storage2,
		/area/maintenance/seconddeck/xenobio
	)
	areaNotType = list(/area/rnd/xenobiology/xenoflora, /area/rnd/xenobiology/xenoflora_storage)

/datum/event/prison_break/warehouse
	eventDept = "Supply"
	areaName = list("Supply Warehouse")
	areaType = list(/area/quartermaster/storage)

/datum/event/prison_break/hardstorage
	eventDept = "Engineering"
	areaName = list("Engineering Storages")
	areaType = list(
		/area/engineering/hardstorage,
		/area/storage/tech,
		/area/storage/tech/high_risk
	)

/datum/event/prison_break/station
	eventDept = "Vessel"
	areaName = list("Brig","Supply Warehouse","Xenobiology","Engineering Storages")
	areaType = list(
		/area/security/sierra/hallway/port,
		/area/security/sierra/brig,
		/area/security/sierra/prison,
		/area/rnd/xenobiology,
		/area/rnd/xenobiology/level1,
		/area/rnd/xenobiology/entry,
		/area/rnd/xenobiology/level2,
		/area/rnd/xenobiology/entry2,
		/area/rnd/xenobiology/storage2,
		/area/maintenance/seconddeck/xenobio,
		/area/quartermaster/storage,
		/area/engineering/hardstorage,
		/area/storage/tech,
		/area/storage/tech/high_risk
	)
	areaNotType = list(/area/rnd/xenobiology/xenoflora, /area/rnd/xenobiology/xenoflora_storage)

/datum/event_container/moderate/sierra
	available_events = list(
		new/datum/event_meta(EVENT_LEVEL_MODERATE, "Xenobiology Breach",					/datum/event/prison_break/xenobiology,	0,		list(ASSIGNMENT_SCIENCE = 100)),
		new/datum/event_meta(EVENT_LEVEL_MODERATE, "Warehouse Breach",						/datum/event/prison_break/warehouse,	0,		list(ASSIGNMENT_SUPPLY = 100)),
		new/datum/event_meta(EVENT_LEVEL_MODERATE, "Hard Storage Breach",					/datum/event/prison_break/hardstorage,	0,		list(ASSIGNMENT_ENGINEER = 100))
	)

/datum/event_container/major/sierra
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Psionic Signal", 							/datum/event/minispasm,				0, 		list(ASSIGNMENT_MEDICAL = 10), 1),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Hivemind",								/datum/event/hivemind, 				0,		list(ASSIGNMENT_ENGINEER = 40,ASSIGNMENT_MEDICAL = 20,ASSIGNMENT_SECURITY = 40), 1),
		new/datum/event_meta(EVENT_LEVEL_MAJOR, "Containment Breach",						/datum/event/prison_break/station,	0,		list(ASSIGNMENT_ANY = 5))
	)



#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_SUPPLY
#undef ASSIGNMENT_SECURITY
