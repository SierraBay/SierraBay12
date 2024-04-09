#define CALIBER_RIFLE_RUSSIA 	"12.7x55mm"

/obj/item/gun/projectile/revolver/rsh21
	name = "RSH-21"
	icon_state = "rsh12"
	caliber = CALIBER_RIFLE_RUSSIA
	ammo_type = /obj/item/ammo_casing/rifle/russia
	desc = "A modern assault revolver that has been adapted for firing at medium and long distances. The RS12 is its direct predecessor, but in comparison with it it has a lower recoil, a larger drum for 6 rounds, and a built-in gyro stabilizer. It has two mounting straps on the bottom and top."
	accuracy = 1
	fire_delay = 3
	one_hand_penalty = 4
	max_shells = 6 //original rsh12 have only 5
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3)

/obj/item/ammo_magazine/box/rifle/military
	name = "12.7 rounds crate"
	icon_state = "rbox_r"
	caliber = CALIBER_RIFLE_RUSSIA
	ammo_type = /obj/item/ammo_casing/rifle/russia

/obj/item/ammo_magazine/speedloader/rifle
	icon_state = "spdloader_small"
	caliber = CALIBER_RIFLE_RUSSIA
	ammo_type = /obj/item/ammo_casing/rifle/russia
	matter = list(MATERIAL_STEEL = 1440)
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_casing/rifle/russia
	desc = "A rifle 12.7x55mm bullet casing."
	caliber = CALIBER_RIFLE_RUSSIA
	projectile_type = /obj/item/projectile/bullet/rifle/russian
	icon_state = "ruscasing"
	spent_icon = "ruscasing-spent"

/obj/item/ammo_casing/rifle/russia/ap
	desc = "A rifle AP 12.7x55mm bullet casing."
	caliber = CALIBER_RIFLE_RUSSIA
	projectile_type = /obj/item/projectile/bullet/rifle/russian/ap
	icon_state = "ruscasing_ap"
	spent_icon = "ruscasing_ap-spent"

/obj/item/ammo_casing/rifle/russia/hp
	desc = "A rifle HP 12.7x55mm bullet casing."
	caliber = CALIBER_RIFLE_RUSSIA
	projectile_type = /obj/item/projectile/bullet/rifle/russian/hp
	icon_state = "ruscasing_hp"
	spent_icon = "ruscasing_hp-spent"

#undef CALIBER_RIFLE_RUSSIA

/obj/item/projectile/bullet/rifle/russian
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 46
	penetrating = 1
	armor_penetration = 30
	penetration_modifier = 1.4

/obj/item/projectile/bullet/rifle/russian/ap
	damage = 38
	penetrating = 2
	armor_penetration = 55
	penetration_modifier = 1.6

/obj/item/projectile/bullet/rifle/russian/hp
	damage = 52
	penetrating = 0
	armor_penetration = 15
	penetration_modifier = 0.5
