/obj/item/rig_module/device/anomaly_detector
	name = "Anomaly detector module"
	desc = "Anomaly detection device."
	icon_state = "eldersasparilla"
	interface_name = "Anomaly detection module"
	interface_desc = "Anomaly detector developed by R&D, installed in this module."
	engage_string = "Begin Scan"

	activate_string = "Turn on detector"
	deactivate_string = "Turn off detector"

	use_power_cost = 200
	usable = TRUE
	selectable = TRUE
	device = /obj/item/clothing/gloves/anomaly_detector

/obj/item/rig/exploration/equipped
	initial_modules = list(
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/flash,
		/obj/item/rig_module/device/anomaly_scanner,
		/obj/item/rig_module/grenade_launcher/light,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/device/anomaly_detector)

/obj/item/rig_module/device/anomaly_detector/select()
	if(!device.is_processing)
		START_PROCESSING(SSanom, device)
	..()

/obj/item/rig_module/device/anomaly_detector/activate()
	device.CtrlClick(usr)

/obj/item/rig_module/device/anomaly_detector/deactivate()
	device.CtrlClick(usr)

/obj/item/rig_module/device/anomaly_detector/engage(atom/target)
	. = ..()
	device.attack_self(usr)
