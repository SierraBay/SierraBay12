/*
	COMBAT_EXTENDED: бронебойные (AP) и экспансивные (HP) патроны .44 Magnum. Снаряд, гильза и
	коробка россыпи. Как подобраны числа: README, "Патроны FMJ, AP и HP".
*/

/obj/item/projectile/bullet/pistol/strong/ap
	// 14.9 мм против 8.6 у FMJ: `ARMOR_BALLISTIC_RESISTANT` (11 мм) пробивает, `ARMOR_BALLISTIC_RIFLE`
	// (16 мм) держит.
	damage = 40
	armor_penetration = 50
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol/strong

/obj/item/projectile/bullet/pistol/strong/hp
	// 4.6 мм: держит уже `ARMOR_BALLISTIC_PISTOL` (6 мм).
	damage = 65
	armor_penetration = -5
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol/strong
	// Мягкая пуля плющится о стену.
	ce_ricochets_max = 0

/obj/item/ammo_casing/pistol/magnum/ap
	desc = "An armor piercing high-power pistol bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/pistol/strong/ap
	icon_state = "15mmP_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "15mmP_ap"

/obj/item/ammo_casing/pistol/magnum/hp
	desc = "A hollow point high-power pistol bullet casing."
	label = "HP"
	projectile_type = /obj/item/projectile/bullet/pistol/strong/hp
	icon_state = "15mmP_hp"
	ce_ammo_color = CE_AMMO_COLOR_HP
	ce_box_sprite = "15mmP_hp"

/obj/item/ammobox/magnum/ap
	ammo_type = /obj/item/ammo_casing/pistol/magnum/ap

/obj/item/ammobox/magnum/hp
	ammo_type = /obj/item/ammo_casing/pistol/magnum/hp
