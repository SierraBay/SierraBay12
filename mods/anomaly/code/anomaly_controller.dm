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
	///Количество ядер
	var/anomalies_cores_in_world_amount = 0
	///Количество вспомогательных частей
	var/anomalies_helpers_in_world_amount = 0
	///Количество спавнов аномалий
	var/spawn_ammount = 0
	///Количество удалений. Помогает определить эффективность генератора аномалий
	var/removed_ammount = 0
	///Количество процессингов
	var/processing_ammount = 0



	//ПОСЛЕДНИЕ ФРАЗЫ
	var/last_attacked_message
	var/gibbed_last_message



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



	//[ИНФА ПО АНОМАЛИЯМ]
	///Количество ударов электры по гуманоидам и подобным
	var/anomalies_activated_times = 0
	var/humanoids_effected_by_anomaly = 0
	var/humanoids_gibbed_by_anomaly = 0
	var/simplemobs_effected_by_anomaly = 0
	var/simplemobs_gibbed_by_anomaly = 0

	var/list/important_logs = list()

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
	anomalies_cores_in_world_amount++

/datum/controller/subsystem/processing/anom/proc/remove_anomaly_from_cores(obj/anomaly/input)
	LAZYREMOVE(all_anomalies_cores, input)
	removed_ammount++
	anomalies_cores_in_world_amount--


/datum/controller/subsystem/processing/anom/proc/add_anomaly_in_helpers(obj/anomaly/input)
	LAZYADD(all_anomalies_helpers, input)
	spawn_ammount++
	anomalies_helpers_in_world_amount++

/datum/controller/subsystem/processing/anom/proc/remove_anomaly_from_helpers(obj/anomaly/input)
	LAZYREMOVE(all_anomalies_helpers, input)
	removed_ammount++
	anomalies_helpers_in_world_amount--



/datum/controller/subsystem/processing/anom/proc/give_gameover_text()
	if(SSanom.spawn_ammount > 0)
		var/anomaly_text
		anomaly_text += "<br><br><br><b>ANOMALY MOD STATISTIC.</b>"
		anomaly_text += "<br>Количество аномалий на момент окончания раунда: [anomalies_cores_in_world_amount]. Мод размещал аномалии [spawn_ammount] раз, а удалял [removed_ammount] раз."
		//Арты
		anomaly_text += "<br>Игра заспавнила [artefacts_spawned_by_game] артефактов, из них [artefacts_deleted_by_game] удалено. Собрано игроками артефактов: [collected_artefacts_by_player]. Всего артефактов на конец раунда: [LAZYLEN(artefacts_list_in_world)]"
		anomaly_text += "<br>Заработано каргопоинтов за продажу артефактов: [earned_cargo_points], заработано РНД поинтов за изучение артефактов: [earned_rnd_points]"
		anomaly_text += "<br>Всего попыток взаимодействия с артефактами [interactions_with_artefacts_by_players_ammount], из них [good_interactions_with_artefacts_by_players_ammount] принесли пользу, а [bad_interactions_with_artefacts_by_players_ammount] - вред."
		//Сработало аномок
		//Электра
		anomaly_text += "<br>Аномалии были взведены [anomalies_activated_times] Раз. В целом, игроки подверглись влиянию аномалий [humanoids_effected_by_anomaly] раз, а [humanoids_gibbed_by_anomaly] игроков были гибнуты. [simplemobs_effected_by_anomaly] симплмобов подверглись влиянию аномалий и [simplemobs_gibbed_by_anomaly] было гибнуто."
		//Раненные, умершие, гибнутые
		if(last_attacked_message)
			anomaly_text += "<br><b>[last_attacked_message].</b>"
		else
			anomaly_text += "<br><b>Никто не пострадал от аномалий.</b>"

		if(gibbed_last_message)
			anomaly_text += "<br><b>[gibbed_last_message].</b>"
		else
			anomaly_text += "<br><b>Никого не порвало от аномалии.</b>"
		return anomaly_text

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
		result_text += "его разорвало на куски гравианомалией."

	if(user.mind.last_words)
		result_text += "его последние слова: [user.mind.last_words]"
	else
		result_text += "Он покинул этот мир молча."

	gibbed_last_message = result_text
