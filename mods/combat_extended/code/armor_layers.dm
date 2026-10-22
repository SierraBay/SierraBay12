/*
	COMBAT_EXTENDED — проход атаки по слоям брони.

	`ce_try_penetrate()` пробивает один слой (§7.1 спеки), `ce_walk_armor_layers()` ведёт атаку по
	всем слоям зоны. Их зовут оверрайды в `_master_files`: слоя — в
	`datums/extensions/armor/armor.dm`, моба — в `modules/mob/living/living_defense.dm`.

	Мод ведёт проход по слоям сам, а не подменяет поведение отдельного слоя. Причина в §7.2:
	чтобы пересобрать остановленную острую атаку в тупую, нужны величины ВСЕЙ атаки до первого
	слоя — исходный урон, исходное пробитие и собственное тупое пробитие. В сигнатуру
	`apply_damage_modifications()` они не помещаются, а менять её в кор коде нельзя.

	Пробитие РАСХОДУЕТСЯ: слой, вставший первым, забирает свои миллиметры из общего бюджета, поэтому
	слои обязаны проверяться строго снаружи внутрь. `get_armors_by_zone()` так их и выдаёт у всех
	мобов. У человека он живёт не в кор коде, а в `mods/ipc_mods/code/prosthetics.dm`.

	Сразу после `get_armors_by_zone()` список правит хук `ce_order_armors()`: порядок слоёв, если
	моб выдаёт их не снаружи внутрь, — второй раз один и тот же путь объявить нельзя, — и слои
	вторичной атаки, которые по её урону и флагам уже не узнать. У экзокостюма оверрайд живёт в
	`mods/mechs_by_shegar` (`mech_damage.dm`) и внешний бронеэлемент части ставит первым сам, а хук
	возвращает этот бронеэлемент остаточному удару пули (`mech_plates.dm`).
*/

/**
 * Ядро CE: попытка пробить один слой брони по §7.1 спеки. Пробитие именно РАСХОДУЕТСЯ, а не
 * сравнивается: пройдя слой в 3 мм, патрон на 7 мм идёт дальше как патрон на 4 мм.
 *
 * Чистая процедура — НИКАКИХ побочных эффектов. Её вызывает не только боевой проход по слоям,
 * но и `get_blocked_ratio()` ради шансов сбить с ног, застрять, вывихнуть сустав, а человеческая
 * рукопашка обращается к броне дважды за удар. Если бы здесь тратился бюджет пробития или
 * изнашивалась броня, настоящее попадание приходило бы уже по испорченной броне.
 *
 * `pen` — остаток пробития: мм RHA для острых атак, Bay МПа для тупых. Три параметра `base_*`
 * описывают атаку ЦЕЛИКОМ, до первого слоя: они нужны только конверсии по §7.2, где масштаб
 * берётся от исходных величин. Если их не передать, процедура считает себя единственным слоем —
 * в таком виде её и зовёт `get_blocked()`.
 *
 * `blunt_impact_mult` — множитель тупого пробития после рикошета, до проверки тупой брони этого
 * же слоя. Урон рикошета он не меняет. Не единица он только у щита, для пуль (`shields.dm`).
 *
 * Возвращает `list(урон, остаток пробития, флаги, доля остановленного, проверки)`. Проверки —
 * для износа брони: по `list(урон до, урон после, пробитие, рейтинг, острая ли)` на каждую
 * проверку слоя. Остановленную острую атаку слой проверяет дважды — по острой оси и сразу по тупой.
 */
