/*
	COMBAT_EXTENDED — вывод пробития АТАКИ из тех значений, которые у неё уже есть.

	Зеркало `armor_conversion.dm` в тех же единицах, иначе формула `damage *= (pen - armor) / pen`
	не имеет смысла.

	`armor_penetration` как есть не годится: это «процент игнорируемой брони» на шкале 0–100, и у
	большинства пуль он ноль — прямая подстановка дала бы им нулевой урон по любой броне. Вывести
	пробитие только из урона тоже нельзя: `pistol` и `rifle` имеют ОДИНАКОВЫЙ урон 45 и различаются
	только `armor_penetration` (0 против 25). Поэтому пробитие — кривая по урону или силе удара плюс
	вклад `armor_penetration`.
*/


/**
 * Множитель пробития от `armor_penetration`, строго больше нуля. `divisor` — один из `CE_AP_DIVISOR_*`.
 *
 * Положительная ветка линейная: `+divisor` удваивает пробитие. На ней откалиброваны опорные точки
 * холодного оружия. Острое пробитие пуль её не берёт: там AP прибавляет миллиметры
 * (`ce_ap_sharp_bonus_bullet()`), а сюда приходит только отрицательный.
 *
 * Отрицательная ветка — обратная величина: `-divisor` пробитие ВДВОЕ УМЕНЬШАЕТ. Линейную
 * формулу продолжать в минус нельзя: при `armor_pen = -divisor` она дала бы ровно ноль, а
 * дальше — отрицательное пробитие, что сломало бы `(pen - armor) / pen`. Отрицательный AP нужен
 * снарядам, которые пробивают броню просто за счёт большого урона, а по замыслу должны работать
 * по ней ХУЖЕ обычного, — например, экспансивной `bullet/shotgun/manstopper`.
 */
/proc/ce_ap_multiplier(armor_pen, divisor)
	if(armor_pen >= 0)
		return 1 + armor_pen / divisor
	return 1 / (1 - armor_pen / divisor)


/**
 * Острое пробитие, которое `armor_penetration` прибавляет пуле, мм RHA.
 *
 * AP пули ПРИБАВЛЯЕТСЯ к пробитию калибра, а не умножает его: бронебойный сердечник добавляет
 * миллиметры, сколько бы ни весила пуля. С множителем вклад AP рос вместе с уроном, и тяжёлые
 * бронебойные пули уходили за верх лестницы брони.
 *
 * Первые единицы AP стоят больше остальных: ранний бонус набирается быстрее всего в начале и к
 * `CE_AP_EARLY_BONUS_RANGE_BULLET` затухает до нуля, так что прибавка нигде не меньше линейной и
 * нигде не даёт излома. Логарифм не подошёл: он растёт без конца, и обрезать его на конце разгона
 * значит получить излом.
 */
/proc/ce_ap_sharp_bonus_bullet(armor_pen)
	ASSERT(armor_pen >= 0)
	var/unspent = 1 - min(armor_pen, CE_AP_EARLY_BONUS_RANGE_BULLET) / CE_AP_EARLY_BONUS_RANGE_BULLET
	return armor_pen * CE_AP_MM_PER_POINT_BULLET + CE_AP_EARLY_BONUS_MM_BULLET * (1 - unspent ** 2)


/// Кубический корень для тупого урона CE: `(10 * bluntPen) ^ (1/3)`.
/proc/ce_cbrt(value)
	if(value <= 0)
		return 0
	return value ** (1 / 3)


/**
 * Острое ли это попадание в терминах CE. Ось определяется флагами САМОЙ АТАКИ, а не тем, из какого
 * ключа брони читается значение.
 */
/proc/ce_is_sharp_attack(damage_flags)
	return (damage_flags & (DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE)) ? TRUE : FALSE


/**
 * Идёт ли эта атака по пути CE, или остаётся на старой процентной формуле. Мод трогает ровно два
 * ключа брони из девяти. `bomb`, `laser`, `energy`, `bio`, `rad` и `psi` остаются отдельными
 * системами, и вместе с ними продолжают работать `armor_range_mult`, `under_armor_mult` и
 * `over_armor_mult` — включая настройку из `mods/guns/code/armor.dm` и `/datum/extension/armor/mech`.
 */
/proc/ce_uses_kinetic_path(damage_type, damage_flags)
	var/key = get_armor_key(damage_type, damage_flags)
	return (key == "bullet" || key == "melee")


