/obj/item/clothing/glasses/sunglasses/lenses
	name = "small sun lenses"
	desc = "It looks fitted to nonhuman proportions. Usually, you can(?) see them in resomis' or monkeys' eyes."
	item_icons = list(slot_glasses_str = 'mods/resomi/icons/clothing/onmob_eyes_resomi.dmi')
	icon = 'packs/infinity/icons/obj/clothing/species/resomi/obj_eyes_resomi.dmi'
	icon_state = "sun_lenses"
	item_state = null
	light_protection = 6
	species_restricted = list(SPECIES_RESOMI)
	flash_protection = FLASH_PROTECTION_MODERATE
	body_parts_covered = 0

/obj/item/clothing/glasses/hud/security/lenses
	name = "small sechud lenses"
	desc = "Lenses with a HUD. This one has a sechud."
	item_icons = list(slot_glasses_str = 'mods/resomi/icons/clothing/onmob_eyes_resomi.dmi')
	icon = 'packs/infinity/icons/obj/clothing/species/resomi/obj_eyes_resomi.dmi'
	icon_state = "sec_lenses"
	off_state = "sun_lenses"
	item_state = null
	light_protection = 6
	species_restricted = list(SPECIES_RESOMI)
	flash_protection = FLASH_PROTECTION_MODERATE

/obj/item/clothing/glasses/hud/health/lenses
	name = "small medhud lenses"
	desc = "A small lenses that scans the creatures in view and provides accurate data about their health status."
	item_icons = list(slot_glasses_str = 'mods/resomi/icons/clothing/onmob_eyes_resomi.dmi')
	icon = 'packs/infinity/icons/obj/clothing/species/resomi/obj_eyes_resomi.dmi'
	icon_state = "med_lenses"
	off_state = "sun_lenses"
	item_state = null
	light_protection = 6
	flash_protection = FLASH_PROTECTION_MODERATE
	species_restricted = list(SPECIES_RESOMI)

/obj/item/clothing/glasses/sunglasses/lenses/visor
	name = "small sun visor"
	desc = "It looks fitted to nonhuman proportions."
	icon_state = "visor"

/obj/item/clothing/glasses/hud/security/lenses/visor
	name = "small sechud visor"
	desc = "A sechud that looks fitted to nonhuman proportions."
	icon_state = "secvisor"
	off_state = "visor"

/obj/item/clothing/glasses/hud/health/lenses/visor
	name = "small medhud visor"
	desc = "A medhud that looks fitted to nonhuman proportions."
	icon_state = "medvisor"
	off_state = "visor"

/obj/item/clothing/glasses/meson/lenses/visor
	name = "small meson visor"
	desc = "It looks fitted to nonhuman proportions. Used for seeing walls, floors, and stuff through anything."
	item_icons = list(slot_glasses_str = 'mods/resomi/icons/clothing/onmob_eyes_resomi.dmi')
	icon = 'packs/infinity/icons/obj/clothing/species/resomi/obj_eyes_resomi.dmi'
	icon_state = "mesonvisor"
	off_state = "visor"
	item_state = null
	light_protection = 6
	flash_protection = FLASH_PROTECTION_MODERATE
	species_restricted = list(SPECIES_RESOMI)

/obj/item/clothing/glasses/science/lenses/visor
	name = "small science visor"
	desc = "A scihud that looks fitted to nonhuman proportions."
	item_icons = list(slot_glasses_str = 'mods/resomi/icons/clothing/onmob_eyes_resomi.dmi')
	icon = 'packs/infinity/icons/obj/clothing/species/resomi/obj_eyes_resomi.dmi'
	icon_state = "scivisor"
	off_state = "visor"
	item_state = null
	light_protection = 6
	flash_protection = FLASH_PROTECTION_MODERATE
	species_restricted = list(SPECIES_RESOMI)

/mob/living/carbon/human/process_glasses(obj/item/clothing/glasses/G)
	equipment_light_protection += G.light_protection
	if(G?.active)
		equipment_darkness_modifier += G.darkness_view
		equipment_vision_flags |= G.vision_flags
		if(G.overlay)
			equipment_overlays |= G.overlay
		if(G.see_invisible >= 0)
			if(equipment_see_invis)
				equipment_see_invis = min(equipment_see_invis, G.see_invisible)
			else
				equipment_see_invis = G.see_invisible

		add_clothing_protection(G)
		G.process_hud(src)
