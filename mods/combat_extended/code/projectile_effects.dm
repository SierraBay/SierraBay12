/*
	COMBAT_EXTENDED — эффекты снарядов, зависящие от пробития.

	Остановила ли броня снаряд и какая доля его урона её прошла, решает проход по слоям. До
	снаряда это знание раньше не доходило: `on_hit()` получает только долю блока 0..1, а
	`after_wounding()` — рану. Теперь проход записывает итог самому снаряду, в `ce_armor_stopped`
	и `ce_armor_pass_share`, и его читают три точки:

	- `after_wounding()` — у всех снарядов, оверрайд в `_master_files`. Остановленный снаряд в тело
	  не вошёл: он не застревает и не перебивает артерию. Порез Bay всё равно может сделать и
	  тупым уроном (`prob(brute)` в `take_external_damage()`), но это рана от удара, а не дыра от
	  пули. На застревании держится и нульглас: его пуля глушит псионику осколком в ране.
	- `on_hit()` — только у снаряда с `ce_effects_need_penetration`. Остановленный бронёй, он
	  получает полный блок Bay, как от щита в `human/bullet_act()`. Что значит полный блок, решает
	  сам `on_hit()`: базовый отказывается от всех эффектов, дротик не впрыскивает. Эффекты,
	  которым броня не помеха, снаряд оставит сам — так, как оставлял их за щитом.
	- боль и оглушение — у всех снарядов, перед `on_hit()` (`agony_armor.dm`).

	Остановленным считается снаряд, который:
	- на пути CE — погашен, если тупой, или срикошетил и стал тупым, если острый;
	- на процентном пути Bay — не превысил брони какого-то слоя. На этой границе Bay и сам снимает с
	  атаки остроту и лазерный флаг (`apply_damage_modifications()`), а погасить урон целиком
	  процентная формула не может: доля блока слоя всегда меньше единицы;
	- луч, который жёсткая броня держит вычитанием (`laser_heat.dm`), — не прошёл слой ни единицей
	  урона.

	Лучи (`ce_hard_only_stop_keys`) останавливает только жёсткая броня. Мягкая — скафандр, одежда —
	их урон ослабляет, как в Bay, но для итога снаряда прозрачна: stun-луч проходит скафандр с
	полной болью.

	Долю блока в `on_hit()` передаёт кор `bullet_act()`, а `on_hit()` дротика `..()` не зовёт.
	Подменить её поэтому можно только там — правка `[SIERRA-EDIT]` в `living_defense.dm`.

	Итог живёт на снаряде только внутри `bullet_act()`: снаряд, прошедший моба насквозь, попадает
	в следующего с чистым листом.
*/

/// Полный блок в `on_hit()`. Так его передаёт щит в `human/bullet_act()`, а базовый `on_hit()`
/// проверяет `blocked >= 100`. Доля блока от брони — 0..1.
#define CE_ON_HIT_FULL_BLOCK 100

/obj/item/projectile
	/// Эффекты `on_hit()` требуют пробить броню: остановленный бронёй снаряд получает полный блок.
	/// Задаётся в блоке снаряда в `code/items/guns/`.
	var/ce_effects_need_penetration = FALSE
	/// Остановила ли броня снаряд в попадании, которое сейчас разбирает `bullet_act()`. null —
	/// через броню снаряд не проходил: у него нет урона, у моба нет прохода по слоям, или
	/// попадание уже разобрано.
	var/ce_armor_stopped
	/// Доля урона снаряда, прошедшая броню в том же попадании, 0..1. У остановленного — 0. null —
	/// тогда же, когда и у `ce_armor_stopped`.
	var/ce_armor_pass_share

/mob/living
	/// Снаряд, чьё попадание разбирает `bullet_act()`, пока проход по слоям не запишет ему итог.
	var/obj/item/projectile/ce_hit_projectile


/**
 * Снаряд, которому принадлежит этот проход по слоям, или null. `modify_damage_by_armor()` оружия
 * не получает, так что снаряду принадлежит проход с его уроном и типом урона. Чистый запрос: снаряд
 * остаётся на мобе — по нему проход берёт собственное тупое пробитие снаряда.
 */
/mob/living/proc/ce_get_hit_projectile(damage, damage_type)
	var/obj/item/projectile/projectile = ce_hit_projectile
	if(!projectile || damage != projectile.damage || damage_type != projectile.damage_type)
		return null
	return projectile


/**
 * То же, но снаряд забирается: его получает первый боевой проход. Остаточный удар и урон из самого
 * `on_hit()` — облучение, взрыв — его итог уже не перепишут.
 */
/mob/living/proc/ce_take_hit_projectile(damage, damage_type)
	var/obj/item/projectile/projectile = ce_get_hit_projectile(damage, damage_type)
	if(projectile)
		ce_hit_projectile = null
	return projectile


/// Записывает снаряду итог прохода по слоям: долю урона, прошедшую броню. 0 — броня его остановила.
/obj/item/projectile/proc/ce_note_armor_outcome(pass_share)
	ce_armor_pass_share = pass_share
	ce_armor_stopped = pass_share <= 0


/// Стирает итог прохода: попадание ещё не началось или уже разобрано.
/obj/item/projectile/proc/ce_clear_armor_outcome()
	ce_armor_stopped = null
	ce_armor_pass_share = null


