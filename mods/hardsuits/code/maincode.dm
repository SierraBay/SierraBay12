/obj/item/clothing/suit/space/rig/proc/give_actions(mob/living/carbon/human/H)
	var/obj/item/rig/suit = H.back
	for(var/obj/item/rig_module/module in suit.installed_modules)
		if(module.selectable)
			var/datum/action/module_select/action = new(module)
			action.Grant(H)
		if(module.show_toggle_button)
			var/datum/action/module_toggle/action = new(module)
			action.Grant(H)

/obj/item/clothing/suit/space/rig/proc/remove_actions(mob/living/carbon/human/H)
	for(var/datum/action/module_select/action in H.actions)
		if(istype(action))
			action.Remove(H)
	for(var/datum/action/module_toggle/action in H.actions)
		if(istype(action))
			action.Remove(H)

/obj/item/clothing/suit/space/rig/equipped(mob/M)
	check_limb_support(M)
	give_actions(M)
	..()


/obj/item/clothing/suit/space/rig/dropped(mob/user)
	check_limb_support(user)
	remove_actions(user)
	..()


/obj/item/rig/proc/update_selected_action()
	if(!wearer)
		return

	var/mob/living/carbon/human/H = wearer
	for(var/datum/action/module_select/action in H.actions)
		if(istype(action))
			if(selected_module == action.target) // highlight selected module
				action.background_icon_state = "bg_spell"
			else
				action.background_icon_state = "bg_default"
	H.update_action_buttons()


/obj/item/rig/proc/update_activated_actions()
	if(!wearer)
		return

	var/mob/living/carbon/human/H = wearer
	for(var/datum/action/module_toggle/action in H.actions)
		if(istype(action))
			var/obj/item/rig_module/module = action.target
			if(istype(module))
				if(module.active) // highlight active modules
					action.background_icon_state = "bg_spell"
					action.name = module.deactivate_string
				else
					action.background_icon_state = "bg_default"
					action.name = module.activate_string
	H.update_action_buttons()

// Proc for toggling on active abilities.
/obj/item/rig_module/proc/activate()

	if(active || !engage())
		return FALSE

	active = 1

	if(suit_overlay_active)
		suit_overlay = suit_overlay_active
	else
		suit_overlay = null
	holder.update_icon()

	if(show_toggle_button)
		holder.update_activated_actions()

	return 1

// Proc for toggling off active abilities.
/obj/item/rig_module/proc/deactivate()

	if(!active)
		return FALSE

	active = 0

	if(suit_overlay_inactive)
		suit_overlay = suit_overlay_inactive
	else
		suit_overlay = null
	if(holder)
		holder.update_icon()

	if(show_toggle_button)
		holder.update_activated_actions()

	return 1

//Repair a certain amount of brute or burn damage to the suit.
/obj/item/clothing/suit/space/proc/repair_breaches(damtype, amount, mob/user, stop_messages = FALSE)

	if(!can_breach || !breaches || !LAZYLEN(breaches) || !damage)
		if(!stop_messages)
			to_chat(user, "There are no breaches to repair on \the [src].")
		return

	var/list/valid_breaches = list()

	for(var/datum/breach/B in breaches)
		if(B.damtype == damtype)
			valid_breaches += B

	if(!LAZYLEN(valid_breaches))
		if(!stop_messages)
			to_chat(user, "There are no breaches to repair on \the [src].")
		return

	var/amount_left = amount
	for(var/datum/breach/B in valid_breaches)
		if(!amount_left) break

		if(B.class <= amount_left)
			amount_left -= B.class
			valid_breaches -= B
			breaches -= B
		else
			B.class	-= amount_left
			amount_left = 0
			B.update_descriptor()

	if(!stop_messages)
		user.visible_message("<b>[user]</b> patches some of the damage on \the [src].")
	calc_breach_damage()
