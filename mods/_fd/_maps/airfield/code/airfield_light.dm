/obj/landmark/light/airfield
	light_range = 20
	light_power = 0.7
	light_color = "#c3f1fa"

/obj/landmark/light/airfield/Initialize()
	. = ..()
	set_light(light_range, light_power, light_color)
