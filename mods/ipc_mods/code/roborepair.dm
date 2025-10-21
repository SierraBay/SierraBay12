/obj/item/stack/cable_coil/use_after(mob/living/carbon/human/target, mob/living/user)
	if (!istype(target))
		return FALSE
	var/obj/item/organ/external/organ = target.organs_by_name[user.zone_sel.selecting]
	if (!organ)
		to_chat(user, SPAN_WARNING("\The [target] is missing that organ."))
		return TRUE
	if (!BP_IS_ROBOTIC(organ))
		to_chat(user, SPAN_WARNING("\The [target]'s [organ.name] is not robotic. \The [src] is useless."))
		return TRUE
	if (BP_IS_BRITTLE(organ))
		to_chat(user, SPAN_WARNING("\The [target]'s [organ.name] is hard and brittle - \the [src] cannot repair it."))
		return TRUE
	var/use_amount = min(amount, ceil(organ.burn_dam / 3), 5)
	if (!can_use(use_amount))
		to_chat(user, SPAN_WARNING("You don't have enough of \the [src] left to repair \the [target]'s [organ.name]."))
		return TRUE
	if(organ.robo_repair(3 * use_amount, DAMAGE_BURN, "some damaged wiring", src, user))
		use(use_amount)
		return TRUE

/obj/item/weldingtool/use_before(mob/living/target, mob/living/user, click_parameters)
	if (!ishuman(target))
		return FALSE

	var/target_zone = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/S = H.organs_by_name[target_zone]

	if (!S || !BP_IS_ROBOTIC(S) || user.a_intent != I_HELP)
		return FALSE

	if(S.expensive)
		to_chat(user, SPAN_WARNING("\The [target]'s [S.name] cannot be repaired with such simple tools - \the [src] cannot repair it."))
		return TRUE

	var/list/all_surgeries = GET_SINGLETON_SUBTYPE_MAP(/singleton/surgery_step)
	for (var/singleton in all_surgeries)
		var/singleton/surgery_step/step = all_surgeries[singleton]
		if (step.name && step.tool_quality(src) && step.can_use(user, H, target_zone, src))
			return FALSE

	if (BP_IS_BRITTLE(S))
		to_chat(user, SPAN_WARNING("\The [target]'s [S.name] is hard and brittle - \the [src] cannot repair it."))
		return TRUE

	if (!can_use(2, user, silent = TRUE)) //The surgery check above already returns can_use's feedback.
		return TRUE

	if (S.robo_repair(15, DAMAGE_BRUTE, "some dents", src, user))
		remove_fuel(2, user)
		return TRUE

	else return FALSE

/obj/item/stack/nanopaste/use_after(mob/living/M as mob, mob/user as mob)
	if (!istype(M) || !istype(user))
		return FALSE
	if (istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if (R.getBruteLoss() || R.getFireLoss() )
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			R.adjustBruteLoss(-15)
			R.adjustFireLoss(-15)
			R.updatehealth()
			use(1)
			user.visible_message(SPAN_NOTICE("\The [user] applied some [src] on [R]'s damaged areas."),\
				SPAN_NOTICE("You apply some [src] at [R]'s damaged areas."))
		else
			to_chat(user, SPAN_NOTICE("All [R]'s systems are nominal."))
		return TRUE

	if (istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_sel.selecting)

		if(!S)
			to_chat(user, SPAN_WARNING("\The [M] is missing that body part."))
			return TRUE

		if(BP_IS_BRITTLE(S))
			to_chat(user, SPAN_WARNING("\The [M]'s [S.name] is hard and brittle - \the [src] cannot repair it."))
			return TRUE

		if(can_use(1))
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

		if(S.brute_dam > S.burn_dam)
			if(S.robo_repair(15, DAMAGE_BRUTE, "some broken elements", src, user))
				use(1)
		else
			if(S.robo_repair(15, DAMAGE_BURN, "some burned elements", src, user))
				use(1)
		H.UpdateDamageIcon()
		return TRUE



/obj/item/organ/external/robo_repair(repair_amount, damage_type, damage_desc, obj/item/tool, mob/living/user)
	if((!BP_IS_ROBOTIC(src)))
		return
	var/damage_amount
	switch(damage_type)
		if (DAMAGE_BRUTE)
			damage_amount = brute_dam
		if (DAMAGE_BURN)
			damage_amount = burn_dam
		else return 0

	if(!damage_amount)
		if(src.hatch_state != HATCH_OPENED)
			to_chat(user, SPAN_NOTICE("Nothing to fix!"))
		return

	if(user == src.owner)
		var/grasp
		if(user.l_hand == tool && (src.body_part & (ARM_LEFT|HAND_LEFT)))
			grasp = BP_L_HAND
		else if(user.r_hand == tool && (src.body_part & (ARM_RIGHT|HAND_RIGHT)))
			grasp = BP_R_HAND

		if(grasp)
			to_chat(user, SPAN_WARNING("You can't reach your [src.name] while holding [tool] in your [owner.get_bodypart_name(grasp)]."))
			return

	if(damage_amount <= (0.5 * max_damage))
		if(expensive == 2)
			if(istype(tool, /obj/item/prosthetic_wiring_layerer) || istype(tool, /obj/item/integrity_repair_tool) || istype(tool, /obj/item/stack/nanopaste))
				robo_heal(damage_amount, damage_type, damage_desc, tool, user)
				return TRUE

		else if(expensive != 2)
			robo_heal(damage_amount, damage_type, damage_desc, tool, user)
			return TRUE

	else
		to_chat(user, SPAN_DANGER("The damage is far too severe to patch over externally."))
		return


/obj/item/organ/external/proc/robo_heal(repair_amount, damage_type, damage_desc, obj/item/tool, mob/living/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(!do_after(user, rand(1,3) SECOND, owner, DO_SURGERY))
		return 0
	switch(damage_type)
		if (DAMAGE_BRUTE)
			heal_damage(repair_amount, 0, 0, 1)
		if (DAMAGE_BURN)
			heal_damage(0, repair_amount, 0, 1)
	owner.regenerate_icons()
	if(user == src.owner)
		var/datum/pronouns/pronouns = user.choose_from_pronouns()
		user.visible_message(SPAN_NOTICE("\The [user] patches [damage_desc] on [pronouns.his] [src.name] with [tool]."))
	else
		user.visible_message(SPAN_NOTICE("\The [user] patches [damage_desc] on [owner]'s [src.name] with [tool]."))

	return TRUE
