/obj/machinery/light/blue
	color = "#4f7fad"
	light_type = /obj/item/light/tube/blue

/obj/machinery/light/golden
	color = "#f1d57f"
	light_type = /obj/item/light/tube/golden

/// LIGHT TUBES ///

/obj/item/light/tube/blue
	name = "light tube (blue)"
	color = COLOR_BLUE_GRAY
	b_colour = COLOR_BLUE_GRAY
	random_tone = FALSE

/obj/item/light/tube/golden
	name = "light tube (golden)"
	color = COLOR_YELLOW_GRAY
	b_colour = COLOR_YELLOW_GRAY
	random_tone = FALSE

/// INVISIBLE LIGHTS ///

/obj/machinery/light/invisible
	invisibility = 101

/obj/machinery/light/blue/invisible
	invisibility = 101

/obj/machinery/light/golden/invisible
	invisibility = 101

/// NAV LIGHTS ///

/obj/machinery/light/navigation
	name = "navigation light"
	desc = "A periodically flashing light."
	icon = 'mods/_fd/fd_assets/icons/machinery/lighting_nav.dmi'
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
