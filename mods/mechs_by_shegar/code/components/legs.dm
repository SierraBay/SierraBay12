/obj/item/mech_component/propulsion

	///////////////BUMP///////////////

	///Сила тарана, выступает модификатором урона от тарана
	var/bump_type = BASIC_BUMP
	///Мех может НЕ таранить если захочет?
	var/bump_safety = TRUE
	var/collision_coldown = 7

	///////////////BUMP///////////////


	///////////////STRAFE///////////////

	///Может ли мех ходить при помощи стрейфа. Крайне полезная фича, используйте если знаете что делаете.
	var/can_strafe = FALSE
	///Влияет на эффективность стрейфа, используйте когда мир будет к нему готов.
	var/good_in_strafe = FALSE

	///////////////STRAFE///////////////


	///////////////SPEED///////////////

	///Максимальная возможная скорость движения ног. Указывается в виде КД до следующего шага.
	var/max_speed = 5
	///Текущая скорость движения меха
	var/current_speed
	///Минимальная возможная скорость движения меха
	var/min_speed = 10
	///Номинальное ускорение меха. Итоговое ускорение меха расчитывается в mech.dm на 79 строке.
	var/acceleration = 0.1
	///Как сильно замедляются ноги при диогональном повороте на 45 градусов
	var/turn_diogonal_slowdown = 0.5
	///Как сильно замедляются ноги при обычном повороте на 90 градусов
	var/turn_slowdown = 0.5
	///КД, спустя которое мех полностью теряет ускорение если он не двигался
	var/lost_speed_colldown = 1 SECONDS

	///////////////SPEED///////////////





/obj/item/mech_component/propulsion/powerloader
	max_damage = 100
	min_damage = 50
	max_repair = 30
	repair_damage = 10
	bump_type = MEDIUM_BUMP
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 7
	emp_heat_generation = 50
	heat_generation = 2
	max_speed = 4
	min_speed = 6
	acceleration = 0.75
	turn_slowdown = 1.25
	turn_diogonal_slowdown = 1.75
	weight = 150

/obj/item/mech_component/propulsion/light
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

/obj/item/mech_component/propulsion/spider
	max_damage = 210
	min_damage = 100
	max_repair = 60
	repair_damage = 50
	bump_type = MEDIUM_BUMP
	can_strafe = TRUE
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 225
	heat_cooling = 8
	emp_heat_generation = 125
	heat_generation = 2
	max_speed = 4
	min_speed = 6
	acceleration = 0.5
	turn_slowdown = 0.75
	turn_diogonal_slowdown = 0.5
	weight = 300

/obj/item/mech_component/propulsion/tracks
	max_damage = 250
	min_damage = 200
	max_repair = 100
	repair_damage = 20
	bump_type = HARD_BUMP
	bump_safety = FALSE
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 2
	emp_heat_generation = 125
	heat_generation = 2
	max_speed = 2
	min_speed = 6
	acceleration = 0.75
	turn_slowdown = 2
	turn_diogonal_slowdown = 1.5
	weight = 300


/obj/item/mech_component/propulsion/heavy
	max_damage = 500
	min_damage = 300
	max_repair = 150
	repair_damage = 20
	bump_type = HARD_BUMP
	bump_safety = FALSE
	req_material = MATERIAL_PLASTEEL
	back_modificator_damage = 1
	front_modificator_damage = 0.7
	max_heat = 300
	heat_cooling = 4
	emp_heat_generation = 100
	heat_generation = 5
	max_speed = 4.5
	min_speed = 8
	acceleration = 1
	turn_slowdown = 2
	turn_diogonal_slowdown = 1.5
	weight = 400

/obj/item/mech_component/propulsion/combat
	max_damage = 180
	min_damage = 100
	max_repair = 60
	repair_damage = 20
	bump_type = MEDIUM_BUMP
	bump_safety = FALSE
	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 100
	heat_generation = 4
	turn_delay = 3.5
	max_speed = 3
	min_speed = 7
	acceleration = 1.25
	turn_slowdown = 2.5
	turn_diogonal_slowdown = 2
	weight = 250
