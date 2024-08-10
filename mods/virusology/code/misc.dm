/datum/goal/sickness
	description = "Don't get sick! Avoid catching any viruses during the shift."
	var/got_sick
	var/announced

/datum/goal/sickness/check_success()
	return !got_sick

/datum/goal/sickness/update_progress(var/progress)
	if(!got_sick)
		got_sick = progress
		if(got_sick)
			addtimer(CALLBACK(src, /datum/goal/sickness/on_completion), rand(30,40))

/datum/goal/sickness/on_completion()
	if(!announced)
		announced = TRUE
		var/datum/mind/mind = owner
		to_chat(mind.current, SPAN_DANGER("You don't feel so good..."))