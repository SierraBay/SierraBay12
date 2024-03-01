/obj/item/missile_equipment/payload/explosive
	name = "explosive charge"
	desc = "An explosive charge. Detonates when the missile is triggered."
	icon_state = "explosive"

/obj/item/missile_equipment/payload/explosive/on_trigger(atom/triggerer)
	explosion(get_turf(src), 16)

	..()
