/obj/machinery/computer/ship/ship_weapon/hmg
	name = "IW-12 heavy machine gun control"
	caldigit = 2
	coolinterval = 8 SECONDS
	gun_name = "Heavy machine gun"

	front_type = /obj/machinery/ship_weapon/front_part/hmg
	middle_type = /obj/machinery/ship_weapon/middle_part/hmg
	back_type = /obj/machinery/ship_weapon/back_part/hmg
	munition_type = /obj/item/ammo_magazine/ammobox/hmg

	burst_size = 10
	fire_interval = 3

/obj/machinery/computer/ship/ship_weapon/hmg/telescreen	//little hacky but it's only used on one ship so it should be okay
	icon = 'mods/_fd/old_space_cannons/icons/telescreen_consoles.dmi'
	icon_state = "tele_hmg"
	density = FALSE
	machine_name = "HMG control telescreen"
	machine_desc = "A compact, slimmed-down version of the weapon control console."

/obj/machinery/computer/ship/ship_weapon/hmg/telescreen/on_update_icon()
	if(reason_broken & MACHINE_BROKEN_NO_PARTS || !is_powered() || MACHINE_IS_BROKEN(src))
		icon_state = "tele_off"
		set_light(0)
	else
		icon_state = "tele_hmg"
		set_light(light_range_on, light_power_on, light_color)
