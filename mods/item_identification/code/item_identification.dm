/obj/item
	var/list/mod_skill_identification = list()

/obj/item/proc/update_mod_identification()
	return

/mob/verb/mod_skill_examine_init()
	set name = "Inspect"
	set category = "IC"

	to_chat(usr, SPAN_CLASS("interface", "Вы теперь можете производить инспекцию предметов через ПКМ и через верб."))
	verbs -= /mob/verb/mod_skill_examine_init
	verbs += /verb/mod_skill_examine
	verbs += /verb/mod_skill_examine_hide

/verb/mod_skill_examine_hide()
	set name = "Hide Inspect"
	set category = "IC"

	to_chat(usr, SPAN_CLASS("interface", "Верб Inspect вновь спрятан."))
	usr.verbs += /mob/verb/mod_skill_examine_init
	usr.verbs -= /verb/mod_skill_examine
	usr.verbs -= /verb/mod_skill_examine_hide

/verb/mod_skill_examine(obj/item/I as obj in view(1))
	set name = "Inspect"
	set category = "IC"

	if(I in usr.contents)
		if(!usr.isEquipped(I) || !usr.canUnEquip(I))
			return

	mod_skill_examinate(usr, I)

/proc/mod_skill_examinate(mob/user, atom/A)
	if ((is_blind(user) || user.stat) && !isobserver(user))
		to_chat(user, SPAN_NOTICE("Something is there but you can't see it."))
		return
	user.face_atom(A)
	if (user.simulated)
		if (A.loc != user || user.IsHolding(A))
			for (var/mob/M in viewers(4, user))
				if (M == user)
					continue
				if (M.client && M.client.get_preference_value(/datum/client_preference/examine_messages) == GLOB.PREF_SHOW)
					if (M.is_blind() || user.is_invisible_to(M))
						continue
					to_chat(M, SPAN_SUBTLE("<b>\The [user]</b> looks at \the [A]."))

	var/is_adjacent = FALSE
	if (!isghost(user) && user.stat != DEAD)
		is_adjacent = user.Adjacent(A)

		if(is_adjacent && !user.incapacitated())
			var/obj/item/I = A
			if(istype(I))
				var/datum/extension/interactive/mod_inspect/MI = get_or_create_extension(user, /datum/extension/interactive/mod_inspect)
				MI.examine_item(user, I)

/datum/extension/interactive/mod_inspect
	var/list/additional_users = list()
	var/obj/item/identify_item
	var/list/request_timeouts = list()

/datum/extension/interactive/mod_inspect/proc/examine_item(mob/user, obj/item/I)
	var/w_width = 350
	var/w_height = 400

	if(identify_item && I != identify_item)
		additional_users = list()

	identify_item = I

	var/list/HTML = list()
	HTML += "<html><head><title>[identify_item.name]</title></head><body>"

	HTML += "<a href='?src=\ref[src];refresh=1'>\[Refresh\]</a><br>"
	HTML += "<b>Инспектируют предмет:</b><br>"
	HTML += "[user.name]<br>"
	for(var/user_ref in additional_users)
		var/user_name = additional_users[user_ref]["name"]
		HTML += "[user_name] <a href='?src=\ref[src];remove_person=\ref[user_ref]'>\[-\]</a><br>"

	HTML += "<a href='?src=\ref[src];add_person=1'>\[Добавить человека\]</a><br><br>"

	HTML += "<a href='?src=\ref[src];inspect=\ref[identify_item]'>\[Инспектировать предмет\]</a>"

	HTML += "<hr>"
	HTML += "Вместо этого вы можете <b>солгать</b> при инспекции предмета, тогда ваши навыки не будут задействованы для осмотра. Но при этом добавленные вами люди все еще могут задействовать свои навыки для инспекции.<br>"
	HTML += "<a href='?src=\ref[src];inspect=\ref[identify_item];inspect_intent=1'>\[Солгать\]</a>"

	if(user.mind && player_is_antag(user.mind))
		HTML += "<hr>"
		HTML += "Так как вы антагонист, то можете произвести проверку предмета, как если бы у вас были максимальные навыки в каждой области.<br>"
		HTML += "<a href='?src=\ref[src];inspect=\ref[identify_item];inspect_intent=2'>\[Гарантированно инспектировать предмет\]</a>"
		w_height += 100

	HTML += "</body></html>"

	var/datum/browser/popup = new(user, "mod_examine_item", "[I.name]", w_width, w_height)
	popup.set_content(jointext(HTML,null))
	popup.open()

