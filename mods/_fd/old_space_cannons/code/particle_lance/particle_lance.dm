/obj/machinery/ship_weapon/front_part/beam_cannon/particle_lance
	name = "particle lance muzzle"
	desc = "A particle beam muzzle."
	color = COLOR_PURPLE

/obj/machinery/ship_weapon/middle_part/beam_cannon/particle_lance
	name = "particle lance barrel"
	desc = "A gas tube that propels munitions to the particle beam muzzle."
	color = COLOR_PURPLE

/obj/machinery/ship_weapon/back_part/beam_cannon/particle_lance
	name = "particle lance charger"
	desc = "An ammo reciever. Munition then goes to particle beam barrel."
	color = COLOR_PURPLE

////////////////////////////////CIRCUIT////////////////////////////////

/obj/item/stock_parts/circuitboard/particlelance
	name = "circuit board (particle lance control)"
	build_path = /obj/machinery/computer/ship/ship_weapon/beam_cannon/particle_lance
	origin_tech = list(TECH_ENGINEERING = 4, TECH_COMBAT = 2)

/obj/item/stock_parts/circuitboard/particlelance_front
	name = "circuit board (particle lance muzzle)"
	build_path = /obj/machinery/ship_weapon/front_part/beam_cannon/particle_lance
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 6, TECH_COMBAT = 7)
	req_components = list (
		/obj/item/stack/material/diamond = 10
	)

/obj/item/stock_parts/circuitboard/particle_lancemiddle
	name = "circuit board (particle lance barrel)"
	build_path = /obj/machinery/ship_weapon/middle_part/beam_cannon/particle_lance
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 6, TECH_COMBAT = 7)
	req_components = list (
		/obj/item/stock_parts/micro_laser/ultra = 10
	)

/obj/item/stock_parts/circuitboard/particle_lanceback
	name = "circuit board (particle lance charger)"
	build_path = /obj/machinery/ship_weapon/back_part/beam_cannon/particle_lance
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 7, TECH_COMBAT = 6)
	req_components = list (
		/obj/item/stock_parts/smes_coil/super_io = 5
	)