/**
 * Пробитие атаки в единицах CE: мм RHA для острых атак, Bay МПа для тупых. `damage` у холодного
 * оружия — `force`, `armor_pen` может быть отрицательным.
 *
 * Вызывается ОДИН раз на атаку, до прохода по слоям брони: дальше каждый слой расходует уже
 * пересчитанное значение.
 */
/proc/ce_derive_penetration(damage, damage_flags, armor_pen = 0)
	if(damage <= 0)
		return 0

	if(!ce_is_sharp_attack(damage_flags))
		return ce_evaluate_curve(ce_pen_curve_blunt, damage) * CE_BLUNT_PEN_MELEE_MULT * ce_ap_multiplier(armor_pen, CE_AP_DIVISOR_MELEE)

	if(damage_flags & DAMAGE_FLAG_BULLET)
		var/sharp_pen = ce_evaluate_curve(ce_pen_curve_bullet, damage)
		// Отрицательный AP делит: вычитание миллиметров ушло бы в ноль и ниже.
		if(armor_pen < 0)
			return sharp_pen * ce_ap_multiplier(armor_pen, CE_AP_DIVISOR_BULLET)
		return sharp_pen + ce_ap_sharp_bonus_bullet(armor_pen)

	return ce_evaluate_curve(ce_pen_curve_melee, damage) * ce_ap_multiplier(armor_pen, CE_AP_DIVISOR_MELEE)


/// Тупое пробитие атаки, Bay МПа: то, чем она бьёт, когда её острую часть остановила броня.
/proc/ce_derive_blunt_penetration(damage, damage_flags, armor_pen = 0)
	if(damage <= 0)
		return 0

	// Импульс от заточки сердечника не зависит, но `armor_penetration` здесь всё равно участвует:
	// в Bay только он отличает винтовку от пистолета с тем же уроном.
	if(damage_flags & DAMAGE_FLAG_BULLET)
		var/blunt_pen = min(damage, CE_BLUNT_PEN_BULLET_KNEE) * CE_BLUNT_PEN_PER_BULLET_DAMAGE
		if(damage > CE_BLUNT_PEN_BULLET_KNEE)
			blunt_pen *= (damage / CE_BLUNT_PEN_BULLET_KNEE) ** CE_BLUNT_PEN_BULLET_EXPONENT
		return blunt_pen * min(ce_ap_multiplier(armor_pen, CE_AP_DIVISOR_BULLET_BLUNT), CE_AP_MAX_MULT_BULLET_BLUNT)

	return ce_evaluate_curve(ce_pen_curve_blunt, damage) * CE_BLUNT_PEN_MELEE_MULT * ce_ap_multiplier(armor_pen, CE_AP_DIVISOR_MELEE)


/obj/item/projectile
	/// Собственное тупое пробитие снаряда на полном уроне, Bay МПа. null — выводится из урона и AP
	/// (`ce_derive_blunt_penetration()`). Задаётся патронам, у которых вывод далёк от импульса пули:
	/// урон Bay с её весом почти не связан (`code/items/guns/bullets.dm`).
	var/ce_blunt_penetration


/**
 * Тупое пробитие атаки, Bay МПа: собственное у снаряда, чьё это попадание, иначе выведенное из
 * урона. Снаряд узнаётся по `ce_hit_projectile` (`projectile_effects.dm`), так что консультационный
 * и боевой проходы одного попадания получают одно число.
 */
/mob/living/proc/ce_get_attack_blunt_penetration(damage, damage_type, damage_flags, armor_pen)
	var/obj/item/projectile/projectile = ce_get_hit_projectile(damage, damage_type)
	if(projectile && !isnull(projectile.ce_blunt_penetration))
		return projectile.ce_get_own_blunt_penetration()
	return ce_derive_blunt_penetration(damage, damage_flags, armor_pen)


/**
 * Собственное тупое пробитие снаряда на его текущем уроне, Bay МПа. Убывает вместе с уроном, как и
 * выведенное: пуля на излёте (`damage_falloff`) и прошедшая моба навылет несёт меньший импульс.
 */
/obj/item/projectile/proc/ce_get_own_blunt_penetration()
	ASSERT(!isnull(ce_blunt_penetration))
	var/full_damage = initial(damage)
	if(full_damage <= 0)
		return 0
	return ce_blunt_penetration * damage / full_damage