/datum/extension/interactive/mod_inspect/proc/identify_item(mob/user, inspect_intent = 0)
	var/list/all_users = additional_users.Copy()

	var/orig_intention = 1

	if(inspect_intent == 1)
		orig_intention = 0

	if(inspect_intent == 2)
		orig_intention = 2

	all_users[user] = list("name" = user.name, "intention" = orig_intention)
	var/list/max_skills = list()

	for(var/key in all_users)
		var/intention = all_users[key]["intention"]
		if(intention > 0)
			var/mob/M = key
			if (istype(M) && M.skillset)
				for(var/singleton/hierarchy/skill/S in GLOB.skills)
					var/skill_val = M.get_skill_value(S.type)

					if(intention == 2)
						skill_val = SKILL_MAX

					if(!max_skills[S.type] || max_skills[S.type] < skill_val)
						max_skills[S.type] = skill_val

	var/starting_message = "[user] начинает детальный осмотр [identify_item.name]"

	if(LAZYLEN(additional_users))
		var/list/additional_names = list()
		starting_message += " вместе с: "
		for(var/auser in additional_users)
			var/auser_name = additional_users[auser]["name"]
			additional_names.Add(auser_name)

		starting_message += jointext(additional_names, ", ")

	starting_message += "."

	user.visible_message(starting_message)

	var/done = do_after(user, 10 SECONDS, identify_item, DO_PUBLIC_UNIQUE)

	if(done)
		if(user.incapacitated())
			to_chat(user, SPAN_WARNING("Вы не смогли произвести осмотр."))
			return

		if(!identify_item || !user.Adjacent(identify_item))
			to_chat(user, SPAN_WARNING("Предмет для осмотра не рядом."))
			return

		if(additional_users)
			for(var/auser in additional_users)
				var/mob/living/A = auser
				var/auser_name = additional_users[auser]["name"]
				if(!user.Adjacent(auser))
					to_chat(user, SPAN_WARNING("[auser_name] не рядом."))
					return
				if(A.incapacitated() || A.stat == DEAD || !A.client)
					to_chat(user, SPAN_WARNING("[auser_name] недоступен для участия в осмотре."))
					return

		identify_item.update_mod_identification()
		if(identify_item && LAZYLEN(identify_item.mod_skill_identification))
			for(var/index in identify_item.mod_skill_identification)
				var/success_text = identify_item.mod_skill_identification[index]["success"]
				var/failure_text = identify_item.mod_skill_identification[index]["failure"]
				var/logic = identify_item.mod_skill_identification[index]["LOGIC"]

				var/success = 0
				var/prevent_success = 0

				for(var/skill in identify_item.mod_skill_identification[index]["skillcheck"])
					var/skill_level = identify_item.mod_skill_identification[index]["skillcheck"][skill]

					if(max_skills[skill] >= skill_level)
						success = 1

					if(logic && logic == "AND" && max_skills[skill] < skill_level)
						prevent_success = 1


				if(success && !prevent_success)
					if(success_text)
						for(var/U in all_users)
							to_chat(U, success_text)
				else
					if(failure_text)
						for(var/U in all_users)
							to_chat(U, failure_text)
					else
						for(var/U in all_users)
							to_chat(U, SPAN_NOTICE("Вы не смогли что-либо обнаружить."))

		else
			for(var/U in all_users)
				to_chat(U, SPAN_NOTICE("Вы не смогли что-либо обнаружить."))

