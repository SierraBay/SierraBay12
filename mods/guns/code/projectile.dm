/obj/item/gun/projectile/revolver/foundation
	icon = 'mods/guns/icons/obj/foundation.dmi'

/obj/item/gun/projectile/automatic
	name = "prototype SMG"
	icon = 'mods/guns/icons/obj/prototype_smg.dmi'

/obj/item/gun/projectile/automatic/machine_pistol
	name = "MP6 machine pistol"
	icon = 'mods/guns/icons/obj/machine_pistol.dmi'

/obj/item/gun/projectile/automatic/merc_smg
	name = "C-20r submachine gun"
	icon = 'mods/guns/icons/obj/merc_smg.dmi'

/obj/item/gun/projectile/automatic/sec_smg
	name = "WT-550 submachine gun"

/obj/item/gun/projectile/automatic/assault_rifle
	name = "STS-35 assault rifle"
	// icon = 'mods/guns/icons/obj/assault_rifle.dmi'

/obj/item/gun/projectile/automatic/l6_saw
	name = "L6 machine gun"
	// icon = 'mods/guns/icons/obj/saw.dmi'



/obj/item/gun/projectile/automatic/bullpup_rifle
	name = "Z8 carabine"
	icon = 'mods/guns/icons/obj/bullpup_rifle.dmi'

/obj/item/gun/projectile/automatic/battlerifle
	icon = 'mods/guns/icons/obj/battlerifle.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns.dmi',
		)

/*
/obj/item/gun/projectile/heavysniper
	icon = 'mods/guns/icons/obj/heavysniper.dmi'

/obj/item/gun/projectile/heavysniper/boltaction
	icon = 'mods/guns/icons/obj/boltaction.dmi'
*/

/obj/item/gun/projectile/pistol/sec
	name = "NT Mk58 pistol"

/obj/item/gun/projectile/pistol/holdout
	name = "P3 holdout pistol"

/obj/item/gun/projectile/pistol/optimus
	name = "HelTek Optimus pistol"
	icon = 'mods/guns/icons/obj/confederate.dmi'

/obj/item/gun/projectile/pistol/magnum_pistol
	name = "HelTek Magnus heavy pistol"
	icon = 'mods/guns/icons/obj/magnum_pistol.dmi'

//NT41 from Infinity pack
/obj/item/gun/projectile/automatic/nt41
	name = "NT41 submachine gun"
	desc = "The NT41 Enforcer is a self-defense weapon made on bullpup system. Produced by NanoTrasen for it's Security Force. Looks cool and stylish, but sometimes too uncomfortably to run with it. Uses 5.7x28mm rounds."
	icon_state = "nt41"
	item_state = "nt41"
	icon = 'packs/infinity/icons/obj/guns.dmi'
	wielded_item_state = "nt41-wielded"
	item_icons = list(
		slot_r_hand_str = 'packs/infinity/icons/mob/onmob/righthand.dmi',
		slot_l_hand_str = 'packs/infinity/icons/mob/onmob/lefthand.dmi',
		)

	caliber = CALIBER_PISTOL_FAST
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3)
	slot_flags = SLOT_BELT
	ammo_type = /obj/item/ammo_casing/nt28mm
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/n10mm
	allowed_magazines = /obj/item/ammo_magazine/n10mm
	screen_shake = 0.5 //SMG

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,         one_hand_penalty=1, burst_accuracy=null, dispersion=null),
		list(mode_name="2-round bursts", burst=2, fire_delay=null,      one_hand_penalty=3, burst_accuracy=list(0,-1), dispersion=list(0.0, 0.8)),
		list(mode_name="short bursts",   burst=4, fire_delay=null,      one_hand_penalty=4, burst_accuracy=list(0,-1,-1.5,-2), dispersion=list(0.6, 0.8, 1.0, 1.4)),
	)

	bulk = GUN_BULK_CARABINE
	w_class = ITEM_SIZE_NORMAL
	one_hand_penalty = 2

/obj/item/gun/projectile/automatic/nt41/on_update_icon()
	..()
	icon_state = (ammo_magazine)? "nt41" : "nt41-e"
