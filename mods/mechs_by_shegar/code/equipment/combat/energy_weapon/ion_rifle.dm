/obj/item/mech_equipment/mounted_system/taser/ion
	name = "mounted ion rifle"
	desc = "An exosuit-mounted ion rifle. Handle with care."
	icon_state = "mech_ionrifle"
	holding_type = /obj/item/gun/energy/ionrifle/mounted/mech
	heat_generation = 20

/obj/item/gun/energy/ionrifle/mounted/mech
	use_external_power = TRUE
	has_safety = FALSE
	self_recharge = TRUE

/obj/item/mech_equipment/mounted_system/taser/ion/need_combat_skill()
	return TRUE

/obj/item/gun/energy/ionrifle/mounted/mech
	var/obj/item/mech_equipment/mounted_system/melee/holder

/obj/item/gun/energy/ionrifle/mounted/mech/Initialize()
	.=..()
	holder = loc

/obj/item/gun/energy/ionrifle/mounted/mech/handle_post_fire()
	.=..()
	holder.owner.add_heat(holder.heat_generation)
