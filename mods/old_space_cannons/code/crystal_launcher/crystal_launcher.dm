/obj/machinery/ship_weapon/front_part/crystal_launcher
	name = "crystal launcher muzzle"
	desc = "A crystal launcher muzzle."
	color = COLOR_PURPLE

/obj/machinery/ship_weapon/middle_part/crystal_launcher
	name = "crystal launcher barrel"
	desc = "A gas tube that propels munitions to the crystal launcher muzzle."
	color = COLOR_PURPLE

/obj/machinery/ship_weapon/back_part/crystal_launcher
	name = "crystal launcher charger"
	desc = "An ammo reciever. Munition then goes to crystal launcher barrel."
	color = COLOR_PURPLE

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/crystal_launcher
	name = "circuit board (crystal launcher control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/crystal_launcher
	origin_tech = list(TECH_ENGINEERING = 2, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/crystal_launcher_front
	name = "circuit board (crystal launcher muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/crystal_launcher
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_COMBAT = 4)
	req_components = list (
		/obj/item/stack/material/plasteel = 20
	)

/obj/item/stock_parts/circuitboard/crystal_launcher_middle
	name = "circuit board (crystal launcher barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/crystal_launcher
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_COMBAT = 4)
	req_components = list (
		/obj/item/stack/material/plasteel = 30
	)

/obj/item/stock_parts/circuitboard/crystal_launcher_back
	name = "circuit board (crystal launcher breech end)"
	build_path = /obj/machinery/ship_weapon/back_part/crystal_launcher
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 3)
	req_components = list (
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5
	)
