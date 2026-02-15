/obj/item/mech_component/propulsion/heavy
	name = "heavy armored leg"
	desc = "Oversized actuators struggle to move these armoured legs. "
	exosuit_desc_string = "heavy hydraulic legs"
	icon_state = "heavy_leg"
	mech_turn_sound = 'sound/mecha/mechmove01.ogg'
	mech_step_sound = 'sound/mecha/mechstep03.ogg'
	move_delay = 5
	turn_delay = 5
	power_use = 50

	//Хп
	max_hp = 150
	min_damage = 100
	max_repair = 40
	repair_damage = 10
	back_modificator_damage = 3
	front_modificator_damage = 0.5

	matter = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

	//Тепло
	max_heat = 400
	heat_cooling = 4
	emp_heat_generation = 150
	heat_generation = 2.5

	bump_type = HARD_BUMP
	bump_safety = FALSE
	req_material = MATERIAL_PLASTEEL
	max_speed = 26
	min_speed = 23
	acceleration = 1
	turn_slowdown = 2
	turn_diogonal_slowdown = 1.5
	weight = 200

/obj/item/mech_component/propulsion/heavy/right
	name = "heavy armored mech leg"
	side = RIGHT
