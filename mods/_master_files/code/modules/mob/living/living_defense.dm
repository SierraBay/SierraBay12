/*
	COMBAT_EXTENDED — сторона моба.

	`modify_damage_by_armor()` и `get_blocked_ratio()` обязаны давать одинаковый ответ, поэтому
	проход по слоям у них общий — `ce_walk_armor_layers()` (`mods/combat_extended/code/armor_layers.dm`),
	а отличаются они только побочными эффектами.
*/

/*
	Боевой проход. Для некинетических ключей уходим в кор код, на старую процентную формулу.
	Зональная броня и там читается по зоне попадания, поэтому кор код зовётся внутри контекста.
	Луч идёт своим проходом (`mods/combat_extended/code/laser_heat.dm`): жёсткая броня держит его
	вычитанием и греется, остальные слои он отдаёт кор коду.
*/
/mob/living/modify_damage_by_armor(def_zone, damage, damage_type, damage_flags, mob/living/victim, armor_pen, silent = FALSE)
	if(damage <= 0 || !ce_uses_kinetic_path(damage_type, damage_flags))
		if(!def_zone)
			def_zone = ran_zone()
		var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))
		// Маркер явного пробития кор коду непонятен: там ждут число.
		var/core_armor_pen = istype(armor_pen, /datum/ce_explicit_pen) ? 0 : armor_pen
		// Итог снаряду считается до `..()`: блок может изменить саму броню (`on_blocking()`).
		var/obj/item/projectile/projectile = damage > 0 ? ce_take_hit_projectile(damage, damage_type) : null
		if(projectile)
			projectile.ce_note_armor_outcome(ce_get_percent_pass_share(def_zone, damage, damage_type, damage_flags, core_armor_pen))
		var/datum/extension/armor/shield_armor = ce_get_shield_armor(def_zone)
		var/shield_stopped = damage > 0 && shield_armor?.ce_percent_stops(damage, damage_type, damage_flags, core_armor_pen)
		if(shield_stopped)
			// Щит, остановивший луч, забирает его целиком: процентная формула Bay пропустила бы
			// часть урона даже под бронёй, но жар остаётся в щите, а не в теле за ним.
			damage = 0
			. = args.Copy(2)
		else if(damage > 0 && ce_is_laser_heat_attack(damage_type, damage_flags))
			var/list/result = ce_walk_laser_layers(def_zone, damage, damage_type, damage_flags, core_armor_pen, TRUE, victim, silent, projectile)
			damage = result[1]
			damage_flags = result[2]
			armor_pen = core_armor_pen
			. = args.Copy(2)
		else
			. = ..(def_zone, damage, damage_type, damage_flags, victim, core_armor_pen, silent)
		ce_set_hit_body_part(outer_body_part)
		ce_resolve_shield_hit(def_zone, shield_stopped, 0)
		return

	var/list/result = ce_walk_armor_layers(def_zone, damage, damage_type, damage_flags, armor_pen, TRUE, victim, silent)
	ce_resolve_shield_hit(def_zone, result[6], result[7])
	// Остаточный удар — вторичная атака, снаряду он не принадлежит.
	if(!istype(armor_pen, /datum/ce_explicit_pen))
		var/obj/item/projectile/projectile = ce_take_hit_projectile(damage, damage_type)
		if(projectile)
			projectile.ce_note_armor_outcome(ce_get_walk_pass_share(result, damage))

	// Присваивание параметру меняет и `args`, поэтому обновлённые значения уезжают в
	// возвращаемом списке — ровно так же, как это делает кор код.
	damage = result[1]
	damage_flags = result[2]
	armor_pen = result[3]

	// Родной тупой урон контекста не пишет и остаётся на правиле Bay.
	if(result[5])
		ce_note_hit(def_zone, 0)
	else if(ce_is_sharp_attack(damage_flags))
		ce_note_hit(def_zone, ce_organ_reach(armor_pen, damage_flags))

	var/list/residual = result[4]
	if(residual && ce_residual_blunt_enabled)
		ce_queue_residual(def_zone, residual[1], residual[2])

	return args.Copy(2)


/**
 * Доля остановленного урона, 0..1. `armor_pen` — на старой шкале 0–100.
 *
 * У CE такого числа нет: его результат — «столько урона дошло», а не «такая доля остановлена».
 * Поэтому здесь оно СИНТЕЗИРУЕТСЯ как `1 - урон_после / урон_до` тем же проходом по слоям,
 * но без побочных эффектов.
 */
/mob/living/get_blocked_ratio(def_zone, damage_type, damage_flags, armor_pen, damage)
	if(!ce_uses_kinetic_path(damage_type, damage_flags))
		// Как и в `modify_damage_by_armor()`: кор код внутри контекста зоны, луч — своим проходом.
		if(!def_zone)
			def_zone = ran_zone()
		if(damage > 0 && ce_is_laser_heat_attack(damage_type, damage_flags))
			var/list/result = ce_walk_laser_layers(def_zone, damage, damage_type, damage_flags, armor_pen)
			return clamp(1 - result[1] / damage, 0, 1)
		var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))
		. = ..(def_zone, damage_type, damage_flags, armor_pen, damage)
		ce_set_hit_body_part(outer_body_part)
		return

	if(damage <= 0)
		return 0

	var/list/result = ce_walk_armor_layers(def_zone, damage, damage_type, damage_flags, armor_pen)
	return clamp(1 - result[1] / damage, 0, 1)


/**
 * Попадание снаряда. Обёртка сообщает проходу по слоям, чьё это попадание, а сам проход пишет
 * снаряду, остановила ли его броня и какая доля урона её прошла (`projectile_effects.dm`). Итог
 * нужен снаряду внутри `..()` — в `after_wounding()` и `on_hit()` — и после неё стирается.
 * По нему же перед `on_hit()` гасятся боль и оглушение снаряда (`agony_armor.dm`), а после
 * `..()` обёртка их возвращает: снаряд, прошедший моба насквозь, бьёт следующего в полную силу.
 *
 * Внешний снаряд откладывается на время вызова, а не затирается: `on_hit()` может породить
 * вложенное попадание по тому же мобу — например, осколками взрыва.
 */
/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	var/obj/item/projectile/outer_projectile = ce_hit_projectile
	ce_hit_projectile = P
	P.ce_clear_armor_outcome()
	var/list/effects = P.ce_get_armor_effects()

	. = ..()

	P.ce_set_armor_effects(effects)
	P.ce_clear_armor_outcome()
	ce_hit_projectile = outer_projectile
