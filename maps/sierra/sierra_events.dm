#define ASSIGNMENT_MEDICAL "Medical"

/datum/event/prison_break/setup()
	areaType = list(
		/area/security/sierra/hallway/port,
		/area/security/sierra/brig,
		/area/security/sierra/prison
	)

/datum/event_container/major/sierra
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Psionic Signal", /datum/event/minispasm, 0, list(ASSIGNMENT_MEDICAL = 10), 1),
	)

/datum/map/sierra/setup_events()
	map_event_container = list(
		num2text(EVENT_LEVEL_MAJOR)	= new/datum/event_container/major/sierra,
	)

#undef ASSIGNMENT_MEDICAL