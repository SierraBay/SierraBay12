/*
	COMBAT_EXTENDED — остаточный тупой удар при частичном пробитии (§7.3 спеки).

	Пуля, пробившая плиту, отдаёт ей часть энергии, и эта часть бьёт по телу как удар — так же,
	как у остановленной пули в §7.2, только слабее. Удар наносится отдельной атакой и заново
	проходит все слои по тупой оси — CE точно так же заново зовёт `TakeDamage`.

	Холодное оружие масштабируется так же, как пули: дословный CE берёт для него полное тупое
	пробитие, и энергомеч через light-плиту бил бы сильнее, чем по голой цели.
*/

/**
 * Явное тупое пробитие атаки, которое нельзя вывести из её урона и флагов.
 *
 * Едет в аргументе `armor_pen` вместо числа: все три реализации `apply_damage()` этот
 * аргумент только передают дальше, так что ни сигнатуры, ни состояние моба менять не нужно.
 * `ce_walk_armor_layers()` разворачивает его раньше любого вывода пробития.
 *
 * Сейчас его несёт только остаточный удар. Проход по слоям заодно понимает по нему, что атака
 * вторичная, и не пускает её к органам.
 */
/datum/ce_explicit_pen
	/// Тупое пробитие, Bay МПа.
	var/pen = 0

/datum/ce_explicit_pen/New(pen)
	..()
	src.pen = pen


/**
 * Остаточный тупой удар от острой атаки, которая пробила слои, но потеряла на них урон:
 * `list(урон, тупое пробитие в Bay МПа)` либо null. `pen` — остаток после брони И плотности тканей.
 *
 * Чистая процедура. Её зовёт `ce_walk_armor_layers()` на каждом проходе, включая
 * консультационный, а выключатель проверяет уже `modify_damage_by_armor()`.
 */
/proc/ce_residual_blunt(damage, pen, base_damage, base_pen, base_blunt_pen)
	// По голой цели урон не теряется, поэтому и остаточного удара там нет.
	if(base_damage <= 0 || base_pen <= 0 || damage >= base_damage)
		return null

	var/pen_lost = clamp((base_pen - pen) / base_pen, 0, 1)
	var/damage_lost = clamp((base_damage - damage) / base_damage, 0, 1)
	var/blunt_pen = base_blunt_pen * pen_lost * damage_lost
	var/blunt_damage = ce_cbrt(10 * blunt_pen)
	if(blunt_damage <= 0)
		return null

	return list(blunt_damage, blunt_pen)


/**
 * Наносит остаточный удар от уже прошедшего основного попадания. Базовая версия наносит его сразу:
 * у простых мобов и экзокостюмов органов нет, и порядок ударов ни на что не влияет.
 */
/mob/living/proc/ce_queue_residual(def_zone, damage, blunt_pen)
	ce_apply_residual(def_zone, damage, blunt_pen)

/*
	Человеку удар наносится ПОСЛЕ основного, из обёртки `apply_damage()` в `_master_files`.
	Пойди он первым, как в CE, синяк мог бы оторвать конечность, а кор код держит `organ`,
	найденный ещё до брони.

	Зона запоминается строкой, а не органом: если основное попадание оторвало конечность, удар
	должен прийти в культю, а не в отлетевшую руку.
*/
/mob/living/carbon/human/ce_queue_residual(def_zone, damage, blunt_pen)
	var/obj/item/organ/external/organ = ce_resolve_organ(def_zone)
	if(!organ)
		return
	ce_pending_residual = list(organ.organ_tag, damage, blunt_pen)


/**
 * Сам удар: без флагов, без оружия, без сообщений. Застревание, разрыв артерии и данные
 * вскрытия второй раз не срабатывают — CE по той же причине отбрасывает `Weapon`.
 */
/mob/living/proc/ce_apply_residual(def_zone, damage, blunt_pen)
	apply_damage(damage, DAMAGE_BRUTE, def_zone, FLAGS_OFF, null, new /datum/ce_explicit_pen(blunt_pen), TRUE)


/mob/living/carbon/human
	/// Отложенный остаточный удар: `list(зона, урон, тупое пробитие)`. Живёт внутри одного
	/// вызова `apply_damage()`.
	var/list/ce_pending_residual
