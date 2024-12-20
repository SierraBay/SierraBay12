/obj/item/mech_equipment/mounted_system/taser
	heat_generation = 10

/obj/item/mech_equipment/mounted_system/taser/need_combat_skill()
	return TRUE

/obj/item/gun/energy/taser/carbine/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/taser/carbine/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)

/obj/item/gun/energy/taser/carbine/mounted/mech/Initialize()
	.=..()
	holder = loc
