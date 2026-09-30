//////////////////////////////////////////////////////////////////
//	robotic limb brute damage repair surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/robotics/repair_brute
	name = "Repair damage to prosthetic"
	allowed_tools = list(
		/obj/item/weldingtool = 35,
		/obj/item/weldingtool/electric = 50,
		/obj/item/gun/energy/plasmacutter = 25,
		/obj/item/stock_parts/manipulator = 50,
		/obj/item/integrity_repair_tool = 50,
		/obj/item/stack/nanopaste = 50,
		/obj/item/psychic_power/psiblade/master = 100
	)

	min_duration = 70
	max_duration = 90

/singleton/surgery_step/robotics/repair_brute/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_BASIC))
		. += 5
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_TRAINED))
		. += 10
	if(!user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED))
		. -= 10

/singleton/surgery_step/robotics/repair_brute/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE
	if(isWelder(tool) || istype(tool, /obj/item/gun/energy/plasmacutter) || istype(tool, /obj/item/psychic_power/psiblade))
		return !affected.expensive
	if(istype(tool, /obj/item/stack/nanopaste) && affected.expensive >= 2)
		return FALSE
	return TRUE

/singleton/surgery_step/robotics/repair_brute/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE
	if(!affected.brute_dam)
		to_chat(user, SPAN_WARNING("There is no damage to repair."))
		return FALSE
	if(BP_IS_BRITTLE(affected))
		to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle to be repaired normally."))
		return FALSE
	if(affected.brute_dam >= affected.max_damage)
		to_chat(user, SPAN_DANGER("The structural damage is catastrophic — this prosthetic cannot be repaired and must be replaced entirely."))
		return FALSE
	if(!affected.can_repair_brute_with(tool))
		to_chat(user, SPAN_WARNING(affected.get_repair_grade_hint(DAMAGE_BRUTE)))
		return FALSE
	if(istype(tool, /obj/item/integrity_repair_tool))
		var/obj/item/integrity_repair_tool/integrity_repair_tool = tool
		if(!integrity_repair_tool.can_use(1))
			return FALSE
	if(istype(tool, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/paste = tool
		paste.use(1)
	if(isWelder(tool))
		var/obj/item/weldingtool/welder = tool
		if(!welder.remove_fuel(1, user))
			return FALSE
	if(istype(tool, /obj/item/gun/energy/plasmacutter))
		var/obj/item/gun/energy/plasmacutter/cutter = tool
		if(!cutter.slice(user))
			return FALSE
	if(istype(tool, /obj/item/stock_parts/manipulator))
		qdel(tool)
	return TRUE

/singleton/surgery_step/robotics/repair_brute/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if(affected && affected.hatch_state == HATCH_OPENED && ((affected.status & ORGAN_DISFIGURED) || affected.brute_dam > 0))
		return affected

/singleton/surgery_step/robotics/repair_brute/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
	"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")
	playsound(target.loc, 'sound/items/Welder.ogg', 15, 1)
	..()

/singleton/surgery_step/robotics/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] finishes patching damage to [target]'s [affected.name] with \the [tool]."), \
	SPAN_NOTICE("You finish patching damage to [target]'s [affected.name] with \the [tool]."))
	affected.heal_damage(rand(30,50),0,1,1)
	affected.status &= ~ORGAN_DISFIGURED

/singleton/surgery_step/robotics/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name]."),
	SPAN_WARNING("Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name]."))
	target.apply_damage(rand(5,20), DAMAGE_BURN, affected)


//////////////////////////////////////////////////////////////////
//	robotic limb brittleness repair surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/robotics/repair_brittle
	name = "Reinforce prosthetic"
	allowed_tools = list(/obj/item/stack/nanopaste = 50)
	min_duration = 50
	max_duration = 60

/singleton/surgery_step/robotics/repair_brittle/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()
	if(user.skill_check(SKILL_ELECTRICAL, SKILL_TRAINED))
		. += 10
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_TRAINED))
		. += 10
	if(!user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED))
		. -= 15

/singleton/surgery_step/robotics/repair_brittle/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if(affected && BP_IS_BRITTLE(affected) && affected.hatch_state == HATCH_OPENED)
		return affected

