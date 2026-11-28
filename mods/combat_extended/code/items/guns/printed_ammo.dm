/*
	A printer makes magazines and guns with no rounds in them. The rounds come from the
	ammunition box designs (`mods/RnD/code/designs_autolathe/designs_arms_ammo.dm`).
	A printed magazine gun keeps its empty magazine.
*/

/obj/item/ammo_magazine/PostFabrication()
	. = ..()
	ce_remove_all_rounds()


/obj/item/gun/projectile/PostFabrication()
	. = ..()
	QDEL_NULL(chambered)
	QDEL_NULL_LIST(loaded)
	loaded = list()
	ammo_magazine?.ce_remove_all_rounds()
	update_icon()


/// Deletes every round in the magazine.
/obj/item/ammo_magazine/proc/ce_remove_all_rounds()
	QDEL_NULL_LIST(stored_ammo)
	stored_ammo = list()
	update_icon()
