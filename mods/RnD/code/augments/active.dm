/// Overrides

/datum/action/item_action/organ/augment
	button_icon = 'mods/RnD/icons/augment.dmi'

/// Knuckles
/obj/item/organ/internal/augment/active/item/knuckles
	name = "cybernetic knuckles"
	desc = "Reinforced frame of the prosthetic hand, which can be used to deliver powerful and fast blows."
	action_button_name = "Deploy knuckles"
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "knuckles"
	augment_slots = AUGMENT_HAND
	item = /obj/item/material/armblade/knuckles
	origin_tech = list(TECH_COMBAT = 3)
	deploy_sound = 'sound/items/metal_clicking_13.ogg'
	retract_sound = 'sound/items/metal_clicking_13.ogg'
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_SCANNABLE | AUGMENT_INSPECTABLE

/obj/item/material/armblade/knuckles
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "knuckles"
	item_state = "knuckles"
	item_icons = list(
		slot_r_hand_str = 'mods/RnD/icons/mob/righthand.dmi',
		slot_l_hand_str = 'mods/RnD/icons/mob/lefthand.dmi',
		)
	name = "cyberknuckles"
	desc = "Not brass, but knuckles."
	max_force = 16
	force_multiplier = 0.2
	base_parry_chance = 15
	attack_cooldown_modifier = -1
	sharp = FALSE
	edge = FALSE

/obj/item/device/augment_implanter/knuckles
	augment = /obj/item/organ/internal/augment/active/item/knuckles

/// Shield
/obj/item/organ/internal/augment/active/item/shield
	name = "energy shield projector"
	desc = "Energy shield projector integrated into cybernetic augment. Last argument when negotiations going not your way."
	action_button_name = "Deploy energy shield"
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "eshield"
	augment_slots = AUGMENT_ARM
	item = /obj/item/shield/energy
	origin_tech = list(TECH_COMBAT = 4, TECH_ESOTERIC = 5)
	deploy_sound = 'sound/obj/item/shield/energy/shield-start.ogg'
	retract_sound = 'sound/obj/item/shield/energy/shield-stop.ogg'
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_SCANNABLE

/obj/item/device/augment_implanter/energy_shield
	augment = /obj/item/organ/internal/augment/active/item/shield

/datum/uplink_item/item/augment/aug_energy_shield
	name = "Concealed Energy Shield CBM (arm)"
	desc = "An augment that slots deployable military grade Energy Shield. Can be easily deployed during firefight. \
	It is unconcealable from body-scanners, due it's energy capacitors. It requires NON-ORGANIC arms."
	item_cost = 36
	path = /obj/item/device/augment_implanter/energy_shield

/// Health Scanner
/obj/item/organ/internal/augment/active/item/scanner
	name = "integrated health scanner"
	desc = "Health scanner which can be intergated into arm. For cases when their insurance deserves it."
	action_button_name = "Deploy health scanner"
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "scanner"
	augment_slots = AUGMENT_ARM
	item = /obj/item/device/scanner/health
	origin_tech = list(TECH_BIO = 3)
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_SCANNABLE

/// IT HUD

/obj/item/organ/internal/augment/active/hud/it
	name = "integrated IT HUD"
	desc = "The DAIS Net-Q is an implantable HUD, designed to interface with the user's optic nerve and display information about surrounding devices."
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "eye_it"
	hud_type = HUD_IT

/obj/item/organ/internal/augment/active/hud/it/loadout
	name = "integrated IT HUD"
	desc = "Corporate issued Net-Q implantable HUD. This implant has a pre-installed access reading system."

/obj/item/organ/internal/augment/active/hud/it/loadout/activate()
	req_access = list(access_tcomsat)
	if (!can_activate())
		return
	if (!allowed(owner))
		to_chat(owner, SPAN_NOTICE("Your access is not sufficient to activate your HUD."))
		return
	active = !active
	to_chat(owner, SPAN_NOTICE("You [active ? "enable" : "disable"] \the [src]."))

/obj/item/device/augment_implanter/it_hud
	augment = /obj/item/organ/internal/augment/active/hud/it
