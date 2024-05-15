#define HOME_SYSTEM_ERIDANI 				"Themis"

#define HOME_SYSTEM_EARTH_FD				"Earth"
#define HOME_SYSTEM_LUNA_FD					"Luna"
#define HOME_SYSTEM_MARS_FD					"Mars"
#define HOME_SYSTEM_VENUS_FD				"Venus"
#define HOME_SYSTEM_CERES_FD				"Ceres"
#define HOME_SYSTEM_PLUTO_FD				"Pluto"
#define HOME_SYSTEM_TAU_CETI_FD				"Ceti Epsilon"
#define HOME_SYSTEM_HELIOS_FD				"Eos"
#define HOME_SYSTEM_TERRA_FD				"Terra"
#define HOME_SYSTEM_SAFFAR_FD				"Saffar"
#define HOME_SYSTEM_PIRX_FD					"Pirx"
#define HOME_SYSTEM_TADMOR_FD				"Tadmor"
#define HOME_SYSTEM_BRAHE_FD				"Brahe"
#define HOME_SYSTEM_IOLAUS_FD				"Iolaus"
#define HOME_SYSTEM_GAIA_FD					"Gaia"
#define HOME_SYSTEM_MAGNITKA_FD				"Magnitka"
#define HOME_SYSTEM_CASTILLA_FD				"Nueva Castilla"
#define HOME_SYSTEM_FOSTER_FD				"Foster's World"

#define IPC_HOMES_TO_DELETE					list(HOME_SYSTEM_ROOT, \
												HOME_SYSTEM_EARTH, \
												HOME_SYSTEM_LUNA, \
												HOME_SYSTEM_MARS, \
												HOME_SYSTEM_VENUS, \
												HOME_SYSTEM_CERES, \
												HOME_SYSTEM_PLUTO, \
												HOME_SYSTEM_TAU_CETI, \
												HOME_SYSTEM_HELIOS, \
												HOME_SYSTEM_TERRA, \
												HOME_SYSTEM_SAFFAR, \
												HOME_SYSTEM_PIRX, \
												HOME_SYSTEM_TADMOR, \
												HOME_SYSTEM_BRAHE, \
												HOME_SYSTEM_IOLAUS, \
												HOME_SYSTEM_GAIA, \
												HOME_SYSTEM_MAGNITKA, \
												HOME_SYSTEM_CASTILLA, \
												HOME_SYSTEM_FOSTER)
#define IPC_HOMES_TO_ADD					list(HOME_SYSTEM_ERIDANI, \
												HOME_SYSTEM_EARTH_FD, \
												HOME_SYSTEM_LUNA_FD, \
												HOME_SYSTEM_MARS_FD, \
												HOME_SYSTEM_VENUS_FD, \
												HOME_SYSTEM_CERES_FD, \
												HOME_SYSTEM_PLUTO_FD, \
												HOME_SYSTEM_TAU_CETI_FD, \
												HOME_SYSTEM_HELIOS_FD, \
												HOME_SYSTEM_TERRA_FD, \
												HOME_SYSTEM_SAFFAR_FD, \
												HOME_SYSTEM_PIRX_FD, \
												HOME_SYSTEM_TADMOR_FD, \
												HOME_SYSTEM_BRAHE_FD, \
												HOME_SYSTEM_IOLAUS_FD, \
												HOME_SYSTEM_GAIA_FD, \
												HOME_SYSTEM_MAGNITKA_FD, \
												HOME_SYSTEM_CASTILLA_FD, \
												HOME_SYSTEM_FOSTER_FD)

/datum/species/machine/New()
	available_cultural_info[TAG_HOMEWORLD] += IPC_HOMES_TO_ADD
	..()
	available_cultural_info[TAG_HOMEWORLD] -= IPC_HOMES_TO_DELETE

/singleton/cultural_info/location/eridani
	name = HOME_SYSTEM_ERIDANI
	nickname = "Фемида"
	description = "Themis, the claimed homeworld of the Positronic Union, is a verdant world slowly falling \
	to mass mechanization. Although there are populations of positronics living directly on the surface, \
	most operate from orbital stations. IPCs living on Themis tend to be more callous than those in organic territories, \
	with a strong drive for freedom."
	ruling_body = "The EYE, Senate of Four"
	distance = "19 light years"

#undef HOME_SYSTEM_ERIDANI

#undef HOME_SYSTEM_EARTH_FD
#undef HOME_SYSTEM_LUNA_FD
#undef HOME_SYSTEM_MARS_FD
#undef HOME_SYSTEM_VENUS_FD
#undef HOME_SYSTEM_CERES_FD
#undef HOME_SYSTEM_PLUTO_FD
#undef HOME_SYSTEM_TAU_CETI_FD
#undef HOME_SYSTEM_HELIOS_FD
#undef HOME_SYSTEM_TERRA_FD
#undef HOME_SYSTEM_SAFFAR_FD
#undef HOME_SYSTEM_PIRX_FD
#undef HOME_SYSTEM_TADMOR_FD
#undef HOME_SYSTEM_BRAHE_FD
#undef HOME_SYSTEM_IOLAUS_FD
#undef HOME_SYSTEM_GAIA_FD
#undef HOME_SYSTEM_MAGNITKA_FD
#undef HOME_SYSTEM_CASTILLA_FD
#undef HOME_SYSTEM_FOSTER_FD

#undef IPC_HOMES_TO_DELETE
#undef IPC_HOMES_TO_ADD
