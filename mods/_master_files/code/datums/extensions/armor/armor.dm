/*
	COMBAT_EXTENDED — детерминированное вычитание CE вместо кривой урона Bay и конверсия острого в
	тупое по §7.2 спеки. Только для ключей `bullet` и `melee`: остальные уходят в `..()`, на старую
	процентную формулу. Сам слой считает `ce_try_penetrate()` (`mods/combat_extended/code/armor_layers.dm`).
*/

// Потолок в 100 снят: ARMOR_BALLISTIC_HEAVY равен 110, и старый `min(..., 100)` молча
// обрезал верхний тир лестницы до уровня ARMOR_BALLISTIC_AP.
/datum/extension/armor/get_value(key)
	if(!armor_values)
		return 0
	if(isnull(armor_values[key]))
		return 0
	return armor_values[key] * ce_get_condition()

// Здесь потолок снят по той же причине: иначе первый же удар по броне с рейтингом 110
// сбрасывал бы её до 100 через износ.
/datum/extension/armor/set_value(key, newval)
	armor_values[key] = max(0, newval)


/**
 * Доля остановленного урона одним слоем, 0..1.
 *
 * Публичный помощник: его дёргают и снаружи пайплайна — перерезание горла в
 * `code/modules/mob/grab/normal/grab_normal.dm` спрашивает каску напрямую. Без этого оверрайда та
 * проверка осталась бы единственным местом в игре, читающим броню по старой процентной формуле
 * для кинетической атаки.
 *
 * В отличие от `ce_try_penetrate()`, сюда `armor_pen` приходит на СТАРОЙ шкале 0–100: это
 * самостоятельная точка входа, а не звено в проходе по слоям, поэтому перевод делается здесь.
 */
/datum/extension/armor/get_blocked(damage_type, damage_flags, armor_pen = 0, damage = 5)
	if(!ce_uses_kinetic_path(damage_type, damage_flags))
		return ..()

	if(damage <= 0)
		return 0

	var/list/step = ce_try_penetrate(damage, damage_flags, ce_derive_penetration(damage, damage_flags, armor_pen))
	return clamp(1 - step[1] / damage, 0, 1)


/*
	Боевой проход по слоям сюда НЕ заходит — его целиком ведёт `/mob/living/modify_damage_by_armor`.
	Кинетическая ветка — для прямых вызовов со стороны: она считает слой как единственный.
*/
/datum/extension/armor/apply_damage_modifications(damage, damage_type, damage_flags, mob/living/victim, armor_pen, silent = FALSE)
	if(damage <= 0)
		return args.Copy()

	if(!ce_uses_kinetic_path(damage_type, damage_flags))
		return ..()

	var/list/result = ce_try_penetrate(damage, damage_flags, armor_pen)
	var/blocked = result[4]

	// Износ брони и трата псионической силы считаются от ИСХОДНЫХ флагов: ключ, который надо
	// изнашивать, определяется до возможной конверсии острого в тупое.
	on_blocking(damage, damage_type, damage_flags, armor_pen, blocked)
	ce_apply_wear(result[5], ce_get_wear_mult(damage_flags))

	damage = result[1]
	armor_pen = result[2]
	damage_flags = result[3]

	if(!silent)
		if(blocked > 0.7)
			to_chat(victim, SPAN_NOTICE(full_block_message))
		else if(blocked > 0.2)
			to_chat(victim, SPAN_NOTICE(partial_block_message))

	return args.Copy()
