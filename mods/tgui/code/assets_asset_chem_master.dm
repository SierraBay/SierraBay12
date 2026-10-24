#define TGUI_MAX_PILL_SPRITE 25
#define TGUI_BOTTLE_SPRITES list("bottle-1", "bottle-2", "bottle-3", "bottle-4")

/// Pill sprites for UIs
/datum/asset/spritesheet/chem_master
	name = "chem_master"

/datum/asset/spritesheet/chem_master/create_spritesheets()
	for(var/pill_type = 1 to TGUI_MAX_PILL_SPRITE)
		Insert("pill[pill_type]", 'icons/obj/pills.dmi', "pill[pill_type]")
	for(var/bottle_type in TGUI_BOTTLE_SPRITES)
		Insert(bottle_type, 'icons/obj/chemical_storage.dmi', bottle_type)

/datum/asset/spritesheet/chem_master/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	pre_asset.Crop(16,16,48,48)
	pre_asset.Scale(32, 32)
	return pre_asset

#undef TGUI_MAX_PILL_SPRITE
#undef TGUI_BOTTLE_SPRITES
