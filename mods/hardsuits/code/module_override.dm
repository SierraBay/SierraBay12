/obj/item/rig_module
	var/activate_on_start               // Set to TRUE for the device to automatically activate on suit equip
	var/mount_type = 0                  // What mounts does this module use
	var/show_toggle_button              // Set to TRUE for the device to show toggle button


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
