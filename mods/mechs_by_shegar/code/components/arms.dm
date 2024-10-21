/obj/item/mech_component/manipulators
	///Могут ли пассажиры занимать Left back и Right back (боковые пассажирские места)?
	var/allow_passengers = TRUE

/obj/item/mech_component/manipulators/powerloader
	max_damage = 100
	min_damage = 50
	max_repair = 30
	melee_damage = 30
	repair_damage = 10
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 7
	emp_heat_generation = 75
	heat_generation = 5
	weight = 150

/obj/item/mech_component/manipulators/light
	allow_passengers = FALSE
	max_damage = 80
	min_damage = 50
	max_repair = 20
	melee_damage = 30
	repair_damage = 15
	req_material = MATERIAL_ALUMINIUM
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 80
	heat_generation = 10
	weight = 100

/obj/item/mech_component/manipulators/heavy
	melee_damage = 40
	max_repair = 150
	max_damage = 500
	min_damage = 300
	repair_damage = 30
	req_material = MATERIAL_PLASTEEL
	back_modificator_damage = 1
	front_modificator_damage = 0.7
	max_heat = 300
	heat_cooling = 4
	emp_heat_generation = 100
	heat_generation = 15
	weight = 400

/obj/item/mech_component/manipulators/combat
	max_damage = 180
	min_damage = 100
	max_repair = 60
	melee_damage = 30
	repair_damage = 20
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 100
	heat_generation = 20
	weight = 250
