/proc/stun_and_jittery_by_electra(mob/living/user)
	if(ishuman(user) && !user.incapacitated()) //Человек в сознании
		var/mob/living/carbon/human/victim = user
		if(prob(14 * victim.get_skill_value(SKILL_HAULING))) //Максимально 70
			to_chat(user, SPAN_GOOD("Вы стойко переносите удар тока."))
			return
		else
			to_chat(user, SPAN_BAD("Сильный удар тока сбивает вас с ног!"))
	user.Weaken(1)
	user.make_jittery(min(50, 200))
	user.stun_effect_act(1,1)
