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
	if(organ.expensive && organ.damage >= 10)
		to_chat(user, SPAN_WARNING("\The [target]'s [organ.name] cannot be repaired with such simple tools - \the [src] cannot repair it."))
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

	if(S.expensive && S.damage >= 10)
		to_chat(user, SPAN_WARNING("\The [target]'s [S.name] cannot be repaired with such simple tools - \the [src] cannot repair it."))
		return TRUE

	if (S.robo_repair(15, DAMAGE_BRUTE, "some dents", src, user))
		remove_fuel(2, user)
		return TRUE

	else return FALSE


/obj/item/stock_parts/manipulator/use_before(mob/living/target, mob/living/user, click_parameters)
	if (!ishuman(target))
		return FALSE

	var/target_zone = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/S = H.organs_by_name[target_zone]

	if (!S || !BP_IS_ROBOTIC(S) || user.a_intent != I_HELP)
		return FALSE

	var/list/all_surgeries = GET_SINGLETON_SUBTYPE_MAP(/singleton/surgery_step)
	for (var/singleton in all_surgeries)
		var/singleton/surgery_step/step = all_surgeries[singleton]
		if (step.name && step.tool_quality(src) && step.can_use(user, H, target_zone, src))
			return FALSE

	if (BP_IS_BRITTLE(S))
		to_chat(user, SPAN_WARNING("\The [target]'s [S.name] is hard and brittle - \the [src] cannot repair it."))
		return TRUE
	if(do_after(usr, 2.5 SECONDS, src, DO_PUBLIC_UNIQUE))
		if(S.robo_repair(25, DAMAGE_BRUTE, "some broken elements", src, user))
			qdel(src)
			return TRUE

	else return FALSE


/obj/item/stock_parts/capacitor/use_after(mob/living/carbon/human/target, mob/living/user)
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
	if(do_after(usr, 2.5 SECONDS, src, DO_PUBLIC_UNIQUE))
		if(organ.robo_repair(25, DAMAGE_BURN, "some burned elements", src, user))
			qdel(src)
			return TRUE

//////////////////////////////////////////////////////////////////
//	robotic limb brute damage repair surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/robotics/repair_brute_manipulator
	name = "Repair damage to prosthetic with manipulator"
	allowed_tools = list(
		/obj/item/stock_parts/manipulator = 50
	)

	min_duration = 70
	max_duration = 90

/singleton/surgery_step/robotics/repair_brute_manipulator/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_BASIC))
		. += 5
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_TRAINED))
		. += 10
	if(!user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED))
		. -= 10

/singleton/surgery_step/robotics/repair_brute_manipulator/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected)
		if(!affected.brute_dam)
			to_chat(user, SPAN_WARNING("There is no damage to repair."))
			return FALSE
		if(BP_IS_BRITTLE(affected))
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle to be repaired normally."))
			return FALSE
		return TRUE
	return FALSE

/singleton/surgery_step/robotics/repair_brute_manipulator/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if(affected && affected.hatch_state == HATCH_OPENED && ((affected.status & ORGAN_DISFIGURED) || affected.brute_dam > 0))
		return affected

/singleton/surgery_step/robotics/repair_brute_manipulator/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to install new [tool.name] to [target]'s [affected.name]'s" , \
	"You begin to install new [tool.name] to [target]'s [affected.name]'s.")
	playsound(target.loc, 'sound/items/Deconstruct.ogg', 15, 1)
	..()

/singleton/surgery_step/robotics/repair_brute_manipulator/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] finishes install new [tool.name] to [target]'s [affected.name]"), \
	SPAN_NOTICE("You finish install new [tool.name] to [target]'s [affected.name]"))
	affected.heal_damage(rand(30,50),0,1,1)
	affected.status &= ~ORGAN_DISFIGURED

/singleton/surgery_step/robotics/repair_brute_manipulator/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name]."),
	SPAN_WARNING("Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name]."))
	target.apply_damage(rand(5,10), DAMAGE_BURN, affected)

/singleton/surgery_step/robotics/repair_burn_capacitor
	name = "Repair burns on prosthetic with capacitor"
	allowed_tools = list(
		/obj/item/stock_parts/capacitor = 50
	)
	min_duration = 80
	max_duration = 100

/singleton/surgery_step/robotics/repair_burn_capacitor/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()

	if(user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC))
		. += 5
	if(user.skill_check(SKILL_ELECTRICAL, SKILL_TRAINED))
		. += 10
	if(!user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED))
		. -= 10

/singleton/surgery_step/robotics/repair_burn_capacitor/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected)
		if(!affected.burn_dam)
			to_chat(user, SPAN_WARNING("There is no damage to repair."))
			return FALSE
		if(BP_IS_BRITTLE(affected))
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle for this kind of repair."))
	return FALSE

/singleton/surgery_step/robotics/repair_burn_capacitor/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if(affected && affected.hatch_state == HATCH_OPENED && ((affected.status & ORGAN_DISFIGURED) || affected.burn_dam > 0))
		return affected

/singleton/surgery_step/robotics/repair_burn_capacitor/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] install new [tool.name] into [target]'s [affected.name]." , \
	"You begin to install new [tool.name] into [target]'s [affected.name].")
	playsound(target.loc, 'sound/items/Deconstruct.ogg', 15, 1)
	..()

/singleton/surgery_step/robotics/repair_burn_capacitor/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] finishes install new [tool.name] into [target]'s [affected.name]."), \
	SPAN_NOTICE("You finishes install new [tool.name] into [target]'s [affected.name]."))
	affected.heal_damage(0,rand(30,50),1,1)
	affected.status &= ~ORGAN_DISFIGURED

/singleton/surgery_step/robotics/repair_burn_capacitor/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user] causes a short circuit in [target]'s [affected.name]!"),
	SPAN_WARNING("You cause a short circuit in [target]'s [affected.name]!"))
	target.apply_damage(rand(5,10), DAMAGE_BURN, affected)
