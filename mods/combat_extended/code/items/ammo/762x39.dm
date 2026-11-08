/*
	COMBAT_EXTENDED: бронебойные (AP) патроны 7.62x39. Снаряд, гильза и коробка россыпи. HP
	винтовкам нет: так задумано, спрайтов под него нет. Как подобраны числа: README, "Патроны FMJ,
	AP и HP".
*/

/obj/item/projectile/bullet/rifle/military_standard/ap
	// 15.7 мм против 10.0 у FMJ: `ARMOR_BALLISTIC_RESISTANT` (11 мм) пробивает,
	// `ARMOR_BALLISTIC_RIFLE` (16 мм) держит. Удар FMJ (`ce_blunt_penetration`) наследуется от
	// штатной пули.
	damage = 40
	armor_penetration = 55

/obj/item/ammo_casing/rifle/military/ap
	desc = "An armor piercing military rifle bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/rifle/military_standard/ap
	icon_state = "7mmR_ap"
	ce_ammo_color = CE_AMMO_COLOR_AP
	ce_box_sprite = "7mmR_ap"

/obj/item/ammobox/rifle/military/ap
	ammo_type = /obj/item/ammo_casing/rifle/military/ap
