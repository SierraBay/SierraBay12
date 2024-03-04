/obj/machinery/ship_weapon/front_part/hmg
	name = "IW-12 HMG muzzle"
	desc = "An old-fashion heavy machinegun muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "gun"

/obj/machinery/ship_weapon/middle_part/hmg
	name = "IW-12 HMG barrel"
	desc = "An old-fashion gas tube that propels munitions to HMG muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "hmg"

/obj/machinery/ship_weapon/back_part/hmg
	name = "IW-12 HMG breech end"
	desc = "An old-fashion ammo reciever. Munition then goes to HMG barrel."
	icon_state = "ammo_loader"

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/heavymg
	name = "circuit board (heavy machine gun control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/hmg

/obj/item/stock_parts/circuitboard/heavymg_front
	name = "circuit board (heavy machine gun muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/hmg
	board_type = "machine"
	req_components = list (
		/obj/item/stack/material/steel = 20
	)

/obj/item/stock_parts/circuitboard/heavymg_middle
	name = "circuit board (heavy machine gun barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/hmg
	board_type = "machine"
	req_components = list (
		/obj/item/stack/material/steel = 30
	)

/obj/item/stock_parts/circuitboard/heavymg_back
	name = "circuit board (heavy machine gun breech end)"
	build_path = /obj/machinery/ship_weapon/back_part/hmg
	board_type = "machine"
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 3,
		/obj/item/stock_parts/manipulator/pico = 3
	)


/obj/item/stock_parts/circuitboard/heavymg/tele
	name = "circuit board (heavy machine gun control telescreen)"
	build_path = /obj/machinery/computer/ship/ship_weapon/hmg/telescreen