/datum/extension/armor/proc/ce_try_penetrate(damage, damage_flags, pen, base_damage, base_pen, base_blunt_pen, blunt_impact_mult = 1)
	if(damage <= 0)
		return list(0, pen, damage_flags, 0, list())

	if(isnull(base_damage))
		base_damage = damage
	if(isnull(base_pen))
		base_pen = pen
	if(isnull(base_blunt_pen))
		base_blunt_pen = ce_derive_blunt_penetration(base_damage, damage_flags)

	var/is_sharp = ce_is_sharp_attack(damage_flags)
	var/armor_value = is_sharp ? get_armor_sharp(damage_flags) : get_armor_blunt()

	if(armor_value <= 0)
		return list(damage, pen, damage_flags, 0, list(list(damage, damage, pen, 0, is_sharp)))

	// Вырожденный случай из §7.1: без пробития множитель равен единице, иначе деление на ноль.
	if(pen <= 0)
		return list(damage, 0, damage_flags, 0, list(list(damage, damage, 0, armor_value, is_sharp)))

	var/new_pen = pen - armor_value
	var/dmg_mult = clamp(new_pen / pen, 0, 1)

	if(dmg_mult > 0)
		var/new_damage = damage * dmg_mult
		return list(new_damage, new_pen, damage_flags, 1 - dmg_mult, list(list(damage, new_damage, pen, armor_value, is_sharp)))

	// Тупая атака просто гасится. Рикошетить ей некуда.
	if(!is_sharp)
		return list(0, 0, damage_flags, 1, list(list(damage, 0, pen, armor_value, FALSE)))

	// Острая атака рикошетит и становится тупой (§7.2). `pen` здесь — пробитие ДО этого слоя: в
	// спеке при остром рикошете значения намеренно не трогаются, потому что атака пересобирается
	// из дослойных величин. Кубический корень не даёт остановленной пуле остаться смертельной:
	// она бьёт как удар, а не как пробитие.
	var/blunt_pen
	var/blunt_damage

	if(damage_flags & DAMAGE_FLAG_BULLET)
		var/pen_multi = base_pen > 0 ? clamp(pen / base_pen, 0, 1) : 0
		blunt_pen = base_blunt_pen * pen_multi
		blunt_damage = ce_cbrt(10 * blunt_pen)
		// Аналог дробления атаки из CE (`attack.damage / damageAmountBase`): пуля, уже
		// потерявшая часть урона на внешних слоях, несёт пропорционально меньший импульс.
		if(base_damage > 0)
			blunt_damage *= clamp(damage / base_damage, 0, 1)
	else
		// Холодное оружие — намеренное исключение из спеки: ни масштабирования по остатку
		// пробития, ни по потерянному урону. Меч, остановленный латами, всё равно прилетает
		// как тяжёлая железка на полной силе.
		blunt_pen = base_blunt_pen
		blunt_damage = ce_cbrt(10 * blunt_pen)

	blunt_pen *= blunt_impact_mult
	var/blunt_armor = get_armor_blunt()
	var/blunt_mult = blunt_pen > 0 ? clamp((blunt_pen - blunt_armor) / blunt_pen, 0, 1) : 0
	var/final_damage = blunt_damage * blunt_mult
	var/final_flags = damage_flags & ~(DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE | DAMAGE_FLAG_BULLET)

	return list(
		final_damage,
		max(0, blunt_pen - blunt_armor),
		final_flags,
		clamp(1 - final_damage / damage, 0, 1),
		list(list(damage, 0, pen, armor_value, TRUE), list(blunt_damage, final_damage, blunt_pen, blunt_armor, FALSE))
	)


/**
 * Проход атаки по слоям брони снаружи внутрь. `armor_pen` — пробитие на старой шкале 0–100 либо
 * маркер явного тупого пробития `/datum/ce_explicit_pen`.
 *
 * `apply_effects` (износ и осколки, `on_blocking()`, сообщения жертве) разделяет два вызова, которые обязаны
 * считать ОДИНАКОВО, но вести себя по-разному. `/mob/living/carbon/human/hit_with_weapon` сначала
 * спрашивает долю блока ради броска на сбивание с ног, и только потом наносит урон. Пойди
 * консультационный вызов с побочными эффектами — броня изнашивалась бы от вопроса о ней.
 *
 * Возвращает `list(урон, флаги, остаток пробития, остаточный удар, перенесено наружу,
 * остановлена щитом, тупая волна от щита)`. Остаточный удар — `list(урон, тупое пробитие)` или
 * null. «Перенесено наружу» — атака срикошетила или сама вторична, и до органов не доходит.
 *
 * Щит на пути попадания (`shields.dm`) — первый слой. Острое, которое он остановил, до зоны
 * попадания не доходит вовсе: тупой урон рикошета уходит волной в руку со щитом, мимо брони.
 * Нематериальный щит (`ce_armor_nonphysical`) волны не даёт: остановленное он гасит целиком.
 * Парирующее оружие (`weapon_parry.dm`) — тоже первый слой, но в руку уходит всё тупое, что его
 * прошло; дальше идёт только пробившее его острое. Как делить, решает сам слой
 * (`ce_split_shield_blow()`).
 */