/datum/extension/interactive/mod_inspect/proc/add_person(mob/user)
	var/list/possible_targets = list()
	var/list/starting_targets

	starting_targets = view_or_range(1, user, "view")

	for(var/mob/living/M in starting_targets)
		if(M == user)
			continue
		possible_targets += M

	if(length(possible_targets))
		var/choice = input("Choose a mob", "Mob") as null | mob in possible_targets

		if(choice)
			var/mob/living/chosen = choice
			if(chosen == user)
				to_chat(user, SPAN_WARNING("Нельзя выбирать себя."))
				return

			if(additional_users[chosen])
				to_chat(user, SPAN_WARNING("[chosen.name] уже участвует в осмотре."))
				return

			if(!user.Adjacent(chosen))
				to_chat(user, SPAN_WARNING("[chosen.name] слишком далеко."))
				return

			if(user.incapacitated() || chosen.incapacitated())
				to_chat(user, SPAN_WARNING("[chosen.name] недоступен для осмотра."))
				return

			request_player(chosen, 30 SECONDS)

/datum/extension/interactive/mod_inspect/proc/request_player(mob/target, request_timeout)
	if(request_timeouts[target] && world.time < request_timeouts[target])
		to_chat(usr, SPAN_WARNING("Обращение уже недавно отправлялось."))
		return

	request_timeouts[target] = world.time + request_timeout
	if(target.client)
		to_chat(target, SPAN_BOLD("Вас запрашивают помочь с инспекцией предмета. В случае, если вы решите солгать, вы будете принимать участие в осмотре, но ваши навыки не будут задействованы для осмотра. <a href='?src=\ref[src];candidate=\ref[target];intention=1'>(Помочь)</a><a href='?src=\ref[src];candidate=\ref[target];intention=0'>(Солгать)</a>"))

		if(target.mind && player_is_antag(target.mind))
			to_chat(target, SPAN_BOLD("Так как вы антагонист, то можете помочь с проверкой предмета, как если бы у вас были максимальные навыки в каждой области. <a href='?src=\ref[src];candidate=\ref[target];intention=2'>(Гарантированная помощь)</a>"))

/datum/extension/interactive/mod_inspect/Topic(href, href_list)
	. = ..()
	if(href_list["add_person"])
		if(usr.stat == DEAD)
			return

		add_person(usr)
		return TRUE

	if(href_list["inspect"])
		if(usr.incapacitated() || usr.stat == DEAD)
			return

		if(!identify_item || !usr.Adjacent(identify_item))
			to_chat(usr, SPAN_WARNING("Предмет для осмотра не рядом."))
			return

		if(additional_users)
			for(var/auser in additional_users)
				var/mob/living/A = auser
				var/auser_name = additional_users[auser]["name"]
				if(!usr.Adjacent(auser))
					to_chat(usr, SPAN_WARNING("[auser_name] не рядом."))
					return
				if(A.incapacitated() || A.stat == DEAD || !A.client)
					to_chat(usr, SPAN_WARNING("[auser_name] недоступен для участия в осмотре."))
					return

		var/inspect_intent = text2num(href_list["inspect_intent"])

		if(inspect_intent == 2)
			if(!usr.mind || !player_is_antag(usr.mind))
				to_chat(usr, SPAN_WARNING("Вы не антагонист."))
				return

		identify_item(usr, inspect_intent)
		return TRUE

	if(href_list["candidate"])
		var/mob/living/candidate = locate(href_list["candidate"])

		if(additional_users[candidate])
			to_chat(usr, SPAN_WARNING("Вы уже участвуете в осмотре [identify_item.name]."))
			return

		if(candidate.incapacitated())
			return

		if(request_timeouts[candidate] && world.time > request_timeouts[candidate])
			to_chat(usr, SPAN_WARNING("Срок обращения истечен."))
			return

		var/inspect_intent = text2num(href_list["intention"])

		if(inspect_intent == 2)
			if(!usr.mind || !player_is_antag(usr.mind))
				to_chat(usr, SPAN_WARNING("Вы не антагонист."))
				return

		to_chat(holder, SPAN_WARNING("[candidate.name] соглашается участвовать в осмотре [identify_item.name]."))
		additional_users[usr] = list("name" = candidate.name, "intention" = inspect_intent)
		return TRUE

	if(href_list["remove_person"])
		var/mob/living/P = locate(href_list["remove_person"])

		if(istype(P) && additional_users[P])
			additional_users.Remove(P)
			examine_item(usr, identify_item)
			return TRUE

	if(href_list["refresh"])
		examine_item(usr, identify_item)
		return TRUE
