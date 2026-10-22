/*
	COMBAT_EXTENDED — боль и оглушение против брони.

	В Bay боль (`agony`) идёт уроном `DAMAGE_PAIN`, у которого нет ключа брони. Снаряд вычитает из
	неё долю блока (`agony - blocked` в `on_hit()`), а доля от брони — 0..1: броня снимала не
	больше единицы боли. Когда же броня съедала весь урон, долю не считали вовсе, и боль шла
	целиком. Beanbag в merc-плиту причинял все свои 60 боли, stun-луч — все 40 сквозь любую броню.
	Остальное оглушение снаряда броня почти не трогала: сбивание с ног и муть в глазах режет
	`blocked_mult()`, который ждёт долю блока по шкале 0–100 и снимает доли процента, а оглушение
	`stun_effect_act()` на броню не смотрит вовсе.

	Теперь боль и оглушение проходят броню вместе с уроном:
	- удар, остановленный бронёй, боли не причиняет. Снаряд ещё и не оглушает, не сбивает с ног, не
	  мутит взгляд, не заставляет заикаться и не усыпляет — весь набор `on_hit()`, кроме облучения:
	  у того своя броня;
	- пробивший — причиняет боль по доле урона, прошедшей броню, в степени `ce_agony_pass_exponent`,
	  то есть меньше прямой доли. Остальное оглушение пробившего снаряда и оглушение дубинки
	  режутся тем же множителем;
	- удар без урона касается брони с нулевым пробитием, и его останавливает любой слой с
	  ненулевой бронёй против него (`ce_armor_stops_contact()`).

	Что значит «остановлен» и «доля урона», решает проход по слоям (`projectile_effects.dm`).
	Stun-луч (1–3 урона по ключу `energy`) не превышает никакой энергетической брони, но лучи
	останавливает только жёсткая броня: плиты, каски, наручи, РИГи. Скафандр и одежда урон луча
	ослабляют, а боль пропускают целиком. Пройти жёсткую броню луч может только за счёт
	`armor_penetration`: plasmastun с AP 10 проходит light-плиту с её energy 10. Сильные
	нелетальные пушки регулируются им же.

	Дубинка — оверрайд `apply_hit_effect()` в `_master_files`: удар по намерению вреда проходит
	броню как удар силой `force`, тычок урона не наносит и касается брони.

	Боль без ключа брони — токсичный болт арбалета, `DAMAGE_STUN` тёмной материи и дезориентатора —
	мод не трогает: броня её не видит ни в Bay, ни здесь. Сопротивление одежды току
	(`siemens_coefficient`) Bay применяет к боли поверх всего этого, в `human/stun_effect_act()`.

	Заодно исправлены две ошибки Bay, из-за которых боль снаряда шла не туда:
	- `bullet/on_hit()` звал `..()` без зоны попадания, и боль пули доставалась случайной
	  конечности — правка `[SIERRA-EDIT]` в `code/modules/projectiles/projectile/bullets.dm`;
	- `on_hit()` вычитал из боли долю блока и отдавал отрицательную боль (`ce_get_on_hit_agony()`).
*/

/// Множитель боли и оглушения удара, прошедшего броню долей `pass_share` урона.
/proc/ce_get_agony_mult(pass_share)
	if(pass_share <= 0)
		return 0
	return min(pass_share, 1) ** ce_agony_pass_exponent


/**
 * Боль для `stun_effect_act()` в `on_hit()`, правка `[SIERRA-EDIT]` в кор коде. Bay вычитает из неё
 * долю блока — наследие шкалы 0–100: доля от брони 0..1 снимает не больше единицы боли, а у
 * снаряда без боли даёт отрицательную. Отрицательная боль не безвредна: по ней `stun_act()`
 * конечности всё равно бросает на выпадение предмета и падение — по уже накопленной боли.
 *
 * С правилом мода боль уже прошла броню (`ce_apply_armor_to_effects()`), и доля не вычитается.
 * Без него вычитается, как в Bay, но не ниже нуля.
 */
/obj/item/projectile/proc/ce_get_on_hit_agony(blocked)
	if(ce_agony_armor_enabled)
		return agony
	return max(agony - blocked, 0)


/**
 * Боль и оглушение снаряда — по итогу прохода по слоям. Зовётся из кор `bullet_act()` прямо перед
 * `on_hit()`, правка `[SIERRA-EDIT]`. Весь набор `ce_get_armor_effects()` умножается на множитель
 * от доли урона, прошедшей броню: у остановленного снаряда он ноль. Прежние значения возвращает
 * обёртка `bullet_act()`: снаряд, прошедший моба насквозь, бьёт следующего в полную силу.
 *
 * Снаряд без урона или с `nodamage` броню не проходил и касается её с нулевым пробитием. Если же
 * прохода не было у снаряда с уроном, судить не по чему, и эффекты остаются как в Bay.
 */
/obj/item/projectile/proc/ce_apply_armor_to_effects(mob/living/target, def_zone)
	if(!ce_agony_armor_enabled)
		return
	var/pass_share = ce_armor_pass_share
	if(isnull(pass_share))
		if(damage > 0 && !nodamage)
			return
		pass_share = target.ce_get_armor_pass_share(def_zone, 0, damage_type, damage_flags())
	var/mult = ce_get_agony_mult(pass_share)
	var/list/effects = ce_get_armor_effects()
	for(var/i in 1 to length(effects))
		effects[i] *= mult
	ce_set_armor_effects(effects)


/// Эффекты снаряда, которые гасит броня: `list(agony, stun, weaken, paralyze, stutter, eyeblur, drowsy)`.
/obj/item/projectile/proc/ce_get_armor_effects()
	return list(agony, stun, weaken, paralyze, stutter, eyeblur, drowsy)


/// Возвращает снаряду эффекты в виде списка из `ce_get_armor_effects()`.
/obj/item/projectile/proc/ce_set_armor_effects(list/effects)
	agony = effects[1]
	stun = effects[2]
	weaken = effects[3]
	paralyze = effects[4]
	stutter = effects[5]
	eyeblur = effects[6]
	drowsy = effects[7]
