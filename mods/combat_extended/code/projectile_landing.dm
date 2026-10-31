/*
	COMBAT_EXTENDED — снаряд с зарядом срабатывает там, куда целились: ионный заряд, гироджет, ракета.

	Такой снаряд делает своё там, где кончился: ЭМИ ионного заряда — в `on_impact()`, взрыв ракеты —
	в `on_hit()`. В Бэй он летел до первой преграды: клик по полу его не останавливал (кор `Process()`
	встречает `original`, только если это не клетка), а клик по предмету на полу останавливал в его
	клетке. С правилами прицела (`ce_flies_past()`, `ce_take_floor_target()`) и клик по предмету стал
	пролетать мимо, и ЭМИ со взрывом уходили к первой стене.

	Здесь снаряд с `ce_lands_at_aim` кончается на дальности точки прицела, если раньше ничего не
	встретил, — во что бы ни целились: в пол, в предмет, в моба, мимо которого он прошёл или который
	отошёл. Так в OnyxBay (`impact_on_original`) и в CEV-Eris (гранаты подствольника); в CE снаряд,
	пущенный в клетку, падает на её дальности сам: его дуга нацелена в пол.

	- Точка приземления (`ce_plan_landing()`) лежит на линии полёта, на дальности точки прицела от
	  начала вектора. Без разброса это сама точка прицела, с разбросом — та же дальность в стороне.
	- Снаряд приземляется в клетке этой точки в начале шага после того, как в неё вошёл
	  (`before_move()`): моб и предмет в этой клетке встречают его раньше, по кор правилам. В клетке,
	  угол которой линия полёта только срезает, — сразу (`ce_pass_cut_corner()`). Не войдя в клетку
	  точки — угол срезан тоньше порога, прицел выключен, — снаряд приземляется на первом шаге за её
	  дальностью.
	- Приземление (`ce_land()`) — попадание в пол клетки: как кор `Bump()` по клетке, но без её
	  содержимого. `bullet_act()` пола зовёт `on_hit()`, следом идёт `on_impact()`. Мобов и предметы в
	  клетке снаряд сам не задевает: их берёт взрыв или ЭМИ.
	- Рикошет и `redirect()` приземление снимают: снаряд летит уже не туда, куда целились.

	Какие снаряды приземляются — `code/items/guns/payload_rounds.dm`. Работает и без выключателей:
	это правило снаряда, а не часть прицела.
*/

/obj/item/projectile
	/// Снаряд кончается на дальности точки прицела, если раньше ничего не встретил.
	var/ce_lands_at_aim = FALSE
	/// Клетка, в которой снаряд приземлится. null — снаряд летит до первой преграды.
	var/turf/ce_landing_turf
	/// Точка приземления в пикселях вектора, `list(x, y)`.
	var/list/ce_landing_point
	/// Начало полёта в пикселях вектора, `list(x, y)`: от него считается пройденная дальность.
	var/list/ce_launch_point
	/// Дальность точки приземления в шагах вектора.
	var/ce_landing_steps


/**
 * Отмечает, где приземлится снаряд с `ce_lands_at_aim`: точку на линии полёта на дальности точки
 * прицела `aim_point` от начала вектора и клетку под ней. Зовётся, когда вектор уже нацелен.
 */
/obj/item/projectile/proc/ce_plan_landing(list/aim_point)
	if(!ce_lands_at_aim || !trajectory || !aim_point)
		return
	var/step_length = sqrt(trajectory.offset_x ** 2 + trajectory.offset_y ** 2)
	var/aim_distance = sqrt((aim_point[1] - trajectory.loc_x) ** 2 + (aim_point[2] - trajectory.loc_y) ** 2)
	if(!step_length || !aim_distance)
		return
	var/steps = aim_distance / step_length
	var/landing_x = trajectory.loc_x + trajectory.offset_x * steps
	var/landing_y = trajectory.loc_y + trajectory.offset_y * steps
	// Клетка точки — по правилу вектора (`return_location()`).
	var/turf/landing_turf = locate(round(landing_x / world.icon_size, 1), round(landing_y / world.icon_size, 1), trajectory.loc_z)
	if(!landing_turf)
		return
	ce_landing_turf = landing_turf
	ce_landing_point = list(landing_x, landing_y)
	ce_launch_point = list(trajectory.loc_x, trajectory.loc_y)
	ce_landing_steps = steps


/// Снимает приземление: снаряд летит до первой преграды.
/obj/item/projectile/proc/ce_cancel_landing()
	ce_landing_turf = null
	ce_landing_point = null
	ce_launch_point = null
	ce_landing_steps = null


/**
 * Приземляет снаряд в его клетке, когда пора: он стоит в клетке точки приземления либо прошёл её
 * дальность, не войдя в неё. Зовётся, когда вектор уже продвинут к точке, в которую снаряд пойдёт
 * следующим: в начале шага (`before_move()`) и в срезанном углу (`ce_pass_cut_corner()`). TRUE —
 * снаряд приземлился.
 */
/obj/item/projectile/proc/ce_land_if_due()
	if(!ce_landing_turf || QDELETED(src) || !isturf(loc))
		return FALSE
	var/turf/here = loc
	if(here == ce_landing_turf)
		ce_put_impact_point(ce_landing_point)
	// Клетка снаряда — у прошлой точки вектора: вектор уже ушёл на шаг вперёд.
	else if(ce_get_vector_progress() - 1 >= ce_landing_steps)
		ce_put_impact_point(here.ce_get_tile_center())
	else
		return FALSE
	ce_land(here)
	return TRUE


/// На каком шаге от начала полёта стоит текущая точка вектора, дробным числом.
/obj/item/projectile/proc/ce_get_vector_progress()
	var/along_x = trajectory.loc_x - ce_launch_point[1]
	var/along_y = trajectory.loc_y - ce_launch_point[2]
	var/step_squared = trajectory.offset_x ** 2 + trajectory.offset_y ** 2
	return (along_x * trajectory.offset_x + along_y * trajectory.offset_y) / step_squared


/// Ставит место попадания — там рисуется эффект попадания (`impact_effect()`) — в точку `point`
/// клетки снаряда, в пикселях вектора.
/obj/item/projectile/proc/ce_put_impact_point(list/point)
	var/turf/here = loc
	if(!location || !istype(here))
		return
	location.loc = here
	location.pixel_x = point[1] - here.x * world.icon_size
	location.pixel_y = point[2] - here.y * world.icon_size


/**
 * Снаряд попадает в пол клетки `floor` и кончается. Как кор `Bump()` по клетке, но без её
 * содержимого: мобов и предметы в клетке берёт то, что снаряд делает сам, — взрыв, ЭМИ.
 */
/obj/item/projectile/proc/ce_land(turf/floor)
	ce_cancel_landing()
	bumped = TRUE
	floor.bullet_act(src, def_zone)
	on_impact(floor)
	set_density(FALSE)
	set_invisibility(INVISIBILITY_ABSTRACT)
	qdel(src)
