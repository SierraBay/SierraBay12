/mob/living/exosuit
	///У всех мехов есть такая защита.
	var/list/mech_basic_armour = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)

/datum/extension/armor/mech
	under_armor_mult = 0.3

//Ниже обьекты которые просто не работают, для тестов
/obj/item/robot_parts/robot_component/armour/exosuit/combat

	name = "exosuit armour plating"
	desc = "A pair of flexible armor plates, used to protect the internals of exosuits and its pilot."

/obj/item/robot_parts/robot_component/armour/exosuit/radproof
	name = "radiation-proof armour plating"
	desc = "A fully enclosed radiation hardened shell designed to protect the pilot from radiation."
	icon_state = "armor_r"
	icon_state_broken = "armor_r_broken"

/obj/item/robot_parts/robot_component/armour/exosuit/em
	name = "EM-shielded armour plating"
	desc = "A shielded plating that sorrounds the eletronics and protects them from electromagnetic radiation."
	icon_state = "armor_e"
	icon_state_broken = "armor_e_broken"

/obj/item/robot_parts/robot_component/armour/exosuit/combat
	name = "heavy combat plating"
	desc = "Plating designed to deflect incoming attacks and explosions."
	icon_state = "armor_c"
	icon_state = "armor_c_broken"
