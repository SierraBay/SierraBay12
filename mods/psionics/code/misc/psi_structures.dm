/obj/structure/psinomaly
	name = "Псионическое возмущение"
	desc = "Прореха в самой ткани реальности. Он пульсирует от неописуемых энергий, клубящихся вокруг него."
	icon = 'mods/psionics/icons/effects/psi_effects.dmi'
	icon_state = "reality_smash"
	layer = ABOVE_HUMAN_LAYER
	density = TRUE
	anchored = TRUE
	var/charged = TRUE

	var/list/psi_mobs = list(
			/mob/living/simple_animal/hostile/giant_spider/psi,
			/mob/living/simple_animal/hostile/vagrant/psi
		)

	invisibility = INVISIBILITY_PSI_PLANE


/obj/structure/psinomaly/Initialize()
	. = ..()

	var/turf/T = get_turf(src)

	var/drone_count = rand(1, 3)
	for(var/i = 1 to drone_count)
		new /mob/living/simple_animal/hostile/retaliate/malf_drone(T)

	update_icon()

/obj/structure/psinomaly/on_update_icon()
	ClearOverlays()
	if(charged)
		var/image/I = image(icon, "plane_glow")
		I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
		I.color = get_random_colour(0, 150, 255)
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		AddOverlays(I)
		set_light(2, 0.3, l_color = I.color)

/obj/structure/psinomaly/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()

/obj/structure/psinomaly/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	if(GLOB.using_map.use_overmap && istype(user,/mob/living/carbon/human))
		var/obj/overmap/visitable/sector/exoplanet/E = map_sectors["[z]"]
		if(istype(E))
			var/mob/living/carbon/human/H = user
			if(!H.isSynthetic())
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				if(prob(70))
					to_chat(H, SPAN_NOTICE("As you touch \the [src], you suddenly get a vivid image - [E.get_engravings()]"))
				else
					to_chat(H, SPAN_WARNING("An overwhelming stream of information invades your mind!"))
					var/vision = ""
					for(var/i = 1 to 10)
						vision += pick(E.actors) + " " + pick("killing","dying","gored","expiring","exploding","mauled","burning","flayed","in agony") + ". "
					to_chat(H, SPAN_DANGER(FONT_NORMAL(uppertext(vision))))
					H.Paralyse(2)
					H.hallucination(20, 100)
				return
	to_chat(user, SPAN_NOTICE("\The [src] is still."))
	return ..()
