/datum/map/torch/New()
	. = ..()
	species_to_job_blacklist -= /datum/species/machine
	species_to_rank_whitelist[/datum/species/machine][/datum/mil_branch/fleet] += list(/datum/mil_rank/fleet/e8, /datum/mil_rank/fleet/e9_alt1, /datum/mil_rank/fleet/e9, /datum/mil_rank/fleet/o1)
