// Diffuses shields in a large radius for a long time
/obj/item/missile_equipment/payload/emp
	name = "EMP device"
	desc = "Emits a strong electromagnetic pulse when the detonation mechanism of the missile it's fitted in is triggered."
	icon_state = "probe"

/obj/item/missile_equipment/payload/emp/on_trigger(atom/triggerer)
	if(istype(triggerer, /obj/shield))
		empulse(get_turf(src), rand(3,6), rand(7,9))
	else
		empulse(get_turf(triggerer), rand(6,12), rand(14,20))

	..()
