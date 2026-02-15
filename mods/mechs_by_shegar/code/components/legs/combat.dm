

/obj/item/mech_component/propulsion/combat
	name = "combat mech leg"
	exosuit_desc_string = "sleek hydraulic legs"
	icon_state = "combat_leg"
	mech_turn_sound = 'sound/mecha/mechmove03.ogg'
	mech_step_sound = 'sound/mecha/mechstep03.ogg'
	move_delay = 3
	turn_delay = 3
	power_use = 20

	max_hp = 150
	min_damage = 100
	max_repair = 60
	repair_damage = 30

	matter = list(MATERIAL_STEEL = 45000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

	//Тепло
	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 150
	heat_generation = 2

	bump_type = MEDIUM_BUMP
	bump_safety = FALSE
	turn_delay = 3.5
	max_speed = 28
	min_speed = 23
	acceleration = 1.5
	turn_slowdown = 2.5
	turn_diogonal_slowdown = 2
	weight = 125

/obj/item/mech_component/propulsion/combat/right
	name = "combat mech leg"
	side = RIGHT
