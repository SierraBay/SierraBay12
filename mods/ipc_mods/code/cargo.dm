/singleton/hierarchy/supply_pack/prosthesis
	name = "Prosthetics"
	var/manufacturer

/singleton/hierarchy/supply_pack/prosthesis/Initialize()
	. = ..()
	for(var/p in subtypesof(/obj/item/organ/external))
		var/obj/item/organ/external/parts = p
		if(parts in contains)
			parts.robotize(manufacturer)

/singleton/hierarchy/supply_pack/prosthesis/nt
	name = "NY Prosthetics"
	containername = "Set of NT prosthetics"
	manufacturer = "NanoTrasen"
	contains = list(
		/obj/item/organ/external/arm = 2,
		/obj/item/organ/external/arm/right = 2,
		/obj/item/organ/external/chest = 1,
	)
	cost = 1
