/*
	COMBAT_EXTENDED — физические попадания: порт модели попаданий Авроры на вектор Бэй.

	В Бэй и в Авроре тело — вся клетка: снаряд, вошедший в клетку моба, уже попал, а дальше бросок.
	Бросок Бэй (`attack_mob()`, `get_zone_with_miss_chance()`) режет попадания квадратом расстояния,
	и за экраном не попадает никто.

	Здесь (`ce_physical_hits_enabled`):
	- у тела есть середина и радиус, в пикселях вектора полёта (`projectile_aim.dm`). Клик по живому
	  мобу целит в тело, а не в край спрайта, — это работает и без выключателя;
	- навык стрелка — дуга разброса (`ce_get_skill_arc()`), как в Авроре: промах неумелого стрелка —
	  пуля, ушедшая в сторону;
	- снаряд, чья линия полёта прошла мимо тела, летит дальше без броска (`ce_misses_body()`,
	  оверрайд `attack_mob()`). Этого в Авроре нет;
	- живой щит решает за держащего: снаряд, промахнувшийся по щиту, не задевает и его
	  (`ce_passes_shield_holder()`);
	- снаряд, прошедший через тело, бросает шанс Авроры (`ce_get_projectile_hit_zone()`, правка
	  `[SIERRA-EDIT]` в кор `attack_mob()`): шанс зоны плюс поправка за расстояние, линейная.
	  Поправку гасит точность снаряда, а у выстрела из оружия — ещё и `ce_gun_accuracy_points`
	  (оверрайд `process_accuracy()` помечает снаряд);
	- выстрел в упор не промахивается (оверрайд `process_point_blank()` помечает снаряд);
	- клик по клетке, где точка прицела легла в тело лежащего, — выстрел по нему
	  (`ce_take_prone_target()`).

	Выключатель работает только вместе с попиксельной стрельбой (`ce_physical_hits_active()`).
*/

/obj/item/projectile
	/// Выстрел в упор (`/obj/item/gun/proc/process_point_blank()`): по тому, в кого целились, он не
	/// промахивается и летит без разброса.
	var/ce_point_blank = FALSE
	/// Выстрел из оружия (`/obj/item/gun/proc/process_accuracy()`): в броске он гасит
	/// `ce_gun_accuracy_points` шанса провала сверх своего `hitchance_mod`.
	var/ce_gun_shot = FALSE
	/// `special_miss_modifier` последнего `attack_mob()`, как его передал вызвавший. Кор версия до
	/// броска успевает вычесть из своего навык стрелка, а в броске Авроры навыка нет.
	var/ce_special_miss_modifier = 0
	/// Моб, по которому снаряд промахнулся последним: пролетел мимо тела или бросок ушёл мимо. Облако
	/// дроби зовёт `attack_mob()` на каждую дробину, а сообщение о пролёте нужно одно; и того, кто
	/// прикрылся этим мобом как живым щитом, снаряд уже не задевает (`ce_passes_shield_holder()`).
	var/mob/living/ce_last_missed
	/// Столкновение этого шага полёта уже разобрано: клетка, не пустившая снаряд, позвала `Bump()`
	/// сама. Повтор того же столкновения от BYOND больше не нужен (`ce_take_bump_echo()`).
	var/ce_bump_resolved = FALSE
	/// Глубина вложенных `Bump()`: кор версия зовёт `Bump()` живого щита из `Bump()` держащего.
	var/ce_bump_depth = 0


/// Физические попадания включены и работают: им нужна попиксельная стрельба.
/proc/ce_physical_hits_active()
	return ce_physical_hits_enabled && ce_pixel_aim_enabled


// ============================================================================================
// Тело
// ============================================================================================

/**
 * Середина тела в пикселях вектора, `list(x, y)`: середина клетки плюс сдвиг моба со своего обычного
 * места — на кровати, на столе, лёжа. null — моб не на карте.
 */
/mob/living/proc/ce_get_body_center()
	RETURN_TYPE(/list)
	var/list/center = ce_get_tile_center()
	if(!center)
		return null
	center[1] += pixel_x - default_pixel_x
	center[2] += pixel_y - default_pixel_y
	var/matrix/turn = transform
	if(turn)
		center[1] += turn.c
		center[2] += turn.f
	return center


/// Радиус тела для снаряда, пиксели: по размеру моба (`ce_hit_radius_by_mob_size`), лежащий — шире.
/mob/living/proc/ce_get_hit_radius()
	var/radius = ce_evaluate_curve(ce_hit_radius_by_mob_size, mob_size)
	return lying ? radius * ce_hit_radius_lying_mult : radius


