/singleton/hierarchy/supply_pack/prosthesis
	name = "Prosthetics"
	var/manufacturer

/singleton/hierarchy/supply_pack/prosthesis/Initialize()
	. = ..()
	for(var/obj/item/organ/external/R in contains)
		basic_robolimb.company = manufacturer
		R.SetName("[basic_robolimb.company] [initial(R.name)]")
		R.desc = "[basic_robolimb.company] [basic_robolimb.desc]"
		R.icon = basic_robolimb.icon

/singleton/hierarchy/supply_pack/prosthesis/nt
	name = "NY Prosthetics"
	containername = "Set of NT prosthetics"
	manufacturer = "NanoTrasen"
	contains = list(
		/obj/item/organ/external/arm = 2
	)
	cost = 1
