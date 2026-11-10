/*
	COMBAT_EXTENDED: экспансивные (HP) патроны 9x19. Снаряд, гильза и коробка россыпи. Как
	подобраны числа: README, "Патроны FMJ, AP и HP".

	Бронебойный 9x19 уже есть: `mods/guns/code/modded.dm`, там и его урон с AP. Здесь только его
	удар.
*/

/obj/item/projectile/bullet/pistol/holdout/ap
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol/holdout

/obj/item/projectile/bullet/pistol/holdout/hp
	// 2.4 мм против 4.1 у FMJ: держит уже `ARMOR_BALLISTIC_SMALL` (3 мм).
	damage = 50
	armor_penetration = -25
	ce_blunt_penetration_of = /obj/item/projectile/bullet/pistol/holdout
	ce_blunt_penetration_mult = 0.5
	// Мягкая пуля плющится о стену.
	ce_ricochets_max = 0

/obj/item/ammo_casing/pistol/small/hp
	desc = "A small hollow point pistol bullet casing."
	label = "HP"
	projectile_type = /obj/item/projectile/bullet/pistol/holdout/hp
	icon_state = "7mm_hp"
	ce_ammo_color = CE_AMMO_COLOR_HP
	ce_box_sprite = "7mm_hp"

/obj/item/ammobox/pistol/small_hp
	ammo_type = /obj/item/ammo_casing/pistol/small/hp
