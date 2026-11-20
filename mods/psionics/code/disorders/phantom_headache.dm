/singleton/psi_disorder/phantom_headache
	id =          "phantom_headache"
	name =        "Фантомная головная боль"
	group =       "green"
	description = "Внезапные эпизоды головной боли от слабой до мигрени. Длятся от нескольких секунд до часа."
	delay_min =   10 SECONDS
	delay_max =   30 SECONDS

/singleton/psi_disorder/phantom_headache/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	var/mob/living/carbon/human/H
	if(!H)
		return
	if(world.time < state["episode_until"])
		H.custom_pain("Голова раскалывается!", rand(10, 40), affecting = H.get_organ(BP_HEAD))
		return
	var/duration = prob(5) ? rand(30 MINUTES, 60 MINUTES) : rand(3 SECONDS, 3 MINUTES)
	state["episode_until"] = world.time + duration
