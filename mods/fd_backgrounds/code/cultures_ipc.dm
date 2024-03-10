#define IPC_CULTURES_TO_DELETE					list(CULTURE_POSITRONICS_GEN1, \
													CULTURE_POSITRONICS_GEN2, \
													CULTURE_POSITRONICS_GEN3)
#define IPC_CULTURES_TO_ADD						list(CULTURE_HUMAN_MARTIAN, \
													CULTURE_HUMAN_MARSTUN, \
													CULTURE_HUMAN_LUNAPOOR, \
													CULTURE_HUMAN_LUNARICH, \
													CULTURE_HUMAN_VENUSIAN, \
													CULTURE_HUMAN_VENUSLOW, \
													CULTURE_HUMAN_BELTER, \
													CULTURE_HUMAN_PLUTO, \
													CULTURE_HUMAN_EARTH, \
													CULTURE_HUMAN_CETIN, \
													CULTURE_HUMAN_CETIS, \
													CULTURE_HUMAN_CETII, \
													CULTURE_HUMAN_SPACER, \
													CULTURE_HUMAN_OFFWORLD, \
													CULTURE_HUMAN_FOSTER, \
													CULTURE_HUMAN_PIRXL, \
													CULTURE_HUMAN_PIRXB, \
													CULTURE_HUMAN_PIRXF, \
													CULTURE_HUMAN_TADMOR, \
													CULTURE_HUMAN_IOLAUS, \
													CULTURE_HUMAN_BRAHE, \
													CULTURE_HUMAN_EOS, \
													CULTURE_HUMAN_GAIAN, \
													CULTURE_HUMAN_OTHER)

/datum/map/New()
	available_cultural_info[TAG_CULTURE] += IPC_CULTURES_TO_ADD
	. = ..()

/datum/species/machine/New()
	available_cultural_info[TAG_CULTURE] += IPC_CULTURES_TO_ADD
	..()
	available_cultural_info[TAG_CULTURE] -= IPC_CULTURES_TO_DELETE

#undef IPC_CULTURES_TO_DELETE
#undef IPC_CULTURES_TO_ADD
