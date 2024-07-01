//Пульсач
/obj/item/mech_equipment/mounted_system/taser/pulse
	name = "\improper IDK \"Pulsator\" laser"
	desc = "Military mounted pulse-rifle, probaly stealed from military ship."
	icon_state = "mech_pulse"
	holding_type = /obj/item/gun/energy/lasercannon/mounted/mech/pulse

/obj/item/gun/energy/lasercannon/mounted/mech/pulse
	name = "\improper CH-PS \"Immolator\" laser"
	use_external_power = TRUE
	has_safety = FALSE
	self_recharge = TRUE
	fire_delay = 10
	accuracy = 2
	max_shots = 10
	projectile_type = /obj/item/projectile/beam/pulse/heavy
//Пульсач
