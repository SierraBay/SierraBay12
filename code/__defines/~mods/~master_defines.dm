/*
	SierraBay12 - Master defines file

	Руководство по добавлению дефайнов:
	- Добавь комментарий с ID модуля и указанием, что это начало
	- Запиши все нужные дефайны
	- Вновь комментарий с ID модуля и указанием, что это конец
*/

// TAJARA - Start
#define SPECIES_TAJARA			"Tajara"
#define LANGUAGE_SIIK_MAAS		"Siik'maas"
#define LANGUAGE_SIIK_TAJR		"Siik'tajr"
// TAJARA - End

// ASCENT - Start
#define SPECIES_MANTID_ALATE	"Kharmaan Alate"
#define SPECIES_MANTID_GYNE		"Kharmaan Gyne"
#define SPECIES_MONARCH_WORKER	"Monarch Serpentid Worker"
#define SPECIES_MONARCH_QUEEN	"Monarch Serpentid Queen"
// ASCENT - End

// LEGALESE - Start
#define LANGUAGE_LEGALESE		"Legalese"
// LEGALESE - End

// UTF8 - Start
#undef show_browser
#define show_browser(target, content, title)  to_target(target, browse(utf_8_html(content), title))
// UTF8 - End

// DON_LOADOUT - Start
// Не открывать до Рождества

#define DONATION_TIER_NONE   null
#define DONATION_TIER_ONE    "Tier 1"
#define DONATION_TIER_TWO    "Tier 2"
#define DONATION_TIER_THREE  "Tier 3"
#define DONATION_TIER_FOUR   "Tier 4"
#define DONATION_TIER_ADMIN  "Admin"

#define DONATION_TIER_ONE_SUM    100
#define DONATION_TIER_TWO_SUM    300
#define DONATION_TIER_THREE_SUM  500
#define DONATION_TIER_FOUR_SUM   700

// Keep this in ascending order
// (from the lower tier to the higher)
#define DONATION_TIER_ALL_TIERS list(\
	DONATION_TIER_NONE, DONATION_TIER_ONE, \
	DONATION_TIER_TWO, DONATION_TIER_THREE, \
	DONATION_TIER_FOUR, DONATION_TIER_ADMIN)

// DON_LOADOUT - End

// GUNS - Start
#define GUN_BULK_PISTOL       1
#define GUN_BULK_REVOLVER     2
#define GUN_BULK_SMG          3
#define GUN_BULK_CARABINE     4
#define GUN_BULK_SNIPER_RIFLE 6
#define GUN_BULK_MACHINEGUN   7
// GUNS - End

// GLIDING - Start
#define DELAY2GLIDESIZE(delay) (world.icon_size / max(ceil(delay / world.tick_lag), 1))
// GLIDING - End

// LOADOUT_ITEMS - Start
#define ACCESSORY_SLOT_OVER     "Over"
// LOADOUT_ITEMS - End

// IPC_COOLING_UNIT - Start
#define BP_COOLING "cooling system"
#define BP_EXONET "exonet connection slot"
// IPC_COOLING_UNIT - End

// RESOMI - Start
#define SPECIES_RESOMI  "Resomi"
#define LANGUAGE_RESOMI "Schechi"
// RESOMI - End

