/obj/landmark/cutscene_landmark/example
	my_cut_scene_type = /datum/cut_scene/example

/datum/cut_scene/example/New()
	actors = list(
		"player1" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 0, "y_offset" = 0),
		"player2" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 2, "y_offset" = 0),
		"player3" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = -1, "y_offset" = 1)
)
	// Добавляем действия
	actions_list = list(
		new /datum/cutscene_action/say("player1", "Съешь ещё этих мягких французских булок, да выпей чаю"),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("player2", "Нет, ты съешь ещё этих мягких французских булок, да выпей чаю"),
		new /datum/cutscene_action/sleeping(2 SECONDS)
	)
	delete_everyone_after_playing = TRUE
