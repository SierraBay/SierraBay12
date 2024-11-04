/singleton/hierarchy/skill/general/EVA/mech
	ID = "exosuit"
	name = "Exosuit Operation"
	desc = "Allows you to operate exosuits well."
	levels = list("Untrained" = "You are unfamiliar with exosuit controls, and if you attempt to use them you are liable to make mistakes.",
		"Trained" = "You are proficient in exosuit operation and safety, and can use them without penalties.")
	default_max = SKILL_BASIC
	difficulty = SKILL_AVERAGE

/singleton/hierarchy/skill/general/EVA/mech/Initialize()
	. = ..()
	prerequisites = null

/singleton/hierarchy/skill/general/EVA/mech/get_cost(level)
	switch(level)
		if(SKILL_BASIC)
			return 3*difficulty
		else
			return 0
