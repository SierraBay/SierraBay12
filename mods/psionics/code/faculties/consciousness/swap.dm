/singleton/psionic_power/consciousness/swap
	name =           "Shadow Swap"
	cost =           30
	cooldown =       100
	use_ranged =     TRUE
	min_rank =       PSI_RANK_MASTER
	use_description = "Выберите пятки или ноги на зелёном интенте. Затем, нажмите по цели на дистанции, чтобы заметно обменяться с ней местами."

/singleton/psionic_power/consciousness/swap/invoke(mob/living/user, mob/living/carbon/human/target)
	var/cn_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)

	if(!istype(target))
		return FALSE

	if(user.a_intent != I_HELP)
		return FALSE

	if(!(user.zone_sel.selecting in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)))
		return FALSE

	. = ..()
	if(.)
		if(!do_after(user, 5 SECONDS / user.psi.get_rank(PSI_CONSCIOUSNESS)))
			return FALSE
		var/turf/target_turf = get_turf(target)
		var/turf/user_turf = get_turf(user)

		var/list/mobs = GLOB.alive_mobs + GLOB.dead_mobs
		for(var/mob/living/M in mobs)
			if(M == user)
				continue
			if(get_dist(user, M) > cn_rank_user)
				continue
			M.eye_blind = max(M.eye_blind,cn_rank_user)
		target.forceMove(user_turf)
		user.forceMove(target_turf)

		return TRUE
