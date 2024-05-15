/obj/machinery/ship_weapon
	icon = 'mods/_fd/old_space_cannons/icons/weapons.dmi'
	density = TRUE
	anchored = TRUE
	construct_state = /singleton/machine_construction/default/panel_closed

/obj/machinery/ship_weapon/examine(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "The maintenance panel is open.")

/obj/machinery/ship_weapon/attackby(obj/item/I, mob/user)
	if(isWrench(I))
		if(panel_open)
			user.visible_message("<span class='notice'>\The [user] rotates \the [src] with \the [I].</span>", "<span class='notice'>You rotate \the [src] with \the [I].</span>")
			set_dir(turn(dir, 90))
			playsound(src, 'sound/items/jaws_pry.ogg', 50, 1)
		else
			to_chat(user,"<span class='notice'>The maintenance panel must be screwed open for this!</span>")
	else
		return ..()

/obj/machinery/ship_weapon/front_part
	name = "ship weapon muzzle"
	desc = "An old-fashion cannon muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "gun"
	layer = 3.01

/obj/machinery/ship_weapon/middle_part
	name = "ship weapon barrel"
	desc = "An old-fashion gas tube that propels munitions to the ship weapon muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "magazine"
	maximum_component_parts = list(/obj/item/stock_parts = 15)

/obj/machinery/ship_weapon/back_part
	name = "ship weapon breech end"
	desc = "An old-fashion ammo reciever. Munition then goes to ship weapon barrel."
	icon_state = "ammo_loader"
	density = FALSE
//	layer = BELOW_DOOR_LAYER //So the charges go above us.

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/ship_weapon
	name = "circuit board (ship weapon control)"
	build_path = /obj/machinery/computer/ship/ship_weapon
	origin_tech = list(TECH_ENGINEERING = 2, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/ship_weapon_front
	name = "circuit board (ship weapon muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_COMBAT = 4)
	req_components = list (
		/obj/item/stack/material/plasteel = 20
	)

/obj/item/stock_parts/circuitboard/ship_weapon_middle
	name = "circuit board (ship weapon barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_COMBAT = 4)
	req_components = list (
		/obj/item/stack/material/plasteel = 30
	)

/obj/item/stock_parts/circuitboard/ship_weapon_back
	name = "circuit board (ship weapon breech end)"
	build_path = /obj/machinery/ship_weapon/back_part
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 3)
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5
	)
