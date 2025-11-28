/obj/item/mech_equipment/mounted_system/taser
	name = "mounted electrolaser carbine"
	desc = "A dual fire mode electrolaser system connected to the mech targetting system."
	icon_state = "mech_taser"
	holding_type = /obj/item/gun/energy/taser/carbine/mounted/mech
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)
	heat_generation = 10

/obj/item/gun/energy/taser/carbine/mounted/mech
	use_external_power = TRUE
	has_safety = FALSE
	self_recharge = TRUE
	burst = 1
	projectile_type = /obj/item/projectile/beam/stun
	firemodes = list(
		list("mode_name" = "stun", "projectile_type" =  /obj/item/projectile/beam/stun),
		list("mode_name" = "shock", "projectile_type" =  /obj/item/projectile/energy/electrode),
		)


/obj/item/mech_equipment/mounted_system/taser/need_combat_skill()
	return TRUE

/obj/item/gun/energy/taser/carbine/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/taser/carbine/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)

/obj/item/gun/energy/taser/carbine/mounted/mech/Initialize()
	.=..()
	holder = loc
