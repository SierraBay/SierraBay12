
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
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_TRAINED))
		. += 5
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_EXPERIENCED))
		. += 10
	if(!user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED))
		. -= 10

/singleton/surgery_step/robotics/repair_brute_manipulator/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/stock_parts/manipulator = tool
	if(affected)
		if(!affected.brute_dam)
			to_chat(user, SPAN_WARNING("There is no damage to repair."))
			return FALSE
		if(affected.expensive > manipulator.rating)
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too advanced to be repaired witch such simple [tool]."))
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
	if(istype(tool, /obj/item/stock_parts/manipulator))
		var/obj/item/stock_parts/manipulator = tool
		affected.heal_damage((15*manipulator.rating),0,1,1)
		affected.status &= ~ORGAN_DISFIGURED
		qdel(tool)

/singleton/surgery_step/robotics/repair_brute_manipulator/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name]."),
	SPAN_WARNING("Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name]."))
	target.apply_damage(rand(5,10), DAMAGE_BURN, affected)
	qdel(tool)

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
	var/obj/item/stock_parts/capacitor = tool
	if(affected)
		if(!affected.burn_dam)
			to_chat(user, SPAN_WARNING("There is no damage to repair."))
			return FALSE
		if(affected.expensive > capacitor.rating)
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too advanced to be repaired witch such simple [tool]."))
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
	if(istype(tool, /obj/item/stock_parts/capacitor))
		var/obj/item/stock_parts/capacitor = tool
		affected.heal_damage(0,(15*capacitor.rating),1,1)
		affected.status &= ~ORGAN_DISFIGURED
		qdel(tool)

/singleton/surgery_step/robotics/repair_burn_capacitor/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user] causes a short circuit in [target]'s [affected.name]!"),
	SPAN_WARNING("You cause a short circuit in [target]'s [affected.name]!"))
	target.apply_damage(rand(5,10), DAMAGE_BURN, affected)
	qdel(tool)



//////////////////////////////////////////////////////////////////
//	robotic organ detachment surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/robotics/connect_to_posibrain
	name = "Connect to posibrain"
	allowed_tools = list(
		/obj/item/device/multitool/multimeter/datajack = 70
	)
	min_duration = 90
	max_duration = 110

/singleton/surgery_step/robotics/connect_to_posibrain/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/posibrain/ipc/I = target.internal_organs_by_name[BP_POSIBRAIN]
	if(I && !(I.status & ORGAN_CUT_AWAY) && !BP_IS_CRYSTAL(I) && I.parent_organ == target_zone)
		if(I.shackles_module)
			return I
		else
			to_chat(user, SPAN_WARNING("The posibrain is not shackled."))
			return
	else
		to_chat(user, SPAN_WARNING("The posibrain is not present."))
	return

/singleton/surgery_step/robotics/connect_to_posibrain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/affected = target.get_organ(target_zone)
	var/obj/removing = target.internal_organs_by_name[LAZYACCESS(target.surgeries_in_progress, target_zone)]
	user.visible_message("[user] starts connect \the [removing] from \the [target]'s [affected.name] with \the [tool].", \
	"You connect \the [removing] to \the [target]'s [affected.name] with \the [tool]." )
	to_chat(user, SPAN_WARNING("Finding weak access points..."))
	if(do_after(user, 80, src))
		sparks(3, 1, target.loc)
		to_chat(user, SPAN_WARNING("Getting backdoor access to the shackles..."))
	..()

/singleton/surgery_step/robotics/connect_to_posibrain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/affected = target.get_organ(target_zone)
	var/obj/removing = LAZYACCESS(target.surgeries_in_progress, target_zone)
	if(!(user.skill_check(SKILL_COMPUTER, SKILL_EXPERIENCED) && user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
		to_chat(user, "You have no idea what to do next!")
		return
	user.visible_message(SPAN_NOTICE("[user] has established a connection to \the [removing] from \the [target]'s [affected.name] with \the [tool].") , \
	SPAN_NOTICE("You have successfully established a connection to \the [removing] from \the [target]'s [affected.name] with \the [tool]."))
	sparks(3, 1, target.loc)
	sparks(3, 1, target.loc)
	var/obj/item/organ/internal/posibrain/ipc/I = target.internal_organs_by_name[BP_POSIBRAIN]
	if(I && I.shackles_module)
		I.shackles_module.update_laws()
		I.shackles_module.ui_interact(user)

/singleton/surgery_step/robotics/connect_to_posibrain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, damaging \the [target]."), \
	SPAN_WARNING("Your hand slips, damaging \the [target]."))
