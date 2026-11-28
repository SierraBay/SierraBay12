/singleton/psionic_power/praxia/psionics/ward
	use_intent =      I_HELP
	name =            "Укрепление обороны"
	cost =            30
	cooldown =        50
	use_melee =       TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите руки или кисти на зелёном интенте и нажмите по себе, чтобы на минуту усилить защиту от псионических атак."

/singleton/psionic_power/praxia/psionics/ward/invoke(mob/living/user, mob/living/carbon/target)
	if(user.a_intent != I_HELP || !(user.zone_sel.selecting in BP_ARMS_HANDS))
		return FALSE
	if(!target.psi)
		return FALSE
	if(target.psi.is_warded())
		to_chat(user, SPAN_NOTICE("Ментальный барьер уже стоит."))
		return FALSE
	. = ..()
	if(.)
		target.psi.ward_until = world.time + 60 SECONDS
		target.visible_message(
			SPAN_NOTICE("Вокруг [target] на мгновение вспыхивает и гаснет прозрачная плёнка."),
			SPAN_NOTICE("Ты окутываешь разум плотным барьером. Он продержится около минуты."))
		return TRUE

/datum/psi_complexus/proc/is_warded()
	return world.time < ward_until
