// Donor TGUI dialogs, retaining Sierra character and loadout mechanics.
/datum/category_item/player_setup_item/physical/body/OnTopic(href,list/href_list, mob/user)
	var/singleton/species/mob_species = GLOB.species_by_name[pref.species]
	// [SIERRA-ADD] CHARACTER_PERSIST
	if(pref.character_persist_is_locked() && !href_list["toggle_species_verbose"] && !href_list["show_species"])
		to_chat(user, SPAN_WARNING("Внешность заблокирована: у персонажа есть сохранённое состояние с прошлой смены. Отключите персистентность, чтобы сбросить его."))
		return TOPIC_NOACTION
	// [/SIERRA-ADD]

	if(href_list["toggle_species_verbose"])
		hide_species = !hide_species
		return TOPIC_REFRESH

	else if(href_list["gender"])
		mob_species = GLOB.species_by_name[pref.species]
		var/new_gender = tgui_input_list(user, "Choose your character's bodytype:", CHARACTER_PREFERENCE_INPUT_TITLE, mob_species.genders, pref.gender)
		if(new_gender && CanUseTopic(user) && (new_gender in mob_species.genders))
			pref.gender = new_gender
			if(!(pref.facial_hair_style in mob_species.get_facial_hair_styles(pref.gender)))
				ResetFacialHair()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["age"])
		var/new_age = tgui_input_number(user, "Choose your character's age:\n([mob_species.min_age]-[mob_species.max_age])", CHARACTER_PREFERENCE_INPUT_TITLE, pref.age, max_value = INFINITY, min_value = -INFINITY, round_value = FALSE)
		if(new_age && CanUseTopic(user))
			pref.age = max(min(round(text2num(new_age)), mob_species.max_age), mob_species.min_age)
			for(var/datum/preferences_slot/slot in pref.slot_priority_list)
				if(slot.slot != pref.default_slot)
					continue
				slot.age = pref.age
			pref.skills_allocated = pref.sanitize_skills(pref.skills_allocated)		// The age may invalidate skill loadouts
			return TOPIC_REFRESH

	else if(href_list["random"])
		pref.randomize_appearance_and_body_for()
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["pronouns"])
		var/new_pronouns = tgui_input_list(user, "Choose your character's pronouns:", CHARACTER_PREFERENCE_INPUT_TITLE, mob_species.pronouns, pref.pronouns)
		mob_species = GLOB.species_by_name[pref.species]
		if(new_pronouns && CanUseTopic(user) && (new_pronouns in mob_species.pronouns))
			pref.pronouns = new_pronouns
		return TOPIC_REFRESH

	else if(href_list["change_descriptor"])
		if(mob_species.descriptors)
			var/desc_id = href_list["change_descriptor"]
			if(pref.body_descriptors[desc_id])
				var/datum/mob_descriptor/descriptor = mob_species.descriptors[desc_id]
	//[SIERRA-EDIT] HEIGHT
				var/choice = tgui_input_list(user, "Please select a descriptor.", "Descriptor", descriptor.chargen_value_descriptors, null)
				if(choice && mob_species.descriptors[desc_id])
					pref.body_descriptors[desc_id] = descriptor.chargen_value_descriptors[choice]
				if(desc_id == "height")
					var/idx = pref.body_descriptors["height"]
					if(idx && idx <= length(GLOB.heights_list))
						pref.height = GLOB.heights_list[idx]
				return TOPIC_REFRESH_UPDATE_PREVIEW
	//[/SIERRA-EDIT] HEIGHT

	else if(href_list["blood_type"])
		var/new_b_type = tgui_input_list(user, "Choose your character's blood-type:", CHARACTER_PREFERENCE_INPUT_TITLE, valid_bloodtypes, null)
		if(new_b_type && CanUseTopic(user))
			pref.b_type = new_b_type
			return TOPIC_REFRESH

	else if(href_list["show_species"])
		var/choice = tgui_input_list(user, "Which species would you like to look at?", null, GLOB.playable_species, null)
		if(choice)
			var/singleton/species/current_species = GLOB.species_by_name[choice]
			show_browser(user, current_species.get_description(), "window=species;size=700x400")
			return TOPIC_HANDLED

	else if(href_list["set_species"])

		var/list/species_to_pick = list()
		for(var/species in GLOB.playable_species)
			if(!GLOB.skip_allow_lists && !check_rights(R_ADMIN, 0) && config.usealienwhitelist)
				var/singleton/species/current_species = GLOB.species_by_name[species]
				if(!(current_species.spawn_flags & SPECIES_CAN_JOIN))
					continue
				else if((current_species.spawn_flags & SPECIES_IS_WHITELISTED) && !is_alien_whitelisted(preference_mob(),current_species))
					continue
			species_to_pick += species

		var/choice = tgui_input_list(user, "Select a species to play as.", null, species_to_pick, null)
		if(!choice || !(choice in GLOB.species_by_name))
			return

		var/prev_species = pref.species
		pref.species = choice
		if(prev_species != pref.species)
			mob_species = GLOB.species_by_name[pref.species]
			if(!(pref.gender in mob_species.genders))
				pref.gender = mob_species.genders[1]
			if(!(pref.pronouns in mob_species.pronouns))
				pref.pronouns = mob_species.pronouns[1]

			ResetAllHair()

			//reset hair colour and skin colour
			pref.head_hair_color = "#000000"
			pref.skin_tone = 0
			pref.age = max(min(pref.age, mob_species.max_age), mob_species.min_age)

			reset_limbs() // Safety for species with incompatible manufacturers; easier than trying to do it case by case.
			pref.body_markings.Cut() // Basically same as above.
			pref.picked_traits.Cut()

			prune_occupation_prefs()
			pref.skills_allocated = pref.sanitize_skills(pref.skills_allocated)

			pref.cultural_info = mob_species.default_cultural_info.Copy()

			sanitize_organs()

			if(!HasAppearanceFlag(GLOB.species_by_name[pref.species], SPECIES_APPEARANCE_HAS_UNDERWEAR))
				pref.all_underwear.Cut()

			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["hair_color"])
		if(!HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_HAIR_COLOR))
			return TOPIC_NOACTION
		var/new_hair = input(user, "Choose your character's hair colour:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.head_hair_color) as color|null
		if(new_hair && HasAppearanceFlag(GLOB.species_by_name[pref.species], SPECIES_APPEARANCE_HAS_HAIR_COLOR) && CanUseTopic(user))
			pref.head_hair_color = new_hair
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["hair_style"])
		var/list/valid_hairstyles = mob_species.get_hair_styles()
		var/new_h_style
		var/hair_index = valid_hairstyles.Find(pref.head_hair_style)

		if (href_list["inc"])
			if (hair_index < length(valid_hairstyles) && valid_hairstyles[hair_index + 1])
				new_h_style = valid_hairstyles[hair_index + 1]
		else if (href_list["dec"])
			if (hair_index > 1 && valid_hairstyles[hair_index - 1])
				new_h_style = valid_hairstyles[hair_index - 1]
		else
			new_h_style = tgui_input_list(user, "Choose your character's hair style:", CHARACTER_PREFERENCE_INPUT_TITLE, valid_hairstyles, pref.head_hair_style)

		mob_species = GLOB.species_by_name[pref.species]
		if(new_h_style && CanUseTopic(user) && (new_h_style in mob_species.get_hair_styles()))
			pref.head_hair_style = new_h_style
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["facial_color"])
		if(!HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_HAIR_COLOR))
			return TOPIC_NOACTION
		var/new_facial = input(user, "Choose your character's facial-hair colour:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.facial_hair_color) as color|null
		if(new_facial && HasAppearanceFlag(GLOB.species_by_name[pref.species], SPECIES_APPEARANCE_HAS_HAIR_COLOR) && CanUseTopic(user))
			pref.facial_hair_color = new_facial
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["eye_color"])
		if(!HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_EYE_COLOR))
			return TOPIC_NOACTION
		var/new_eyes = input(user, "Choose your character's eye colour:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.eye_color) as color|null
		if(new_eyes && HasAppearanceFlag(GLOB.species_by_name[pref.species], SPECIES_APPEARANCE_HAS_EYE_COLOR) && CanUseTopic(user))
			pref.eye_color = new_eyes
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["base_skin"])
		if(!HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS))
			return TOPIC_NOACTION
		var/new_s_base = tgui_input_list(user, "Choose your character's base colour:", CHARACTER_PREFERENCE_INPUT_TITLE, mob_species.base_skin_colours, null)
		if(new_s_base && CanUseTopic(user))
			pref.base_skin = new_s_base
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["skin_tone"])
		if(!HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_A_SKIN_TONE))
			return TOPIC_NOACTION
		var/new_s_tone = tgui_input_number(user, "Choose your character's skin-tone. Lower numbers are lighter, higher are darker. Range: 1 to [mob_species.max_skin_tone()]", CHARACTER_PREFERENCE_INPUT_TITLE, (-pref.skin_tone) + 35, max_value = INFINITY, min_value = -INFINITY, round_value = FALSE)
		mob_species = GLOB.species_by_name[pref.species]
		if(new_s_tone && HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_A_SKIN_TONE) && CanUseTopic(user))
			pref.skin_tone = 35 - max(min(round(new_s_tone), mob_species.max_skin_tone()), 1)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["skin_color"])
		if(!HasAppearanceFlag(mob_species, SPECIES_APPEARANCE_HAS_SKIN_COLOR))
			return TOPIC_NOACTION
		var/new_skin = input(user, "Choose your character's skin colour: ", CHARACTER_PREFERENCE_INPUT_TITLE, pref.skin_color) as color|null
		if(new_skin && HasAppearanceFlag(GLOB.species_by_name[pref.species], SPECIES_APPEARANCE_HAS_SKIN_COLOR) && CanUseTopic(user))
			pref.skin_color = new_skin
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["facial_style"])
		var/list/valid_facialhairstyles = mob_species.get_facial_hair_styles(pref.gender)
		var/new_f_style
		var/hair_index = valid_facialhairstyles.Find(pref.facial_hair_style)

		if (href_list["inc"])
			if (hair_index < length(valid_facialhairstyles) && valid_facialhairstyles[hair_index + 1])
				new_f_style = valid_facialhairstyles[hair_index + 1]
		else if (href_list["dec"])
			if (hair_index > 1 && valid_facialhairstyles[hair_index - 1])
				new_f_style = valid_facialhairstyles[hair_index - 1]
		else
			new_f_style = tgui_input_list(user, "Choose your character's facial-hair style:", CHARACTER_PREFERENCE_INPUT_TITLE, valid_facialhairstyles, pref.facial_hair_style)

		mob_species = GLOB.species_by_name[pref.species]
		if(new_f_style && CanUseTopic(user) && (new_f_style in mob_species.get_facial_hair_styles(pref.gender)))
			pref.facial_hair_style = new_f_style
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["marking_style"])
		var/list/disallowed_markings = list()
		//[SIERRA-ADD]
		var/list/robo_limbs = list()
		var/list/prosthetic_temp = list()
		//[//SIERRA-ADD]
		for (var/M in pref.body_markings)
			var/datum/sprite_accessory/marking/mark_style = GLOB.body_marking_styles_list[M]
			disallowed_markings |= mark_style.disallows
		var/list/usable_markings = pref.body_markings.Copy() ^ GLOB.body_marking_styles_list.Copy()
		for(var/M in usable_markings)
			var/datum/sprite_accessory/S = usable_markings[M]
			if(is_type_in_list(S, disallowed_markings) || (S.species_allowed && !(mob_species.get_bodytype() in S.species_allowed)) || (S.subspecies_allowed && !(mob_species.name in S.subspecies_allowed)))
				usable_markings -= M
		//[SIERRA-ADD/EDIT]
		for(var/P in pref.organ_data)
			if(pref.organ_data[P] == "cyborg")
				robo_limbs += P

		if(LAZYLEN(robo_limbs))
			var/option = alert("Select which type of bodymarks?", "select", "Flesh", "Robotic")
			switch(option)
				if("Flesh")
					var/new_marking = tgui_input_list(user, "Choose a body marking:", CHARACTER_PREFERENCE_INPUT_TITLE, usable_markings, null)
					if(new_marking && CanUseTopic(user))
						pref.body_markings[new_marking] = "#000000" //New markings start black
				if("Robotic")
					if(LAZYLEN(robo_limbs))
						var/bodypart = tgui_input_list(user, "Body Part for marking:", CHARACTER_PREFERENCE_INPUT_TITLE, robo_limbs, null)
						var/sorted
						if(bodypart && CanUseTopic(user))
							for(var/M in GLOB.body_marking_styles_list)
								var/datum/sprite_accessory/marking/mark_style = GLOB.body_marking_styles_list[M]
								if(mark_style.robo_paints == TRUE && !(M in prosthetic_temp))
									if(bodypart in mark_style.body_parts)
										LAZYADD(sorted, M)
						var/new_robo_marking = tgui_input_list(user, "Choose marking:", CHARACTER_PREFERENCE_INPUT_TITLE, sorted, null)
						if(new_robo_marking && CanUseTopic(user))
							pref.body_markings[new_robo_marking] = "#000000"
		else
			var/new_marking = tgui_input_list(user, "Choose a body marking:", CHARACTER_PREFERENCE_INPUT_TITLE, usable_markings, null)
			if(new_marking && CanUseTopic(user))
				pref.body_markings[new_marking] = "#000000" //New markings start black

		return TOPIC_REFRESH_UPDATE_PREVIEW
		//[/SIERRA-ADD/EDIT]

	else if(href_list["marking_remove"])
		var/M = href_list["marking_remove"]
		pref.body_markings -= M
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["marking_color"])
		var/M = href_list["marking_color"]
		var/mark_color = input(user, "Choose the [M] color: ", CHARACTER_PREFERENCE_INPUT_TITLE, pref.body_markings[M]) as color|null
		if(mark_color && CanUseTopic(user))
			pref.body_markings[M] = "[mark_color]"
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["reset_limbs"])
		reset_limbs()
		pref.body_markings.Cut() //[SIERRA-ADD
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["limbs"])

		var/list/limb_selection_list = list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand","Full Body")

		// Full prosthetic bodies without a brain are borderline unkillable so make sure they have a brain to remove/destroy.
		var/singleton/species/current_species = GLOB.species_by_name[pref.species]
		if(current_species.spawn_flags & SPECIES_NO_FBP_CHARGEN)
			limb_selection_list -= "Full Body"
		else if(pref.organ_data[BP_CHEST] == "cyborg")
			limb_selection_list |= "Head"

		var/organ_tag = tgui_input_list(user, "Which limb do you want to change?", null, limb_selection_list, null)

		if(!organ_tag || !CanUseTopic(user)) return TOPIC_NOACTION

		var/limb = null
		var/second_limb = null // if you try to change the arm, the hand should also change
		var/third_limb = null  // if you try to unchange the hand, the arm should also change

		// Do not let them amputate their entire body, ty.
		var/list/choice_options = list("Normal","Amputated","Prosthesis")

		//Dare ye who decides to one day make fbps be able to have fleshy bits. Heed my warning, recursion is a bitch. - Snapshot
		if(pref.organ_data[BP_CHEST] == "cyborg")
			choice_options = list("Amputated", "Prosthesis")

		switch(organ_tag)
			if("Left Leg")
				limb = BP_L_LEG
				second_limb = BP_L_FOOT
			if("Right Leg")
				limb = BP_R_LEG
				second_limb = BP_R_FOOT
			if("Left Arm")
				limb = BP_L_ARM
				second_limb = BP_L_HAND
			if("Right Arm")
				limb = BP_R_ARM
				second_limb = BP_R_HAND
			if("Left Foot")
				limb = BP_L_FOOT
				third_limb = BP_L_LEG
			if("Right Foot")
				limb = BP_R_FOOT
				third_limb = BP_R_LEG
			if("Left Hand")
				limb = BP_L_HAND
				third_limb = BP_L_ARM
			if("Right Hand")
				limb = BP_R_HAND
				third_limb = BP_R_ARM
			if("Head")
				limb =        BP_HEAD
				choice_options = list("Prosthesis")
			if("Full Body")
				limb =        BP_CHEST
				third_limb =  BP_GROIN
				choice_options = list("Normal","Prosthesis")

				//[SIERRA-ADD] - XENO WHITELIST
				if((!whitelist_lookup(SPECIES_FBP, user.ckey) && current_species.name != SPECIES_IPC) && !user.client.holder)
					choice_options -= "Prosthesis"
				//[/SIERRA-ADD]

		var/new_state = tgui_input_list(user, "What state do you wish the limb to be in?", null, choice_options, null)
		if(!new_state || !CanUseTopic(user)) return TOPIC_NOACTION

		switch(new_state)
			if("Normal")
				if(limb == BP_CHEST)
					for(var/other_limb in (BP_ALL_LIMBS - BP_CHEST))
						pref.organ_data[other_limb] = null
						pref.rlimb_data[other_limb] = null
						for(var/internal_organ in list(BP_HEART,BP_EYES,BP_LUNGS,BP_LIVER,BP_KIDNEYS,BP_STOMACH,BP_BRAIN))
							pref.organ_data[internal_organ] = null
				pref.organ_data[limb] = null
				pref.rlimb_data[limb] = null
				if(third_limb)
					pref.organ_data[third_limb] = null
					pref.rlimb_data[third_limb] = null
			if("Amputated")
				if(limb == BP_CHEST)
					return
				pref.organ_data[limb] = "amputated"
				pref.rlimb_data[limb] = null
				if(second_limb)
					pref.organ_data[second_limb] = "amputated"
					pref.rlimb_data[second_limb] = null

			if("Prosthesis")
				var/singleton/species/temp_species = pref.species ? GLOB.species_by_name[pref.species] : GLOB.species_by_name[SPECIES_HUMAN]
				var/tmp_species = temp_species.get_bodytype(user)
				var/list/usable_manufacturers = list()
				for(var/company in chargen_robolimbs)
					var/datum/robolimb/M = chargen_robolimbs[company]
					if(tmp_species in M.species_cannot_use)
						continue
					if(length(M.restricted_to) && !(tmp_species in M.restricted_to))
						continue
					if(length(M.applies_to_part) && !(limb in M.applies_to_part))
						continue
					if(M.allowed_bodytypes && !(tmp_species in M.allowed_bodytypes))
						continue
					usable_manufacturers[company] = M
				if(!length(usable_manufacturers))
					return
				var/choice = tgui_input_list(user, "Which manufacturer do you wish to use for this limb?", null, usable_manufacturers, null)
				if(!choice)
					return
				pref.rlimb_data[limb] = choice
				pref.organ_data[limb] = "cyborg"
				if(second_limb)
					pref.rlimb_data[second_limb] = choice
					pref.organ_data[second_limb] = "cyborg"
				if(third_limb && pref.organ_data[third_limb] == "amputated")
					pref.organ_data[third_limb] = null

				if(limb == BP_CHEST)
					for(var/other_limb in BP_ALL_LIMBS - BP_CHEST)
						pref.organ_data[other_limb] = "cyborg"
						pref.rlimb_data[other_limb] = choice
					if(!pref.organ_data[BP_BRAIN])
						pref.organ_data[BP_BRAIN] = "assisted"
					for(var/internal_organ in list(BP_HEART,BP_EYES,BP_LUNGS,BP_LIVER,BP_KIDNEYS))
						pref.organ_data[internal_organ] = "mechanical"

		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["organs"])
		var/organ_name = tgui_input_list(user, "Which internal function do you want to change?", null, list("Heart", "Eyes", "Lungs", "Liver", "Kidneys", "Stomach"), null)
		if(!organ_name) return

		var/organ = null
		switch(organ_name)
			if("Heart")
				organ = BP_HEART
			if("Eyes")
				organ = BP_EYES
			if("Lungs")
				organ = BP_LUNGS
			if("Liver")
				organ = BP_LIVER
			if("Kidneys")
				organ = BP_KIDNEYS
			if("Stomach")
				organ = BP_STOMACH

		var/list/organ_choices = list("Normal","Assisted","Synthetic")

		if(mob_species && mob_species.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS)
			organ_choices -= "Assisted"
			organ_choices -= "Synthetic"

		if(pref.organ_data[BP_CHEST] == "cyborg")
			organ_choices -= "Normal"
			organ_choices -= "Assisted"
			organ_choices += "Synthetic"

		var/new_state = tgui_input_list(user, "What state do you wish the organ to be in?", null, organ_choices, null)
		if(!new_state) return

		switch(new_state)
			if("Normal")
				pref.organ_data[organ] = null
			if("Assisted")
				pref.organ_data[organ] = "assisted"
			if("Synthetic")
				pref.organ_data[organ] = "mechanical"

		sanitize_organs()
		return TOPIC_REFRESH

	else if(href_list["disabilities"])
		var/disability_flag = text2num(href_list["disabilities"])
		pref.disabilities ^= disability_flag
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["res_trait"])
		if (!length(pref.picked_traits))
			return
		pref.picked_traits.Cut()
		return TOPIC_REFRESH

	else if (href_list["add_trait"])
		if (!mob_species)
			return
		var/list/possible_traits = mob_species.get_selectable_traits()
		var/picked = tgui_input_list(user, "Select a trait to apply.", "Add Trait", possible_traits, null)
		var/singleton/trait/selected = possible_traits[picked]
		if (!selected || !istype(selected))
			return

		var/remaining_budget = mob_species.trait_budget
		for (var/existing_type as anything in pref.picked_traits)
			var/singleton/trait/existing_trait = GET_SINGLETON(existing_type)
			if (!existing_trait || !istype(existing_trait))
				continue
			if (LAZYISIN(existing_trait.incompatible_traits, selected.type) || LAZYISIN(selected.incompatible_traits, existing_type))
				to_chat(usr, SPAN_WARNING("\The [selected.name] trait is incompatible with [existing_trait.name]."))
				return

			///This snippet handles calculating remaining budget.
			if (length(existing_trait.metaoptions))
				var/list/ex_metaoptions = pref.picked_traits[existing_trait.type]
				for (var/metaoption in ex_metaoptions)
					remaining_budget -= existing_trait.GetCost(metaoption)
			else
				remaining_budget -= existing_trait.GetCost()

		var/list/possible_levels = selected.levels
		if (selected.type in mob_species.traits)
			var/minimum_level = mob_species.traits[selected.type]
			var/cut = possible_levels.Find(minimum_level)
			if (cut >= length(possible_levels)) //get_selectable_traits() already weeded out traits where Cut(1, cut + 1) returns an out of bound error. This is just for safety.
				crash_with("Tried to cause an out of bounds error. ")
				return
			possible_levels.Cut(1, cut + 1)

		var/selected_level
		if (length(possible_levels) > 1)
			var/list/letterized_levels
			for (var/severity in possible_levels)
				LAZYSET(letterized_levels, LetterizeSeverity(severity), severity)
			var/letterized_input = tgui_input_list(user, "Select the trait's level to apply.", "Select Level", letterized_levels, null)
			if (!letterized_input)
				return
			selected_level = letterized_levels[letterized_input]
		else
			selected_level = possible_levels[1]
			to_chat(usr, SPAN_NOTICE ("The only level available for this trait is [LetterizeSeverity(selected_level)]."))

		var/additional_data
		if (length(selected.metaoptions))
			var/list/sanitized_metaoptions
			for (var/atom/option as anything in selected.metaoptions)
				var/cost = isnull(selected.metaoptions[option]) ? selected.budget_cost : selected.metaoptions[option]
				var/named_option = initial(option.name) + " ([cost])"
				LAZYSET(sanitized_metaoptions, named_option, option)

			var/additional_input = tgui_input_list(user, "[selected.addprompt]", "Select Option", sortAssoc(sanitized_metaoptions), null)
			if (!additional_input)
				return
			additional_data = sanitized_metaoptions[additional_input]

		if (selected.GetCost(additional_data) && remaining_budget - selected.GetCost(additional_data) < 0)
			to_chat(usr, SPAN_WARNING("\The [selected.name] trait cannot be selected as it costs [selected.GetCost(additional_data)] and the remaining trait budget is [remaining_budget]."))
			return

		if (additional_data)
			var/list/interim = list()
			if (!LAZYISIN(pref.picked_traits, selected.type))
				LAZYSET(pref.picked_traits, selected.type, interim)

			var/list/existing_meta_options = pref.picked_traits[selected.type]
			if (existing_meta_options[additional_data] == selected_level)
				return
			LAZYSET(existing_meta_options, additional_data, selected_level)
			LAZYSET(pref.picked_traits, selected.type, existing_meta_options)
		else
			LAZYSET(pref.picked_traits, selected.type, selected_level)
		return TOPIC_REFRESH

	return ..()


