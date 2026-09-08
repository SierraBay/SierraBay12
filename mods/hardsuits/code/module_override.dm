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
		to_chat(holder.wearer, SPAN_DANGER("You have not selected a chemical type."))
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
			to_chat(H, SPAN_DANGER("Insufficient chems!"))
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
		to_chat(H, SPAN_DANGER("You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name]."))
	to_chat(target_mob, SPAN_DANGER("You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected."))
	target_mob.reagents.add_reagent(charge.product_type, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0)
		charge.charges = 0
	return TRUE


/obj/item/rig/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return TRUE

	// Lock or unlock the access panel.
	if(W.GetIdCard())
		if(subverted)
			locked = 0
			to_chat(user, SPAN_DANGER("It looks like the locking system has been shorted out."))
			return TRUE

		if(!length(req_access))
			locked = 0
			to_chat(user, SPAN_DANGER("\The [src] doesn't seem to have a locking mechanism."))
			return TRUE

		if(security_check_enabled && !src.allowed(user))
			to_chat(user, SPAN_DANGER("Access denied."))
			return TRUE

		locked = !locked
		to_chat(user, "You [locked ? "lock" : "unlock"] \the [src] access panel.")
		return TRUE

	if (isCrowbar(W))

		if(!open && locked)
			to_chat(user, SPAN_WARNING("The access panel is locked shut."))
			return TRUE

		open = !open
		to_chat(user, "You [open ? "open" : "close"] the access panel.")
		return TRUE

	if (isScrewdriver(W))
		p_open = !p_open
		to_chat(user, "You [p_open ? "open" : "close"] the wire cover.")
		return TRUE

	// Hacking.
	if (isWirecutter(W) || isMultitool(W))
		if(p_open)
			wires.Interact(user)
		else
			to_chat(user, SPAN_WARNING("You can't reach the wiring."))
		return TRUE

	if(open)
		// Air tank.
		if(istype(W,/obj/item/tank)) //Todo, some kind of check for suits without integrated air supplies.

			if(air_supply)
				to_chat(user, SPAN_WARNING("\The [src] already has a tank installed."))
				return TRUE
			if (istype(W, /obj/item/tank/scrubber))
				to_chat(user, SPAN_WARNING("\The [W] is far too large to attach to \the [src]."))
				return TRUE
			if(!user.unEquip(W))
				FEEDBACK_UNEQUIP_FAILURE(user, W)
				return TRUE
			air_supply = W
			W.forceMove(src)
			to_chat(user, "You slot \the [W] into \the [src] and tighten the connecting valve.")
			return TRUE

		// Check if this is a hardsuit upgrade or a modification.
		if (istype(W,/obj/item/rig_module))
			var/obj/item/rig_module/mod = W
			if (!mod.can_install(src, user))
				return TRUE

			to_chat(user, "You begin installing \the [mod] into \the [src].")
			if(!do_after(user, 4 SECONDS, src, DO_PUBLIC_UNIQUE))
				return TRUE
			if(!user || !W || !mod.can_install(src, user))
				return TRUE
			if(!user.unEquip(mod))
				FEEDBACK_UNEQUIP_FAILURE(user, mod)
				return TRUE
			to_chat(user, "You install \the [mod] into \the [src].")
			LAZYADD(installed_modules, mod)
			installed_modules |= mod
			mod.forceMove(src)
			mod.installed(src)
			update_icon()
			return TRUE

		if (!cell && istype(W,/obj/item/cell))

			if(!user.unEquip(W))
				FEEDBACK_UNEQUIP_FAILURE(user, W)
				return TRUE
			to_chat(user, "You jack \the [W] into \the [src]'s battery mount.")
			W.forceMove(src)
			cell = W
			return TRUE

		if (isWrench(W))
			var/list/current_mounts = list()
			if(cell) current_mounts   += "cell"
			if(air_supply) current_mounts += "tank"
			if(istype(chest, /obj/item/clothing/suit/space/rig))
				if (length(chest?.storage?.contents)) current_mounts += "storage"
			if(installed_modules && length(installed_modules)) current_mounts += "system module"
			var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
			if(!to_remove)
				return TRUE

			if(istype(src.loc,/mob/living/carbon/human) && to_remove != "cell" && to_remove != "tank")
				var/mob/living/carbon/human/H = src.loc
				if(H.back == src)
					to_chat(user, SPAN_WARNING("You can't remove an installed device while the hardsuit is being worn."))
					return TRUE

			switch(to_remove)
				if("cell")
					if(cell)
						to_chat(user, "You detach \the [cell] from \the [src]'s battery mount.")
						for(var/obj/item/rig_module/module in installed_modules)
							module.deactivate()
						user.put_in_hands(cell)
						cell = null
					else
						to_chat(user, "There is nothing loaded in that mount.")

				if("tank")
					if(!air_supply)
						to_chat(user, SPAN_WARNING("There is no tank to remove."))
						return TRUE

					user.put_in_hands(air_supply)
					to_chat(user, "You detach and remove \the [air_supply].")
					air_supply = null

				if ("storage")
					if (!length(chest?.storage?.contents))
						to_chat(user, SPAN_WARNING("There is nothing in the storage to remove."))
						return TRUE
					chest.storage.DoQuickEmpty()
					user.visible_message(
						SPAN_ITALIC("\The [user] ejects the contents of \a [src]'s storage."),
						SPAN_ITALIC("You eject the contents of \the [src]'s storage."),
						SPAN_ITALIC("You hear things clatter to the floor."),
						range = 5
					)

				if("system module")
					var/list/possible_removals = list()
					for(var/obj/item/rig_module/module in installed_modules)
						if(module.permanent)
							continue
						possible_removals[module.name] = module

					if(!LAZYLEN(possible_removals))
						to_chat(user, SPAN_WARNING("There are no installed modules to remove."))
						return TRUE

					var/removal_choice = input("Which module would you like to remove?") as null|anything in possible_removals
					if(!removal_choice)
						return TRUE

					var/obj/item/rig_module/removed = possible_removals[removal_choice]
					to_chat(user, "You detach \the [removed] from \the [src].")
					removed.dropInto(loc)
					removed.removed()
					installed_modules -= removed
					update_icon()
					return TRUE

		if (istype(W,/obj/item/stack/nanopaste)) //EMP repair
			var/obj/item/stack/S = W
			if(malfunctioning || malfunction_delay)
				if(S.use(1))
					to_chat(user, "You pour some of \the [S] over \the [src]'s control circuitry and watch as the nanites do their work with impressive speed and precision.")
					malfunctioning = 0
					malfunction_delay = 0
				else
					to_chat(user, "\The [S] is empty!")
			else
				to_chat(user, "You don't see any use for \the [S].")
			return TRUE

	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(W,user)) //Item is handled in this proc
			return TRUE

	// Pass repair items on to the chestpiece.
	if(chest && (istype(W,/obj/item/stack/material) || isWelder(W)))
		return chest.use_tool(W,user)


	return ..()
