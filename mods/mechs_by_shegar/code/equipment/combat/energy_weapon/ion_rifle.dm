/obj/item/mech_equipment/mounted_system/taser/ion
	heat_generation = 20

/obj/item/mech_equipment/mounted_system/taser/ion/need_combat_skill()
	return TRUE

/obj/item/gun/energy/ionrifle/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/ionrifle/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/ionrifle/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
