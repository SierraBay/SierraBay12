/singleton/species/attempt_grab(mob/living/carbon/human/grabber, atom/movable/target, grab_type)
	if(grabber.lying)
		to_chat(grabber, SPAN_BAD("I can't fight in this position!"))
		return
	if(grabber != target)
		grabber.visible_message(SPAN_DANGER("[grabber] attempted to grab \the [target]!"))
	return grabber.make_grab(grabber, target, grab_type)

/mob/living/carbon/human/proc/drop_grabs()
	for(var/obj/item/grab/detected_grab in contents)
		to_chat(src, SPAN_BAD("I can't hold somneone in this position!"))
		detected_grab.current_grab.let_go(detected_grab)
	stop_pulling()
