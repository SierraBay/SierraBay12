/obj/machinery/ship_weapon/front_part/disruptor
	name = "EWW-01 disruptor muzzle"
	desc = "A disruptor muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "gun"

/obj/machinery/ship_weapon/middle_part/disruptor
	name = "EWW-01 disruptor barrel"
	desc = "A gas tube that propels munitions to the disruptor muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "disruptor"

/obj/machinery/ship_weapon/back_part/disruptor
	name = "EWW-01 disruptor breech end"
	desc = "An ammo reciever. Munition then goes to disruptor barrel."
	icon_state = "ammo_loader"

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/disruptor
	name = "circuit board (disruptor control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/disruptor

/obj/item/stock_parts/circuitboard/disruptor_front
	name = "circuit board (disruptor muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/disruptor
	board_type = "machine"
	req_components = list (
		/obj/item/stock_parts/manipulator/pico = 5
	)

/obj/item/stock_parts/circuitboard/disruptor_middle
	name = "circuit board (disruptor barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/disruptor
	board_type = "machine"
	req_components = list (
		/obj/item/stock_parts/subspace/crystal = 10
	)

/obj/item/stock_parts/circuitboard/disruptor_back
	name = "circuit board (disruptor breech end)"
	build_path = /obj/machinery/ship_weapon/back_part/disruptor
	board_type = "machine"
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 5
	)

/obj/item/stock_parts/circuitboard/disruptor/tele
	name = "circuit board (disruptor control telescreen)"
	build_path = /obj/machinery/computer/ship/ship_weapon/disruptor/telescreen
