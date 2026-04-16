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