var/global/list/teleport_landmarks_list = list()

/obj/landmark/teleport_to_z_level
	invisibility = 60
	name = "Телепорт"
	desc = "А я вижу ты любознательный, да?"
	var/teleport_tag = "TEST"
	var/map_path
	var/is_exit = FALSE
	var/spawn_started = FALSE
	//Применяется чтоб двигать персонажиков нормально по меткам и не устраивать вечный закид туда сюда
	var/temp_offed = FALSE
	var/datum/map_template/spawned_template
	var/obj/landmark/teleport_to_z_level/connected_landmark

/obj/landmark/teleport_to_z_level/New()
	. = ..()
	LAZYADD(teleport_landmarks_list, src)
	deploy_map()


/obj/landmark/teleport_to_z_level/proc/deploy_map()
	set waitfor = FALSE
	if(map_path && !spawn_started && !is_exit)
		spawn_started = TRUE
		spawned_template = new map_path()
		var/turf/spawned_turf = spawned_template.load_new_z()
		var/area/map_area = get_area(spawned_turf)
		update_landmarks_connection(map_area)

/obj/landmark/teleport_to_z_level/proc/update_landmarks_connection(area/map_area)
	for(var/obj/landmark/teleport_to_z_level/landmark in landmarks_list)
		if(map_area == get_area(landmark))
			if(landmark.is_exit)
				if(teleport_tag == landmark.teleport_tag)
					connect_teleports_landmarks(landmark)

/obj/landmark/teleport_to_z_level/proc/connect_teleports_landmarks(obj/landmark/teleport_to_z_level/input_mark)
	connected_landmark = input_mark
	input_mark.connected_landmark = src

/obj/landmark/teleport_to_z_level/skat

	name = "Спуск на второй этаж СКАТ"
	teleport_tag = "SKAT"
	map_path = /datum/map_template/ruin/exoplanet/drowned_skat_second_deck

/obj/landmark/teleport_to_z_level/skat/exit
	name = "Подьём на первый этаж СКАТ"
	teleport_tag = "SKAT"
	map_path = null
	is_exit = TRUE

/obj/landmark/teleport_to_z_level/Crossed(O)
	if(isvirtualmob(O))
		return
	if(temp_offed)
		temp_offed = FALSE
		return
	teleport_to_conntected_z_level(O)

/obj/landmark/teleport_to_z_level/proc/teleport_to_conntected_z_level(atom/movable/victim)
	if(connected_landmark)
		connected_landmark.temp_offed = TRUE
		victim.forceMove(get_turf(connected_landmark))


/obj/landmark/teleport_to_z_level/skat_third_deck
	name = "Спуск на третий этаж СКАТ"
	teleport_tag = "SKAT_DEEP"
	map_path = /datum/map_template/ruin/exoplanet/drowned_skat_third_deck

/obj/landmark/teleport_to_z_level/skat_third_deck/exit
	name = "Подьём на второй этаж СКАТ"
	teleport_tag = "SKAT_DEEP"
	map_path = null
	is_exit = TRUE
