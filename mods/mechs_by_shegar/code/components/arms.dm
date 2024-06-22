/obj/item/mech_component/manipulators
	///Могут ли пассажиры занимать Left back и Right back (боковые пассажирские места)?
	var/allow_passengers = TRUE

/obj/item/mech_component/manipulators/powerloader
	max_damage = 100
	min_damage = 50
	max_repair = 30
	melee_damage = 30
	repair_damage = 10

/obj/item/mech_component/manipulators/light
	allow_passengers = FALSE
	max_damage = 80
	min_damage = 50
	max_repair = 20
	melee_damage = 30
	repair_damage = 15
	req_material = MATERIAL_ALUMINIUM

/obj/item/mech_component/manipulators/heavy
	melee_damage = 40
	max_repair = 150
	max_damage = 500
	min_damage = 300
	repair_damage = 30
	req_material = MATERIAL_PLASTEEL

/obj/item/mech_component/manipulators/combat
	max_damage = 180
	min_damage = 100
	max_repair = 60
	melee_damage = 30
	repair_damage = 20
