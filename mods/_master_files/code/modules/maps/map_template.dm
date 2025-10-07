//Fix for atmospherics of lateloaded away sites, keeps suspend for the entire process
/datum/map_template
	var/air_suspended = FALSE
	var/airflow_suspended = FALSE

/datum/map_template/init_atoms(list/atoms)
	if(GAME_STATE >= RUNLEVEL_GAME)
		if(!SSair.suspended)
			SSair.suspend()
			air_suspended = TRUE

		if(!SSairflow.suspended)
			SSairflow.suspend()
			airflow_suspended = TRUE
	..()

/datum/map_template/init_atoms(list/atoms)
	..()
	if(air_suspended)
		SSair.wake()
		air_suspended = FALSE

	if(airflow_suspended)
		SSairflow.wake()
		airflow_suspended = FALSE


/area/shuttle/escape_pod
	name = "Escape Pod"
