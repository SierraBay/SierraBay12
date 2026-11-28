/singleton/psionic_power/praxia/psionics/sever
	use_intent =      I_DISARM
	name =            "Отсечь путы"
	cost =            40
	cooldown =        600
	use_grab =        TRUE
	min_rank =        PSI_RANK_MASTER
	use_description = "Схватите порабощённого, выберите голову и нажмите по нему захватом на синем интенте, чтобы разорвать ментальные путы поработителя."

/singleton/psionic_power/praxia/psionics/sever/invoke(mob/living/user, mob/living/target)
	if(!istype(target) || user.a_intent != I_DISARM || user.zone_sel.selecting != BP_HEAD)
		return FALSE
	. = ..()
	if(.)
		if(!target.mind || !GLOB.thralls.is_antagonist(target.mind))
			to_chat(user, SPAN_NOTICE("На [target] нет ментальных пут."))
			return TRUE
		user.visible_message(SPAN_WARNING("[user] обхватывает голову [target] и принимается что-то нащупывать."))
		to_chat(user, SPAN_NOTICE("Ты нащупываешь чужие нити в разуме [target] и перебираешь их одну за другой..."))
		if(!do_after(user, 6 SECONDS, target))
			user.psi.backblast(rand(5, 15))
			return TRUE
		GLOB.thralls.remove_antagonist(target.mind, TRUE)
		to_chat(user, SPAN_NOTICE("Путы лопаются. [target] свободен."))
		to_chat(target, SPAN_NOTICE("Чужая воля отпускает твой разум, и ты снова принадлежишь себе."))
		target.apply_damage(10, DAMAGE_PAIN, BP_HEAD)
		return TRUE
