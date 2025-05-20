#define COMSIG_CLOTHING_VISOR_TOGGLE "clothing_visor_toggle"
#define COMSIG_ITEM_EQUIPPED "item_equipped"
#define COMSIG_ITEM_DROPPED "item_dropped"

/datum/component/helmets

/datum/component/helmets/Initialize()
	. = ..()

/datum/component/helmets/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/component/helmets/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_CLOTHING_VISOR_TOGGLE))
	return ..()

/datum/component/helmets/proc/on_drop(obj/item/clothing/head/helmet/source, mob/living/holder)
	SIGNAL_HANDLER
	holder.toggle_fov(usefov = FALSE, fovangle = 0)

/datum/component/helmets/proc/on_equip(obj/item/clothing/head/helmet/source, mob/living/holder)
	SIGNAL_HANDLER
	holder.toggle_fov(usefov = TRUE, fovangle = source.fov_angle)
