//instant loadout previews regardless of chosen gear and their equip time
/datum/gear/spawn_on_mob(mob/living/carbon/human/H, metadata)
	var/obj/item/item = spawn_item(H, H, metadata)
	if(H.equip_to_slot_if_possible(item, slot, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)) //added TRYEQUIP_INSTANT
		. = item