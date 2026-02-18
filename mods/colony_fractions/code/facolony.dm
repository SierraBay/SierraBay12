// Frontier Alliance: Blockade Runners Extension (Playable Colony) by GarryFlint

/datum/map_template/ruin/exoplanet/facolony
	name = "FA Blockade Runners Outpost"
	id = "facolony"
	description = "FA Blockade Runners Outpost"
	mappaths = list('mods/colony_fractions/maps/facolony.dmm')
	spawn_cost = 3
	player_cost = 0
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS | TEMPLATE_FLAG_NO_RADS
	ruin_tags = RUIN_HUMAN|RUIN_HABITAT
	ban_ruins = list(
		/datum/map_template/ruin/exoplanet/playablecolony,
		/datum/map_template/ruin/exoplanet/playablecolony2
	)
	apc_test_exempt_areas = list(
		/area/map_template/facolony/mineralprocessing = NO_SCRUBBER|NO_VENT,
		/area/map_template/facolony/outsidewarehouse = NO_SCRUBBER|NO_VENT
	)
	spawn_weight = 1
	skip_main_unit_tests = TRUE

/singleton/submap_archetype/facolony
	descriptor = "FA Blockade Runners Outpost"
	crew_jobs = list(
		/datum/job/submap/facolony/colonist,
		/datum/job/submap/facolony/colonist/scientist,
		/datum/job/submap/facolony/colonist/medic,
		/datum/job/submap/facolony/colonist/engineer,
		/datum/job/submap/facolony/colonist/leader
	)

var/global/const/access_facolony = "ACCESS_FACOLONY"

/datum/access/facolony
	id = access_facolony

/singleton/hierarchy/outfit/job/facolony
	name = OUTFIT_JOB_NAME("facolony")
	id_types = list(/obj/item/card/id/facolony)
	pda_type = null
	l_ear = /obj/item/device/radio/headset/map_preset/facolony

/datum/job/submap/facolony/colonist
	title = "Cargo Operator"
	supervisors = "Ship Captain"
	info = "You are a colonist living on the rim of explored space. Keep the outpost running and protect its interests."
	total_positions = 3
	outfit_type = /singleton/hierarchy/outfit/job/facolony
	is_semi_antagonist = TRUE
	max_skill = list(
		SKILL_COMBAT		= SKILL_EXPERIENCED,
		SKILL_WEAPONS		= SKILL_EXPERIENCED
	)

/datum/job/submap/facolony/colonist/leader
	title = "Ship Captain"
	supervisors = "Jared, Long-Range Handler"
	info = "Вы — Лидер одной из ячеек Блокадных Беглецов Альянса Фронтира. Развивайте торговый пункт, проводите сделки, обменивайтесь информацией и прокладывайте маршруты для тех, кто ищет свободу от империалистических цепей. Придерживайтесь легенды, не раскрывайте истинных мотивов кому попало, особенно оккупантам из ЦПСС. И вы же уже придумали, что будете делать с угнанным тягачом?"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/facolony
	is_semi_antagonist = TRUE
	min_skill = list(
		SKILL_COMBAT	= SKILL_BASIC,
		SKILL_WEAPONS	= SKILL_BASIC,
		SKILL_PILOT	= SKILL_BASIC,
		SKILL_PHYSICAL	= SKILL_BASIC
	)
	max_skill = list(
		SKILL_PILOT			= SKILL_MAX,
		SKILL_CONSTRUCTION	= SKILL_MAX,
		SKILL_ELECTRICAL	= SKILL_MAX,
		SKILL_ATMOS			= SKILL_MAX,
		SKILL_ENGINES		= SKILL_MAX,
		SKILL_CHEMISTRY		= SKILL_MAX,
		SKILL_SCIENCE		= SKILL_MAX,
		SKILL_DEVICES		= SKILL_MAX,
		SKILL_COMBAT		= SKILL_MAX,
		SKILL_FORENSICS		= SKILL_MAX,
		SKILL_WEAPONS		= SKILL_MAX
	)

