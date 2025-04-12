/obj/item/mech_component/propulsion/light
	name = "light leg"
	desc = "These Odysseus series legs are built from lightweight flexible polymers, making them capable of handling falls from up to 120 meters in 1g environments. Provided that the exosuit lands on its feet."

	exosuit_desc_string = "flexible electromechanic legs"
	icon_state = "light_leg"
	mech_turn_sound = 'sound/mecha/mechmove02.ogg'
	mech_step_sound = 'sound/mecha/mechstep01.ogg'
	max_fall_damage = 0
	move_delay = 2
	turn_delay = 3
	power_use = 2.5
	max_hp = 40
	min_damage = 25
	max_repair = 10
	repair_damage = 7.5
	bump_type = MEDIUM_BUMP
	req_material = MATERIAL_ALUMINIUM
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 50
	heat_cooling = 6
	emp_heat_generation = 35
	heat_generation = 1.5
	max_speed = 29
	min_speed = 26
	acceleration = 1
	turn_slowdown = 1.5
	turn_diogonal_slowdown = 1
	weight = 50

/obj/item/mech_component/propulsion/light/right
	side = RIGHT

/obj/item/mech_component/propulsion/light/handle_vehicle_fall()
	..()
	visible_message(SPAN_NOTICE("\The [src] creak as they absorb the impact."))
