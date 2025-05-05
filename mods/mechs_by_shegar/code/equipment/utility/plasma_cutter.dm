/obj/item/mech_equipment/mounted_system/taser/plasma
	name = "mounted plasma cutter"
	desc = "An industrial plasma cutter mounted onto the chassis of the mech. "
	icon_state = "mech_plasma"
	holding_type = /obj/item/gun/energy/plasmacutter/mounted/mech
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND, HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	origin_tech = list(TECH_MATERIAL = 4, TECH_PHORON = 4, TECH_ENGINEERING = 6, TECH_COMBAT = 3)
	disturb_passengers = TRUE
	icon_state = "railauto"
	heat_generation = 15

/obj/item/mech_equipment/mounted_system/taser/plasma/need_combat_skill()
	return FALSE


/obj/item/gun/energy/plasmacutter/mounted/mech
	use_external_power = FALSE
	has_safety = FALSE
	max_shots = 20

/obj/item/gun/energy/plasmacutter/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/plasmacutter/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/plasmacutter/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
