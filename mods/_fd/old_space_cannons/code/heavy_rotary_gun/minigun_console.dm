/obj/machinery/computer/ship/ship_weapon/minigun
	name = "АК2057-Р rotary railgun cannon control"
	coolinterval = 25 SECONDS
	gun_name = "Heavy rotary gun"

	front_type = /obj/machinery/ship_weapon/front_part/minigun
	middle_type = /obj/machinery/ship_weapon/middle_part/minigun
	back_type = /obj/machinery/ship_weapon/back_part/minigun
	munition_type = /obj/item/ammo_magazine/ammobox/minigun

	ammo_per_shot = 1
	burst_size = 60
	fire_interval = 1.5

	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'

/obj/machinery/computer/ship/ship_weapon/minigun/telescreen	//little hacky but it's only used on one ship so it should be okay
	icon = 'mods/_fd/old_space_cannons/icons/telescreen_consoles.dmi'
	icon_state = "tele_hmg"
	density = FALSE
	machine_name = "АК2057-Р control telescreen"
	machine_desc = "A compact, slimmed-down version of the weapon control console."

/obj/machinery/computer/ship/ship_weapon/minigun/telescreen/on_update_icon()
	if(reason_broken & MACHINE_BROKEN_NO_PARTS || !is_powered() || MACHINE_IS_BROKEN(src))
		icon_state = "tele_off"
		set_light(0)
	else
		icon_state = "tele_hmg"
		set_light(light_range_on, light_power_on, light_color)
