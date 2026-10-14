//Signals

// Mob
#define COMSIG_KB_MOB_PIXEL_SHIFT_DOWN "keybinding_mob_pixel_shift_down"
#define COMSIG_KB_MOB_PIXEL_SHIFT_UP "keybinding_mob_pixel_shift_up"

/datum/keybinding/living/pixel_shift
	hotkey_keys = list("V")
	classic_keys = list("None")
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Hold to pixel shift with movement keys"

/datum/keybinding/living/pixel_shift/down(client/user)
	if(!(SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN) & COMSIG_KB_ACTIVATED))
		user.mob.AddComponent(/datum/component/pixel_shift)

/datum/keybinding/living/pixel_shift/up(client/user)
	SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
