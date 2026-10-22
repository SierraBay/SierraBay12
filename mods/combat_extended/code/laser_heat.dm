/*
	COMBAT_EXTENDED — луч через жёсткую броню и нагрев брони.

	В Bay луч проходит каждый слой по процентной формуле: карабин G40E пропускает около 23% урона
	сквозь любую броню от 50 и выше, сколько бы раз ни попал, а саму броню не трогает. Здесь жёсткая
	броня на одежде держит луч вычитанием:

		рейтинг   R = laser × состояние × (1 − спад × температура ^ степень) − AP
		проходит  урон × clamp((урон − R) / урон, 0, 1)
		жар       остановленный урон × жар на урон × множитель луча × (1 − AP / делитель)

	Остановленная часть луча не пропадает, а греет броню. Температура 0..1 — это
	(жар / теплоёмкость) ^ степень, теплоёмкость — `(база + мм × толщина) × материал`, у брони головы,
	рук и ног меньше. Раскалённая броня держит луч чуть хуже и изнашивается от него кубически:
	холодную луч почти не портит. Абляционное покрытие забирает долю жара каждого попадания, пока не
	выгорит. Числа — в `_settings.dm`, свойства материалов — в `armor_materials.dm`.

	Жар живёт на расширении брони по группам зон, рядом с HP (`armor_zones.dm`): попадание в грудь
	греет торс скафандра, а не его рукава.

	Тёплая броня раз в секунду остывает (`ce_process_heat()`), пока не остынет совсем, и тогда
	снимается с обработки. Остывает она по расписанию: каждую полосу между ступенями накала — за
	свои секунды, в вакууме вдвое дольше, с включённым охладителем на носителе вдвое быстрее — за
	заряд его батареи. Подбой брони догоняет температуру лица со скоростью по проводимости материала
	и толщине, и носителя жжёт именно подбой: сталь печёт почти сразу, керамика — сильно позже.

	Ожоги идут в тик Life носителя, вместе с огнём (`ce_burn_from_hot_armor()`): на каждую надетую
	вещь или группу зон, поровну на закрытые ею части тела, мимо брони. И остывание, и ожоги считаются
	тиками, а не временем: лагающий сервер их замедляет, но не сваливает в один удар.

	Раскалённая броня хуже держит и пули с клинками: её Sharp и Blunt падают по размягчению
	материала (`ce_get_hot_kinetic_mult()`), а износ от них растёт (`ce_get_hot_wear_mult()`). HP
	брони выводятся по холодным рейтингам (`ce_get_cold_*()` в `armor_conversion.dm`).

	Мягкая броня от луча не греется, а обугливается (`ce_char_from_laser()`): луч изнашивает её
	вполовину слабее, чем острая атака с тем же уроном.

	Раскалённая вещь светится по ступеням накала: тусклый красный, красный, оранжевый, белое
	каление. Перерисовывается она только при смене ступени. Спрайт вещи и её картинка на носителе
	окрашиваются в цвет ступени. На носителе окраску даёт слой жара поверх всей одежды: в силуэте
	горячей вещи с её аксессуарами он умножает всё под собой на цвет ступени и прибавляет его же, с
	ореолом вокруг. Так светятся и подсумки, и то, что надето поверх, и ничего не прячется. С
	красного картинка на носителе светится мимо темноты (эмиссив). С оранжевого вещь ещё и светит, а
	над носителем дрожит горячий воздух, как над горячим газом, только слабее: один на носителя, по
	самой горячей вещи, которая на нём светится. Своего спрайта на носителе у
	пластин плитоноски нет, поэтому горячую пластину видно через плитоноску. Каждый луч ещё и
	оставляет на вещи прожог (`laser_scorch.dm`). При осмотре броня говорит, как раскалена, а кодекс
	печатает, сколько луча она держит и сколько жара вмещает.

	По этой формуле луч держит только жёсткая броня на одежде и внешние бронеэлементы мехов
	(`ce_uses_laser_heat()`, `ce_laser_heat_holders`). Мягкая броня, щиты, парирующее оружие и
	естественная броня мобов остаются на процентной формуле Bay. Бронеэлемент меха греется,
	размягчается и изнашивается как одежда, но не светится, не носит прожогов и никого не жжёт.

	Как с пробитием (`armor_layers.dm`), расчёт разделён на чистую процедуру и побочные эффекты.
	`ce_try_burn_through()` ничего не меняет: её зовут и консультационный проход, и итог снаряда
	(`projectile_effects.dm`). Жар, износ и покрытие накладывает `ce_absorb_laser()`, и только в
	боевом проходе.

	Проход луча по слоям — `ce_walk_laser_layers()`, его зовут оверрайды `modify_damage_by_armor()` и
	`get_blocked_ratio()` в `_master_files`. Слои, которые не греются, он отдаёт кор коду как есть.
	Поэтому граница Bay («урон не превысил брони слоя») по-прежнему снимает с луча лазерный флаг, и
	внутренние слои читают его уже как `energy`.
*/

/// Подбой ближе этого к температуре лица считается её догнавшим. Иначе экспонента не дошла бы до
/// нуля, и остывшая броня обрабатывалась бы вечно.
#define CE_LASER_INNER_SNAP 0.005

/// Фильтры свечения: оттенок и ореол. Приоритет — после фильтров роста (`height_system`), чтобы
/// ореол повторял уже подрезанный под рост силуэт.
#define CE_HEAT_TINT_FILTER "ce_heat_tint"
#define CE_HEAT_HALO_FILTER "ce_heat_halo"
#define CE_HEAT_FILL_FILTER "ce_heat_fill"
#define CE_HEAT_TINT_PRIORITY 20
#define CE_HEAT_HALO_PRIORITY 21

