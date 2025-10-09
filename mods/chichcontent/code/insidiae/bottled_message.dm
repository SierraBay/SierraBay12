/obj/item/stock_parts/computer/hard_drive/bottled_message

/obj/item/stock_parts/computer/hard_drive/bottled_message/Initialize()
	. = ..()
	save_file(new/datum/computer_file/data/text/bottled_message(src))

/datum/computer_file/data/text/bottled_message
	filename = "diary"
	stored_data = {"123123123123123 \[daislogo]"}
