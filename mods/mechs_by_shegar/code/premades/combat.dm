/mob/living/exosuit/premade/combat
	name = "combat mech"
	desc = "A sleek, modern combat mech."
	external_armor_type = /obj/item/mech_external_armor/buletproof

/mob/living/exosuit/premade/combat/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
		head.color = COLOR_GUNMETAL
	if(!body)
		body = new /obj/item/mech_component/chassis/combat(src)
		body.color = COLOR_GUNMETAL
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/combat(src)
		L_arm.color = COLOR_GUNMETAL
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/combat(src)
		R_arm.color = COLOR_GUNMETAL
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/combat(src)
		L_leg.color = COLOR_GUNMETAL
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/combat(src)
		R_leg.color = COLOR_GUNMETAL
		R_leg.side = RIGHT
		R_leg.setup_side()

	. = ..()

/mob/living/exosuit/premade/combat/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/mounted_system/taser(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ion(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/flash(src), HARDPOINT_LEFT_SHOULDER)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)

/mob/living/exosuit/premade/combat/military
	decal = "cammo1"

/mob/living/exosuit/premade/combat/military/alpine
	decal = "cammo2"

/mob/living/exosuit/premade/combat/military/Initialize()
	. = ..()
	for(var/obj/thing in list(head,body, L_arm, R_arm, L_leg, R_leg))
		thing.color = COLOR_WHITE

/mob/living/exosuit/premade/combat/laserproof
	external_armor_type = /obj/item/mech_external_armor/laserproof
