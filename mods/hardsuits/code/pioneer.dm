/* PIONEER CORPS VOIDSUITS AND RIGS
 * ======== Used by Farfleet
 */

/obj/item/clothing/head/helmet/space/void/pioneer
	name = "pioneer corps voidsuit helmet"
	desc = "A somewhat old-fashioned helmet in bright colors. On the forehead you can see the inscription PC ICCG. This one has radiation shielding."
	icon = 'mods/hardsuits/icons/voidsuits/obj_head.dmi'
	icon_state = "pioneer"
	item_state = "pioneer"
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/voidsuits/onmob_head.dmi')
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	max_pressure_protection = ENG_VOIDSUIT_MAX_PRESSURE
	siemens_coefficient = 0.3

/obj/item/clothing/suit/space/void/pioneer
	name = "pioneer corps voidsuit"
	desc = "A somewhat old-fashioned voidsuit in bright colors. On the shoulder you can see the inscription PC ICCG. This one has radiation shielding."
	icon = 'mods/hardsuits/icons/voidsuits/obj_suit.dmi'
	icon_state = "pioneer"
	item_state = "pioneer"
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/voidsuits/onmob_suit.dmi')
	max_pressure_protection = ENG_VOIDSUIT_MAX_PRESSURE
	siemens_coefficient = 0.3
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/briefcase/inflatable,/obj/item/rcd,/obj/item/rpd, /obj/item/gun)

/obj/item/clothing/suit/space/void/pioneer/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pioneer
	boots = /obj/item/clothing/shoes/magboots
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/rig/pioneer
	name = "pioneer corps suit control module"
	desc = "A ridiculously bulky military hardsuit with PC-13AA inscription and a small ICCG crest on its control module. This suit's armor plates mostly replaced with anomaly and radiation shielding."
	icon = 'mods/hardsuits/icons/rigs/rig_modules.dmi'
	suit_type = "heavy"
	icon_state = "gcc_rig"
	online_slowdown = 2 ///chunky
	offline_slowdown = 4
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_STRONG,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)
	initial_modules = list(
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/chem_dispenser,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/device/anomaly_scanner,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/maneuvering_jets
		)

	chest_type = /obj/item/clothing/suit/space/rig/pioneer
	helm_type =  /obj/item/clothing/head/helmet/space/rig/pioneer
	boot_type =  /obj/item/clothing/shoes/magboots/rig/pioneer
	glove_type = /obj/item/clothing/gloves/rig/pioneer

/obj/item/clothing/head/helmet/space/rig/pioneer
	light_overlay = "helmet_light_dual_alt"

/obj/item/clothing/suit/space/rig/pioneer
	breach_threshold = 40
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC)
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/handcuffs,
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/melee/baton
	)

/obj/item/clothing/gloves/rig/pioneer
	icon = 'mods/hardsuits/icons/rigs/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'mods/hardsuits/icons/rigs/onmob_hands.dmi')
	siemens_coefficient = 0

/obj/item/clothing/shoes/magboots/rig/pioneer
	icon = 'mods/hardsuits/icons/rigs/obj_feet.dmi'
	item_icons = list(slot_shoes_str = 'mods/hardsuits/icons/rigs/onmob_feet.dmi')

/obj/item/clothing/head/helmet/space/rig/pioneer
	icon = 'mods/hardsuits/icons/rigs/obj_head.dmi'
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/rigs/onmob_head.dmi')

/obj/item/clothing/suit/space/rig/pioneer
	icon = 'mods/hardsuits/icons/rigs/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/rigs/onmob_suit.dmi')

/obj/item/rig/pioneer/sergeant
	name = "pioneer corps sergeant suit control module"
	desc = "A ridiculously bulky military hardsuit with PC-13AS inscription and a small ICCG crest on its control module. This suit's armor plates mostly replaced with anomaly and radiation shielding."
	suit_type = "heavy"

	initial_modules = list(
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/chem_dispenser,
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/mounted/ballistic/minigun,
		/obj/item/rig_module/device/anomaly_scanner,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/maneuvering_jets
		)

/obj/item/rig/pioneer/on_update_icon(update_mob_icon)

	ClearOverlays()
	if(!mob_icon || update_mob_icon)
		var/species_icon = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi'
		if(wearer && sprite_sheets && sprite_sheets[wearer.species.get_bodytype(wearer)])
			species_icon =  sprite_sheets[wearer.species.get_bodytype(wearer)]
		mob_icon = image("icon" = species_icon, "icon_state" = "[icon_state]")

	if(equipment_overlay_icon && LAZYLEN(installed_modules))
		for(var/obj/item/rig_module/module in installed_modules)
			if(module.suit_overlay)
				var/overlay = image("icon" = equipment_overlay_icon, "icon_state" = "[module.suit_overlay]", "dir" = SOUTH)
				chest.AddOverlays(overlay)

	if(wearer)
		wearer.update_inv_shoes()
		wearer.update_inv_gloves()
		wearer.update_inv_head()
		wearer.update_inv_wear_mask()
		wearer.update_inv_wear_suit()
		wearer.update_inv_w_uniform()
		wearer.update_inv_back()
	return
