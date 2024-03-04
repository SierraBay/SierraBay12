/obj/reactor_radiate
	name = "Reactor Radiation Spawner"
	icon = 'icons/effects/landmarks.dmi'
	icon_state = "x2"
	var/radiation_power = 70
	var/datum/radiation_source/S
	var/req_range = 2

/obj/reactor_radiate/Initialize()
	. = ..()

	name = null
	icon = null
	icon_state = null

	S = new()
	S.flat = TRUE
	S.range = req_range
	S.respect_maint = FALSE
	S.decay = FALSE
	S.source_turf = get_turf(src)
	S.update_rad_power(radiation_power)
	SSradiation.add_source(S)

	loc.set_light(0.2, 1, req_range, l_color = COLOR_LIME) //The goo doesn't last, so this is another indicator

/obj/reactor_radiate/Destroy()
	. = ..()
	QDEL_NULL(S)
