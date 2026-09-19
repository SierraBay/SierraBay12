/datum/keybinding/living/toggle_combat_mode
	hotkey_keys = list("G")
	name = "toggle_combat_mode"
	full_name = "Combat Mode"
	description = "Смотреть только туда, куда направлена мышь"

/datum/keybinding/living/toggle_combat_mode/down(client/user)
	var/mob/living/L = user.mob
	if(!istype(L))
		return FALSE
	L.toggle_combat_mode()
	return TRUE
