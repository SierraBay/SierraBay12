#define CALIBER_SHIP_ROCKET    "85mm"

///////////////////////////AMMOBOX///////////////////////////

/obj/item/ammo_magazine/ammobox/rocket
	name = "rocket box"
	desc = "Ammo box that contains rockets for rocket launcher systems."
	icon_state = "crate_closed_ammo"
	caliber = CALIBER_SHIP_ROCKET
	max_ammo = 40
	ammo_type = /obj/item/ammo_casing/huge_caliber/rocket

/obj/item/ammo_magazine/ammobox/rocket/he
	name = "HE rocket box"
	desc = "Ammo box that contains HE rockets for rocket launcher systems."
	icon_state = "rocket_he"
	ammo_type = /obj/item/ammo_casing/huge_caliber/rocket/high_explosive

/obj/item/ammo_magazine/ammobox/rocket/aphe
	name = "APHE rocket box"
	desc = "Ammo box that contains APHE rockets for rocket launcher systems."
	icon_state = "rocket_he"
	ammo_type = /obj/item/ammo_casing/huge_caliber/rocket/aphe

/obj/item/ammo_magazine/ammobox/rocket/tandem
	name = "TANDEM rocket box"
	desc = "Ammo box that contains TANDEM rockets for rocket launcher systems."
	icon_state = "rocket_tandem"
	ammo_type = /obj/item/ammo_casing/huge_caliber/rocket/tandem

///////////////////////////CASING///////////////////////////

/obj/item/ammo_casing/huge_caliber/rocket
	name = "rocket casing"
	desc = "A rocket-propelled explosive casing."
	icon_state = "rocket"
	spent_icon = "rocket-spent"
	caliber = CALIBER_SHIP_ROCKET
	w_class = ITEM_SIZE_NORMAL
	projectile_type = /obj/item/projectile/bullet/huge_caliber/rocket

/obj/item/ammo_casing/huge_caliber/rocket/high_explosive
	icon_state = "rocket_he"
	projectile_type = /obj/item/projectile/bullet/huge_caliber/rocket/high_explosive

/obj/item/ammo_casing/huge_caliber/rocket/aphe
	icon_state = "rocket_aphe"
	projectile_type = /obj/item/projectile/bullet/huge_caliber/rocket/aphe

/obj/item/ammo_casing/huge_caliber/rocket/tandem
	icon_state = "rocket_tandem"
	projectile_type = /obj/item/projectile/bullet/huge_caliber/rocket/tandem

///////////////////////////BULLETS///////////////////////////

/obj/item/projectile/bullet/huge_caliber/rocket
	name ="rocket"
	damage = 50
	pew_spread = 9
	explosion_radius = 2

/obj/item/projectile/bullet/huge_caliber/rocket/high_explosive
	explosion_radius = 4

/obj/item/projectile/bullet/huge_caliber/rocket/aphe
	damage = 80
	armor_penetration = 100
	penetrating = 5
	penetration_modifier = 2
	explosion_radius = 3

/obj/item/projectile/bullet/huge_caliber/rocket/tandem
	damage = 60
	armor_penetration = 100
	penetrating = 5
	penetration_modifier = 2
	proximity_detonation = FALSE
	explosion_radius = 4
	pew_spread = 16
	var/explosion_power_first = 100
	var/exploded_inwall = FALSE
	var/delay = 8

/obj/item/projectile/bullet/huge_caliber/rocket/tandem/Bump(atom/A as mob|obj|turf|area, forced=0)
	..()
	if(exploded)
		return

	exploded = TRUE
	if(istype(A,/obj/shield))
		explosion(get_turf(A), explosion_radius, explosion_max_power)
		qdel(src)
		return
	explosion_power_first = explosion_radius / 2
	if(src && !exploded_inwall)
		explosion(get_turf(src), explosion_power_first, explosion_max_power)
	sleep(delay)
	if(src && !exploded_inwall)
		explosion(get_turf(src), explosion_radius, explosion_max_power)
		qdel(src)

#undef CALIBER_SHIP_ROCKET
