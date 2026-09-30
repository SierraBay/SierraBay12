#define TWOHAND_ICON 'mods/twohanding/icons/offhand.dmi'

/obj/item/gun
	var/obj/item/offhand_grip/twohand_grip
	var/twohand_busy = FALSE
	var/twohand_lowered = FALSE

/obj/item/gun/proc/can_twohand()
	return wielded_item_state || one_hand_penalty >= 4

/obj/item/gun/is_held_twohanded(mob/living/M)
	if(istype(loc, /obj/item/rig_module) || istype(loc, /obj/item/rig))
		return TRUE
	if(can_twohand())
		if(!twohand_grip || QDELETED(twohand_grip))
			return FALSE
		if(!M || (M.l_hand != twohand_grip && M.r_hand != twohand_grip))
			return FALSE
	return ..()

/obj/item/gun/proc/release_twohand()
	var/obj/item/offhand_grip/grip = twohand_grip
	twohand_grip = null
	if(grip && !QDELETED(grip))
		grip.wielding = null
		qdel(grip)

/obj/item/gun/proc/lower_twohand(mob/living/user)
	if(!can_twohand())
		return
	twohand_lowered = TRUE
	twohand_busy = TRUE
	release_twohand()
	twohand_busy = FALSE
	update_icon()
	if(user)
		to_chat(user, SPAN_NOTICE("You lower \the [src] to one hand. Alt-click it to brace it again."))

/obj/item/gun/proc/raise_twohand(mob/living/user)
	if(!can_twohand())
		return
	var/was_lowered = twohand_lowered
	twohand_lowered = FALSE
	if(refresh_twohand())
		update_icon()
		return
	twohand_lowered = was_lowered
	if(user)
		to_chat(user, SPAN_WARNING("You need a free hand to brace \the [src]."))

/obj/item/gun/AltClick(mob/user)
	if(can_twohand() && (user.l_hand == src || user.r_hand == src))
		if(twohand_lowered || !twohand_grip)
			raise_twohand(user)
		else
			lower_twohand(user)
		return TRUE
	return ..()

// Puts a grip in the free hand for guns that are meant to be shouldered or braced.
// Returns TRUE if the grip was added or removed.
/obj/item/gun/proc/refresh_twohand()
	if(twohand_busy)
		return FALSE
	if(twohand_lowered)
		if(twohand_grip)
			release_twohand()
			return TRUE
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!can_twohand() || !ishuman(user) || (user.l_hand != src && user.r_hand != src))
		if(twohand_grip)
			release_twohand()
			return TRUE
		return FALSE

	if(twohand_grip && !QDELETED(twohand_grip) && (user.l_hand == twohand_grip || user.r_hand == twohand_grip))
		return FALSE
	if(twohand_grip)
		release_twohand()

	var/check_hand
	if(user.l_hand == src && !user.r_hand)
		check_hand = BP_R_HAND
	else if(user.r_hand == src && !user.l_hand)
		check_hand = BP_L_HAND
	else
		return FALSE

	if(!user.can_wield_item(src))
		return FALSE
	var/obj/item/organ/external/hand = user.organs_by_name[check_hand]
	if(!istype(hand) || !hand.is_usable())
		return FALSE

	twohand_busy = TRUE
	var/obj/item/offhand_grip/grip = new()
	grip.wielding = src
	grip.SetName("grip on \the [name]")
	grip.desc = "Your other hand, braced on \the [src]."
	twohand_grip = grip
	var/placed = FALSE
	if(user.l_hand == src)
		placed = user.put_in_r_hand(grip)
	else
		placed = user.put_in_l_hand(grip)
	twohand_busy = FALSE
	if(!placed)
		twohand_grip = null
		grip.wielding = null
		qdel(grip)
		return FALSE

	user.visible_message(SPAN_NOTICE("\The [user] braces \the [src] with both hands."), SPAN_NOTICE("You brace \the [src] with both hands."))
	return TRUE

// Space: rack a manual action, or switch fire mode. Single-mode guns keep unload on the use-item key.
/obj/item/gun/proc/hotkey_action(mob/user)
	if(length(firemodes) > 1)
		attack_self(user)
		return TRUE
	return FALSE

/obj/item/gun/projectile/shotgun/pump/hotkey_action(mob/user)
	attack_self(user)
	return TRUE

/obj/item/gun/projectile/heavysniper/hotkey_action(mob/user)
	attack_self(user)
	return TRUE

/obj/item/gun/update_twohanding()
	if(refresh_twohand())
		update_icon()
		return
	return ..()

/obj/item/gun/ui_action_click(mob/living/user)
	if(scope_zoom)
		toggle_scope(user, scope_zoom)
		return
	return ..()

/datum/action/item_action/scope
	action_type = AB_ITEM_USE_ICON
	button_overlay_icon = TWOHAND_ICON
	button_icon_state = "scope"
	name = "Use Scope"

/obj/item/gun/Destroy()
	release_twohand()
	return ..()

/obj/item/offhand_grip
	name = "offhand"
	desc = "Your other hand."
	icon = TWOHAND_ICON
	icon_state = "offhand"
	w_class = ITEM_SIZE_HUGE
	slot_flags = 0
	canremove = FALSE
	var/obj/item/wielding

/obj/item/offhand_grip/get_mob_overlay(mob/user_mob, slot)
	return null

/obj/item/offhand_grip/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/offhand_grip/can_use_item(obj/item/tool, mob/living/user, click_params)
	return tool == wielding

/obj/item/offhand_grip/proc/release_for(mob/living/user)
	var/obj/item/gun/gun = wielding
	if(istype(gun))
		gun.lower_twohand(user)

/obj/item/offhand_grip/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(tool == wielding)
		release_for(user)
		return TRUE
	return ..()

/obj/item/offhand_grip/use_weapon(obj/item/weapon, mob/living/user, list/click_params)
	if(weapon == wielding)
		release_for(user)
		return TRUE
	return ..()

/obj/item/offhand_grip/resolve_attackby(atom/A, mob/living/user, click_params)
	if(wielding && !QDELETED(wielding))
		if(A == wielding)
			return TRUE
		return wielding.resolve_attackby(A, user, click_params)
	return ..()

/obj/item/offhand_grip/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(wielding && !QDELETED(wielding) && target != wielding)
		wielding.afterattack(target, user, proximity_flag, click_parameters)
		return
	return ..()

/obj/item/offhand_grip/attack_self(mob/living/user)
	release_for(user)

/obj/item/offhand_grip/dropped(mob/user)
	var/obj/item/gun/gun = wielding
	wielding = null
	if(istype(gun) && gun.twohand_grip == src)
		gun.twohand_grip = null
	. = ..()
	if(!QDELING(src))
		qdel(src)

#undef TWOHAND_ICON
