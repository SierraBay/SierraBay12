/mob/living/exosuit/premade/merc
	name = "Mercenary exosuit"
	desc = "A sleek, modern combat exosuit."

/mob/living/exosuit/premade/merc/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/combat(src)
		arms.color = COLOR_RED
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/combat(src)
		legs.color = COLOR_RED
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
		head.color = COLOR_RED
	if(!body)
		body = new /obj/item/mech_component/chassis/combat/merc(src)
		body.color = COLOR_RED
	. = ..()

/obj/item/mech_component/chassis/combat/merc/prebuild()
	. = ..()
	QDEL_NULL(cell)
	QDEL_NULL(m_armour)
	cell = new /obj/item/cell/hyper(src)
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/em(src)

/mob/living/exosuit/premade/merc/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/pulse(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/flash(src), HARDPOINT_LEFT_SHOULDER)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
