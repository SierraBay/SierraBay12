/obj/item/gun/Initialize()
	. = ..()
	if(scope_zoom)
		action_button_name = "Use Scope"
		default_action_type = /datum/action/item_action/scope

/obj/item/gun/on_update_icon()
	refresh_twohand()
	return ..()

/obj/item/gun/dropped(mob/living/user)
	twohand_lowered = FALSE
	twohand_busy = TRUE
	release_twohand()
	. = ..()
	twohand_busy = FALSE
	if(isliving(user) && action_button_name)
		user.handle_actions()

/obj/item/gun/switch_firemodes()
	. = ..()
	if(. && refresh_twohand())
		update_icon()

/obj/item/gun/equipped(mob/user, slot)
	if(slot != slot_l_hand && slot != slot_r_hand)
		twohand_busy = TRUE
		release_twohand()
	. = ..()
	twohand_busy = FALSE
	if(isliving(user) && action_button_name)
		var/mob/living/holder = user
		holder.handle_actions()
