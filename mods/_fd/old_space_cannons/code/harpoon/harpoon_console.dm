/obj/machinery/computer/ship/ship_weapon/harpoon_gun
	name = "IW-05 harpoon gun control"
	caldigit = 5
	coolinterval = 45 SECONDS
	gun_name = "Harpoon gun"

	front_type = /obj/machinery/ship_weapon/front_part/harpoon_cannon
	middle_type = /obj/machinery/ship_weapon/middle_part/harpoon_cannon
	back_type = /obj/machinery/ship_weapon/back_part/harpoon_cannon
	munition_type = /obj/item/ammo_magazine/ammobox/harpoon_cannon

	burst_size = 1
	fire_interval = 0

	fire_sound = 'mods/_fd/old_space_cannons/sounds/autocannon_fire.ogg'

	play_emptymag_sound = 0

/obj/machinery/computer/ship/ship_weapon/harpoon_gun/telescreen	//little hacky but it's only used on one ship so it should be okay
	icon = 'mods/_fd/old_space_cannons/icons/telescreen_consoles.dmi'
	icon_state = "tele_hmg"
	density = FALSE
	machine_name = "harpoon control telescreen"
	machine_desc = "A compact, slimmed-down version of the weapon control console."

/obj/machinery/computer/ship/ship_weapon/harpoon_gun/telescreen/on_update_icon()
	if(reason_broken & MACHINE_BROKEN_NO_PARTS || !is_powered() || MACHINE_IS_BROKEN(src))
		icon_state = "tele_off"
		set_light(0)
	else
		icon_state = "tele_hmg"
		set_light(light_range_on, light_power_on, light_color)