/obj/item/projectile
	/// Множитель жара луча: сколько жара несёт единица его урона, остановленная жёсткой бронёй.
	/// Задаётся в блоке луча в `code/items/guns/beams.dm`.
	var/ce_laser_heat_mult = 1

/datum/extension/armor
	/// Жар незональной брони. null — луч её ещё не грел.
	var/datum/ce_armor_heat/ce_heat
	/// Жар зональной брони по группам зон, `CE_ARMOR_ZONE_*` -> `/datum/ce_armor_heat`. Групп,
	/// которых здесь нет, луч ещё не грел.
	var/list/ce_zone_heat
	/// Когда вещь в следующий раз может написать носителю, что жжёт (`world.time`).
	var/ce_burn_message_time = 0


/// Жар одной группы зон брони.
/datum/ce_armor_heat
	/// Группа зон `CE_ARMOR_ZONE_*`, null — у незональной брони.
	var/group
	/// Температура лица 0..1: доля пути до белого каления по кривой нагрева.
	var/temperature = 0
	/// Температура подбоя 0..1 — той стороны, что лежит на носителе. Догоняет температуру лица с
	/// запаздыванием, и ожоги идут по ней.
	var/inner_temperature = 0
	/// Сколько жара уже забрало абляционное покрытие. Выгоревшее возвращает только починка.
	var/coating_spent = 0

/datum/ce_armor_heat/New(group)
	..()
	src.group = group


/// Луч ли это, который жёсткая броня держит вычитанием и который её греет.
/proc/ce_is_laser_heat_attack(damage_type, damage_flags)
	return ce_laser_heat_enabled && get_armor_key(damage_type, damage_flags) == "laser"


/// Держит ли слой эту атаку вычитанием и греется ли от неё.
/datum/extension/armor/proc/ce_uses_laser_heat(damage_type, damage_flags)
	return ce_is_laser_heat_attack(damage_type, damage_flags) && is_hard_armor() && ce_can_heat()


/**
 * Может ли броня греться: вещь из `ce_laser_heat_holders`, которая изнашивается (`ce_can_wear()`).
 * Щиты и парирующее оружие остаются на формуле Bay: их броня — корпус в руке, а не одежда на теле.
 */
/datum/extension/armor/proc/ce_can_heat()
	if(!ce_can_wear())
		return FALSE
	for(var/holder_type in ce_laser_heat_holders)
		if(istype(holder, holder_type))
			return TRUE
	return FALSE


/// Жар группы зон. null — луч её ещё не грел.
/datum/extension/armor/proc/ce_get_heat(group)
	RETURN_TYPE(/datum/ce_armor_heat)
	if(!group)
		return ce_heat
	return LAZYACCESS(ce_zone_heat, group)


/datum/extension/armor/proc/ce_get_or_create_heat(group)
	RETURN_TYPE(/datum/ce_armor_heat)
	. = ce_get_heat(group)
	if(.)
		return
	. = new /datum/ce_armor_heat(group)
	if(!group)
		ce_heat = .
	else
		LAZYSET(ce_zone_heat, group, .)


/// Температура группы зон, 0..1.
/datum/extension/armor/proc/ce_get_temperature(group)
	var/datum/ce_armor_heat/heat = ce_get_heat(group)
	return heat ? heat.temperature : 0


/// Броня головы, рук или ног: теплоёмкость и покрытие у неё меньше, как и HP.
/datum/extension/armor/proc/ce_is_limb_heat_group(group)
	if(group)
		return group != CE_ARMOR_ZONE_TORSO
	return istype(holder, /obj/item/clothing/head) || ce_is_secondary_zone_accessory()


/// Острая броня против пуль целой вещи, мм. По ней, а не по изношенной, считается теплоёмкость:
/// толщина листа от износа не меняется.
/datum/extension/armor/proc/ce_get_intact_sharp_ballistic()
	if(!isnull(armor_sharp_ballistic))
		return armor_sharp_ballistic
	var/bullet = LAZYACCESS(armor_values, "bullet") || 0
	return ce_evaluate_curve(ce_get_sharp_ballistic_curve(), bullet)


/// Теплоёмкость группы зон: сколько жара она держит до белого каления.
/datum/extension/armor/proc/ce_get_heat_capacity(group)
	var/singleton/ce_armor_material/material = ce_get_material()
	. = (ce_laser_heat_capacity_base + ce_laser_heat_capacity_per_mm * ce_get_intact_sharp_ballistic()) * material.heat_capacity_mult
	if(ce_is_limb_heat_group(group))
		. *= ce_laser_heat_limb_capacity_mult


/// Сколько жара абляционное покрытие группы зон заберёт за всю свою жизнь. 0 — покрытия нет.
/datum/extension/armor/proc/ce_get_coating_max(group)
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.coating_share <= 0)
		return 0
	. = ce_laser_coating_per_rating * (LAZYACCESS(armor_values, "laser") || 0)
	if(ce_is_limb_heat_group(group))
		. *= ce_laser_heat_limb_capacity_mult


/**
 * Доля отражения лучей Bay, которую броня сохраняет, по группе зон текущего попадания: сколько
 * покрытия осталось, умноженное на холод брони. Целое покрытие холодной брони отражает как Bay,
 * выгоревшее или раскалённое добела — почти никак. Броня без покрытия теряет отражение только от жара.
 */
/datum/extension/armor/proc/ce_get_reflect_mult()
	var/group = ce_get_wear_group()
	var/datum/ce_armor_heat/heat = ce_get_heat(group)
	if(!heat)
		return 1
	var/coating_max = ce_get_coating_max(group)
	var/coating_left = coating_max > 0 ? max(0, 1 - heat.coating_spent / coating_max) : 1
	return coating_left * (1 - heat.temperature)


/// Доля рейтинга `laser`, которую броня сохраняет при этой температуре.
/proc/ce_get_laser_rating_mult(temperature)
	return 1 - ce_laser_heat_rating_drop * temperature ** ce_laser_heat_rating_drop_exponent


