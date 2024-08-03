/obj/item/gun/projectile/revolver/foundation
	icon = 'mods/guns/icons/obj/foundation.dmi'

/obj/item/gun/projectile/automatic
	icon = 'mods/guns/icons/obj/prototype_smg.dmi'

/obj/item/gun/projectile/automatic/machine_pistol
	icon = 'mods/guns/icons/obj/machine_pistol.dmi'

/obj/item/gun/projectile/automatic/merc_smg
	icon = 'mods/guns/icons/obj/merc_smg.dmi'

/*
/obj/item/gun/projectile/automatic/assault_rifle
	icon = 'mods/guns/icons/obj/assault_rifle.dmi'

/obj/item/gun/projectile/automatic/l6_saw
	icon = 'mods/guns/icons/obj/saw.dmi'

*/

/obj/item/gun/projectile/automatic/bullpup_rifle
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

/obj/item/gun/projectile/pistol/optimus
	icon = 'mods/guns/icons/obj/confederate.dmi'

/obj/item/gun/projectile/pistol/magnum_pistol
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

/obj/item/gun/projectile/pistol/hos
	name = "Kimber Warrior custom"
	desc = "The old pistol is in good condition, it used to be in service with the armed forces for officers. You can see silver and bronze on it"
	icon = 'mods/guns/icons/obj/M1911.dmi'
	icon_state = "standart"
	caliber = CALIBER_PISTOL_MAGNUM
	magazine_type = /obj/item/ammo_magazine/pistol/hos
	allowed_magazines = /obj/item/ammo_magazine/pistol/hos
	accuracy = -1
	fire_delay = 5
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	fire_sound = 'mods/guns/sounds/pistol_fire.ogg'

/obj/item/ammo_magazine/pistol/hos
	name = "Kimber magazine"
	icon = 'mods/guns/icons/obj/ammo_m1911.dmi'
	icon_state = "m1911"
	mag_type = MAGAZINE
	matter = list(MATERIAL_STEEL = 1200)
	caliber = CALIBER_PISTOL_MAGNUM
	ammo_type = /obj/item/ammo_casing/pistol/magnum
	max_ammo = 8

/obj/item/ammo_magazine/pistol/hos/empty
	initial_ammo = 0
