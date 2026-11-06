/*
	COMBAT_EXTENDED: бронебойные (AP) и экспансивные (HP) патроны 10mm Auto. Снаряд, гильза и
	коробка россыпи. Как подобраны числа: README, "Патроны FMJ, AP и HP". Где взять в игре: пока
	нигде.
*/

/obj/item/projectile/bullet/pistol/ap
	// 9.9 мм против 4.4 у FMJ: `ARMOR_BALLISTIC_PISTOL` (6 мм) пробивает, `ARMOR_BALLISTIC_RESISTANT`
	// (11 мм) держит.
	damage = 35
	armor_penetration = 25
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol

/obj/item/projectile/bullet/pistol/hp
	// 2.5 мм: держит уже `ARMOR_BALLISTIC_SMALL` (3 мм).
	damage = 55
	armor_penetration = -25
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol
	// Мягкая пуля плющится о стену.
	ce_ricochets_max = 0

/obj/item/ammo_casing/pistol/ap
	desc = "An armor piercing pistol bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/pistol/ap
	icon_state = "10mm_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "10mm_ap"

/obj/item/ammo_casing/pistol/hp
	desc = "A hollow point pistol bullet casing."
	label = "HP"
	projectile_type = /obj/item/projectile/bullet/pistol/hp
	icon_state = "10mm_hp"
	ce_ammo_color = CE_AMMO_COLOR_HP
	ce_box_sprite = "10mm_hp"

/obj/item/ammobox/pistol/ap
	ammo_type = /obj/item/ammo_casing/pistol/ap

/obj/item/ammobox/pistol/hp
	ammo_type = /obj/item/ammo_casing/pistol/hp
