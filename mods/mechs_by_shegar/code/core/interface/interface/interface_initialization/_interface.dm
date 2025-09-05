/mob/living/exosuit
	var/obj/screen/movable/exosuit/advanced_heat/advanced_heat_indicator
	var/obj/screen/exosuit/full_integrity/mech_hp
	//Датум хранящий в себе информацию для работы меню
	var/datum/exosuit_holder/exosuit_data


/mob/living/exosuit/InitializeHud()
	on_update_icon()
	zone_sel = new
	if(!LAZYLEN(hud_elements))
		Initialize_hardpoints() //Размещение интерфейса модулей
		Initialize_big_menu() //Размещение .большого меню
		Initialize_downside_menu() //Размещение основных кнопок снизу
		Initialize_menu_parts() //Размещение частей меха в большом меню
		hud_guide = new /obj/screen/movable/exosuit/guide(src)
		hud_guide.screen_loc =  "EAST-1:28,CENTER-2.1"
		hud_elements |= hud_guide
		hud_health = new /obj/screen/movable/exosuit/mech_integrity(src)
		hud_health.screen_loc = "EAST-1:28,CENTER-3:6"
		hud_elements |= hud_health
		hud_power = new /obj/screen/movable/exosuit/power(src)
		hud_power.screen_loc = "EAST-1:24,CENTER-4:25"
		hud_elements |= hud_power
		advanced_heat_indicator = new /obj/screen/movable/exosuit/advanced_heat(src)
		advanced_heat_indicator.screen_loc = "EAST-1.1,SOUTH+4.18"
		hud_elements |= advanced_heat_indicator

	refresh_hud()
	refresh_menu_hud()
