/obj/psi_plane/psinomaly
	name = "Psionic breach"
	desc = "Breach in fabric of reality itself, leading to realm on infinite possibilities and dangers."
	icon = 'mods/psionics/icons/effects/psi_effects.dmi'
	icon_state = "reality_smash"
	layer = ABOVE_HUMAN_LAYER
	density = TRUE
	anchored = TRUE
	var/charged = TRUE
	var/aura_color = COLOR_CIVIE_GREEN

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
		I.color = aura_color
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
		if(charged)
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				to_chat(H, SPAN_WARNING("After you interacted with anomaly it started to fade away!"))
				if(prob(50))
					var/datum/event_meta/EM = new(EVENT_LEVEL_MUNDANE, "Psionic anomaly - Balm", add_to_queue = 0)
					new/datum/event/psi/balm(EM)
					to_chat(H, SPAN_NOTICE("You feel invigorated with energies of anomaly"))
				else
					var/datum/event_meta/EM = new(EVENT_LEVEL_MUNDANE, "Psionic anomaly - Wail", add_to_queue = 0)
					new/datum/event/psi/wail(EM)
					to_chat(H, SPAN_WARNING("You have a bad feeling about this..."))
				return
			else
				to_chat(H, SPAN_DANGER("A wave of uncontrolled energy emerges from the [src], and your vision flickers!"))
				H.psi.backblast(rand(5,15))
				H.Paralyse(5)
				H.make_jittery(100)
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

/obj/psi_plane/psinomaly/coercion
	aura_color = "#3333cc"

/obj/psi_plane/psinomaly/psychokinesis
	aura_color = "#cc3333"

/obj/psi_plane/psinomaly/redaction
	aura_color = "#33cc33"

/obj/psi_plane/psinomaly/energistics
	aura_color = "#cc8221"

/obj/psi_plane/psinomaly/consciousness
	aura_color = "#5233cc"

/obj/psi_plane/psinomaly/metakinesis
	aura_color = "#cccc33"

/obj/psi_plane/psinomaly/manifestation
	aura_color = "#cc8221"
