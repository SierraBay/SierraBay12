/obj/machinery/computer/ship/ship_weapon/beam_cannon
	name = "ion beam emitter control"
	caldigit = 6
	coolinterval = 175 SECONDS
	gun_name = "Ion beam emitter"

	front_type = /obj/machinery/ship_weapon/front_part/beam_cannon
	middle_type = /obj/machinery/ship_weapon/middle_part/beam_cannon
	back_type = /obj/machinery/ship_weapon/back_part/beam_cannon

	ammo_per_shot = 9750000
	burst_size = 1

	fire_delay = 200

	shake_camera_force = 50

	var/shoot_range = 1

	var/destroy_event_flags = OVERMAP_WEAKNESS_EXPLOSIVE

	var/shield_modflag_counter = MODEFLAG_PHOTONIC

	var/ignore_blockage = TRUE

	var/pew_spread = 20

	fire_sound = 'mods/_fd/old_space_cannons/sounds/superlaser_firing.ogg'
	prefire_sound = 'mods/_fd/old_space_cannons/sounds/superlaser_prefire.ogg'

	far_fire_sound = 'mods/_fd/old_space_cannons/sounds/superlaser_firing.ogg'
	far_prefire_sound = 'mods/_fd/old_space_cannons/sounds/superlaser_prefire.ogg'

	var/overmap_icon = "ion_beam" // icons\effects\beam.dmi

	var/beam_time = 70
	var/beam_speed = 1

	var/beam_light_color = COLOR_RED_LIGHT
	var/beam_icon = "ion_beam" // icons\effects\beam.dmi

	var/beam_sound = 'mods/_fd/old_space_cannons/sounds/ion_beam_hit.ogg'

/obj/machinery/computer/ship/ship_weapon/beam_cannon/get_charge()
	return "energy"

/obj/machinery/computer/ship/ship_weapon/beam_cannon/get_ammo_type()
	return "energy"

/obj/machinery/computer/ship/ship_weapon/beam_cannon/get_ammo()
	return "energy"

/obj/machinery/computer/ship/ship_weapon/beam_cannon/remove_ammo()
	return "energy"
