/proc/twohand_held_weapon(mob/living/user)
	var/obj/item/held = user.get_active_hand()
	if(!held)
		return null
	var/obj/item/offhand_grip/grip = held
	if(istype(grip))
		return grip.wielding
	var/obj/item/material/twohanded/offhand/melee_grip = held
	if(istype(melee_grip))
		return melee_grip.wielded_item
	return held

/mob/living/proc/toggle_twohand_grip()
	var/obj/item/held = twohand_held_weapon(src)
	var/obj/item/material/twohanded/melee = held
	if(istype(melee) && !istype(melee, /obj/item/material/twohanded/offhand))
		if(melee.wielded)
			melee.unwield(src)
		else
			melee.wield(src)
		return TRUE
	var/obj/item/gun/gun = held
	if(istype(gun) && gun.can_twohand())
		if(gun.twohand_lowered || !gun.twohand_grip)
			gun.raise_twohand(src)
		else
			gun.lower_twohand(src)
		return TRUE
	return FALSE

/mob/living/proc/gun_hotkey_action()
	var/obj/item/gun/gun = twohand_held_weapon(src)
	if(!istype(gun))
		return FALSE
	return gun.hotkey_action(src)

// Z is still Activate In-Hand. On Z, two-hand weapons take the grip. Y and PageDown keep using the item.
/datum/keybinding/mob/activate_inhand/down(client/user)
	if(user.keys_held["Z"] || user.keys_held["z"])
		var/mob/living/M = user.mob
		if(istype(M) && M.toggle_twohand_grip())
			return TRUE
	return ..()

/datum/keybinding/mob/gun_action
	hotkey_keys = list("Space")
	name = "gun_action"
	full_name = "Rack / Switch Firemode"
	description = "Racks a pump or bolt, or switches the fire mode of a gun in hand"
	category = "HUMAN"

/datum/keybinding/mob/gun_action/down(client/user)
	var/mob/living/M = user.mob
	if(!istype(M))
		return FALSE
	return M.gun_hotkey_action()
