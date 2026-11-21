/singleton/psi_disorder/white_noise
	id =          "white_noise"
	name =        "Белый шум"
	group =       "green"
	description = "Пациент слышит белый шум разной громкости. Похоже на звон в ушах, но чаще вызывает бессонницу."
	delay_min =   30 SECONDS
	delay_max =   60 SECONDS

/singleton/psi_disorder/white_noise/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	var/mob/living/carbon/human/H
	if(!H)
		return
	if(prob(40))
		to_chat(H, ". . .")
