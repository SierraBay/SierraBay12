/*
	COMBAT_EXTENDED — попиксельная стрельба: выстрел летит в пиксель, по которому щёлкнули.

	В Бэй вектор полёта (`/datum/plot_vector`) идёт из середины клетки стрелка в середину клетки
	цели, а угол округляется до целого градуса. Пиксель клика до снаряда не доходит: `ClickOn()`
	отдаёт оружию уже разобранный список параметров, кор `set_clickpoint()` разбирает его второй
	раз, а `params2list()` от списка возвращает пустой список.

	Здесь:
	- оверрайд `set_clickpoint()` (`_master_files`) запоминает пиксель клика;
	- точка прицела (`ce_get_aim_point()`) считается от того, по чему щёлкнули, как в Авроре
	  (`preparePixelProjectile()`), а не от экрана: спрайт на экране едет между клетками и отстаёт
	  на пинг, а сервер знает только клетку. Тело моба и зажим клика в него — в
	  `projectile_hits.dm`;
	- выстрел, нацеленный в неплотный предмет без запаса прочности, — в гильзу, брошенный пистолет,
	  пятно крови — летит дальше (`ce_flies_past()`): в Бэй он в клетке такого предмета и кончался.
	  А клик по тому, что лежит вровень с полом, — по пятну крови, кабелю, решётке вентиляции — это
	  клик по полу под ним (`ce_take_floor_target()`). Оба правила работают и без выключателя;
	- оверрайд `setup_trajectory()` после кор версии нацеливает вектор в эту точку
	  (`ce_aim_trajectory()`): угол не округляется, разброс оружия идёт дробными градусами;
	- оверрайд `Move()` на диагональном шаге сперва проводит снаряд через клетку, угол которой
	  линия полёта срезает (`ce_pass_cut_corner()`): сквозь угол стены выстрел не проходит;
	- снаряд с зарядом — ионный, ракета — кончается на дальности точки прицела
	  (`projectile_landing.dm`).

	Шаг вектора остаётся по правилу Бэй — по большей оси ровно клетка, — и столкновения остаются
	клеточными. Координаты — пиксели вектора: середина клетки `T` лежит в `T.x * 32`, `T.y * 32`.
*/

/// На сколько пикселей граница между пикселями клетки сдвинута к старшему, когда точка выстрела
/// переводится в `p_x`/`p_y`: точка ровно на границе — середина клетки — отходит младшему пикселю,
/// и погрешность счёта её не перебрасывает.
#define CE_AIM_PIXEL_EDGE_BIAS 0.01

/obj/item/projectile
	/// Пиксель клика по цели в координатах её иконки (`icon-x`, `icon-y`), от 1. null — клика не
	/// было, и выстрел летит в середину цели.
	var/ce_click_icon_x
	var/ce_click_icon_y
	/// Вектор полёта уже нацелен. Повторный `setup_trajectory()` — `redirect()` — идёт как в Бэй.
	var/ce_trajectory_aimed = FALSE
	/// Снаряд сейчас проходит клетку, угол которой срезает линия полёта (`ce_pass_cut_corner()`).
	var/ce_cutting_corner = FALSE
	/// В срезанном углу снаряд обошёл моба, который его не пустил (`ce_skip_corner_bump()`).
	var/ce_corner_mob_skipped = FALSE
	/// Направление шага, который снаряд сейчас делает, пока шаг не кончился. Через срезанный угол
	/// снаряд идёт двумя прямыми шагами, а летит по диагонали: тогда это диагональ. Это направление
	/// читает кор `Bump()`: с какой стороны пришёл выстрел.
	var/ce_travel_dir


// ============================================================================================
// Точка прицела
// ============================================================================================

/// Середина клетки атома в пикселях вектора, `list(x, y)`. null — атом не на карте.
/atom/proc/ce_get_tile_center()
	RETURN_TYPE(/list)
	var/turf/place = get_turf(src)
	if(!place)
		return null
	return list(place.x * world.icon_size, place.y * world.icon_size)


/// Размер кадра иконки `icon_file`, `list(ширина, высота)`. Без иконки — клетка.
/proc/ce_get_icon_size(icon_file)
	RETURN_TYPE(/list)
	var/static/list/sizes = list()
	if(!isicon(icon_file))
		return list(world.icon_size, world.icon_size)
	// У иконки, собранной на лету, — человека — имени файла нет: её размер не запоминается.
	var/file_name = "[icon_file]"
	var/list/size = file_name ? sizes[file_name] : null
	if(size)
		return size
	var/icon/frame = icon(icon_file)
	size = list(frame.Width() || world.icon_size, frame.Height() || world.icon_size)
	if(file_name)
		sizes[file_name] = size
	return size


