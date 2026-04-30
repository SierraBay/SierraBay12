/turf/simulated/floor/holofloor/tiled/white
	name = "holo deck"
	desc = "Get it?"
	icon = 'icons/turf/flooring/tiles.dmi'
	icon_state = "white"
	initial_flooring = /singleton/flooring/tiling/white

/obj/machinery/button/medical_dummy_creator
	name = "Medical Patience Creator"
	desc = "Press to create a fully simulated human patient for medical training purposes."
	var/list/patients = list()
	var/maximum_patients = 5

/obj/machinery/button/medical_dummy_creator/activate(mob/living/user)
	. = ..()
	if (length(patients) >= maximum_patients)
		to_chat(user, SPAN_WARNING("Maximum number of simulated patients reached. Please remove an existing patient before creating a new one."))
		return

	var/mob/living/carbon/human/medical_dummy = new(loc)
	patients += medical_dummy
	GLOB.destroyed_event.register(medical_dummy, src, PROC_REF(remove_patient))
	visible_message(SPAN_NOTICE("A generic, starkly naked human materializes out of nothing!"))

/obj/machinery/button/medical_dummy_creator/proc/remove_patient(mob/living/carbon/human/target)
	patients -= target
	GLOB.destroyed_event.unregister(target, src)

/obj/machinery/button/medical_dummy_disintigrator
	name = "Medical Patience Disintegrator"
	desc = "Press to delete a non-sentient simulated human."

/obj/machinery/button/medical_dummy_disintigrator/activate(mob/living/user)
	. = ..()

	var/mob/living/carbon/human/medical_dummy = locate(/mob/living/carbon/human) in loc
	if (medical_dummy && medical_dummy.client)
		to_chat(user, SPAN_WARNING("You cannot delete a user controlled avatar!"))
		playsound(user, 'sound/machines/buzz-two.ogg', 50, 1)
		return
	visible_message(SPAN_DANGER("\The [medical_dummy] dissapears in a momentarily blip."))
	qdel(medical_dummy)

// Beach area

/turf/simulated/floor/exoplanet/titan_water/holodeck
	thermal_conductivity = 0
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_TOOLS

/turf/simulated/floor/exoplanet/titan_water/holodeck/affect_atom_crossed(atom/movable/input_movable)
	if(ishuman(input_movable))
		var/mob/living/carbon/human/detected_human = input_movable
		detected_human.handle_footsteps()
		affect_slowdown(detected_human)
		if(swim_stamina_spend)
			start_spend_stamina()

// Beach

/turf/simulated/floor/exoplanet/titan_water/holodeck/minimal
	name = "water"
	deep_status = MIN_DEEP
	icon = 'icons/misc/beach.dmi'
	mask_icon_state = "min_deep"
	icon_state = "seashallow"
	possible_icons = list("seashallow")
	footstep_type = /singleton/footsteps/min_water
	swim_delay = 1

/turf/simulated/floor/exoplanet/titan_water/holodeck/middle
	name = "water"
	deep_status = MIDDLE_DEEP
	icon = 'icons/misc/beach.dmi'
	mask_icon_state = "middle_deep"
	icon_state = "seashallow"
	possible_icons = list("seashallow")
	footstep_type = /singleton/footsteps/mid_water
	swim_delay = 2

/obj/effect/lightsourse
	name = "lightsourse"
	icon = 'icons/effects/landmarks.dmi'
	icon_state = "x2"
	anchored = TRUE
	unacidable = TRUE
	invisibility = 101

/obj/effect/lightsourse/Initialize()
	. = ..()

	name = null
	icon = null
	icon_state = null

	loc.set_light(25, 1, l_color = COLOR_WHITE) //Hidden lightsource

/obj/effect/lightsourse/Destroy()
	. = ..()

// Snow area

/turf/simulated/floor/holofloor/permafrost
	icon = 'icons/turf/snow.dmi'
	icon_state = "permafrost"

/obj/floor_decal/ice
	name = "ice"
	icon = 'mods/vr/icons/ice.dmi'
	icon_state = "ice1"

// You know where you are?

/turf/simulated/floor/holofloor/grass/jungle
	name = "jungle grass"
	icon = 'mods/vr/icons/jungle_turfs.dmi'
	icon_state = "grass1"

/turf/simulated/floor/holofloor/dirt
	name = "jungle dirt"
	icon = 'mods/vr/icons/jungle_turfs.dmi'
	icon_state = "dirt"

/obj/firepit
	name = "firepit"
	icon = 'mods/vr/icons/jungle_props.dmi'
	icon_state = "campfire"
	anchored = TRUE
	unacidable = TRUE

/obj/firepit/Initialize()
	. = ..()

	loc.set_light(5, 0.90, l_color = "#e58775")

/obj/item/device/flashlight/flare/torch
	name = "huntsman torch"
	desc = "Torch with seemingly infinite amount of fuel. Don't burns or dims. Virtual reality meets dev's lazyness"
	icon = 'mods/vr/icons/lighting.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/vr/icons/items_righthand.dmi',
		slot_l_hand_str = 'mods/vr/icons/items_lefthand.dmi'
		)
	icon_state = "torch"
	item_state = "torch"
	flashlight_power = 3
	flashlight_range = 3
