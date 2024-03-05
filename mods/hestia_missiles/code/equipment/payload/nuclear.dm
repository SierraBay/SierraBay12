/obj/item/missile_equipment/payload/nuclear
	name = "small nuclear warhead"
	desc = "An incredibly dangerous warhead. Detonates when the missile is triggered."
	icon_state = "ion"

/obj/item/missile_equipment/payload/nuclear/on_trigger(atom/triggerer)
	var/list/relevant_z = GetConnectedZlevels(loc.z)

	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in relevant_z))
			continue
		to_chat("<font size='4' color='red'><b>Suddenly a bright blinding flash appears in nearby outer space, followed by a deadly shockwave!</b></font>")
		if(M.eyecheck() < FLASH_PROTECTION_MAJOR)
			M.flash_eyes()
			M.updatehealth()
		sound_to(M, sound('sound/effects/explosionfar.ogg'))

	if(!istype(triggerer, /obj/shield))
		SSradiation.radiate(get_turf(triggerer), 40)

	empulse(get_turf(triggerer), rand(20,40), rand(50,80))
	explosion(get_turf(triggerer), 96)

	..()

/// adminbus
/obj/item/missile_equipment/payload/big_nuclear
	name = "nuclear warhead"
	desc = "An incredibly dangerous warhead. Detonates when the missile is triggered."
	icon_state = "nuclear"

/obj/item/missile_equipment/payload/big_nuclear/on_trigger(atom/triggerer)
	var/list/relevant_z = GetConnectedZlevels(loc.z)

	for(var/mob/living/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in relevant_z))
			continue
		to_chat("<font size='5' color='red'><b>Your doomsday is calling...</b></font>")
		M.flash_eyes(FLASH_PROTECTION_MAJOR)
		M.updatehealth()
		sound_to(M, sound('sound/effects/explosionfar.ogg'))

	if(!istype(triggerer, /obj/shield))
		SSradiation.radiate(get_turf(triggerer), 400)

	explosion(get_turf(triggerer), 192)
	empulse(get_turf(triggerer), rand(50,75), rand(75,100))

	..()
