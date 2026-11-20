/obj/item/projectile/bullet/pellet/fragment/hand_grenade
	damage = 35
	armor_penetration = 10

/obj/item/projectile/bullet/pellet/fragment/strong/hand_grenade
	armor_penetration = 10

/obj/item/grenade/frag
	// Increase the pellet budget for the 20 px human hitbox on a 32 px tile.
	num_fragments = 120
	fragment_types = list(/obj/item/projectile/bullet/pellet/fragment/hand_grenade = 1)

/obj/item/grenade/frag/high_yield
	num_fragments = 240
	fragment_types = list(
		/obj/item/projectile/bullet/pellet/fragment/hand_grenade = 1,
		/obj/item/projectile/bullet/pellet/fragment/strong/hand_grenade = 4
	)

/obj/item/grenade/frag/shell
	fragment_types = list(/obj/item/projectile/bullet/pellet/fragment = 1)

/obj/item/grenade/frag/makeshift
	fragment_types = list(/obj/item/projectile/bullet/pellet/fragment = 1)