/singleton/surgery_step/robotics/repair_brittle/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to repair the brittle metal inside \the [target]'s [affected.name]." , \
	"You begin to repair the brittle metal inside \the [target]'s [affected.name].")
	playsound(target.loc, 'sound/items/bonegel.ogg', 50, TRUE)
	..()

/singleton/surgery_step/robotics/repair_brittle/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] finishes repairing the brittle interior of \the [target]'s [affected.name]."), \
	SPAN_NOTICE("You finish repairing the brittle interior of \the [target]'s [affected.name]."))
	affected.status &= ~ORGAN_BRITTLE

/singleton/surgery_step/robotics/repair_brittle/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user] causes some of \the [target]'s [affected.name] to crumble!"),
	SPAN_WARNING("You cause some of \the [target]'s [affected.name] to crumble!"))
	target.apply_damage(rand(5,20), DAMAGE_BRUTE, affected)

//////////////////////////////////////////////////////////////////
//	robotic limb burn damage repair surgery step
//////////////////////////////////////////////////////////////////

/singleton/surgery_step/robotics/repair_burn
	name = "Repair burns on prosthetic"
	allowed_tools = list(
		/obj/item/stack/nanopaste = 50,
		/obj/item/stack/cable_coil = 50,
		/obj/item/prosthetic_wiring_layerer = 50,
		/obj/item/stock_parts/capacitor = 50
	)
	min_duration = 70
	max_duration = 90

/singleton/surgery_step/robotics/repair_burn/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()

	if(user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC))
		. += 5
	if(user.skill_check(SKILL_ELECTRICAL, SKILL_TRAINED))
		. += 10
	if(!user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED))
		. -= 10

/singleton/surgery_step/robotics/repair_burn/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE
	if(istype(tool, /obj/item/stack/cable_coil))
		return !affected.expensive
	if(istype(tool, /obj/item/stack/nanopaste) && affected.expensive >= 2)
		return FALSE
	return TRUE

