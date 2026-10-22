/*
	COMBAT_EXTENDED — рикошеты снарядов от стен.

	Собрано из двух портов:
	- Aurora (порт TG): счётчик и предел рикошетов у снаряда, спад шанса за каждый рикошет, цена
	  рикошета в дальности, стрелок без неуязвимости, зеркало самого вектора полёта;
	- OnyxBay (Rodial-Admiral, 2018): шанс от материала стены и от угла, доля сохранённого урона по
	  шансу, остаток урона уходит в стену, грань стены — по соседним стенам.

	Снаряд в Бэй летит по `/datum/plot_vector`: шаг в пикселях на итерацию, по большей оси — ровно
	клетка. `Process()` продвигает точку вектора и двигает снаряд в её клетку, а плотное на пути
	зовёт `Bump()`. Рикошет решается там, до кор версии (оверрайд в `_master_files`): отскочивший
	снаряд в стену не попадает — её `bullet_act()` не зовётся, — а стена получает только ту долю
	урона, которую снаряд на ней потерял.

	Рикошетит:
	- снаряд, которому это разрешено (`ce_ricochets_max`, `code/items/guns/bullets.dm`), пока не
	  исчерпал свои рикошеты;
	- только кинетический: лучи и огонь — нет;
	- только не пробивной (`ce_ricochet_max_penetrating`): тот стену проходит или застревает в ней;
	- только от поверхности со своим шансом (`ce_get_ricochet_surface_chance()`): стены — по
	  материалу, закрытые двери — по своему, окна во всю клетку — по стеклу, если оно армировано,
	  несимулируемые стены, стены шаттлов и порода — по числу на клетке. Другая поверхность
	  подключается оверрайдом этой процедуры.

	После рикошета точность, потеря дроби и сторона, с которой снаряд пришёл, считаются от клетки
	рикошета: туда переносится `starting`. Его читают щиты и прожоги мода и столы Бэй.
*/

/material
	/// Шанс рикошета пули от стены или двери из этого материала под 45° к ней, %. 0 — от неё не
	/// рикошетит. Значения — в `code/items/walls/wall_materials.dm`.
	var/ce_ricochet_chance = 0
	/// То же для армированного окна во всю клетку из этого стекла. Окно без арматуры не рикошетит.
	var/ce_reinforced_window_ricochet_chance = 0

/turf
	/// Шанс рикошета пули от этой клетки под 45° к ней, %, пока она плотная. Для клеток без
	/// материала: значения — в `code/items/walls/wall_turfs.dm`. У стены `/turf/simulated/wall` шанс
	/// даёт материал.
	var/ce_ricochet_chance = 0

/obj/item/projectile
	/// Сколько раз снаряд может срикошетить. 0 — не рикошетит. Задаётся в блоке снаряда в
	/// `code/items/guns/`.
	var/ce_ricochets_max = 0
	/// Множитель шанса рикошета этого снаряда.
	var/ce_ricochet_chance_mult = 1
	/// Сколько раз снаряд уже срикошетил.
	var/ce_ricochets = 0
	/// Клетка, в которую снаряд упёрся при последнем рикошете, пока BYOND не повторил столкновение
	/// с ней (`ce_take_ricochet_echo()`).
	var/turf/ce_ricochet_echo_turf


// ============================================================================================
// Поверхность
// ============================================================================================

/// Шанс рикошета `projectile` от этой поверхности под 45° к ней, % — до угла и множителей. 0 — от
/// неё не рикошетит.
/atom/proc/ce_get_ricochet_surface_chance(obj/item/projectile/projectile)
	return 0


/// Плотная клетка без материала — несимулируемая стена, стена шаттла, порода — по своему числу.
/turf/ce_get_ricochet_surface_chance(obj/item/projectile/projectile)
	return density ? ce_ricochet_chance : 0


