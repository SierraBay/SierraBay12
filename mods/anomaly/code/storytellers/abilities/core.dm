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
