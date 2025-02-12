/obj/item/mech_component/propulsion/light
	name = "light legs"
	desc = "These Odysseus series legs are built from lightweight flexible polymers, making them capable of handling falls from up to 120 meters in 1g environments. Provided that the exosuit lands on its feet."

	exosuit_desc_string = "flexible electromechanic legs"
	icon_state = "light_legs"
	mech_turn_sound = 'sound/mecha/mechmove02.ogg'
	mech_step_sound = 'sound/mecha/mechstep01.ogg'
	max_fall_damage = 0
	move_delay = 2
	turn_delay = 3
	power_use = 5
	max_damage = 80
	min_damage = 50
	max_repair = 20
	repair_damage = 15
	bump_type = MEDIUM_BUMP
	req_material = MATERIAL_ALUMINIUM
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 70
	heat_generation = 3
	max_speed = 2
	min_speed = 4
	acceleration = 0.75
	turn_slowdown = 1.5
	turn_diogonal_slowdown = 1
	weight = 100

/obj/item/mech_component/propulsion/light/handle_vehicle_fall()
	..()
	visible_message(SPAN_NOTICE("\The [src] creak as they absorb the impact."))