/// Стена — по материалу. Армированная — среднее геометрическое двух материалов, как в OnyxBay:
/// стекло с любой арматурой остаётся нулём.
/turf/simulated/wall/ce_get_ricochet_surface_chance(obj/item/projectile/projectile)
	if(!material)
		return 0
	if(reinf_material)
		return sqrt(material.ce_ricochet_chance * reinf_material.ce_ricochet_chance)
	return material.ce_ricochet_chance


/**
 * Закрытая дверь — по своему материалу: шлюз — сталь или то, из чего он собран, гермозатвор, ставни
 * и аварийный затвор — пласталь. У шлюза со стеклом половину полотна занимает стекло
 * (`ce_ricochet_glass_door_mult`). У окошка раздачи материала нет, и оно не рикошетит: полотно у него
 * стеклянное, а грань — на краю клетки.
 */
/obj/machinery/door/ce_get_ricochet_surface_chance(obj/item/projectile/projectile)
	if(!density)
		return 0
	var/material/door_material = get_material()
	if(!door_material)
		return 0
	return door_material.ce_ricochet_chance * (glass ? ce_ricochet_glass_door_mult : 1)


/// Окно во всю клетку — по стеклу, и только армированное. Стекло на краю клетки не рикошетит.
/obj/structure/window/ce_get_ricochet_surface_chance(obj/item/projectile/projectile)
	if(!material || !reinf_material || !is_fulltile())
		return 0
	return material.ce_reinforced_window_ricochet_chance


/**
 * Стоит ли клетка преградой на пути снаряда: плотная сама или занята поверхностью, от которой
 * рикошетят, — закрытой дверью, армированным окном во всю клетку. По соседним преградам рикошет
 * решает, в какую грань снаряд попал (`ce_get_ricochet_axis()`).
 */
/turf/proc/ce_is_ricochet_barrier()
	if(density)
		return TRUE
	for(var/obj/thing in src)
		if(thing.density && thing.ce_get_ricochet_surface_chance(null) > 0)
			return TRUE
	return FALSE


/// Поверхность принимает рикошет: `lost_damage` — урон по конструкциям, который снаряд на ней
/// потерял.
/atom/proc/ce_take_ricochet(obj/item/projectile/projectile, lost_damage)
	if(!can_damage_health(lost_damage, projectile.damage_type, projectile.damage_flags))
		return
	damage_health(lost_damage, projectile.damage_type, projectile.damage_flags, skip_can_damage_check = TRUE)


/turf/simulated/wall/ce_take_ricochet(obj/item/projectile/projectile, lost_damage)
	create_bullethole(projectile)
	..()


// ============================================================================================
// Снаряд
// ============================================================================================

/**
 * Рикошет от `surface`, если снаряд может и бросок шанса удался. Зовётся из `Bump()` до кор версии,
 * `called` — как у него. TRUE — снаряд отскочил и летит дальше, кор `Bump()` звать не надо.
 */
/obj/item/projectile/proc/ce_try_ricochet(atom/surface, called)
	if(!ce_can_ricochet(surface, called))
		return FALSE
	// Клетка, в которую снаряд шёл: у двери в несколько клеток это не обязательно её собственная.
	var/turf/hit = location?.return_turf() || get_turf(surface)
	var/previous_x = trajectory.loc_x - trajectory.offset_x
	var/previous_y = trajectory.loc_y - trajectory.offset_y
	var/axis = ce_get_ricochet_axis(loc, hit, previous_x, previous_y, trajectory.offset_x, trajectory.offset_y)
	if(!axis)
		return FALSE
	var/chance = ce_get_ricochet_chance(surface, axis)
	var/bounced = prob(chance)
	if(ce_ricochet_debug)
		ce_report_ricochet(surface, axis, chance, bounced)
	if(bounced)
		ce_ricochet(surface, axis, chance)
		ce_ricochet_echo_turf = hit
	return bounced


