/singleton/psionic_power/praxia/psionics/mirror
	use_intent =      I_HELP
	name =            "Зеркало"
	cost =            20
	cooldown =        200
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите ноги или ступни на зелёном интенте и нажмите по себе, чтобы следующая псионическая атака на вас была отражена в нападавшего. Зеркало держится около полминуты."

/singleton/psionic_power/praxia/psionics/mirror/invoke(mob/living/carbon/user, mob/living/target)
	if(target != user || user.a_intent != I_HELP || !(user.zone_sel.selecting in  BP_LEGS_FEET))
		return FALSE
	if(user.psi.is_mirroring())
		return FALSE
	. = ..()
	if(.)
		user.psi.mirror_until = world.time + ((30 SECONDS) * user.psi.get_rank(PSI_PRAXIA) - 1)
		to_chat(user, SPAN_NOTICE("Ты выставляешь внутри разума зеркало. Следующий удар по нему вернётся хозяину."))
		return TRUE

/datum/psi_complexus/proc/is_mirroring()
	return world.time < mirror_until
