/*
	COMBAT_EXTENDED: бронебойные (AP) и экспансивные (HP) патроны 4mm. Снаряд, гильза и коробка
	россыпи. Как подобраны числа: README, "Патроны FMJ, AP и HP". Где взять в игре: пока нигде.

	FMJ 4mm берёт 11.7 мм и пробивает `ARMOR_BALLISTIC_RESISTANT` (11 мм) едва-едва. Окна AP и
	HP считаются от этого.
*/

/obj/item/projectile/bullet/flechette/ap
	// 18.9 мм: `ARMOR_BALLISTIC_RIFLE` (16 мм) пробивает, `ARMOR_BALLISTIC_AP` (20 мм) держит. Урона
	// мало, и через rifle-плиту доходит около 2 урона.
	damage = 15
	armor_penetration = 85
	ce_blunt_penetration_of = /obj/item/projectile/bullet/flechette

/obj/item/projectile/bullet/flechette/hp
	// 3.4 мм: `ARMOR_BALLISTIC_SMALL` (3 мм) пробивает, `ARMOR_BALLISTIC_PISTOL` (6 мм) держит.
	damage = 30
	armor_penetration = 0
	ce_blunt_penetration_of = /obj/item/projectile/bullet/flechette
	// Раскрывшаяся пуля не проходит цель навылет.
	penetrating = 0
	// Мягкая пуля плющится о стену.
	ce_ricochets_max = 0

/obj/item/ammo_casing/flechette/ap
	desc = "An armor piercing flechette casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/flechette/ap
	icon_state = "4mm_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "4mm_ap"

/obj/item/ammo_casing/flechette/hp
	desc = "A hollow point flechette casing."
	label = "HP"
	projectile_type = /obj/item/projectile/bullet/flechette/hp
	icon_state = "4mm_hp"
	ce_ammo_color = CE_AMMO_COLOR_HP
	ce_box_sprite = "4mm_hp"

/obj/item/ammobox/flechette/ap
	ammo_type = /obj/item/ammo_casing/flechette/ap

/obj/item/ammobox/flechette/hp
	ammo_type = /obj/item/ammo_casing/flechette/hp
