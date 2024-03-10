/obj/machinery/light/navigation
	name = "navigation light"
	desc = "A periodically flashing light."
	icon = 'mods/fd_assets/icons/machinery/lighting_nav.dmi'
	icon_state = "nav10"
	base_state = "nav1"
	light_type = /obj/item/light/tube/large
	on = TRUE

/obj/machinery/light/navigation/delay2
		icon_state = "nav20"
		base_state = "nav2"

/obj/machinery/light/navigation/delay3
		icon_state = "nav30"
		base_state = "nav3"

/obj/machinery/light/navigation/delay4
		icon_state = "nav40"
		base_state = "nav4"

/obj/machinery/light/navigation/delay5
		icon_state = "nav50"
		base_state = "nav5"

/obj/machinery/light/navigation/powered()
	return TRUE
