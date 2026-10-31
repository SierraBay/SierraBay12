/*
	COMBAT_EXTENDED — свечение раскалённой брони (`mods/combat_extended/code/laser_heat.dm`).

	Горячую пластину видно через плитоноску, поэтому плитоноска перерисовывает свечение, когда
	пластину пристёгивают или отстёгивают. Здесь, а не в `on_attached()` и `on_removed()`
	аксессуара: те зовутся, пока список `accessories` ещё не обновлён. Удалённый аксессуар уходит
	через `remove_accessory()` же (`accessory_deleted()`).
*/

/obj/item/clothing/attach_accessory(mob/user, obj/item/clothing/accessory/A)
	. = ..()
	ce_refresh_glow()


/obj/item/clothing/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	. = ..()
	ce_refresh_glow()
