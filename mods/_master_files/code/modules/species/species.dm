/datum/species/disarm_attackhand(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	attacker.do_attack_animation(target)

	if(target.w_uniform)
		target.w_uniform.add_fingerprint(attacker)
	var/obj/item/organ/external/affecting = target.get_organ(ran_zone(attacker.zone_sel.selecting))

	var/list/holding = list(target.get_active_hand() = 60, target.get_inactive_hand() = 30)

	var/skill_mod = 10 * attacker.get_skill_difference(SKILL_COMBAT, target)
	var/state_mod = attacker.melee_accuracy_mods() - target.melee_accuracy_mods()
	var/stim_mod = target.chem_effects[CE_STIMULANT]
	var/push_threshold = 20
	var/disarm_threshold = 50

	if(target.a_intent == I_HELP)
		state_mod -= 30
	//Handle unintended consequences
	for(var/obj/item/I in holding)
		var/hurt_prob = max(holding[I] - 3*skill_mod, 0)
		if(prob(hurt_prob) && I.on_disarm_attempt(target, attacker))
			return

	var/randn = rand(1, 100) - skill_mod + state_mod - stim_mod
	if(!(check_no_slip(target)) && randn <= push_threshold)
		var/armor_check = 100 * target.get_blocked_ratio(affecting, DAMAGE_BRUTE, damage = 20)
		target.apply_effect(2, EFFECT_WEAKEN, armor_check)
		playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(armor_check < 100)
			target.visible_message(SPAN_DANGER("[attacker] has pushed [target]!"))
		else
			target.visible_message(SPAN_WARNING("[attacker] attempted to push [target]!"))
		return

	if(randn <= disarm_threshold)
		//See about breaking grips or pulls
		if(target.break_all_grabs(attacker))
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return

		//Actually disarm them
		for(var/obj/item/I in holding)
			if(I && target.unEquip(I))
				target.visible_message(SPAN_DANGER("[attacker] has disarmed [target]!"))
				playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return

	playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	target.visible_message(SPAN_DANGER("[attacker] attempted to disarm \the [target]!"))
