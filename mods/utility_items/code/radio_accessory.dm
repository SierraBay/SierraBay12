/// Clip-on shortwave: radio is a clothing accessory, same path as goggle mods / other action accessories.

/obj/item/device/radio/get_inv_overlay()
	if (!inv_overlay)
		inv_overlay = image(icon = 'mods/utility_items/icons/radio_accessory.dmi', icon_state = "accessories_radio", dir = SOUTH)
	inv_overlay.color = color
	return inv_overlay


/obj/item/device/radio/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/nanoui/master_ui = null, datum/topic_state/state = null)
	if (isnull(state))
		state = parent ? GLOB.deep_inventory_state : GLOB.default_state
	return ..(user, ui_key, ui, force_open, master_ui, state)


// Non-handheld radios must not clip onto clothing or show an action button.
/obj/item/device/radio/headset
	slot = null
	action_button_name = null

/obj/item/device/radio/intercom
	slot = null
	action_button_name = null

/obj/item/device/radio/borg
	slot = null
	action_button_name = null

/obj/item/device/radio/phone
	slot = null
	action_button_name = null

/obj/item/device/radio/electropack
	slot = null
	action_button_name = null

/obj/item/device/radio/announcer
	slot = null
	action_button_name = null

/obj/item/device/radio/exosuit
	slot = null
	action_button_name = null


/proc/get_first_clipped_radio(mob/living/user)
	if (!istype(user))
		return null
	for (var/obj/item/clothing/C in user.get_equipped_items())
		for (var/obj/item/clothing/accessory/A in C.accessories)
			var/obj/item/device/radio/R = A
			if (istype(R) && R.slot)
				return R
	return null
