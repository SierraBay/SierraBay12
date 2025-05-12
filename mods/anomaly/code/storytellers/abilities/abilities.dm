//Обманные
#include "_scam\fake_anomaly.dm"
#include "anomaly\spawn_anomaly.dm"
#include "mob\spawn_mobs.dm"

/datum/storyteller_ability
	var/ability_name = "Без названия"
	var/ability_desc = "Без описания"
	var/turf/start_turf
	var/proc_chance = 0	  // Базовый шанс вызова способности (0-100)
	var/point_price = 50	 // Стоимость в очках
	var/point_type		  // Тип очков (SCAM/ANOMALY/MOB)
	var/datum/planet_storyteller/owner

	// Категории способностей
	var/ability_category = null

/datum/storyteller_ability/New(datum/planet_storyteller/storyteller, turf/input_turf)
	if(!storyteller)
		return FALSE

	owner = storyteller
	if(input_turf && isturf(input_turf))
		start_turf = input_turf

/datum/storyteller_ability/proc/execute(input_turf)
	// Вызывайте родителя в каждой функции
	qdel(src)
	return TRUE

//Очистка от невалидной зоны
/datum/storyteller_ability/proc/clean_unplayable_storyteller_zones(list/turfs_for_spawn, area/good_area)
	for(var/turf/T in turfs_for_spawn)
		if(T.loc != good_area)
			LAZYREMOVE(turfs_for_spawn, src)

//Очистка от неиграбельных турфов
/datum/storyteller_ability/proc/clean_from_unplayable_turfs(list/turfs_for_spawn)
	for(var/turf/T in turfs_for_spawn)
		if(TurfBlocked(loc = T, space_allowed = FALSE) || TurfBlockedByAnomaly(T) || locate(/mob/living/carbon/human) in T)
			LAZYREMOVE(turfs_for_spawn, T)

//Очищает от турфов которые находятся в поле зрения игроков
//turfs_for_spawn - турфы которые мы очищаем от видимых игроками турфов
//victims - мобы на которых мы и смотрим, нам интересно не попасть на только их глаза
/datum/storyteller_ability/proc/clean_from_visibled_turfs(list/turfs_for_spawn, list/victims)
	if(!LAZYLEN(victims) || !LAZYLEN(turfs_for_spawn))
		CRASH("clean_from_visibled_turfs получил некоректные данные.")
	//Основной цикл поиска хороших турфов
	for(var/turf/T in turfs_for_spawn)
		var/list/temp_list = oviewers(10, T)
		for(var/atom/I in victims)
			if(I in temp_list)
				LAZYREMOVE(turfs_for_spawn, T)
			else if(get_turf(I) == T)
				LAZYREMOVE(turfs_for_spawn, T)

///Просто собирает всех мобиков на Z уровне
/datum/storyteller_ability/proc/collect_possible_victims_classic()
	var/list/temp_list = list()
	for(var/mob/living/carbon/human/human in GLOB.living_players)
		if(get_z(human) in owner.my_z)
			LAZYADD(temp_list, human)
	return temp_list
