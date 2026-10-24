#define MISSILE_FLIGHT_MAX_STEP_ANGLE 5

/obj/item/missile_equipment/thruster
	var/guidance_type = /datum/missile_guidance
	var/datum/missile_guidance/guidance
	/// Degrees per decisecond; a half-turn takes twelve seconds at the default rate.
	var/turn_rate = 15 / (1 SECOND)
	var/steering = FALSE

/obj/item/missile_equipment/thruster/Initialize(mapload)
	. = ..()
	guidance = new guidance_type

/obj/item/missile_equipment/thruster/Destroy()
	QDEL_NULL(guidance)
	return ..()

/obj/item/missile_equipment/thruster/proc/get_target()
	return guidance.get_target()

/obj/item/missile_equipment/thruster/proc/set_target(atom/new_target)
	guidance.set_target(new_target)

/obj/item/missile_equipment/thruster/proc/requires_propulsion(obj/overmap/projectile/projectile)
	var/list/course = guidance.get_course(projectile)
	return !isnull(course) && (course[1] || course[2])

/// Replace the core booster algorithm; calling it would spend fuel twice.
/obj/item/missile_equipment/thruster/do_overmap_work(obj/overmap/projectile/projectile)
	steering = FALSE
	if (world.time < next_work)
		return FALSE

	next_work = world.time + cooldown
	var/list/course = guidance.get_course(projectile)
	if (isnull(course) || (!course[1] && !course[2]))
		apply_course(projectile, course, 0)
		return TRUE

	if (!try_consume_fuel())
		exhaust_fuel(projectile)
		return FALSE

	steering = TRUE
	return TRUE

/obj/item/missile_equipment/thruster/proc/steer(obj/overmap/projectile/projectile, elapsed, timestamp)
	if (!steering || projectile.halted)
		return

	var/list/course = guidance.get_course(projectile, elapsed, overmap_speed, turn_rate, timestamp)
	apply_course(projectile, course, elapsed)

/// Five-degree chords lose <0.1% arc length; also bound sagitta to contact_radius / 8.
/obj/item/missile_equipment/thruster/proc/get_flight_step(obj/overmap/projectile/projectile, elapsed)
	if (!steering || turn_rate <= 0)
		return elapsed

	var/map_speed = min(overmap_speed, projectile.max_speed) / 2
	var/angular_speed = turn_rate * M_PI / 180
	var/sagitta_step = SSobj.wait
	if (map_speed > 0 && projectile.contact_radius > 0)
		sagitta_step = sqrt(projectile.contact_radius / (map_speed * angular_speed))

	return min(elapsed, SSobj.wait, MISSILE_FLIGHT_MAX_STEP_ANGLE / turn_rate, sagitta_step)

/// The mean tangent of a constant-speed arc gives its chord without reducing physical speed.
/obj/item/missile_equipment/thruster/proc/get_average_velocity(obj/overmap/projectile/projectile, start_angle)
	var/turn = guidance.get_angle_delta(guidance.get_projectile_heading(projectile), start_angle)
	if (!turn)
		return projectile.speed.Copy()

	var/half_turn = turn / 2
	var/magnitude = sqrt(projectile.speed[1] ** 2 + projectile.speed[2] ** 2)
	var/chord_speed = magnitude * sin(half_turn) / (half_turn * M_PI / 180)
	return list(chord_speed * cos(start_angle + half_turn), chord_speed * sin(start_angle + half_turn))

/obj/item/missile_equipment/thruster/on_touch_map_edge(obj/overmap/projectile/projectile)
	// Local flight time does not grant an instantaneous turn on returning to the overmap.
	steering = FALSE
	guidance.reset_navigation()
	return ..()

/obj/item/missile_equipment/thruster/should_enter(obj/overmap/site)
	return guidance.should_enter(site)

/obj/item/missile_equipment/thruster/is_target_valid(obj/overmap/site)
	return guidance.is_target_valid(site, src)

/obj/item/missile_equipment/thruster/configure(mob/user)
	return guidance.configure(src, user)

/obj/item/missile_equipment/thruster/on_enter_level(z_level)
	return guidance_enter_level(z_level)

/obj/item/missile_equipment/thruster/proc/guidance_enter_level(z_level)
	var/obj/structure/missile/missile = loc
	if (!istype(missile))
		return null

	var/turf/impact_turf = guidance.get_impact_turf(z_level)
	if (impact_turf)
		missile.impact_at(impact_turf)
		return null

	var/turf/goal = guidance.get_local_target(missile, target_range, z_level)
	if (goal)
		return list(goal.x, goal.y)

	return null

/obj/item/missile_equipment/thruster/proc/apply_course(obj/overmap/projectile/projectile, list/course, elapsed)
	ASSERT(istype(projectile))
	if (isnull(course))
		return

	if (!course[1] && !course[2])
		projectile.set_flight_velocity(0, 0)
		return

	var/angle = get_course_angle(projectile, course, elapsed)
	var/magnitude = min(overmap_speed, projectile.max_speed)
	projectile.set_flight_velocity(magnitude * cos(angle), magnitude * sin(angle))

/obj/item/missile_equipment/thruster/proc/get_course_angle(obj/overmap/projectile/projectile, list/course, elapsed)
	var/current_angle = guidance.get_projectile_heading(projectile)
	var/delta = guidance.get_angle_delta(Atan2(course[1], course[2]), current_angle)
	var/maximum_turn = max(0, turn_rate * elapsed)
	return current_angle + clamp(delta, -maximum_turn, maximum_turn)

/obj/item/missile_equipment/thruster/proc/exhaust_fuel(obj/overmap/projectile/projectile)
	projectile.actual_missile?.self_destruct()

/obj/item/missile_equipment/thruster/proc/has_fuel()
	if (!fuel_consumption)
		return TRUE

	var/obj/item/tank/fuel_tank = locate() in src
	return fuel_tank && fuel_tank.air_contents.get_by_flag(XGM_GAS_FUEL) >= fuel_consumption

#undef MISSILE_FLIGHT_MAX_STEP_ANGLE
