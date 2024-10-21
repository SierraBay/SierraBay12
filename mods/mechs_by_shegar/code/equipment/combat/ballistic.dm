//Пулемёт
/obj/item/mech_equipment/mounted_system/taser/ballistic
	name = "\improper Military \"Vulcan\" machinegun"
	desc = "Military mounted machinegun for combat mechs."
	icon_state = "mech_scatter"
	holding_type = /obj/item/gun/projectile/automatic/assault_rifle/mounted


/*
/obj/item/mech_equipment/mounted_system/taser/ballistic/attack_hand(mob/user)
	return
	if(holding.ammo_magazine != null && src.loc == owner)
		holding.unload_ammo(user, allow_dump=0)
		get_hardpoint_maptext()
*/

/obj/item/mech_equipment/mounted_system/taser/ballistic/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(!holding.ammo_magazine)
		holding.load_ammo(item,user)
		get_hardpoint_maptext()
	. = ..()

/obj/item/gun/projectile/automatic/assault_rifle/mounted
	name = "mech machinegun"
	desc = "Very big machinegun with classic calibre."
	icon = 'icons/obj/guns/saw.dmi'
	force = 10
	burst = 3
	accuracy = 1
	bulk = GUN_BULK_RIFLE
	caliber = CALIBER_RIFLE
	w_class = ITEM_SIZE_HUGE
	one_hand_penalty= 0
	load_method = SINGLE_CASING|SPEEDLOADER
	max_shells = 200
	ammo_type = /obj/item/ammo_casing/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle/mech_machinegun
	has_safety = FALSE
	firemodes = list(
		list(mode_name="semi auto", burst=4, fire_delay=null, move_delay=null, one_hand_penalty=8, burst_accuracy=null, dispersion=null),
		)

/obj/item/gun/projectile/automatic/assault_rifle/mounted/unload_ammo(mob/user,allow_dump = 1)
	return

/obj/item/ammo_magazine/rifle/mech_machinegun
	max_ammo = 200
	icon_state = "machinegun"
	mag_type = SPEEDLOADER
	w_class = ITEM_SIZE_HUGE
//Пулемёт




//СМГ
/obj/item/mech_equipment/mounted_system/taser/ballistic/smg
	name = "\improper Mounted \"SH-G\" prototype SMG"
	desc = "Prototype SMG, created by one of the ships R&D."
	icon_state = "mech_smg"
	holding_type = /obj/item/gun/projectile/automatic/mounted/smg

/obj/item/gun/projectile/automatic/mounted/smg
	name = "mech scattergun"
	icon = 'icons/obj/guns/saw.dmi'
	icon_state = "l6closed50"
	item_state = "l6closedmag"
	force = 10
	burst= 3
	accuracy = 3
	bulk = GUN_BULK_RIFLE
	w_class = ITEM_SIZE_HUGE
	caliber = CALIBER_PISTOL_SMALL
	one_hand_penalty= 0
	load_method = SINGLE_CASING|SPEEDLOADER
	max_shells = 100
	ammo_type = /obj/item/ammo_casing/pistol/small/mech
	magazine_type = /obj/item/ammo_magazine/proto_smg/mech
	allowed_magazines = /obj/item/ammo_magazine/proto_smg/mech
	has_safety = FALSE
	firemodes = list(
		list(mode_name="semi auto",burst=3, fire_delay=null,move_delay=null, one_hand_penalty=0, burst_accuracy=null, dispersion=null),
		)

/obj/item/gun/projectile/automatic/mounted/smg/unload_ammo(mob/user,allow_dump = 1)
	return

/obj/item/ammo_magazine/proto_smg/mech
	max_ammo = 100
	icon_state = "666"
	mag_type = SPEEDLOADER
	caliber = CALIBER_PISTOL_SMALL
	w_class = ITEM_SIZE_HUGE
	ammo_type = /obj/item/ammo_casing/pistol/small/mech

/obj/item/ammo_casing/pistol/small/mech
	projectile_type = /obj/item/projectile/bullet/pistol/holdout/mech
	caliber = CALIBER_PISTOL_SMALL

/obj/item/projectile/bullet/pistol/holdout/mech
	damage = 30
	fire_sound = 'mods/mechs_by_shegar/sounds/mech_smg.ogg'
	penetrating = 1
//СМГ





//Авотшотган
/obj/item/mech_equipment/mounted_system/taser/ballistic/autoshotgun
	name = "\improper Mounted \"TR-V\" anti-terror shotgun"
	desc = "Combat autoshotgun created special for NanoTrasen mechs. Technicaly, its automatic KS-43"
	icon_state = "mech_shotgun"
	holding_type = /obj/item/gun/projectile/automatic/mounted/shotgun

/obj/item/gun/projectile/automatic/mounted/shotgun
	name = "mech autoshotgun"
	desc = "This one connected by ammunition belt to the mech."
	icon = 'icons/obj/guns/saw.dmi'
	icon_state = "l6closed50"
	item_state = "l6closedmag"
	force = 10
	burst= 3
	accuracy = -1
	bulk = GUN_BULK_RIFLE
	w_class = ITEM_SIZE_HUGE
	one_hand_penalty= 0
	caliber = CALIBER_SHOTGUN
	load_method = SINGLE_CASING|SPEEDLOADER
	max_shells = 50
	ammo_type = /obj/item/ammo_casing/shotgun/mech
	allowed_magazines = /obj/item/ammo_magazine/shotgunmag/mech
	has_safety = FALSE

/obj/item/gun/projectile/automatic/mounted/shotgun/unload_ammo(mob/user,allow_dump = 1)
	return

/obj/item/ammo_magazine/shotgunmag/mech
	max_ammo = 50
	mag_type = SPEEDLOADER
	w_class = ITEM_SIZE_HUGE
	ammo_type = /obj/item/ammo_casing/shotgun/mech

/obj/item/ammo_casing/shotgun/mech
	projectile_type = /obj/item/projectile/bullet/shotgun/mech

/obj/item/projectile/bullet/shotgun/mech
	fire_sound = 'mods/mechs_by_shegar/sounds/mech_autoshotgun.ogg'
//Автошотган




/obj/item/mech_equipment/mounted_system/taser/ballistic/get_hardpoint_maptext()
	return "[LAZYLEN(holding.contents)]/[holding.max_shells]"