/**
 * Луч через один слой жёсткой брони, по группе зон текущего попадания. Чистая процедура.
 * `armor_pen` — AP луча на шкале 0–100, `heat_mult` — множитель жара луча.
 *
 * Возвращает `list(прошедший урон, жар)`. Жар — от остановленной части луча, до покрытия.
 */
/datum/extension/armor/proc/ce_try_burn_through(damage, armor_pen = 0, heat_mult = 1)
	if(damage <= 0)
		return list(0, 0)
	var/temperature = ce_get_temperature(ce_get_wear_group())
	var/rating = max(0, get_value("laser") * ce_get_laser_rating_mult(temperature) - armor_pen)
	// `урон × clamp((урон − R) / урон, 0, 1)` — то же, что вычесть рейтинг из урона.
	var/passed = clamp(damage - rating, 0, damage)
	var/heat = (damage - passed) * ce_laser_heat_per_damage * heat_mult * max(0, 1 - armor_pen / ce_laser_heat_ap_divisor)
	return list(passed, heat)


/**
 * Жар попадания в группу зон текущего попадания: покрытие забирает свою долю, остальное греет
 * броню, а раскалённая броня изнашивается от всего жара попадания. Зовётся только боевым проходом.
 * `wearer` и `def_zone` — в кого и куда летит осколок при износе, как в `ce_apply_wear()`.
 */
/datum/extension/armor/proc/ce_absorb_laser(heat_amount, mob/living/wearer, def_zone)
	if(heat_amount <= 0)
		return
	var/group = ce_get_wear_group()
	var/datum/ce_armor_heat/heat = ce_get_or_create_heat(group)
	var/singleton/ce_armor_material/material = ce_get_material()
	var/stored_heat = heat_amount - ce_burn_coating(heat, group, heat_amount * material.coating_share)
	ce_add_heat(heat, group, stored_heat)
	ce_take_wear(heat_amount * material.heat_wear * heat.temperature ** ce_laser_wear_exponent, wearer, def_zone)
	ce_update_glow()
	START_PROCESSING(SSprocessing, src)


/// Покрытие забирает до `amount` жара, пока не выгорит. Возвращает, сколько забрало.
/datum/extension/armor/proc/ce_burn_coating(datum/ce_armor_heat/heat, group, amount)
	var/burned = clamp(ce_get_coating_max(group) - heat.coating_spent, 0, amount)
	heat.coating_spent += burned
	return burned


/// Сколько абляционного покрытия группы зон выгорело. 0 — не выгорало или покрытия нет.
/datum/extension/armor/proc/ce_get_coating_spent(group)
	var/datum/ce_armor_heat/heat = ce_get_heat(group)
	return heat ? heat.coating_spent : 0


/// Возвращает `amount` выгоревшего покрытия группы зон — починкой (`armor_repair.dm`).
/datum/extension/armor/proc/ce_restore_coating(group, amount)
	var/datum/ce_armor_heat/heat = ce_get_heat(group)
	if(heat && amount > 0)
		heat.coating_spent = max(0, heat.coating_spent - amount)


/// Прибавляет жар группе зон: температура растёт по кривой нагрева и упирается в белое каление.
/datum/extension/armor/proc/ce_add_heat(datum/ce_armor_heat/heat, group, amount)
	var/capacity = ce_get_heat_capacity(group)
	var/exponent = ce_laser_heat_temperature_exponent
	var/stored = capacity * heat.temperature ** (1 / exponent) + amount
	heat.temperature = min(1, (stored / capacity) ** exponent)


/**
 * Боевое попадание луча в слой: `on_blocking()`, жар и износ, прожог на вещи, сообщение жертве о
 * блоке — пороги те же, что у Bay. `projectile` — луч, null — луч не снарядом. Возвращает итог
 * `ce_try_burn_through()`, который и накладывается.
 */
/datum/extension/armor/proc/ce_take_laser_hit(damage, damage_type, damage_flags, armor_pen, obj/item/projectile/projectile, mob/living/victim, def_zone, silent)
	var/list/burn = ce_try_burn_through(damage, armor_pen, projectile ? projectile.ce_laser_heat_mult : 1)
	var/blocked = 1 - burn[1] / damage
	on_blocking(damage, damage_type, damage_flags, armor_pen, blocked)
	ce_absorb_laser(burn[2], victim, def_zone)
	// Прожоги носит только одежда.
	var/obj/item/clothing/clothing = holder
	if(istype(clothing))
		clothing.ce_add_scorch_mark(victim, def_zone, ce_get_wear_group(), projectile)
	if(!silent)
		if(blocked > 0.7)
			to_chat(victim, SPAN_NOTICE(full_block_message))
		else if(blocked > 0.2)
			to_chat(victim, SPAN_NOTICE(partial_block_message))
	return burn


/**
 * Мягкая броня от луча не греется, а обугливается: изнашивается по формуле износа мягкой брони от
 * острой атаки (§8), умноженной на `ce_laser_soft_char_mult`. `damage` и `new_damage` — урон до
 * слоя и после него. Жёсткая броня, которая не греется, — щиты, естественная броня — не обугливается.
 */
/datum/extension/armor/proc/ce_char_from_laser(damage, new_damage, damage_type, damage_flags, mob/living/wearer, def_zone)
	if(is_hard_armor() || get_armor_key(damage_type, damage_flags) != "laser")
		return
	ce_take_wear(ce_armor_wear_amount(damage, new_damage, 0, 0, TRUE, FALSE) * ce_laser_soft_char_mult, wearer, def_zone)


/**
 * Доля Sharp и Blunt, которую броня сохраняет при температуре группы зон текущего попадания. Её
 * читают `get_armor_sharp_*()` и `get_armor_blunt()`.
 */
