/singleton/species/attempt_grab(mob/living/carbon/human/grabber, atom/movable/target, grab_type)
	if(grabber.lying)
		to_chat(grabber, SPAN_BAD("I can't fight in this position!"))
		return
	if(grabber != target)
		grabber.visible_message(SPAN_DANGER("[grabber] attempted to grab \the [target]!"))
	return grabber.make_grab(grabber, target, grab_type)

