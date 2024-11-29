// explosion logic is in code/controllers/Processes/explosives.dm now

/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, z_transfer = UP|DOWN, shaped, turf_breaker, spreading = config.use_spreading_explosions)
	UNLINT(src = null)	//so we don't abort once src is deleted
	var/datum/explosiondata/data = new
	data.epicenter = epicenter
	data.devastation_range = devastation_range
	data.heavy_impact_range = heavy_impact_range
	data.light_impact_range = light_impact_range
	data.flash_range = flash_range
	data.adminlog = adminlog
	data.z_transfer = z_transfer
	data.spreading = spreading
	data.rec_pow = max(0,devastation_range) * 2 + max(0,heavy_impact_range) + max(0,light_impact_range)

	// queue work
	SSexplosives.queue(data)

	//Machines which report explosions.
	for(var/thing in doppler_arrays)
		var/obj/machinery/doppler_array/Array = thing
		Array.sense_explosion(epicenter.x,epicenter.y,epicenter.z,devastation_range,heavy_impact_range,light_impact_range)

// == Recursive Explosions stuff ==

/client/proc/kaboom()
	var/power = input(src, "power?", "power?") as num
	var/turf/T = get_turf(src.mob)
	var/datum/explosiondata/d = new
	d.spreading = TRUE
	d.epicenter = T
	d.rec_pow = power
	SSexplosives.queue(d)

/atom
	var/explosion_resistance

/turf/space
	explosion_resistance = 1

/turf/simulated/open
	explosion_resistance = 1

/turf/simulated/floor
	explosion_resistance = 1

/turf/simulated/mineral
	explosion_resistance = 2

/turf/simulated/wall
	explosion_resistance = 10

/obj/machinery/atmospherics/unary/engine/ex_act(severity)
	switch(severity)
		if(EX_ACT_DEVASTATING)
			qdel(src)
		if(EX_ACT_HEAVY)
			if(prob(25))
				qdel(src)
		if(EX_ACT_LIGHT)
			if(prob(5))
				dismantle(src)

/atom/ex_act(severity, turf_breaker)
	var/max_health = get_max_health()
	if (max_health)
		var/damage_flags = turf_breaker ? DAMAGE_FLAG_TURF_BREAKER : EMPTY_BITFIELD
		var/damage = 0
		var/basic_health = 525 // За основу возьмем здоровье укрепленной стальной стены, и весь дамаг от взрывов будем считать в соотношении от неё
		switch (severity)
			if (EX_ACT_DEVASTATING)
				damage = round(basic_health * (rand(100, 200) / 100))
			if (EX_ACT_HEAVY)
				damage = round(basic_health * (rand(55, 100) / 100))
			if (EX_ACT_LIGHT)
				damage = round(basic_health * (rand(1, 25) / 100))
		if (damage)
			damage_health(damage, DAMAGE_EXPLODE, damage_flags, severity)

/obj/machinery/ex_act(severity)
	. = ..()
	if(get_current_health(src) <= 0 && !get_current_health(src))
		switch(severity)
			if(EX_ACT_DEVASTATING)
				qdel(src)
			if(EX_ACT_HEAVY)
				if(prob(50))
					qdel(src)
			if(EX_ACT_LIGHT)
				if(prob(5))
					dismantle(src)