/// Доля блока для `on_hit()`: `blocked` как есть либо полный блок, если эффектам снаряда нужно
/// пробитие, а броня его остановила.
/obj/item/projectile/proc/ce_get_on_hit_blocked(blocked)
	if(ce_penetration_effects_enabled && ce_effects_need_penetration && ce_armor_stopped)
		return CE_ON_HIT_FULL_BLOCK
	return blocked


/**
 * Доля урона удара, которую пропустит броня зоны, 0..1. 0 — броня удар остановит. Чистый запрос:
 * броня не изнашивается. Удар без урона касается брони с нулевым пробитием
 * (`ce_armor_stops_contact()`). `armor_pen` — на старой шкале 0–100.
 */
/mob/living/proc/ce_get_armor_pass_share(def_zone, damage, damage_type, damage_flags, armor_pen)
	if(damage <= 0)
		return ce_armor_stops_contact(def_zone, damage_type, damage_flags) ? 0 : 1
	if(ce_uses_kinetic_path(damage_type, damage_flags))
		return ce_get_walk_pass_share(ce_walk_armor_layers(def_zone, damage, damage_type, damage_flags, armor_pen), damage)
	return ce_get_percent_pass_share(def_zone, damage, damage_type, damage_flags, armor_pen)


/// Доля урона, прошедшая броню, по итогу `ce_walk_armor_layers()`. 0 — атака остановлена.
/proc/ce_get_walk_pass_share(list/result, damage)
	if(result[5] || result[1] <= 0)
		return 0
	return clamp(result[1] / damage, 0, 1)


/**
 * Доля урона, прошедшая броню по процентной формуле Bay, 0..1. Слои проходятся так же, как в кор
 * `modify_damage_by_armor()`: каждый следующий получает урон, уже ослабленный предыдущими. 0 —
 * урон не превысил брони какого-то слоя (`ce_is_under_armor()`) или жёсткая броня остановила луч
 * целиком (`ce_try_burn_through()`). Слой, который атаку остановить не может (`ce_can_stop()`),
 * здесь пропускается целиком.
 */
/mob/living/proc/ce_get_percent_pass_share(def_zone, damage, damage_type, damage_flags, armor_pen)
	ASSERT(damage > 0)
	if(!def_zone)
		def_zone = ran_zone()
	// Зональная броня читается по зоне попадания, как и в самом проходе.
	var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))
	var/remaining = damage
	for(var/datum/extension/armor/armor_datum as anything in get_armors_by_zone(def_zone, damage_type, damage_flags))
		if(!armor_datum.ce_can_stop(damage_type, damage_flags))
			continue
		if(armor_datum.ce_uses_laser_heat(damage_type, damage_flags))
			var/list/burn = armor_datum.ce_try_burn_through(remaining, armor_pen)
			remaining = burn[1]
			if(remaining <= 0)
				break
			continue
		var/blocked = armor_datum.get_blocked(damage_type, damage_flags, armor_pen, remaining)
		if(armor_datum.ce_is_under_armor(blocked))
			remaining = 0
			break
		remaining *= 1 - blocked
	ce_set_hit_body_part(outer_body_part)
	return remaining / damage


/**
 * Не превысил ли урон брони слоя. `blocked` — доля блока слоя от `get_blocked()`. Граница — та же,
 * на которой `apply_damage_modifications()` снимает с атаки остроту: доля блока от урона, равного
 * броне. Слой без брони по ключу атаки блока не даёт и не останавливает ничего.
 */
/datum/extension/armor/proc/ce_is_under_armor(blocked)
	return blocked > 0 && blocked >= 1 - (under_armor_mult * 1/armor_range_mult)


/**
 * Останавливает ли броня зоны касание — удар без урона, а значит и без пробития. Его держит любой
 * слой с ненулевой бронёй против удара, который вообще может его остановить (`ce_can_stop()`).
 * Удар без ключа брони не держит ничто: броня его не видит. Подкожная броня касание не держит:
 * она под кожей, а касание приходится на кожу (`ce_is_under_skin()`).
 */
/mob/living/proc/ce_armor_stops_contact(def_zone, damage_type, damage_flags)
	if(!get_armor_key(damage_type, damage_flags))
		return FALSE
	if(!def_zone)
		def_zone = ran_zone()
	var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))
	. = FALSE
	for(var/datum/extension/armor/armor_datum as anything in get_armors_by_zone(def_zone, damage_type, damage_flags))
		if(armor_datum.ce_is_under_skin())
			continue
		if(armor_datum.ce_can_stop(damage_type, damage_flags) && armor_datum.ce_get_armor_against(damage_type, damage_flags) > 0)
			. = TRUE
			break
	ce_set_hit_body_part(outer_body_part)


/// Может ли слой остановить атаку. Лучи (`ce_hard_only_stop_keys`) останавливает только жёсткая броня.
/datum/extension/armor/proc/ce_can_stop(damage_type, damage_flags)
	return is_hard_armor() || !(get_armor_key(damage_type, damage_flags) in ce_hard_only_stop_keys)


/// Броня слоя против атаки — в той шкале, в которой её читает проход по слоям.
/datum/extension/armor/proc/ce_get_armor_against(damage_type, damage_flags)
	if(ce_uses_kinetic_path(damage_type, damage_flags))
		return ce_is_sharp_attack(damage_flags) ? get_armor_sharp(damage_flags) : get_armor_blunt()
	return get_value(get_armor_key(damage_type, damage_flags))

#undef CE_ON_HIT_FULL_BLOCK
