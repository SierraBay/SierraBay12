// ИКСы
//шахтёрский
/obj/item/clothing/head/helmet/space/rig/industrial
	light_overlay = "helmet_light_wide"
	camera = /obj/machinery/camera/network/helmet
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

/obj/item/clothing/suit/space/rig/industrial
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/stack/flag,
		/obj/item/storage/ore,
		/obj/item/device/t_scanner,
		/obj/item/pickaxe,
		/obj/item/rcd,
		/obj/item/rpd
	)

/obj/item/clothing/shoes/magboots/rig/industrial
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

/obj/item/clothing/gloves/rig/industrial
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	siemens_coefficient = 0

//инженерный
/obj/item/clothing/head/helmet/space/rig/eva
	light_overlay = "helmet_light_alt"
	camera = /obj/machinery/camera/network/helmet
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_SKRELL = 'icons/mob/species/skrell/onmob_head_skrell.dmi',
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_head_unathi.dmi'
	)

/obj/item/clothing/suit/space/rig/eva
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi'
		)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/storage/toolbox,
		/obj/item/storage/briefcase/inflatable,
		/obj/item/inflatable_dispenser,
		/obj/item/device/t_scanner,
		/obj/item/rcd,
		/obj/item/rpd
	)

/obj/item/clothing/shoes/magboots/rig/eva
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_feet_unathi.dmi'
	)

/obj/item/clothing/gloves/rig/eva
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	siemens_coefficient = 0
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_hands_unathi.dmi'
	)

/obj/item/rig/eva/equipped

	initial_modules = list(
		/obj/item/rig_module/mounted/energy/plasmacutter,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/cooling_unit
	)

//медицинский
/obj/item/clothing/head/helmet/space/rig/medical
	light_overlay = "helmet_light_wide"
	camera = /obj/machinery/camera/network/helmet
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_head_unathi.dmi',
		SPECIES_SKRELL = 'icons/mob/species/skrell/onmob_head_skrell.dmi',
	)

/obj/item/clothing/suit/space/rig/medical
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/storage/firstaid,
		/obj/item/device/scanner/health,
		/obj/item/stack/medical,
		/obj/item/roller_bed,
		/obj/item/auto_cpr,
		/obj/item/inflatable_dispenser
	)

/obj/item/clothing/shoes/magboots/rig/medical
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_feet_unathi.dmi'
	)

/obj/item/clothing/gloves/rig/medical
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_hands_unathi.dmi'
	)

//ИКС СЕ
/obj/item/clothing/head/helmet/space/rig/ce
	light_overlay = "helmet_light_alt"
	camera = /obj/machinery/camera/network/helmet
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_head_unathi.dmi',
		SPECIES_SKRELL = 'icons/mob/species/skrell/onmob_head_skrell.dmi'
	)
/obj/item/clothing/suit/space/rig/ce
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi'
	)
	allowed = list(
		/obj/item/gun,
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/storage/ore,
		/obj/item/storage/toolbox,
		/obj/item/storage/briefcase/inflatable,
		/obj/item/inflatable_dispenser,
		/obj/item/device/t_scanner,
		/obj/item/pickaxe,
		/obj/item/rcd,
		/obj/item/rpd
	)
/obj/item/clothing/shoes/magboots/rig/ce
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_feet_unathi.dmi'
	)
//ИКС РД (нет спрайта для резоми)
/obj/item/clothing/head/helmet/space/rig/hazmat
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/helmet
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI*/)

/obj/item/clothing/suit/space/rig/hazmat
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI*/)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/stack/flag,
		/obj/item/storage/excavation,
		/obj/item/pickaxe,
		/obj/item/device/scanner/health,
		/obj/item/device/measuring_tape,
		/obj/item/device/ano_scanner,
		/obj/item/device/depth_scanner,
		/obj/item/device/core_sampler,
		/obj/item/device/gps,
		/obj/item/pinpointer/radio,
		/obj/item/pickaxe/xeno,
		/obj/item/storage/bag/fossils
	)

/obj/item/clothing/shoes/magboots/rig/hazmat
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI*/)

/obj/item/clothing/gloves/rig/hazmat
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI*/)

//сапёрский хз где используемый но пусть
/obj/item/clothing/head/helmet/space/rig/hazard
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/helmet
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)


/obj/item/clothing/suit/space/rig/hazard
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

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

/obj/item/clothing/shoes/magboots/rig/hazard
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)


