/turf/simulated/floor/exoplanet/titan_water/proc/signals_setup(atom/movable/input_movable)
	RegisterSignal(input_movable, COMSIG_MOB_LAYING_CHANGED, PROC_REF(update_laying_overlays))

/turf/simulated/floor/exoplanet/titan_water/proc/signals_desetup(atom/movable/input_movable)
	UnregisterSignal(input_movable, COMSIG_MOB_LAYING_CHANGED)


/turf/simulated/floor/exoplanet/titan_water/proc/update_laying_overlays(atom/movable/input_movable)
	if(ishuman(input_movable))
		var/mob/living/carbon/human/human = input_movable
		if(human.lying)
			human.desetup_water_overlay()
			drown_human(human)
			return
	add_water_mask_to_living(input_movable, mask_icon_state, called_by_lying = TRUE)
