/*
	COMBAT_EXTENDED: бронебойные (AP) патроны 5.56x45. Снаряд, гильза и коробка россыпи. HP
	винтовкам нет: так задумано, спрайтов под него нет. Как подобраны числа: README, "Патроны FMJ,
	AP и HP". Где взять в игре: пока нигде.
*/

/obj/item/projectile/bullet/rifle/ap
	// 15.4 мм против 10.5 у FMJ: `ARMOR_BALLISTIC_RESISTANT` (11 мм) пробивает, `ARMOR_BALLISTIC_RIFLE`
	// (16 мм) держит.
	damage = 35
	armor_penetration = 55
	ce_blunt_penetration_of = /obj/item/projectile/bullet/rifle

/obj/item/ammo_casing/rifle/ap
	desc = "An armor piercing rifle bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/rifle/ap
	icon_state = "5mmR_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "5mmR_ap"

/obj/item/ammobox/rifle/ap
	ammo_type = /obj/item/ammo_casing/rifle/ap
