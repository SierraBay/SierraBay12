#define SEC_WHITELIST_EQUIPMENT list( \
	/obj/item/mech_equipment/ballistic_shield, \
	/obj/item/mech_equipment/camera, \
	/obj/item/mech_equipment/clamp, \
	/obj/item/mech_equipment/light, \
	/obj/item/mech_equipment/mounted_system/taser/ballistic/grenade_launcher \
)

/mob/living/exosuit/premade/security
	name = "security mech"
	desc = "An old battle mech that fought in Sierra's past missions. This mech is now useless—its parts are badly worn, and it can't hold much gear. Do one last thing for it: let it die in battle for good, then build a new one."

/mob/living/exosuit/premade/security/Initialize()
	if(!head)
		head = new /obj/item/mech_component/sensors/powerloader/security(src)
		head.color = "#1c1c1c"
	if(!body)
		body = new /obj/item/mech_component/chassis/combat/security(src)
		body.color = "#1c1c1c"
	if(!L_arm)
		L_arm = new /obj/item/mech_component/manipulators/powerloader/security(src)
		L_arm.color = "#cc3300"
	if(!R_arm)
		R_arm = new /obj/item/mech_component/manipulators/powerloader/security(src)
		R_arm.color = "#cc3300"
		R_arm.side = RIGHT
		R_arm.setup_side()
	if(!L_leg)
		L_leg = new /obj/item/mech_component/propulsion/powerloader/security(src)
		L_leg.color = "#1c1c1c"
	if(!R_leg)
		R_leg = new /obj/item/mech_component/propulsion/powerloader/security(src)
		R_leg.color = "#1c1c1c"
		R_leg.side = RIGHT
		R_leg.setup_side()
	. = ..()

/obj/item/mech_component/sensors/powerloader/security
	icon_state = "combat_head"
	name = "old combat sensors array"
	exosuit_desc_string = "really old combat sensors array"
	prebuilt_software = list(/obj/item/circuitboard/exosystem/utility, /obj/item/circuitboard/exosystem/weapons)
	whitelist_equipment_paths = SEC_WHITELIST_EQUIPMENT
	component_tag = "SECURITY"
	max_heat = 200
	heat_cooling = 8

/obj/item/mech_component/chassis/combat/security
	icon_state = "combat_body"
	name = "old combat body"
	exosuit_desc_string = "really old combat body"
	power_use = 0
	climb_time = 6
	max_hp = 80
	min_damage = 75
	max_repair = 50
	repair_damage = 25
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 100
	weight = 300
	whitelist_equipment_paths = SEC_WHITELIST_EQUIPMENT
	component_tag = "SECURITY"

/obj/item/mech_component/manipulators/powerloader/security
	icon_state = "combat_arm"
	name = "old combat manipulator"
	exosuit_desc_string = "really old combat mech arm"
	whitelist_equipment_paths = SEC_WHITELIST_EQUIPMENT
	component_tag = "SECURITY"
	max_heat = 200
	heat_cooling = 8

/obj/item/mech_component/propulsion/powerloader/security
	icon_state = "combat_leg"
	name = "old combat motivator"
	exosuit_desc_string = "really old combat mech motivator"
	whitelist_equipment_paths = SEC_WHITELIST_EQUIPMENT
	component_tag = "SECURITY"
	max_heat = 200
	heat_cooling = 8


//Тоже самое что и СБ мех, но с снаряжением
/mob/living/exosuit/premade/security/equiped/spawn_mech_equipment()
	..()
	install_system(new /obj/item/mech_equipment/ballistic_shield(src), HARDPOINT_RIGHT_HAND)
	install_system(new /obj/item/mech_equipment/mounted_system/taser/ballistic/grenade_launcher(src), HARDPOINT_LEFT_HAND)
	install_system(new /obj/item/mech_equipment/camera(src), HARDPOINT_LEFT_SHOULDER)
	install_system(new /obj/item/mech_equipment/light(src), HARDPOINT_RIGHT_SHOULDER)
