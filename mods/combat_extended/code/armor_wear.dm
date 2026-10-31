/*
	COMBAT_EXTENDED — износ брони.

	У каждого расширения брони на предмете есть HP. Попадание снимает их по формулам §8 спеки,
	а рейтинг читается через кривую состояния §4. Кривая применяется в `get_value()`, поэтому
	износ видят сразу все оси CE и процентный путь laser/energy/bomb — как в CE, где от HP зависит
	каждый рейтинг вещи.

	HP дробные и живут на расширении, а не в здоровье атома. Так вещь не ломается от ударов по
	ней на полу, а дробный износ не теряется. Поэтому стохастического округления из спеки здесь
	нет: CE округляет только потому, что HP в RimWorld целые.

	Износ считается только боевым проходом. `ce_try_penetrate()` остаётся чистой и лишь
	описывает, какие проверки слой прошёл; снимает HP `ce_apply_wear()`. Жёсткую броню луч
	изнашивает жаром (`laser_heat.dm`), через тот же `ce_take_wear()`.

	У зональной брони свой запас HP на каждую группу зон (`armor_zones.dm`), поэтому HP читаются и
	пишутся только через `ce_get_health()` и `ce_set_health()`.

	Максимум HP не меняется и после починки хламом (`armor_repair.dm`): починка опускает только
	предел, до которого HP можно вернуть, а кривая состояния читает HP от максимума.
*/

/obj/item
	/// Нематериальная вещь — поле, а не вещество: не изнашивается ни как броня, ни как оружие при
	/// парировании (`weapon_parry.dm`). Нематериальный щит ещё и не передаёт тупой волны в руку
	/// (`shields.dm`). Задаётся в блоке вещи в `code/items/`.
	var/ce_armor_nonphysical = FALSE

/// Броня вещи только что потеряла HP. `group` — группа зон зональной брони либо null. Сам износ
/// с вещью ничего не делает: рейтинг падает по кривой состояния, а что делать с изношенной вещью,
/// решает она.
/obj/item/proc/ce_on_armor_worn(group)
	return

/datum/extension/armor
	/// Текущие HP. null — вещь ещё не изнашивалась.
	var/ce_health
	/// Максимум HP. Выводится при первом износе и дальше не меняется.
	var/ce_health_max


/**
 * Сколько HP снимает с брони одна проверка слоя, по §8 спеки. `pen` и `armor_value` — по оси
 * проверки: мм RHA для острой атаки, Bay МПа для тупой.
 */
/proc/ce_armor_wear_amount(damage, new_damage, pen, armor_value, is_sharp, is_hard)
	if(damage <= 0)
		return 0

	if(!is_hard)
		if(!is_sharp)
			return 0
		return max(damage * CE_SOFT_ARMOR_MIN_WEAR, damage - new_damage)

	if(pen <= 0 || armor_value <= 0)
		return 0
	if(!is_sharp && pen / armor_value < CE_ELASTIC_BLUNT_RATIO)
		return 0

	var/stopped_wear = (damage - new_damage) * min(1, (pen / armor_value) ** ce_armor_wear_ratio_exponent)
	var/passed_wear = new_damage * clamp(armor_value / pen, 0, 1)
	return (stopped_wear + passed_wear) * CE_HARD_ARMOR_WEAR_FACTOR


/// Множитель износа для атаки. Флаги — исходные, до конверсии острого в тупое.
/proc/ce_get_wear_mult(damage_flags)
	if(damage_flags & DAMAGE_FLAG_BULLET)
		return 1
	return ce_armor_melee_wear_mult


/**
 * Может ли эта броня изнашиваться. Изнашиваются только вещи: естественная броня мобов — это
 * §11 спеки, отдельная механика, а корпус протеза — часть тела со своим уроном. Нематериальной
 * вещи (`ce_armor_nonphysical`) изнашиваться нечему.
 */
/datum/extension/armor/proc/ce_can_wear()
	if(!istype(holder, /obj/item) || istype(holder, /obj/item/organ))
		return FALSE
	var/obj/item/armor_item = holder
	if(armor_item.ce_armor_nonphysical)
		return FALSE
	for(var/exempt_type in ce_armor_wear_exempt_extensions)
		if(istype(src, exempt_type))
			return FALSE
	return TRUE


/// Множитель рейтинга 0..1 по кривой состояния, для зоны текущего попадания. Его читает `get_value()`.
/datum/extension/armor/proc/ce_get_condition()
	return ce_get_group_condition(ce_get_wear_group())