/singleton/surgery_step/robotics/repair_burn/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE
	if(!affected.burn_dam)
		to_chat(user, SPAN_WARNING("There is no damage to repair."))
		return FALSE
	if(BP_IS_BRITTLE(affected))
		to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle to be repaired normally."))
		return FALSE
	if(affected.burn_dam >= affected.max_damage)
		to_chat(user, SPAN_DANGER("The electrical damage is catastrophic — this prosthetic cannot be repaired and must be replaced entirely."))
		return FALSE
	if(!affected.can_repair_burn_with(tool))
		to_chat(user, SPAN_WARNING(affected.get_repair_grade_hint(DAMAGE_BURN)))
		return FALSE
	if(istype(tool, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cable = tool
		if(!cable.use(3))
			to_chat(user, SPAN_WARNING("You need at least three cable pieces to repair this damage."))
			return FALSE
		return TRUE
	if(istype(tool, /obj/item/prosthetic_wiring_layerer))
		var/obj/item/prosthetic_wiring_layerer/layerer = tool
		layerer.amount = layerer.amount - 1
		if(layerer.amount < 1)
			qdel(tool)
	if(istype(tool, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/paste = tool
		paste.use(1)
	if(istype(tool, /obj/item/stock_parts/capacitor))
		qdel(tool)
	return TRUE

/singleton/surgery_step/robotics/repair_burn/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if(affected && affected.hatch_state == HATCH_OPENED && ((affected.status & ORGAN_DISFIGURED) || affected.burn_dam > 0))
		return affected

/singleton/surgery_step/robotics/repair_burn/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
	"You begin to splice new cabling into [target]'s [affected.name].")
	playsound(target.loc, 'sound/items/Deconstruct.ogg', 15, 1)
	..()

/singleton/surgery_step/robotics/repair_burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_NOTICE("[user] finishes splicing cable into [target]'s [affected.name]."), \
	SPAN_NOTICE("You finish splicing new cable into [target]'s [affected.name]."))
	affected.heal_damage(0,rand(30,50),1,1)
	affected.status &= ~ORGAN_DISFIGURED

/singleton/surgery_step/robotics/repair_burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(SPAN_WARNING("[user] causes a short circuit in [target]'s [affected.name]!"),
	SPAN_WARNING("You cause a short circuit in [target]'s [affected.name]!"))
	target.apply_damage(rand(5,20), DAMAGE_BURN, affected)




//////////////////////////////////////////////////////////////////
//	robotic organ detachment surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/robotics/connect_to_posibrain
	name = "Access ECS directive disk"
	allowed_tools = list(
		/obj/item/device/multitool/multimeter/datajack = 70
	)
	min_duration = 90
	max_duration = 110

/singleton/surgery_step/robotics/connect_to_posibrain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	if(target_zone != BP_HEAD)
		return FALSE
	var/obj/item/organ/external/head = target.get_organ(BP_HEAD)
	if(!head || head.hatch_state != HATCH_OPENED)
		return FALSE
	var/obj/item/organ/internal/ecs/ecs = target.internal_organs_by_name[BP_EXONET]
	return ecs && ecs.directive_disk

/singleton/surgery_step/robotics/connect_to_posibrain/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/ecs/ecs = target.internal_organs_by_name[BP_EXONET]
	if(!ecs)
		to_chat(user, SPAN_WARNING("There is no ECS in this chassis."))
		return FALSE
	if(!ecs.directive_disk)
		to_chat(user, SPAN_WARNING("The ECS has no directive disk installed."))
		return FALSE
	return TRUE

/singleton/surgery_step/robotics/connect_to_posibrain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts connecting \the [tool] to \the [target]'s ECS.", \
	"You start connecting \the [tool] to \the [target]'s ECS.")
	to_chat(user, SPAN_WARNING("Mounting the directive disk..."))
	..()

/singleton/surgery_step/robotics/connect_to_posibrain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/ecs/ecs = target.internal_organs_by_name[BP_EXONET]
	if(!(user.skill_check(SKILL_COMPUTER, SKILL_EXPERIENCED) && user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
		to_chat(user, SPAN_WARNING("You have no idea what to do next!"))
		return
	user.visible_message(SPAN_NOTICE("[user] has established a connection to \the [target]'s ECS with \the [tool].") , \
	SPAN_NOTICE("You have successfully established a connection to the ECS directive disk."))
	sparks(3, 1, target.loc)
	if(ecs && ecs.directive_disk)
		ecs.directive_disk.ui_interact(user)

/singleton/surgery_step/robotics/connect_to_posibrain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, damaging \the [target]."), \
	SPAN_WARNING("Your hand slips, damaging \the [target]."))

/singleton/surgery_step/robotics/eject_ipc_directive_disk
	name = "Eject ECS directive disk"
	allowed_tools = list(
		/obj/item/device/multitool = 80
	)
	min_duration = 40
	max_duration = 60

/singleton/surgery_step/robotics/eject_ipc_directive_disk/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	if(target_zone != BP_HEAD)
		return FALSE
	if(user == target)
		return FALSE
	if(istype(tool, /obj/item/device/multitool/multimeter/datajack))
		return FALSE
	var/obj/item/organ/external/head = target.get_organ(BP_HEAD)
	if(!head || head.hatch_state != HATCH_OPENED)
		return FALSE
	var/obj/item/organ/internal/ecs/ecs = target.internal_organs_by_name[BP_EXONET]
	return ecs && ecs.directive_disk

/singleton/surgery_step/robotics/eject_ipc_directive_disk/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts disconnecting the directive disk from \the [target]'s ECS with \the [tool].", \
	"You start disconnecting the directive disk from the ECS with \the [tool].")
	playsound(target.loc, 'sound/items/Deconstruct.ogg', 15, 1)
	..()

/singleton/surgery_step/robotics/eject_ipc_directive_disk/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/ecs/ecs = target.internal_organs_by_name[BP_EXONET]
	var/obj/item/stock_parts/computer/hard_drive/portable/directive/disk = ecs ? ecs.uninstall_directive_disk(user) : null
	if(disk)
		user.visible_message(SPAN_NOTICE("[user] ejects \the [disk] from \the [target]'s ECS."), \
		SPAN_NOTICE("You eject the directive disk from the chassis computer."))

/singleton/surgery_step/robotics/eject_ipc_directive_disk/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(SPAN_WARNING("[user]'s hand slips, failing to eject the directive disk."), \
	SPAN_WARNING("Your hand slips, failing to eject the directive disk."))
