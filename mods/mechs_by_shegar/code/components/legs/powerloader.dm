/obj/item/mech_component/propulsion/powerloader
	name = "exosuit leg"
	icon_state = "loader_leg"
	desc = "Wide and stable but not particularly fast."
	exosuit_desc_string = "reinforced hydraulic legs"
	mech_step_sound = 'sound/mecha/mechstep03.ogg'
	move_delay = 4
	turn_delay = 4
	power_use = 5
	//ХП
	max_hp = 40
	min_damage = 25
	max_repair = 15
	repair_damage = 10
	front_modificator_damage = 1
	//Тепло
	max_heat = 100
	heat_cooling = 7
	emp_heat_generation = 50
	heat_generation = 2

	matter = list(MATERIAL_STEEL = 10000)

	bump_type = MEDIUM_BUMP
	max_speed = 26
	min_speed = 23
	acceleration = 0.75
	turn_slowdown = 1.25
	turn_diogonal_slowdown = 1.75

	weight = 70

/obj/item/mech_component/propulsion/powerloader/right
	name = "exosuit leg"
	side = RIGHT
