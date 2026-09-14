/obj/effect/nabber_wings
	name = ""
	icon = 'mods/giant_armored_centipede/icons/GAS_wings.dmi'
	icon_state = "flying"
	pixel_x = -17
	pixel_y = -2
	layer = ABOVE_HUMAN_LAYER
	mouse_opacity = 0
	anchored = TRUE
	simulated = FALSE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_ID

/mob/living/carbon/human
	var/nabber_wing_display_until = 0
	var/obj/effect/nabber_wings/nabber_wings_overlay

/mob/living/carbon/human/proc/should_show_nabber_wings()
	if(!species || species.get_bodytype(src) != SPECIES_NABBER)
		return FALSE
	if(stat || lying || resting || buckled || is_cloaked())
		return FALSE
	if(nabber_wing_display_until > world.time)
		return TRUE
	if(!isturf(loc))
		return FALSE
	var/turf/T = loc
	if(isopenspace(T) || istype(T, /turf/space))
		return TRUE
	if(T.CanZPass(src, DOWN))
		var/turf/below = GetBelow(src)
		if(!below || below.CanZPass(src, DOWN))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/flash_nabber_wings(duration = 2 SECONDS)
	if(!species || species.get_bodytype(src) != SPECIES_NABBER)
		return
	nabber_wing_display_until = max(nabber_wing_display_until, world.time + duration)
	update_nabber_wings()
	addtimer(new Callback(src, PROC_REF(update_nabber_wings)), duration + 1, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/carbon/human/proc/update_nabber_wings()
	if(should_show_nabber_wings())
		if(!nabber_wings_overlay)
			nabber_wings_overlay = new(src)
		if(!(nabber_wings_overlay in vis_contents))
			vis_contents += nabber_wings_overlay
		return
	if(!nabber_wings_overlay)
		return
	vis_contents -= nabber_wings_overlay

/mob/living/carbon/human/Move(NewLoc, Dir)
	var/old_z = loc ? loc.z : null
	. = ..()
	if(.)
		species.handle_exertion(src)
		handle_leg_damage()
		if(species && species.get_bodytype(src) == SPECIES_NABBER)
			if((Dir & (UP|DOWN)) || (old_z && loc && loc.z != old_z))
				flash_nabber_wings()
			else
				update_nabber_wings()

/singleton/species/nabber/default_emotes = list(
	/singleton/emote/audible/bug_hiss,
	/singleton/emote/audible/bug_buzz,
	/singleton/emote/audible/bug_chitter,
	/singleton/emote/visible/flap,
	/singleton/emote/visible/aflap
)

/singleton/species/nabber/handle_environment_special(mob/living/carbon/human/H)
	if(!H.on_fire && H.fire_stacks < 2)
		H.fire_stacks += 0.2
	H.update_nabber_wings()

/singleton/species/nabber/handle_fall_special(mob/living/carbon/human/H, turf/landing)
	var/datum/gas_mixture/mixture = H.loc.return_air()
	var/turf/T = GetBelow(H.loc)

	for(var/obj/O in T)
		if(istype(O, /obj/structure/stairs))
			return FALSE

	if(mixture)
		var/pressure = mixture.return_pressure()
		if(pressure > 50)
			if(istype(landing, /turf/simulated/open))
				H.visible_message("\The [H] descends from the deck above through \the [landing]!", "Your wings slow your descent.")
			else
				H.visible_message("\The [H] buzzes down from \the [landing], wings slowing their descent!", "You land on \the [landing], folding your wings.")
			H.flash_nabber_wings()
			return TRUE

	return FALSE

/singleton/species/nabber/handle_post_spawn(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/nabber/verb/bug_flap
	return H.pulling_punches = TRUE
