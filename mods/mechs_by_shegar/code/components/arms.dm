/obj/item/mech_component/manipulators
	var/allow_passengers = TRUE

/obj/item/mech_component/manipulators/light
	allow_passengers = FALSE
	max_damage = 80
	melee_damage = 30

/obj/item/mech_component/manipulators/powerloader
	max_damage = 100
	melee_damage = 30

/obj/item/mech_component/manipulators/heavy
	melee_damage = 40
	max_damage = 500

/obj/item/mech_component/manipulators/combat
	max_damage = 180
	melee_damage = 30
