//Собственно, ланд марка размещается на карте и реагирует на вхождение в опр.радиус
//После чего и стартует кат сцена
/obj/landmark/cutscene_landmark
	var/my_cut_scene_type
	var/datum/cut_scene/my_cut_scene
	var/activated = FALSE

/obj/landmark/cutscene_landmark/Crossed(O)
	if(isobserver(O) || isghost(O))
		return
	if(activated || !my_cut_scene_type)
		return
	activated = TRUE
	my_cut_scene = new my_cut_scene_type(src)
	my_cut_scene.my_landmark = src
	my_cut_scene.start_cutscene(get_turf(src))


/obj/random_titan_landmark
	var/list/possible_landmarks = list(

	)

/obj/random_titan_landmark/New(loc, ...)
	.=..()
	var/result_spawn_type = pickweight(possible_landmarks)
	var/turf/my_turf = get_turf(src)
	new result_spawn_type(my_turf)
