/obj/machinery/ship_weapon/front_part/autocannon
	name = "M2410 autocannon muzzle"
	desc = "An old-fashion autocannon muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "gun"

/obj/machinery/ship_weapon/middle_part/autocannon
	name = "M2410 autocannon barrel"
	desc = "An old-fashion gas tube that propels munitions to the autocannon muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "autocannon"

/obj/machinery/ship_weapon/back_part/autocannon
	name = "M2410 autocannon breech end"
	desc = "An old-fashion ammo reciever. Munition then goes to autocannon barrel."
	icon_state = "ammo_loader"

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/autocannon
	name = "circuit board (autocannon control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/autocannon
	origin_tech = list(TECH_ENGINEERING = 2, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/autocannon_front
	name = "circuit board (autocannon muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/autocannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_COMBAT = 4)
	req_components = list (
		/obj/item/stack/material/plasteel = 20
	)

/obj/item/stock_parts/circuitboard/autocannon_middle
	name = "circuit board (autocannon barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/autocannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_COMBAT = 4)
	req_components = list (
		/obj/item/stack/material/plasteel = 30
	)

/obj/item/stock_parts/circuitboard/autocannon_back
	name = "circuit board (autocannon breech end)"
	build_path = /obj/machinery/ship_weapon/back_part/autocannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 3)
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5
	)
