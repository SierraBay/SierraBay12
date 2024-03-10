#define HOME_SYSTEM_ERIDANI 				"Themis"

#define IPC_HOMES_TO_DELETE					list(HOME_SYSTEM_ROOT)
#define IPC_HOMES_TO_ADD					list(HOME_SYSTEM_ERIDANI)

/datum/species/machine/New()
	available_cultural_info[TAG_HOMEWORLD] += IPC_HOMES_TO_ADD
	..()
	available_cultural_info[TAG_HOMEWORLD] -= IPC_HOMES_TO_DELETE

/datum/map/New()
	available_cultural_info[TAG_HOMEWORLD] += IPC_HOMES_TO_ADD
	. = ..()

/singleton/cultural_info/location/eridani
	name = HOME_SYSTEM_ERIDANI
	description = "Themis, the claimed homeworld of the Positronic Union, is a verdant world slowly falling \
	to mass mechanization. Although there are populations of positronics living directly on the surface, \
	most operate from orbital stations. IPCs living on Themis tend to be more callous than those in organic territories, \
	with a strong drive for freedom."
	ruling_body = "The EYE, Senate of Four"
	distance = "19 light years"

#undef HOME_SYSTEM_ERIDANI

#undef IPC_HOMES_TO_DELETE
#undef IPC_HOMES_TO_ADD
