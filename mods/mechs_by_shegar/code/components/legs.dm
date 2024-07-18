/obj/item/mech_component/propulsion
	///Сила тарана
	var/bump_type = BASIC_BUMP
	///Мех может НЕ таранить если захочет?
	var/bump_safety = TRUE
	///Может ли мех ходить при помощи стрейфа. Крайне полезная фича, используйте если знаете что делаете.
	var/can_strafe = FALSE
	///Влияет на эффективность стрейфа, используйте когда мир будет к нему готов.
	var/good_in_strafe = FALSE
	var/collision_coldown = 7

/obj/item/mech_component/propulsion/powerloader
	max_damage = 100
	min_damage = 50
	max_repair = 30
	repair_damage = 10
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 15
	emp_heat_generation = 50
	heat_generation = 2

/obj/item/mech_component/propulsion/light
	max_damage = 80
	min_damage = 50
	max_repair = 20
	repair_damage = 15
	req_material = MATERIAL_ALUMINIUM
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 75
	heat_cooling = 7.5
	emp_heat_generation = 70
	heat_generation = 3

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
	heat_cooling = 3
	emp_heat_generation = 100
	heat_generation = 5

/obj/item/mech_component/propulsion/combat
	max_damage = 180
	min_damage = 100
	max_repair = 60
	repair_damage = 20
	bump_type = MEDIUM_BUMP
	bump_safety = FALSE
	move_delay = 3.5
	turn_delay = 3.5
	max_heat = 150
	heat_cooling = 5
	emp_heat_generation = 75
	heat_generation = 5
