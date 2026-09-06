/singleton/species/human/mule
	name = SPECIES_MULE
	name_plural = "Mules"
	description = "Мулы, это подвид людей, имеющих предрасположенность к псионике, \
	но населяющие социальное дно, ввиду своих видимых мутаций и измененному виду. \
	Часто, не имеющие постоянного трудоустройства или даже, крыши над головой, о них \
	принято судить как о предрасположенным к совершению преступления, а так же, как тех \
	кто может злоупотреблять своим псионическим потенциалом."
	preview_icon = 'icons/mob/human_races/species/human/subspecies/mule_preview.dmi'
	icobase = 'mods/mules/icons/mule_body.dmi'
	deform = 'mods/mules/icons/mule_deformed.dmi'

	spawn_flags =   SPECIES_CAN_JOIN | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_NO_ROBOTIC_INTERNAL_ORGANS
	brute_mod =     1.25
	burn_mod =      1.25
	oxy_mod =       1.25
	toxins_mod =    1.25
	radiation_mod = 1.25
	flash_mod =     1.25
	blood_volume =  SPECIES_BLOOD_DEFAULT * 0.85
	min_age =       18
	max_age =       45

	available_cultural_info = list(
		TAG_CULTURE = list(
			CULTURE_HUMAN_MARTIAN,
			CULTURE_HUMAN_MARSTUN,
			CULTURE_HUMAN_LUNAPOOR,
			CULTURE_HUMAN_LUNARICH,
			CULTURE_HUMAN_VENUSIAN,
			CULTURE_HUMAN_VENUSLOW,
			CULTURE_HUMAN_BELTER,
			CULTURE_HUMAN_PLUTO,
			CULTURE_HUMAN_MAGNITKA,
			CULTURE_HUMAN_EARTH,
			CULTURE_HUMAN_CETIN,
			CULTURE_HUMAN_CETIS,
			CULTURE_HUMAN_CETII,
			CULTURE_HUMAN_SPACER,
			CULTURE_HUMAN_OFFWORLD,
			CULTURE_HUMAN_CONFEDO,
			CULTURE_HUMAN_FOSTER,
			CULTURE_HUMAN_PIRXL,
			CULTURE_HUMAN_PIRXB,
			CULTURE_HUMAN_PIRXF,
			CULTURE_HUMAN_TADMOR,
			CULTURE_HUMAN_IOLAUS,
			CULTURE_HUMAN_BRAHE,
			CULTURE_HUMAN_EOS,
			CULTURE_HUMAN_GAIAN,
			CULTURE_HUMAN_OTHER
		),
		TAG_FACTION = list(
			FACTION_LUMPEN,
			FACTION_ASSAMBLEE
		)
	)

	default_cultural_info = list(TAG_FACTION = FACTION_LUMPEN)

	extended_cultural_info = list(
		TAG_CULTURE = list(
			CULTURE_HUMAN_AVACOMMON,
			CULTURE_HUMAN_AVANOBLE,
			CULTURE_HUMAN_LORRIMAN,
			CULTURE_HUMAN_LORDUP,
			CULTURE_HUMAN_LORDLOW,
			CULTURE_HUMAN_MIRANIAN,
			CULTURE_HUMAN_NYXIAN
		),
		TAG_HOMEWORLD = list(
			HOME_SYSTEM_EARTH,
			HOME_SYSTEM_LUNA,
			HOME_SYSTEM_MARS,
			HOME_SYSTEM_VENUS,
			HOME_SYSTEM_CERES,
			HOME_SYSTEM_PLUTO,
			HOME_SYSTEM_TAU_CETI,
			HOME_SYSTEM_HELIOS,
			HOME_SYSTEM_TERRA,
			HOME_SYSTEM_SAFFAR,
			HOME_SYSTEM_PIRX,
			HOME_SYSTEM_TADMOR,
			HOME_SYSTEM_BRAHE,
			HOME_SYSTEM_IOLAUS,
			HOME_SYSTEM_GAIA,
			HOME_SYSTEM_MAGNITKA,
			HOME_SYSTEM_CASTILLA,
			HOME_SYSTEM_FOSTER,
			HOME_SYSTEM_QUIG,
			HOME_SYSTEM_TERSTEN,
			HOME_SYSTEM_AVALON,
			HOME_SYSTEM_MIRANIA,
			HOME_SYSTEM_NYX_BRINKBURN,
			HOME_SYSTEM_NYX_KALDARK,
			HOME_SYSTEM_NYX_ROANOK,
			HOME_SYSTEM_NYX_YUKLIT,
			HOME_SYSTEM_NYX_CASSER,
			HOME_SYSTEM_OTHER,
			HOME_SYSTEM_DEEP_SPACE,
			HOME_SYSTEM_LORRIMAN,
			HOME_SYSTEM_CINU,
			HOME_SYSTEM_YUKLID,
			HOME_SYSTEM_LORDANIA,
			HOME_SYSTEM_KINGSTON
		),
		TAG_FACTION = list()
	)
