/obj/machinery/computer/ship/ship_weapon/beam_cannon/fire(mob/user)
	set waitfor = FALSE
	if(!link_parts())
		return FALSE //no disperser, no service
	if(!front.powered() || !middle.powered() || !back.powered())
		return FALSE //no power, no boom boom

	var/turf/start = front
	var/direction = front.dir

	if(prefire_sound)
		playsound(start, prefire_sound, 250, 0)

	var/list/relevant_z = GetConnectedZlevels(start.z)
	if(far_prefire_sound)
		for(var/mob/M in GLOB.player_list)
			var/turf/T = get_turf(M)
			if(!T || !(T.z in relevant_z))
				continue
			if(!isdeaf(M))
				sound_to(M, sound(far_prefire_sound, volume=10))

	back.change_power_consumption(ammo_per_shot, POWER_USE_IDLE)

	sleep(fire_delay)

	back.change_power_consumption(initial(back.idle_power_usage), POWER_USE_IDLE)

	if(!front || !front.powered()) //Meanwhile front might have exploded
		return FALSE

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in relevant_z))
			continue
		shake_camera(M, shake_camera_force)
		if(!isdeaf(M))
			sound_to(M, sound(far_fire_sound, volume=10))

	playsound(start, fire_sound, 250, 1)
	handle_muzzle(start, direction)

	if(!front) //Meanwhile front might have exploded
		return

	for(var/turf/T in getline(get_step(front,front.dir),get_edge_turf(start, direction)))
		if(T.density && !istype(T, /turf/simulated/planet_edge) && !ignore_blockage)
			return TRUE
		for(var/atom/A in T)
			if(((A.density && A.layer != TABLE_LAYER) && !istype(A, /obj/item/projectile) && (!istype(A, /obj/effect) || istype(A, /obj/shield))))
				if(istype(A, /obj/shield))
					var/obj/shield/S = A
					if(S.gen.check_flag(shield_modflag_counter))
						return TRUE
				if(!ignore_blockage)
					return TRUE

	var/turf/target_turf
	if(linked.z == 12)
		target_turf = get_turf(linked)
		for(var/i = 1 to shoot_range)
			target_turf = get_step(target_turf, overmapdir)

	else
		target_turf = get_turf(linked.loc)
		for(var/i = 1 to shoot_range)
			target_turf = get_step(target_turf, overmapdir)

	var/turf/overmaptarget = target_turf
	var/list/candidates = list()

	//Next we see if there are any targets around. Logically they are between us and the sector if one exists.

	if(!length(candidates))
		for(var/obj/overmap/visitable/ship/S in overmaptarget)
			if(S == linked)
				continue //Why are you shooting yourself?
			candidates += S

	if(!length(candidates))
		for(var/obj/overmap/projectile/M in overmaptarget)
			candidates += M

	if(!length(candidates))
		for(var/obj/overmap/visitable/sector/O in overmaptarget)
			if(O == linked)
				continue //Why are you shooting yourself?
			if(O.sector_flags & OVERMAP_SECTOR_UNTARGETABLE || istype(O,/obj/overmap/visitable/sector/exoplanet))
				continue
			candidates += O

//		for(var/obj/overmap/trading/T in overmaptarget) TODO: OVERMAP_TRADERS
//			candidates += T

	if(!length(candidates) && destroy_event_flags)
		for(var/obj/overmap/event/E in overmaptarget)
			candidates += E

	if(!length(candidates))
		for(var/obj/overmap/visitable/sector/exoplanet/P in overmaptarget)
			candidates += P

	//Way to waste a charge
	if(!length(candidates))
		handle_overbeam()
		return TRUE

	var/obj/overmap/target = pick(candidates)

//	if(istype(target, /obj/overmap/trading)) TODO: OVERMAP_TRADERS
//		qdel(target)
//		return TRUE

	if(istype(target, /obj/overmap/event))
		var/obj/overmap/event/E = target
		if(destroy_event_flags & E.weaknesses)
			var/turf/T = E.loc
			qdel(E)
			overmap_event_handler.update_hazards(T)
		handle_overbeam()
		return TRUE

	if(istype(target, /obj/overmap/projectile))
		if(prob(100 - cal_accuracy() / 2))
			target.Destroy()
		handle_overbeam()
		return TRUE

	var/obj/overmap/visitable/finaltarget = target
	var/z_level = pick(finaltarget.map_z)

	//Success, but we missed.
	if(prob(100 - cal_accuracy()) && !istype(finaltarget, /obj/overmap/visitable/sector/exoplanet))
		log_and_message_admins("Âûñòðåë îò [linked.name] èç [gun_name] åáàíóë [finaltarget.name], íî êàëèáðîâêà áûëà ãîâíîì (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[linked.x];Y=[linked.y];Z=[linked.z]'>MAP</a>)", location=get_turf(front))
		handle_overbeam(TRUE)
		return TRUE

	if(istype(finaltarget, /obj/overmap/visitable/sector/exoplanet))
		fire_at_exoplanet(z_level, finaltarget)
	else
		var/fore_dir = SOUTH
		if(istype(finaltarget, /obj/overmap/visitable/ship))
			var/obj/overmap/visitable/ship/target_ship = finaltarget
			fore_dir = target_ship.fore_dir
		fire_at_sector(z_level, fore_dir, finaltarget)

	handle_overbeam()

	return TRUE

