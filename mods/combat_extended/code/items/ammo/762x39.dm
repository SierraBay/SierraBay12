/*
	7.62x39 AP projectile, casing, and loose-round box. Rifle HP rounds are intentionally absent.
*/

/obj/item/projectile/bullet/rifle/ap
	// 15.7 mm versus 10.0 mm for FMJ: pierces ARMOR_BALLISTIC_RESISTANT and stops at ARMOR_BALLISTIC_RIFLE.
	damage = 40
	armor_penetration = 55
	ce_blunt_penetration_of = /obj/item/projectile/bullet/rifle

/obj/item/ammo_casing/rifle/ap
	desc = "An armor piercing rifle bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/rifle/ap
	icon_state = "7mmR_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "7mmR_ap"

/obj/item/ammobox/rifle/ap
	ammo_type = /obj/item/ammo_casing/rifle/ap