/**
 * Точка карты под пикселем `icon_x`, `icon_y` иконки атома, `list(x, y)` в пикселях вектора. null —
 * атом не на карте.
 *
 * Иконка стоит левым нижним углом в левом нижнем углу клетки, сдвинута на `pixel_x`/`pixel_y` и
 * повёрнута `transform` вокруг своей середины. Пиксель клика BYOND отдаёт в координатах самой
 * иконки, до `transform`, поэтому поворот лежащего моба применяется здесь. Размер иконки нужен
 * только повороту: у неповёрнутого атома он не спрашивается.
 */
/atom/proc/ce_get_click_point(icon_x, icon_y)
	RETURN_TYPE(/list)
	var/list/point = ce_get_tile_center()
	if(!point)
		return null
	// От левого нижнего угла иконки до середины щёлкнутого пикселя.
	var/from_corner_x = icon_x - 0.5
	var/from_corner_y = icon_y - 0.5
	var/matrix/turn = transform
	if(turn && (turn.a != 1 || turn.b || turn.c || turn.d || turn.e != 1 || turn.f))
		var/list/icon_size = ce_get_icon_size(icon)
		var/half_width = icon_size[1] / 2
		var/half_height = icon_size[2] / 2
		var/from_center_x = from_corner_x - half_width
		var/from_center_y = from_corner_y - half_height
		from_corner_x = half_width + turn.a * from_center_x + turn.b * from_center_y + turn.c
		from_corner_y = half_height + turn.d * from_center_x + turn.e * from_center_y + turn.f
	var/half_tile = world.icon_size / 2
	point[1] += pixel_x + pixel_w + from_corner_x - half_tile
	point[2] += pixel_y + pixel_z + from_corner_y - half_tile
	return point


/**
 * Точка прицела по атому, `list(x, y)` в пикселях вектора: пиксель клика `icon_x`, `icon_y` по его
 * иконке, без клика — середина его клетки. null — атом не на карте.
 */
/atom/proc/ce_get_aim_point(icon_x, icon_y)
	RETURN_TYPE(/list)
	if(isnull(icon_x) || isnull(icon_y))
		return ce_get_tile_center()
	return ce_get_click_point(icon_x, icon_y)


/**
 * Клик по предмету ведёт линию выстрела через его клетку: точка прицела лежит не дальше
 * `ce_aim_tile_reach` от её середины. Неплотный предмет снаряд задевает, только войдя в его клетку,
 * а клик по краю спрайта — у предмета со сдвигом он бывает и за краем клетки — провёл бы линию
 * через угол клетки мимо неё. Клик по тому, что лежит вровень с полом, — клик по полу: его точка,
 * как у клетки, не подтягивается.
 */
/atom/movable/ce_get_aim_point(icon_x, icon_y)
	var/list/point = ..()
	if(!point || ce_is_flush_with_floor())
		return point
	return ce_pull_point_within(point, ce_get_tile_center(), ce_aim_tile_reach)


/// Атом лежит вровень с полом, и снаряду задеть в нём нечего: клик по нему — клик по полу под ним
/// (`ce_take_floor_target()`).
/atom/proc/ce_is_flush_with_floor()
	return FALSE


/**
 * Предмет, которому снаряд ничего не сделает, нарисованный ниже слоя предметов
 * (`ce_floor_level_layer`): кровь и грязь, руна, открытый кабель, решётка вентиляции, голопад,
 * мостки, лестница. То, что снаряд может сломать, — открытая труба, светильник в полу, сеть,
 * провода улья — остаётся целью. Правило Авроры (`can_hit_target()`); там оговорки о прочности
 * нет, и в такое не попасть вовсе.
 */
/obj/ce_is_flush_with_floor()
	return layer < ce_floor_level_layer && ce_has_nothing_to_hit()


/// Снаряду в предмете задеть нечего: он неплотный и без запаса прочности — гильза, брошенный
/// пистолет, пятно крови, табличка на стене.
/obj/proc/ce_has_nothing_to_hit()
	return !density && !get_max_health()