/obj/machinery/computer/ship/ship_weapon/beam_cannon/proc/fire_at_sector(z_level, target_fore_dir, obj/overmap/target, firing_at_exoplanet = FALSE)
	var/heading = overmapdir

	if(!heading)
		heading = pick(GLOB.cardinal)

	var/start_x = floor(world.maxx / 2) + rand(-pew_spread/2, pew_spread/2)
	var/start_y = floor(world.maxy / 2) + rand(-pew_spread/2, pew_spread/2)

	if(firing_at_exoplanet)
		start_x = floor(rand(8,world.maxx-8))
		start_y = floor(rand(8,world.maxy-8))

	//Normalize killing people :D
	if(heading in GLOB.cornerdirs)
		if(heading == NORTHEAST)
			heading = pick(NORTH, EAST)
		if(heading == NORTHWEST)
			heading = pick(NORTH, WEST)
		if(heading == SOUTHEAST)
			heading = pick(SOUTH, EAST)
		if(heading == SOUTHWEST)
			heading = pick(SOUTH, WEST)

	if(target.dir in GLOB.cornerdirs)
		if(target.dir == NORTHEAST)
			target.dir = pick(NORTH, EAST)
		if(target.dir == NORTHWEST)
			target.dir = pick(NORTH, WEST)
		if(target.dir == SOUTHEAST)
			target.dir = pick(SOUTH, EAST)
		if(target.dir == SOUTHWEST)
			target.dir = pick(SOUTH, WEST)

	if(heading == target.dir)
		if(target_fore_dir == NORTH)
			start_y = TRANSITIONEDGE + 2
			heading = NORTH
		else if(target_fore_dir == SOUTH)
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH
		else if(target_fore_dir == WEST)
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST
		else
			start_x = TRANSITIONEDGE + 2
			heading = EAST

	else if(heading == GLOB.reverse_dir[target.dir])
		if(target_fore_dir == NORTH)
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH
		else if(target_fore_dir == SOUTH)
			start_y = TRANSITIONEDGE + 2
			heading = NORTH
		else if(target_fore_dir == WEST)
			start_x = TRANSITIONEDGE + 2
			heading = EAST
		else
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST

	else if(heading == GLOB.cw_dir[target.dir])
		if(target_fore_dir == NORTH)
			start_x = TRANSITIONEDGE + 2
			heading = EAST
		else if(target_fore_dir == SOUTH)
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST
		else if(target_fore_dir == WEST)
			start_y = TRANSITIONEDGE + 2
			heading = NORTH
		else
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH

	else if(heading == GLOB.ccw_dir[target.dir])
		if(target_fore_dir == NORTH)
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST
		else if(target_fore_dir == SOUTH)
			start_x = TRANSITIONEDGE + 2
			heading = EAST
		else if(target_fore_dir == WEST)
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH
		else
			start_y = TRANSITIONEDGE + 2
			heading = NORTH

	var/turf/start = locate(start_x, start_y, z_level)

	log_and_message_admins("Луч от [linked.name], выпущенный из [gun_name] - успешно попал в [target.name] на Z [z_level] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[start_x];Y=[start_y];Z=[z_level]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[linked.x];Y=[linked.y];Z=[linked.z]'>MAP</a>)")

	var/list/relevant_z = GetConnectedZlevels(z_level)
	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in relevant_z))
			continue
		if(!isdeaf(M))
			sound_to(M, sound(fire_sound, volume=5))

//	handle_beam(start, heading)				ебаная параша на beam() без каких либо причин не хочет проводить лучик через судно врага, ни рантаймов ни ошибок - по этому меняем на костыль
	handle_beam_on_enemy(start, heading)//	хоть и костыль но выглядит очень модно :P
	handle_beam_damage(start, heading, TRUE)

/obj/machinery/computer/ship/ship_weapon/beam_cannon/proc/fire_at_exoplanet(z_level, obj/overmap/target)
	fire_at_sector(z_level, pick(GLOB.cardinal), target, TRUE)

/obj/machinery/computer/ship/ship_weapon/beam_cannon/proc/handle_beam(turf/s, d)
	set waitfor = FALSE
	s.Beam(get_edge_turf(s, d), beam_icon, time = beam_time, maxdistance = world.maxx)
	if(front)
		front.layer = initial(front.layer)

