// Derelict Mission Configurations
// Each config maps an away site ID to a corporation and defines mission parameters.

// ============================================================
// COMPLEX MISSIONS (large artifact + research on Sierra)
// ============================================================

// --- Lar Maria -> Zeng-Hu Pharmaceuticals ---
/datum/derelict_mission_config/lar_maria
	away_site_id = "awaysite_lar_maria"
	away_site_name = "Lar Maria"
	corporation_id = RND_MISSION_CORP_ZENG_HU
	mission_type = DERELICT_MISSION_COMPLEX
	ghost_mob_count = 5
	title = "Сыворотка Type-8"
	description = "Орбитальная станция Лар-Мария использовалась Zeng-Hu Pharmaceuticals для секретных вирусологических исследований. Просканируйте терминалы, синтезируйте антидот в вирусологической лаборатории и сдайте исследовательский пакет через дронпад."
	target_artifact_type = /obj/item/derelict_mission_artifact/virus_container
	target_item_type = /obj/item/reagent_containers
	require_antibodies = TRUE
	objective_templates = list(
		list("type" = "scan_object", "description" = "Просканировать исследовательские терминалы (компьютеры) на Лар-Марии. Сохранить RDF-файлы и загрузить в R&D консоль с флешки", "target_type" = /obj/machinery/computer, "count" = 2),
		list("type" = "study_artifact", "description" = "Извлечь образец вируса из контейнера (ПКМ → Extract Sample), доставить чашку в вирусологическую лабораторию, синтезировать вакцину через Vaccine Synthesizer", "target_type" = /obj/item/derelict_mission_artifact/virus_container, "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать бикер с вакциной (антителами) и сдать через дронпад", "target_type" = /obj/item/reagent_containers, "count" = 1)
	)

