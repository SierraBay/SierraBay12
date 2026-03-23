GLOBAL_LIST_EMPTY(active_leviathans)

/obj/meteor/proc/move_to_dest(target_dest, speed)
	walk_towards(src, target_dest, speed)

/obj/overmap/event/leviathan
	name = "Space Leviathan"
	icon = 'mods/leviathans/icons/leviathan.dmi'
	icon_state = "dragon" // TODO ПЛЕСХОЛДЕР!!!
	requires_contact = TRUE
	opacity = 0
	instant_contact = TRUE
	color = COLOR_RED

	var/health = 1000
	var/max_health = 1000
	var/damage = 10

	var/weakref/target_ship = null // Целевое судно, будет следовать за ним через всю овермапу
	var/manual_ai = FALSE // Если TRUE, левиафан не ищет цели сам
	var/weakref/forced_target = null // Принудительно установленная цель

	var/damage_cooldown = 10 SECONDS // КД следующего выстрела снарядом
	var/next_damage_time = 0

	var/movement_update_rate = 2 SECONDS // Как часто двигаться
	var/next_movement_update = 0

	var/leviathan_speed = 1 / (1 MINUTES) // Скорость левиафана на овермапе

	// Процессинг левиафанов
	var/processing = FALSE

	// Хил значения
	var/is_healing = FALSE // Флаг хила
	var/healing_threshold = 0.35 // Порог ХП в 35%, при котором левиафан летит лечиться
	var/weakref/healing_target_ref = null // Зона, где хилится левиафан
	var/last_heal_time = 0
	var/base_speed = 0 // Временный буфер скорости
	var/heal_min = 5 // 30 в минуту
	var/heal_max = 8 // 50 в минуту

	var/boredom_factor = 0 // На сколько увеличивается КД за каждый выстрел по стоячему судну

/obj/overmap/event/leviathan/Initialize(seed)
	. = ..(seed)
	GLOB.active_leviathans += src
	max_health = health
	base_speed = leviathan_speed

	make_movable()
	START_PROCESSING(SSobj, src)
	processing = TRUE
	find_target()

	var/image/I = image(icon, icon_state = "warning")
	I.color = COLOR_ORANGE
	I.appearance_flags = RESET_COLOR
	AddOverlays(I, ATOM_ICON_CACHE_PROTECTED)

/obj/overmap/event/leviathan/Destroy()
	GLOB.active_leviathans -= src
	if(processing)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/overmap/event/leviathan/proc/find_target()
	if(manual_ai)
		return
	// Ищем самый тяжелый/большой корабль на овермапе (обычно Сьерра)
	// и делаем его своей целью
	var/obj/overmap/visitable/ship/best_target = null
	var/best_mass = 0
	for(var/obj/overmap/visitable/ship/S in SSshuttle.ships)
		if(S.vessel_mass > best_mass)
			best_mass = S.vessel_mass
			best_target = S

	if(best_target)
		target_ship = weakref(best_target)

/obj/overmap/event/leviathan/Process()
	if(health <= 0)
		die()
		return

	handle_healing()

	if(world.time >= next_movement_update)
		update_movement()
		next_movement_update = world.time + movement_update_rate

	// Если хилимся, то приоритет на хил, атаковать не будем (кроме Роя)
	if((!is_healing || !needs_healing_location()) && world.time >= next_damage_time)
		deal_damage_to_sector()

	var/obj/overmap/O = target_ship?.resolve()
	if(istype(O) && O.is_moving())
		boredom_factor = 0

	..()

/obj/overmap/event/leviathan/proc/handle_healing()
	if(!is_healing && (health <= max_health * healing_threshold || !needs_healing_location()))
		is_healing = TRUE
		healing_target_ref = null
		// Если мало ХП, уносим ноги/щупальца/лапы
		if(needs_healing_location())
			leviathan_speed = base_speed * 2

	if(is_healing)
		if(health >= max_health && needs_healing_location())
			health = max_health
			is_healing = FALSE
			healing_target_ref = null
			if(needs_healing_location())
				leviathan_speed = base_speed
			return

		perform_healing()

/obj/overmap/event/leviathan/proc/perform_healing()
	if(world.time < last_heal_time + 10 SECONDS)
		return

	var/heal_amount = rand(heal_min, heal_max)
	health = min(health + heal_amount, max_health)
	last_heal_time = world.time

/obj/overmap/event/leviathan/proc/needs_healing_location()
	return TRUE

/obj/overmap/event/leviathan/proc/get_wrapped_dist(atom/A, atom/B)
	var/dx = abs(A.x - B.x)
	var/dy = abs(A.y - B.y)

	if(dx > GLOB.using_map.overmap_size / 2)
		dx = GLOB.using_map.overmap_size - dx
	if(dy > GLOB.using_map.overmap_size / 2)
		dy = GLOB.using_map.overmap_size - dy

	return sqrt(dx**2 + dy**2)

