//Всё сложено сюда, ибо юниттест реально инфернальный и не пускает
/datum/job/security_mech_pilot
	title = "Mechanized Systems Operator"
	department = "Security"
	department_flag = SEC
	total_positions = 1
	spawn_positions = 1
	selection_color = "#601c1c"
	hud_icon = "hudmechsec"
	supervisors = "Главе Службы безопасности и Смотрителю (сержанту)"
	economic_power = 6
	minimal_player_age = 10
	minimum_character_age = list(SPECIES_HUMAN = 22)
	ideal_character_age = 25
	alt_titles = list("Combat Mech Pilot")


	skill_points = 10 //Почему 10 поинтов? 6 поинта за мехводство, 4 за пилотирование. 20 - 6 - 4

	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
						SKILL_EVA         = SKILL_BASIC,
						SKILL_MECH        = SKILL_TRAINED,
						SKILL_PILOT       = SKILL_TRAINED,
						SKILL_COMBAT      = SKILL_BASIC,
						SKILL_HAULING     = SKILL_BASIC,
						SKILL_WEAPONS     = SKILL_TRAINED,
						SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT       = SKILL_MAX,
	                    SKILL_WEAPONS      = SKILL_MAX,
						SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
						SKILL_ELECTRICAL   = SKILL_EXPERIENCED,
						SKILL_DEVICES      = SKILL_EXPERIENCED)







	software_on_spawn = list(/datum/computer_file/program/digitalwarrant,
							 /datum/computer_file/program/camera_monitor)

/datum/job/security_mech_pilot/get_description_blurb()
	return "Оператор механизированных систем — сотрудник отдела безопасности, специализирующийся на \
	обслуживании и пилотировании как мехов, так и специального челнока. В его распоряжении имеются \
	небольшой летательный аппарат «Фаэтон», предназначенный для быстрой транспортировки боевой группы \
	к точке назначения, а также боевой мех, оснащённый нелетальными средствами задержания. \
	В обязанности сотрудника входят заправка, снаряжение и осмотр «Фаэтона», \
	а также поддержание меха в рабочем состоянии. При отсутствии необходимости в использовании \
	механизированных систем сотрудник, обладая теми же полномочиями, что и офицер отдела безопасности, \
	может проводить пешие патрули, задержания и обыски."





/singleton/hierarchy/outfit/job/sierra/crew/security/mech_pilot
	name = OUTFIT_JOB_NAME("Mechanized Systems Operator - Sierra")
	shoes = /obj/item/clothing/shoes/jackboots
