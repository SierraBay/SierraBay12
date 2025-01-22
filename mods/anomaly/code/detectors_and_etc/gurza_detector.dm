//Самопальный ослабленный детектор, разработанный силами инженера ГКК.
/obj/item/clothing/gloves/anomaly_detector/gurza
	name = "Gurza"
	desc = "An incredibly homemade detector clearly designed by a talented engineer. It is capable of detecting static voltage and determining its direction and distance. Despite its homemade nature, it looks extremely reliable. Apparently, the assembly involved blue duct tape."
	icon = 'mods/anomaly/icons/gurza_detector.dmi'
	on_turf_icon = null //Нарисуйте плез спрайты на полу ему
	icon_state = "gurza_turned_off"
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
