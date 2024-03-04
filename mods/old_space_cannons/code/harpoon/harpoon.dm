/obj/machinery/ship_weapon/front_part/harpoon_cannon
	name = "IW-05 harpoon cannon muzzle"
	desc = "An old-fashion harpoon cannon muzzle.\
		<br>A sign on it reads: <i>STAY CLEAR! DO NOT BLOCK!</i>"
	icon_state = "front"

/obj/machinery/ship_weapon/middle_part/harpoon_cannon
	name = "IW-05 harpoon cannon rail"
	desc = "An old-fashion gas tube that propels munitions to the cannon muzzle. \
		<br>A sign on it reads: <i>EXPLOSIVE! DO NOT OVERHEAT!</i>"
	icon_state = "harpoon"

/obj/machinery/ship_weapon/back_part/harpoon_cannon
	name = "IW-05 harpoon cannon munition rack"
	desc = "An old-fashion ammo reciever. Munition then goes to cannon rail."
	icon_state = "back"

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/harpoon
	name = "circuit board (harpoon cannon control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/harpoon_gun
	origin_tech = list(TECH_ENGINEERING = 2, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/harpoonfront
	name = "circuit board (harpoon cannon muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/harpoon_cannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 2)
	req_components = list (
		/obj/item/stack/material/steel = 40
	)

/obj/item/stock_parts/circuitboard/harpoonmiddle
	name = "circuit board (harpoon cannon rail)"
	build_path = /obj/machinery/ship_weapon/middle_part/harpoon_cannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 2)
	req_components = list (
		/obj/item/stack/material/steel = 50
	)

/obj/item/stock_parts/circuitboard/harpoonback
	name = "circuit board (harpoon cannon munition rack)"
	build_path = /obj/machinery/ship_weapon/back_part/harpoon_cannon
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 2)
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 3,
		/obj/item/stock_parts/manipulator/pico = 3
	)

/obj/item/stock_parts/circuitboard/harpoon/tele
	name = "circuit board (harpoon control telescreen)"
	build_path = /obj/machinery/computer/ship/ship_weapon/harpoon_gun/telescreen
