/obj/item/mech_component/manipulators/light
	name = "light arm"
	desc = "As flexible as they are fragile, these Vey-Med manipulators can follow a pilot's movements in close to real time."
	exosuit_desc_string = "lightweight, segmented manipulators"
	icon_state = "light_arm"
	punch_sound = 'sound/mecha/mech_punch_fast.ogg'
	action_delay = 8
	power_use = 5

	max_hp = 75
	min_damage = 30
	max_repair = 50
	repair_damage = 15
	front_modificator_damage = 1

	matter = list(MATERIAL_STEEL = 30000, MATERIAL_PLASTIC = 5000, MATERIAL_ALUMINIUM = 5000)

	melee_damage = 30
	req_material = MATERIAL_ALUMINIUM
	//Тепло
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 110
	heat_generation = 5

	weight = 50

/obj/item/mech_component/manipulators/light/right
	side = RIGHT