/datum/extension/armor/proc/ce_get_hot_kinetic_mult()
	var/temperature = ce_get_effective_temperature()
	if(temperature <= 0)
		return 1
	var/singleton/ce_armor_material/material = ce_get_material()
	return 1 - material.heat_softening * temperature ** ce_laser_hot_kinetic_exponent


/// Множитель износа от пуль и клинков при температуре группы зон текущего попадания.
/datum/extension/armor/proc/ce_get_hot_wear_mult()
	return 1 + ce_laser_hot_kinetic_wear * ce_get_effective_temperature() ** ce_laser_hot_kinetic_exponent


/// Температура группы зон текущего попадания, которая влияет на кинетическую броню. 0 — при
/// выключенном нагреве. Броня, которую луч не грел ни разу, отвечает сразу: геттеры рейтингов
/// зовут это на каждой проверке слоя.
/datum/extension/armor/proc/ce_get_effective_temperature()
	if(!ce_laser_heat_enabled || (!ce_heat && !ce_zone_heat))
		return 0
	return ce_get_temperature(ce_get_wear_group())


/**
 * Итог кор `apply_damage_modifications()` на слое без побочных эффектов и в том же формате:
 * `list(урон, тип урона, флаги)`. Нужен консультационному проходу луча по слоям, которые не
 * греются: граница Bay снимает с луча лазерный флаг и здесь.
 */
/datum/extension/armor/proc/ce_preview_damage_modifications(damage, damage_type, damage_flags, armor_pen)
	var/blocked = get_blocked(damage_type, damage_flags, armor_pen, damage)
	if(ce_is_under_armor(blocked))
		if(damage_flags & DAMAGE_FLAG_LASER)
			damage *= FLUIDLOSS_CONC_BURN/FLUIDLOSS_WIDE_BURN
		damage_flags &= ~(DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE | DAMAGE_FLAG_LASER)
	return list(damage * (1 - blocked), damage_type, damage_flags)


/**
 * Проход луча по слоям брони снаружи внутрь — зеркало кор `modify_damage_by_armor()`, где слои,
 * которые греются, держат луч вычитанием. `armor_pen` — AP луча на шкале 0–100, `projectile` — сам
 * луч: его множитель жара и откуда он пришёл, для прожога. null — луч не снарядом.
 *
 * `apply_effects` разделяет боевой проход и консультационный, как в `ce_walk_armor_layers()`: без
 * него броня не греется, не изнашивается и не пишет жертве.
 *
 * Возвращает `list(урон, флаги)`.
 */
/mob/living/proc/ce_walk_laser_layers(def_zone, damage, damage_type, damage_flags, armor_pen = 0, apply_effects = FALSE, mob/living/victim, silent = FALSE, obj/item/projectile/projectile)
	if(!def_zone)
		def_zone = ran_zone()
	var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))

	for(var/datum/extension/armor/armor_datum as anything in get_armors_by_zone(def_zone, damage_type, damage_flags))
		if(damage <= 0)
			break
		if(armor_datum.ce_uses_laser_heat(damage_type, damage_flags))
			var/list/burn
			if(apply_effects)
				burn = armor_datum.ce_take_laser_hit(damage, damage_type, damage_flags, armor_pen, projectile, victim, def_zone, silent)
			else
				burn = armor_datum.ce_try_burn_through(damage, armor_pen, projectile ? projectile.ce_laser_heat_mult : 1)
			damage = burn[1]
			continue
		var/list/modified
		if(apply_effects)
			modified = armor_datum.apply_damage_modifications(damage, damage_type, damage_flags, victim, armor_pen, silent)
			armor_datum.ce_char_from_laser(damage, modified[1], damage_type, damage_flags, victim, def_zone)
		else
			modified = armor_datum.ce_preview_damage_modifications(damage, damage_type, damage_flags, armor_pen)
		damage = modified[1]
		damage_flags = modified[3]

	ce_set_hit_body_part(outer_body_part)
	return list(damage, damage_flags)


/datum/extension/armor/Process(wait)
	if(!ce_process_heat(wait / (1 SECOND)))
		return PROCESS_KILL


/datum/extension/armor/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/**
 * `seconds` остывания: одна обработка — одна секунда расписания. Возвращает, осталась ли броня
 * тёплой: остывшую `Process()` снимает с обработки, а следующее попадание луча ставит обратно.
 */
/datum/extension/armor/proc/ce_process_heat(seconds)
	// Выключенный нагрев не тратит охладитель: броня просто остывает и светится.
	var/mob/living/carbon/human/wearer = ce_laser_heat_enabled ? ce_get_heat_wearer() : null
	var/obj/item/cell/cooler_cell = wearer?.ce_get_cooling_cell()
	var/cooling_seconds = seconds * (ce_is_in_vacuum() ? ce_laser_vacuum_cooling_mult : 1)
	if(cooler_cell)
		cooling_seconds *= ce_laser_cooler_cooling_mult

	var/removed_heat = 0
	. = FALSE
	for(var/datum/ce_armor_heat/heat as anything in ce_get_all_heat())
		removed_heat += ce_cool_heat(heat, cooling_seconds)
		ce_conduct_heat(heat, seconds)
		if(heat.temperature > 0 || heat.inner_temperature > 0)
			. = TRUE

	ce_update_glow()
	// Охладитель платит только за то, что снял сверх естественного остывания.
	if(cooler_cell)
		cooler_cell.use(removed_heat * (1 - 1 / ce_laser_cooler_cooling_mult) * ce_laser_cooler_charge_per_heat)


/// Жар всех групп зон, которые луч уже грел.
/datum/extension/armor/proc/ce_get_all_heat()
	RETURN_TYPE(/list)
	. = list()
	if(ce_heat)
		. += ce_heat
	for(var/group in ce_zone_heat)
		. += ce_zone_heat[group]


