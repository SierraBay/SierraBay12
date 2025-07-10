/datum/component/helmets

/datum/component/helmets/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/component/helmets/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	return ..()

/datum/component/helmets/proc/on_drop(obj/item/clothing/head/helmet/source, mob/living/holder)
	SIGNAL_HANDLER
	holder.toggle_fov(usefov = FALSE, fovangle = 0)

/datum/component/helmets/proc/on_equip(obj/item/clothing/head/helmet/source, mob/living/holder)
	SIGNAL_HANDLER
	holder.toggle_fov(usefov = TRUE, fovangle = source.fov_angle)

/datum/component/mech_sensor

/datum/component/mech_sensor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CABINE_OPEN, .proc/open_cabine)
	RegisterSignal(parent, COMSIG_CABINE_CLOSED, .proc/closed_cabine)

/datum/component/mech_sensor/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CABINE_OPEN, COMSIG_CABINE_CLOSED))
	return ..()

/datum/component/mech_sensor/proc/open_cabine(obj/item/mech_component/sensors/source, mob/living/holder)
	SIGNAL_HANDLER
	holder.toggle_fov(usefov = FALSE, fovangle = 0)

/datum/component/mech_sensor/proc/closed_cabine(obj/item/mech_component/sensors/source, mob/living/holder)
	SIGNAL_HANDLER
	if(istype(source, /obj/item/mech_component/sensors))
		var/fov_angle = source.fov_angle
		holder.toggle_fov(usefov = TRUE, fovangle = fov_angle)
