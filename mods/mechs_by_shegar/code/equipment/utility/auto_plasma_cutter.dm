/obj/item/mech_equipment/mounted_system/taser/autoplasma
	icon_state = "mech_energy"
	holding_type = /obj/item/gun/energy/plasmacutter/mounted/mech/auto
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	origin_tech = list(TECH_MATERIAL = 5, TECH_PHORON = 4, TECH_ENGINEERING = 6, TECH_COMBAT = 4)
	heat_generation = 20

/obj/item/mech_equipment/mounted_system/taser/autoplasma/need_combat_skill()
	return FALSE

/obj/item/gun/energy/plasmacutter/mounted/mech/auto
	charge_cost = 13
	name = "rotatory plasma cutter"
	desc = "A state of the art rotating, variable intensity, sequential-cascade plasma cutter. Resist the urge to aim this at your coworkers."
	max_shots = 15
	firemodes = list(
		list("mode_name" = "single shot",	can_autofire=0, burst=1, fire_delay=6,  dispersion = list(0.0)),
		list("mode_name" = "full auto",		can_autofire=1, burst=1, fire_delay=1, burst_accuracy = list(0,-1,-1,-1,-1,-2,-2,-2), dispersion = list(1.0, 1.0, 1.0, 1.0, 1.1)),
		)
