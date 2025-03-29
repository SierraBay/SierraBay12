/obj/landmark/cutscene_landmark/skat_most_first
	my_cut_scene_type = /datum/cut_scene/skat_most_first


/datum/cut_scene/skat_most_first/New()
	actors = list(
		"Captain" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 2, "y_offset" = -2),
		"Adjutant" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = -1, "y_offset" = 2)
)
	// Добавляем действия
	actions_list = list(
		new /datum/cutscene_action/say("Adjutant", "Капитан!!! "),
		new /datum/cutscene_action/sleeping(1 SECONDS),
		new /datum/cutscene_action/say("Captain", "Ну?В чём дело."),
		new /datum/cutscene_action/sleeping(1 SECONDS),
		new /datum/cutscene_action/say("Adjutant", "Капитан, там, горы! "),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/say("Captain", "Чего?!"),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", EAST),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Adjutant", EAST),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", WEST),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", WEST),
		new /datum/cutscene_action/set_dir("Captain", NORTH),
		new /datum/cutscene_action/set_dir("Adjutant", NORTH),
		new /datum/cutscene_action/sleeping(3 SECONDS),
		new /datum/cutscene_action/say("Captain", "Ебать его рот...это не горы...это..."),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Captain", "ЭТО БЛЯТЬ ВОДА! НАЧАТЬ ВЗЛЁТ!"),
		new /datum/cutscene_action/sleeping(2 SECONDS)
	)
	delete_everyone_after_playing = TRUE