/**
 * Температура после `seconds` остывания по расписанию `ce_laser_cooling_band_seconds`: каждую полосу
 * между ступенями накала броня проходит за свои секунды, внутри полосы — равномерно.
 */
/proc/ce_cool_temperature(temperature, seconds)
	var/list/edges = list(0) + ce_laser_heat_stage_temperatures + 1
	var/band = length(ce_laser_cooling_band_seconds)
	while(seconds > 0 && temperature > 0)
		// Температура ровно на ступени остывает уже по полосе под ней.
		while(band > 1 && edges[band] >= temperature)
			band--
		var/rate = (edges[band + 1] - edges[band]) / ce_laser_cooling_band_seconds[band]
		var/to_edge = (temperature - edges[band]) / rate
		if(to_edge >= seconds)
			return max(0, temperature - rate * seconds)
		temperature = edges[band]
		seconds -= to_edge
	return max(0, temperature)


/// Остужает лицо группы зон на `seconds` расписания. Возвращает, сколько жара она отдала.
/datum/extension/armor/proc/ce_cool_heat(datum/ce_armor_heat/heat, seconds)
	var/exponent = ce_laser_heat_temperature_exponent
	var/before = heat.temperature
	heat.temperature = ce_cool_temperature(before, seconds)
	return ce_get_heat_capacity(heat.group) * (before ** (1 / exponent) - heat.temperature ** (1 / exponent))


/// Подбой догоняет лицо за `seconds` — по проводимости материала, и тем медленнее, чем броня толще.
/datum/extension/armor/proc/ce_conduct_heat(datum/ce_armor_heat/heat, seconds)
	var/singleton/ce_armor_material/material = ce_get_material()
	var/thickness = max(1, ce_get_intact_sharp_ballistic())
	var/share = min(1, material.heat_conduction * sqrt(ce_laser_conduction_reference_mm / thickness))
	share = 1 - (1 - share) ** (seconds / ce_laser_conduction_seconds)
	heat.inner_temperature += share * (heat.temperature - heat.inner_temperature)
	if(abs(heat.temperature - heat.inner_temperature) < CE_LASER_INNER_SNAP)
		heat.inner_temperature = heat.temperature


/**
 * Ожоги от раскалённой брони за тик Life, как от огня: подбой каждой надетой вещи, которую луч грел,
 * жжёт закрытые ею части тела. Охладитель на носителе их ослабляет.
 */
/mob/living/carbon/human/proc/ce_burn_from_hot_armor()
	if(!ce_laser_heat_enabled)
		return
	var/list/heated_armors = list()
	for(var/obj/item/item as anything in ce_get_worn_armor_items())
		var/datum/extension/armor/armor = ce_get_heated_armor(item)
		if(armor)
			heated_armors += armor
	if(!length(heated_armors))
		return
	var/burn_mult = ce_get_cooling_cell() ? ce_laser_cooler_burn_mult : 1
	var/burned = 0
	for(var/datum/extension/armor/armor as anything in heated_armors)
		for(var/datum/ce_armor_heat/heat as anything in armor.ce_get_all_heat())
			burned += armor.ce_burn_wearer(src, heat, burn_mult)
	if(burned > 0)
		updatehealth()


/// Одежда, которую человек носит в слотах с бронёй, вместе с пристёгнутыми аксессуарами.
/mob/living/carbon/human/proc/ce_get_worn_armor_items()
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/clothing/gear in list(head, wear_mask, wear_suit, w_uniform, gloves, shoes))
		. += gear
		if(gear.accessories)
			. += gear.accessories


/**
 * Ожоги носителя от подбоя группы зон за один тик Life, поровну на закрытые ею части тела, мимо брони.
 * Броня головы, рук и ног жжёт слабее (`ce_laser_burn_limb_mult`). Возвращает, сколько ожогов нанесено.
 */
/datum/extension/armor/proc/ce_burn_wearer(mob/living/carbon/human/wearer, datum/ce_armor_heat/heat, burn_mult = 1)
	var/burn = ce_evaluate_curve(ce_laser_burn_curve, heat.inner_temperature) * burn_mult
	if(ce_is_limb_heat_group(heat.group))
		burn *= ce_laser_burn_limb_mult
	if(burn <= 0)
		return 0
	var/list/organs = ce_get_heated_organs(wearer, heat.group)
	if(!length(organs))
		return 0
	var/obj/item/armor_item = holder
	for(var/obj/item/organ/external/organ as anything in organs)
		organ.take_external_damage(0, burn / length(organs), FLAGS_OFF, armor_item.name)
	ce_report_burn(wearer, organs)
	return burn


/// Части тела носителя, которые закрывает группа зон брони. У незональной — все, что закрывает вещь.
/datum/extension/armor/proc/ce_get_heated_organs(mob/living/carbon/human/wearer, group)
	RETURN_TYPE(/list)
	var/obj/item/clothing/clothing = holder
	var/body_parts = clothing.body_parts_covered
	if(group)
		body_parts &= ce_armor_zone_groups[group]
	. = list()
	for(var/obj/item/organ/external/organ as anything in wearer.organs)
		if(organ.body_part & body_parts)
			. += organ


/// Пишет носителю, что вещь его жжёт, — не чаще раза в `ce_laser_burn_message_cooldown`.
/datum/extension/armor/proc/ce_report_burn(mob/living/carbon/human/wearer, list/organs)
	if(world.time < ce_burn_message_time)
		return
	ce_burn_message_time = world.time + ce_laser_burn_message_cooldown
	var/obj/item/armor_item = holder
	var/list/names = list()
	for(var/obj/item/organ/external/organ as anything in organs)
		names += organ.name
	to_chat(wearer, SPAN_DANGER("The heat of your [armor_item.name] sears your [english_list(names)]!"))


