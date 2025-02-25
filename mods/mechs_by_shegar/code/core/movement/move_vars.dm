/mob/living/exosuit
	movement_handlers = list(
		/datum/movement_handler/mob/delay/exosuit,
		/datum/movement_handler/mob/space/exosuit,
		/datum/movement_handler/mob/multiz,
		/datum/movement_handler/mob/exosuit
	)

/datum/movement_handler/mob/delay/exosuit
	expected_host_type = /mob/living/exosuit
///
/mob/living/exosuit/SetMoveCooldown(current_speed_input)
	var/result_timeout = (BIGGEST_POSSIBLE_SPEED+1) - current_speed
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay/exosuit)
	if(delay)
		delay.SetDelay(result_timeout)
