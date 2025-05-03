//Детектор что-то говорит
/obj/item/clothing/gloves/anomaly_detector/proc/say_message(input_message)
	runechat_message(input_message, 7)
	visible_message(input_message, range = 7)
