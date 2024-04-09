/obj/item/missile_equipment/payload/void
	name = "void warhead"
	desc = "An incredibly dangerous warhead. Detonates when the missile is triggered."
	icon_state = "diffuse"

/obj/item/missile_equipment/payload/void/on_trigger(atom/triggerer)
	var/list/relevant_z = GetConnectedZlevels(loc.z)

	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in relevant_z))
			continue
		to_chat("<font size='5' color='red'><b>The world distorts around you momentarily!</b></font>")
		if(M.eyecheck() < FLASH_PROTECTION_MAJOR)
			M.flash_eyes()
			M.updatehealth()
		if(!isdeaf(M))
			sound_to(M, sound('sound/effects/heavy_cannon_blast.ogg'))

	empulse(get_turf(triggerer), rand(6,8), rand(8,12))
	explosion(get_turf(triggerer), 25)

	..()
