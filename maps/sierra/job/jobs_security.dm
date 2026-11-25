/datum/job/warden
	title = "Warden"
	department = "Security"
	department_flag = SEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Главе Службы безопасности"
	economic_power = 9
	minimal_player_age = 14
	minimum_character_age = list(SPECIES_HUMAN = 26)
	ideal_character_age = 28
	alt_titles = list(
		"Security Sergeant",
		)
	outfit_type = /singleton/hierarchy/outfit/job/sierra/crew/security/warden
	allowed_branches = list(/datum/mil_branch/employee)
	allowed_ranks = list(/datum/mil_rank/civ/nt, /datum/mil_rank/civ/acting, /datum/mil_rank/civ/probation_employee)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_TRAINED,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_HAULING	  = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_TRAINED,
	                    SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX,
	                    SKILL_FORENSICS   = SKILL_MAX)
	skill_points = 25

	access = list(access_seceva, access_mech_security, access_guard, access_security, access_brig, access_armory, access_forensics_lockers,
			            access_maint_tunnels, access_external_airlocks, access_emergency_storage,
			            access_eva, access_sec_doors, access_gun, access_hangar, access_warden, access_security_records
			            )



	software_on_spawn = list(/datum/computer_file/program/digitalwarrant,
							 /datum/computer_file/program/camera_monitor)

	// SIERRA TODO: need_exp_to_play
	// need_exp_to_play = 2

/datum/job/warden/get_description_blurb()
	return "Надзиратель отвечает за наблюдение, допрос, уход и безопасность заключенных, арестованных охранниками.\
	Как следует из названия, он несет ответственность за наблюдение за различными камерами и шкафами со снаряжением, доступным персоналу безопасности,\
	а также за надлежащую организацию проведения допросов подозреваемых и наказаний виновных.\
	Это включает в себя обновление их записей в базах данных, а также исполнение наказаний, в виде помещения в камеру."

/datum/job/detective
	title = "Criminal Investigator"
	department = "Security"
	department_flag = SEC
	hud_icon = "huddetective"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Главе Службы безопасности"
	economic_power = 8
	minimal_player_age = 7
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 30
	skill_points = 14
	alt_titles = list(
		"Forensic Technician"
		)
	outfit_type = /singleton/hierarchy/outfit/job/sierra/crew/security/detective
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/civilian, /datum/mil_branch/contractor)
	allowed_ranks = list(/datum/mil_rank/civ/nt, /datum/mil_rank/civ/contractor, /datum/mil_rank/civ/civ, /datum/mil_rank/civ/probation_employee, /datum/mil_rank/civ/probation_contractor)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_COMPUTER    = SKILL_BASIC,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_BASIC,
	                    SKILL_FORENSICS   = SKILL_TRAINED)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX,
	                    SKILL_FORENSICS   = SKILL_MAX)
	skill_points = 22

	access = list(access_seceva, access_security, access_brig, access_forensics_lockers,
			            access_maint_tunnels, access_emergency_storage, access_eva,
			            access_sec_doors, access_morgue, access_hangar, access_security_records)



	software_on_spawn = list(/datum/computer_file/program/digitalwarrant,
							 /datum/computer_file/program/camera_monitor)

/datum/job/detective/get_description_blurb()
	return "Детектив занимается расследованием преступлений, взятием отпечатков пальцев, поиском потенциальных преступников и разрешением самых запутанных дел.\
	Его основная миссия - выяснить, кто совершил преступление и собрать все имеющиеся доказательства."

/datum/job/officer
	title = "Security Guard"
	department = "Security"
	department_flag = SEC
	total_positions = 4
	spawn_positions = 4
	supervisors = "Главе Службы безопасности и Смотрителю (сержанту)"
	economic_power = 6
	minimal_player_age = 10
	minimum_character_age = list(SPECIES_HUMAN = 22)
	ideal_character_age = 25
	alt_titles = list("Junior Guard", "Cadet")


	skill_points = 20

	outfit_type = /singleton/hierarchy/outfit/job/sierra/crew/security/officer
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)
	allowed_ranks = list(/datum/mil_rank/civ/nt, /datum/mil_rank/civ/contractor, /datum/mil_rank/civ/probation_employee, /datum/mil_rank/civ/probation_contractor)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_HAULING     = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_TRAINED,
	                    SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX)

	access = list(access_seceva, access_guard, access_security, access_brig, access_maint_tunnels,
						access_external_airlocks, access_emergency_storage,
			            access_eva, access_sec_doors, access_hangar, access_security_records)



	software_on_spawn = list(/datum/computer_file/program/digitalwarrant,
							 /datum/computer_file/program/camera_monitor)

/datum/job/officer/get_description_blurb()
	return "Охранник - это основная должность отдела безопасности. Офицеры представляют собой первую линию защиты корабля от криминальных элементов и враждебных форм жизни. \
	 Со своими надежными дубинкой и тазером, охрана преследует различных нарушителей закона на судне и отправляет их в бриг отбывать заслуженное наказание. \
	 Главной задачей офицеров СБ является предотвращение ущерба персоналу корабля и собственности корпорации, и охранник который не ставит эти обязанности для себя на первое место имеет мало шансов задержаться на этой работе."





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
	outfit_type = /singleton/hierarchy/outfit/job/sierra/crew/security/mech_pilot


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

	allowed_ranks = list(/datum/mil_rank/civ/nt, /datum/mil_rank/civ/contractor, /datum/mil_rank/civ/probation_employee, /datum/mil_rank/civ/probation_contractor)
	access = list(access_mech_security, access_seceva, access_guard, access_security, access_brig, access_maint_tunnels,
						access_external_airlocks, access_emergency_storage,
			            access_eva, access_sec_doors, access_hangar, access_security_records)







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
	uniform = /obj/item/clothing/under/rank/security/corp/mech_pilot
	shoes = /obj/item/clothing/shoes/jackboots
