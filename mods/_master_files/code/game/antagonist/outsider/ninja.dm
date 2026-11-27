/datum/antagonist/ninja/create_objectives(datum/mind/ninja)
	if (!..())
		return
	var/datum/objective/survive/ninja_objective = new
	ninja_objective.owner = ninja
	ninja.objectives += ninja_objective
