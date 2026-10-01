// Ranks/branches needed by playable away ships when Sierra is not compiled in.

/datum/job/submap
	available_by_default = TRUE
	branch = /datum/mil_branch/civilian
	rank = /datum/mil_rank/civ/civ
	allowed_branches = list(/datum/mil_branch/civilian)
	allowed_ranks = list(/datum/mil_rank/civ/civ)

/datum/map/lobby_host
	branch_types = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/contractor,
		/datum/mil_branch/employee,
		/datum/mil_branch/alien,
		/datum/mil_branch/iccgn,
		/datum/mil_branch/css,
		/datum/mil_branch/fleet,
		/datum/mil_branch/scga
	)
	spawn_branch_types = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/contractor,
		/datum/mil_branch/employee,
		/datum/mil_branch/alien,
		/datum/mil_branch/iccgn,
		/datum/mil_branch/css,
		/datum/mil_branch/fleet,
		/datum/mil_branch/scga
	)

/datum/mil_branch/civilian
	name = "Civilian"
	name_short = "civ"
	email_domain = "freemail.net"
	allow_custom_email = TRUE
	rank_types = list(
		/datum/mil_rank/civ/civ,
		/datum/mil_rank/civ/offduty,
		/datum/mil_rank/civ/synthetic
	)
	spawn_rank_types = list(
		/datum/mil_rank/civ/civ,
		/datum/mil_rank/civ/offduty,
		/datum/mil_rank/civ/synthetic
	)
	assistant_job = "Passenger"

/datum/mil_branch/contractor
	name = "Contractor"
	name_short = "contr"
	email_domain = "freemail.net"
	allow_custom_email = TRUE
	rank_types = list(
		/datum/mil_rank/civ/contractor,
		/datum/mil_rank/civ/probation_contractor,
		/datum/mil_rank/civ/offduty,
		/datum/mil_rank/civ/synthetic
	)
	spawn_rank_types = list(
		/datum/mil_rank/civ/contractor,
		/datum/mil_rank/civ/probation_contractor,
		/datum/mil_rank/civ/offduty,
		/datum/mil_rank/civ/synthetic
	)

/datum/mil_branch/employee
	name = "Employee"
	name_short = "empl"
	email_domain = "mail.nanotrasen.net"
	rank_types = list(
		/datum/mil_rank/civ/nt,
		/datum/mil_rank/civ/acting,
		/datum/mil_rank/civ/acting_temp,
		/datum/mil_rank/civ/probation_employee,
		/datum/mil_rank/civ/offduty,
		/datum/mil_rank/civ/synthetic
	)
	spawn_rank_types = list(
		/datum/mil_rank/civ/nt,
		/datum/mil_rank/civ/acting,
		/datum/mil_rank/civ/probation_employee,
		/datum/mil_rank/civ/offduty,
		/datum/mil_rank/civ/synthetic
	)

/datum/mil_rank/civ/civ
	name = "Civilian"

/datum/mil_rank/civ/nt
	name = "NT Employee"

/datum/mil_rank/civ/acting
	name = "NT Acting Official"
	name_short = "Acting"
	name_short_job_prefix = TRUE

/datum/mil_rank/civ/acting_temp
	name = "NT Temporary Assignment"
	name_short = "TA"
	name_short_job_prefix = TRUE

/datum/mil_rank/civ/probation_employee
	name = "NT Employee on Probationary Period"
	name_short = "P.P."
	name_short_job_prefix = TRUE

/datum/mil_rank/civ/probation_contractor
	name = "NT Contractor on Probationary Period"
	name_short = "P.P."
	name_short_job_prefix = TRUE

/datum/mil_rank/civ/contractor
	name = "NT Contractor"

/datum/mil_rank/civ/offduty
	name = "Off-Duty Personnel"

/datum/mil_rank/civ/synthetic
	name = "Synthetic"

/datum/mil_branch/alien
	name = "Alien"
	name_short = "Alien"
	rank_types = list(/datum/mil_rank/alien)
	spawn_rank_types = list(/datum/mil_rank/alien)

/datum/mil_rank/alien
	name = "Alien"
