/obj/screen/screen_text_shit
	icon = null
	icon_state = ""
	name = ""
	screen_loc = "CENTER-9, CENTER"
	layer = HUD_BASE_LAYER+0.02
	plane = HUD_PLANE
	alpha = 0
	var/list/current_words_list = list()
	var/result_phrase
	var/deleted_by_external = FALSE
	var/text_color = "#ff3333"
	var/shrift = "Verdana"
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	var/delay_between_inputing_words = 0.1 SECONDS
	var/delay_between_erasing_words = 0.05 SECONDS

/client/proc/play_screentext_on_client_screen(input_text = "AHTUNG RAZRAB DAUN сообщите разработчику", holding_on_screen_time = 5 SECONDS, need_output_every_word = TRUE, delay_between_words = 0.1 SECONDS, text_color = "#ff3333", input_shrift = "Verdana", clear_screen = TRUE)
	set waitfor = FALSE
	if(clear_screen)
		for(var/obj/screen/screen_text_shit/detected_screen in screen)
			detected_screen.deleted_by_external = TRUE
			qdel(detected_screen)
	var/obj/screen/screen_text_shit/T = new()
	T.text_color = text_color
	T.shrift = input_shrift
	T.delay_between_inputing_words = delay_between_words
	T.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	screen += T
	T.maptext_width = 500
	T.maptext_height = 200
	T.maptext_x = 64
	T.maptext_y = 32

	animate(T, alpha = 255, time = 10, easing = EASE_IN)
	if(need_output_every_word)
		if(T.deleted_by_external)
			screen -= T
			return
		var/list/words_list = convert_phrase_to_words(input_text)
		for(var/word in words_list)
			LAZYADD(T.current_words_list, word)
			T.result_phrase = T.current_words_list.Join(T.current_words_list, "")
			T.maptext = "<span style='vertical-align:top; text-align:center; color: [T.text_color]; font-size: 300%; text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black; font-family: [T.shrift], \"Pterra\";'>[T.result_phrase]</span>"
			sleep(delay_between_words)
	else
		T.maptext = "<span style='vertical-align:top; text-align:center; color: [T.text_color]; font-size: 300%; text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black; font-family: [T.shrift], \"Pterra\";'>[input_text]</span>"

	addtimer(new Callback(src, PROC_REF(smooth_delete_screentext_from_client_screen), T, TRUE), holding_on_screen_time)

/client/proc/smooth_delete_screentext_from_client_screen(obj/screen/screen_text_shit/input_screen, word_erasing = FALSE)
	if(!input_screen)
		return
	if(word_erasing)
		var/list/words_to_remove = input_screen.current_words_list.Copy()
		for(var/i = length(words_to_remove), i >= 1, i--)
			if(input_screen.deleted_by_external)
				break
			input_screen.current_words_list.Cut(i)
			input_screen.result_phrase = input_screen.current_words_list.Join("")
			input_screen.maptext = "<span style='vertical-align:top; text-align:center; color: [input_screen.text_color]; font-size: 300%; text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black; font-family: [input_screen.shrift], \"Pterra\";'>[input_screen.result_phrase]</span>"
			sleep(input_screen.delay_between_erasing_words)
	else
		animate(input_screen, alpha = 0, time = 10, easing = EASE_OUT)
		sleep(11)
	if(screen && input_screen)
		screen -= input_screen
		qdel(input_screen)

/proc/convert_phrase_to_words(input_string)
	if(!input_string)
		return FALSE
	var/list/words = list()
	var/length = length(input_string)
	for(var/i = 1, i <= length, i++)
		var/char = copytext_char(input_string, i, i + 1)
		words += char
	return words

/*
* time - время в тиках (1/10 секунды), которое будет отображаться в таймере (формат ММ:СС)
* text_color - цвет текста
* input_shrift - шрифт
* delete_after_time - если указано, таймер исчезнет с экрана через это время (в тиках)
*/
/client/proc/start_counting_back_on_screen(time = 10 SECONDS, text_color = "#ff3333", input_shrift = "Verdana", delete_after_time)
	set waitfor = FALSE

	var/obj/screen/screen_text_shit/T = new()
	T.text_color = text_color
	T.shrift = input_shrift
	T.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	T.alpha = 255

	T.maptext_width = 500
	T.maptext_height = 200
	T.maptext_x = 64
	T.maptext_y = 32

	screen += T
	animate(T, alpha = 255, time = 5, easing = EASE_IN)

	var/end_time = world.time + time
	var/delete_time = delete_after_time ? (world.time + delete_after_time) : null

	while(world.time < end_time)
		if(QDELETED(T) || (delete_time && world.time >= delete_time))
			break

		var/remaining_ticks = end_time - world.time
		var/remaining_seconds = round(remaining_ticks / 10) // Конвертируем тики в секунды

		var/mins = floor(remaining_seconds / 60)
		var/secs = remaining_seconds % 60
		var/mins_text = mins < 10 ? "0[mins]" : "[mins]"
		var/secs_text = secs < 10 ? "0[secs]" : "[secs]"

		T.maptext = "<span style='vertical-align:top; text-align:center; color: [text_color]; font-size: 300%; text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black; font-family: [input_shrift], \"Pterra\";'>[mins_text]:[secs_text]</span>"

		sleep(1 SECOND)

	// Плавное исчезновение
	if(!QDELETED(T) && screen)
		animate(T, alpha = 0, time = 5, easing = EASE_OUT)
		sleep(5)
		screen -= T
		qdel(T)