/// Точка `point`, подтянутая к точке `center` на расстояние не больше `reach`, `list(x, y)`.
/proc/ce_pull_point_within(list/point, list/center, reach)
	RETURN_TYPE(/list)
	var/offset_x = point[1] - center[1]
	var/offset_y = point[2] - center[2]
	var/distance = sqrt(offset_x ** 2 + offset_y ** 2)
	if(distance <= reach)
		return point
	var/share = reach / distance
	return list(center[1] + offset_x * share, center[2] + offset_y * share)


// ============================================================================================
// Снаряд
// ============================================================================================

/// Запоминает пиксель клика из параметров клика: списком, как их отдаёт `ClickOn()`, или строкой.
/obj/item/projectile/proc/ce_note_click(params)
	var/list/click_params = islist(params) ? params : params2list(params)
	var/icon_x = text2num(click_params[MOUSE_ICON_X])
	var/icon_y = text2num(click_params[MOUSE_ICON_Y])
	if(isnull(icon_x) || isnull(icon_y))
		return
	ce_click_icon_x = icon_x
	ce_click_icon_y = icon_y


/**
 * Дуга разброса выстрела, градусы: снаряд отклоняется не дальше половины дуги в каждую сторону.
 * Разброс оружия, а с физическими попаданиями (`projectile_hits.dm`) ещё и навык стрелка: неумелый
 * дугу расширяет, умелый сужает, но меньше нуля она не бывает. Выстрел в упор тогда летит без
 * разброса: ствол упёрт в цель. Дуга от отдачи стрелка (`recoil_spread.dm`) прибавляется после
 * навыка: умелый стрелок гасит разброс оружия, но не отдачу.
 */
/obj/item/projectile/proc/ce_get_spread_arc()
	var/arc = dispersion * ce_dispersion_arc_degrees
	if(ce_physical_hits_active())
		if(ce_point_blank)
			return 0
		arc += ce_get_skill_arc()
	return max(arc, 0) + ce_recoil_arc


/**
 * Снаряд пролетает мимо предмета `target`, в клетке которого стоит: задеть в нём нечего
 * (`ce_has_nothing_to_hit()`). Спрашивает оверрайд `/obj/bullet_act()`
 * (`mods/_master_files/code/game/atoms.dm`) — тот, до которого доходит предмет без своей реакции на
 * пулю: мина, шарик, штора решают сами и остаются целью.
 *
 * Неплотный предмет снаряд встречает, только когда целились в него (кор `Process()`), и в Бэй на нём
 * кончался: выстрел по гильзе или брошенному пистолету до противника за ними не долетал. Работает и
 * без выключателей: это правило Бэй, а не часть прицела.
 *
 * Только в полёте и только в клетке предмета. Выстрел себе под ноги кончается сразу, как в Бэй;
 * неплотный предмет, который сам не пустил снаряд в свою клетку, — преграда; а предмет, который
 * уже не лежит на клетке, — оживлённый посохом волшебника — не мусор на полу.
 */
/obj/item/projectile/proc/ce_flies_past(obj/target)
	return trajectory && loc == target.loc && target.ce_has_nothing_to_hit()


/**
 * Клик по тому, что лежит вровень с полом (`ce_is_flush_with_floor()`), — выстрел по клетке под ним:
 * целью снаряда становится клетка. В Бэй снаряд, вошедший в клетку того, по чему щёлкнули, встречает
 * его, даже неплотного (кор `Process()`): выстрел по пятну крови между стрелком и противником в этом
 * пятне и кончался. Работает и без выключателей: это правило Бэй, а не часть прицела.
 */
/obj/item/projectile/proc/ce_take_floor_target()
	var/turf/floor = get_turf(original)
	if(floor && original.ce_is_flush_with_floor())
		original = floor


/**
 * Нацеливает вектор полёта в точку прицела по `original`, с отклонением в пределах дуги разброса.
 * Зовётся из `setup_trajectory()` после кор версии и работает один раз на снаряд: `redirect()`
 * перенацеливает уже летящий снаряд в клетку, и пиксель клика к ней не относится.
 */
