// Закоментите весь файл, если вам не нужна эта карта
/datum/map_template/ruin/away_site/skrellscoutship
	prefix = "mods/utility_items/maps/"
	suffixes = list("skrell-sierrabay.dmm")


//А здесь мы заменим спрайты войдов
/obj/item/clothing/head/helmet/space/void/skrell/black
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

/obj/item/clothing/head/helmet/space/void/skrell/white
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

/obj/item/clothing/suit/space/void/skrell/black
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

/obj/item/clothing/suit/space/void/skrell/white
	icon = 'mods/utility_items/icons/skrell_suit.dmi'
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)
	sprite_sheets_obj = list(
		SPECIES_UNATHI = 'icons/obj/clothing/species/unathi/obj_suit_unathi.dmi',
		SPECIES_SKRELL = 'mods/utility_items/icons/skrell_suit_on_mob.dmi',
		)

// Very vegan freezer
/obj/structure/closet/crate/freezer/skrell
	name = "SDF rations"
	desc = "A crate of skrellian rations."

/obj/structure/closet/crate/freezer/skrell/WillContain()
	return list(
		/obj/item/reagent_containers/food/snacks/skrellsnacks = 16,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit = 8,
		/obj/item/reagent_containers/food/snacks/tossedsalad = 8
	)

// The Frog
/mob/living/simple_animal/friendly/frog/skrells_frog
	name = "Kro-krri"
	desc = "An unusual creature that looks like a frog, it looks sad."

// Munitions
/obj/machinery/computer/modular/preset/munitions/skrell
	default_software = list(
		/datum/computer_file/program/munitions/skrell
	)

/datum/computer_file/program/munitions/skrell
	filename = "munitionscontrol"
	filedesc = "SDF Munitions Control Program"
	nanomodule_path = /datum/nano_module/program/munitions/skrell
	program_icon_state = "munitions"
	program_key_state = "security_key"
	program_menu_icon = "bullet"
	extended_desc = "SDF Program for controlling munitions loading and arming systems."
	requires_ntnet = FALSE
	size = 8
	category = PROG_COMMAND
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	available_on_ntnet = FALSE
	available_on_syndinet = FALSE
	required_access = access_skrellscoutship

/datum/nano_module/program/munitions/skrell
	name = "SDF Munitions Control Program"
	access_req = list(access_skrellscoutship)
/obj/item/paper/skrell/ssvsdocking
	name = "SSV-S Semi-Auto Docking Procedure"
	language = "Skrellian"
	info = {"
	<tt><font face='Verdana' color='black'><center><b><span style='font-size:18px'>Использование полуавтоматического режима стыковки</span></b></center><ul><li>Активировать режим Override на контроллере дока;</li><li>Принудительно открыть внутренний и внешний шлюзы дока;</li><li>Деактивировать режим Override на контроллере дока;</li><li>Повторить процедуру с контроллерами шаттла.</li></ul>После выполнения действий все контроллеры перейдут в статус <b>DOCKED</b>.<br>Последующая отстыковка будет выполнена автоматически.</font></tt>
	"}
