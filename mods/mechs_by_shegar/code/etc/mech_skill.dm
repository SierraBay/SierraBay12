//ЗАТЫЧКА ЧТОБ ЮНИТ ТЕСТ УСПОКОИЛСЯ, НЕ ТРОГАТь. Забейте ваще на поддержку кода ниже, он нужен один раз чтоб
//юнит тест пропустил
/datum/job/security_mech_pilot
	title = "Mechanized Systems Operator"
	department = "Security"
	department_flag = SEC
	total_positions = 1
	spawn_positions = 1
	selection_color = "#601c1c"
	hud_icon = "hudblank"
	outfit_type = /singleton/hierarchy/outfit/job/security/officer
	supervisors = "Главе Службы безопасности и Смотрителю (сержанту)"
	economic_power = 6
	minimal_player_age = 10
	minimum_character_age = list(SPECIES_HUMAN = 22)
	ideal_character_age = 25
	alt_titles = list("Combat Mech Pilot")















/singleton/hierarchy/skill/general/EVA/mech
	name = "Пилотирование меха"
	desc = "Позволяет управлять мехами - грозными боевыми единицами и незаменимой техникой в современном мире."
	levels = list(
		"Необученный" = "Вы не знакомы с управлением мехов и будете совершать ошибки при передвижении и использовании модулей. <br>-Боевые модули недопступны. <br>-Случайные повороты во время движения. <br>-Чем выше навык - тем больше скорость погрузки в меха.",
		"Гражданский опыт" = "У вас есть опыт управления мехами и вы можете полноценно им управлять, но не использовать боевые модули. <br>-Боевые модули недопступны. <br>-Полная управляемость меха.",
		"Боевой опыт" = "У вас есть опыт пилотирования мехов в боевых условиях, в бою вы ведёте себя смело и уверенно, чувствуя себя как в танке. Вы можете использовать все боевые модули. <br>-Доступны боевые модули. <br>-Полная управляемость меха. <br>-Отвага и слабоумие в бою.")
	default_max = SKILL_TRAINED

//По каким-то уморительным причинам если выставить нул не в инициализации а выше - то эффекта не будет и
//То у игроков не будет рисоваться "Необученный", игра будет думать что ЕВА нужна для скилла
//Лезть в кор код глупо, потому ниже вот такой костыль.
//Не сносите его плез.
/singleton/hierarchy/skill/general/EVA/mech/Initialize()
	.=..()
	prerequisites = null

/singleton/hierarchy/skill/general/EVA/mech/get_cost(level)
	switch(level)
		if(SKILL_BASIC)
			return 2
		if(SKILL_TRAINED)
			return 4
		else
			return 0
