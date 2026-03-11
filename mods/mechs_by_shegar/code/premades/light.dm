/mob/living/exosuit/premade/light
	name = "light mech"
	desc = "A light and agile mech."

/mob/living/exosuit/premade/light/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/light(src)
		head.color = COLOR_OFF_WHITE
	if(!body)
		body = new /obj/item/mech_component/chassis/light(src)
		body.color = COLOR_OFF_WHITE
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/light(src)
		L_arm.color = COLOR_OFF_WHITE
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/light(src)
		R_arm.color = COLOR_OFF_WHITE
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/light(src)
		L_leg.color = COLOR_OFF_WHITE
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/light(src)
		R_leg.color = COLOR_OFF_WHITE
		R_leg.side = RIGHT
		R_leg.setup_side()

	. = ..()

/mob/living/exosuit/premade/light/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/catapult(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/sleeper(src), HARDPOINT_BACK)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_HEAD)
