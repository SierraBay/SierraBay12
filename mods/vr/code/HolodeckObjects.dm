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

/turf/simulated/floor/exoplanet/titan_water/minimal/holodeck
	name = "water"
	deep_status = MIN_DEEP
	icon = 'icons/misc/beach.dmi'
	mask_icon_state = "min_deep"
	icon_state = "seashallow"
	possible_icons = list("seashallow")
	footstep_type = /singleton/footsteps/min_water
	swim_delay = 1
	thermal_conductivity = 0
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_TOOLS

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

	loc.set_light(25, 1, l_color = COLOR_WHITE) //The goo doesn't last, so this is another indicator

/obj/effect/lightsourse/Destroy()
	. = ..()

// Netspace turfs

/turf/simulated/floor/holofloor/netspace
	name = "netspace floor"
	icon = 'mods/vr/icons/netspace_turfs.dmi'
	icon_state = "netfloor"
	initial_flooring = null

/turf/unsimulated/wall/netspace
	name = "netspace wall"
	icon = 'mods/vr/icons/netspace_turfs.dmi'
	icon_state = "netwall"


// Netspace objects


// Doors core
/obj/machinery/door/netspace
	name = "netspace blockade"
	icon = 'mods/vr/icons/netspace_obj.dmi'
	icon_state = "barrier"
	var/icon_base = "barrier"

	/// Boolean. Whether or not the door is locked/bolted.
	var/locked = FALSE

	uncreated_component_parts = list(
		/obj/item/stock_parts/radio/receiver,
		/obj/item/stock_parts/power/apc
	)
	// To be fleshed out and moved to parent door, but staying minimal for now.
	public_methods = list(
		/singleton/public_access/public_method/toggle_door,
		/singleton/public_access/public_method/netspace_toggle_bolts
	)
	stock_part_presets = list(/singleton/stock_part_preset/radio/receiver/netspace = 1)

/obj/machinery/door/netspace/proc/lock(forced=0)
	if(locked)
		return 0

	locked = TRUE
	update_icon()
	return 1

/obj/machinery/door/netspace/proc/unlock(forced=0)
	if(!src.locked)
		return

	locked = FALSE
	update_icon()
	return 1

/obj/machinery/door/netspace/proc/toggle_lock(forced = 0)
	return locked ? unlock() : lock()

/singleton/public_access/public_method/netspace_toggle_bolts
	name = "toggle bolts"
	desc = "Toggles whether the netspace door is bolted or not, if possible."
	call_proc = TYPE_PROC_REF(/obj/machinery/door/netspace, toggle_lock)

/singleton/stock_part_preset/radio/receiver/netspace
	frequency = AIRLOCK_FREQ
	receive_and_call = list(
		"toggle_door" = /singleton/public_access/public_method/toggle_door,
		"toggle_bolts" = /singleton/public_access/public_method/netspace_toggle_bolts
	)

/obj/machinery/door/netspace/on_update_icon()
	update_dir()
	if(density && !locked)
		icon_state = "[icon_base]"
	if(density && locked)
		icon_state = "[icon_base]_locked"
	else
		icon_state = "[icon_base]_open"
	return


// Doors variants

/obj/machinery/door/netspace/dojo
	icon_state = "door_dojo"
	icon_base = "door_dojo"

/obj/machinery/door/netspace/firewall
	icon_state = "firewall"
	icon_base = "firewall"

// Level
/obj/machinery/button/alternate/door/bolts/netspace
	name = "access switch"
	icon = 'mods/vr/icons/netspace_obj.dmi'
	icon_state = "level"
	stock_part_presets = list(/singleton/stock_part_preset/radio/basic_transmitter/button/netspace_bolt)

/obj/machinery/button/alternate/door/on_update_icon()
	if(operating)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]"

/singleton/stock_part_preset/radio/basic_transmitter/button/netspace_bolt
	frequency = AIRLOCK_FREQ
	transmit_on_change = list("toggle_bolts" = /singleton/public_access/public_variable/button_active)
