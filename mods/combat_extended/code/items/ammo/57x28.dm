/*
	COMBAT_EXTENDED: бронебойные (AP) и экспансивные (HP) патроны 5.7x28. Снаряд, гильза и коробка
	россыпи. Как подобраны числа: README, "Патроны FMJ, AP и HP". Где взять в игре: пока нигде.

	FMJ 5.7x28 берёт 6.4 мм и пробивает `ARMOR_BALLISTIC_PISTOL` (6 мм) едва-едва. Окна AP и HP
	считаются от этого.
*/

/obj/item/projectile/bullet/pistol/fast/ap
	// 15.4 мм: `ARMOR_BALLISTIC_RESISTANT` (11 мм) пробивает, `ARMOR_BALLISTIC_RIFLE` (16 мм) держит.
	damage = 35
	armor_penetration = 55
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol/fast

/obj/item/projectile/bullet/pistol/fast/hp
	// 3.6 мм: `ARMOR_BALLISTIC_SMALL` (3 мм) пробивает, `ARMOR_BALLISTIC_PISTOL` держит.
	damage = 55
	armor_penetration = -10
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol/fast
	// Мягкая пуля плющится о стену.
	ce_ricochets_max = 0

/obj/item/ammo_casing/nt28mm/ap
	desc = "An armor piercing casing used in NT submachine guns."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/pistol/fast/ap
	icon_state = "5.7mmP_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "5.7mmP_ap"

/obj/item/ammo_casing/nt28mm/hp
	desc = "A hollow point casing used in NT submachine guns."
	label = "HP"
	projectile_type = /obj/item/projectile/bullet/pistol/fast/hp
	icon_state = "5.7mmP_hp"
	ce_ammo_color = CE_AMMO_COLOR_HP
	ce_box_sprite = "5.7mmP_hp"

// Коробка FMJ 5.7x28, `/obj/item/ammobox/nt41`, лежит в модпаке `guns`.
/obj/item/ammobox/nt41/ap
	ammo_type = /obj/item/ammo_casing/nt28mm/ap

/obj/item/ammobox/nt41/hp
	ammo_type = /obj/item/ammo_casing/nt28mm/hp
