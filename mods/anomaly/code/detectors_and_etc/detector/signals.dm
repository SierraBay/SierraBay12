/obj/item/clothing/gloves/anomaly_detector/pickuped(user)
	. = ..()
	setup_signals(user)

/obj/item/clothing/gloves/anomaly_detector/dropped()
	. = ..()
	desetup_signals(usr)

/obj/item/clothing/gloves/anomaly_detector/proc/setup_signals(mob/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_electrostatic))

/obj/item/clothing/gloves/anomaly_detector/proc/desetup_signals(mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
