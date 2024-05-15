/obj/machinery/ship_weapon/front_part/minigun
	name = "АК2057-Р rotary railgun cannon muzzle"
	desc = "An old-fashion minigun muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "meme2"

/obj/machinery/ship_weapon/middle_part/minigun
	name = "АК2057-Р rotary railgun cannon barrel"
	desc = "An old-fashion gas tube that propels munitions to rotary cannon muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "middle"

/obj/machinery/ship_weapon/back_part/minigun
	name = "АК2057-Р rotary railgun cannon breech end"
	desc = "An old-fashion ammo reciever. Munition then goes to rotary cannon barrel."
	icon_state = "back"
	density = FALSE
//	layer = BELOW_DOOR_LAYER //So the charges go above us.

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/minigun
	name = "circuit board (rotary railgun cannon control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/minigun
	origin_tech = list(TECH_ENGINEERING = 2, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/minigun/tele
	name = "circuit board (rotary railgun cannon control telescreen)"
	build_path = /obj/machinery/computer/ship/ship_weapon/minigun/telescreen

/obj/item/stock_parts/circuitboard/minigun_front
	name = "circuit board (rotary railgun cannon muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/minigun
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 6)
	req_components = list (
		/obj/item/stack/material/plasteel = 25
	)

/obj/item/stock_parts/circuitboard/minigun_middle
	name = "circuit board (rotary cannon barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/minigun
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 6)
	req_components = list (
		/obj/item/stack/material/plasteel = 35
	)

/obj/item/stock_parts/circuitboard/minigun_back
	name = "circuit board (rotary cannon breech end)"
	build_path = /obj/machinery/ship_weapon/back_part/minigun
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 5, TECH_COMBAT = 5)
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 3,
		/obj/item/stock_parts/manipulator/pico = 3
	)
