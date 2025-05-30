//SSanom
PROCESSING_SUBSYSTEM_DEF(anom)
	name = "Anomalys"
	priority = SS_PRIORITY_DEFAULT
	init_order = SS_INIT_DEFAULT
	flags = SS_BACKGROUND
	wait = 3 //Каждые три тика



	//[ВЫВОДИМАЯ СТАТИСТИКА]
	///Список всех ЯДЕР аномалий
	var/list/all_anomalies_cores = list()
	///Список всех ВСПОМОГАТЕЛЬНЫХ ЧАСТЕЙ
	var/list/all_anomalies_helpers = list()
	///Активные рассказчики
	var/list/all_storytellers = list()
	///Количество ядер
	var/anomalies_cores_in_world_amount = 0
	///Количество вспомогательных частей
	var/anomalies_helpers_in_world_amount = 0
	///Количество рассказчиков
	var/storytellers_ammount = 0
	///Количество спавнов аномалий
	var/spawn_ammount = 0
	///Количество удалений. Помогает определить эффективность генератора аномалий
	var/removed_ammount = 0
	///Количество процессингов
	var/processing_ammount = 0



	//ПОСЛЕДНИЕ ФРАЗЫ и прочее по ранениям
	var/last_attacked_message
	var/gibbed_last_message
	var/destroyed_items = 0



	//[ИНФА ПО АРТЕФАКТАМ]
	///Количество артефактов, успешно собранные игроками
	var/collected_artefacts_by_player = 0
	var/earned_cargo_points = 0
	var/earned_rnd_points = 0
	var/list/artefacts_list_in_world = list()
	var/artefacts_deleted_by_game = 0
	var/artefacts_spawned_by_game = 0
	var/interactions_with_artefacts_by_players_ammount = 0
	var/bad_interactions_with_artefacts_by_players_ammount = 0
	var/good_interactions_with_artefacts_by_players_ammount = 0
	//Большие артефакты
	var/list/big_anomaly_artefacts = list()


	//[ИНФА ПО АНОМАЛИЯМ]
	///Количество ударов электры по гуманоидам и подобным
	var/anomalies_activated_times = 0
	var/humanoids_effected_by_anomaly = 0
	var/humanoids_gibbed_by_anomaly = 0
	var/simplemobs_effected_by_anomaly = 0
	var/simplemobs_gibbed_by_anomaly = 0
	var/list/important_logs = list()

	//[ПРОЧЕЕ]
	var/list/detectors = list()
	//Сикеи что будут получать сообщения от сторителлера о своём состоянии
	var/list/debug_storyteller_listeners = list()

/datum/controller/subsystem/processing/anom/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"\
		anomalies in world:    [anomalies_cores_in_world_amount]  \
		anomaly helpers in world: [anomalies_helpers_in_world_amount]  \
		spawned times:    [spawn_ammount]  \
		removed times: [removed_ammount]  \
		objects in processing: [processing_ammount]
	"})

/datum/controller/subsystem/processing/anom/Initialize(start_uptime)
	anomalies_init()


/datum/controller/subsystem/processing/anom/proc/anomalies_init()

/datum/controller/subsystem/processing/anom/proc/add_anomaly_in_cores(obj/anomaly/input)
	LAZYADD(all_anomalies_cores, input)
	spawn_ammount++
	anomalies_cores_in_world_amount = LAZYLEN(all_anomalies_cores)

/datum/controller/subsystem/processing/anom/proc/remove_anomaly_from_cores(obj/anomaly/input)
	LAZYREMOVE(all_anomalies_cores, input)
	removed_ammount++
	anomalies_cores_in_world_amount = LAZYLEN(all_anomalies_cores)


/datum/controller/subsystem/processing/anom/proc/add_anomaly_in_helpers(obj/anomaly/input)
	LAZYADD(all_anomalies_helpers, input)
	spawn_ammount++
	anomalies_helpers_in_world_amount = LAZYLEN(all_anomalies_helpers)

/datum/controller/subsystem/processing/anom/proc/remove_anomaly_from_helpers(obj/anomaly/input)
	LAZYREMOVE(all_anomalies_helpers, input)
	removed_ammount++
	anomalies_helpers_in_world_amount = LAZYLEN(all_anomalies_helpers)

