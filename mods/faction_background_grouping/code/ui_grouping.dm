/datum/category_item/player_setup_item/background/culture
	var/list/current_pages = list()

/datum/category_item/player_setup_item/background/culture/content()
	. = list()
	for(var/token in tokens)
		var/singleton/cultural_info/culture = SSculture.get_culture(pref.cultural_info[token])
		var/title = "<a href='byond://?src=\ref[src];expand_options_[token]=1'>[tokens[token]]</a><b>- </b>"
		var/append_text = "<a href='byond://?src=\ref[src];toggle_verbose_[token]=1'>[hidden[token] ? "Расширить" : "Скрыть"]</a>"

		. += culture.get_description(title, append_text, verbose = !hidden[token])

		if (expanded[token])
			var/list/valid_values

			var/singleton/species/S = GLOB.species_by_name[pref.species];
			if(!S)
				valid_values = list()
			else if(S.force_cultural_info[token])
				valid_values = list(S.force_cultural_info[token] = TRUE)
			else
				valid_values = list()
				for(var/cul in S.available_cultural_info[token])
					valid_values[cul] = TRUE

			if (!hidden[token])
				. += "<br>"

			// Использование токенов для распределения "культур" и "мест жительства"
			if(token == TAG_CULTURE || token == TAG_HOMEWORLD)
				var/p = current_pages[token] || 1

				var/list/grouped_cultures = list(
					FACTION_SOL_CENTRAL = list(),
					FACTION_INDIE_CONFED = list(),
					"Others" = list()
				)

				for (var/V in valid_values)
					var/singleton/cultural_info/VCulture = SSculture.get_culture(V)
					var/fact = (VCulture && VCulture.faction) ? VCulture.faction : "Others"
					if(fact != FACTION_SOL_CENTRAL && fact != FACTION_INDIE_CONFED)
						fact = "Others"
					grouped_cultures[fact] += V

				var/list/page_names = list(
					"Центральное Правительство Солнечной Системы",
					"Гильгамешская Колониальная Конфедерация",
					"Остальные"
				)
				var/list/page_keys = list(FACTION_SOL_CENTRAL, FACTION_INDIE_CONFED, "Others")

				. += "<table width=100% style='border: 1px solid #555; padding: 5px; background: #222;'>"
				. += "<tr><td align='center'>"

				for(var/i=1; i<=3; i++)
					if(i == p)
						. += "<b>[page_names[i]]</b> "
					else
						. += "<a href='byond://?src=\ref[src];set_page_[token]=[i]'>[page_names[i]]</a> "
					if(i < 3) . += " | "

				. += "</td></tr>"
				. += "<tr><td><hr></td></tr>"

				// Указатель на текущий выбранный вариант
				var/current_fact_key = page_keys[p]
				. += "<tr><td>"
				if(!LAZYLEN(grouped_cultures[current_fact_key]))
					. += "<i>В данной категории нет доступных вариантов для выбранной расы.</i>"
				else
					for (var/V in grouped_cultures[current_fact_key])
						var/sanitized_value = html_encode(replacetext(V, "+", "PLUS"))
						var/singleton/cultural_info/VCulture = SSculture.get_culture(V)
						if(VCulture)
							if (pref.cultural_info[token] == V)
								. += "[SPAN_CLASS("linkOn", "[VCulture.get_nickname()]")] "
							else
								. += "<a href='byond://?src=\ref[src];set_token_entry_[token]=[sanitized_value]'>[VCulture.get_nickname()]</a> "
				. += "</td></tr></table>"
			else
				// Normal flat list for Faction, Beliefs, etc.
				. += "<table width=100%><tr><td colspan=3>"
				for (var/V in valid_values)
					var/sanitized_value = html_encode(replacetext(V, "+", "PLUS"))
					var/singleton/cultural_info/VCulture = SSculture.get_culture(V)
					if(VCulture)
						if (pref.cultural_info[token] == V)
							. += "[SPAN_CLASS("linkOn", "[VCulture.get_nickname()]")] "
						else
							. += "<a href='byond://?src=\ref[src];set_token_entry_[token]=[sanitized_value]'>[VCulture.get_nickname()]</a> "
				. += "</td></tr></table>"
		. += "<hr>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/background/culture/OnTopic(href,list/href_list, mob/user)
	for(var/token in tokens)
		if(href_list["set_page_[token]"])
			current_pages[token] = text2num(href_list["set_page_[token]"])
			return TOPIC_REFRESH

	. = ..()