/mob/living/proc/ce_walk_armor_layers(def_zone, damage, damage_type, damage_flags, armor_pen, apply_effects = FALSE, mob/living/victim, silent = FALSE)
	var/base_pen
	var/base_blunt_pen
	var/datum/ce_explicit_pen/explicit = istype(armor_pen, /datum/ce_explicit_pen) ? armor_pen : null
	if(explicit)
		// Остаточный удар везёт своё тупое пробитие с собой: из урона и флагов его не вывести.
		base_pen = explicit.pen
		base_blunt_pen = explicit.pen
	else
		base_pen = ce_derive_penetration(damage, damage_flags, armor_pen)
		base_blunt_pen = ce_derive_blunt_penetration(damage, damage_flags, armor_pen)
	var/base_damage = damage
	var/pen = base_pen
	var/was_sharp = ce_is_sharp_attack(damage_flags)
	// Флаги меняются на рикошете, поэтому множитель износа берётся до прохода. У остаточного
	// удара флагов нет и от пули его не отличить, а оружие, которое его родило, свой износ уже
	// сняло первым проходом, поэтому он изнашивает без множителя.
	var/wear_mult = explicit ? 1 : ce_get_wear_mult(damage_flags)

	// Зональная броня читается и изнашивается по зоне попадания (`armor_zones.dm`). Зону без
	// попадания выбираем здесь, а не в `get_armors_by_zone()`: иначе слои и зона износа
	// разошлись бы.
	if(!def_zone)
		def_zone = ran_zone()
	var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))

	var/list/armors = ce_order_armors(get_armors_by_zone(def_zone, damage_type, damage_flags), def_zone, !!explicit)
	var/datum/extension/armor/shield_armor = ce_get_shield_armor(def_zone)
	var/shield_stopped = FALSE
	var/shield_shock = 0

	for(var/armor in armors)
		var/datum/extension/armor/armor_datum = armor
		var/is_shield = armor_datum == shield_armor
		var/impact_mult = (is_shield && (damage_flags & DAMAGE_FLAG_BULLET)) ? ce_shield_bullet_impact_mult : 1
		var/list/step = armor_datum.ce_try_penetrate(damage, damage_flags, pen, base_damage, base_pen, base_blunt_pen, impact_mult)
		var/blocked = step[4]

		if(apply_effects)
			// Износ брони и трата псионической силы считаются от ЕЩЁ НЕ ИЗМЕНЁННЫХ флагов:
			// ключ, который надо изнашивать, определяется до возможной конверсии.
			armor_datum.on_blocking(damage, damage_type, damage_flags, pen, blocked)
			armor_datum.ce_apply_wear(step[5], wear_mult, src, def_zone)
			// О блоке щитом сообщает сам щит (`ce_resolve_shield_hit()`).
			if(!silent && !is_shield)
				if(blocked > 0.7)
					to_chat(victim, SPAN_NOTICE(armor_datum.full_block_message))
				else if(blocked > 0.2)
					to_chat(victim, SPAN_NOTICE(armor_datum.partial_block_message))

		var/sharp_before = ce_is_sharp_attack(damage_flags)
		damage = step[1]
		pen = step[2]
		damage_flags = step[3]

		// Щит или парирующее оружие делит прошедшее на волну в руку и урон дальше.
		if(is_shield)
			var/list/split = armor_datum.ce_split_shield_blow(damage, sharp_before, ce_is_sharp_attack(damage_flags))
			shield_shock = split[1]
			damage = split[2]
			if(damage <= 0)
				shield_stopped = TRUE

		if(damage <= 0)
			break

	ce_set_hit_body_part(outer_body_part)

	var/list/residual
	var/relocated = !!explicit
	if(was_sharp && !ce_is_sharp_attack(damage_flags))
		// Рикошет. CE переносит его на внешнюю часть тела (`GetFirstOuterPart`), байевский
		// эквивалент — не пускать его к органам.
		relocated = TRUE
	else if(was_sharp)
		// Плотность тканей — шаг 4 в CE, после всей брони. Тратит только пробитие.
		pen = max(0, pen - ce_part_density(def_zone))
		residual = ce_residual_blunt(damage, pen, base_damage, base_pen, base_blunt_pen)

	return list(damage, damage_flags, pen, residual, relocated, shield_stopped, shield_shock)


/**
 * Правит список слоёв: порядок снаружи внутрь и слои, которых `get_armors_by_zone()` не выдал.
 * Проход по слоям зовёт его сразу после неё.
 *
 * `secondary` — атака вторичная, то есть остаточный удар (`residual_blunt.dm`). Он обязан встретить
 * те же слои, что и основное попадание, а по его урону и флагам их уже не узнать: он тупой и без
 * флагов.
 */
/mob/living/proc/ce_order_armors(list/armors, def_zone, secondary = FALSE)
	return armors