// ERIS_ANNOUNCER - Start
///Announcer audio keys
#define ANNOUNCER_ALIENS 'mods/eris_announcer/sound/announcements/life_signatures.ogg'
#define ANNOUNCER_METEORS 'mods/eris_announcer/sound/announcements/meteors_1.ogg'
#define ANNOUNCER_OUTBREAK5 'mods/eris_announcer/sound/announcements/biohazard_level_5.ogg'
#define ANNOUNCER_OUTBREAK7 'mods/eris_announcer/sound/announcements/biohazard_level_7.ogg'
#define ANNOUNCER_POWEROFF 'mods/eris_announcer/sound/announcements/electricity_off.ogg'
#define ANNOUNCER_POWERON 'mods/eris_announcer/sound/announcements/electricity_on.ogg'
#define ANNOUNCER_RADIATION 'mods/eris_announcer/sound/announcements/radiation.ogg'
#define ANNOUNCER_SPANOMALIES 'mods/eris_announcer/sound/announcements/anomaly_gravity.ogg'
#define ANNOUNCER_WELCOME 'mods/eris_announcer/sound/announcements/welcome_1.ogg'
#define ANNOUNCER_COMMANDREPORT 'mods/eris_announcer/sound/announcements/command_report.ogg'
#define ANNOUNCER_ABANDONSHIP 'mods/eris_announcer/sound/announcements/evacuation.ogg'
#define ANNOUNCER_ELECTRICALSTORM_MOD 'mods/eris_announcer/sound/announcements/electrical_storm_normal.ogg'
#define ANNOUNCER_ELECTRICALSTORM_MAJ 'mods/eris_announcer/sound/announcements/electrical_storm_high.ogg'
#define ANNOUNCER_BLUESPACEJUMP_INIT 'mods/eris_announcer/sound/announcements/bluespacejump_initialization.ogg'
#define ANNOUNCER_BLUESPACEJUMP_PREP 'mods/eris_announcer/sound/announcements/bluespacejump_prepare.ogg'
#define ANNOUNCER_BLUESPACEJUMP_START 'mods/eris_announcer/sound/announcements/bluespacejump_start.ogg'
// ERIS_ANNOUNCER - End

//PRIMLANGS - Start
#define LANGUAGE_SIMPSKRELLIAN "Simplified Skrellian"
#define LANGUAGE_SIMPUNATHI "Iber'Unathi"
#define LANGUAGE_SIMPTAJARAN "Simplified Siik'Maas"
//PRIMLANGS - End

//ANOMALIES
#define MAX_DEEP 1
#define MIDDLE_DEEP 2
#define MIN_DEEP 3
#define NO_DEEP 4
#define DEEQUIP 5
#define KILL 6
#define WATER_OVERLAY 10
#define istitanwater(A) istype(A, /turf/simulated/floor/exoplanet/titan_water)
//ANOMALIES

//FOV
#define FIELD_OF_VISION_BLOCKER_PLANE -199
#define FIELD_OF_VISION_BLOCKER_RENDER_TARGET "*FIELD_OF_VISION_BLOCKER_RENDER_TARGET"
//FOV

// XENOBIO TRANSFORMATIONS

#define SPECIES_MOTH			"Mothman"

// XENOBIO TRANSFORMATIONS - END

// PSIONICS - Start
#define SPECIES_PSI	"Psionics"

#define PSI_IMPLANT_AUTOMATIC "Security Level Derived"
#define PSI_IMPLANT_SHOCK     "Issue Neural Shock"
#define PSI_IMPLANT_WARN      "Issue Reprimand"
#define PSI_IMPLANT_LOG       "Log Incident"
#define PSI_IMPLANT_DISABLED  "Disabled"

#define PSI_COERCION           "coercion"
#define PSI_CONSCIOUSNESS      "consciousness"
#define PSI_PSYCHOKINESIS      "psychokinesis"
#define PSI_MANIFESTATION      "manifestation"
#define PSI_METAKINESIS        "metakinesis"
#define PSI_ENERGISTICS        "energistics"
#define PSI_REDACTION          "redaction"

#define PSI_RANK_BLUNT         0
#define PSI_RANK_LATENT        1
#define PSI_RANK_APPRENTICE    2
#define PSI_RANK_OPERANT       3
#define PSI_RANK_MASTER        4
#define PSI_RANK_GRANDMASTER   5
// PSIONICS - End

//NTSH
#define MODULAR_CONFIG_REMCON_SETTING "RemoteConnectionPass"
///NTSH

//New aways testing mod, change to 1 in order to turn it on. Always turn it off afterwards.
#define NEW_AWAYS_TESTING 0

#if NEW_AWAYS_TESTING == 1
	#define UNIT_TEST 1
#endif
//New aways testing mod
