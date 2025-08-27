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

/obj/item/mech_equipment/mounted_system/taser/ballistic/autoshotgun/need_combat_skill()
	return TRUE

/obj/item/ammo_magazine/shotgunmag/mech
	max_ammo = 50
	mag_type = SPEEDLOADER
	w_class = ITEM_SIZE_HUGE
	ammo_type = /obj/item/ammo_casing/shotgun/mech

/obj/item/ammo_casing/shotgun/mech
	projectile_type = /obj/item/projectile/bullet/shotgun/mech

/obj/item/projectile/bullet/shotgun/mech
	fire_sound = 'mods/mechs_by_shegar/sounds/mech_autoshotgun.ogg'