/datum/job/submap/facolony/colonist/scientist
	title = "Systems Technician"
	supervisors = "Ship Captain"
	info = "Вы — Системный Техник в команде Блокадных Беглецов Альянса Фронтира. Поддерживайте и модифицируйте системы базы, развивайте торговый пункт, проводите сделки, обменивайтесь информацией и прокладывайте маршруты для тех, кто ищет свободу от империалистических цепей. Придерживайтесь легенды, не раскрывайте истинных мотивов кому попало, особенно оккупантам из ЦПСС. И вы же уже придумали, что будете делать с угнанным тягачом?"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/facolony
	is_semi_antagonist = TRUE
	min_skill = list(
		SKILL_DEVICES	= SKILL_TRAINED,
		SKILL_CONSTRUCTION	= SKILL_BASIC,
		SKILL_ELECTRICAL	= SKILL_BASIC
	)
	max_skill = list(
		SKILL_SCIENCE	= SKILL_EXPERIENCED,
		SKILL_DEVICES	= SKILL_EXPERIENCED
	)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/datum/job/submap/facolony/colonist/medic
	title = "Crew Medic"
	supervisors = "Ship Captain"
	info = "Вы — Врач в команде Блокадных Беглецов Альянса Фронтира. Вытаскивайте товарищей с того света, развивайте торговый пункт, проводите сделки, обменивайтесь информацией и прокладывайте маршруты для тех, кто ищет свободу от империалистических цепей. Придерживайтесь легенды, не раскрывайте истинных мотивов кому попало, особенно оккупантам из ЦПСС. И вы же уже придумали, что будете делать с угнанным тягачом?"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/facolony
	is_semi_antagonist = TRUE
	min_skill = list(
		SKILL_MEDICAL = SKILL_TRAINED,
		SKILL_CHEMISTRY = SKILL_BASIC,
		SKILL_ANATOMY = SKILL_EXPERIENCED
	)
	max_skill = list(
		SKILL_CHEMISTRY = SKILL_MAX,
		SKILL_MEDICAL	= SKILL_MAX,
		SKILL_ANATOMY = SKILL_MAX
	)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/datum/job/submap/facolony/colonist/engineer
	title = "Ship Mechanic"
	supervisors = "Ship Captain"
	info = "Вы — Инженер в команде Блокадных Беглецов Альянса Фронтира. Поддерживайте работоспособность систем питания и атмоса, развивайте торговый пункт, проводите сделки, обменивайтесь информацией и прокладывайте маршруты для тех, кто ищет свободу от империалистических цепей. Придерживайтесь легенды, не раскрывайте истинных мотивов кому попало, особенно оккупантам из ЦПСС. И вы же уже придумали, что будете делать с угнанным тягачом?"
	total_positions = 2
	outfit_type = /singleton/hierarchy/outfit/job/facolony
	is_semi_antagonist = TRUE
	min_skill = list(
		SKILL_COMPUTER		= SKILL_BASIC,
		SKILL_EVA			= SKILL_BASIC,
		SKILL_CONSTRUCTION	= SKILL_TRAINED,
		SKILL_ELECTRICAL	= SKILL_BASIC,
		SKILL_ATMOS			= SKILL_BASIC,
		SKILL_ENGINES		= SKILL_BASIC
	)
	max_skill = list(
		SKILL_CONSTRUCTION	= SKILL_MAX,
		SKILL_ELECTRICAL	= SKILL_MAX,
		SKILL_ATMOS			= SKILL_MAX,
		SKILL_ENGINES		= SKILL_MAX
		)
	outfit_type = /singleton/hierarchy/outfit/job/facolony

/obj/submap_landmark/spawnpoint/facolony/leader_spawn
	name = "Ship Captain"

/obj/submap_landmark/spawnpoint/facolony/crewman_spawn
	name = "Crewman"

/obj/submap_landmark/spawnpoint/facolony/scientist_spawn
	name = "Systems Technician"

/obj/submap_landmark/spawnpoint/facolony/medic_spawn
	name = "Crew Medic"

/obj/submap_landmark/spawnpoint/facolony/engineer_spawn
	name = "Ship Mechanic"

/obj/submap_landmark/joinable_submap/facolony
	name = "FA Blockade Runners Outpost"
	archetype = /singleton/submap_archetype/facolony

/obj/item/card/id/facolony
	name = "Crew access card"
	desc = "Old worn-out access card."
	access = list(access_facolony)
	color = COLOR_OFF_WHITE
	detail_color = COLOR_GRAY15

/obj/paint/facolony/commandblue
	color = "#46698c"

/obj/structure/table/mag/facolony
	req_access = list(access_facolony)

/obj/structure/closet/facolony/wardrobe
	name = "Wardrobe Locker"
	closet_appearance = /singleton/closet_appearance/wardrobe/red

/obj/structure/closet/facolony/wardrobe/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/troops_colony/heavy = 4,
		/obj/item/clothing/head/helmet = 4,
		/obj/item/clothing/accessory/storage/holster/hip = 4,
		/obj/item/shield/riot/metal = 1
	)

