/obj/machinery/ship_weapon/front_part/rocket
	name = "RLS-85 rocket accelerator"
	desc = "Lots of rocket accelerator barrels.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "rls_front"

/obj/machinery/ship_weapon/middle_part/rocket
	name = "RLS-85 rocket activator"
	desc = "A massive rocket activator for their further launch into the accelerator. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "rls_middle"

/obj/machinery/ship_weapon/back_part/rocket
	name = "RLS-85 rocket receiver"
	desc = "Rocket reciever. Munition then goes to rocket activator."
	icon_state = "rls_back"

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/rocket
	name = "circuit board (RLS control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/rocket
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 4)

/obj/item/stock_parts/circuitboard/rocket_front
	name = "circuit board (rocket accelerator)"
	build_path = /obj/machinery/ship_weapon/front_part/rocket
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 5)
	req_components = list (
		/obj/item/stack/material/plasteel = 30
	)

/obj/item/stock_parts/circuitboard/rocket_middle
	name = "circuit board (rocket activator)"
	build_path = /obj/machinery/ship_weapon/middle_part/rocket
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 5)
	req_components = list (
		/obj/item/stack/material/plasteel = 30
	)

/obj/item/stock_parts/circuitboard/rocket_back
	name = "circuit board (rocket receiver)"
	build_path = /obj/machinery/ship_weapon/back_part/rocket
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 3)
	req_components = list (
		/obj/item/stock_parts/capacitor/adv = 5,
		/obj/item/stock_parts/manipulator/nano = 5
	)
