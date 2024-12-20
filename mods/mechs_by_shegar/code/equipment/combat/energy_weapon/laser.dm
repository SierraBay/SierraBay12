/obj/item/mech_equipment/mounted_system/taser/laser
	heat_generation = 50

/obj/item/mech_equipment/mounted_system/taser/laser/need_combat_skill()
	return TRUE

/obj/item/gun/energy/lasercannon/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/lasercannon/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/lasercannon/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