/obj/overmap/event/leviathan/proc/get_wrapped_dir(atom/A, atom/B)
	var/dx = B.x - A.x
	var/dy = B.y - A.y

	if(abs(dx) > GLOB.using_map.overmap_size / 2)
		dx = -SIGN(dx) * (GLOB.using_map.overmap_size - abs(dx))
	if(abs(dy) > GLOB.using_map.overmap_size / 2)
		dy = -SIGN(dy) * (GLOB.using_map.overmap_size - abs(dy))

	var/res = 0
	if(dx > 0)
		res |= EAST
	else if(dx < 0)
		res |= WEST

	if(dy > 0)
		res |= NORTH
	else if(dy < 0)
		res |= SOUTH

	return res

// Поиск ближайшего сектора для лечения
/obj/overmap/event/leviathan/proc/find_healing_target(event_type)
	var/obj/overmap/event/best_event = null
	var/best_dist = 1000
	for(var/turf/T in overmap_event_handler.hazard_by_turf)
		for(var/obj/overmap/event/E in overmap_event_handler.hazard_by_turf[T])
			if(istype(E, event_type))
				var/dist = get_wrapped_dist(src, E)
				if(dist < best_dist)
					best_dist = dist
					best_event = E
	return best_event

/obj/overmap/event/leviathan/proc/update_movement()
	var/atom/movable/current_target = null

	if(manual_ai)
		current_target = forced_target?.resolve()
	else if(is_healing && needs_healing_location())
		var/obj/overmap/H = healing_target_ref?.resolve()
		if(!H || QDELETED(H))
			H = find_healing_target()
			if(H)
				healing_target_ref = weakref(H)

		if(H)
			current_target = H
			// Если долетели до точки лечения, останавливаемся
			if(loc == H.loc)
				adjust_speed(-speed[1], -speed[2])
				update_icon()
				return
	else
		current_target = target_ship?.resolve()
		if(!current_target)
			find_target()
			current_target = target_ship?.resolve()

	if(!current_target)
		adjust_speed(-speed[1], -speed[2])
		update_icon()
		return

	// Проверка на края карты
	if(istype(get_turf(src), /turf/unsimulated/map/edge))
		handle_wraparound(x, y)
		return

	if(!is_healing && loc == current_target.loc)
		// Останавливаемся, если мы в том же секторе
		adjust_speed(-speed[1], -speed[2])
		update_icon()
		return

	var/target_dir = get_wrapped_dir(src, current_target)
	if(!target_dir)
		adjust_speed(-speed[1], -speed[2])
		update_icon()
		return

	var/dir_x = SIGN((target_dir & EAST) * 1 + (target_dir & WEST) * -1)
	var/dir_y = SIGN((target_dir & NORTH) * 1 + (target_dir & SOUTH) * -1)

	if(dir_x == 0 && dir_y == 0)
		adjust_speed(-speed[1], -speed[2])
		update_icon()
		return

	// Сбрасываем скорость перед тем, как сменить вектор направления
	adjust_speed(-speed[1], -speed[2])

	dir = target_dir
	adjust_speed(dir_x * leviathan_speed, dir_y * leviathan_speed)

/obj/overmap/event/leviathan/proc/deal_damage_to_sector()
	var/damaged_something = FALSE

	var/obj/overmap/O = (manual_ai ? forced_target?.resolve() : target_ship?.resolve())
	var/stationary = istype(O) && !O.is_moving()

	for(var/obj/overmap/visitable/ship/S in range(1, src))
		deal_ship_damage(S)
		damaged_something = TRUE

	if(damaged_something)
		if(stationary)
			boredom_factor += 0.1
		else
			boredom_factor = 0
		next_damage_time = world.time + (damage_cooldown * (1 + boredom_factor))

/obj/overmap/event/leviathan/proc/deal_ship_damage(obj/overmap/visitable/ship/S)

	return

/obj/overmap/event/leviathan/proc/get_damage_multiplier(damage_source)
	return 0 // Игнорирование урона

/obj/overmap/event/leviathan/proc/take_damage(amount, damage_source)
	var/modifier = get_damage_multiplier(damage_source)

	if(modifier <= 0)
		return

	health -= (amount * modifier)
	if(health <= 0)
		death_gasp()
		die()

// Предсмертный хрип левиафана
/obj/overmap/event/leviathan/proc/death_gasp()
	return

/obj/overmap/event/leviathan/proc/die()
	qdel(src)

// Бродкаст по соседним секторам от текущего
/proc/get_overmap_broadcast_zlevels(obj/overmap/origin, range = 1)
	var/list/z_levels = list(origin.z)
	for(var/obj/overmap/visitable/ship/S in range(range, origin))
		if(LAZYLEN(S.map_z))
			z_levels |= S.map_z
	return z_levels

/proc/overmap_narrate(list/z_levels, message)
	if(!islist(z_levels))
		z_levels = list(z_levels)

	if(!length(z_levels))
		return

	for(var/mob/M in GLOB.player_list)
		if(get_z(M) in z_levels)
			to_chat(M, FONT_LARGE(SPAN_WARNING(message)))
