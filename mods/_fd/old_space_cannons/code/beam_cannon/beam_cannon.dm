/obj/machinery/ship_weapon/front_part/beam_cannon
	name = "ion beam emitter muzzle"
	desc = "An ion beam muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "front"

/obj/machinery/ship_weapon/middle_part/beam_cannon
	name = "ion beam emitter barrel"
	desc = "A gas tube that propels munitions to the ion beam muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "middle"

/obj/machinery/ship_weapon/back_part/beam_cannon
	name = "ion beam emitter charger"
	desc = "An ammo reciever. Munition then goes to ion beam barrel."
	icon_state = "back"
	density = TRUE

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/beamcannon
	name = "circuit board (ion beam emitter control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/beam_cannon
	origin_tech = list(TECH_ENGINEERING = 2, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/beamcannon_front
	name = "circuit board (ion beam emitter muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/beam_cannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 5, TECH_COMBAT = 6)
	req_components = list (
		/obj/item/stack/material/diamond = 10
	)

/obj/item/stock_parts/circuitboard/beamcannon_middle
	name = "circuit board (ion beam emitter barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/beam_cannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 5, TECH_COMBAT = 6)
	req_components = list (
		/obj/item/stock_parts/micro_laser/ultra = 10
	)

/obj/item/stock_parts/circuitboard/beamcannon_back
	name = "circuit board (ion beam emitter charger)"
	build_path = /obj/machinery/ship_weapon/back_part/beam_cannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 6, TECH_COMBAT = 5)
	req_components = list (
		/obj/item/stock_parts/smes_coil/super_io = 5
	)
