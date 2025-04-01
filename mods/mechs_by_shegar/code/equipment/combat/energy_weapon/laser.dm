/obj/item/mech_equipment/mounted_system/taser/laser
	name = "\improper CH-PS \"Immolator\" laser"
	desc = "An exosuit-mounted laser rifle. Handle with care."
	icon_state = "mech_lasercarbine"
	holding_type = /obj/item/gun/energy/lasercannon/mounted/mech
	heat_generation = 50

/obj/item/gun/energy/lasercannon/mounted/mech
	use_external_power = TRUE
	has_safety = FALSE
	self_recharge = TRUE
	fire_delay = 15
	accuracy = 2

/obj/item/mech_equipment/mounted_system/taser/laser/need_combat_skill()
	return TRUE

/obj/item/gun/energy/lasercannon/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/lasercannon/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/lasercannon/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
