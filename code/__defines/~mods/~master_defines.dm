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

// RESOMI - Start
#define LANGUAGE_RESOMI			"Schechi"
#define SPECIES_RESOMI			"Resomi"
// RESOMI - End

// UTF8 - Start
#undef show_browser
#define show_browser(target, content, title)  to_target(target, browse(utf_8_html(content), title))
// UTF8 - End
