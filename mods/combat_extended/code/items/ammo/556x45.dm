/*
	5.56x45 AP projectile, casing, and loose-round box. Rifle HP rounds are intentionally absent.
*/

/obj/item/projectile/bullet/rifle/military_standard/ap
	// 15.4 mm versus 10.5 mm for FMJ: pierces ARMOR_BALLISTIC_RESISTANT and stops at ARMOR_BALLISTIC_RIFLE.
	damage = 35
	armor_penetration = 55
	ce_blunt_penetration_of = /obj/item/projectile/bullet/rifle/military_standard

/obj/item/ammo_casing/rifle/military/ap
	desc = "An armor piercing military rifle bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/rifle/military_standard/ap
	icon_state = "5mmR_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "5mmR_ap"

/obj/item/ammobox/rifle/military/ap
	ammo_type = /obj/item/ammo_casing/rifle/military/ap
