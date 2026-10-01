#define TWOHAND_ICON 'mods/twohanding/icons/offhand.dmi'

/obj/item/material/twohanded
	var/obj/item/material/twohanded/offhand/offhand_item

/obj/item/material/twohanded/Destroy()
	if(offhand_item && !QDELETED(offhand_item))
		var/obj/item/material/twohanded/offhand/O = offhand_item
		offhand_item = null
		O.wielded_item = null
		qdel(O)
	return ..()

/obj/item/material/twohanded/proc/wield(mob/living/user, silent = FALSE)
	if(wielded || istype(src, /obj/item/material/twohanded/offhand))
		return FALSE
	if(!istype(user))
		return FALSE
	if(!user.can_wield_item(src))
		if(!silent)
			to_chat(user, SPAN_WARNING("\The [src] is too large for you to wield."))
		return FALSE
	if((user.l_hand == src && user.r_hand) || (user.r_hand == src && user.l_hand))
		if(!silent)
			to_chat(user, SPAN_WARNING("You need your other hand to be empty to wield \the [src]."))
		return FALSE

	var/check_hand
	if(user.l_hand == src)
		check_hand = BP_R_HAND
	else if(user.r_hand == src)
		check_hand = BP_L_HAND
	else
		check_hand = null
	if(!ishuman(user) || !check_hand)
		if(!silent)
			to_chat(user, SPAN_WARNING("You need both hands to wield \the [src]."))
		return FALSE
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
	if(!istype(hand) || !hand.is_usable())
		if(!silent)
			to_chat(user, SPAN_WARNING("You need both hands to wield \the [src]."))
		return FALSE

	wielded = 1
	force = force_wielded
	update_icon()

	var/obj/item/material/twohanded/offhand/O = new()
	var/placed = FALSE
	if(!QDELETED(O))
		O.SetName("[name] - offhand")
		O.desc = "Your second grip on \the [src]."
		O.wielded_item = src
		offhand_item = O
		if(user.l_hand == src)
			placed = user.put_in_r_hand(O)
		else if(user.r_hand == src)
			placed = user.put_in_l_hand(O)
	if(!placed)
		var/created = O && !QDELETED(O)
		if(created)
			offhand_item = null
			O.wielded_item = null
			qdel(O)
		wielded = 0
		force = force_unwielded
		update_icon()
		if(created && !silent)
			to_chat(user, SPAN_WARNING("You need your other hand to be empty to wield \the [src]."))
		return FALSE

	if(wieldsound)
		playsound(src, wieldsound, 25, TRUE)
	user.visible_message(SPAN_NOTICE("\The [user] grips \the [src] with both hands."), SPAN_NOTICE("You grip \the [src] with both hands."))
	return TRUE

/obj/item/material/twohanded/proc/unwield(mob/living/user, silent = FALSE)
	if(!wielded)
		return FALSE
	wielded = 0
	force = force_unwielded

	var/obj/item/material/twohanded/offhand/O = offhand_item
	offhand_item = null
	if(O && !QDELETED(O))
		O.wielded_item = null
		qdel(O)

	if(!QDELING(src))
		update_icon()
		if(unwieldsound)
			playsound(src, unwieldsound, 25, TRUE)
		if(user && !silent)
			var/datum/pronouns/pronouns = user.choose_from_pronouns()
			user.visible_message(SPAN_NOTICE("\The [user] loosens [pronouns.his] grip on \the [src]."), SPAN_NOTICE("You loosen your grip on \the [src]. Alt-click it to grip it again."))
	return TRUE

/obj/item/material/twohanded/AltClick(mob/user)
	if(istype(src, /obj/item/material/twohanded/offhand))
		var/obj/item/material/twohanded/offhand/O = src
		if(O.wielded_item && !QDELETED(O.wielded_item))
			return O.wielded_item.AltClick(user)
		return ..()
	if(user.l_hand == src || user.r_hand == src)
		if(wielded)
			unwield(user)
		else
			wield(user)
		return TRUE
	return ..()

/obj/item/material/twohanded/attack_self(mob/living/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/material/twohanded/equipped(mob/user, slot)
	. = ..()
	if(istype(src, /obj/item/material/twohanded/offhand))
		return
	if(slot == slot_l_hand || slot == slot_r_hand)
		if(!wielded)
			wield(user)
	else if(wielded)
		unwield(user)

/obj/item/material/twohanded/dropped(mob/user)
	if(wielded)
		unwield(user, TRUE)
	return ..()

/obj/item/material/twohanded/pickup(mob/user)
	..()
	if(wielded)
		unwield(user, TRUE)

/obj/item/material/twohanded/offhand
	name = "offhand"
	desc = "Your second grip."
	icon = TWOHAND_ICON
	icon_state = "offhand"
	w_class = ITEM_SIZE_HUGE
	slot_flags = 0
	canremove = FALSE
	applies_material_colour = FALSE
	applies_material_name = FALSE
	unbreakable = TRUE
	drops_debris = FALSE
	force = 0
	throwforce = 0
	var/obj/item/material/twohanded/wielded_item

/obj/item/material/twohanded/offhand/update_force()
	force = 0
	throwforce = 0
	force_wielded = 0
	force_unwielded = 0

/obj/item/material/twohanded/offhand/on_update_icon()
	icon_state = "offhand"

/obj/item/material/twohanded/offhand/get_mob_overlay(mob/user_mob, slot)
	return null

/obj/item/material/twohanded/offhand/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/material/twohanded/offhand/resolve_attackby(atom/A, mob/living/user, click_params)
	if(wielded_item && !QDELETED(wielded_item))
		if(A == wielded_item)
			return TRUE
		return wielded_item.resolve_attackby(A, user, click_params)
	return ..()

/obj/item/material/twohanded/offhand/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(wielded_item && !QDELETED(wielded_item) && target != wielded_item)
		wielded_item.afterattack(target, user, proximity_flag, click_parameters)
		return
	return ..()

/obj/item/material/twohanded/offhand/attack_self(mob/living/user)
	if(wielded_item && !QDELETED(wielded_item))
		wielded_item.unwield(user)
		return
	if(!QDELING(src))
		qdel(src)

/obj/item/material/twohanded/offhand/can_use_item(obj/item/tool, mob/living/user, click_params)
	return FALSE

/obj/item/material/twohanded/offhand/shatter()
	qdel(src)

/obj/item/material/twohanded/offhand/dropped(mob/user)
	. = ..()
	var/obj/item/material/twohanded/W = wielded_item
	wielded_item = null
	if(W && !QDELETED(W))
		W.offhand_item = null
		W.unwield(user)
	if(!QDELING(src))
		qdel(src)

/obj/item/material/twohanded/offhand/Destroy()
	var/obj/item/material/twohanded/W = wielded_item
	wielded_item = null
	if(W && !QDELETED(W))
		if(W.offhand_item == src)
			W.offhand_item = null
		if(W.wielded)
			W.unwield(null, TRUE)
	return ..()

#undef TWOHAND_ICON
