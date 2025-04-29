/datum/map/dev/setup_map()
	..()
	system_name = "Зазеркалье"
	minor_announcement = new(new_sound = sound(ANNOUNCER_COMMANDREPORT, volume = 45))

/datum/map/dev/map_info(victim)
	to_chat(victim, "<h2>Информация о карте</h2>")
	to_chat(victim, "Игра запущена в режиме разработки.")
	to_chat(victim, "На этой карте расположено лишь всё самое нужное для разработки, от чего скорость компиляции составляет сущие копейки.")
	to_chat(victim, "Разработчик: Shegar")
