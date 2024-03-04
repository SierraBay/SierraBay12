#define CALIBER_SHIP_MINIGUN "75mm"

/obj/item/ammo_magazine/ammobox/minigun
	name = "ammo box"
	desc = "Ammo box that contains 75mm rocket-propelled rounds."
	icon_state = "crate_closed_ammo"
	caliber = CALIBER_SHIP_MINIGUN
	max_ammo = 420
	ammo_type = /obj/item/projectile/bullet/huge_caliber/minigun

/obj/item/ammo_magazine/ammobox/minigun/high_explosive
	name = "HE ammo box"
	desc = "Ammo box that contains 75mm rocket-propelled high explosive rounds."
	ammo_type = /obj/item/projectile/bullet/huge_caliber/minigun/high_explosive

/obj/item/ammo_casing/huge_caliber/minigun
	name = "heavy machine gun casing"
	desc = "A heavy machine gun round casing."
	caliber = CALIBER_SHIP_MINIGUN
	projectile_type = /obj/item/projectile/bullet/huge_caliber/hmg_ship

/obj/item/projectile/bullet/huge_caliber/minigun
	name = "minigun bullet"
	icon_state= "bolter"
	damage = 300
	armor_penetration = 30
	pew_spread = 20

/obj/item/projectile/bullet/huge_caliber/minigun/high_explosive
	damage = 150
	explosion_radius = 5
	explosion_max_power = EX_ACT_HEAVY

#undef CALIBER_SHIP_MINIGUN
