/*
	Встроенная броня меха: она есть у каждого меха и ни на что не навешивается. От пуль и лучей
	она не защищает — это дело внешних бронеэлементов (`external_armor/_external_armour.dm`).

	Внутренние бронеплиты выведены из игры: в корпусе под них больше нет места.
*/
/mob/living/exosuit
	///Встроенная броня, list(ключ брони = рейтинг). Её получает каждый мех при создании
	var/list/mech_basic_armour = list(
		melee = ARMOR_MELEE_MAJOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)

/datum/extension/armor/mech
	under_armor_mult = 0.3

//Сами бронеплиты оставлены пустышками без брони: они лежат на картах
/obj/item/robot_parts/robot_component/armour/exosuit
	name = "exosuit armour plating"
	desc = "A pair of flexible armor plates, once used to protect the internals of exosuits and their pilots."
	origin_tech = list(TECH_MATERIAL = 1)

/obj/item/robot_parts/robot_component/armour/exosuit/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("It is obsolete: modern exosuits have no slot for internal plating and carry their armour outside."))

/obj/item/robot_parts/robot_component/armour/exosuit/radproof
	name = "radiation-proof armour plating"
	desc = "A fully enclosed radiation hardened shell once designed to protect the pilot from radiation."
	icon_state = "armor_r"
	icon_state_broken = "armor_r_broken"
	origin_tech = list(TECH_MATERIAL = 3)

/obj/item/robot_parts/robot_component/armour/exosuit/em
	name = "EM-shielded armour plating"
	desc = "A shielded plating once used to surround exosuit electronics and protect them from electromagnetic radiation."
	icon_state = "armor_e"
	icon_state_broken = "armor_e_broken"
	origin_tech = list(TECH_MATERIAL = 3)

/obj/item/robot_parts/robot_component/armour/exosuit/combat
	name = "heavy combat plating"
	desc = "Plating once designed to deflect incoming attacks and explosions."
	icon_state = "armor_c"
	icon_state_broken = "armor_c_broken"
	origin_tech = list(TECH_MATERIAL = 5)
