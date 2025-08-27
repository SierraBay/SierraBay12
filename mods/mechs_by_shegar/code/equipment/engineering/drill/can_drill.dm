/obj/item/mech_equipment/drill/proc/can_drill(atom/target, mob/living/pilot)
	if(!pilot || !target)
		return FALSE

	if (!drill_head)
		to_chat(pilot, SPAN_WARNING("\The [src] doesn't have a head!"))
		return FALSE

	if(isopenspace(target) || isspaceturf(target))
		to_chat(pilot, SPAN_WARNING("\The [target] can't be drilled away."))
		return FALSE

	if (ismob(target))
		var/mob/tmob = target
		if (tmob.unacidable)
			to_chat(pilot, SPAN_WARNING("\The [target] can't be drilled away."))
			return FALSE
		else
			to_chat(tmob, FONT_HUGE(SPAN_DANGER("You're about to get drilled - dodge!")))

	else if (isobj(target))
		var/obj/tobj = target
		if (tobj.unacidable)
			to_chat(pilot, SPAN_WARNING("\The [target] can't be drilled away."))
			return FALSE


	else if (istype(target, /turf/unsimulated))
		to_chat(pilot, SPAN_WARNING("\The [target] can't be drilled away."))
		return FALSE
	//Если все проверки прошли - бурить можно.
	return TRUE
