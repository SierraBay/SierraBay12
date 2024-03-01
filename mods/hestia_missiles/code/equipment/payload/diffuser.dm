// Diffuses shields in a large radius for a long time
/obj/item/missile_equipment/payload/diffuser
	name = "dynamic antiphase emitter"
	desc = "A one time use device designed to emit a strong, lasting strobe of antiphase EM waves. It can diffuse large shield sections for a long period of time, possibly causing massive damage to them as well."
	icon_state = "diffuse"

	var/diffuse_range = 60
	var/diffuse_duration = 120
	var/damage_induced = 600 //Two will certainly take out a 9MJ shield.

/obj/item/missile_equipment/payload/diffuser/on_trigger()
	for(var/turf/T in trange(diffuse_range, get_turf(src)))
		for(var/obj/shield/S in T)
			S.diffuse(diffuse_duration)
			S.take_damage(damage_induced) //not that unreasonable
	..()
