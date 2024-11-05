/obj/item/mech_equipment/mounted_system/taser/plasma
	disturb_passengers = TRUE
	icon_state = "railauto"
	heat_generation = 15

/obj/item/gun/energy/plasmacutter/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/plasmacutter/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/plasmacutter/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