/obj/item/clothing/under/fa/vacsuit/facolony/guardsman
	accessories = list(/obj/item/clothing/accessory/fa_badge/guardsman)

/obj/item/clothing/under/fa/vacsuit/facolony/warden
	accessories = list(/obj/item/clothing/accessory/fa_badge/warden)

/obj/item/clothing/under/fa/vacsuit/facolony/marshal
	accessories = list(/obj/item/clothing/accessory/fa_badge/marshal)

/obj/structure/closet/facolony/vacsuits
	name = "plain locker"
	closet_appearance = /singleton/closet_appearance/wardrobe/black

/obj/structure/closet/facolony/vacsuits/WillContain()
	return list(
		/obj/item/clothing/accessory/storage/webbing_large = 2,
		/obj/item/clothing/under/fa/vacsuit/facolony/warden = 1,
		/obj/item/clothing/mask/balaclava = 8,
		/obj/item/clothing/under/fa/vacsuit/facolony/guardsman = 8
	)

/obj/structure/sign/double/faflag/left
	name = "Frontier Alliance flag"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "faflag_l"

/obj/structure/sign/double/faflag/right
	name = "Frontier Alliance flag"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "faflag_r"

/obj/structure/sign/double/falogo/
	name = "Frontier Alliance logo"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "falogo"

/obj/floor_decal/falogo
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "falogo"

/obj/machinery/telecomms/hub/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/receiver/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/bus/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/processor/map_preset/facolony
	preset_name = "Internal"

/obj/machinery/telecomms/server/map_preset/facolony
	preset_name = "Internal"
	preset_color = COLOR_SKY_BLUE

/obj/machinery/telecomms/broadcaster/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/radio/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/radio/intercom/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/encryptionkey/map_preset/facolony
	preset_name = "Internal"

/obj/item/device/radio/headset/map_preset/facolony
	preset_name = "Internal"
	encryption_key = /obj/item/device/encryptionkey/map_preset/facolony

/obj/machinery/door/airlock/facolony/command
	name = "Airlock"
	door_color = COLOR_COMMAND_BLUE
	stripe_color = COLOR_GUNMETAL

/obj/machinery/door/airlock/facolony/mining
	name = "Airlock"
	door_color = COLOR_PALE_ORANGE
	stripe_color = COLOR_GUNMETAL

/obj/machinery/door/airlock/multi_tile/facolony/general
	name = "Airlock"
	stripe_color = COLOR_GRAY20

/obj/machinery/door/airlock/facolony/general
	name = "Airlock"
	stripe_color = COLOR_GRAY20

/obj/machinery/door/airlock/glass/facolony/jail
	name = "Temporary Detention"
	stripe_color = COLOR_NT_RED

