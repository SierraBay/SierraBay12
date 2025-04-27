/mob/observer/alive_planet
	var/datum/alive_planet_hud_data/hud_data
	var/datum/storyteller_ability/selected_ability

/datum/alive_planet_hud_data
	var/list/hud_list = list()
	var/list/screen_objects_types = list(
		/obj/screen/alive_planet_downside,
		/obj/screen/alive_planet_evoluiton_points,
		/obj/screen/alive_planet_scam_points,
		/obj/screen/alive_planet_anomaly_points,
		/obj/screen/alive_planet_mob_points
	)

/mob/observer/alive_planet/proc/setup_hud()
	hud_data = new /datum/alive_planet_hud_data(src)
	for(var/type in hud_data.screen_objects_types)
		var/obj/screen/spawned_screen_obj = new type(src)
		LAZYADD(hud_data.hud_list, spawned_screen_obj)

/mob/observer/alive_planet/proc/setup_hud_on_screen()
	src.client.screen |= hud_data.hud_list

/mob/observer/alive_planet/proc/desetup_hud_on_screen()
	src.client.screen -= hud_data.hud_list

/obj/screen/alive_planet_downside
	icon = 'mods/anomaly/icons/alive_planet_fullscreen.dmi'
	icon_state = "alive_downside"
	screen_loc = "CENTER-3.5, CENTER-7"

/obj/screen/alive_planet_evoluiton_points
	icon = 'mods/anomaly/icons/alive_planet_fullscreen.dmi'
	icon_state = "stats_evolution_points"
	screen_loc = "CENTER-8, CENTER-6.25"
	maptext = "300"
	maptext_height = 64
	maptext_width = 128
	maptext_x = 12
	maptext_y = 38

/obj/screen/alive_planet_scam_points
	icon = 'mods/anomaly/icons/alive_planet_fullscreen.dmi'
	icon_state = "scam_points"
	screen_loc = "CENTER-8, CENTER-6.5"
	maptext_height = 64
	maptext_width = 128
	maptext_x = 12
	maptext_y = 38
	maptext = "ТЕКУЩЕЕ КОЛИЧЕСТВО ОЧКОВ ОБМАНА"

/obj/screen/alive_planet_anomaly_points
	icon = 'mods/anomaly/icons/alive_planet_fullscreen.dmi'
	icon_state = "anomaly_points"
	screen_loc = "CENTER-8, CENTER-6.75"
	maptext_height = 64
	maptext_width = 128
	maptext_x = 12
	maptext_y = 38
	maptext = "ТЕКУЩЕЕ КОЛИЧЕСТВО ОЧКОВ АНОМАЛИЙ"

/obj/screen/alive_planet_mob_points
	icon = 'mods/anomaly/icons/alive_planet_fullscreen.dmi'
	icon_state = "mob_points"
	screen_loc = "CENTER-8, CENTER-7"
	maptext_height = 64
	maptext_width = 128
	maptext_x = 12
	maptext_y = 38
	maptext = "ТЕКУЩЕЕ КОЛИЧЕСТВО ОЧКОВ МОБОВ"