/**
 * Множитель рейтинга 0..1 группы зон по кривой состояния.
 *
 * Вывод максимума HP отсюда не зовётся: он читает рейтинги через `get_value()`, а `get_value()`
 * зовёт эту процедуру. Пока максимум не выведен, броня считается целой.
 */
/datum/extension/armor/proc/ce_get_group_condition(group)
	var/health = ce_get_health(group)
	if(!ce_armor_wear_enabled || isnull(health) || !ce_health_max)
		return 1
	var/health_fraction = health / (ce_health_max * ce_get_zone_health_mult(group))
	var/break_point = ce_get_break_point()
	if(break_point)
		health_fraction *= ce_get_curve_break_point(ce_armor_condition_curve) / break_point
	return ce_evaluate_curve(ce_armor_condition_curve, health_fraction)


/**
 * Доля HP, на которой множитель рейтинга опускается до `condition`, — обратная к
 * `ce_get_group_condition()`, с той же точкой поломки материала.
 */
/datum/extension/armor/proc/ce_get_condition_health_fraction(condition)
	. = ce_invert_curve(ce_armor_condition_curve, condition)
	var/break_point = ce_get_break_point()
	if(break_point)
		. *= break_point / ce_get_curve_break_point(ce_armor_condition_curve)


/// Точка поломки кривой состояния: наименьшая доля HP, на которой рейтинг ещё полный.
/proc/ce_get_curve_break_point(list/curve)
	for(var/list/point as anything in curve)
		if(point[2] >= 1)
			return point[1]
	return 1


/// Своя точка поломки брони — точка её материала (`armor_materials.dm`). null — броня ломается по
/// самой кривой состояния.
/datum/extension/armor/proc/ce_get_break_point()
	var/singleton/ce_armor_material/material = ce_get_material()
	return material.break_point


/// Сглаживает линейные HP от рейтинга выше излома `ce_armor_health_knee_mm`.
/proc/ce_flatten_armor_health(health)
	var/knee = ce_armor_health_knee_mm * ce_armor_health_per_mm
	if(health <= knee)
		return health
	return knee * (health / knee) ** ce_armor_health_exponent


/**
 * Максимум HP группы зон. Выводится из рейтингов один раз, при первом износе, пока броня ещё
 * целая: изношенная читает рейтинги уже через кривую состояния. Рейтинги — холодные: первый износ
 * часто приходит от луча, когда броня уже раскалена (`laser_heat.dm`).
 *
 * Доля головных уборов, множитель материала и доля вторичных зон берутся уже после нижней
 * границы `ce_armor_health_min` и могут опустить HP ниже неё.
 */
/datum/extension/armor/proc/ce_get_health_max(group)
	if(isnull(ce_health_max))
		var/best_sharp = max(ce_get_cold_sharp_ballistic(), ce_get_cold_sharp_melee())
		var/health_max = ce_flatten_armor_health(max(best_sharp * ce_armor_health_per_mm, ce_get_cold_blunt() * ce_armor_health_per_blunt))
		health_max = max(ce_armor_health_min, health_max)
		if(istype(holder, /obj/item/clothing/head))
			health_max *= ce_armor_health_head_mult
		var/singleton/ce_armor_material/material = ce_get_material()
		ce_health_max = health_max * material.health_mult
	return ce_health_max * ce_get_zone_health_mult(group)


/**
 * Снимает HP за попадание с группы зон текущего попадания. Зовётся только боевым проходом.
 * `tests` — проверки слоя из `ce_try_penetrate()`, по `list(урон до, урон после, пробитие,
 * рейтинг, острая ли)` на каждую.
 *
 * `wearer` и `def_zone` — в кого и куда летит осколок (`armor_shards.dm`). Без них осколков нет:
 * прямой вызов со стороны зоны попадания не знает.
 *
 * Раскалённая броня изнашивается быстрее (`ce_get_hot_wear_mult()`, `laser_heat.dm`).
 */
/datum/extension/armor/proc/ce_apply_wear(list/tests, wear_mult = 1, mob/living/wearer, def_zone)
	if(!ce_armor_wear_enabled || !length(tests) || !ce_can_wear())
		return

	var/is_hard = is_hard_armor()
	var/wear = 0
	for(var/list/test as anything in tests)
		wear += ce_armor_wear_amount(test[1], test[2], test[3], test[4], test[5], is_hard)
	ce_take_wear(wear * wear_mult * ce_get_hot_wear_mult(), wearer, def_zone)


