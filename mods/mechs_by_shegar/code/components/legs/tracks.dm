/obj/item/mech_component/propulsion/tracks
	name = "track"
	desc = "A classic brought back. The Hephaestus' Landmaster class tracks are impervious to most damage and can maintain top speed regardless of load. Watch out for corners."
	exosuit_desc_string = "armored tracks"
	cant_be_differents = TRUE
	icon_state = "tracks"
	mech_turn_sound = 'sound/mecha/mechstep03.ogg'
	mech_step_sound = 'sound/machines/engine.ogg'
	move_delay = 2 //Скорость на уровне лёгких ног
	turn_delay = 10
	power_use = 75
	//ХП
	max_hp = 180
	min_damage = 100
	max_repair = 50
	repair_damage = 20

	matter = list(MATERIAL_STEEL = 75000, MATERIAL_PLASTEEL = 5000, MATERIAL_ALUMINIUM = 5000)

	bump_type = HARD_BUMP
	bump_safety = FALSE
	front_modificator_damage = 1
	//Тепло
	max_heat = 200
	heat_cooling = 4
	emp_heat_generation = 150
	heat_generation = 2

	max_speed = 29
	min_speed = 27
	acceleration = 0.5
	turn_slowdown = 2
	turn_diogonal_slowdown = 1.5
	weight = 200

	should_have_doubled_owner = TRUE
	doubled_owner_type = /obj/item/mech_component/doubled_legs/tracks

/obj/item/mech_component/propulsion/tracks/right
	name = "track"
	side = RIGHT