/obj/item/paper/facolony/faxmessage
	name = "FAFB 'Kelpi' - Message"
	language = "Spacer"
	info = {"
	<tt><font face='Verdana' color='black'><center><img src='falogo.png'><br><b><large>Сообщение от<br>Передовой Базы 'Кельпи'<br>Объединённой Флотилии</large></b></center><hr><font size='1'><b>Форма:</b> СС-UFCO-COMFA<br><b>Объект:</b> <u>ПБ 'Кельпи'</u><br><b>Отправитель:</b> <u>Агент Дальней Связи Смотритель 'Джаред'</u><br><b>Подпись:</b> <u><i>J-R-D</i></u><br><b>Время:</b> <u>\[time\]</u><br><b>Дата:</b> <u>\[date\]</u></font><hr><font size='1'><b>Объект-получатель:</b> <u>IPV 'Celeste Hauler'</u><br><b>Адресат:</b> <u>B.R. \[date\]</u></font><hr><center><b>Сообщение</b></center>Приветствуем вас, Блокадники!<br>Мы рады наблюдать, что операция по изъятию активов завершилась успешно.<br><br>Судя по вашим отчётам, у тягача был внушительный запас ресурсов, включая добытое вами дополнительно, — поэтому развёрнутый торговый пункт держится стабильно. У вас остаётся несколько незаконченных секций базы — нам не терпится узнать, под что вы их оборудуете.<br><br>Однако, как бы хорошо вам сейчас ни жилось, помните, ради чего вы пошли на этот угон.<br>Блокада, поддерживаемая оккупантами из ЦПСС, всё ещё действует, а значит, на ваших плечах лежит задача добывать ресурсы максимально широкого спектра: от материалов и медикаментов — до вооружения и сложных технологий. Место, где вы сейчас находитесь, — важный узел будущей торговли между империалистическими государствами: в частности, оно расположено у границ Скрелльской Империи.<br><br>Корабли Ассамблеи, Конфедерации, Позитронного союза, а также суда частных лиц и компаний будут проходить через вас. Ваша задача — извлечь максимум прибыли: торгуйте найденными предметами, обменивайтесь информацией и прокладывайте маршруты тем, кто ищет свободу от цепей империалистов.<br><br>Важно помнить об осторожности. Не доверяйте каждому встречному — ориентируйтесь на систему медалей и проверенные каналы. Если солдаты ЦПСС установят вашу связь с Альянсом Фронтира, всё закончится мгновенно. Не допускайте их граждан вглубь территории и тем более не раскрывайте секретные помещения. Держитесь легенды независимых предпринимателей и колонистов.<br><br>ГКК не наш прямой противник, но и не союзник; не стоит верить им лишь потому, что они по другую сторону баррикад от Ассамблеи. Если ЦПСС перейдёт к открытому давлению, солдаты ГКК, скорее всего, попытаются усыпить вашу бдительность сладкими речами. Не поддавайтесь и не раскрывайте ничего сверх легенды.<br><br>Блокада никуда не делась. Её прорыв — на плечах Блокадных Беглецов. Сделайте всё, чтобы наш дом не знал голода.<br><br><center><b>Конец сообщения</b></center><hr><center><b>МП</b></center><hr><font size='1'><i>*Данная форма документа обязательно должна подтверждаться подписью или печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей документ считается недействительным;<br>*Получатель(и) данной трансляции сообщения подтверждает(ют), что он(она/они) несут ответственность за любой ущерб, который может возникнуть в результате игнорирования приведённых здесь директив или рекомендаций;<br>*Все отчёты должны храниться конфиденциально их предполагаемым получателем и любой соответствующей стороной. Несанкционированное распространение данного сообщения может привести к дисциплинарным взысканиям.</i></font></font></tt>
	"}

/// AREAS ///

/area/map_template/facolony
	req_access = list(access_facolony)

/area/map_template/facolony/command
	name = "\improper IPV Celeste Hauler - Bridge"
	icon_state = "A"

/area/map_template/facolony/airlock
	name = "\improper Base Primary External Airlock"
	icon_state = "A"

/area/map_template/facolony/armory
	name = "\improper Ship Armory"
	icon_state = "A"

/area/map_template/facolony/bathroom
	name = "\improper Base Lavatory"
	icon_state = "A"

/area/map_template/facolony/dorms
	name = "\improper Base Dormitories"
	icon_state = "A"

/area/map_template/facolony/engineering
	name = "\improper Ship Engineering"
	icon_state = "processing"

/area/map_template/facolony/atmospherics
	name = "\improper Ship Atmospherics"
	icon_state = "shipping"

/area/map_template/facolony/atmospherics2
	name = "\improper Base Atmospherics"
	icon_state = "shipping"

/area/map_template/facolony/cargo
	name = "\improper Ship Mid Cargo Area"
	icon_state = "A"

/area/map_template/facolony/cargo2
	name = "\improper Ship Aft Cargo Area"
	icon_state = "A"

/area/map_template/facolony/cargohatch
	name = "\improper Ship Cargo Hatch"
	icon_state = "B"

/area/map_template/facolony/unspecified
	name = "\improper Unspecified Compartment"
	icon_state = "A"

/area/map_template/facolony/tcomms
	name = "\improper Base Telecommunications"
	icon_state = "B2"

/area/map_template/facolony/medbay
	name = "\improper Ship Infirmary"
	icon_state = "A"

/area/map_template/facolony/surgery
	name = "\improper Ship Operating Theatre"
	icon_state = "A"

/area/map_template/facolony/messhall
	name = "\improper Ship Mess Hall"
	icon_state = "B"

/area/map_template/facolony/mineralprocessing
	name = "\improper Base Mining Site"
	icon_state = "A"

/area/map_template/facolony/science
	name = "\improper Base R&D"
	icon_state = "A"

/area/map_template/facolony/warehouse
	name = "\improper Base warehouse"
	icon_state = "shipping"

/area/map_template/facolony/outsidewarehouse
	name = "\improper Trade Zone warehouse"
	icon_state = "shipping"

/area/map_template/facolony/tradezone
	name = "\improper Trade Zone"
	icon_state = "shipping"
