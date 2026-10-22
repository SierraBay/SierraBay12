/*
	COMBAT_EXTENDED — снаряд, остановленный бронёй, в тело не входит (`projectile_effects.dm`),
	задевший стену вскользь — рикошетит (`projectile_ricochet.dm`), летит он в пиксель, по
	которому щёлкнули (`projectile_aim.dm`), а пройдя мимо тела, летит дальше без броска
	(`projectile_hits.dm`).
*/

/**
 * Застревание, разрыв артерии и брызги крови — эффекты снаряда, вошедшего в тело. Остановленный
 * бронёй снаряд бьёт тупым ударом, и порез от такого удара — рана от удара, а не от снаряда.
 */
/obj/item/projectile/after_wounding(obj/item/organ/external/organ, datum/wound/wound)
	if(ce_penetration_effects_enabled && ce_armor_stopped)
		return
	return ..()


/**
 * Рикошет от стены решается до кор версии: отскочивший снаряд в стену не попадает, и её
 * `bullet_act()` не зовётся (`/mods/combat_extended/code/projectile_ricochet.dm`). Повтор
 * столкновения от BYOND гасится, а мобов, стоящих в одной клетке с тем, мимо кого снаряд прошёл,
 * он встречает сам (`/mods/combat_extended/code/projectile_hits.dm`).
 */
/obj/item/projectile/Bump(atom/atom, called)
	// Снаряд, который уже попал и удалён, ни с чем больше не сталкивается. Клетка, не пустившая
	// снаряд, зовёт `Bump()` сама, а следом то же столкновение повторяет BYOND; кор версия гасит
	// повтор флагом `bumped`, но пролёт мимо живого щита этот флаг снимает, и держащий щит получал
	// одну пулю дважды.
	if(QDELETED(src))
		return FALSE
	// Через срезанный угол снаряд идёт двумя прямыми шагами, а летит по диагонали: кор версия по
	// `dir` решает, прикрыт ли моб живым щитом (`/mods/combat_extended/code/projectile_aim.dm`).
	ce_face_travel()
	// Повтор столкновения от BYOND — с любым плотным предметом в клетке — снаряд, прошедший мимо
	// моба, принимал за новое попадание: в окно вдоль полёта, во второго моба в клетке
	// (`/mods/combat_extended/code/projectile_hits.dm`).
	if(ce_take_ricochet_echo(atom, called) || ce_take_bump_echo(called) || ce_try_ricochet(atom, called))
		return FALSE
	// Моба в клетке, угол которой линия полёта только срезает, снаряд не задевает
	// (`/mods/combat_extended/code/projectile_aim.dm`).
	if(ce_skip_corner_bump(atom))
		return FALSE
	ce_bump_depth++
	. = ..()
	ce_bump_depth--
	// Клетка зовёт `Bump()` только для первого, кто не пустил снаряд. Остальных плотных мобов в ней
	// снаряд, прошедший мимо первого, встречает сам.
	if(!. && !ce_bump_depth && !ce_meet_tile_bodies(atom))
		return TRUE


/**
 * Пиксель клика доходит до снаряда (`/mods/combat_extended/code/projectile_aim.dm`). Параметры
 * клика приходят уже разобранным списком, а кор версия разбирает их второй раз и получает пустой
 * список: ей они отдаются строкой.
 */
/obj/item/projectile/set_clickpoint(params)
	if(!ce_pixel_aim_enabled)
		return ..()
	ce_note_click(params)
	return ..(islist(params) ? list2params(params) : params)


/// Кор версия строит вектор из середины клетки в середину клетки, целыми градусами. После неё вектор
/// нацеливается в точку прицела (`/mods/combat_extended/code/projectile_aim.dm`).
/obj/item/projectile/setup_trajectory(turf/startloc, turf/targloc, x_offset = 0, y_offset = 0)
	. = ..()
	ce_aim_trajectory()


/**
 * Физические попадания (`/mods/combat_extended/code/projectile_hits.dm`). Снаряд, чья линия полёта
 * прошла мимо тела, и снаряд, промахнувшийся по живому щиту, которым моб прикрылся, до броска не
 * доходят: кор `Bump()` пропускает их дальше, как после промаха. Остальным запоминается
 * `special_miss_modifier` вызвавшего: кор версия до броска вычитает из своего навык стрелка, а в
 * броске Авроры навыка нет.
 */
/obj/item/projectile/attack_mob(mob/living/target_mob, distance, special_miss_modifier = 0)
	if(ce_passes_shield_holder(target_mob) || ce_misses_body(target_mob))
		return FALSE
	ce_special_miss_modifier = special_miss_modifier
	return ..()


/**
 * Диагональный шаг BYOND делает прыжком, а линия полёта между двумя точками вектора проходит ещё
 * одну клетку — срезает её угол. Сперва снаряд идёт в неё, и стена в ней его останавливает
 * (`/mods/combat_extended/code/projectile_aim.dm`).
 *
 * Куда снаряд смотрит, когда клетка зовёт его `Bump()`, решает сборка BYOND: одни успевают повернуть
 * его по шагу, другие нет. Кор `Bump()` по `dir` решает, прикрыт ли моб живым щитом, поэтому
 * направление шага снаряд запоминает сам (`ce_face_travel()`).
 */
/obj/item/projectile/Move(newloc, direct)
	. = FALSE
	ce_bump_resolved = FALSE
	ce_travel_dir = isturf(newloc) ? get_dir(src, newloc) : null
	if(ce_pass_cut_corner(newloc))
		// У шага в срезанный угол столкновения свои.
		ce_bump_resolved = FALSE
		. = ..()
	ce_travel_dir = null