/obj/item/clothing/gloves/rig/hazard
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

//нульсьют (нет спрайта для таяр и шлема для скреллов)
/obj/item/clothing/head/helmet/space/rig/zero
	camera = null
	species_restricted = list(SPECIES_HUMAN,/*SPECIES_SKRELL,*/SPECIES_UNATHI,SPECIES_IPC, /*SPECIES_TAJARA,*/ SPECIES_RESOMI)

//All in one suit
/obj/item/clothing/suit/space/rig/zero
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, /*SPECIES_TAJARA,*/ SPECIES_RESOMI)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi'
	)
	breach_threshold = 18
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit
	)
	max_w_class = null
	slots = null

//мерк сьюты - нет спрайтов для резоми
/obj/item/clothing/gloves/rig/merc
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_NOCUFFS | ITEM_FLAG_AIRTIGHT
	siemens_coefficient = 0
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_hands_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_hands_vox.dmi'
		)
/obj/item/clothing/head/helmet/space/rig/merc
	camera = /obj/machinery/camera/network/mercenary
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_SKRELL = 'icons/mob/species/skrell/onmob_head_skrell.dmi',
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_head_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_head_vox.dmi',
		SPECIES_RESOMI = 'mods/resomi/icons/clothing/onmob_head_resomi.dmi'
		)

/obj/item/clothing/suit/space/rig/merc
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_suit_vox.dmi',
		SPECIES_RESOMI = 'mods/resomi/icons/clothing/onmob_suit_resomi.dmi'
	)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/gun,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/handcuffs
	)

/obj/item/clothing/shoes/magboots/rig/merc
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, /*SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_feet_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_feet_vox.dmi'
		)

//хеви-версия (нужны спрайты котам и резомам)
/obj/item/clothing/head/helmet/space/rig/merc/heavy
	camera = /obj/machinery/camera/network/mercenary
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, /*SPECIES_TAJARA, SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_SKRELL = 'icons/mob/species/skrell/onmob_head_skrell.dmi',
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_head_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_head_vox.dmi'
		)

/obj/item/clothing/suit/space/rig/merc/heavy
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, /*SPECIES_TAJARA, SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_suit_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_suit_vox.dmi'
		)

/obj/item/clothing/shoes/magboots/rig/merc/heavy
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, /*SPECIES_TAJARA, SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_feet_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_feet_vox.dmi'
		)

/obj/item/clothing/gloves/rig/merc/heavy
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, /*SPECIES_TAJARA, SPECIES_RESOMI,*/ SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_hands_unathi.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/onmob_hands_vox.dmi'
		)

//ОБР - на таяр есть шлема, но нет хвостов, у унатхов нет хвостов, у резом нет спрайтов - пока закроем им доступ
/obj/item/clothing/head/helmet/space/rig/ert
	light_overlay = "helmet_light_dual"
	camera = /obj/machinery/camera/network/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,/*SPECIES_UNATHI,*/SPECIES_IPC/*, SPECIES_TAJARA, SPECIES_RESOMI*/)

/obj/item/clothing/suit/space/rig/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,/*SPECIES_UNATHI,*/SPECIES_IPC/*, SPECIES_TAJARA, SPECIES_RESOMI*/)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/handcuffs,
		/obj/item/device/t_scanner,
		/obj/item/rcd,
		/obj/item/rpd,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/device/multitool,
		/obj/item/device/radio,
		/obj/item/device/scanner/gas,
		/obj/item/storage/briefcase/inflatable,
		/obj/item/melee/baton,
		/obj/item/gun,
		/obj/item/storage/firstaid,
		/obj/item/reagent_containers/hypospray,
		/obj/item/roller_bed
	)

/obj/item/clothing/shoes/magboots/rig/ert
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,/*SPECIES_UNATHI,*/SPECIES_IPC/*, SPECIES_TAJARA, SPECIES_RESOMI*/)

/obj/item/clothing/gloves/rig/ert
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_NOCUFFS
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,/*SPECIES_UNATHI,*/SPECIES_IPC/*, SPECIES_TAJARA, SPECIES_RESOMI*/)

//ниндзя ИКС (спрайты на резоми-нинжу есть)
/obj/item/clothing/gloves/rig/light/ninja
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

/obj/item/clothing/gloves/rig/light/ninja
	name = "insulated gloves"
	siemens_coefficient = 0
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