/**
 * Кто носит вещь с этой бронёй: человек, у которого она — или одежда, к которой она пристёгнута, —
 * надета в один из слотов, чью броню читает `get_armors_by_zone()` человека. null — вещь не надета:
 * в руках, в рюкзаке, на полу, в свёрнутом РИГе.
 */
/datum/extension/armor/proc/ce_get_heat_wearer()
	RETURN_TYPE(/mob/living/carbon/human)
	var/obj/item/clothing/worn = holder
	if(!istype(worn))
		return null
	var/obj/item/clothing/accessory/accessory = holder
	if(istype(accessory) && accessory.parent)
		worn = accessory.parent
	var/mob/living/carbon/human/wearer = worn.loc
	if(!istype(wearer))
		return null
	if(!(worn in list(wearer.head, wearer.wear_mask, wearer.wear_suit, wearer.w_uniform, wearer.gloves, wearer.shoes)))
		return null
	return wearer


/// Остывает ли броня как в вакууме: на клетке вещи давление ниже `ce_laser_vacuum_pressure`.
/datum/extension/armor/proc/ce_is_in_vacuum()
	var/turf/turf = get_turf(holder)
	if(!turf)
		return FALSE
	var/datum/gas_mixture/air = turf.return_air()
	return !air || air.return_pressure() < ce_laser_vacuum_pressure


/**
 * Батарея включённого охладителя, null — охладителя нет или батарея пуста. Переносной охладитель
 * работает на спине или в хранилище скафандра, как и в Bay (`is_in_slot()`), модуль охлаждения — в
 * РИГе на спине.
 */
/mob/living/carbon/human/proc/ce_get_cooling_cell()
	RETURN_TYPE(/obj/item/cell)
	for(var/obj/item/device/suit_cooling_unit/unit in list(back, s_store))
		if(unit.on && unit.cell?.charge > 0)
			return unit.cell
	var/obj/item/rig/rig = back
	if(!istype(rig) || !(rig.cell?.charge > 0))
		return null
	for(var/obj/item/rig_module/cooling_unit/module in rig.installed_modules)
		if(module.active)
			return rig.cell
	return null



/// Ступень накала при температуре: 0 — ниже тусклого красного, дальше по `ce_laser_heat_stage_temperatures`.
/proc/ce_get_heat_stage(temperature)
	. = 0
	for(var/stage_temperature in ce_laser_heat_stage_temperatures)
		if(temperature < stage_temperature)
			return
		.++


/// Ступень накала брони — по самой горячей её группе зон.
/datum/extension/armor/proc/ce_get_armor_heat_stage()
	. = 0
	for(var/datum/ce_armor_heat/heat as anything in ce_get_all_heat())
		. = max(., ce_get_heat_stage(heat.temperature))


/// Передаёт вещи ступень накала её брони. Перерисуется вещь, только если ступень сменилась.
/// Светится только одежда.
/datum/extension/armor/proc/ce_update_glow()
	var/obj/item/clothing/clothing = holder
	if(istype(clothing))
		clothing.ce_set_heat_stage(ce_get_armor_heat_stage())


/// Словами — как раскалена броня при этой температуре. null — холодная.
/proc/ce_describe_heat(temperature)
	var/static/list/stage_words = list("glowing dull red", "red-hot", "glowing orange", "white-hot")
	var/stage = ce_get_heat_stage(temperature)
	if(stage)
		return stage_words[stage]
	return temperature > 0 ? "hot to the touch" : null


/**
 * Строки осмотра о жаре брони, пустой list у холодной. У зональной — по строке на каждую тёплую
 * группу зон. `label` — чья это броня, если осматривают не её вещь.
 */
/datum/extension/armor/proc/ce_get_heat_lines(label)
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/ce_armor_heat/heat as anything in ce_get_all_heat())
		var/description = ce_describe_heat(heat.temperature)
		if(!description)
			continue
		var/part = heat.group ? (label ? "[label], [heat.group]" : heat.group) : label
		. += part ? "Armor heat ([part]): [description]." : "Armor heat: [description]."


/**
 * Строки кодекса о луче для брони, которая держит его вычитанием, по группе зон текущего чтения:
 * сколько урона луча она держит сейчас и сколько жара вмещает. Пустой list у остальной брони.
 */
/datum/extension/armor/proc/ce_get_laser_codex_lines()
	RETURN_TYPE(/list)
	. = list()
	if(!ce_laser_heat_enabled || !is_hard_armor() || !ce_can_heat())
		return
	var/group = ce_get_wear_group()
	var/rating = get_value("laser") * ce_get_laser_rating_mult(ce_get_temperature(group))
	. += "stops [round(rating, 0.1)] beam damage per hit, minus the beam's armor penetration"
	. += "[round(ce_get_heat_capacity(group))] heat to white-hot"
	var/coating_max = ce_get_coating_max(group)
	if(coating_max > 0)
		var/datum/ce_armor_heat/heat = ce_get_heat(group)
		. += "ablative coating: [round(coating_max - (heat ? heat.coating_spent : 0))] of [round(coating_max)] heat left"


/obj/item/clothing
	/// Ступень накала собственной брони вещи, 0 — не светится. Её ставит броня (`ce_update_glow()`).
	var/ce_heat_stage = 0
	/// Ступень накала, которую вещь показывает: своя или пластины внутри неё.
	var/ce_glow_stage = 0
	/// Свет вещи сейчас — свечение жара, а не её собственный.
	var/ce_heat_light = FALSE
	/// Слои жара вещи на носителе, собранные при последней сборке её картинки: умножение и прибавка.
	/// null — вещь не светится или в руках.
	var/list/ce_worn_heat_layers


/obj/item/clothing/proc/ce_set_heat_stage(stage)
	if(stage == ce_heat_stage)
		return
	ce_heat_stage = stage
	ce_update_heat_light()
	ce_refresh_glow()
	var/obj/item/clothing/accessory/accessory = src
	if(istype(accessory) && accessory.parent)
		accessory.parent.ce_refresh_glow()


