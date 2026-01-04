/datum/controller/subsystem/processing/anom/proc/Show_weather_UI(list/input_html, mob/living/user)
	draw_main_buttons(input_list = input_html, weather_choosed = TRUE)
	for(var/datum/weather_manager/weather in SSweatherold.weather_managers_in_world)
		input_html += "<br> Погода: [weather.weather_name]."

		if(istype(weather, /datum/weather_manager/titan_rain))
			var/datum/weather_manager/titan_rain/my_weather = weather
			input_html += "<br>Статус отсчёта титана: [my_weather.counting_started == TRUE ? "АКТИВНА" : "НЕАКТИВНА"]"
			if(my_weather.have_cunami_ang_changes)
				input_html += "Время/стадий до цунами: [my_weather.remain_power_ups * 15] Минут/ [my_weather.remain_power_ups] усилений."
			input_html += "[MULTI_BTN("delete_weather", "\ref[weather]", "Погода", "Удалить погоду")] [MULTI_BTN("change_power_ups", "\ref[weather]", "Погода", "Изменить количество усиления")]"
			input_html += "[MULTI_BTN("change_weather_stage", "\ref[weather]", "Спокойная", "Спокойная погода")] [MULTI_BTN("change_weather_stage", "\ref[weather]", "Дождь", "Дождь")] [MULTI_BTN("start_blowout", "\ref[my_weather]", "Погода", "Начать цунами")]"
		else if(istype(weather, /datum/weather_manager/snow))
			if(weather.can_blowout)
				input_html += "Время/стадий до выброса: [weather.remain_power_ups * 15] Минут/ [weather.remain_power_ups] усилений. Следущее усиление через: [(weather.change_time - world.time)/10] секунд"
			input_html += "[MULTI_BTN("delete_weather", "\ref[weather]", "Погода", "Удалить погоду")] [MULTI_BTN("change_power_ups", "\ref[weather]", "Погода", "Изменить количество усиления")]"
			input_html += "[MULTI_BTN("change_weather_stage", "\ref[weather]", "Спокойная", "Спокойная погода")] [MULTI_BTN("change_weather_stage", "\ref[weather]", "Лёгкий снег", "Лёгкий снег")] [MULTI_BTN("change_weather_stage", "\ref[weather]", "Буран", "Буран")] [MULTI_BTN("start_blowout", "\ref[weather]", "Погода", "Начать белую мглу")]"