/obj/item/projectile/proc/ce_aim_trajectory()
	if(ce_trajectory_aimed)
		return
	ce_trajectory_aimed = TRUE
	if(!trajectory || QDELETED(original))
		return
	// Пиксель клика — в координатах иконки того, по чему щёлкнули, даже когда целью стала клетка.
	var/atom/clicked = original
	ce_take_floor_target()
	// Вектор Бэй идёт в середину клетки цели: на её дальности снаряд и приземляется
	// (`projectile_landing.dm`).
	if(!ce_pixel_aim_enabled)
		ce_plan_landing(clicked.ce_get_tile_center())
		return
	var/list/aim_point = clicked.ce_get_aim_point(ce_click_icon_x, ce_click_icon_y)
	if(!aim_point)
		return
	ce_take_prone_target(aim_point)
	var/spread_arc = ce_get_spread_arc()
	var/deviation = (rand() - 0.5) * spread_arc
	if(!trajectory.ce_aim_at(aim_point[1], aim_point[2], deviation))
		return
	ce_plan_landing(aim_point)
	ce_turn_to_trajectory()
	ce_set_clickpoint_on_line(aim_point)
	if(ce_aim_debug)
		ce_report_aim(aim_point, spread_arc, deviation)


/// Снаряд-трассировщик нацелен как выстрел без клика, чтобы проверять ту же линию, но в чат о своём
/// прицеле не пишет: его пускают ИИ, турели и прицеливание.
/obj/item/projectile/test/ce_report_aim(list/aim_point, spread_arc, deviation)
	return


/// Трассировщик проверяет линию прицела, а не выстрел: разброса у него нет, и навык стрелка его не
/// качает.
/obj/item/projectile/test/ce_get_spread_arc()
	return 0


/// Поворачивает спрайт снаряда и его эффекты по вектору полёта, как `setup_trajectory()`.
/obj/item/projectile/proc/ce_turn_to_trajectory()
	effect_transform = matrix().Update(
		scale_x = round(trajectory.return_hypotenuse() + 0.005, 0.001),
		rotation = round(-trajectory.angle, 0.1)
	)
	SetTransform(rotation = -(trajectory.angle + 90))


/**
 * Ставит `p_x`/`p_y` — пиксель клетки цели, через который линия выстрела проходит на расстоянии
 * точки прицела `aim_point`. Без отклонения это сама точка прицела, с отклонением — место, куда
 * выстрел лёг на самом деле: его читают след пули на стене и мишень в тире. Зовётся, пока вектор
 * стоит в начале полёта.
 */
/obj/item/projectile/proc/ce_set_clickpoint_on_line(list/aim_point)
	var/turf/target_turf = get_turf(original)
	var/aim_distance = sqrt((aim_point[1] - trajectory.loc_x) ** 2 + (aim_point[2] - trajectory.loc_y) ** 2)
	var/steps = aim_distance / sqrt(trajectory.offset_x ** 2 + trajectory.offset_y ** 2)
	var/shot_x = trajectory.loc_x + trajectory.offset_x * steps
	var/shot_y = trajectory.loc_y + trajectory.offset_y * steps
	// Пиксель `k` клетки занимает отрезок от `k - 1` до `k` от её левого края. Середина клетки лежит
	// ровно на границе пикселей 16 и 17, и Бэй считает её пикселем 16: граница отходит младшему.
	var/left_edge = world.icon_size / 2 - CE_AIM_PIXEL_EDGE_BIAS
	p_x = clamp(ceil(shot_x - target_turf.x * world.icon_size + left_edge), 1, world.icon_size)
	p_y = clamp(ceil(shot_y - target_turf.y * world.icon_size + left_edge), 1, world.icon_size)


/**
 * Отладка (`ce_aim_debug`): пишет стрелку, куда нацелен выстрел, — смещение точки прицела от
 * середины клетки цели, дугу разброса и выпавшее отклонение.
 */
/obj/item/projectile/proc/ce_report_aim(list/aim_point, spread_arc, deviation)
	var/list/tile_center = original.ce_get_tile_center()
	var/off_x = round(aim_point[1] - tile_center[1], 0.1)
	var/off_y = round(aim_point[2] - tile_center[2], 0.1)
	ce_tell_gunners("Aim: \the [original] at ([off_x], [off_y]) px off centre, spread arc [round(spread_arc, 0.1)], rolled [round(deviation, 0.1)] deg.")


/// Строка отладки стрелку в чат; у меха — его пилотам. Снаряд без стрелка — турели — молчит.
/obj/item/projectile/proc/ce_tell_gunners(message)
	if(!ismob(firer))
		return
	for(var/mob/gunner as anything in firer.ce_get_gunners())
		to_chat(gunner, SPAN_DEBUG(message))


/// Кто стреляет, когда стреляет этот моб: он сам, а у меха — его пилоты.
/mob/proc/ce_get_gunners()
	RETURN_TYPE(/list)
	return list(src)


