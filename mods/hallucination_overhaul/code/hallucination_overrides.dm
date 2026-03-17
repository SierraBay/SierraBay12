/mob/proc/hallucinating()
	return FALSE

/mob/living/proc/can_hear()
	return !(sdisabilities & DEAFENED) && ear_deaf <= 0

/mob/living/carbon/Destroy()
	QDEL_NULL_LIST(hallucination_actors)
	return ..()

/mob/living/carbon/handle_statuses()
	. = ..()
	if(hallucinating())
		handle_hallucinations()

/datum/admins/Topic(href, href_list)
	..()

	if(href_list["hallucination_panel"])
		if(!check_rights(R_ADMIN))
			return

		var/action = href_list["hallucination_panel"]
		var/mob/living/carbon/target = locate(href_list["target"])
		if(action != "target" && !istype(target))
			to_chat(usr, SPAN_WARNING("That hallucination target is no longer valid."))
			return

		switch(action)
			if("target")
				target = locate(href_list["target"])
				if(!istype(target))
					to_chat(usr, SPAN_WARNING("That hallucination target is no longer valid."))
					return
			if("prime")
				var/power = text2num(href_list["power"])
				var/duration = text2num(href_list["duration"])
				target.hallucination(duration, power)
				log_and_message_admins("primed [key_name_admin(target)] for hallucinations at [power] power and [duration] duration.")
			if("dry_pick")
				var/datum/hallucination_context/context = target.build_hallucination_context()
				var/list/candidates = target.get_hallucination_candidates(TRUE, context)
				var/dry_pick_type = target.pick_contextual_hallucination(context, candidates)
				show_hallucination_panel(target, dry_pick_type)
				return
			if("clear_runtime")
				target.clear_hallucination_runtime_state()
				log_and_message_admins("cleared hallucination runtime state from [key_name_admin(target)].")
			if("clear")
				target.hallucination_power = 0
				target.hallucination_duration = 0
				target.clear_hallucination_runtime_state()
				for(var/datum/hallucination/active_hallucination in target.hallucinations.Copy())
					qdel(active_hallucination)
				log_and_message_admins("cleared hallucinations from [key_name_admin(target)].")
			if("cast", "cast_prime")
				var/datum/hallucination_context/context = target.build_hallucination_context()
				var/list/candidates = target.get_hallucination_candidates(TRUE, context)
				var/type_key = href_list["hall_type"]
				var/type_path
				for(var/datum/hallucination_candidate/candidate in candidates)
					if("[candidate.type_path]" != type_key)
						continue
					type_path = candidate.type_path
					break

				if(!ispath(type_path, /datum/hallucination))
					to_chat(usr, SPAN_WARNING("That hallucination type is invalid."))
					return

				if(action == "cast_prime")
					var/power = text2num(href_list["power"])
					var/duration = text2num(href_list["duration"])
					target.hallucination(duration, power)

				var/success = target.cause_hallucination(type_path, "admin panel by [key_name(usr)]", TRUE)
				log_and_message_admins("[success ? "forced" : "attempted to force"] hallucination [type_path] on [key_name_admin(target)] via panel.")
				if(!success)
					to_chat(usr, SPAN_WARNING("The hallucination failed to start."))

		show_hallucination_panel(target)
		return
