/datum/keybinding/living
	category = KEYBINDING_CATEGORY_HUMAN


/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


/datum/keybinding/living/rest
	hotkey_keys = list("ShiftB")
	classic_keys = list("None")
	name = "rest"
	full_name = "Rest"
	description = "You lay down/get up"


/datum/keybinding/living/rest/down(client/user)
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE

/datum/keybinding/mob/face_direction
	hotkey_keys = list("F")
	classic_keys = list("None")
	name = "face_direction"
	full_name = "Face Direction"
	description = "Block dir"

/datum/keybinding/mob/face_direction/down(client/user)
	var/mob/living/L = user.mob
	L.face_direction()
	return TRUE

/datum/keybinding/living/resist
	hotkey_keys = list("B")
	classic_keys = list("None")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? On fire? Resist!"


/datum/keybinding/living/resist/down(client/user)
	var/mob/living/L = user.mob
	L.resist()
	return TRUE


/datum/keybinding/living/drop_item
	hotkey_keys = list("Q", "Northwest") // HOME
	classic_keys = list("Northwest")
	name = "drop_item"
	full_name = "Drop Item"
	description = ""


/datum/keybinding/living/drop_item/down(client/user)
	user.drop_item()
	return TRUE
