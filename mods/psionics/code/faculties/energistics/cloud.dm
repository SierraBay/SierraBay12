/singleton/psionic_power/energistics/cloud
	name =            "Cloud"
	cost =            20
	cooldown =        50
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите грудь на зелёном интенте и нажмите по себе, чтобы создать дымовую завесу."
	admin_log = FALSE

/datum/effect/smoke_spread/paramount
	smoke_type = /obj/effect/smoke/paramount

/obj/effect/smoke/paramount
	name = "foul gas"
	color = "#3b3b3b"
	layer = ABOVE_HUMAN_LAYER

/obj/effect/smoke/paramount/can_affect(mob/living/carbon/M)
	. = ..()
	if (!.)
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.psi.get_rank(PSI_ENERGISTICS) == PSI_RANK_GRANDMASTER) // Если персонаж Грандмастер по Псионике Энергетики, то он не будет получать урон от дыма.
			return FALSE

/obj/effect/smoke/paramount/affect(mob/living/carbon/human/R)
	R.apply_damage(10, DAMAGE_PSIONIC)
	if (R.coughedtime != 1)
		R.coughedtime = 1
		R.emote("gasp")
		addtimer(new Callback(R, TYPE_PROC_REF(/mob/living/carbon, clear_coughedtime)), 2 SECONDS)
	R.updatehealth()
	return

/singleton/psionic_power/energistics/cloud/invoke(mob/living/user, mob/living/target)
	var/en_rank_user = user.psi.get_rank(PSI_ENERGISTICS)

	if(user.zone_sel.selecting != BP_CHEST)
		return FALSE
	if(target != user)
		return FALSE
	if(user.a_intent != I_HELP)
		return FALSE

	. = ..()

	if(target == user)
		var/datum/effect/smoke_spread/smoke = new /datum/effect/smoke_spread()
		if(en_rank_user == PSI_RANK_GRANDMASTER)
			smoke = new /datum/effect/smoke_spread/paramount()
		smoke.set_up(10, 0, user.loc)
		smoke.attach(user)
		smoke.start()
		return TRUE