/// Мех занимает клетку целиком.
/mob/living/exosuit/ce_get_hit_radius()
	return world.icon_size


/**
 * Клик по живому мобу целит в его тело: точка клика по спрайту, но не дальше доли
 * `ce_aim_clamp_share` радиуса тела от его середины. Без клика — сама середина тела. Как и у
 * предмета, точка лежит не дальше `ce_aim_tile_reach` от середины клетки: тело сдвинутого моба
 * выходит за её край.
 */
/mob/living/ce_get_aim_point(icon_x, icon_y)
	var/list/point = ce_get_body_center()
	if(!point)
		return null
	if(!isnull(icon_x) && !isnull(icon_y))
		point = ce_pull_point_within(ce_get_click_point(icon_x, icon_y), point, ce_get_hit_radius() * ce_aim_clamp_share)
	return ce_pull_point_within(point, ce_get_tile_center(), ce_aim_tile_reach)


// ============================================================================================
// Навык стрелка
// ============================================================================================

/**
 * Навык оружия, с которым моб стреляет, или null — навыка у него нет, и дуги навыка тоже. Набор
 * навыков есть у каждого моба, и у того, кому его никто не выдавал, — турели, простого моба, бота
 * — каждый навык «опытный»: считать его нельзя.
 */
/mob/proc/ce_get_shooter_skill()
	return null


/mob/living/carbon/human/ce_get_shooter_skill()
	return get_skill_value(SKILL_WEAPONS)


/// Навыки робота выдаёт его модуль.
/mob/living/silicon/robot/ce_get_shooter_skill()
	return get_skill_value(SKILL_WEAPONS)


/// Из орудий меха стреляет пилот, и всякий, кого мех допустил до орудий, пока считается мастером:
/// своих навыков стрельбы у мехов ещё нет. Мех без пилота — автоматика.
/mob/living/exosuit/ce_get_shooter_skill()
	return length(pilots) ? SKILL_MASTER : null


/**
 * Дуга разброса от навыка стрелка, градусы: за каждый уровень ниже обученного —
 * `ce_skill_dispersion_arc_degrees`, выше — столько же со знаком минус: умелый стрелок гасит разброс
 * оружия. Ноль — стрелка нет или навыка у него нет. Вектор нацеливается тиком позже выстрела, и
 * стрелка к тому времени может уже не быть: у удалённого моба набора навыков нет.
 */
/obj/item/projectile/proc/ce_get_skill_arc()
	if(!ismob(firer) || QDELETED(firer))
		return 0
	var/skill = firer.ce_get_shooter_skill()
	if(isnull(skill))
		return 0
	return (SKILL_TRAINED - skill) * ce_skill_dispersion_arc_degrees


// ============================================================================================
// Круг тела
// ============================================================================================

/**
 * Расстояние от середины тела `body` до линии полёта, пиксели. null — линии нет: снаряд ещё не
 * запущен, либо моб не на карте.
 *
 * Линия — прямая через нынешнюю точку вектора по его направлению: после рикошета это уже
 * отражённая линия. Обход клеток вектором не пропускает клетку, чья середина ближе 11.3 пикселя к
 * линии, так что тело до 11 пикселей, стоящее посреди клетки, проверяется всегда.
 */
/obj/item/projectile/proc/ce_get_pass_distance(mob/living/body)
	if(!trajectory)
		return null
	var/list/center = body.ce_get_body_center()
	var/step_length = sqrt(trajectory.offset_x ** 2 + trajectory.offset_y ** 2)
	if(!center || !step_length)
		return null
	var/to_body_x = center[1] - trajectory.loc_x
	var/to_body_y = center[2] - trajectory.loc_y
	return abs(to_body_x * trajectory.offset_y - to_body_y * trajectory.offset_x) / step_length


/**
 * Снаряд проходит мимо тела `body`: его линия полёта лежит дальше радиуса тела. TRUE —
 * `attack_mob()` делать нечего: броска нет, урон с расстоянием не снимается, а кор `Bump()`
 * пропускает снаряд дальше и запоминает моба. Близкий пролёт слышен и виден, как промах Бэй.
 *
 * Выстрел в упор по тому, в кого целились, мимо не проходит: ствол упёрт в тело. Живой щит держат
 * на пути всего, что летит в держащего: мимо щита проходит только снаряд, чья линия не задела ни
 * его тела, ни тела держащего.
 */
