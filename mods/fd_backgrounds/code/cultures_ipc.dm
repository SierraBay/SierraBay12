#define CULTURE_HUMAN_KIPERIUSMINER				"Kiperius, Miner Colony"
#define CULTURE_HUMAN_KIPERIUSPRISONER			"Kiperius, Prison"
#define CULTURE_HUMAN_MEOT						"Meonian"
#define CULTURE_HUMAN_REPUBL					"Republican"
#define CULTURE_HUMAN_MARTIAN_FD				"Martian, Surfacer"
#define CULTURE_HUMAN_MARSTUN_FD				"Martian, Tunneller"
#define CULTURE_HUMAN_LUNAPOOR_FD				"Luna, Lower Class"
#define CULTURE_HUMAN_LUNARICH_FD				"Luna, Upper Class"
#define CULTURE_HUMAN_VENUSIAN_FD				"Venusian, Zoner"
#define CULTURE_HUMAN_VENUSLOW_FD				"Venusian, Surfacer"

#define IPC_CULTURES_TO_DELETE					list(CULTURE_POSITRONICS_GEN1, \
													CULTURE_POSITRONICS_GEN2, \
													CULTURE_POSITRONICS_GEN3)
#define IPC_CULTURES_TO_ADD						list(CULTURE_HUMAN_MARTIAN_FD, \
													CULTURE_HUMAN_MARSTUN_FD, \
													CULTURE_HUMAN_LUNAPOOR_FD, \
													CULTURE_HUMAN_LUNARICH_FD, \
													CULTURE_HUMAN_KIPERIUSMINER, \
													CULTURE_HUMAN_KIPERIUSPRISONER, \
													CULTURE_HUMAN_MEOT, \
													CULTURE_HUMAN_REPUBL, \
													CULTURE_HUMAN_VENUSIAN_FD, \
													CULTURE_HUMAN_VENUSLOW_FD, \
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

#undef CULTURE_HUMAN_KIPERIUSMINER
#undef CULTURE_HUMAN_KIPERIUSPRISONER
#undef CULTURE_HUMAN_MEOT
#undef CULTURE_HUMAN_REPUBL
#undef CULTURE_HUMAN_MARTIAN_FD
#undef CULTURE_HUMAN_MARSTUN_FD
#undef CULTURE_HUMAN_LUNAPOOR_FD
#undef CULTURE_HUMAN_LUNARICH_FD
#undef CULTURE_HUMAN_VENUSIAN_FD
#undef CULTURE_HUMAN_VENUSLOW_FD

#undef IPC_CULTURES_TO_DELETE
#undef IPC_CULTURES_TO_ADD
