/turf/simulated/floor/exoplanet/titan_water/proc/signals_setup(atom/movable/input_movable)
	RegisterSignal(input_movable, COMSIG_MOB_LAYING_CHANGED, PROC_REF(update_water_filter))
	RegisterSignal(input_movable, COMSIG_MOB_EQUIPED_SMTHG, PROC_REF(update_water_filter))

/turf/simulated/floor/exoplanet/titan_water/proc/signals_desetup(atom/movable/input_movable)
	UnregisterSignal(input_movable, COMSIG_MOB_LAYING_CHANGED)
	UnregisterSignal(input_movable, COMSIG_MOB_EQUIPED_SMTHG)

/turf/simulated/floor/exoplanet/titan_water/proc/update_water_filter(atom/movable/input_movable)
	input_movable.update_water_filter(mask_icon_state)

/obj/item/proc/setup_water_signals()
	RegisterSignal(src, COMSIG_ITEM_PICKUPED, PROC_REF(call_update_water_filter))

//Что-то PROC_REF сам по себе не видит update_water_filter
// TODO: Разобраться в причине и избавиться от этого костыля
/obj/item/proc/call_update_water_filter()
	update_water_filter()
