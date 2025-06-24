//Данная броня переопределена в слот декора, чтобы не занимать слот утилити.
/obj/item/clothing/accessory/armor_plate/sneaky
	slot = ACCESSORY_SLOT_DECOR
	on_rolled_down = "undervest"

//Теперь действительно скрыт под одеждой.
/obj/item/clothing/accessory/armor_plate/sneaky/get_mob_overlay(mob/user_mob, slot)
	if(istype(loc,/obj/item/clothing/under))
		var/obj/item/clothing/under/C = loc
		if (on_rolled_down && C.rolled_down > 0)
			return ..()
		else
			return null
	return ..()