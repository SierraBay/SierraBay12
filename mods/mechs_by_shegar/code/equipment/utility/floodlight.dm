// A lot of this is copied from floodlights.
/obj/item/mech_equipment/light
	name = "floodlight"
	desc = "An mech-mounted light."
	icon_state = "mech_floodlight"
	item_state = "mech_floodlight"
	restricted_hardpoints = list(HARDPOINT_HEAD, HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)


	var/on = 0
	var/l_power = 2
	var/l_range = 6
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)

/obj/item/mech_equipment/light/installed(mob/living/exosuit/_owner)
	. = ..()
	update_icon()

/obj/item/mech_equipment/light/attack_self(mob/user)
	. = ..()
	if(.)
		toggle()
		to_chat(user, "You switch \the [src] [on ? "on" : "off"].")

/obj/item/mech_equipment/light/proc/toggle()
	on = !on
	update_icon()
	owner.update_icon()
	active = on
	passive_power_use = on ? 0.1 KILOWATTS : 0

/obj/item/mech_equipment/light/deactivate()
	if(on)
		toggle()
	..()

/obj/item/mech_equipment/light/on_update_icon()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(l_range, l_power, angle = LIGHT_WIDE)
	else
		icon_state = "[initial(icon_state)]"
		set_light(0, 0)

	//Check our layers
	if(owner && (owner.hardpoints[HARDPOINT_HEAD] == src))
		mech_layer = MECH_INTERMEDIATE_LAYER
	else mech_layer = initial(mech_layer)
