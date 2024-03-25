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

// LEGALESE - Start
#define LANGUAGE_LEGALESE		"Legalese"
// LEGALESE - End

// UTF8 - Start
#undef show_browser
#define show_browser(target, content, title)  to_target(target, browse(utf_8_html(content), title))
// UTF8 - End

// DON_LOADOUT - Start
#define DONATION_TIER_NONE 0
#define DONATION_TIER_ONE 1
#define DONATION_TIER_TWO 2
#define DONATION_TIER_THREE 3
#define DONATION_TIER_FOUR 4
#define DONATION_TIER_ADMIN 5

#define DONATION_TIER_ONE_SUM    100
#define DONATION_TIER_TWO_SUM    300
#define DONATION_TIER_THREE_SUM  500
#define DONATION_TIER_FOUR_SUM   1000

// GLIDING - Start
#define DELAY2GLIDESIZE(delay) (world.icon_size / max(ceil(delay / world.tick_lag), 1))
// GLIDING - End

// LOADOUT_ITEMS - Start
#define ACCESSORY_SLOT_OVER     "Over"
// LOADOUT_ITEMS - End

// IPC_MODS - Start
#define BP_COOLING				"cooling system"
#define BP_EXONET				"exonet connection slot"
// IPC_MODS - End

// RESOMI - Start
#define SPECIES_RESOMI  "Resomi"
#define LANGUAGE_RESOMI "Schechi"
// RESOMI - End
