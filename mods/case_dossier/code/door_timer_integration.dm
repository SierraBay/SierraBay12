/obj/machinery/door_timer/var/datum/computer_file/data/punishment/linked_punishment
/obj/machinery/door_timer/var/sentence_active = FALSE


/obj/machinery/door_timer/proc/load_from_punishment_log(mob/user)
	var/list/options = list()
	var/list/lookup = list()
	for(var/datum/computer_file/data/punishment/P in GLOB.all_punishments)
		if(!P.is_active_brig_sentence())
			continue
		var/label = "[P.fields["offender_name"]] - [P.fields["brig_minutes"]] min ([P.fields["authorized_by"]])"
		options += label
		lookup[label] = P

	if(!LAZYLEN(options))
		to_chat(user, SPAN_WARNING("No active brig sentences found in the Case Dossier."))
		return

	var/choice = input(user, "Select a sentence to load into [id].", "Case Dossier") as null|anything in options
	if(!choice || timing)
		return

	var/datum/computer_file/data/punishment/P = lookup[choice]
	linked_punishment = P
	timeset(text2num(P.fields["brig_minutes"]) * 60)
	to_chat(user, SPAN_NOTICE("Loaded [P.fields["brig_minutes"]] minute sentence for [P.fields["offender_name"]]."))
