/obj/machinery/computer/ship/ship_weapon/beam_cannon/particle_lance
	name = "particle lance control"
	caldigit = 5
	coolinterval = 120 SECONDS //time to wait between safe shots in deciseconds

	icon_state = "ascent"
	icon_keyboard = "mining_key"
	icon_screen = "ascent_screen"

	gun_name = "particle lance"

	front_type = /obj/machinery/ship_weapon/front_part/beam_cannon/particle_lance
	middle_type = /obj/machinery/ship_weapon/middle_part/beam_cannon/particle_lance
	back_type = /obj/machinery/ship_weapon/back_part/beam_cannon/particle_lance

	destroy_event_flags = OVERMAP_WEAKNESS_EMP

	var/heavy_ion_effect_range = 2
	var/light_ion_effect_range = 3

	shield_modflag_counter = MODEFLAG_EM

	overmap_icon = "particle_beam"

	beam_light_color = COLOR_LIGHT_CYAN
	beam_icon = "particle_beam"
