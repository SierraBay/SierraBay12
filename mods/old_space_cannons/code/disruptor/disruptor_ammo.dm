#define CALIBER_SHIP_DISRUPTOR    "fusion cells"

/obj/item/ammo_magazine/ammobox/disruptor
	name = "ammo box"
	desc = "Military grade fusion cells box, used in ship disruptors."
	icon_state = "ammocrate_disruptor"
	caliber = CALIBER_SHIP_DISRUPTOR
	max_ammo = 40
	ammo_type = /obj/item/ammo_casing/huge_caliber/disruptor

/obj/item/ammo_casing/huge_caliber/disruptor
	name = "disruptor charge"
	desc = "A disruptor charge stored in casing-like structure."
	caliber = CALIBER_SHIP_DISRUPTOR
	projectile_type = /obj/item/projectile/bullet/huge_caliber/disruptor

/obj/item/projectile/bullet/huge_caliber/disruptor
	name = "energy bolt"
	icon_state = "spark_green"
	temperature = T0C + 300
	damage = 20
	agony = 20
	damage_type = DAMAGE_BURN
	damage_flags = 0
	var/heavy_effect_range = 2
	var/light_effect_range = 3

	ground_to_space = FALSE
	pew_spread = 10

	overmap_color = COLOR_YELLOW

/obj/item/projectile/bullet/huge_caliber/disruptor/on_impact(atom/A)
	empulse(A, heavy_effect_range, light_effect_range)
	return 1

/obj/projectile/bullet/muzzle/ship_weapon/disruptor
	icon_state = "disruptor_muzzle"

#undef CALIBER_SHIP_DISRUPTOR
