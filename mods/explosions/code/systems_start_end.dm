
// Called when SSexplosives begins processing explosions.
/datum/controller/proc/ExplosionStart()

// Called when SSexplosives finishes processing all queued explosions.
/datum/controller/proc/ExplosionEnd()


/datum/controller/subsystem/alarm/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/alarm/ExplosionEnd()
	can_fire = TRUE

/datum/controller/subsystem/machines/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/machines/ExplosionEnd()
	can_fire = TRUE

/datum/controller/subsystem/processing/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/processing/ExplosionEnd()
	can_fire = TRUE

/datum/controller/subsystem/air/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/air/ExplosionEnd()
	can_fire = TRUE

/datum/controller/subsystem/airflow/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/airflow/ExplosionEnd()
	can_fire = TRUE

/datum/controller/subsystem/ao/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/ao/ExplosionEnd()
	can_fire = TRUE

/datum/controller/subsystem/lighting/ExplosionStart()
	force_queued = TRUE
	can_fire = FALSE

/datum/controller/subsystem/lighting/ExplosionEnd()
	can_fire = TRUE
	if (!force_override)
		force_queued = FALSE

/datum/controller/subsystem/fluids/ExplosionStart()
	can_fire = FALSE

/datum/controller/subsystem/fluids/ExplosionEnd()
	can_fire = TRUE

/datum/station_holomap/Destroy()
	QDEL_NULL(station_map)
	QDEL_NULL(cursor)
	LAZYCLEARLIST(legend)
	LAZYCLEARLIST(levels)
	LAZYCLEARLIST(lbuttons)
	LAZYCLEARLIST(maptexts)
	LAZYCLEARLIST(z_levels)
	return ..()
