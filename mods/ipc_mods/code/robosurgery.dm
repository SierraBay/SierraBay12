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

/singleton/surgery_step/robotics/repair_brute/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(affected)
		if(!affected.brute_dam)
			to_chat(user, SPAN_WARNING("There is no damage to repair."))
			return FALSE
		if(BP_IS_BRITTLE(affected))
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle to be repaired normally."))
			return FALSE
		if(affected.expensive == 2)
			if(istype(tool, /obj/item/integrity_repair_tool))
				var/obj/item/integrity_repair_tool/integrity_repair_tool = tool
				if(affected.brute_dam < affected.max_damage)
					if(integrity_repair_tool.can_use(1))
						return TRUE
					else
						return FALSE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			if(istype(tool, /obj/item/stock_parts/manipulator))
				var/obj/item/stock_parts/manipulator = tool
				if(manipulator.rating >= affected.expensive)
					qdel(tool)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			else
				to_chat(user, SPAN_DANGER("[tool.name] cannot be used for such expensive repairs."))
				return FALSE
		if(affected.expensive == 1)
			if(istype(tool, /obj/item/integrity_repair_tool) || istype(tool, /obj/item/stack/nanopaste))
				if(affected.brute_dam < affected.max_damage)
					if(istype(tool, /obj/item/integrity_repair_tool))
						var/obj/item/integrity_repair_tool/integrity_repair_tool = tool
						if(affected.brute_dam < affected.max_damage)
							if(integrity_repair_tool.can_use(1))
								return FALSE
					if(istype(tool, /obj/item/stack/nanopaste))
						var/obj/item/stack/nanopaste = tool
						nanopaste.use(1)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			if(istype(tool, /obj/item/stock_parts/manipulator))
				var/obj/item/stock_parts/manipulator = tool
				if(manipulator.rating >= affected.expensive)
					qdel(tool)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			else
				to_chat(user, SPAN_DANGER("[tool.name] cannot be used for such expensive repairs."))
				return FALSE

		if(affected.expensive == 0)
			if(affected.brute_dam < affected.max_damage)
				if(istype(tool, /obj/item/integrity_repair_tool))
					var/obj/item/integrity_repair_tool/integrity_repair_tool = tool
					if(affected.brute_dam < affected.max_damage)
						if(!integrity_repair_tool.can_use(1))
							return FALSE
				if(istype(tool, /obj/item/stack/nanopaste))
					var/obj/item/stack/nanopaste = tool
					nanopaste.use(1)
				if(isWelder(tool))
					var/obj/item/weldingtool/welder = tool
					if(!welder.remove_fuel(1,user))
						return FALSE
				if(istype(tool, /obj/item/gun/energy/plasmacutter))
					var/obj/item/gun/energy/plasmacutter/cutter = tool
					if(!cutter.slice(user))
						return FALSE
			if(istype(tool, /obj/item/stock_parts/manipulator))
				qdel(tool)
				return TRUE
		return TRUE
	return FALSE

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

/singleton/surgery_step/robotics/repair_burn/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(affected)
		if(!affected.burn_dam)
			to_chat(user, SPAN_WARNING("There is no damage to repair."))
			return FALSE
		if(BP_IS_BRITTLE(affected))
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle to be repaired normally."))
			return FALSE
		if(affected.expensive == 2)
			if(istype(tool, /obj/item/prosthetic_wiring_layerer))
				var/obj/item/prosthetic_wiring_layerer/prosthetic_wiring_layerer = tool
				if(affected.burn_dam < affected.max_damage)
					prosthetic_wiring_layerer.amount = prosthetic_wiring_layerer.amount - 1
					if(prosthetic_wiring_layerer.amount < 1)
						qdel(tool)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			if(istype(tool, /obj/item/stock_parts/capacitor))
				var/obj/item/stock_parts/capacitor = tool
				if(capacitor.rating >= affected.expensive)
					qdel(tool)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			else
				to_chat(user, SPAN_DANGER("[tool.name] cannot be used for such expensive repairs."))
				return FALSE

		if(affected.expensive == 1)
			if(istype(tool, /obj/item/prosthetic_wiring_layerer) || istype(tool, /obj/item/stack/nanopaste))
				if(affected.burn_dam < affected.max_damage)
					if(istype(tool, /obj/item/prosthetic_wiring_layerer))
						var/obj/item/prosthetic_wiring_layerer/prosthetic_wiring_layerer = tool
						prosthetic_wiring_layerer.amount = prosthetic_wiring_layerer.amount - 1
						if(prosthetic_wiring_layerer.amount < 1)
							qdel(tool)
					if(istype(tool, /obj/item/stack/nanopaste))
						var/obj/item/stack/nanopaste = tool
						nanopaste.use(1)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			if(istype(tool, /obj/item/stock_parts/capacitor))
				var/obj/item/stock_parts/capacitor = tool
				if(capacitor.rating >= affected.expensive)
					return TRUE
				else
					to_chat(user, SPAN_DANGER("The damage is far too severe, shoud use stock parts rating = [max(1, affected.expensive)] or higher."))
					return FALSE
			else
				to_chat(user, SPAN_DANGER("[tool.name] cannot be used for such expensive repairs."))
				return FALSE

		if(affected.expensive == 0)
			var/obj/item/stack/cable_coil/C = tool
			if(istype(C))
				if(!C.use(3))
					to_chat(user, SPAN_WARNING("You need three or more cable pieces to repair this damage."))
				else
					return TRUE
			else
				if(istype(tool, /obj/item/prosthetic_wiring_layerer))
					var/obj/item/prosthetic_wiring_layerer/prosthetic_wiring_layerer = tool
					prosthetic_wiring_layerer.amount = prosthetic_wiring_layerer.amount - 1
					if(prosthetic_wiring_layerer.amount < 1)
						qdel(tool)
				if(istype(tool, /obj/item/stack/nanopaste))
					var/obj/item/stack/nanopaste = tool
					nanopaste.use(1)
				return TRUE
	return FALSE

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
	SPAN_NOTICE("You finishes splicing new cable into [target]'s [affected.name]."))
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
