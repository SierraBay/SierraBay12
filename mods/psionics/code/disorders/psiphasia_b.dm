/singleton/psi_disorder/psiphasia_b
	id =          "psiphasia_b"
	name =        "Псифазия группы Б"
	group =       "red"
	description = "Ты теряешь способность адекватно воспринимать реальность. Силы проявляются спонтанно и неуправляемо."
	delay_min =   45 SECONDS
	delay_max =   120 SECONDS

/singleton/psi_disorder/psiphasia_b/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	psi.trigger_instability(rand(1, 2))
