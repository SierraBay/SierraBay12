/singleton/psionic_power/consciousness/curse
	name =            "Hallucinations"
	cost =            20
	cooldown =        50
	use_grab =        TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Схватите цель, затем выберите верхнюю часть тела на зелёном интент. После этого, нажмите по цели захватом, чтобы погрузить её в мир галлюцинаций."

/singleton/psionic_power/consciousness/curse/invoke(mob/living/user, mob/living/carbon/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_CHEST || user.a_intent != I_HELP)
		return FALSE
	if(target == user)
		return FALSE
	. = ..()
	if(.)
		new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "eye_opening")
		playsound(target.loc, 'sound/hallucinations/far_noise.ogg', 15, 1)
		target.hallucination(rand(10,20) * con_rank_user, 100)
