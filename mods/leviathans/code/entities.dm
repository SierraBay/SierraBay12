//-------MEDUSA-------
/obj/overmap/event/leviathan/medusa
	name = "Pulsar Medusa"
	icon_state = "medusa"
	health = 1000
	leviathan_speed = 1 / (25 SECONDS)
	weaknesses = OVERMAP_WEAKNESS_EMP
	damage_cooldown = 30 SECONDS
	events = list(/datum/event/electrical_storm)
	color = COLOR_SKY_BLUE
	heal_min = 5
	heal_max = 10

/obj/overmap/event/leviathan/medusa/deal_ship_damage(obj/overmap/visitable/ship/S)
	if(LAZYLEN(S.map_z))
		var/z_target = pick(S.map_z)
		spawn_meteor(list(/obj/meteor/supermatter/medusa = 1), pick(NORTH, SOUTH, EAST, WEST), z_target)

/obj/overmap/event/leviathan/medusa/death_gasp()
	overmap_narrate(get_overmap_broadcast_zlevels(src, 1), "The Pulsar Medusa has collapsed into a black hole, leaving dark matter influx.")
	new /obj/overmap/event/gravity(loc)

/obj/overmap/event/leviathan/medusa/find_healing_target()
	return ..(/obj/overmap/event/electric)

/obj/overmap/event/leviathan/medusa/perform_healing()
	if(locate(/obj/overmap/event/electric) in loc)
		..()

// -------DRAGON-------
/obj/overmap/event/leviathan/dragon
	name = "Space Dragon"
	icon_state = "dragon"
	health = 1500
	damage_cooldown = 40 SECONDS
	leviathan_speed = 1 / (20 SECONDS)
	weaknesses = OVERMAP_WEAKNESS_EXPLOSIVE
	color = COLOR_SEDONA
	heal_min = 10
	heal_max = 15
	events = list(/datum/event/dragon)

/datum/event/dragon
	has_skybox_image = TRUE

/datum/event/dragon/get_skybox_image()
	var/image/res = overlay_image('mods/leviathans/icons/background.dmi', "dragon", RESET_COLOR)
	res.blend_mode = BLEND_OVERLAY
	return res

/obj/overmap/event/leviathan/dragon/deal_ship_damage(obj/overmap/visitable/ship/S)
	if(LAZYLEN(S.map_z))
		var/z_target = pick(S.map_z)
		spawn_meteor(list(/obj/meteor/leviathan_fireball = 1), pick(NORTH, SOUTH, EAST, WEST), z_target)

/obj/overmap/event/leviathan/dragon/death_gasp()
	overmap_narrate(get_overmap_broadcast_zlevels(src, 1), "The Space Dragon's remains have shattered into a thousand burning fragments, triggering a meteor shower.")
	new /obj/overmap/event/meteor(loc)

/obj/overmap/event/leviathan/dragon/find_healing_target()
	return ..(/obj/overmap/event/meteor)

/obj/overmap/event/leviathan/dragon/perform_healing()
	if(locate(/obj/overmap/event/meteor) in loc)
		..()

// -------SWARM-------
/obj/overmap/event/leviathan/swarm
	name = "Autonomous Drone Swarm"
	icon_state = "swarm"
	health = 1200
	damage_cooldown = 1 MINUTE
	leviathan_speed = 1 / (15 SECONDS)
	weaknesses = OVERMAP_WEAKNESS_EMP | OVERMAP_WEAKNESS_EXPLOSIVE
	color = COLOR_DARK_BLUE_GRAY
	heal_min = 10
	heal_max = 20

/obj/overmap/event/leviathan/swarm/deal_ship_damage(obj/overmap/visitable/ship/S)
	if(LAZYLEN(S.map_z))
		var/z_target = pick(S.map_z)
		spawn_meteors(rand(2, 4), list(/obj/meteor/drone_pod = 1), pick(NORTH, SOUTH, EAST, WEST), z_target)

/obj/overmap/event/leviathan/swarm/death_gasp()
	overmap_narrate(get_overmap_broadcast_zlevels(src, 1), "The Drone Swarm's central core has overloaded and detonated, leaving a lingering electrical storm.")
	new /obj/overmap/event/electric(loc)

/obj/overmap/event/leviathan/swarm/needs_healing_location()
	return FALSE
