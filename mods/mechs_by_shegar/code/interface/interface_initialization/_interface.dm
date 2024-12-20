/mob/living/exosuit
	var/obj/screen/movable/exosuit/advanced_heat/advanced_heat_indicator
	var/obj/screen/exosuit/hardpoints_menu/hardpoints_menu
	var/obj/screen/exosuit/full_integrity/mech_hp

/mob/living/exosuit/InitializeHud()
	on_update_icon()
	zone_sel = new
	if(!LAZYLEN(hud_elements))
		Initialize_hardpoints() //Размещение интерфейса модулей
		Initialize_big_menu_background() //Размещение меню и задника
		Initialize_big_menu_buttons() //Размещение больших кнопачек в меню
		Initialize_menu_parts() //Размещение частей меха в большом меню
		mech_hp = new /obj/screen/exosuit/full_integrity(src)
		mech_hp.screen_loc = "CENTER-0.1, CENTER+1.5"
		menu_hud_elements |= mech_hp
		hud_health = new /obj/screen/movable/exosuit/mech_integrity(src)
		hud_health.screen_loc = "EAST-1:28,CENTER-3:11"
		hud_elements |= hud_health
		hud_power = new /obj/screen/movable/exosuit/power(src)
		hud_power.screen_loc = "EAST-1:24,CENTER-4:25"
		hud_elements |= hud_power
		advanced_heat_indicator = new /obj/screen/movable/exosuit/advanced_heat(src)
		advanced_heat_indicator.screen_loc = "EAST-1.1,SOUTH+4.35"
		hud_elements |= advanced_heat_indicator

	refresh_hud()
	refresh_menu_hud()
