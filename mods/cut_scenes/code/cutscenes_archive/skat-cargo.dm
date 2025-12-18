/obj/random_titan_landmark/cargo
	possible_landmarks = list(
		/obj/landmark/cutscene_landmark/skat_cargo = 3,
		/obj/landmark/cutscene_landmark/skat_cargo_get_ready = 2
	)

///Людишки поднялись с 3 палубы
/obj/landmark/cutscene_landmark/skat_cargo
	my_cut_scene_type = /datum/cut_scene/skat_cargo


/datum/cut_scene/skat_cargo/New()
	actors = list(
		"Captain" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 0, "y_offset" = -1),
		"Left Soldier" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = -2, "y_offset" = 2),
		"Right Soldier" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 2, "y_offset" = 1),
		"Mech Pilot" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 0, "y_offset" = 3)
	)
	// Добавляем действия
	actions_list = list(
		new /datum/cutscene_action/sleeping(3 SECONDS),
		new /datum/cutscene_action/say("Captain", "Каковы результаты?"),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Left Soldier", "Паршивые, сэр"),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Right Soldier", "Третья техническая палуба захвачена противником."),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Captain", "Противником?"),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Mech Pilot", "Агрессивные крабы переростки, сэр"),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Captain", "А где твоё вооружение?"),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Mech Pilot", "Миниган потерян при обвале металических конструкций на потолке. Обломило, сэр."),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Left Soldier", "Мы не смогли обнаружить утерянного инженера."),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Right Soldier", "Как и второго боевого меха оставленного там до аварии."),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Captain", "Понятно. Мы уже день не слышим стука по трубам с третьей палубы, похоже мы опоздали."),
		new /datum/cutscene_action/sleeping(2 SECONDS),
		new /datum/cutscene_action/say("Captain", "Готовьтесь к последнему рывку."),
		new /datum/cutscene_action/sleeping(1 SECONDS),
		new /datum/cutscene_action/say("Left Soldier", "Да, сэр."),
		new /datum/cutscene_action/say("Right Soldier", "Есть, сэр."),
		new /datum/cutscene_action/say("Mech Pilot", "Хорошо, сэр"),
	)
	delete_everyone_after_playing = TRUE


///Людишки готовятся спускаться на 3 палубу
/obj/landmark/cutscene_landmark/skat_cargo_get_ready
	my_cut_scene_type = /datum/cut_scene/skat_cargo_get_ready

/datum/cut_scene/skat_cargo_get_ready/New()
	actors = list(
		"Captain" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = -1, "y_offset" = -3),
		"Left Soldier" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 1, "y_offset" = -3),
		"Right Soldier" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 0, "y_offset" = -1),
		"Mech Pilot" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 0, "y_offset" = -2)
	)
	actions_list = list(
		new /datum/cutscene_action/sleeping(0.5 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/move("Left Soldier", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/move("Left Soldier", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", NORTH),
		new /datum/cutscene_action/move("Left Soldier", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Captain", WEST),
		new /datum/cutscene_action/move("Left Soldier", EAST),
		new /datum/cutscene_action/move("Right Soldier", WEST),
		new /datum/cutscene_action/move("Mech Pilot", EAST),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Left Soldier", NORTH),
		new /datum/cutscene_action/move("Right Soldier", NORTH),
		new /datum/cutscene_action/move("Mech Pilot", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Left Soldier", NORTH),
		new /datum/cutscene_action/move("Right Soldier", NORTH),
		new /datum/cutscene_action/move("Mech Pilot", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Left Soldier", NORTH),
		new /datum/cutscene_action/move("Right Soldier", NORTH),
		new /datum/cutscene_action/move("Mech Pilot", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Right Soldier", NORTH),
		new /datum/cutscene_action/move("Mech Pilot", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Right Soldier", NORTH),
		new /datum/cutscene_action/move("Mech Pilot", NORTH),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/move("Mech Pilot", WEST),
		new /datum/cutscene_action/sleeping(0.25 SECONDS),
		new /datum/cutscene_action/say("Captain", "Ну, с богом."),
		new /datum/cutscene_action/sleeping(0.4 SECONDS),
		new /datum/cutscene_action/say("Left Soldier", "С богом."),
		new /datum/cutscene_action/say("Right Soldier", "С богом."),
		new /datum/cutscene_action/say("Mech Pilot", "С богом.")

	)
	delete_everyone_after_playing = TRUE