/obj/item/clothing/suit/space/rig/light/ninja
	breach_threshold = 38 //comparable to regular hardsuits
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

//стелс-ИКС и вообще все ИКСы от родителя rig/light (спрайтов на резоми-стелсеров-не-нинжей нет)
//АЛЯРМ - РОДИТЕЛЬ RIG/LIGHT ПОЗВОЛЯЕТ КСЕНОТЕ НОСИТЬ ИКСЫ МЕРКОВ (ГКК, ЦПСС и корпо) БЕЗ НУЖНЫХ СПРАЙТОВ - своих вещей у меркоИКСов нет, поэтому пока не в курсе как починить :(
/obj/item/clothing/suit/space/rig/light
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA /*SPECIES_RESOMI*/)

/obj/item/clothing/shoes/magboots/rig/light/
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI) //нужно для ниндзи

/obj/item/clothing/gloves/rig/light/
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA /*SPECIES_RESOMI*/)

/obj/item/clothing/head/helmet/space/rig/light/
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI) //нужно для ниндзи

// хакер-ИКС
/obj/item/clothing/suit/lightrig/hacker //нет спрайтов для резоми
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA /*SPECIES_RESOMI*/)

/obj/item/clothing/head/lightrig/hacker
	species_restricted = list(SPECIES_HUMAN,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_IPC, SPECIES_TAJARA /*SPECIES_RESOMI*/)

// командные ИКСы

/obj/item/clothing/head/helmet/space/rig/command
	light_overlay = "helmet_light_dual"
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	// SIERRA TODO: port SPECIES_TAJARA, SPECIES_RESOMI
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI) // No available icons for aliens: скреллы + ящеры

/obj/item/clothing/suit/space/rig/command
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	// SIERRA TODO: port SPECIES_TAJARA, SPECIES_RESOMI
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

/obj/item/clothing/shoes/magboots/rig/command
	icon = 'maps/torch/icons/obj/obj_feet_solgov.dmi'
	item_icons = list(slot_shoes_str = 'maps/torch/icons/mob/onmob_feet_solgov.dmi')
	// SIERRA TODO: port SPECIES_TAJARA, SPECIES_RESOMI
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)

/obj/item/clothing/gloves/rig/command
	icon = 'maps/torch/icons/obj/obj_hands_solgov.dmi'
	item_icons = list(slot_gloves_str = 'maps/torch/icons/mob/onmob_hands_solgov.dmi')
	// SIERRA TODO: port SPECIES_TAJARA, SPECIES_RESOMI
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_TAJARA, SPECIES_RESOMI)


//ГСБ ИКС
/obj/item/clothing/head/helmet/space/rig/command/hos
	icon_state = "hos_rig"
	icon = 'maps/sierra/icons/obj/clothing/obj_head.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/mob/onmob/onmob_head.dmi')
	species_restricted = list(SPECIES_HUMAN, SPECIES_TAJARA) // No available icons for aliens: скреллы + ящеры + резоми
	sprite_sheets = list(
		SPECIES_TAJARA = 'mods/tajara/icons/sprite_sheets/helmet.dmi'
	)

/obj/item/clothing/suit/space/rig/command/hos
	icon_state = "hos_rig"
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	species_restricted = list(SPECIES_HUMAN, SPECIES_TAJARA)
	sprite_sheets = list(
		SPECIES_TAJARA = 'mods/tajara/icons/sprite_sheets/suit.dmi'
	)

/obj/item/clothing/shoes/magboots/rig/command/hos
	icon_state = "hos_rig"
	icon = 'maps/sierra/icons/obj/clothing/obj_feet.dmi'
	item_icons = list(slot_shoes_str = 'maps/sierra/icons/mob/onmob/onmob_feet.dmi')
	species_restricted = list(SPECIES_HUMAN, SPECIES_TAJARA)

/obj/item/clothing/gloves/rig/command/hos
	icon_state = "hos_rig"
	icon = 'maps/sierra/icons/obj/clothing/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'maps/sierra/icons/mob/onmob/onmob_hands.dmi')
	species_restricted = list(SPECIES_HUMAN, SPECIES_TAJARA)

//капитанский ИКС (вообще нет спрайтов command_CO_rig на ксеноту)
/obj/item/clothing/head/helmet/space/rig/command/captain
	species_restricted = list(SPECIES_HUMAN)

/obj/item/clothing/suit/space/rig/command/captain
	species_restricted = list(SPECIES_HUMAN)
