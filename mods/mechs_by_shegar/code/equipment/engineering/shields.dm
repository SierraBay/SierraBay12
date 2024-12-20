/obj/item/mech_equipment/atmos_shields
    icon_state = "mech_power"
    heat_generation = 20

/obj/item/mech_equipment/atmos_shields/on_update_icon()
	icon_state = "mech_power"

/obj/item/mech_equipment/atmos_shields/CtrlClick(mob/user)
	if (owner && ((user in owner.pilots) || user == owner))
		if (active)
			to_chat(user, SPAN_WARNING("You cannot modify the projection mode while the shield is active."))
		else
			current_mode = !current_mode
			owner.add_heat(heat_generation)
			to_chat(user, SPAN_NOTICE("You set the shields to [current_mode ? "bubble" : "barrier"] mode."))
		return TRUE
	return ..()
