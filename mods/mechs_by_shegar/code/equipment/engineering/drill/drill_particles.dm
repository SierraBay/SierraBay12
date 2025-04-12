/obj/item/mech_equipment/drill/proc/generate_drill_particles(atom/input_atom, delay)
	if(istype(input_atom, /turf/simulated/mineral))
		return new/obj/particle_emitter/sparks/debris(get_turf(input_atom), delay, input_atom.color)
	else
		return new/obj/particle_emitter/sparks(get_turf(input_atom), delay)
