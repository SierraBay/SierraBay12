// Automatically arms the missile upon reaching the map edge if it isn't already active
/obj/item/missile_equipment/autoarm
	name = "automatic missile activator"
	desc = "A system that automatically arms missiles."

/obj/item/missile_equipment/autoarm/on_touch_map_edge(obj/overmap/missile/P)
	var/obj/structure/missile/M = loc
	if(!istype(M))
		return

	if(!M.active)
		M.activate()

// Breacher
/obj/item/missile_equipment/autoarm/breacher/on_missile_activated(obj/overmap/missile/P)
	P.set_dangerous(TRUE)
	P.set_enter_zs(TRUE)
