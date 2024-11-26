//Самопальный ослабленный детектор, разработанный силами инженера ГКК.
/obj/item/clothing/gloves/anomaly_detector/gurza
	name = "Gurza"
	desc = "An incredibly homemade detector clearly designed by a talented engineer. It is capable of detecting static voltage and determining its direction and distance. Despite its homemade nature, it looks extremely reliable. Apparently, the assembly involved blue duct tape."
	icon = 'mods/anomaly/icons/gurza_detector.dmi'
	icon_state = "gurza_undeployed"
	detector_basic_name = "gurza"
	action_button_name = "Scan anomalies"
	//Устройство не лезет на кисть.
	slot_flags = SLOT_DENYPOCKET
	//Гюрза способен находить исключительно электроаномалии
	blacklisted_amomalies = list(
		"Cooler",
		"Heater",
		"Rvach",
		"Tramp",
		"Vent",
		"Vspishka",
		"Zharka"
	)

/obj/item/clothing/gloves/anomaly_detector/gurza/switch_toggle()
	if(!is_processing)
		to_chat(usr, SPAN_NOTICE("Вы включили детектор."))
		flick("gurza_undeploing", src)
		icon_state = "gurza_scanning"
		usr.update_action_buttons()
		START_PROCESSING(SSanom, src)
		SSanom.processing_ammount++
	else
		flick("gurza_deploing", src)
		to_chat(usr, SPAN_NOTICE("Вы выключили детектор."))
		STOP_PROCESSING(SSanom, src)
		icon_state = "gurza_undeployed"
		usr.update_action_buttons()
		SSanom.processing_ammount--
