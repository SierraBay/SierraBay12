/obj/landmark/light/snow_cage
	light_range = 20
	light_power = 0.5
	light_color = "#618ac0"

/obj/landmark/light/snow_cage/Initialize()
	. = ..()
	set_light(light_range, light_power, light_color)
