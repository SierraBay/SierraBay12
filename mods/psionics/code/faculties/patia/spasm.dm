/singleton/psionic_power/patia/coercion/spasm
	use_intent =     I_DISARM
	name =           "Дрожь"
	cost =           15
	cooldown =       100
	use_ranged =     TRUE
	min_rank =       PSI_RANK_APPRENTICE
	use_description = "Выберите кисти или руки на синем интенте. Затем, совершите дистанционную атаку по цели, чтобы попытаться вырвать оружие(или иной предмет) из ранее выбранной конечности."

/singleton/psionic_power/patia/coercion/spasm/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE

	if(!(user.zone_sel.selecting in list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)))
		return FALSE

	. = ..()

	if(.)
		var/cn_rank = user.psi.get_rank(PSI_PATIA)
		to_chat(user, SPAN_DANGER("Вы ментально протыкаете руку [target] иглой."))
		to_chat(target, SPAN_DANGER("Вы ощущаете, как вашу руку проткнули иглой!"))
		if(prob(80))
			target.emote("scream")
		if(prob(cn_rank * 20) && target.l_hand && target.l_hand.simulated && target.unEquip(target.l_hand))
			target.visible_message(SPAN_DANGER("[target] из-за спазма роняет предмет, находившийся в левой руке!"))
		if(prob(cn_rank * 20) && target.r_hand && target.r_hand.simulated && target.unEquip(target.r_hand))
			target.visible_message(SPAN_DANGER("[target] из-за спазма невольно роняет предмет, находившийся в правой руке!"))
		new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "white_electricity_constant")
		return TRUE
