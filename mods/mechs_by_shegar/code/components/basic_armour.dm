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
