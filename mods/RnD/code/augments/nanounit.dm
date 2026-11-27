// Nanite MCU, core type in code/modules/augment/passive/nanoaura.dm.
// The action button shows how many more projectile hits the nanites can stop.
// The charges never refill, and the hit after the last one breaks the aura.

/obj/item/organ/internal/augment/active/nanounit/activate()
	..()
	refresh_action_button()

/obj/item/organ/internal/augment/active/nanounit/catastrophic_failure()
	..()
	refresh_action_button()

/// White while asleep, cyan while active, red once the next hit breaks the aura.
/obj/item/organ/internal/augment/active/nanounit/get_action_button_label()
	if(!aura)
		return create_action_button_label("OFF", COLOR_RED_LIGHT)
	if(charges <= 0)
		return create_action_button_label("0", COLOR_RED_LIGHT)
	return create_action_button_label("[charges]", aura.active ? COLOR_CYAN : COLOR_WHITE)

/obj/aura/nanoaura/aura_check_bullet(obj/item/projectile/proj, def_zone)
	. = ..()
	// Null once the hit broke the aura; catastrophic_failure() redraws then
	unit?.refresh_action_button()
