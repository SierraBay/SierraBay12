/singleton/surgery_step/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	.=..()
	var/obj/item/I = target.get_covering_equipped_item_by_zone(target_zone)
	if(I && (I.body_parts_covered))
		. -= 30