/obj/item/projectile/proc/ce_misses_body(mob/living/body)
	if(!ce_physical_hits_active() || !istype(body))
		return FALSE
	if(ce_point_blank && body == original)
		return FALSE
	var/pass_distance = ce_get_pass_distance(body)
	if(isnull(pass_distance))
		return FALSE
	var/radius = body.ce_get_hit_radius()
	if(pass_distance <= radius)
		return FALSE
	var/mob/living/holder = ce_get_shield_holder(body)
	if(holder && ce_crosses_body(holder))
		return FALSE
	if(ce_last_missed != body)
		ce_last_missed = body
		ce_show_flyby(body, pass_distance, radius)
	return TRUE


/// Линия полёта проходит через тело `body`. FALSE и тогда, когда линии нет.
/obj/item/projectile/proc/ce_crosses_body(mob/living/body)
	var/pass_distance = ce_get_pass_distance(body)
	return !isnull(pass_distance) && pass_distance <= body.ce_get_hit_radius()


/// Пролёт мимо тела слышен и виден: снаряд не бесшумный и прошёл ближе `ce_near_miss_margin_px` от
/// тела радиуса `radius`.
/obj/item/projectile/proc/ce_is_near_miss(pass_distance, radius)
	return !silenced && pass_distance - radius < ce_near_miss_margin_px


/// Пролёт мимо тела: отладка стрелку, а близкий пролёт — сообщение и свист, как у промаха Бэй.
/obj/item/projectile/proc/ce_show_flyby(mob/living/body, pass_distance, radius)
	if(ce_aim_debug)
		ce_tell_gunners("Pass: \the [src] passes \the [body] at [round(pass_distance, 0.1)] px, body radius [round(radius, 0.1)].")
	if(!ce_is_near_miss(pass_distance, radius))
		return
	body.visible_message(SPAN_NOTICE("\The [src] misses [body] narrowly!"))
	if(LAZYLEN(miss_sounds))
		playsound(body.loc, pick(miss_sounds), 60, 1)


// ============================================================================================
// Повтор столкновения
// ============================================================================================
// Работает и без выключателей: это ошибка Бэй, а не часть модели попаданий.

/**
 * Забирает повтор столкновения: TRUE — `Bump()` делать нечего.
 *
 * Клетка, не пустившая снаряд, зовёт `Bump()` сама, с `called` (`/turf/Enter()`), а следом то же
 * столкновение повторяет BYOND — без `called` и с тем, что преградой считает он: с любым плотным
 * предметом в клетке. Кор версия гасит повтор флагом `bumped`, но снаряд, прошедший мимо моба —
 * броском или пролётом, — этот флаг снимает. Повтор приходил ему новым попаданием: пуля, не
 * попавшая в стоящего у окна, разбивалась об окно на краю его клетки, даже летя вдоль него.
 */
/obj/item/projectile/proc/ce_take_bump_echo(called)
	if(called)
		ce_bump_resolved = TRUE
		return FALSE
	return ce_bump_resolved


/**
 * Снаряд, прошедший мимо моба `passed`, встречает остальных плотных мобов в его клетке: клетка
 * зовёт `Bump()` только для первого, кто снаряд не пустил, а второго раньше задевал разве что
 * повтор столкновения. FALSE — снаряд на этом кончился.
 */
/obj/item/projectile/proc/ce_meet_tile_bodies(mob/living/passed)
	if(QDELETED(src) || !istype(passed) || !(passed in permutated))
		return TRUE
	var/turf/place = get_turf(passed)
	if(!place || loc != place)
		return TRUE
	for(var/mob/living/body in place)
		if(body == passed || !body.density || (body in permutated))
			continue
		if(Bump(body, TRUE) || QDELETED(src))
			return FALSE
	return TRUE


// ============================================================================================
// Живой щит
// ============================================================================================
// Кор `Bump()` отдаёт снаряд, летящий в лицо держащему, сперва живому щиту, а после промаха по щиту
// бросает ещё раз — уже по держащему. Здесь щит решает за обоих: попал — щит, промахнулся — снаряд
// летит дальше мимо обоих. Держащего за щитом задевает только пуля, прошедшая щит насквозь.

/**
 * Моб, которым `holder` прикрывается от этого снаряда как живым щитом, или null. Условия — кор
 * `Bump()`: первый захват в руках держит щитом, а снаряд летит держащему в лицо, с отклонением не
 * больше 45°.
 */
/obj/item/projectile/proc/ce_get_living_shield(mob/living/holder)
	RETURN_TYPE(/mob/living)
	var/obj/item/grab/grab = locate() in holder
	if(!grab?.shield_assailant())
		return null
	var/front = GLOB.reverse_dir[holder.dir & 0xF]
	if(!(dir in list(front, GLOB.cw_dir_8[front], GLOB.ccw_dir_8[front])))
		return null
	return grab.affecting


