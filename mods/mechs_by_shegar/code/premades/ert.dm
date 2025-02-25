/mob/living/exosuit/premade/ert
	name = "Nanotrasen special combat mech"
	desc = "A sleek, modern combat mech."

/mob/living/exosuit/premade/ert/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
		head.color = COLOR_WHITE
	if(!body)
		body = new /obj/item/mech_component/chassis/combat/ert(src)
		body.color = COLOR_WHITE
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/combat(src)
		R_arm.color = COLOR_CYAN_BLUE
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/combat(src)
		L_arm.color = COLOR_CYAN_BLUE
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/combat(src)
		R_leg.color = COLOR_CYAN_BLUE
		R_leg.side = RIGHT
		R_leg.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/combat(src)
		L_leg.color = COLOR_CYAN_BLUE
	//Выдаём батарею и броню покруче
	. = ..()

/obj/item/mech_component/chassis/combat/ert/prebuild()
	. = ..()
	QDEL_NULL(cell)
	QDEL_NULL(m_armour)
	cell = new /obj/item/cell/hyper(src)
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/em(src)


/mob/living/exosuit/premade/ert/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/autoshotgun(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/laser(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/flash(src), HARDPOINT_LEFT_SHOULDER)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
