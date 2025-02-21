/datum/species/adherent/New()
	. = ..()
	brute_mod = 0.8
	burn_mod =  0.8
	natural_armour_values = list(
		melee = ARMOR_MELEE_RESISTANT,
		laser = ARMOR_LASER_SMALL,
		bullet = ARMOR_BALLISTIC_MINOR,
		bomb = ARMOR_BOMB_PADDED
		)
