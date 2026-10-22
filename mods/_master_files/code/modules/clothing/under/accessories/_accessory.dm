/*
	COMBAT_EXTENDED — свечение раскалённой брони на аксессуарах
	(`mods/combat_extended/code/laser_heat.dm`).

	Пристёгнутый аксессуар рисуется на носителе своей картинкой, мимо `get_mob_overlay()` одежды,
	поэтому своё свечение и прожоги он накладывает здесь.
*/

/obj/item/clothing/accessory/get_mob_overlay(mob/user_mob, slot)
	. = ..()
	// Непристёгнутый аксессуар рисуется как обычная одежда, и свечение уже наложено там.
	if(istype(loc, /obj/item/clothing))
		ce_glow_worn_image(., slot)
		ce_draw_scorch_marks(., slot)
