/obj/item/mech_equipment/mounted_system/melee/mechete
	heat_generation = 20

/obj/item/material/hatchet/machete/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/material/hatchet/machete/mech/Initialize()
	. = ..()
	holder = loc
