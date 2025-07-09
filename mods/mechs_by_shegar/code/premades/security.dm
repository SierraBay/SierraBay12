#define SEC_WHITELIST_EQUIPMENT list( \
	/obj/item/mech_equipment/ballistic_shield, \
	/obj/item/mech_equipment/camera, \
	/obj/item/mech_equipment/clamp, \
	/obj/item/mech_equipment/catapult, \
	/obj/item/mech_equipment/light, \
	/obj/item/mech_equipment/mounted_system/taser/ballistic/grenade_launcher, \
	/obj/item/mech_equipment/mounted_system/taser/ballistic/launcher/security, \
	/obj/item/mech_equipment/mounted_system/taser, \
	/obj/item/mech_equipment/flash \
)

/mob/living/exosuit/premade/security
	name = "security mech"
	desc = "An old battle mech that fought in Sierra's past missions. This mech is now useless—its parts are badly worn, and it can't hold much gear. Do one last thing for it: let it die in battle for good, then build a new one."
	external_armor_type = /obj/item/mech_external_armor/civil

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
	can_have_external_armour = FALSE
	armour_can_be_removed = FALSE
	armour_can_be_installed = FALSE

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
	can_have_external_armour = FALSE
	armour_can_be_removed = FALSE

/obj/item/mech_component/manipulators/powerloader/security
	icon_state = "combat_arm"
	name = "old combat manipulator"
	exosuit_desc_string = "really old combat mech arm"
	whitelist_equipment_paths = SEC_WHITELIST_EQUIPMENT
	component_tag = "SECURITY"
	max_heat = 200
	heat_cooling = 8
	can_have_external_armour = FALSE
	armour_can_be_removed = FALSE

/obj/item/mech_component/propulsion/powerloader/security
	icon_state = "combat_leg"
	name = "old combat motivator"
	exosuit_desc_string = "really old combat mech motivator"
	whitelist_equipment_paths = SEC_WHITELIST_EQUIPMENT
	component_tag = "SECURITY"
	max_heat = 200
	heat_cooling = 8
	can_have_external_armour = FALSE
	armour_can_be_removed = FALSE


//Спавнер для камеры, ибо вы не поверите, камера руинит юнит тесты
/obj/item/camera_package
	name = "Packaged equipment"
	desc = "With some reason, this equipment was packaged."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "case"


/obj/item/camera_package/attack_self(mob/living/user)
	. = ..()
	new /obj/item/mech_equipment/camera(get_turf(src))
	qdel(src)

//Нелетальный ракетомёт
/obj/item/mech_equipment/mounted_system/taser/ballistic/launcher/security
	name = "\improper  \"SHAI-TAN\" missle launcher system"
	desc = "Somewhen, thats was first missle launch system for mechs. Now, thats just a history. Can't support modern combat rockets"
	holding_type = /obj/item/gun/projectile/automatic/rocket_launcher/security

/obj/item/gun/projectile/automatic/rocket_launcher/security
	name = "SHAI-TAN"
	white_list_ammo_types = list(/obj/item/ammo_casing/rocket/mech/flashbang, /obj/item/ammo_casing/rocket/mech/pepper)
