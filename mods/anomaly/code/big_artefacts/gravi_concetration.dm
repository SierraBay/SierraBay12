/obj/structure/big_artefact/gravi
	icon_state = "gravi_anomalies"
	min_anomalies_ammout = 60
	max_anomalies_ammout = 120
	range_spawn = 30
	possible_anomalies = list(
		/obj/anomaly/thamplin/random = 2,
		/obj/anomaly/rvach/three_and_three = 1
		)
	var/last_gravi_attack
	var/gravi_attack_cooldown

/obj/structure/big_artefact/gravi/Initialize()
	.=..()
	if(!is_processing)
		START_PROCESSING(SSanom, src)
	gravi_attack_cooldown = rand(20 SECONDS, 50 SECONDS)
	last_gravi_attack = world.time

/obj/structure/big_artefact/gravi/Process()
	if(world.time -last_gravi_attack > gravi_attack_cooldown)
		gravi_attack()

/obj/structure/big_artefact/gravi/proc/gravi_attack()
	set waitfor = FALSE
	last_gravi_attack = world.time
	for(var/turf/picked_turf in RANGE_TURFS(src, 5))
		for(var/mob/living/picked_living in picked_turf)
			picked_living.Weaken(3)
			picked_living.stun_effect_act(3,1)
			to_chat(picked_living, SPAN_WARNING("Что-то с силой прижимает вас к земле."))
			shake_camera(picked_living, 3, 1)
