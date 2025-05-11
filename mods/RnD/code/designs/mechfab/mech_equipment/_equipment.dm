/datum/design/item/mech
	build_type = MECHFAB
	category = list("Mech Equipment")
	time = 10
	materials = list(MATERIAL_STEEL = 10000)

/datum/design/item/mech/AssembleDesignDesc()
	if(!desc)
		desc = "Allows for the construction of \a [item_name] for installation in an mech hardpoint."
// End mechs.