/**
 * Забирает эхо рикошета: TRUE — это столкновение уже разобрано рикошетом, и `Bump()` делать нечего.
 *
 * Клетка, не пустившая снаряд, зовёт `Bump()` сама, с `called` (`/turf/Enter()`), а следом то же
 * столкновение повторяет BYOND — уже без `called` и с самой клеткой, что бы в ней ни стояло. Кор
 * версия гасит повтор флагом `bumped`, но после рикошета он не стоит: снаряд летит дальше. Без этой
 * проверки повтор пришёл бы в отскочившую пулю новым попаданием в ту же стену, а после рикошета от
 * двери или окна — в клетку под ними и во всё, что в ней стоит.
 */
/obj/item/projectile/proc/ce_take_ricochet_echo(atom/surface, called)
	if(called || !ce_ricochet_echo_turf || get_turf(surface) != ce_ricochet_echo_turf)
		return FALSE
	ce_ricochet_echo_turf = null
	return TRUE


/// Может ли снаряд срикошетить от `surface`. Чистый запрос, без броска шанса; `called` — как у
/// `Bump()`.
/obj/item/projectile/proc/ce_can_ricochet(atom/surface, called)
	if(!ce_ricochet_enabled || ce_ricochets >= ce_ricochets_max)
		return FALSE
	// Отскакивает только кинетика, а снаряду без урона отскакивать нечем.
	if(nodamage || damage <= 0 || damage_type != DAMAGE_BRUTE)
		return FALSE
	// Пробивной снаряд стену проходит или застревает в ней.
	if(penetrating > ce_ricochet_max_penetrating)
		return FALSE
	// Отказы кор `Bump()`: второе столкновение за шаг и то, сквозь что снаряд уже прошёл.
	if((bumped && !called) || (surface in permutated))
		return FALSE
	if(!trajectory || !isturf(loc))
		return FALSE
	return surface.ce_get_ricochet_surface_chance(src) > 0


/**
 * Шанс рикошета от `surface`, 0–100%: шанс поверхности × множители × спад за прежние рикошеты ×
 * тангенс угла между полётом и нормалью к грани. `axis` — составляющая вектора поперёк грани.
 */
/obj/item/projectile/proc/ce_get_ricochet_chance(atom/surface, axis)
	var/into_surface = abs(axis == CE_RICOCHET_AXIS_X ? trajectory.offset_x : trajectory.offset_y)
	var/along_surface = abs(axis == CE_RICOCHET_AXIS_X ? trajectory.offset_y : trajectory.offset_x)
	var/chance = surface.ce_get_ricochet_surface_chance(src) * ce_ricochet_chance_mult * ce_ricochet_chance_scale
	chance *= ce_ricochet_chance_decay ** ce_ricochets
	// Полёт вдоль грани: тангенс бесконечен.
	if(!into_surface)
		return chance > 0 ? 100 : 0
	return clamp(chance * along_surface / into_surface, 0, 100)


/// Доля урона и боли, которую снаряд сохраняет после рикошета с шансом `chance`: сам шанс, в
/// границах `ce_ricochet_damage_keep_min` и `ce_ricochet_damage_keep_max`.
/proc/ce_get_ricochet_kept_share(chance)
	return clamp(chance / 100, ce_ricochet_damage_keep_min, ce_ricochet_damage_keep_max)


/**
 * Рикошет от `surface`: снаряд теряет урон и боль, поверхность получает потерянное, вектор полёта
 * зеркалится по составляющей `axis`. `chance` — шанс, с которым рикошет случился: по нему считается
 * сохранённая доля (`ce_get_ricochet_kept_share()`).
 *
 * AP и зона прицела остаются как были, как в обоих портах. Пробитие в моде выводится из урона и
 * падает вместе с ним, так что срезать ещё и AP — терять его дважды. А случайная зона вместо
 * прицельной вчетверо поднимала шанс промаха: у рук, ног и головы он свой, от 30 до 70%.
 */
