/datum/job/submap/CTI_professor
	title = "CTI Professor of Xenoscience"
	total_positions = 0 // Pedal spawn only
	outfit_type = /singleton/hierarchy/outfit/job/verne/professor
	supervisors = "the CTI Rector"
	info = "Вы руководите ГНС Верне, перевозящим студентов престижного Технического Университета Киты, во время проведения исследований \
	в глубинах космоса. Ваша задача как профессора Ксенонауки - обеспечить студентов всем необходимым для исследований, быть их научным руководителем. Вы были пробуждены из криосна \
 	для помощи группе по обследованию сектора. Возможно им понадобится ваша оценка сложных аномалий и умение договариваться. На фронтире нынче неспокойно."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN,SPECIES_SKRELL)
	required_language = LANGUAGE_HUMAN_EURO

	min_skill = list(
		SKILL_BUREAUCRACY	=	SKILL_TRAINED,
		SKILL_COMPUTER		=	SKILL_BASIC,
		SKILL_FINANCE		=	SKILL_TRAINED,
		SKILL_BOTANY		=	SKILL_BASIC,
		SKILL_ANATOMY		=	SKILL_BASIC,
		SKILL_DEVICES		=	SKILL_BASIC,
		SKILL_SCIENCE		=	SKILL_TRAINED

	)

	max_skill = list(
		SKILL_ANATOMY		=	SKILL_MAX,
		SKILL_DEVICES		=	SKILL_MAX,
		SKILL_SCIENCE		=	SKILL_MAX
	)
	skill_points = 30 //skills copied from Sierra pilot - 6 points

/datum/job/submap/CTI_pilot
	title = "CTI Pilot"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/verne/pilot
	supervisors = "the CTI Professor in Command of the Verne"
	info = "Вы работаете на ГНС Верне, перевозящим студентов престижного Технического Университета Киты, во время проведения исследований \
	в глубинах космоса. Ваша работа в группе Обследования проста; Пилотировать ГНС Верне и ГНС Почтенный Сом; защищать студентов; помогать им в обучении. Ваша группа Обследования проснулась \
	и обнаружила, что Верне переживает нехватку персонала, генерирующих мощностей, а автоматизированные системы жизнеобеспечения работают на полную."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_EVA     = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_TRAINED,
		SKILL_PILOT   = SKILL_TRAINED,
	)

	max_skill = list(
		SKILL_PILOT   = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
	)
	skill_points = 20 //skills copied from Torch pilot + gun

/datum/job/submap/CTI_engineer
	title = "CTI Engineer"
	total_positions = 1 //up to two in larger mode
	outfit_type = /singleton/hierarchy/outfit/job/verne/engineer
	supervisors = "the CTI Professor in Command of the Verne"
	info = "Вы работаете на ГНС Верне, перевозящим студентов престижного Технического Университета Киты, во время проведения исследований \
 	в глубинах космоса. Ваша работа в группе Обследования проста; Обслуживать ГНС Верне и ГНС Почтенный Сом; защищать студентов; помогать им в обучении. Ваша группа Обследования проснулась \
	и обнаружила, что Верне переживает нехватку персонала, генерирующих мощностей, а автоматизированные системы жизнеобеспечения работают на полную."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
		SKILL_EVA          = SKILL_BASIC,
		SKILL_CONSTRUCTION = SKILL_TRAINED,
		SKILL_ELECTRICAL   = SKILL_BASIC,
		SKILL_ATMOS        = SKILL_BASIC,
		SKILL_ENGINES      = SKILL_BASIC,
	)

	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MAX,
		SKILL_ELECTRICAL   = SKILL_MAX,
		SKILL_ATMOS        = SKILL_MAX,
		SKILL_ENGINES      = SKILL_MAX,
	)
	skill_points = 20 //skills copied from torch eng

/datum/job/submap/CTI_Undergraduate_Xenoscience_Researcher
	title = "CTI Undergraduate Xenoscience Researcher"
	supervisors = "the CTI Professor in Command of the Verne"
	total_positions = 2 // up to four in larger mode
	outfit_type = /singleton/hierarchy/outfit/job/verne/researcher
	info = "Вы студент-бакалавр ксенонауки на борту ГНС Верне, занимающийся исследованиями с вашими одногруппниками из престижного Технического Университета Киты \
	в глубинах космоса. Группа Обследования будет сопровождать вас, готовая помочь вашим исследованием экзопланет этой системы. Ваша группа проснулась \
	и обнаружила, что Верне переживает нехватку персонала, генерирующих мощностей, а автоматизированные системы жизнеобеспечения работают на полную."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_BUREAUCRACY = SKILL_BASIC,
		SKILL_COMPUTER    = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_BASIC,
		SKILL_SCIENCE     = SKILL_TRAINED,
	)

	max_skill = list(
		SKILL_ANATOMY = SKILL_MAX,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
	)
	skill_points = 20 //skills copied from Torch sci

