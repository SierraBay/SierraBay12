/datum/category_item/player_setup_item/physical/runechat
	name = "Persistence"
	sort_order = 7

/datum/preferences
	var/chat_color

/datum/category_item/player_setup_item/physical/runechat/content()
	. = list()
	. += "[TBTN("chat_color_change", pref.chat_color || "Random", "Runechat color")] [COLOR_PREVIEW(pref.chat_color || "#101010")]"
	. = jointext(., null)

/datum/category_item/player_setup_item/physical/runechat/OnTopic(href, list/href_list, mob/user)
	if (href_list["chat_color_change"])
		var/new_color = input(user, "Choose your character's text color:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.chat_color) as color|null

		var/list/hsl = rgb2num(new_color, COLORSPACE_HSL)
		if(LAZYACCESS(hsl, 3) < 50)
			hsl[3] = 50
			new_color = rgb(LAZYACCESS(hsl, 1), LAZYACCESS(hsl, 2), LAZYACCESS(hsl, 3), , COLORSPACE_HSL)

		pref.chat_color = new_color
		return TOPIC_REFRESH

/datum/category_item/player_setup_item/physical/runechat/save_character(datum/pref_record_writer/W)
	W.write("chat_color", pref.chat_color)

/datum/category_item/player_setup_item/physical/runechat/load_character(datum/pref_record_reader/R)
	pref.chat_color = R.read("chat_color")