/**
 * Ступень накала, которую показывает вещь: своя или пластины внутри неё. Своего спрайта на носителе
 * у пластин плитоноски нет, так что горячую пластину видно только через плитоноску. Наручи и поножи
 * рисуются сами и светятся сами.
 */
/obj/item/clothing/proc/ce_get_shown_heat_stage()
	. = ce_heat_stage
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		if(accessory.slot == ACCESSORY_SLOT_ARMOR_CHEST)
			. = max(., accessory.ce_heat_stage)


/// Перерисовывает свечение спрайта вещи и её картинки на носителе, если показанная ступень сменилась.
/obj/item/clothing/proc/ce_refresh_glow()
	var/stage = ce_get_shown_heat_stage()
	ce_update_plane_flags(stage)
	if(stage == ce_glow_stage)
		return
	ce_glow_stage = stage
	remove_filter(list(CE_HEAT_TINT_FILTER, CE_HEAT_HALO_FILTER))
	if(stage)
		if(ce_laser_glow_tint_enabled)
			add_filter(CE_HEAT_TINT_FILTER, CE_HEAT_TINT_PRIORITY, list("type" = "color", "color" = ce_get_glow_matrix(stage)))
		add_filter(CE_HEAT_HALO_FILTER, CE_HEAT_HALO_PRIORITY, ce_get_halo_filter(stage))
	update_clothing_icon()


/**
 * Свет раскалённой вещи — с оранжевого. Вещь, которая уже светит своим светом, жаром не светит:
 * источник света у неё один. Каска с фонарём не светит жаром вовсе, иначе остывая она гасила бы
 * фонарь.
 */
/obj/item/clothing/proc/ce_update_heat_light()
	var/obj/item/clothing/head/hat = src
	if(istype(hat) && hat.brightness_on)
		return
	var/range = ce_heat_stage ? ce_laser_glow_light_range[ce_heat_stage] : 0
	if(range > 0 && (ce_heat_light || !light_range))
		set_light(range, ce_laser_glow_light_power[ce_heat_stage], ce_laser_glow_colors[ce_heat_stage])
		ce_heat_light = TRUE
	else if(range <= 0 && ce_heat_light)
		set_light(0)
		ce_heat_light = FALSE


/**
 * Свечение на картинке вещи на носителе в слоте `slot`. Окраску даёт не сама картинка, а слои жара —
 * копии картинки вместе с аксессуарами, которые `ce_add_heat_layers()` человека кладёт поверх всей
 * одежды. У вещи в руках слоёв жара нет, и её картинка окрашивается сама. С красного — ещё эмиссив
 * на своей плоскости. Горячий воздух картинка вещи не несёт: его кладёт человек, один на все вещи.
 */
/obj/item/clothing/proc/ce_glow_worn_image(image/worn_image, slot)
	ce_worn_heat_layers = null
	if(!ce_glow_stage || !istype(worn_image))
		return
	if(slot == slot_l_hand_str || slot == slot_r_hand_str)
		if(ce_laser_glow_tint_enabled)
			worn_image.color = ce_get_glow_matrix(ce_glow_stage, worn_image.color)
		else
			worn_image.add_filter(CE_HEAT_HALO_FILTER, CE_HEAT_HALO_PRIORITY, ce_get_halo_filter(ce_glow_stage))
	else
		ce_worn_heat_layers = ce_make_heat_layers(worn_image, ce_glow_stage)
	var/emissive_alpha = ce_laser_glow_emissive_alpha[ce_glow_stage]
	if(emissive_alpha > 0)
		worn_image.AddOverlays(emissive_appearance(worn_image.icon, worn_image.icon_state, CE_LASER_EMISSIVE_LAYER, emissive_alpha))


/**
 * Слои жара: две копии картинки вещи на носителе вместе с аксессуарами, залитые сплошным цветом.
 * Первая умножает всё под собой на цвет ступени, вторая прибавляет его же и несёт ореол — это та же
 * окраска, что у спрайта вещи, только для всего, что лежит в силуэте. Фильтры — через
 * `add_filter()`, чтобы их не стёрла система роста.
 */
/proc/ce_make_heat_layers(image/worn_image, stage)
	// Без окраски остаётся один ореол: прибавка чёрного силуэта ничего не меняет, а ореол вокруг
	// него — светится.
	if(!ce_laser_glow_tint_enabled)
		var/mutable_appearance/halo_layer = ce_make_heat_fill(worn_image, BLEND_ADD, list(0, 0, 0))
		halo_layer.add_filter(CE_HEAT_HALO_FILTER, CE_HEAT_HALO_PRIORITY, ce_get_halo_filter(stage))
		return list(halo_layer)
	var/list/glow = rgb2num(ce_laser_glow_colors[stage])
	var/tint = ce_laser_glow_tint[stage]
	var/list/multiply = list()
	var/list/lift = list()
	for(var/channel in 1 to 3)
		multiply += 1 - tint + tint * glow[channel] / 255
		lift += tint * ce_laser_glow_worn_lift * glow[channel] / 255
	var/mutable_appearance/tint_layer = ce_make_heat_fill(worn_image, BLEND_MULTIPLY, multiply)
	var/mutable_appearance/lift_layer = ce_make_heat_fill(worn_image, BLEND_ADD, lift)
	lift_layer.add_filter(CE_HEAT_HALO_FILTER, CE_HEAT_HALO_PRIORITY, ce_get_halo_filter(stage))
	return list(tint_layer, lift_layer)


