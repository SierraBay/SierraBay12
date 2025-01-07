/datum/map/dev
	name = "\improper dev"
	full_name = "\improper dev map"
	config_path = "config/sierra_config.txt"
	flags = MAP_HAS_BRANCH | MAP_HAS_RANK
	welcome_sound = ANNOUNCER_WELCOME
	use_bluespace_interlude = TRUE
	load_legacy_saves = TRUE
	station_levels = list(1,2)
	accessible_z_levels = list("1"=1,"2"=1)
	overmap_size = 40
	overmap_event_areas = 34
	allowed_spawns = list("Cryogenic Storage", "Cyborg Storage")
	default_spawn = "Cryogenic Storage"

	station_name  = "Режим разработки"
	station_short = "DEV"
	company_name  = "Контрибьюторы"
	company_short = "KT"


	evac_controller_type = /datum/evacuation_controller/starship/fast //[SIERRA-EDIT] evac_controller_type = /datum/evacuation_controller/starship/

	default_law_type = /datum/ai_laws/nanotrasen
	use_overmap = 0
	num_exoplanets = 0
	planet_size = list(129,129)

	away_site_budget = -5 //поставил отрицательное значение чтоб авейки даже с ценой 0 не спавнились

	id_hud_icons = 'maps/sierra/icons/assignment_hud.dmi'

	available_cultural_info = list(
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
			HOME_SYSTEM_GAIA,
			HOME_SYSTEM_MAGNITKA,
			HOME_SYSTEM_OTHER
		),
		TAG_FACTION = list(
			FACTION_SOL_CENTRAL,
			FACTION_INDIE_CONFED,
			FACTION_NANOTRASEN,
			FACTION_HEPHAESTUS,
			FACTION_DAIS,
			FACTION_PCRC,
			FACTION_SAARE,
			FACTION_XYNERGY,
			FACTION_FREETRADE,
			FACTION_OTHER
		),
		TAG_CULTURE = list(
			CULTURE_HUMAN_MARTIAN,
			CULTURE_HUMAN_MARSTUN,
			CULTURE_HUMAN_LUNAPOOR,
			CULTURE_HUMAN_LUNARICH,
			CULTURE_HUMAN_VENUSIAN,
			CULTURE_HUMAN_VENUSLOW,
			CULTURE_HUMAN_BELTER,
			CULTURE_HUMAN_PLUTO,
			CULTURE_HUMAN_EARTH,
			CULTURE_HUMAN_CETIN,
			CULTURE_HUMAN_CETIS,
			CULTURE_HUMAN_CETII,
			CULTURE_HUMAN_FOSTER,
			CULTURE_HUMAN_PIRXL,
			CULTURE_HUMAN_PIRXB,
			CULTURE_HUMAN_PIRXF,
			CULTURE_HUMAN_TADMOR,
			CULTURE_HUMAN_IOLAUS,
			CULTURE_HUMAN_BRAHE,
			CULTURE_HUMAN_EOS,
			CULTURE_HUMAN_SPACER,
			CULTURE_HUMAN_OFFWORLD,
			CULTURE_HUMAN_SOLCOL,
			CULTURE_HUMAN_CONFEDC,
			CULTURE_HUMAN_CONFEDO,
			CULTURE_HUMAN_OTHER
		),
		TAG_RELIGION = list(
			RELIGION_OTHER,
			RELIGION_JUDAISM,
			RELIGION_HINDUISM,
			RELIGION_BUDDHISM,
			RELIGION_SIKHISM,
			RELIGION_JAINISM,
			RELIGION_ISLAM,
			RELIGION_CHRISTIANITY,
			RELIGION_BAHAI_FAITH,
			RELIGION_AGNOSTICISM,
			RELIGION_DEISM,
			RELIGION_ATHEISM,
			RELIGION_THELEMA,
			RELIGION_SPIRITUALISM,
			RELIGION_SHINTO,
			RELIGION_TAOISM
		)
	)
