//Задача руины - быть стартовой площадкой для тестеров
/datum/map_template/ruin/exoplanet/playtest_anomaly
	name = "PLAYTEST ANOMALY RUINA"
	id = "planetsite_anomalies_playtest"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/test.dmm')
	spawn_cost = 999
	ruin_tags = RUIN_CHUDO_ANOMALIES

/area/map_template/playtest_anomaly
	name = "\improper PLAYTEST"
	icon_state = "A"
	requires_power = 0
	dynamic_lighting = 0

//Штука на которую нажимают призраки и подключаются к игре
/obj/structute/join_the_playtest
	name = "ПРИСОЕДИНИТЬСЯ К ПЛЕЙТЕСТУ"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "portal"
	invisibility = 60

/obj/structute/join_the_playtest/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structute/join_the_playtest/Click(location, control, params)
	if(isghost(usr) || isobserver(usr))
		var/result = alert(usr, "Присоединиться к плей тесту?", "Думой", "Да🏊‍♀️", "Нет, посижу в гостах")
		if(result == "Нет, посижу в гостах")
			return
		else if(result == "Да🏊‍♀️")
			spawn_new_tester()

/obj/structute/join_the_playtest/proc/spawn_new_tester()
	var/name = input("Имя кукле дай", "Имечко") as text|null
	var/mob/living/carbon/human/H = new(get_turf(src))
	H.name = name
	H.key = usr.key
	qdel(usr)