/**
 * Снимает `wear` HP с группы зон текущего попадания: сообщения носителю, звук поломки и осколок.
 * Общая часть износа от кинетического прохода (`ce_apply_wear()`) и от луча (`laser_heat.dm`).
 */
/datum/extension/armor/proc/ce_take_wear(wear, mob/living/wearer, def_zone)
	if(!ce_armor_wear_enabled || wear <= 0 || !ce_can_wear())
		return

	var/group = ce_get_wear_group()
	var/health_max = ce_get_health_max(group)
	var/old_state = ce_get_wear_state(group)
	var/old_percent = ce_get_health_percent(group)
	var/old_health = ce_get_health(group)
	if(isnull(old_health))
		old_health = health_max
	var/new_health = max(0, old_health - wear)
	ce_set_health(group, new_health)
	ce_report_wear(group, old_state, isnull(old_percent) ? 100 : old_percent)
	if(wearer && prob(ce_get_shard_chance(group, old_health, new_health)))
		wearer.ce_queue_shard(def_zone, holder)
	var/obj/item/armor_item = holder
	armor_item.ce_on_armor_worn(group)


/**
 * Звук поломки, когда броня проходит свою точку поломки, и сообщения носителю о смене состояния
 * и об износе.
 */
/datum/extension/armor/proc/ce_report_wear(group, old_state, old_percent)
	var/obj/item/armor_item = holder
	var/new_state = ce_get_wear_state(group)
	// Словесное состояние есть только у неполного рейтинга: его появление и есть проход точки.
	if(!old_state && new_state)
		var/singleton/ce_armor_material/material = ce_get_material()
		playsound(armor_item, material.break_sound, material.break_sound_volume, TRUE)

	var/mob/wearer = get_holder_of_type(armor_item, /mob)
	if(!istype(wearer))
		return
	var/armor_name = group ? "[armor_item.name] ([group])" : armor_item.name
	if(new_state != old_state)
		to_chat(wearer, SPAN_WARNING("Your [armor_name] is [new_state]!"))
	else if(ce_get_health_percent(group) < old_percent)
		to_chat(wearer, SPAN_WARNING("The condition of your [armor_name] worsens."))


/// Состояние брони для осмотра, в процентах оставшихся HP. null — броня не изнашивалась или износ выключен.
/datum/extension/armor/proc/ce_get_health_percent(group)
	var/health = ce_get_health(group)
	if(!ce_armor_wear_enabled || isnull(health))
		return null
	return round(100 * health / ce_get_health_max(group))


/**
 * Строки осмотра о состоянии брони, пустой list у неизношенной. У зональной брони — по строке на
 * каждую группу зон, как только износилась хоть одна. `label` — чья это броня, если осматривают
 * не её вещь.
 */
/datum/extension/armor/proc/ce_get_condition_lines(label)
	RETURN_TYPE(/list)
	. = list()
	var/list/groups = ce_get_zone_groups()
	if(!length(groups))
		var/percent = ce_get_health_percent()
		if(!isnull(percent))
			. += ce_format_condition_line(label, percent, ce_get_health_cap_percent())
		return
	if(!ce_armor_wear_enabled || !LAZYLEN(ce_zone_health))
		return
	for(var/group in groups)
		var/percent = ce_get_health_percent(group)
		. += ce_format_condition_line(label ? "[label], [group]" : group, isnull(percent) ? 100 : percent, ce_get_health_cap_percent(group))


/// Строка осмотра: «Armor condition: 90%/100%» — HP и предел починки (`armor_repair.dm`), оба в
/// процентах максимума. У брони, которую не латали, предел — 100%.
/proc/ce_format_condition_line(label, percent, cap_percent = 100)
	return label ? "Armor condition ([label]): [percent]%/[cap_percent]%" : "Armor condition: [percent]%/[cap_percent]%"


/**
 * Словесное состояние брони для сообщений, null — пока рейтинг полный. Пороги стоят на множителе
 * рейтинга, а не на HP, так что они сами следуют за кривой состояния.
 */
/datum/extension/armor/proc/ce_get_wear_state(group)
	var/condition = ce_get_group_condition(group)
	if(condition >= 1)
		return null
	if(condition <= 0)
		return "ruined"
	if(condition < 0.25)
		return "nearly ruined"
	if(condition < 0.5)
		return "badly damaged"
	return "damaged"

