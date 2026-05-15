/obj/psi_plane/psinomaly
	name = "Псионическое возмущение"
	desc = "Прореха в самой ткани реальности. Он пульсирует от неописуемых энергий, клубящихся вокруг него."
	icon = 'mods/psionics/icons/effects/psi_effects.dmi'
	icon_state = "reality_smash"
	layer = ABOVE_HUMAN_LAYER
	density = TRUE
	anchored = TRUE
	var/charged = TRUE

	invisibility = INVISIBILITY_PSI_PLANE


/obj/psi_plane/psinomaly/Initialize()
	. = ..()

	var/list/places_to_spawn = list()
	for(var/turf/T in orange(1, src))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(locate(/obj/structure/wall_frame) in T) continue
		places_to_spawn.Add(T)
	if(!LAZYLEN(places_to_spawn))
		places_to_spawn.Add(get_turf(src))

	var/mob_path
	var/amount = rand(1,3)

	var/squad = pick("spider", "vagrant")
	switch(squad)
		if("spider")
			mob_path = /mob/living/simple_animal/hostile/giant_spider/psi
		if("vagrant")
			mob_path = /mob/living/simple_animal/hostile/vagrant/psi

	for(var/i = 1 to amount)
		var/turf/spawn_loc = pick(places_to_spawn)
		new mob_path(spawn_loc)
		if(LAZYLEN(places_to_spawn) > 1)
			places_to_spawn -= spawn_loc

	update_icon()

/obj/psi_plane/psinomaly/on_update_icon()
	ClearOverlays()
	if(charged)
		var/image/I = image(icon, "plane_glow")
		I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
		I.color = get_random_colour(0, 150, 255)
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		AddOverlays(I)
		set_light(2, 0.3, l_color = I.color)

/obj/psi_plane/psinomaly/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()

/obj/psi_plane/psinomaly/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE))
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(charged)
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				to_chat(H, SPAN_WARNING("После прикосновения к аномалии, она начинает угасать!"))
				if(prob(70))
					var/list/balm_messages = list(
						"Успокаивающие мысли омывают вашу психонетику.",
						"На момент, ты слышишь приятный, знакомый голос, что поет песню где-то в дали.",
						"Чувство покоя и комфорта окутывает вас, словно теплое одеяло."
						)
					var/soothed
					if(H.psi.stun > 1)
						H.psi.stun--
						soothed = TRUE
					else if(H.psi.stamina < H.psi.max_stamina)
						H.psi.stamina = min(H.psi.max_stamina, H.psi.stamina + rand(1,3))
						soothed = TRUE
					else if(H.psi.owner.getBrainLoss() > 0)
						H.psi.owner.adjustBrainLoss(-1)
						soothed = TRUE
					if(soothed && prob(10))
						to_chat(H.psi.owner, SPAN_NOTICE("<i>[pick(balm_messages)]</i>"))
				else
					var/list/whine_messages = list(
						"Вой, что угнетает твой мозг, вторгается в твою голову.",
						"Ужасный, отвлекающий жужжащий звук прерывает ход твоих мыслей.",
						"Ты ощущаешь страшную мигрень, как в твою голову вторгается знакомый вой."
						)
					var/annoyed
					if(prob(1))
						H.psi.stunned(1)
						annoyed = TRUE
					else if(H.psi.stamina > 0)
						H.psi.stamina = max(0, H.psi.stamina - rand(1,3))
						annoyed = TRUE
					if(annoyed && prob(1))
						to_chat(H.psi.owner, SPAN_NOTICE("<i>[pick(whine_messages)]</i>"))
					H.Paralyse(2)
					H.hallucination(20, 100)
				return
			else
				to_chat(user, SPAN_NOTICE("Ты соприкасаешься с аномалией, но она угасла и не реагирует на тебя, оставляя лишь чувство утраты в твоей груди и холод в руке."))
	else
		to_chat(user, SPAN_NOTICE("Ты соприкасаешься с аномалией, но она никак не реагирует на тебя, будто тебя для неё не существует."))
