/mob/living/exosuit/premade/heavy
	name = "Heavy mech"
	desc = "A heavily armored combat mech."
	external_armor_type = /obj/item/mech_external_armor/buletproof

/mob/living/exosuit/premade/heavy/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/heavy(src)
		head.color = COLOR_TITANIUM
	if(!body)
		body = new /obj/item/mech_component/chassis/heavy(src)
		body.color = COLOR_TITANIUM
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/heavy(src)
		L_arm.color = COLOR_TITANIUM
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/heavy(src)
		R_arm.color = COLOR_TITANIUM
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/heavy(src)
		L_leg.color = COLOR_TITANIUM
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/heavy(src)
		R_leg.color = COLOR_TITANIUM
		R_leg.side = RIGHT
		R_leg.setup_side()

	. = ..()

/mob/living/exosuit/premade/heavy/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser/laser(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ion(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)

/mob/living/exosuit/premade/heavy/merc/Initialize()
	. = ..()
	if(head)
		head.color = COLOR_RED
	if(body)
		body.color = COLOR_DARK_GUNMETAL
	if(L_arm)
		L_arm.color = COLOR_RED
	if(R_arm)
		R_arm.color = COLOR_RED
	if(L_leg)
		L_leg.color = COLOR_RED
	if(R_leg)
		R_leg.color = COLOR_RED

/mob/living/exosuit/premade/heavy/merc/spawn_mech_equipment()
	install_system(new /obj/item/mech_equipment/mounted_system/taser(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/laser(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/shields(src), HARDPOINT_BACK)
