/obj/structure/fake_beacon
	name = "distress beacon"
	desc = "WARNING: Will deploy ship's distress beacon and request help. Misuse may result in fines and jail time."
	icon = 'packs/infinity/icons/obj/panicbutton.dmi'
	icon_state = "panicbutton"
	anchored = TRUE
	var/triggered = FALSE

/obj/structure/fake_beacon/Initialize()
	. = ..()
	addtimer(new Callback(src, PROC_REF(launch)), rand(10,20) MINUTES)

/obj/structure/fake_beacon/proc/launch()
	if(GAME_STATE < RUNLEVEL_GAME)
		addtimer(new Callback(src, PROC_REF(launch)), 5 MINUTES)
		return

	var/sound/SND = sound('packs/infinity/sound/misc/emergency_beacon_launched.ogg')

	var/overmap_sector
	if(GLOB.using_map.use_overmap)
		overmap_sector = map_sectors["[z]"]

	var/obj/overmap/visitable/S = overmap_sector
	if(!S)
		error("Distress beacon on z[z] but that's not an overmap sector...")
		return
	S.distress(null)
	playsound(src, SND, 25)

/obj/structure/fake_beacon/attack_hand(mob/living/user)
	if(!istype(user))
		return ..()

	if(user.incapacitated())
		return

	src.visible_message(SPAN_NOTICE("\The [user] flips \the [src] switch."))
	if(do_after(user, 1 SECONDS, src, DO_DEFAULT | DO_TARGET_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		if(triggered)
			src.visible_message(SPAN_NOTICE("nothing happend"))
			return

		triggered = TRUE
		addtimer(new Callback(src, PROC_REF(detonate)), 3 SECONDS)


/obj/structure/fake_beacon/proc/detonate()
	switch(rand(0,3))
		if(1)
			explosion(loc, 1, 2, 3, 5)
		if(2)
			empulse(loc, 3, 25)
		if(3)
			var/mob/living/target = locate() in view(7, src)
			if (!target)
				return
			var/obj/item/throw_item = new /obj/item/grenade/frag
			spawn(0)
				throw_item.throw_at(target, rand(3,6), 4)
			visible_message(SPAN_WARNING("\The [src] launches \a [throw_item] at \the [target]!"))
			return TRUE
	// announce