/datum/controller/subsystem/processing/anom/proc/add_storyteller(datum/planet_storyteller/input_storyteller)
	LAZYADD(all_storytellers, input_storyteller)
	storytellers_ammount = LAZYLEN(all_storytellers)

/datum/controller/subsystem/processing/anom/proc/remove_storyteller(datum/planet_storyteller/input_storyteller)
	LAZYREMOVE(all_storytellers, input_storyteller)
	storytellers_ammount = LAZYLEN(all_storytellers)

/datum/controller/subsystem/processing/anom/proc/give_gameover_text()
	var/anomaly_text
	anomaly_text += "<br><br><br><b>ANOMALY MOD STATISTIC.</b>"
	if(!last_attacked_message && !gibbed_last_message && !collected_artefacts_by_player)
		anomaly_text += "<br>Никто не рискнул ступить на аномальную планету."
		anomaly_text += "<br><a href='byond://?src=\ref[src];show_anomaly_stats=1'>\[Показать подробную статистику\]</a>"
		return anomaly_text
	if(SSanom.spawn_ammount > 0)
		//Раненные, умершие, гибнутые
		if(last_attacked_message)
			anomaly_text += "<br>[last_attacked_message]."
		else
			anomaly_text += "<br>Никто не пострадал от аномалий."

		if(gibbed_last_message)
			anomaly_text += "<br>[gibbed_last_message]."
		else
			anomaly_text += "<br>Никого не порвало от аномалии."
		anomaly_text += "<br><a href='byond://?src=\ref[src];show_anomaly_stats=1'>\[Показать подробную статистику\]</a>"
		return anomaly_text


/datum/controller/subsystem/processing/anom/Topic(href, href_list)
	..()
	if(href_list["show_anomaly_stats"])
		var/mob/user = usr
		if(!user.client)
			return
	var/HTML = "<html><body>"
	HTML += "<br><br> ANOMALIES"
	HTML += "<br>Количество аномалий на момент окончания раунда: [anomalies_cores_in_world_amount]. Мод размещал аномалии [spawn_ammount] раз, а удалял [removed_ammount] раз."
	HTML += "<br>Игра заспавнила [artefacts_spawned_by_game] артефактов, из них [artefacts_deleted_by_game] удалено. Собрано игроками артефактов: [collected_artefacts_by_player]. Всего артефактов на конец раунда: [LAZYLEN(artefacts_list_in_world)]"
	HTML +=  "<br>Аномалии были взведены [anomalies_activated_times] раз. В целом, игроки подверглись влиянию аномалий [humanoids_effected_by_anomaly] раз, а [humanoids_gibbed_by_anomaly] игроков были гибнуты. [simplemobs_effected_by_anomaly] симплмобов подверглись влиянию аномалий и [simplemobs_gibbed_by_anomaly] было гибнуто."
	HTML += "<br><br> ARTEFACTS"
	HTML += "<br>Заработано каргопоинтов за продажу артефактов: [earned_cargo_points], заработано РНД поинтов за изучение артефактов: [earned_rnd_points]"
	HTML += "<br>Всего попыток взаимодействия с артефактами: [interactions_with_artefacts_by_players_ammount], из них [good_interactions_with_artefacts_by_players_ammount] принесли пользу, а [bad_interactions_with_artefacts_by_players_ammount] принесли вред."
	HTML += "<br><br> DAMAGES"
	HTML += "<br> Люди подверглись влиянию аномалий [humanoids_effected_by_anomaly] раз, а гибнулись [humanoids_gibbed_by_anomaly] раз."
	HTML += "<br> Симплмобы подверглись влиянию аномалий [simplemobs_effected_by_anomaly] раз, а гибнулись [simplemobs_gibbed_by_anomaly] раз."


	// Открываем окно
	var/window_x = 600
	var/window_y = 400
	var/datum/browser/popup = new(usr, "anomaly_stats", "Anomaly Statistics", window_x, window_y)
	popup.set_content(HTML)
	popup.open()

