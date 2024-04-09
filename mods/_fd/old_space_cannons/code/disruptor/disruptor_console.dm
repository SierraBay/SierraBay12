/obj/machinery/computer/ship/ship_weapon/disruptor
	name = "EWW-01 disruptor control"
	coolinterval = 16 SECONDS
	gun_name = "Disruptor"

	front_type = /obj/machinery/ship_weapon/front_part/disruptor
	middle_type = /obj/machinery/ship_weapon/middle_part/disruptor
	back_type = /obj/machinery/ship_weapon/back_part/disruptor
	munition_type = /obj/item/ammo_magazine/ammobox/disruptor

	ammo_per_shot = 150
	burst_size = 4
	fire_interval = 4

	prefire_sound = 'mods/_fd/old_space_cannons/sounds/disruptor_charging.ogg'
	fire_delay = 4

	shake_camera_force = 0

	fire_sound = 'mods/_fd/old_space_cannons/sounds/disruptor_shoot.ogg'
	far_fire_sound = 'mods/_fd/old_space_cannons/sounds/disruptor_shoot.ogg'

	muzzle_flash = /obj/projectile/bullet/muzzle/ship_weapon/disruptor

	play_emptymag_sound = 0

/obj/machinery/computer/ship/ship_weapon/disruptor/telescreen	//little hacky but it's only used on one ship so it should be okay
	icon = 'mods/_fd/old_space_cannons/icons/telescreen_consoles.dmi'
	icon_state = "tele_disruptor"
	density = FALSE
	machine_name = "disruptor control telescreen"
	machine_desc = "A compact, slimmed-down version of the weapon control console."

/obj/machinery/computer/ship/ship_weapon/disruptor/telescreen/on_update_icon()
	if(reason_broken & MACHINE_BROKEN_NO_PARTS || !is_powered() || MACHINE_IS_BROKEN(src))
		icon_state = "tele_off"
		set_light(0)
	else
		icon_state = "tele_disruptor"
		set_light(light_range_on, light_power_on, light_color)
