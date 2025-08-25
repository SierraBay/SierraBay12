/mob/living/exosuit/premade/foundation
	name = "Orange Suit"
	desc = "A streamlined exosuit with orange armor plates."
	external_armor_type = /obj/item/mech_external_armor/buletproof

/mob/living/exosuit/premade/foundation/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
		head.color = COLOR_DARK_ORANGE
	if(!body)
		body = new /obj/item/mech_component/chassis/combat/foundation(src)
		body.color = COLOR_DARK_ORANGE
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/combat(src)
		R_arm.color = COLOR_DARK_ORANGE
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/combat(src)
		L_arm.color = COLOR_DARK_ORANGE
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/combat(src)
		R_leg.color = COLOR_DARK_ORANGE
		R_leg.side = RIGHT
		R_leg.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/combat(src)
		L_leg.color = COLOR_DARK_ORANGE
	//Выдаём батарею и броню покруче
	. = ..()

/obj/item/mech_component/chassis/combat/foundation/prebuild()
	. = ..()
	QDEL_NULL(cell)
	cell = new /obj/item/cell/hyper(src)


/mob/living/exosuit/premade/foundation/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/autoshotgun(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/laser(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/flash(src), HARDPOINT_LEFT_SHOULDER)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
