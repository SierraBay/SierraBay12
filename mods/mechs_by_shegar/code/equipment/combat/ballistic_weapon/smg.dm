/obj/item/mech_equipment/mounted_system/taser/ballistic/smg
	name = "\improper Mounted \"SH-G\" prototype SMG"
	desc = "Prototype SMG, created by one of the ships R&D."
	icon_state = "mech_smg"
	holding_type = /obj/item/gun/projectile/automatic/mounted/smg

/obj/item/gun/projectile/automatic/mounted/smg
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

/obj/item/mech_equipment/mounted_system/taser/ballistic/smg/need_combat_skill()
	return TRUE

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