/obj/item/projectile/proc/ce_ricochet(atom/surface, axis, chance)
	var/kept_share = ce_get_ricochet_kept_share(chance)
	surface.ce_take_ricochet(src, get_structure_damage() * (1 - kept_share))
	ce_settle_flight_distance()
	ce_ricochets++
	damage *= kept_share
	agony *= kept_share
	life_span -= ce_ricochet_life_span_cost
	// Снаряд летит обратно: тех, кого он миновал, теперь может задеть.
	permutated.Cut()
	ce_last_missed = null
	// Дальность и сторона, с которой снаряд пришёл, теперь считаются отсюда.
	starting = get_turf(src)
	ce_reflect_trajectory(axis)
	ce_show_ricochet(surface)


/**
 * Отладка (`ce_ricochet_debug`): пишет всем, кто видит поверхность, исход столкновения — угол к
 * нормали, шанс поверхности, шанс рикошета, бросок и урон до и после. Зовётся до самого рикошета,
 * пока вектор и урон ещё прежние.
 */
/obj/item/projectile/proc/ce_report_ricochet(atom/surface, axis, chance, bounced)
	var/into_surface = abs(axis == CE_RICOCHET_AXIS_X ? trajectory.offset_x : trajectory.offset_y)
	var/along_surface = abs(axis == CE_RICOCHET_AXIS_X ? trajectory.offset_y : trajectory.offset_x)
	var/angle = round(Atan2(into_surface, along_surface))
	var/outcome = "embedded"
	if(bounced)
		outcome = "bounced, damage [round(damage, 0.1)] -> [round(damage * ce_get_ricochet_kept_share(chance), 0.1)], AP [armor_penetration]"
	var/surface_chance = round(surface.ce_get_ricochet_surface_chance(src), 0.1)
	surface.visible_message(SPAN_DEBUG("Ricochet: \the [src] hits \the [surface] at [angle] deg off the normal, surface [surface_chance]%, chance [round(chance, 0.1)]%: [outcome]."))


/// Запоминает всё, что снаряд считал от прежнего `starting`: после рикошета дальность идёт заново.
/obj/item/projectile/proc/ce_settle_flight_distance()
	return


/// Дробь, потерянная по пути до стены, после рикошета не возвращается.
/obj/item/projectile/bullet/pellet/ce_settle_flight_distance()
	pellets = get_pellets(get_dist(starting, loc))


/// Зеркалит вектор полёта по составляющей `axis` и поворачивает за ним спрайт и эффекты
/// (`ce_turn_to_trajectory()`, `projectile_aim.dm`).
/obj/item/projectile/proc/ce_reflect_trajectory(axis)
	trajectory.ce_reflect(axis, ce_ricochet_scatter_degrees)
	location = trajectory.return_location(location)
	ce_turn_to_trajectory()


/// Звук и искры рикошета. Беззвучный снаряд — осколки гранаты, пуля из-под глушителя — не шумит и
/// не искрит: осколков в комнате десятки.
/obj/item/projectile/proc/ce_show_ricochet(atom/surface)
	if(silenced)
		return
	if(LAZYLEN(ricochet_sounds))
		playsound(surface, pick(ricochet_sounds), 100, TRUE)
	new /obj/sparks(get_turf(src))


// ============================================================================================
// Вектор
// ============================================================================================

/**
 * Зеркалит вектор по составляющей `axis`, с разбросом до `scatter_degrees` в каждую сторону. Кор
 * `Process()` к этому моменту уже продвинул точку в стену: она возвращается на шаг назад, в клетку,
 * где снаряд стоит.
 */
/datum/plot_vector/proc/ce_reflect(axis, scatter_degrees = 0)
	loc_x -= offset_x
	loc_y -= offset_y
	if(axis == CE_RICOCHET_AXIS_X)
		offset_x = -offset_x
	else
		offset_y = -offset_y
	if(scatter_degrees)
		ce_scatter(axis, scatter_degrees)
	angle = Atan2(offset_x, offset_y)


