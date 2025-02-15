/obj/effect/cult
	icon = 'icons/effects/effects.dmi'
	opacity = FALSE
	anchored = TRUE
	mouse_opacity = FALSE
	layer = ABOVE_HUMAN_LAYER

/obj/effect/cult/rune_teleport
	name = "teleportation"
	icon_state = "rune_teleport"

/obj/effect/cult/rune_teleport/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/cult/rune_teleport/LateInitialize()
	animate(src, alpha = 0, 3 SECONDS, easing = EASE_IN)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/cult/rune_teleport_appear
	name = "teleportation_appearing"
	icon_state = "rune_teleport"
	icon = 'mods/antagonists/icons/effects/cult_icons.dmi'

/obj/effect/cult/rune_teleport_appear/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/cult/rune_teleport_appear/LateInitialize()
	animate(src, alpha = 0, 3 SECONDS, easing = EASE_IN)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/cult/rune_convert
	name = "convert"
	icon_state = "rune_convert"

/obj/effect/cult/rune_convert/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/cult/rune_convert/LateInitialize()
	animate(src, alpha = 0, 3 SECONDS, easing = EASE_IN)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/cult/rune_sacrifice
	name = "sacrifice"
	icon_state = "rune_sac"

/obj/effect/cult/rune_sacrifice/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/cult/rune_sacrifice/LateInitialize()
	animate(src, alpha = 0, 3 SECONDS, easing = EASE_IN)
	QDEL_IN(src, 3 SECONDS)

/obj/rune/convert/Topic(href, href_list)
	if(href_list["join"])
		if(usr.loc == loc && !iscultist(usr))
			new /obj/effect/cult/rune_convert(get_turf(usr))
			GLOB.cult.add_antagonist(usr.mind, ignore_role = 1, do_not_equip = 1)

/obj/rune/teleport/cast(mob/living/user)
	if(user.loc == src)
		showOptions(user)
	else if(user.loc == get_turf(src))
		speak_incantation(user, "Sas[pick("'","`")]so c'arta forbici!")
		if(do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE))
			user.visible_message(SPAN_WARNING("\The [user] disappears in a flash of red light!"), SPAN_WARNING("You feel as your body gets dragged into the dimension of Nar-Sie!"), "You hear a sickening crunch.")
			new /obj/effect/cult/rune_teleport(get_turf(user))
			user.forceMove(src)
			showOptions(user)
			var/warning = 0
			while(user.loc == src)
				user.take_organ_damage(0, 2)
				if(user.getFireLoss() > 50)
					to_chat(user, SPAN_DANGER("Your body can't handle the heat anymore!"))
					leaveRune(user)
					return
				if(warning == 0)
					to_chat(user, SPAN_WARNING("You feel the immerse heat of the realm of Nar-Sie..."))
					++warning
				if(warning == 1 && user.getFireLoss() > 15)
					to_chat(user, SPAN_WARNING("Your burns are getting worse. You should return to your realm soon..."))
					++warning
				if(warning == 2 && user.getFireLoss() > 35)
					to_chat(user, SPAN_WARNING("The heat! It burns!"))
					++warning
				sleep(10)
	else
		var/input = input(user, "Choose a new rune name.", "Destination", "") as text|null
		if(!input)
			return
		destination = sanitize(input)

/obj/rune/teleport/leaveRune(mob/living/user)
	if(user.loc != src)
		return
	new /obj/effect/cult/rune_teleport_appear(get_turf(user))
	sleep(10)
	user.dropInto(loc)
	user.visible_message(SPAN_WARNING("\The [user] appears in a flash of red light!"), SPAN_WARNING("You feel as your body gets thrown out of the dimension of Nar-Sie!"), "You hear a pop.")

/obj/rune/offering/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(victim)
		to_chat(user, SPAN_WARNING("You are already sarcificing \the [victim] on this rune."))
		return
	if(length(cultists) < 3)
		to_chat(user, SPAN_WARNING("You need three cultists around this rune to make it work."))
		return fizzle(user)
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(M.stat != DEAD && !iscultist(M))
			victim = M
			break
	if(!victim)
		return fizzle(user)

	for(var/mob/living/M in cultists)
		M.say("Barhah hra zar[pick("'","`")]garis!")

	while(victim && victim.loc == T && victim.stat != DEAD)
		var/list/mob/living/casters = get_cultists()
		if(length(casters) < 3)
			break
		//T.turf_animation('icons/effects/effects.dmi', "rune_sac")
		victim.fire_stacks = max(2, victim.fire_stacks)
		victim.IgniteMob()
		victim.take_organ_damage(2 + length(casters), 2 + length(casters)) // This is to speed up the process and also damage mobs that don't take damage from being on fire, e.g. borgs
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			if(H.is_asystole())
				H.adjustBrainLoss(2 + length(casters))
		sleep(40)
	if(victim && victim.loc == T && victim.stat == DEAD)
		GLOB.cult.add_cultiness(CULTINESS_PER_SACRIFICE)
		new /obj/effect/cult/rune_sacrifice(get_turf(src))
		var/obj/item/device/soulstone/full/F = new(get_turf(src))
		for(var/mob/M in cultists | get_cultists())
			to_chat(M, SPAN_WARNING("The Geometer of Blood accepts this offering."))
		visible_message(SPAN_NOTICE("\The [F] appears over \the [src]."))
		GLOB.cult.sacrificed += victim.mind
		if(victim.mind == GLOB.cult.sacrifice_target)
			for(var/datum/mind/H in GLOB.cult.current_antagonists)
				if(H.current)
					to_chat(H.current, SPAN_OCCULT("Your objective is now complete."))
		//TODO: other rewards?
		/* old sac code - left there in case someone wants to salvage it
		var/worth = 0
		if(istype(H,/mob/living/carbon/human))
			var/mob/living/carbon/human/lamb = H
			if(lamb.species.rarity_value > 3)
				worth = 1

		if(H.mind == cult.sacrifice_target)

		to_chat(usr, SPAN_WARNING("The Geometer of Blood accepts this sacrifice, your objective is now complete."))

		to_chat(usr, SPAN_WARNING("The Geometer of Blood accepts this [worth ? "exotic " : ""]sacrifice."))

		to_chat(usr, SPAN_WARNING("The Geometer of blood accepts this sacrifice."))
		to_chat(usr, SPAN_WARNING("However, this soul was not enough to gain His favor."))

		to_chat(usr, SPAN_WARNING("The Geometer of blood accepts this sacrifice."))
		to_chat(usr, SPAN_WARNING("However, a mere dead body is not enough to satisfy Him."))
		*/
		to_chat(victim, SPAN_OCCULT("The Geometer of Blood claims your body."))
		victim.dust()
	if(victim)
		victim.ExtinguishMob() // Technically allows them to put the fire out by sacrificing them and stopping immediately, but I don't think it'd have much effect
		victim = null
