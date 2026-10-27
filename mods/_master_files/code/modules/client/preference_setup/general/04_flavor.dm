// Donor TGUI dialogs, retaining Sierra character and loadout mechanics.
/datum/category_item/player_setup_item/physical/flavor/OnTopic(href,list/href_list, mob/user)
	if(href_list["flavor_text"])
		switch(href_list["flavor_text"])
			if("open")
			if("general")
				var/msg = sanitize(tgui_input_text(usr, "Give a general description of your character. This will be shown regardless of clothing. Do not include OOC information here.", "Flavor Text", html_decode(pref.flavor_texts[href_list["flavor_text"]]), multiline = TRUE, encode = FALSE), extra = 0)
				if(CanUseTopic(user))
					pref.flavor_texts[href_list["flavor_text"]] = msg
			else
				var/msg = sanitize(tgui_input_text(usr, "Set the flavor text for your [href_list["flavor_text"]].", "Flavor Text", html_decode(pref.flavor_texts[href_list["flavor_text"]]), multiline = TRUE, encode = FALSE), extra = 0)
				if(CanUseTopic(user))
					pref.flavor_texts[href_list["flavor_text"]] = msg
		SetFlavorText(user)
		return TOPIC_HANDLED

	else if(href_list["flavour_text_robot"])
		switch(href_list["flavour_text_robot"])
			if("open")
			if("Default")
				var/msg = sanitize(tgui_input_text(usr, "Set the default flavour text for your robot. It will be used for any module without individual setting.", "Flavour Text", html_decode(pref.flavour_texts_robot["Default"]), multiline = TRUE, encode = FALSE), extra = 0)
				if(CanUseTopic(user))
					pref.flavour_texts_robot[href_list["flavour_text_robot"]] = msg
			else
				var/msg = sanitize(tgui_input_text(usr, "Set the flavour text for your robot with [href_list["flavour_text_robot"]] module. If you leave this empty, default flavour text will be used for this module.", "Flavour Text", html_decode(pref.flavour_texts_robot[href_list["flavour_text_robot"]]), multiline = TRUE, encode = FALSE), extra = 0)
				if(CanUseTopic(user))
					pref.flavour_texts_robot[href_list["flavour_text_robot"]] = msg
		SetFlavourTextRobot(user)
		return TOPIC_HANDLED

	return ..()

