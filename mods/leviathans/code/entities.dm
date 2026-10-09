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

// -------BRETHREN MOON-------
/obj/overmap/event/leviathan/brethren_moon
	name = "Brethren Moon"
	icon_state = "moon"
	health = 2000
	max_health = 2000
	damage_cooldown = 2 MINUTES
	leviathan_speed = 1 / (30 SECONDS)
	weaknesses = OVERMAP_WEAKNESS_FIRE | OVERMAP_WEAKNESS_EXPLOSIVE
	color = COLOR_MAROON

	var/biomass_collected = 0
	var/biomass_per_necromorph = 35
	var/max_necromorphs = 40
	var/necromorphs_per_spawn = 8
	var/hp_per_corpse = 10

	var/list/necromorph_types = list(
		/mob/living/simple_animal/hostile/meat/strippedhuman,
		/mob/living/simple_animal/hostile/meat/horror,
		/mob/living/simple_animal/hostile/meat/horrorsmall,
		/mob/living/simple_animal/hostile/meat/horrorminer,
		/mob/living/simple_animal/hostile/meat/humansecurity,
		/mob/living/simple_animal/hostile/meat/abomination
	)

	var/list/announced_ships = list()
	var/list/spawned_ships = list()

/obj/overmap/event/leviathan/brethren_moon/deal_ship_damage(obj/overmap/visitable/ship/S)
	if(!LAZYLEN(S.map_z))
		return

	collect_biomass(S)
	spawn_necromorphs(S)

/obj/overmap/event/leviathan/brethren_moon/proc/collect_biomass(obj/overmap/visitable/ship/S)
	var/corpses_collected = 0
	var/total_biomass = 0

	for(var/z_level in S.map_z)
		for(var/mob/living/M in SSmobs.mob_list)
			if(M.z != z_level)
				continue

			if(M.stat != DEAD)
				continue

			if(istype(M, /mob/living/simple_animal/hostile/meat))
				continue

			var/mob_biomass = 0
			if(ishuman(M))
				mob_biomass = 100
			else if(istype(M, /mob/living/carbon))
				mob_biomass = 80
			else if(istype(M, /mob/living/simple_animal))
				mob_biomass = 30
			else
				mob_biomass = 20

			total_biomass += mob_biomass
			corpses_collected++

			health = min(health + hp_per_corpse, max_health)

			var/turf/T = get_turf(M)
			if(T)
				new /obj/decal/cleanable/blood(T)
				if(prob(30))
					new /obj/decal/cleanable/blood/splatter(T)

			qdel(M)

	if(corpses_collected > 0)
		biomass_collected += total_biomass

		if(!(S in announced_ships))
			announced_ships += S
			command_announcement.Announce(
				"ВНИМАНИЕ! Биосканеры фиксируют аномальную активность. Обнаружено исчезновение [corpses_collected] биологических сигнатур. \
				Системы жизнеобеспечения регистрируют необъяснимые флуктуации органического материала. \
				Рекомендуется немедленная проверка всех палуб медицинским персоналом.",
				"Система мониторинга жизнеобеспечения [S.name]",
				msg_sanitized = 0,
				zlevels = S.map_z
			)

/obj/overmap/event/leviathan/brethren_moon/proc/spawn_necromorphs(obj/overmap/visitable/ship/S)
	if(biomass_collected < biomass_per_necromorph)
		return

	var/existing_necromorphs = 0
	for(var/z_level in S.map_z)
		for(var/mob/living/simple_animal/hostile/meat/N in SSmobs.mob_list)
			if(N.z == z_level)
				existing_necromorphs++

	if(existing_necromorphs >= max_necromorphs)
		return

	var/necromorphs_to_spawn = min(
		floor(biomass_collected / biomass_per_necromorph),
		max_necromorphs - existing_necromorphs,
		necromorphs_per_spawn
	)

	if(necromorphs_to_spawn <= 0)
		return

	for(var/i = 1 to necromorphs_to_spawn)
		var/z_target = pick(S.map_z)
		spawn_necromorph_on_zlevel(z_target)
		biomass_collected -= biomass_per_necromorph

/obj/overmap/event/leviathan/brethren_moon/proc/spawn_necromorph_on_zlevel(z_level)
	var/list/spawn_turfs = list()

	for(var/turf/simulated/floor/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		var/area/A = get_area(T)
		if(!A || istype(A, /area/crew_quarters/sleep) || istype(A, /area/bridge) || istype(A, /area/medical))
			continue

		if(T.density)
			continue

		var/has_mobs_nearby = FALSE
		for(var/mob/living/L in range(7, T))
			has_mobs_nearby = TRUE
			break

		if(!has_mobs_nearby)
			spawn_turfs += T

	if(!LAZYLEN(spawn_turfs))
		for(var/turf/simulated/floor/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
			if(!T.density)
				spawn_turfs += T
				if(length(spawn_turfs) > 50)
					break

	if(LAZYLEN(spawn_turfs))
		var/turf/spawn_turf = pick(spawn_turfs)
		var/mob_type = pick(necromorph_types)
		new mob_type(spawn_turf)

/obj/overmap/event/leviathan/brethren_moon/death_gasp()
	var/list/affected_ships = list()
	for(var/obj/overmap/visitable/ship/S in range(1, src))
		affected_ships += S

	if(LAZYLEN(affected_ships))
		for(var/obj/overmap/visitable/ship/S in affected_ships)
			command_announcement.Announce(
				"Критическая аномалия в секторе устранена. Массивный биологический объект прекратил существование. \
				Сенсоры фиксируют остаточное электромагнитное излучение в окрестностях. \
				Рекомендуется соблюдать осторожность при навигации в данном секторе.",
				"Навигационная система [S.name]",
				msg_sanitized = 0,
				zlevels = S.map_z
			)

	new /obj/overmap/event/electric(loc)

/obj/overmap/event/leviathan/brethren_moon/needs_healing_location()
	return FALSE
