/*
	COMBAT_EXTENDED — дротики: типы из `code/modules/projectiles/guns/projectile/dartgun.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».
*/

/obj/item/projectile/bullet/chemdart
	// Дротик впрыскивает, только воткнувшись в тело: остановленный бронёй, он не впрыскивает
	// ничего. Флаг наследует и органический дротик генокрада
	// (`/obj/item/projectile/bullet/chemdart/changeling`): его жало тоже бьёт уколом.
	ce_effects_need_penetration = TRUE
