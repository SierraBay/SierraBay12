
/mob/living/carbon/human/heal_overall_damage(brute, burn)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)

	while(length(parts) && (brute>0 || burn>0) )
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		var/organ_type = 0
		if(picked.status & ORGAN_ROBOTIC)
			organ_type = 1
		picked.heal_damage(brute,burn,0, organ_type)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	SET_BIT(hud_updateflag, HEALTH_HUD)


//Processes the occupant, drawing from the internal power cell if needed.
/obj/machinery/recharge_station/proc/process_occupant()
	// Check whether the mob is compatible
	if(!isrobot(occupant) && !ishuman(occupant))
		return

	// If we have repair capabilities, repair any damage.
	if(weld_rate)
		var/repair = weld_rate - use_power_oneoff(weld_power_use * weld_rate, LOCAL) / weld_power_use
		occupant.adjustBruteLoss(-repair)
	if(wire_rate)
		var/repair = wire_rate - use_power_oneoff(wire_power_use * wire_rate, LOCAL) / wire_power_use
		occupant.adjustFireLoss(-repair)

	var/obj/item/cell/target
	if(isrobot(occupant))
		var/mob/living/silicon/robot/R = occupant
		target = R.cell
		if(R.module)
			R.module.respawn_consumable(R, charging_power * CELLRATE / 250) //consumables are magical, apparently
		// If we are capable of repairing damage, reboot destroyed components and allow them to be repaired for very large power spike.
		var/list/damaged = R.get_damaged_components(1,1,1)
		if(length(damaged) && wire_rate && weld_rate)
			for(var/datum/robot_component/C in damaged)
				if((C.installed == -1) && use_power_oneoff(100 KILOWATTS, LOCAL) <= 0)
					C.repair()

	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		var/obj/item/organ/internal/cell/potato = H.internal_organs_by_name[BP_CELL]
		if(potato)
			target = potato.cell
		if((!target || target.percent() > 95) && istype(H.back,/obj/item/rig))
			var/obj/item/rig/R = H.back
			if(R.cell && !R.cell.fully_charged())
				target = R.cell

	if(target && !target.fully_charged())
		var/diff = min(target.maxcharge - target.charge, charging_power * CELLRATE) // Capped by charging_power / tick
		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			if(H.species.name == SPECIES_ADHERENT)
				diff /= 2 //Adherents charge at half the normal rate.
		var/charge_used = diff - use_power_oneoff(diff / CELLRATE, LOCAL) * CELLRATE
		target.give(charge_used)
