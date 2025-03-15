/obj/item/mech_component/propulsion/spider
	name = "spider leg"
	desc = "Xion Industrial's arachnid series boasts more leg per leg than the leading competitor."
	exosuit_desc_string = "hydraulic quadlegs"
	icon_state = "spiderlegs"
	cant_be_differents = TRUE
	mech_turn_sound = 'sound/mecha/mechmove03.ogg'
	mech_step_sound = 'sound/mecha/mechstep02.ogg'
	move_delay = 4
	turn_delay = 1
	power_use = 12.5
	max_hp = 50
	min_damage = 50
	max_repair = 30
	repair_damage = 25
	bump_type = MEDIUM_BUMP
	can_strafe = TRUE
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 112.5
	heat_cooling = 4
	emp_heat_generation = 75
	heat_generation = 2
	//Паучьи ноги не страдают от ускорений, их скорость статична
	max_speed = 26
	min_speed = 26
	acceleration = 0.5
	turn_slowdown = 0.75
	turn_diogonal_slowdown = 0.5
	weight = 150
	should_have_doubled_owner = TRUE
	doubled_owner_type = /obj/item/mech_component/doubled_legs/spider

/obj/item/mech_component/propulsion/spider/right
	name = "spider leg"
	side = RIGHT
