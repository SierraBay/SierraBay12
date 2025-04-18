/datum/storyteller_ability/spawn_fake_anomaly
	ability_name = "Спавн фейковой аномалии"
	ability_desc = "Создаёт аномалию которую видно на детекторе, но империческим путём её не существует."
	proc_chance = 33	  // Базовый шанс вызова способности (0-100)
	point_price = 50	 // Стоимость в очках
	point_type = "scam"
	var/list/possible_fake_anomalies = list()

/datum/storyteller_ability/spawn_fake_anomaly/electra_ice
	possible_fake_anomalies = list(
		/obj/fake_anomaly/electra
	)

/datum/storyteller_ability/spawn_fake_anomaly/execute(input_turf)
	var/fake_anomaly_path = pick(possible_fake_anomalies)
	new fake_anomaly_path(input_turf)
	. = ..()


/datum/storyteller_ability/spawn_fake_anomaly/gravi

/datum/storyteller_ability/spawn_fake_anomaly/water

//Это ложная аномалия, она никак не влияет на игроков, её задача - улавливаться детектором чтоб запутать
//игрока
/obj/fake_anomaly
	name = "Мираж"
	anchored = TRUE
	invisibility = 60
	icon = 'mods/anomaly/icons/detection_icon.dmi'
	icon_state = "tesla_first_detection"

/obj/fake_anomaly/proc/get_detection_icon()
	return icon_state

/obj/fake_anomaly/electra
	name = "Электрический мираж"
	icon = 'mods/anomaly/icons/detection_icon.dmi'
	icon_state = "tesla_first_detection"

/obj/fake_anomaly/electra/get_detection_icon()
	return pick(list("tesla_first_detection", "tesla_second_detection", "electra_detection"))