/// Тот, кто прикрывается мобом `body` от этого снаряда как живым щитом, или null.
/obj/item/projectile/proc/ce_get_shield_holder(mob/living/body)
	RETURN_TYPE(/mob/living)
	for(var/obj/item/grab/grab in body.grabbed_by)
		var/mob/living/holder = grab.assailant
		if(istype(holder) && ce_get_living_shield(holder) == body)
			return holder
	return null


/**
 * Снаряд, промахнувшийся по живому щиту, не задевает и того, кто им прикрылся: TRUE —
 * `attack_mob()` делать нечего, кор `Bump()` пропускает снаряд дальше. Пуля, которая в щит попала
 * и прошла его насквозь, сюда не относится: по щиту она не промахнулась.
 */
/obj/item/projectile/proc/ce_passes_shield_holder(mob/living/holder)
	if(!ce_physical_hits_active() || !istype(holder) || !ce_last_missed)
		return FALSE
	if(ce_get_living_shield(holder) != ce_last_missed)
		return FALSE
	if(ce_aim_debug)
		ce_tell_gunners("Pass: \the [src] missed \the [ce_last_missed] held as a shield and passes \the [holder] too.")
	return TRUE


// ============================================================================================
// Лежащие
// ============================================================================================

/**
 * Неплотный живой моб в клетке `place`, в теле которого лежит точка `point` (пиксели вектора); из
 * нескольких — тот, чья середина ближе. Плотного снаряд встречает сам, а лежащего в Бэй задевает,
 * только если целились в него.
 */
/obj/item/projectile/proc/ce_find_prone_body(turf/place, list/point)
	RETURN_TYPE(/mob/living)
	var/mob/living/nearest
	var/nearest_distance
	for(var/mob/living/body in place)
		if(body.density || body == firer)
			continue
		var/list/center = body.ce_get_body_center()
		var/distance = sqrt((point[1] - center[1]) ** 2 + (point[2] - center[2]) ** 2)
		if(distance > body.ce_get_hit_radius())
			continue
		if(nearest && distance >= nearest_distance)
			continue
		nearest = body
		nearest_distance = distance
	return nearest


/**
 * Выстрел по клетке, чья точка прицела `aim_point` легла в тело лежащего, — выстрел по нему: целью
 * снаряда становится этот моб, и дальше его встречает кор `Process()`, как любого лежащего, в
 * которого целились. Пуля, летящая над лежащим в цель за ним, его по-прежнему не задевает. Клик по
 * пятну крови под лежащим — тот же клик по клетке (`ce_take_floor_target()`). Зовётся из
 * `ce_aim_trajectory()`, пока вектор ещё не нацелен: точка прицела остаётся той, по которой
 * щёлкнули.
 */
/obj/item/projectile/proc/ce_take_prone_target(list/aim_point)
	if(!ce_physical_hits_active() || !isturf(original))
		return
	var/mob/living/body = ce_find_prone_body(original, aim_point)
	if(body)
		original = body


// ============================================================================================
// Бросок
// ============================================================================================

/**
 * Зона, в которую снаряд попал по мобу `target_mob`, целясь в `zone`, или null — мимо. Зовётся из
 * кор `attack_mob()` вместо `get_zone_with_miss_chance()`; с выключенными физическими попаданиями
 * зовёт её же, с поправкой и расстоянием Бэй (`bay_miss_modifier`, `bay_distance`).
 *
 * Бросок Авроры (`calculate_zone_with_miss_chance()`): провал с шансом `ce_get_miss_chance()`, и
 * провал — это `ce_miss_pass_share` мимо, иначе случайная зона. Случайная зона — по размерам частей
 * тела (`ran_zone()`), а не равновероятная, как в Авроре.
 */
/obj/item/projectile/proc/ce_get_projectile_hit_zone(zone, mob/living/target_mob, bay_miss_modifier, bay_distance)
	if(!ce_physical_hits_active())
		//if the projectile hits a target we weren't originally aiming at then retain the chance to miss
		return get_zone_with_miss_chance(zone, target_mob, bay_miss_modifier, ranged_attack = (bay_distance > 1 || original != target_mob))
	var/distance = ce_get_hit_distance(target_mob, bay_distance)
	if(ce_is_sure_hit(target_mob, distance))
		ce_report_roll(target_mob, zone, distance, null, FALSE, zone)
		return zone
	zone = check_zone(zone)
	var/miss_chance = ce_get_miss_chance(zone, distance)
	var/hit_zone = zone
	var/failed = prob(miss_chance)
	if(failed)
		hit_zone = prob(ce_miss_pass_share) ? null : ran_zone()
	if(!hit_zone)
		ce_last_missed = target_mob
	ce_report_roll(target_mob, zone, distance, miss_chance, failed, hit_zone)
	return hit_zone


