#define HUMAN_HOMES_TO_DELETE					list(HOME_SYSTEM_TERSTEN, \
													HOME_SYSTEM_AVALON, \
													HOME_SYSTEM_MIRANIA, \
													HOME_SYSTEM_NYX_BRINKBURN, \
													HOME_SYSTEM_NYX_KALDARK, \
													HOME_SYSTEM_NYX_ROANOK, \
													HOME_SYSTEM_NYX_YUKLIT, \
													HOME_SYSTEM_NYX_CASSER)

/datum/species/human/New()
	..()
	available_cultural_info[TAG_HOMEWORLD] -= HUMAN_HOMES_TO_DELETE

#undef HUMAN_HOMES_TO_DELETE
