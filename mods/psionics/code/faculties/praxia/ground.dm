/singleton/psionic_power/praxia/psionics/ground
	use_intent =      I_GRAB
	name =            "П-Стабильность"
	cost =            15
	cooldown =        150
	use_grab =        TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Схватите цель, выберите грудь и нажмите по ней захватом на жёлтом интенте, чтобы снять с неё псионическое оглушение и вернуть часть сил."

/singleton/psionic_power/praxia/psionics/ground/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || user.a_intent != I_GRAB || user.zone_sel.selecting != BP_CHEST)
		return FALSE
	if(!target.psi)
		to_chat(user, SPAN_NOTICE("У [target] нет псионики, которую можно заземлить."))
		return FALSE
	. = ..()
	if(.)
		user.visible_message(
			SPAN_NOTICE("[user] прикладывает ладонь к лбу [target] и замирает."),
			SPAN_NOTICE("Ты направляешь чужую силу, успокаивая её."))
		if(!do_after(user, 3 SECONDS, target))
			return TRUE
		target.psi.stun = 0
		target.psi.next_power_use = world.time
		target.psi.stamina = min(target.psi.max_stamina, target.psi.stamina + 20)
		target.psi.ui?.update_icon()
		to_chat(target, SPAN_NOTICE("Спутанность моей ментальности становится легче."))
		return TRUE