/**
 * Расстояние до цели для броска, клетки: от клетки выстрела — после рикошета от клетки рикошета —
 * до клетки моба, как в Авроре. Кор `Bump()` считает его до клетки самого снаряда, а перед плотным
 * мобом снаряд стоит на клетку ближе. У снаряда, который ещё не запущен, — осколок гранаты,
 * взорвавшейся в руке, — берётся расстояние вызвавшего.
 */
/obj/item/projectile/proc/ce_get_hit_distance(mob/living/target_mob, bay_distance)
	var/turf/target_turf = get_turf(target_mob)
	if(!starting || !target_turf)
		return bay_distance
	return get_dist(starting, target_turf)


/**
 * По мобу бросок не нужен: он тот, в кого целились, стоит вплотную, и выстрел сделан в упор — либо
 * моб лежит, пристёгнут или схвачен так, что не увернуться. Правило Авроры; у Бэй сюда же шла
 * цель на намерении помощи.
 */
/obj/item/projectile/proc/ce_is_sure_hit(mob/living/target_mob, distance)
	if(original != target_mob || distance > 1)
		return FALSE
	if(ce_point_blank || target_mob.buckled || target_mob.lying)
		return TRUE
	for(var/obj/item/grab/grab in target_mob.grabbed_by)
		if(grab.stop_move())
			return TRUE
	return FALSE


/**
 * Шанс провалить бросок по зоне `zone` с `distance` клеток, проценты: шанс зоны плюс поправка —
 * `ce_miss_per_tile` за клетку после первой и `special_miss_modifier` вызвавшего, минус точность
 * снаряда. Поправка не ниже нуля, как в Авроре: точность гасит расстояние, а шанс зоны не трогает.
 * Навыка и движения цели в броске нет: навык — это дуга разброса и очки точности, которые кор
 * `process_accuracy()` уже положил в `hitchance_mod`.
 */
/obj/item/projectile/proc/ce_get_miss_chance(zone, distance)
	var/zone_chance = ce_zone_miss_chances[zone]
	if(isnull(zone_chance))
		zone_chance = ce_zone_miss_chances[BP_CHEST]
	var/penalty = ce_miss_per_tile * (distance - 1) + ce_special_miss_modifier
	penalty -= ce_get_accuracy_points()
	return max(zone_chance + max(penalty, 0), 0)


/**
 * Сколько процентов шанса провала гасит точность снаряда: `hitchance_mod` по цене
 * `ce_miss_per_hitchance`, а у выстрела из оружия — ещё `ce_gun_accuracy_points`. Бывает меньше
 * нуля: громоздкое оружие в неумелых руках промахивается чаще.
 */
/obj/item/projectile/proc/ce_get_accuracy_points()
	. = hitchance_mod * ce_miss_per_hitchance
	if(ce_gun_shot)
		. += ce_gun_accuracy_points


/**
 * Отладка (`ce_aim_debug`): бросок попадания — стрелку в чат. `miss_chance` null — бросок не нужен.
 *
 * Пишутся исходы, а не шанс провала: проваленный бросок — это ещё не промах, и с шансом провала
 * выше 100 снаряд всё равно попадает в случайную зону в `100 − ce_miss_pass_share` случаях из ста.
 */
/obj/item/projectile/proc/ce_report_roll(mob/living/target_mob, zone, distance, miss_chance, failed, hit_zone)
	if(!ce_aim_debug)
		return
	if(isnull(miss_chance))
		ce_tell_gunners("Roll: \the [target_mob], [parse_zone(zone)], [distance] tiles: sure hit.")
		return
	var/fail_share = clamp(miss_chance, 0, 100)
	var/miss_share = round(fail_share * ce_miss_pass_share / 100, 0.1)
	var/stray_share = round(fail_share - miss_share, 0.1)
	var/outcome = "missed"
	if(!failed)
		outcome = "hit as aimed"
	else if(hit_zone)
		outcome = "stray hit in the [parse_zone(hit_zone)]"
	ce_tell_gunners("Roll: \the [target_mob], [parse_zone(zone)], [distance] tiles: as aimed [round(100 - fail_share, 0.1)]%, stray [stray_share]%, miss [miss_share]%; [outcome].")
