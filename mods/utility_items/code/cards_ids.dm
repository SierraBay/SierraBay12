/obj/item/card/id/get_display_name()
	. = registered_name
	if(military_rank && military_rank.name_short && !military_rank.name_short_job_prefix)
		. ="[military_rank.name_short] [.][formal_name_suffix]"
	else if(formal_name_prefix || formal_name_suffix)
		. = "[formal_name_prefix][.][formal_name_suffix]"
	if(assignment)
		if(military_rank.name_short_job_prefix)
			. += ", [military_rank.name_short] [assignment]"
		else
			. += ", [assignment]"

/datum/mil_rank
	var/name_short_job_prefix = FALSE // If TRUE - rank Abbreviation displayed like job prefix, not name prefix
