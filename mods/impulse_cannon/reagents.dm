//Убираем спам логами
/datum/reagent/napalm/touch_turf(turf/T, nologs = FALSE)
	new /obj/decal/cleanable/liquid_fuel(T, volume, nologs)
	remove_self(volume)
