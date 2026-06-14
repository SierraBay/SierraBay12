/singleton/psionic_power/psychokinesis/propel
	name =           "Propel"
	cost =           20
	cooldown =       40
	use_ranged =     TRUE
	min_rank =       PSI_RANK_APPRENTICE
	use_description = "Выберите любую ногу или пятку на жёлтом интенте, чтобы отправится в полёт."

/singleton/psionic_power/psychokinesis/propel/invoke(mob/living/carbon/user, turf/simulated/target)
	if(!(user.zone_sel.selecting in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)))
		return FALSE

	if(!target)
		return FALSE

	. = ..()
	if(.)
		var/user_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
		user.throw_at(target, user_rank, user_rank, user)
