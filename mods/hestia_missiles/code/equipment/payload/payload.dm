// Destroys missiles that are traveling on the overmap
/obj/item/missile_equipment/payload
	name = "missile payload"
	desc = "dangerous equipment!!"

/obj/item/missile_equipment/payload/on_missile_activated(obj/overmap/missile/P)
	P.set_dangerous(TRUE)
	P.set_enter_zs(TRUE)

/obj/item/missile_equipment/payload/on_trigger(atom/triggerer)
	qdel(loc)