/obj/machinery/computer/ship/ship_weapon/beam_cannon/proc/handle_beam_damage(turf/s, d, killing_floor = FALSE)
	set waitfor = FALSE
	for(var/turf/T in getline(s,get_edge_turf(s, d)))
		if(istype(T,/turf/simulated/planet_edge))
			return
		var/deflected = FALSE
		for(var/obj/shield/S in T)
			if(S.gen.check_flag(shield_modflag_counter) && S.density)
				S.take_damage(5000,SHIELD_DAMTYPE_HEAT)
				deflected = TRUE
		if(deflected)
			var/def_angle = pick(90,-90,0)
			handle_beam_damage(get_step(T, turn(d, 180)), turn(d,180 + def_angle), TRUE)
			handle_beam_on_enemy(get_step(T, turn(d, 180)), turn(d,180 + def_angle))
			log_and_message_admins("Луч [gun_name] смешно отрикошетил от щита.")
			break
		if(T.density && !killing_floor)
			sleep(beam_speed)
			if(T && T.density)
				explosion(T, 4, EX_ACT_DEVASTATING, adminlog = 0)
				if(T)
					T.ex_act(1,TRUE)
		else if(killing_floor && !istype(T, /turf/space))
			sleep(beam_speed)
			explosion(T, 4, EX_ACT_DEVASTATING, adminlog = 0)
			if(T)
				T.ex_act(1,TRUE)
			var/list/relevant_z = GetConnectedZlevels(s.z)
			for(var/mob/M in GLOB.player_list)
				var/turf/J = get_turf(M)
				if(!J || !(J.z in relevant_z))
					continue
				shake_camera(M, shake_camera_force/10, 0.5)
			var/turf/right = get_step(T,turn(d,90))
			var/turf/left = get_step(T,turn(d,-90))
			if(!right.density && !istype(right, /turf/space))
				new /obj/turf_fire/inferno(right)
			if(!left.density && !istype(left, /turf/space))
				new /obj/turf_fire/inferno(left)
			if(!T.density && !istype(T, /turf/space))
				new /obj/turf_fire/inferno(T)
		else
			sleep(beam_speed)
		for(var/mob/living/U in T)
			U.gib()
		for(var/atom/A in T)
			if(A.density && !istype(A,/obj/shield))
				explosion(T, 4, EX_ACT_DEVASTATING, adminlog = 0)
				if(A && A.density)
					A.ex_act(1,TRUE)

/obj/machinery/computer/ship/ship_weapon/beam_cannon/proc/handle_beam_on_enemy(turf/s, d)
	set waitfor = FALSE
	for(var/turf/T in getline(s,get_edge_turf(s, d)))
		if(istype(T,/turf/simulated/planet_edge))
			return
		var/deflected = FALSE
		for(var/obj/shield/S in T)
			if((S.gen.mitigation_heat > 0 || S.gen.check_flag(MODEFLAG_PHOTONIC)) && S.density)
				deflected = TRUE
		if(deflected)
			break
		var/obj/effect/ion_beam = new /obj/projectile(T)
		ion_beam.dir = d
		ion_beam.icon = 'icons/effects/beam.dmi'
		ion_beam.icon_state = beam_icon
		ion_beam.anchored = TRUE //иначе лазеры смешно улетают от взрывов
		ion_beam.does_spin = FALSE // ^^^
		ion_beam.set_light(1, 2, 4, l_color = beam_light_color)
		playsound(T, beam_sound, 250, 1)
		QDEL_IN(ion_beam,beam_time)
		sleep(beam_speed)

/obj/machinery/computer/ship/ship_weapon/beam_cannon/proc/handle_overbeam(missed)
	set waitfor = FALSE
	var/turf/target_turf
	var/beam_dir = overmapdir

	if(missed)
		beam_dir = turn(overmapdir,pick(45,-45))

	if(linked.z == 12)
		target_turf = get_turf(linked)
		for(var/i = 1 to shoot_range)
			target_turf = get_step(target_turf, beam_dir)
		linked.Beam(target_turf, overmap_icon, time = beam_time, maxdistance = world.maxx)
	else
		target_turf = get_turf(linked.loc)
		for(var/i = 1 to shoot_range)
			target_turf = get_step(target_turf, beam_dir)
		linked.loc.Beam(target_turf, overmap_icon, time = beam_time, maxdistance = world.maxx)

/obj/machinery/computer/ship/ship_weapon/beam_cannon/handle_muzzle()
	set waitfor = FALSE
	var/turf/start = front
	var/direction = front.dir

	handle_beam(start, direction)
	handle_beam_damage(get_step(front,direction), direction)