/datum/job/submap/CTI_Exchange_Student
	title = "CTI Undergraduate Anomaly Researcher"
	supervisors = "the CTI Professor in Command of the Verne"
	total_positions = 1 // up to two in larger mode
	outfit_type = /singleton/hierarchy/outfit/job/verne/anomalist
	info = "Вы студент по обмену, прибывший с родной планеты, чтобы обучаться исследованию аномалий на борту ГНС Верне, снаряженым престижным Техническим Университом Киты \
	и отправленным в глубины космоса. Группа Обследования будет сопровождать вас, готовая помочь вашим исследованием экзопланет этой системы. Ваша группа проснулась \
	и обнаружила, что Верне переживает нехватку персонала, генерирующих мощностей, а автоматизированные системы жизнеобеспечения работают на полную."
	whitelisted_species = list(SPECIES_TAJARA,SPECIES_UNATHI,SPECIES_YEOSA,SPECIES_RESOMI)
	required_language = LANGUAGE_HUMAN_EURO
	min_skill = list(
		SKILL_BUREAUCRACY = SKILL_BASIC,
		SKILL_COMPUTER    = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_BASIC,
		SKILL_SCIENCE     = SKILL_TRAINED,
	)

	max_skill = list(
		SKILL_ANATOMY = SKILL_MAX,
		SKILL_DEVICES = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX,
	)
	skill_points = 20 //skills copied from Torch sci

#define VERNE_OUTFIT_JOB_NAME(job_name) ("CTI Research Vessel - Job - " + job_name)
/singleton/hierarchy/outfit/job/verne
	hierarchy_type = /singleton/hierarchy/outfit/job/verne
	pda_type = null
	pda_slot = null
	id_types = list(/obj/item/card/id/verne)
	l_ear = /obj/item/device/radio/headset/map_preset/verne

/singleton/hierarchy/outfit/job/verne/professor
	name = OUTFIT_JOB_NAME("CTI Professor of Xenoscience")
	uniform = /obj/item/clothing/under/rank/research_director/rdalt
	suit = /obj/item/clothing/suit/storage/toggle/labcoat
	shoes = /obj/item/clothing/shoes/brown
	backpack_contents = list(/obj/item/spacecash/bundle/c1000 = 5)

/singleton/hierarchy/outfit/job/verne/pilot
	name = VERNE_OUTFIT_JOB_NAME("Pilot")
	uniform = /obj/item/clothing/under/suit_jacket/navy
	shoes = /obj/item/clothing/shoes/dress/caretakershoes
	belt = /obj/item/storage/belt/holster/general
	r_pocket = /obj/item/gun/energy/gun/small
	l_pocket = /obj/item/crowbar/prybar
	backpack_contents = list(/obj/item/spacecash/bundle/c1000 = 4, /obj/item/spacecash/bundle/c200 = 1)

/singleton/hierarchy/outfit/job/verne/engineer
	name = VERNE_OUTFIT_JOB_NAME("Engineer")
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/workboots
	belt = /obj/item/storage/belt/utility/full
	r_pocket = /obj/item/device/radio/map_preset/verne
	l_pocket = /obj/item/crowbar/prybar
	backpack_contents = list(/obj/item/spacecash/bundle/c1000 = 2, /obj/item/spacecash/bundle/c500 = 1, /obj/item/spacecash/bundle/c200 = 1, /obj/item/spacecash/bundle/c100 = 1)

/singleton/hierarchy/outfit/job/verne/engineer/New()
	..()
	backpack_overrides[/singleton/backpack_outfit/backpack] = /obj/item/storage/backpack/industrial
	backpack_overrides[/singleton/backpack_outfit/satchel] = /obj/item/storage/backpack/satchel/eng
	backpack_overrides[/singleton/backpack_outfit/messenger_bag] = /obj/item/storage/backpack/messenger/engi

/singleton/hierarchy/outfit/job/verne/researcher
	name = VERNE_OUTFIT_JOB_NAME("Undergraduate Xenoscience Researcher")
	uniform = /obj/item/clothing/under/rank/psych/turtleneck
	suit = /obj/item/clothing/suit/storage/toggle/hoodie/cti
	shoes = /obj/item/clothing/shoes/black
	backpack_contents = list(/obj/item/spacecash/bundle/c1000 = 1, /obj/item/spacecash/bundle/c500 = 1)

/singleton/hierarchy/outfit/job/verne/anomalist
	name = VERNE_OUTFIT_JOB_NAME("Undergraduate Anomaly Researcher")
	uniform = /obj/item/clothing/under/rank/psych/turtleneck
	suit = /obj/item/clothing/suit/storage/toggle/hoodie/cti
	shoes = /obj/item/clothing/shoes/black
	backpack_contents = list(/obj/item/spacecash/bundle/c1000 = 1)

/obj/submap_landmark/spawnpoint/CTI_professor
	name = "CTI Professor of Xenoscience"

/obj/submap_landmark/spawnpoint/CTI_pilot
	name = "CTI Pilot"

/obj/submap_landmark/spawnpoint/CTI_engineer
	name = "CTI Engineer"

/obj/submap_landmark/spawnpoint/CTI_Undergraduate_Xenoscience_Researcher
	name = "CTI Undergraduate Xenoscience Researcher"

/obj/submap_landmark/spawnpoint/CTI_Undergraduate_Anomaly_Researcher
	name = "CTI Undergraduate Anomaly Researcher"

#undef VERNE_OUTFIT_JOB_NAME