/mob/living/exosuit/ce_get_gunners()
	return length(pilots) ? pilots.Copy() : ..()


// ============================================================================================
// Срез угла
// ============================================================================================
// Вектор шагает по большей оси ровно на клетку и в каждом столбце входит в одну клетку — ту, где
// лежит его точка. Но между двумя точками на диагональном шаге линия полёта проходит ещё одну
// клетку: ту, чью границу пересекает первой. BYOND делает диагональный шаг прыжком, и эту клетку
// никто не проверял: выстрел проходил сквозь угол стены на глубину до 11 пикселей. В Бэй так
// летели только выстрелы из середины клетки в середину, с пиксельным прицелом — любой.

/**
 * Срез угла на диагональном шаге из клетки снаряда в клетку `next`: `list(клетка, x, y)` — клетка,
 * угол которой линия полёта проходит между двумя точками вектора, и середина отрезка линии в ней,
 * в пикселях вектора. null — шаг не диагональный, либо линия идёт через сам угол: отрезок не
 * длиннее `ce_corner_cut_tolerance`. Зовётся, когда вектор уже продвинут в `next`.
 */
/obj/item/projectile/proc/ce_get_corner_cut(turf/next)
	RETURN_TYPE(/list)
	var/turf/from = loc
	if(!ce_pixel_aim_enabled || !trajectory || !istype(from) || !istype(next) || next.z != from.z)
		return null
	var/step_x = next.x - from.x
	var/step_y = next.y - from.y
	if(abs(step_x) != 1 || abs(step_y) != 1 || !trajectory.offset_x || !trajectory.offset_y)
		return null
	var/previous_x = trajectory.loc_x - trajectory.offset_x
	var/previous_y = trajectory.loc_y - trajectory.offset_y
	// Снаряд стоит не в клетке прежней точки вектора — после рикошета в углу: линию не к чему
	// привязать, и шаг идёт как в Бэй.
	if(round(previous_x / world.icon_size, 1) != from.x || round(previous_y / world.icon_size, 1) != from.y)
		return null
	// Доли шага, на которых линия пересекает границы клетки снаряда по x и по y.
	var/half_tile = world.icon_size / 2
	var/time_x = (from.x * world.icon_size + half_tile * step_x - previous_x) / trajectory.offset_x
	var/time_y = (from.y * world.icon_size + half_tile * step_y - previous_y) / trajectory.offset_y
	var/step_length = sqrt(trajectory.offset_x ** 2 + trajectory.offset_y ** 2)
	if(abs(time_x - time_y) * step_length <= ce_corner_cut_tolerance)
		return null
	var/turf/corner = time_x < time_y ? locate(next.x, from.y, from.z) : locate(from.x, next.y, from.z)
	if(!corner)
		return null
	var/middle = (time_x + time_y) / 2
	return list(corner, previous_x + trajectory.offset_x * middle, previous_y + trajectory.offset_y * middle)


/**
 * Перед диагональным шагом в `next` проводит снаряд через клетку, угол которой срезает линия
 * полёта: обычным шагом, так что стена, окно на краю клетки и всё плотное в ней встречают снаряд
 * как на любом шаге. TRUE — можно шагать в `next`; FALSE — в углу снаряд остановился, отскочил
 * или упёрся. Зовётся из `Move()` до кор версии.
 *
 * Мобов в срезанном углу снаряд не задевает: линия проходит не ближе 11.3 пикселя к середине их
 * клетки. На время шага снаряд неплотный — такому мобы не мешают (`/mob/CanPass()`), а остальные
 * преграды на плотность снаряда не смотрят; моба со своими правилами прохода снаряд обходит в
 * `Bump()` (`ce_skip_corner_bump()`). С физическими попаданиями тех, чьё тело шире, — меха, крупного
 * моба — снаряд встречает сам (`ce_meet_corner_bodies()`).
 */
