//уох бля
/obj/screen/screen_text_shit
	icon = null
	icon_state = ""
	name = ""
	screen_loc = "CENTER-9, CENTER"
	layer = HUD_BASE_LAYER+0.02
	plane = HUD_PLANE
	alpha = 0
	var/deleted_by_external = FALSE

/client/proc/play_screentext_on_client_screen(input_text = "AHTUNG RAZRAB DAUN сообщите разработчику", holding_on_screen_time = 5 SECONDS, need_output_every_word = TRUE, delay_between_words = 0.1 SECONDS, text_color = "#ff3333", input_shrift = "Verdana", clear_screen = TRUE)
	set waitfor = FALSE
	if(clear_screen)
		for(var/obj/screen/screen_text_shit/detected_screen in screen)
			detected_screen.deleted_by_external = TRUE
			qdel(detected_screen)
	var/obj/screen/screen_text_shit/T = new()
	screen += T
	T.maptext_width = 500
	T.maptext_height = 200
	T.maptext_x = 64
	T.maptext_y = 32
	//Нам нужно вывести предложение по буковкам
	animate(T, alpha = 255, time = 10, easing = EASE_IN)
	if(need_output_every_word)
		if(T.deleted_by_external)
			screen -= T
			return
		var/list/words_list = convert_phrase_to_words(input_text)
		var/list/current_words_list = list()
		var/result_phrase
		for(var/word in words_list)
			LAZYADD(current_words_list, word)
			result_phrase = current_words_list.Join(current_words_list, "")
			T.maptext = {"<span style='vertical-align:top; text-align:center;
				color: [text_color]; font-size: 300%;
				text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black;
				font-family: [input_shrift], "Pterra";'>[result_phrase]</span>"}
			sleep(delay_between_words)

	else
		T.maptext = {"<span style='vertical-align:top; text-align:center;
			color: [text_color]; font-size: 300%;
			text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black;
			font-family: [input_shrift], "Pterra";'>[input_text]</span>"}
	addtimer(new Callback(src, PROC_REF(smooth_delete_screentext_from_client_screen), T), holding_on_screen_time)

/client/proc/smooth_delete_screentext_from_client_screen(obj/screen/screen_text_shit/input_screen)
	if(!input_screen) //А экранчик то нам уже удалили
		return
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
		var/char = copytext_char(input_string, i, i + 1) // Извлекаем символ по индексу
		words += char // Добавляем символ в список
	return words
