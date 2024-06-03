/obj/machinery/computer/ship/helm/controller
	icon = 'mods/_fd/fd_assets/icons/machinery/telescreen_consoles.dmi'
	icon_state = "tiny_helm"
	density = FALSE
	machine_name = "helm control pad"
	machine_desc = "A compact, controller-like helm panel."

/obj/machinery/computer/ship/helm/controller/on_update_icon()
	if(reason_broken & MACHINE_BROKEN_NO_PARTS || !is_powered() || MACHINE_IS_BROKEN(src))
		icon_state = "tiny"
		set_light(0)
	else
		icon_state = "tiny_helm"
		set_light(light_range_on, light_power_on, light_color)

/obj/item/stock_parts/circuitboard/helm/controller
	name = "circuit board (helm control pad)"
	build_path = /obj/machinery/computer/ship/helm/controller

/obj/machinery/computer/ship/sensors/telescreen
	icon = 'mods/_fd/fd_assets/icons/machinery/telescreen_consoles.dmi'
	icon_state = "tele_sensors"
	density = FALSE
	machine_name = "sensors telescreen"
	machine_desc = "A compact, slimmed-down version of the sensors console."

/obj/machinery/computer/ship/sensors/telescreen/on_update_icon()
	if(reason_broken & MACHINE_BROKEN_NO_PARTS || !is_powered() || MACHINE_IS_BROKEN(src))
		icon_state = "tele_off"
		set_light(0)
	else
		icon_state = "tele_nav"
		set_light(light_range_on, light_power_on, light_color)

/obj/item/stock_parts/circuitboard/sensors/tele
	name = "circuit board (sensors telescreen)"
	build_path = /obj/machinery/computer/ship/sensors/telescreen
