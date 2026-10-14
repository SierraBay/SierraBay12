/obj/item/is_held_twohanded(mob/living/M)
	var/obj/item/material/twohanded/melee = src
	if(istype(melee) && !istype(melee, /obj/item/material/twohanded/offhand))
		return melee.wielded

	if(istype(loc, /obj/item/rig_module) || istype(loc, /obj/item/rig))
		return TRUE

	var/check_hand
	var/obj/item/other_hand
	if(M.l_hand == src)
		other_hand = M.r_hand
		check_hand = BP_R_HAND
	else if(M.r_hand == src)
		other_hand = M.l_hand
		check_hand = BP_L_HAND
	else
		return FALSE

	if(other_hand)
		var/obj/item/offhand_grip/grip = other_hand
		if(!istype(grip) || grip.wielding != src)
			return FALSE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
		if(istype(hand) && hand.is_usable())
			return TRUE
	return FALSE

/obj/item/zoom(mob/user, tileoffset = 14, viewsize = 9)
	if(!user.client)
		return
	if(zoom)
		return

	if(!user.loc?.MayZoom())
		return

	var/devicename = zoomdevicename || name
	var/is_distracted = FALSE
	var/mob/living/carbon/human/H = user

	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, SPAN_WARNING("You are unable to focus through the [devicename]."))
		return
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, SPAN_WARNING("Your eyewear gets in the way of looking through the [devicename]."))
		return
	if(H)
		is_distracted = !zoom && H.get_active_hand() != src && H.get_equipped_item(slot_glasses) != src
	else
		is_distracted = !zoom && user.get_active_hand() != src
	if(is_distracted)
		var/obj/item/offhand_grip/grip = user.get_active_hand()
		if(istype(grip) && grip.wielding == src)
			is_distracted = FALSE
	if(is_distracted)
		to_chat(user, SPAN_WARNING("You are too distracted to look through the [devicename]. Perhaps if it was in your active hand this might work better."))
		return

	var/viewoffset = WORLD_ICON_SIZE * tileoffset
	switch(user.dir)
		if(NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = viewoffset
		if(SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -viewoffset
		if(EAST)
			user.client.pixel_x = viewoffset
			user.client.pixel_y = 0
		if(WEST)
			user.client.pixel_x = -viewoffset
			user.client.pixel_y = 0

	if(user.hud_used.hud_shown)
		user.toggle_zoom_hud()
	if(istype(H))
		H.handle_vision()

	user.client.view = viewsize
	zoom = 1
	user.client.viewoffset = TRUE

	GLOB.destroyed_event.register(src, src, TYPE_PROC_REF(/obj/item, unzoom))
	GLOB.moved_event.register(user, src, TYPE_PROC_REF(/obj/item, unzoom))
	GLOB.dir_set_event.register(user, src, TYPE_PROC_REF(/obj/item, unzoom))
	GLOB.item_unequipped_event.register(src, user, TYPE_PROC_REF(/mob/living, unzoom))

	GLOB.stat_set_event.register(user, src, TYPE_PROC_REF(/obj/item, unzoom))

	user.visible_message("\The [user] peers through [zoomdevicename ? "the [zoomdevicename] of [src]" : "[src]"].")
