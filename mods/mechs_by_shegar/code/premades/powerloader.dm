/mob/living/exosuit/premade/powerloader
	name = "power loader"
	desc = "An ancient, but well-liked cargo handling mech."

/mob/living/exosuit/premade/powerloader/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/powerloader(src)
		head.color = "#ffbc37"
	if(!body)
		body = new /obj/item/mech_component/chassis/powerloader(src)
		body.color = "#ffbc37"
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/powerloader(src)
		L_arm.color = "#ffbc37"
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/powerloader(src)
		R_arm.color = "#ffbc37"
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/powerloader(src)
		L_leg.color = "#ffbc37"
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/powerloader(src)
		R_leg.color = "#ffbc37"
		R_leg.side = RIGHT
		R_leg.setup_side()

	. = ..()

/mob/living/exosuit/premade/powerloader/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/drill/steel(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/clamp(src), HARDPOINT_RIGHT_HAND)

/mob/living/exosuit/premade/powerloader/mechete/Initialize()
	. = ..()
	if (head)
		head.color = "#6c8aaf"
	if (body)
		body.color = "#6c8aaf"
	if (L_arm)
		L_arm.color = "#6c8aaf"
	if (R_arm)
		R_arm.color = "#6c8aaf"
	if (L_leg)
		L_leg.color = "#6c8aaf"
	if (R_leg)
		R_leg.color = "#6c8aaf"

/mob/living/exosuit/premade/powerloader/mechete/spawn_mech_equipment()
	install_system(new /obj/item/mech_equipment/ballistic_shield(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/melee/mechete(src), HARDPOINT_RIGHT_HAND)


/mob/living/exosuit/premade/powerloader/flames_red
	name = "APLU \"Firestarter\""
	desc = "An ancient, but well-liked cargo handling mech. This one has cool red flames."
	decal = "flames_red"

/mob/living/exosuit/premade/powerloader/flames_blue
	name = "APLU \"Burning Chrome\""
	desc = "An ancient, but well-liked cargo handling mech. This one has cool blue flames."
	decal = "flames_blue"


/mob/living/exosuit/premade/firefighter
	name = "firefighting mech"
	desc = "A mix and match of industrial parts designed to withstand fires."


/mob/living/exosuit/premade/firefighter/Initialize(mapload)
	if(!head)
		head = new /obj/item/mech_component/sensors/powerloader(src)
		head.color = "#385b3c"
	if(!body)
		body = new /obj/item/mech_component/chassis/heavy(src)
		body.color = "#385b3c"
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/powerloader(src)
		L_arm.color = "#385b3c"
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/powerloader(src)
		R_arm.color = "#385b3c"
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/powerloader(src)
		L_leg.color = "#385b3c"
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/powerloader(src)
		R_leg.color = "#385b3c"
		R_leg.side = RIGHT
		R_leg.setup_side()

	. = ..()

	material = SSmaterials.get_material_by_name(MATERIAL_OSMIUM_CARBIDE_PLASTEEL)


/mob/living/exosuit/premade/firefighter/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/drill/steel(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/extinguisher(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/atmos_shields(src), HARDPOINT_BACK)

/mob/living/exosuit/premade/powerloader/old
	name = "weathered power loader"
	desc = "An ancient, but well-liked cargo handling mech. The paint is starting to flake. Perhaps some maintenance is in order?"

/mob/living/exosuit/premade/powerloader/old/Initialize()
	. = ..()
	var/list/parts = list(head,body, L_arm, R_arm, L_leg, R_leg)
	//Damage it
	var/obj/item/mech_component/damaged = pick(parts)
	damaged.take_brute_damage((damaged.max_hp / 4 ) * MECH_COMPONENT_DAMAGE_DAMAGED)
	if(prob(33))
		parts -= damaged
		damaged = pick(parts)
		damaged.take_brute_damage((damaged.max_hp / 4 ) * MECH_COMPONENT_DAMAGE_DAMAGED)

/mob/living/exosuit/premade/powerloader/old/spawn_mech_equipment()
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_HEAD)
	install_system(new /obj/item/mech_equipment/clamp(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/clamp(src), HARDPOINT_RIGHT_HAND)
