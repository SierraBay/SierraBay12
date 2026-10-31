/*
	COMBAT_EXTENDED — снаряды с зарядом, который срабатывает там, где снаряд кончился: ионные заряды и
	гироджет из `code/modules/projectiles/projectile/special.dm`, патроны с ионным зарядом из
	`code/modules/projectiles/ammunition/bullets.dm`, ракеты из `mods/rocket_launchers/code/rockets.dm`
	и `mods/mechs_by_shegar/code/equipment/combat/rocket_launcher.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Кончается ли снаряд на дальности точки прицела (`ce_lands_at_aim`, `projectile_landing.dm`). По
	умолчанию — нет: пуля летит до первой преграды. Подтип без своего значения берёт значение
	родителя. Патронам с ионным зарядом — ещё вид пули.
*/

/obj/item/projectile/ion
	// Ионная винтовка, ионный пистолет, ионная пушка меха и робота: ЭМИ — там, куда целились.
	ce_lands_at_aim = TRUE

/obj/item/projectile/ion/haywire
	// Ионный заряд дробового слага. Патроны с ионным зарядом летят как пули, до первой преграды, и
	// выглядят и звучат как пуля — спрайт и вспышка у ствола пули, выстрел самого ствола вместо
	// лазера: от патрона этого и ждут, а нужны они, чтобы быстро добить робота, а не глушить площадь.
	// Свой подтип — потому что заряд у патронов тот же, что у ионного оружия.
	ce_lands_at_aim = FALSE
	icon_state = "bullet"
	muzzle_type = /obj/projectile/bullet
	fire_sound = null

/obj/item/projectile/ion/small/haywire
	// Ионный заряд пистолетного патрона.
	ce_lands_at_aim = FALSE
	icon_state = "bullet"
	muzzle_type = /obj/projectile/bullet
	fire_sound = null

/obj/item/projectile/ion/tiny/haywire
	// Ионный заряд малого пистолетного патрона.
	ce_lands_at_aim = FALSE
	icon_state = "bullet"
	muzzle_type = /obj/projectile/bullet
	fire_sound = null

/obj/item/projectile/bullet/gyro
	// Миниракета гироджета, в том числе у мегабота улья.
	ce_lands_at_aim = TRUE

/obj/item/ammo_casing/pistol/emp
	// Пистолетный патрон с ионным зарядом летит как пуля.
	projectile_type = /obj/item/projectile/ion/small/haywire

/obj/item/ammo_casing/pistol/small/emp
	projectile_type = /obj/item/projectile/ion/tiny/haywire

/obj/item/ammo_casing/shotgun/emp
	projectile_type = /obj/item/projectile/ion/haywire

/obj/item/projectile/bullet/rpg_rocket
	// Все ракеты РПГ: осколочные, кумулятивные, тандемные.
	ce_lands_at_aim = TRUE

/obj/item/projectile/bullet/rocket
	// Ракеты «Града» меха: фугасные, газовые, светошумовые, зажигательные.
	ce_lands_at_aim = TRUE
