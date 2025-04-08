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
