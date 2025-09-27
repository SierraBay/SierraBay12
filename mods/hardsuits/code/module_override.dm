/obj/item/rig_module/maneuvering_jets
	show_toggle_button = TRUE

/obj/item/rig_module/self_destruct
	show_toggle_button = TRUE

/obj/item/rig_module/datajack
	show_toggle_button = TRUE

/obj/item/rig_module/power_sink
	show_toggle_button = TRUE

/obj/item/rig_module/voice
	show_toggle_button = TRUE

/obj/item/rig_module/electrowarfare_suite
	show_toggle_button = TRUE

/obj/item/rig_module/vision
	show_toggle_button = TRUE

/obj/item/rig_module/mounted/arm_blade
	show_toggle_button = TRUE

/obj/item/rig_module/device/anomaly_scanner
	show_toggle_button = TRUE

/obj/item/rig_module/teleporter
	show_toggle_button = TRUE

/obj/item/rig_module/mounted/power_fist
	show_toggle_button = TRUE

/obj/item/rig_module/stealth_field
	show_toggle_button = TRUE

/obj/item/rig_module/personal_shield
	show_toggle_button = TRUE

/obj/item/rig_module/electrowarfare_suite
	show_toggle_button = TRUE

/obj/item/rig_module/device/flash
	show_toggle_button = TRUE



/obj/item/rig/Process()

	// If we've lost any parts, grab them back.
	var/mob/living/M
	for(var/obj/item/piece in list(gloves,boots,helmet,chest))
		if(piece.loc != src && !(wearer && piece.loc == wearer))
			if(istype(piece.loc, /mob/living))
				M = piece.loc
				M.drop_from_inventory(piece)
			piece.forceMove(src)

	var/changed = update_offline()
	if(changed)
		if(offline)
			//notify the wearer
			if(!canremove)
				if (offline_slowdown < 3)
					to_chat(wearer, SPAN_DANGER("Your suit beeps stridently, and suddenly goes dead."))
				else
					to_chat(wearer, SPAN_DANGER("Your suit beeps stridently, and suddenly you're wearing a leaden mass of metal and plastic composites instead of a powered suit."))
			if(offline_vision_restriction >= TINT_MODERATE)
				to_chat(wearer, SPAN_DANGER("The suit optics flicker and die, leaving you with restricted vision."))
			else if(offline_vision_restriction >= TINT_BLIND)
				to_chat(wearer, SPAN_DANGER("The suit optics drop out completely, drowning you in darkness."))

			if(electrified > 0)
				electrified = 0
			for(var/obj/item/rig_module/module in installed_modules)
				module.deactivate()
		else
			if(istype(wearer) && !wearer.wearing_rig)
				wearer.wearing_rig = src
				for(var/obj/item/rig_module/module in installed_modules)
					if(module.activate_on_start)
						module.activate()

		set_slowdown_and_vision(!offline)
		if(istype(chest))
			chest.check_limb_support(wearer)

	if(!offline)
		if(cell && cell.charge > 0 && electrified > 0)
			electrified--

		if(malfunction_delay > 0)
			malfunction_delay--
		else if(malfunctioning)
			malfunctioning--
			malfunction()

		for(var/obj/item/rig_module/module in installed_modules)
			if(!cell.checked_use(module.Process() * CELLRATE))
				module.deactivate()//turns off modules when your cell is dry


/obj/item/rig_module/chem_dispenser/engage(atom/target)
	if(!isturf(holder.wearer.loc) && target)
		return FALSE

	if(!..())
		return FALSE

	if(!charge_selected)
		to_chat(holder.wearer, "<span class='danger'>You have not selected a chemical type.</span>")
		return FALSE

	return use_charge(charge_selected, target)

/obj/item/rig_module/chem_dispenser/proc/use_charge(charge_selected, atom/target, show_warnings = TRUE)
	var/mob/living/carbon/human/H = holder.wearer

	var/datum/rig_charge/charge = charges[charge_selected]
	if(damage > MODULE_NO_DAMAGE && prob(40))
		to_chat(H, "<span class='warning'>[name] malfunctions and injects wrong chemical!</span>")
		charge = charges[pick(charges)]

	if(!charge)
		return FALSE

	var/chems_to_use = 10
	if(charge.charges <= 0)
		if(show_warnings)
			to_chat(H, "<span class='danger'>Insufficient chems!</span>")
		return FALSE
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/carbon/target_mob
	if(target)
		if(iscarbon(target))
			target_mob = target
		else
			return FALSE
	else
		target_mob = H

	if(target_mob != H)
		to_chat(H, "<span class='danger'>You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name].</span>")
	to_chat(target_mob, "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>")
	target_mob.reagents.add_reagent(charge.product_type, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0)
		charge.charges = 0
	return TRUE
