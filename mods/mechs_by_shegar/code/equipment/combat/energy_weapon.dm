///ТАЗЕР///
/obj/item/mech_equipment/mounted_system/taser
	heat_generation = 10

/obj/item/gun/energy/taser/carbine/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/taser/carbine/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)

/obj/item/gun/energy/taser/carbine/mounted/mech/Initialize()
	.=..()
	holder = loc
///ТАЗЕР///


///ИОНКА///
/obj/item/mech_equipment/mounted_system/taser/ion
	heat_generation = 20

/obj/item/gun/energy/ionrifle/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/ionrifle/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/ionrifle/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
///ИОНКА///


///ЛАЗЕР///

/obj/item/mech_equipment/mounted_system/taser/laser
	heat_generation = 50

/obj/item/gun/energy/lasercannon/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/lasercannon/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/lasercannon/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
///ЛАЗЕР///



//Пульсач
/obj/item/mech_equipment/mounted_system/taser/pulse
	name = "\improper IDK \"Pulsator\" laser"
	desc = "Military mounted pulse-rifle, probaly stealed from military ship."
	icon_state = "mech_pulse"
	holding_type = /obj/item/gun/energy/lasercannon/mounted/mech/pulse
	heat_generation = 50

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
