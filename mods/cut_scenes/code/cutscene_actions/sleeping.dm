/datum/cutscene_action/sleeping
	var/duration = 1 SECONDS

/datum/cutscene_action/sleeping/New(input_duration)
	duration = input_duration

/datum/cutscene_action/sleeping/execute()
	sleep(duration)
	return TRUE
