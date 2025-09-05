/obj/landmark/cutscene_landmark/skat_conference
	my_cut_scene_type = /datum/cut_scene/skat_conference

/datum/cut_scene/skat_conference/New()
	actors = list(
		"Captain" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 2, "y_offset" = 0),
		"Adjutant" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 1, "y_offset" = -1),
		//Первая линия людей
		"FirstSoldier" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 5, "y_offset" = 2),
		"1cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 5, "y_offset" = 1),
		"2cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 5, "y_offset" = 0),
		"3cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 5, "y_offset" = -1),
		"SecondSoldier" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 5, "y_offset" = -2),
		//Вторая линия людей
		"5cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 6, "y_offset" = 2),
		"6cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 6, "y_offset" = 1),
		"7cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 6, "y_offset" = 0),
		"8cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 6, "y_offset" = -1),
		"9cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 6, "y_offset" = -2),
		//Третий слой людей
		"11cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 7, "y_offset" = 2),
		"12cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 7, "y_offset" = 1),
		"13cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 8, "y_offset" = -1),
		"14cargoboy" = list("type" = /obj/sctructure/titan_ghost/human_ghost, "x_offset" = 7, "y_offset" = -2)
)
	// Добавляем действия
	actions_list = list(
		//Сперва будет галдёж
		new /datum/cutscene_action/say("1cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("3cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("5cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("7cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("8cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("13cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("14cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("2cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("4cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("11cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("10cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("1cargoboy", "*Неразборчивый галдёж*"),
		new /datum/cutscene_action/say("Captain", "ОТСТАВИТЬ ГАЛДЁЖ!!!!."),
		new /datum/cutscene_action/sleeping(6 SECONDS),
		new /datum/cutscene_action/say("5cargoboy", "*Кашель*"),
		new /datum/cutscene_action/sleeping(6 SECONDS),
		new /datum/cutscene_action/say("Captain", "Мне прекрасно понятна ваша тревога, ваше возмущение, и что самое главное..."),
		new /datum/cutscene_action/sleeping(0.5 SECONDS),
		new /datum/cutscene_action/say("Captain", "...ваш страх!"),
		new /datum/cutscene_action/sleeping(4 SECONDS),
		new /datum/cutscene_action/say("Captain", "Но это не значит что нужно скатываться в тень от самих себя, да, связи нет, да, двигатели залиты водой"),
		new /datum/cutscene_action/sleeping(4 SECONDS),
		new /datum/cutscene_action/say("Captain", "Да, нижняя палуба полностью под водой из-за пробоины, да, волны повреждают обшивку судна"),
		new /datum/cutscene_action/sleeping(4 SECONDS),
		new /datum/cutscene_action/say("Captain", "Но это не значит что мы сдадимся так просто в пучину страха и беспомощности!"),
		new /datum/cutscene_action/sleeping(4 SECONDS),
		new /datum/cutscene_action/say("Captain", "Мы люди, а я ваш капитан, и уверяю вас, у нас ещё есть шансы!"),
		new /datum/cutscene_action/sleeping(4 SECONDS),
		new /datum/cutscene_action/say("Captain", "Гарантий в нашей ситуации нет"),
		new /datum/cutscene_action/sleeping(4 SECONDS),
		new /datum/cutscene_action/say("Captain", "Но попробовать мы обязаны.")
	)
	delete_everyone_after_playing = TRUE