/// Копия картинки вещи, залитая сплошным цветом `rgb` (доли 0..1) и сложенная с тем, что под ней, как `blend_mode`.
/proc/ce_make_heat_fill(image/worn_image, blend_mode, list/rgb)
	var/mutable_appearance/fill = new(worn_image)
	fill.blend_mode = blend_mode
	fill.appearance_flags |= KEEP_TOGETHER
	fill.add_filter(CE_HEAT_FILL_FILTER, CE_HEAT_TINT_PRIORITY, list("type" = "color", "color" = list(0, 0, 0, 0, 0, 0, 0, 0, 0) + rgb))
	return fill


/**
 * Кладёт слои жара надетых вещей поверх всех оверлеев человека. Их, как и картинки вещей, подгоняет
 * под рост система роста: голову только сдвигает, тело ещё и растягивает. Горячий воздух — один на
 * человека, по самой горячей из вещей со слоями жара: копии от каждой вещи легли бы друг на друга.
 */
/mob/living/carbon/human/proc/ce_add_heat_layers()
	if(is_cloaked())
		return
	var/list/heat_layers = list()
	var/haze_stage = 0
	for(var/obj/item/clothing/item in ce_get_worn_armor_items())
		if(!item.ce_worn_heat_layers)
			continue
		haze_stage = max(haze_stage, item.ce_glow_stage)
		// Слои жара одежды уже покрывают её аксессуары.
		var/obj/item/clothing/accessory/accessory = item
		if(istype(accessory) && accessory.parent?.ce_worn_heat_layers)
			continue
		var/is_head_level = item == head || item == wear_mask
		for(var/mutable_appearance/heat_layer as anything in item.ce_worn_heat_layers)
			if(!is_head_level)
				update_height(heat_layer)
			human_update_offset(heat_layer, is_head_level)
			heat_layers += heat_layer
	var/mutable_appearance/haze = ce_get_heat_haze(haze_stage)
	if(haze)
		heat_layers += haze
	if(length(heat_layers))
		AddOverlays(heat_layers)


/// Рисует ли вещь на носителе на этой ступени что-то на своих плоскостях: эмиссив её картинки или горячий воздух над носителем.
/proc/ce_glow_uses_planes(stage)
	return stage && (ce_laser_glow_emissive_alpha[stage] > 0 || ce_laser_glow_haze_alpha[stage] > 0)


/**
 * Эмиссив картинки вещи и горячий воздух над её носителем рисуются на своих плоскостях, и Z-Mimic
 * должен это учесть: как у глазного импланта, флаг `ZMM_MANGLE_PLANES` ставится на вещь, а моб
 * собирает его со снаряжения (`check_emissive_equipment()`). Считается и то, что рисуют пристёгнутые
 * аксессуары. Свой флаг вещи, заданный на типе, не снимается.
 */
/obj/item/clothing/proc/ce_update_plane_flags(shown_stage)
	var/uses_planes = ce_glow_uses_planes(shown_stage)
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		if(ce_glow_uses_planes(accessory.ce_glow_stage))
			uses_planes = TRUE
	var/old_flags = z_flags
	if(uses_planes)
		z_flags |= ZMM_MANGLE_PLANES
	else if(!(initial(z_flags) & ZMM_MANGLE_PLANES))
		z_flags &= ~ZMM_MANGLE_PLANES
	var/mob/wearer = loc
	if(z_flags != old_flags && istype(wearer))
		wearer.check_emissive_equipment()


/**
 * Горячий воздух над носителем на ступени `stage` — тот же, что над горячим газом
 * (`/obj/gas_overlay/heat`): картинка на плоскости жара, которая берёт частицы из цели рендерера
 * жара, а сцена по ней дрожит. Сила — непрозрачность картинки, как у газа. null — на этой ступени
 * воздух не дрожит.
 */
/proc/ce_get_heat_haze(stage)
	RETURN_TYPE(/mutable_appearance)
	var/haze_alpha = stage ? ce_laser_glow_haze_alpha[stage] : 0
	if(haze_alpha <= 0)
		return null
	var/mutable_appearance/haze = mutable_appearance(null, null, null, KEEP_APART | RESET_COLOR | RESET_ALPHA | NO_CLIENT_COLOR, HEAT_EFFECT_PLANE)
	haze.render_source = HEAT_EFFECT_TARGET
	haze.alpha = haze_alpha
	return haze


/**
 * Матрица цвета ступени накала: спрайт окрашивается в цвет ступени, а его рисунок остаётся в яркости:
 * цвет × (подъём + усиление × яркость пикселя), смешанный с исходным цветом на долю окраски.
 * `base_color` — свой цвет картинки, который матрица заменяет, null — без своего цвета.
 */
/proc/ce_get_glow_matrix(stage, base_color)
	var/static/list/luma = list(0.3, 0.59, 0.11)
	var/list/glow = rgb2num(ce_laser_glow_colors[stage])
	var/list/base = istext(base_color) ? rgb2num(base_color) : list(255, 255, 255)
	var/tint = ce_laser_glow_tint[stage]
	. = list()
	for(var/input in 1 to 3)
		for(var/output in 1 to 3)
			var/weight = tint * glow[output] / 255 * ce_laser_glow_gain * luma[input]
			if(input == output)
				weight += 1 - tint
			. += weight * base[input] / 255
	for(var/output in 1 to 3)
		. += tint * glow[output] / 255 * ce_laser_glow_lift


/// Параметры фильтра ореола ступени накала для `add_filter()`.
/proc/ce_get_halo_filter(stage)
	return list(
		"type" = "drop_shadow",
		"x" = 0,
		"y" = 0,
		"size" = ce_laser_glow_halo_size[stage],
		"color" = ce_laser_glow_colors[stage] + num2text(ce_laser_glow_halo_alpha, 2, 16)
	)

#undef CE_LASER_INNER_SNAP
#undef CE_HEAT_TINT_FILTER
#undef CE_HEAT_HALO_FILTER
#undef CE_HEAT_FILL_FILTER
#undef CE_HEAT_TINT_PRIORITY
#undef CE_HEAT_HALO_PRIORITY
