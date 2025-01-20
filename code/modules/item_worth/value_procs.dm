/atom/proc/Value(base)
	return base

/obj/Value()
	. = ..()
	for(var/a in contents)
		. += get_value(a)

/obj/machinery/Value(base)
	. = ..()
	if(MACHINE_IS_BROKEN(src))
		. *= 0.5
	. = round(.)

/obj/structure/barricade/Value(base)
	return material.value

/obj/structure/bed/Value()
	return ..() * material.value

/obj/item/slime_extract/Value(base)
	return base * Uses

/obj/item/ammo_casing/Value(base)
	if(!BB)
		return 1
	return ..()

/obj/item/reagent_containers/Value(base)
	. = ..()
	if(reagents)
		for(var/a in reagents.reagent_list)
			var/datum/reagent/reg = a
			. += reg.Value() * reg.volume
	. = round(.)

/datum/reagent/proc/Value(base)
	return value

/obj/item/stack/Value(base)
	return base * amount

/obj/item/stack/material/Value(base)
	if(!material)
		return ..()
	. = material.value * amount
	if(reinf_material)
		. += reinf_material.value * amount

/obj/item/ore/Value(base)
	return material ? material.value : 0

/obj/item/material/Value(base)
	return material.value * worth_multiplier

/obj/item/spacecash/Value(base)
	return worth

/mob/living/carbon/human/Value(base)
	. = ..()
	if(species)
		. *= species.rarity_value
