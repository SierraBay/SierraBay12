/// Overrides

/datum/action/item_action/organ/augment
	button_icon = 'mods/augments/icons/augment.dmi'

/// Knuckles
/obj/item/organ/internal/augment/active/item/knuckles
	name = "cybernetic knuckles"
	desc = "Reinforced frame of the prosthetic hand, which can be used to deliver powerful and fast blows."
	action_button_name = "Deploy knuckles"
	icon = 'mods/augments/icons/augment.dmi'
	icon_state = "knuckles"
	augment_slots = AUGMENT_HAND
	item = /obj/item/material/armblade/knuckles
	origin_tech = list(TECH_COMBAT = 3)
	deploy_sound = 'sound/items/metal_clicking_13.ogg'
	retract_sound = 'sound/items/metal_clicking_13.ogg'
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_SCANNABLE | AUGMENT_INSPECTABLE

/obj/item/material/armblade/knuckles
	icon = 'mods/augments/icons/augment.dmi'
	icon_state = "knuckles"
	item_state = "knuckles"
	name = "integrated knuckles"
	desc = "Not brass, but knuckles."
	max_force = 15
	force_multiplier = 0.2
	base_parry_chance = 15
	attack_cooldown_modifier = -1


/// Shield
/obj/item/organ/internal/augment/active/item/shield
	name = "energy shield projector"
	desc = "Energy shield projector integrated into cybernetic augment. Last argument when negotiations going not your way."
	action_button_name = "Deploy energy shield"
	icon = 'mods/augments/icons/augment.dmi'
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
	icon = 'mods/augments/icons/augment.dmi'
	icon_state = "scanner"
	augment_slots = AUGMENT_ARM
	item = /obj/item/device/scanner/health
	origin_tech = list(TECH_BIO = 3)
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_SCANNABLE

/// Snake
/obj/item/organ/internal/augment/active/item/cybersnake
	name = "cybersnake implant"
	desc = "A dubious augmentation from any point of view. Cybernetic snake, installed directly in the stomach. Crawls out of the mouth and is used as a deadly weapon."
	action_button_name = "Extract snake"
	icon_state = "popout_shotgun"
	augment_slots = AUGMENT_GROIN
	item = /obj/item/clothing/mask/cybersnake
	origin_tech = list(TECH_MATERIAL = 3, TECH_COMBAT = 3, TECH_ESOTERIC = 4)
	deploy_sound = 'sound/weapons/guns/interaction/rifle_boltback.ogg'
	retract_sound = 'sound/weapons/guns/interaction/rifle_boltforward.ogg'
	augment_flags = AUGMENT_MECHANICAL | AUGMENT_BIOLOGICAL

/obj/item/clothing/mask/cybersnake
	name = "cybersnake"
	desc = "Cybernetic snake, emerging from mouth. Looks both disgusting and disturbing, moving like real, organic snake, ready to bite."
	icon_state = "cybersnake"
	item_state = "cybersnake"
	icon = 'mods/augments/icons/augments_obj.dmi'
	attack_verb = list("bited")
	force = 1
	w_class = 3
	item_flags = null
	slot_flags = SLOT_HEAD | SLOT_MASK
	matter = list("steel" = 5000)
