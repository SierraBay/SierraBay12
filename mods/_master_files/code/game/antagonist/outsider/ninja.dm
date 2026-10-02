//Full override, not a ..() extension - the original random Kill/Steal/Protect/Download/Harm objective roll
//has been intentionally removed, so we deliberately don't run ninja's own original create_objectives()
//(that logic lives in core and would re-add it). ..() here reaches the base /datum/antagonist guard check
//(respects config.objectives_disabled), same as the original did.
/datum/antagonist/ninja/create_objectives(datum/mind/ninja)
	if (!..())
		return
	var/datum/objective/survive/ninja_objective = new
	ninja_objective.owner = ninja
	ninja.objectives += ninja_objective