/**
 * Поворачивает вектор на случайный угол до `scatter_degrees` в каждую сторону. Составляющая `axis`
 * — поперёк грани — знак не меняет: в стену разброс снаряд не разворачивает. Шаг остаётся по
 * правилу `setup()`: по большей оси — ровно клетка.
 */
/datum/plot_vector/proc/ce_scatter(axis, scatter_degrees)
	var/scattered_angle = Atan2(offset_x, offset_y) + (rand() * 2 - 1) * scatter_degrees
	var/direction_x = cos(scattered_angle)
	var/direction_y = sin(scattered_angle)
	if(axis == CE_RICOCHET_AXIS_X)
		direction_x = abs(direction_x) * sign(offset_x)
	else
		direction_y = abs(direction_y) * sign(offset_y)
	var/step_scale = world.icon_size / max(abs(direction_x), abs(direction_y))
	offset_x = direction_x * step_scale
	offset_y = direction_y * step_scale


/**
 * Какую составляющую вектора полёта переворачивает рикошет: поперёк какой оси стоит грань, в
 * которую снаряд попал. `from` — клетка снаряда, `hit` — клетка, в которую он упёрся, `previous_x` и
 * `previous_y` — точка вектора до шага, `offset_x` и `offset_y` — шаг. null — клетка та же.
 *
 * Шаг по прямой — грань одна. Шаг по диагонали BYOND делает прыжком, соседние клетки не проверяя,
 * и грань решают они (правило OnyxBay): стена продолжается вбок — снаряд попал в её плоскость.
 * Продолжением считается любая преграда (`ce_is_ricochet_barrier()`): стена, закрытая дверь,
 * армированное окно. Угол — обе соседние клетки преграды или обе пустые — решает граница клетки,
 * которую вектор пересёк первой: во внутреннем углу снаряд встречает первую стену на пути, наружный
 * задевает уже из соседней клетки.
 */
/proc/ce_get_ricochet_axis(turf/from, turf/hit, previous_x, previous_y, offset_x, offset_y)
	var/step_x = hit.x - from.x
	var/step_y = hit.y - from.y
	if(!step_x && !step_y)
		return null
	if(!step_y)
		return CE_RICOCHET_AXIS_X
	if(!step_x)
		return CE_RICOCHET_AXIS_Y
	var/turf/side_x = locate(hit.x, from.y, from.z)
	var/turf/side_y = locate(from.x, hit.y, from.z)
	var/x_blocked = !!side_x?.ce_is_ricochet_barrier()
	var/y_blocked = !!side_y?.ce_is_ricochet_barrier()
	if(x_blocked != y_blocked)
		return x_blocked ? CE_RICOCHET_AXIS_X : CE_RICOCHET_AXIS_Y
	var/x_first = ce_crosses_x_first(from, step_x, step_y, previous_x, previous_y, offset_x, offset_y)
	if(x_blocked)
		return x_first ? CE_RICOCHET_AXIS_X : CE_RICOCHET_AXIS_Y
	return x_first ? CE_RICOCHET_AXIS_Y : CE_RICOCHET_AXIS_X


/**
 * Какую границу клетки `from` вектор пересекает раньше на диагональном шаге в сторону `step_x`,
 * `step_y`: TRUE — границу по x. Клетка — пиксели от половины клетки до середины до половины после.
 */
/proc/ce_crosses_x_first(turf/from, step_x, step_y, previous_x, previous_y, offset_x, offset_y)
	if(!offset_x)
		return FALSE
	if(!offset_y)
		return TRUE
	var/half_tile = world.icon_size / 2
	var/time_x = (from.x * world.icon_size + half_tile * sign(step_x) - previous_x) / offset_x
	var/time_y = (from.y * world.icon_size + half_tile * sign(step_y) - previous_y) / offset_y
	return time_x <= time_y