// --- Meatstation -> Vey-Med ---
/datum/derelict_mission_config/meatstation
	away_site_id = "awaysite_meatstation"
	away_site_name = "Research Station"
	corporation_id = RND_MISSION_CORP_VEYMED
	mission_type = DERELICT_MISSION_COMPLEX
	ghost_mob_count = 3
	title = "Биоэнергетические исследования"
	description = "Заброшенная исследовательская станция, где проводились эксперименты с ксенофлорой и биологической генерацией энергии. Сфотографируйте аномалии, подключите кабель к биоячейке и измерьте выходную мощность — затем сдайте отчёт через дронпад."
	target_artifact_type = /obj/structure/derelict_mission_artifact/bio_cell
	target_item_type = /obj/item/derelict_mission_sample/biocell_sample
	objective_templates = list(
		list("type" = "photograph_object", "description" = "Сфотографировать враждебных существ (карпы, пауки и т.д.) на станции. Подать фото в R&D консоль — физическое или цифровое с флешки", "target_type" = /mob/living/simple_animal/hostile, "count" = 2),
		list("type" = "study_artifact", "description" = "Подключить кабель к биоячейке, измерить мощность на проводе мультитулом до и после, вычислить множитель и ввести его мультитулом на ячейке", "target_type" = /obj/structure/derelict_mission_artifact/bio_cell, "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать биоорганический образец и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/biocell_sample, "count" = 1)
	)

// --- Bluespace River -> Kappa ---
/datum/derelict_mission_config/blue
	away_site_id = "awaysite_blue"
	away_site_name = "Arctic Dwarf Planet"
	corporation_id = RND_MISSION_CORP_KAPPA
	mission_type = DERELICT_MISSION_COMPLEX
	ghost_mob_count = 2
	title = "Инопланетные структуры"
	description = "На ледяной карликовой планете обнаружены подземные структуры инопланетного происхождения. Установите датчик, доставьте фрагмент на Сьерру, проанализируйте в ксеноарх-анализаторе — затем сдайте отчёт через дронпад."
	target_artifact_type = /obj/machinery/artifact/mission/alien_fragment
	target_artifact_report_type = /obj/item/paper/anomaly_scan/mission/alien_fragment
	target_item_type = /obj/item/paper/anomaly_scan/mission/alien_fragment
	objective_templates = list(
		list("type" = "deploy_sensor", "description" = "Установить исследовательский датчик в подземных структурах (активировать в руке)", "count" = 1),
		list("type" = "study_artifact", "description" = "Доставить инопланетный фрагмент на Сьерру и проанализировать в ксеноарх-анализаторе аномалий. Подать распечатанный отчёт в R&D консоль", "target_type" = /obj/machinery/artifact/mission/alien_fragment, "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать отчёт анализатора и сдать через дронпад", "target_type" = /obj/item/paper/anomaly_scan/mission/alien_fragment, "count" = 1)
	)

// --- Mining Station -> Grayson ---
/datum/derelict_mission_config/miningstation
	away_site_id = "awaysite_miningstation"
	away_site_name = "Orbital Mining Station"
	corporation_id = RND_MISSION_CORP_GRAYSON
	mission_type = DERELICT_MISSION_COMPLEX
	title = "Артефакт Грейсон"
	description = "Орбитальная горнодобывающая станция Grayson Industries была заброшена после обнаружения инопланетного артефакта. Просканируйте оборудование, доставьте артефакт на Сьерру, проанализируйте в ксеноарх-анализаторе — затем сдайте отчёт через дронпад."
	target_artifact_type = /obj/machinery/artifact/mission/alien_artifact
	target_artifact_report_type = /obj/item/paper/anomaly_scan/mission/alien_artifact
	target_item_type = /obj/item/paper/anomaly_scan/mission/alien_artifact
	objective_templates = list(
		list("type" = "scan_object", "description" = "Просканировать горное оборудование (машины/механизмы) на станции. Сохранить RDF-файлы и загрузить в R&D консоль с флешки", "target_type" = /obj/machinery, "count" = 2),
		list("type" = "study_artifact", "description" = "Доставить инопланетный артефакт на Сьерру и проанализировать в ксеноарх-анализаторе аномалий. Подать распечатанный отчёт в R&D консоль", "target_type" = /obj/machinery/artifact/mission/alien_artifact, "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать отчёт анализатора и сдать через дронпад", "target_type" = /obj/item/paper/anomaly_scan/mission/alien_artifact, "count" = 1)
	)

// --- Slavers Base -> Shellguard ---
/datum/derelict_mission_config/slavers
	away_site_id = "awaysite_slavers"
	away_site_name = "Slavers Base"
	corporation_id = RND_MISSION_CORP_SHELLGUARD
	mission_type = DERELICT_MISSION_COMPLEX
	ghost_mob_count = 0
	title = "Тактический анализ"
	description = "На астероиде обнаружена база работорговцев, подвергшаяся нападению аболиционистов. Сфотографируйте укрепления, взломайте тактический терминал с помощью датаджека и кода доступа — затем сдайте чип с данными через дронпад."
	target_item_type = /obj/item/derelict_mission_sample/shellguard_data
	objective_templates = list(
		list("type" = "photograph_object", "description" = "Сфотографировать баррикады/укрепления на базе. Подать фото в R&D консоль — физическое или цифровое с флешки", "target_type" = /obj/structure/barricade, "count" = 2),
		list("type" = "study_artifact", "description" = "Взломать тактический терминал: кликнуть датаджеком на терминал, найти нужный провод через панель проводов, ввести код доступа (ищите документ рядом)", "target_type" = /obj/item/tactical_terminal, "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать диск с тактическими данными Shellguard и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/shellguard_data, "count" = 1)
	)

// ============================================================
// SIMPLE MISSIONS (small item -> drone pad)
// ============================================================

// --- Errant Pisces -> NanoTrasen ---
/datum/derelict_mission_config/errant_pisces
	away_site_id = "awaysite_errant_pisces"
	away_site_name = "XCV Ahab's Harpoon"
	corporation_id = RND_MISSION_CORP_VEYMED
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Генетика карпов"
	description = "Коммерческое рыболовное судно Xynergy было захвачено космическими карпами. Просканируйте особей и доставьте генетический образец для ксенобиологических исследований NanoTrasen."
	target_item_type = /obj/item/derelict_mission_sample/carp_genetic
	objective_templates = list(
		list("type" = "scan_object", "description" = "Просканировать космических карпов (исследовательским сканером на КПК). Загрузить RDF-файлы в R&D консоль с флешки", "target_type" = /mob/living/simple_animal/hostile/carp, "count" = 2),
		list("type" = "retrieve_item", "description" = "Упаковать генетический образец карпа и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/carp_genetic, "count" = 1)
	)

// --- Magshield -> Einstein Engines ---
/datum/derelict_mission_config/magshield
	away_site_id = "awaysite_magshield"
	away_site_name = "Orbital Shield Station"
	corporation_id = RND_MISSION_CORP_EINSTEIN
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Магнитный щит"
	description = "Орбитальная станция планетарного щита пострадала от солнечной вспышки. Установите датчик у магнитного генератора и доставьте записи частот для Einstein Engines."
	target_item_type = /obj/item/derelict_mission_sample/shield_frequency
	objective_templates = list(
		list("type" = "deploy_sensor", "description" = "Установить исследовательский датчик у магнитного генератора (активировать в руке)", "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать записи частот и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/shield_frequency, "count" = 1)
	)

// --- Spy Station -> DAIS ---
/datum/derelict_mission_config/spy_station
	away_site_id = "awaysite_spy_station"
	away_site_name = "Unknown Station"
	corporation_id = RND_MISSION_CORP_DAIS
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Разведданные SCGDF"
	description = "Обнаружена замаскированная разведывательная станция SCGDF. Сфотографируйте мониторинговые терминалы и доставьте зашифрованный диск с разведданными для DAIS."
	target_item_type = /obj/item/derelict_mission_sample/encrypted_disk
	objective_templates = list(
		list("type" = "photograph_object", "description" = "Сфотографировать мониторинговые терминалы (компьютеры). Подать фото в R&D консоль — физическое или цифровое с флешки", "target_type" = /obj/machinery/computer, "count" = 2),
		list("type" = "retrieve_item", "description" = "Упаковать зашифрованный диск и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/encrypted_disk, "count" = 1)
	)

// --- Casino -> Ward-Takahashi ---
/datum/derelict_mission_config/casino
	away_site_id = "awaysite_casino"
	away_site_name = "IPV Fortuna"
	corporation_id = RND_MISSION_CORP_WARD_TAKAHASHI
	mission_type = DERELICT_MISSION_SIMPLE
	title = "ИИ-модуль развлечений"
	description = "Пассажирский лайнер с казино дрейфует в секторе. Просканируйте игровые автоматы и доставьте ядро развлекательного ИИ для Ward-Takahashi."
	target_item_type = /obj/item/derelict_mission_sample/entertainment_ai
	objective_templates = list(
		list("type" = "scan_object", "description" = "Просканировать игровые автоматы (рулетка, однорукий бандит и др.). Загрузить RDF-файлы в R&D консоль с флешки", "target_type" = /obj/structure/casino, "count" = 2),
		list("type" = "retrieve_item", "description" = "Упаковать ядро развлекательного ИИ и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/entertainment_ai, "count" = 1)
	)

// --- Derelict Station -> Hephaestus ---
/datum/derelict_mission_config/derelict
	away_site_id = "awaysite_derelict"
	away_site_name = "Derelict Station"
	corporation_id = RND_MISSION_CORP_HEPHAESTUS
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Промышленные чертежи"
	description = "Заброшенный строительный проект орбитальной станции. Сфотографируйте незавершённые конструкции и доставьте инженерные чертежи для Hephaestus Industries."
	target_item_type = /obj/item/derelict_mission_sample/structural_blueprint
	objective_templates = list(
		list("type" = "photograph_object", "description" = "Сфотографировать конструкции/структуры на станции. Подать фото в R&D консоль — физическое или цифровое с флешки", "target_type" = /obj/structure, "count" = 2),
		list("type" = "retrieve_item", "description" = "Упаковать инженерные чертежи и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/structural_blueprint, "count" = 1)
	)

// --- Abandoned Hotel -> Morpheus ---
/datum/derelict_mission_config/abandoned_hotel
	away_site_id = "awaysite_abandoned_hotel"
	away_site_name = "Cinnamon Resort"
	corporation_id = RND_MISSION_CORP_MORPHEUS
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Системы автоматизации"
	description = "Заброшенный курорт Cinnamon Resort. Просканируйте автоматизированные системы управления и доставьте лог деградации ИИ для Morpheus Cybernetics."
	target_item_type = /obj/item/derelict_mission_sample/automation_log
	objective_templates = list(
		list("type" = "scan_object", "description" = "Просканировать автоматизированные системы (машины/механизмы). Загрузить RDF-файлы в R&D консоль с флешки", "target_type" = /obj/machinery, "count" = 2),
		list("type" = "retrieve_item", "description" = "Упаковать лог автоматизации и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/automation_log, "count" = 1)
	)

// --- Lost Supply Base -> Xion ---
/datum/derelict_mission_config/lost_supply_base
	away_site_id = "awaysite_lost_supply_base"
	away_site_name = "Supply Station"
	corporation_id = RND_MISSION_CORP_XION
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Логистические данные"
	description = "Заброшенная база снабжения. Установите исследовательский датчик для анализа инфраструктуры и доставьте манифест снабжения для Xion Industrial."
	target_item_type = /obj/item/derelict_mission_sample/supply_manifest
	objective_templates = list(
		list("type" = "deploy_sensor", "description" = "Установить исследовательский датчик для анализа инфраструктуры (активировать в руке)", "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать манифест снабжения и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/supply_manifest, "count" = 1)
	)

// --- Smugglers -> Al-Maliki ---
/datum/derelict_mission_config/smugglers
	away_site_id = "awaysite_smugglers"
	away_site_name = "Smugglers Base"
	corporation_id = RND_MISSION_CORP_ALMALIKI
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Контрабандное оружие"
	description = "Контрабандистская база на астероиде. Сфотографируйте оружейный склад и доставьте данные о модификациях оружия для Al-Maliki & Mosley."
	target_item_type = /obj/item/derelict_mission_sample/contraband_weapons
	objective_templates = list(
		list("type" = "photograph_object", "description" = "Сфотографировать оружие на базе контрабандистов. Подать фото в R&D консоль — физическое или цифровое с флешки", "target_type" = /obj/item/gun, "count" = 2),
		list("type" = "retrieve_item", "description" = "Упаковать данные об оружии и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/contraband_weapons, "count" = 1)
	)

// --- Mobius Rift -> Focal Point ---
/datum/derelict_mission_config/mobius_rift
	away_site_id = "awaysite_mobius_rift"
	away_site_name = "Mobius Rift"
	corporation_id = RND_MISSION_CORP_FOCAL
	mission_type = DERELICT_MISSION_SIMPLE
	title = "Аномальная энергия"
	description = "Астероид с неевклидовой пространственной аномалией. Установите датчик внутри аномалии и доставьте показания для Focal Point Energetics."
	target_item_type = /obj/item/derelict_mission_sample/anomaly_readings
	objective_templates = list(
		list("type" = "deploy_sensor", "description" = "Установить исследовательский датчик внутри пространственной аномалии (активировать в руке)", "count" = 1),
		list("type" = "retrieve_item", "description" = "Упаковать аномальные показания и сдать через дронпад", "target_type" = /obj/item/derelict_mission_sample/anomaly_readings, "count" = 1)
	)
