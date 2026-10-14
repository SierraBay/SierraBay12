/obj/item/rig/industrial
	icon = 'mods/hardsuits/icons/rigs/rig_modules.dmi'
	sprite_sheets = list(
		SPECIES_HUMAN = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi',
		SPECIES_IPC = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi',
		SPECIES_SKRELL = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi',
		SPECIES_UNATHI = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi',
		SPECIES_TAJARA = 'mods/hardsuits/icons/rigs/onmob_rig_back.dmi'
	)


/obj/item/clothing/head/helmet/space/rig/industrial
	icon = 'mods/hardsuits/icons/rigs/obj_head.dmi'
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/rigs/onmob_head.dmi')
	sprite_sheets = list(
		SPECIES_SKRELL = 'mods/hardsuits/icons/rigs/species/onmob_head_skrell.dmi',
		SPECIES_UNATHI = 'mods/hardsuits/icons/rigs/species/onmob_head_unathi.dmi'
	)

/obj/item/clothing/head/helmet/space/rig/industrial/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/human/H = user
	if (!istype(H))
		return
	var/list/groups = list(SPECIES_SKRELL = "head_skrell", SPECIES_UNATHI = "head_unathi", SPECIES_TAJARA = "head_tajara")
	var/group = groups[H.species.get_bodytype(H)]
	if (!group)
		icon = initial(icon)
		return
	var/icon_file = 'mods/hardsuits/icons/rigs/species/obj_industrial_species.dmi'
	var/icon/renamed = icon(icon_file, group)
	renamed.Insert(icon(icon_file, group), "engineering_rig")
	renamed.Insert(icon(icon_file, "[group]_sealed"), "engineering_rig_sealed")
	icon = renamed

/obj/item/clothing/head/helmet/space/rig/industrial/dropped(mob/user)
	. = ..()
	icon = initial(icon)


/obj/item/clothing/suit/space/rig/industrial
	icon = 'mods/hardsuits/icons/rigs/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/rigs/onmob_suit.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/hardsuits/icons/rigs/species/onmob_suit_unathi.dmi'
	)


/obj/item/clothing/shoes/magboots/rig/industrial
	icon = 'mods/hardsuits/icons/rigs/obj_feet.dmi'
	item_icons = list(slot_shoes_str = 'mods/hardsuits/icons/rigs/onmob_feet.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/hardsuits/icons/rigs/species/onmob_feet_unathi.dmi',
		SPECIES_TAJARA = 'mods/tajara/icons/sprite_sheets/feet.dmi'
	)

/obj/item/clothing/shoes/magboots/rig/industrial/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/human/H = user
	if (!istype(H))
		return
	if (H.species.get_bodytype(H) != SPECIES_UNATHI)
		icon = initial(icon)
		return
	var/icon_file = 'mods/hardsuits/icons/rigs/species/obj_industrial_species.dmi'
	var/icon/renamed = icon(icon_file, "feet_unathi")
	renamed.Insert(icon(icon_file, "feet_unathi"), "engineering_rig")
	renamed.Insert(icon(icon_file, "feet_unathi_sealed"), "engineering_rig_sealed")
	icon = renamed

/obj/item/clothing/shoes/magboots/rig/industrial/dropped(mob/user)
	. = ..()
	icon = initial(icon)


/obj/item/clothing/gloves/rig/industrial
	icon = 'mods/hardsuits/icons/rigs/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'mods/hardsuits/icons/rigs/onmob_hands.dmi')
