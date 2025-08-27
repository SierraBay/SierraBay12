//Функция создаст удар молнии в определённом месте
/proc/create_thunderbolt_attack_here(turf/input_turf, delayed)
	if(!input_turf)
		return
	if(delayed)
		var/obj/spawnerd_electra_particles = new /obj/electrostatic (input_turf)
		addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(calculate_thunderbolt_attack_here), input_turf, spawnerd_electra_particles), rand(10, 20))
	else
		calculate_thunderbolt_attack_here(input_turf)

/proc/calculate_thunderbolt_attack_here(turf/input_turf, spawnerd_electra_particles)
	if(spawnerd_electra_particles)
		qdel(spawnerd_electra_particles)
	for(var/atom/movable/picked_atom in input_turf)
		electroanomaly_act(picked_atom)
