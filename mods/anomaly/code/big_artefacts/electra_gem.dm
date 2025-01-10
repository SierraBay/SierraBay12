/obj/structure/big_artefact/electra
	icon_state = "electra_anomalies"
	min_anomalies_ammout = 70
	max_anomalies_ammout = 150
	range_spawn = 30
	possible_anomalies = list(
		/obj/anomaly/electra/three_and_three = 1,
		/obj/anomaly/electra/three_and_three/tesla = 2,
		/obj/anomaly/electra/three_and_three/tesla_second = 3,
		/obj/anomaly/cooler/two_and_two = 1,
		/obj/anomaly/cooler/three_and_three = 1
		)
	//
	var/datum/beam = null
	var/last_electra_attack
	var/electra_attack_cooldown

/obj/structure/big_artefact/electra/Initialize()
	.=..()
	if(!is_processing)
		START_PROCESSING(SSanom, src)
	electra_attack_cooldown = rand(20 SECONDS, 50 SECONDS)
	last_electra_attack = world.time

//Пусть кусается молниями в пределах 3 турфов.
/obj/structure/big_artefact/electra/Process()
	if(world.time - last_electra_attack > electra_attack_cooldown)
		electra_attack()

/obj/structure/big_artefact/electra/proc/electra_attack()
	set waitfor = FALSE
	last_electra_attack = world.time
	var/turf/picked_turf
	picked_turf = pick(RANGE_TURFS(src, 3))
	for(var/mob/living/picked_living in picked_turf)
		picked_living.electoanomaly_act(50, src)
	for(var/obj/structure/aurora/picked_aurora in picked_turf)
		picked_aurora.wake_up(5 SECONDS)
	beam = src.Beam(BeamTarget = picked_turf, icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)
	playsound(src, 'mods/anomaly/sounds/electra_blast.ogg', 100, FALSE  )
