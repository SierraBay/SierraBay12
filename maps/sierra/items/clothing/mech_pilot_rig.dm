/obj/item/rig/mech_pilot
	name = "Mech pilot control module"
	suit_type = "Mech pilot hardsuit"
	desc = "A security hardsuit designed for mech pilots."
	icon = 'mods/hardsuits/icons/rigs/rig_modules.dmi'
	item_icons = list(slot_back_str = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi')
	on_turf_icon = 'mods/hardsuits/icons/rigs/on_floor.dmi'
	icon_state = "mech_pilot"
	offline_vision_restriction = TINT_NONE
	item_icons = list(
		slot_l_hand_st = 'mods/hardsuits/icons/rigs/l_hand.dmi',
		slot_r_hand_str = 'mods/hardsuits/icons/rigs/r_hand.dmi'
	)


	helm_type = /obj/item/clothing/head/helmet/space/rig/mech_pilot
	chest_type = /obj/item/clothing/suit/space/rig/mech_pilot
	glove_type = /obj/item/clothing/gloves/rig/mech_pilot
	boot_type = /obj/item/clothing/shoes/magboots/rig/mech_pilot
	online_slowdown = 0
	offline_slowdown = 1
	req_access = list(access_mech_security)
	initial_modules = list(
		/obj/item/rig_module/vision/sechud,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/cooling_unit
	)



/obj/item/clothing/head/helmet/space/rig/mech_pilot
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/security
	icon = 'mods/hardsuits/icons/rigs/obj_head.dmi'
	icon_state = "mech_pilot"
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/rigs/onmob_head.dmi')


/obj/item/clothing/suit/space/rig/mech_pilot
	icon = 'mods/hardsuits/icons/rigs/obj_suit.dmi'
	icon_state = "mech_pilot"
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/rigs/onmob_suit.dmi')
	armor = list(
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_MINOR
	)
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


/obj/item/clothing/gloves/rig/mech_pilot
	icon = 'mods/hardsuits/icons/rigs/obj_hands.dmi'
	icon_state = "mech_pilot"
	item_icons = list(slot_gloves_str = 'mods/hardsuits/icons/rigs/onmob_hands.dmi')


/obj/item/clothing/shoes/magboots/rig/mech_pilot
	icon = 'mods/hardsuits/icons/rigs/obj_feet.dmi'
	icon_state = "mech_pilot"
	item_icons = list(slot_shoes_str = 'mods/hardsuits/icons/rigs/onmob_feet.dmi')








/obj/item/rig/mech_pilot/on_update_icon(update_mob_icon)

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
