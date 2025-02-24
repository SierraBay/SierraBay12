/obj/anomaly/part/handle_human_teamplay(mob/living/carbon/human/target, mob/living/carbon/human/helper)
	core.handle_human_teamplay(target, helper)

/obj/anomaly/proc/handle_human_teamplay(mob/living/carbon/human/target, mob/living/carbon/human/helper)
	visible_message(SPAN_GOOD("[helper] с силой дёргает [target] на себя!"))
	target.forceMove(get_turf(helper))
	target.Weaken(5)
	helper.Weaken(5)


/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	if(isanomalyhere(get_turf(src)))
		var/obj/anomaly/handled_anomaly = locate() in get_turf(src)
		handled_anomaly.handle_human_teamplay(src, M)
	..()