/datum/controller/subsystem/processing/anom/proc/add_last_attack(mob/living/user, attack_name)
	if(!ishuman(user) && !isrobot(user))
		SSanom.simplemobs_effected_by_anomaly++
		return FALSE
	SSanom.humanoids_effected_by_anomaly++
	if(last_attacked_message)
		return FALSE //У нас уже всё записано

	var/result_text = "Первым от аномалии пострадал [user.ckey],"
	//генерируем текст причины атаки
	if(attack_name == "Электра")
		result_text += "он получил мощный электроудар."
	else if(attack_name == "Жарка")
		result_text += "его сильно обожгло."
	else if(attack_name == "Вспышка")
		result_text += "его сильно ослепило и дезеориентировало."
	else if(attack_name == "Рвач")
		result_text += "ему оторвало конечность."
	else if(attack_name == "Трамплин")
		result_text += "его с силой швырнуло."
	//а теперь генерируем последние сказанные им слова
	if(user.mind.last_words)
		result_text += "Перед этим он сказал: [user.mind.last_words]"
	else
		result_text += "Он пострадал молча."
	add_say_handle(user)
	last_attacked_message = result_text

/datum/controller/subsystem/processing/anom/proc/add_last_gibbed(mob/living/user, attack_name)
	if(!ishuman(user) && !isrobot(user))
		SSanom.simplemobs_gibbed_by_anomaly++
		return FALSE
	SSanom.humanoids_gibbed_by_anomaly++
	if(gibbed_last_message)
		return FALSE //У нас уже всё записано
	if(!user.ckey && !user.last_ckey)
		return FALSE

	var/victim_ckey
	if(!user.ckey)
		victim_ckey = user.last_ckey
	else
		victim_ckey = user.ckey

	var/result_text = "Первым гибнуло [victim_ckey]."
	//генерируем текст причины атаки
	if(attack_name == "Электра")
		result_text += "его испепелило до костей электроударом."
	else if(attack_name == "Жарка")
		result_text += "его сожгло до костей огнём."
	else if(attack_name == "Рвач")
		result_text += "его разорвало на куски."

	if(user.mind.last_words)
		result_text += "его последние слова: [user.mind.last_words]"
	else
		result_text += "Он покинул этот мир молча."

	gibbed_last_message = result_text

/datum/controller/subsystem/processing/anom/proc/AddImportantLog(input)
	if(!input)
		return
	LAZYADD(important_logs, input)

/datum/controller/subsystem/processing/anom/proc/announce_to_all_detectors_on_z_level(z_level, message, list/sound_list)
	for(var/obj/item/detector in detectors)
		if(get_z(detector) == z_level)
			detector.runechat_message(message)
		for(var/mob/living/carbon/human/human in get_turf(detector))
			to_chat(human, SPAN_NOTICE("Вы видите на экране [detector] сообщение: [message]"))
			if(sound_list)
				sound_to(human, sound(pick(sound_list), volume = 100))

//Рассказчик сам найдёт в своих закромах рассказчика с этим Z уровнем
/datum/controller/subsystem/processing/anom/proc/add_points_to_storyteller(input_z_level, points_ammout, points_type, source)
	if(!points_type || !points_ammout)
		CRASH("Контроллер получил пустые points_type или points_ammout при попытке добавить очков рассказчику")
	if(!LAZYLEN(all_storytellers))
		return //В игре пока нет рассказчиков
	var/datum/planet_storyteller/picked_storyteller
	if(input_z_level)
		for(var/datum/planet_storyteller/picked in all_storytellers)
			if(input_z_level in picked.my_z)
				picked_storyteller = picked
				break
	else
		picked_storyteller = pick(all_storytellers)
	if(points_type == "evolution")
		picked_storyteller.add_points(evolution = points_ammout)
	if(points_type == "scam")
		picked_storyteller.add_points(scam = points_ammout)
	else if(points_type == "anomaly")
		picked_storyteller.add_points(anomaly = points_ammout)
	else if(points_type == "mob")
		picked_storyteller.add_points(mob = points_ammout)
	picked_storyteller.log_point_getting(points_ammout, points_type, source)

//Создадим сигнал который перехватит у мобика 1 раз его say() чтоб узнать что он скажет ПОСЛЕ удара аномалии
/datum/controller/subsystem/processing/anom/proc/add_say_handle(mob/living/user)
	RegisterSignal(user, COMSIG_MOB_SAYED, PROC_REF(add_after_damage_say))

/datum/controller/subsystem/processing/anom/proc/add_after_damage_say(mob/living/user, message)
	last_attacked_message += "<br> А после этого сказал: [message]"
	UnregisterSignal(user, COMSIG_MOB_SAYED)