/obj/item/projectile/proc/ce_pass_cut_corner(turf/next)
	if(!location)
		return TRUE
	var/list/cut = ce_get_corner_cut(next)
	if(!cut)
		return TRUE
	var/turf/corner = cut[1]
	var/step_dir = get_dir(loc, next)
	// Попадание в угол считается и рисуется в нём, а не в клетке, куда шёл шаг: клетку попадания
	// рикошет и эффекты берут из `location`.
	location.loc = corner
	location.pixel_x = cut[2] - corner.x * world.icon_size
	location.pixel_y = cut[3] - corner.y * world.icon_size
	var/was_dense = density
	ce_cutting_corner = TRUE
	ce_corner_mob_skipped = FALSE
	set_density(FALSE)
	Move(corner)
	ce_cutting_corner = FALSE
	if(QDELETED(src))
		return FALSE
	set_density(was_dense)
	// Снаряд в угол не вошёл и не потому, что обошёл моба: отскочил от стены или упёрся.
	if(loc != corner && !ce_corner_mob_skipped)
		return FALSE
	// Дальше — прямой шаг из угла, а летит снаряд по диагонали (`ce_face_travel()`).
	ce_travel_dir = step_dir
	if(!ce_meet_corner_bodies(corner))
		return FALSE
	// Точка приземления лежит в срезанном углу: снаряд кончается в нём (`projectile_landing.dm`).
	if(ce_land_if_due())
		return FALSE
	location = trajectory.return_location(location)
	return TRUE


/// Поворачивает снаряд по шагу, который он делает, а через срезанный угол — по диагонали. Зовётся
/// перед каждым столкновением на этом шаге: кор `Bump()` читает по `dir`, с какой стороны пришёл
/// выстрел, а повернуть снаряд до `Bump()` успевает не каждая сборка BYOND.
/obj/item/projectile/proc/ce_face_travel()
	if(ce_travel_dir && dir != ce_travel_dir)
		set_dir(ce_travel_dir)


/**
 * С физическими попаданиями (`projectile_hits.dm`) снаряд в срезанном углу `corner` встречает
 * плотных мобов, через чьё тело прошла линия полёта: неплотным шагом он их миновал. У человека
 * посреди клетки тело до линии не достаёт; достаёт у меха, у крупного моба и у сдвинутого с места.
 * FALSE — снаряд в одном из них остановился.
 *
 * Круг тела проверяется здесь, а не только в `attack_mob()`: трассировщик до броска не доходит, и
 * любой моб, с которым он столкнулся, для него преграда.
 */
/obj/item/projectile/proc/ce_meet_corner_bodies(turf/corner)
	if(!ce_physical_hits_active())
		return TRUE
	for(var/mob/living/body in corner)
		if(!body.density)
			continue
		var/pass_distance = ce_get_pass_distance(body)
		if(isnull(pass_distance) || pass_distance > body.ce_get_hit_radius())
			continue
		if(Bump(body, TRUE) || QDELETED(src))
			return FALSE
	return TRUE


/**
 * Столкновение с мобом в срезанном углу снаряд пропускает: TRUE — `Bump()` делать нечего. Повтор
 * этого столкновения от BYOND — уже с самой клеткой — гасит `ce_take_bump_echo()`
 * (`projectile_hits.dm`): иначе кор `Bump()` клетки раздал бы попадания всему, что в ней стоит.
 */
/obj/item/projectile/proc/ce_skip_corner_bump(atom/obstacle)
	if(!ce_cutting_corner || !isliving(obstacle))
		return FALSE
	ce_corner_mob_skipped = TRUE
	return TRUE


// ============================================================================================
// Вектор
// ============================================================================================

/**
 * Нацеливает вектор из его текущей точки в точку `aim_x`, `aim_y` (пиксели вектора), с поворотом на
 * `deviation_degrees` против часовой стрелки. Угол не округляется. Шаг остаётся по правилу
 * `setup()`: по большей оси — ровно клетка. FALSE — точка совпала с началом, вектор не тронут.
 *
 * Направление берётся прямо из разности координат, без угла: выстрел вдоль оси и по диагонали
 * получает ровно те же шаги, что даёт `setup()`.
 */
/datum/plot_vector/proc/ce_aim_at(aim_x, aim_y, deviation_degrees = 0)
	var/delta_x = aim_x - loc_x
	var/delta_y = aim_y - loc_y
	if(!delta_x && !delta_y)
		return FALSE
	var/turn_cos = cos(deviation_degrees)
	var/turn_sin = sin(deviation_degrees)
	var/direction_x = delta_x * turn_cos - delta_y * turn_sin
	var/direction_y = delta_x * turn_sin + delta_y * turn_cos
	var/major = max(abs(direction_x), abs(direction_y))
	offset_x = world.icon_size * direction_x / major
	offset_y = world.icon_size * direction_y / major
	angle = Atan2(offset_x, offset_y)
	return TRUE

#undef CE_AIM_PIXEL_EDGE_BIAS
