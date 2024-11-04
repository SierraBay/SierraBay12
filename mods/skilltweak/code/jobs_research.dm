/datum/job/roboticist
	title = "Roboticist"
	department = "Научный"
	department_flag = SCI

	total_positions = 2
	spawn_positions = 2
	supervisors = "Директору Исследований и Старшему Исследователю"
	selection_color = "#633d63"
	economic_power = 6
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 27
	alt_titles = list(
			"Biomechanical Engineer",
			"Exosuit Technician",
		)
	outfit_type = /singleton/hierarchy/outfit/job/sierra/crew/research/roboticist
	allowed_branches = list(
			/datum/mil_branch/employee,
			/datum/mil_branch/contractor
		)
	allowed_ranks = list(
			/datum/mil_rank/civ/nt,
			/datum/mil_rank/civ/contractor
		)
	min_skill = list(
			SKILL_COMPUTER		=	SKILL_TRAINED,
			SKILL_DEVICES		=	SKILL_TRAINED,
			SKILL_ANATOMY		=	SKILL_TRAINED,
			SKILL_MEDICAL		=	SKILL_BASIC,
			SKILL_ELECTRICAL	=	SKILL_TRAINED
		)

	max_skill = list(
			SKILL_CONSTRUCTION	=	SKILL_MAX,
			SKILL_ELECTRICAL	=	SKILL_MAX,
			SKILL_ATMOS			=	SKILL_EXPERIENCED,
			SKILL_ENGINES		=	SKILL_EXPERIENCED,
			SKILL_DEVICES		=	SKILL_MAX,
			SKILL_MEDICAL		=	SKILL_EXPERIENCED,
			SKILL_ANATOMY		=	SKILL_EXPERIENCED
		)

	skill_points = 22

	access = list(
			access_robotics,
			access_research,
			access_tech_storage,
			access_research_storage
		)


/datum/job/roboticist/get_description_blurb()
	return "Корабельный роботехник, в первую очередь, занимается производством и обслуживанием киборгов и роботов корабля.\
	Он также может быть призван собирать различные экзокостюмы, ремонтировать протезированные конечности у членов экипажа и пересаживать чей-то мозг в корпус киборга или полностью синтетический юнит."
