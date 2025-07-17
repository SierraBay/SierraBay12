/obj/item/rig/ert/assetprotection
	name = "heavy emergency response suit control module"
	desc = "A heavy, modified version of a common emergency response hardsuit. Has blood red highlights. Armoured and space ready."
	suit_type = "heavy emergency response"
	icon_state = "asset_protection_rig"
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)

	glove_type = /obj/item/clothing/gloves/rig/ert/assetprotection

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/vision/multi,
		/obj/item/rig_module/mounted/energy/egun,
		/obj/item/rig_module/chem_dispenser/combat,
		/obj/item/rig_module/mounted/energy/plasmacutter,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/cooling_unit
	)

/obj/item/clothing/gloves/rig/ert/assetprotection
	siemens_coefficient = 0

/obj/item/clothing/suit/space/rig/ert
	icon = 'mods/antagonists/icons/obj/ert_rig_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/antagonists/icons/mob/ert_rig_suit.dmi')

/obj/item/clothing/head/helmet/space/rig/ert
	icon = 'mods/antagonists/icons/obj/ert_rig_head.dmi'
	item_icons = list(slot_head_str = 'mods/antagonists/icons/mob/ert_rig_head.dmi')

/obj/item/clothing/shoes/magboots/rig/ert
	icon = 'mods/antagonists/icons/obj/ert_rig_feet.dmi'
	item_icons = list(slot_shoes_str = 'mods/antagonists/icons/mob/ert_rig_feet.dmi')

/obj/item/clothing/gloves/rig/ert
	icon = 'mods/antagonists/icons/obj/ert_rig_hands.dmi'
	item_icons = list(slot_gloves_str = 'mods/antagonists/icons/mob/ert_rig_hands.dmi')

/obj/item/rig/ert/on_update_icon(update_mob_icon)

	//TODO: Maybe consider a cache for this (use mob_icon as blank canvas, use suit icon overlay).
	ClearOverlays()
	if(!mob_icon || update_mob_icon)
		var/species_icon = 'mods/antagonists/icons/mob/ert_rig_back.dmi'
		// Since setting mob_icon will override the species checks in
		// update_inv_wear_suit(), handle species checks here.
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


/obj/item/rig/ert
	icon = 'mods/antagonists/icons/obj/ert_rig_back.dmi'
	item_icons = list(slot_back_str = 'mods/antagonists/icons/mob/ert_rig_back.dmi')

/obj/item/rig/ert/engineer
	icon = 'mods/antagonists/icons/obj/ert_rig_back.dmi'
	item_icons = list(slot_back_str = 'mods/antagonists/icons/mob/ert_rig_back.dmi')

/obj/item/rig/ert/janitor
	icon = 'mods/antagonists/icons/obj/ert_rig_back.dmi'
	item_icons = list(slot_back_str = 'mods/antagonists/icons/mob/ert_rig_back.dmi')

/obj/item/rig/ert/medical
	icon = 'mods/antagonists/icons/obj/ert_rig_back.dmi'
	item_icons = list(slot_back_str = 'mods/antagonists/icons/mob/ert_rig_back.dmi')

/obj/item/rig/ert/security
	icon = 'mods/antagonists/icons/obj/ert_rig_back.dmi'
	item_icons = list(slot_back_str = 'mods/antagonists/icons/mob/ert_rig_back.dmi')
