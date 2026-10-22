/*
	COMBAT_EXTENDED — вычисление Sharp/Blunt брони из тех значений, которые у предмета уже есть.

	Процедуры вывода считают значение на каждый вызов и ничего не кешируют — это намеренно:
	рейтинг меняется с износом (кривая состояния в `get_value()`, а `/datum/extension/armor/ablative`
	снижает сами `armor_values`) и с жаром от лучей (`laser_heat.dm`), и посчитанное при создании
	значение протухло бы.
*/

/datum/extension/armor
	/// Sharp против пуль, мм RHA. Если задано — используется напрямую, минуя вывод по кривым.
	var/armor_sharp_ballistic
	/// Sharp против холодного оружия, мм RHA. Если задано — используется напрямую, минуя вывод по кривым.
	var/armor_sharp_melee
	/// Blunt, Bay МПа. Если задано — используется напрямую, минуя весь вывод по кривым.
	var/armor_blunt
	/// Кеш `is_hard_armor()`. null — ещё не считали.
	var/ce_hard_armor


/**
 * Кусочно-линейная интерполяция по точкам `list(вход, выход)`, отсортированным по входу, с зажимом
 * по краям. Аналог SimpleCurve.Evaluate() из RimWorld.
 */
/proc/ce_evaluate_curve(list/curve, value)
	if(!length(curve))
		return 0

	var/list/first = curve[1]
	if(value <= first[1])
		return first[2]

	var/list/last = curve[length(curve)]
	if(value >= last[1])
		return last[2]

	for(var/i = 1 to length(curve) - 1)
		var/list/low = curve[i]
		var/list/high = curve[i + 1]
		if(value >= low[1] && value <= high[1])
			var/span = high[1] - low[1]
			if(span <= 0)
				return high[2]
			return low[2] + (high[2] - low[2]) * ((value - low[1]) / span)

	return last[2]


/**
 * Обратная к `ce_evaluate_curve()`: наименьший вход, на котором неубывающая кривая достигает
 * `output`. Ниже выхода первой точки — её вход, выше выхода последней — вход последней.
 */
/proc/ce_invert_curve(list/curve, output)
	if(!length(curve))
		return 0

	var/list/first = curve[1]
	if(output <= first[2])
		return first[1]

	for(var/i = 1 to length(curve) - 1)
		var/list/low = curve[i]
		var/list/high = curve[i + 1]
		// Сюда доходит только `output` выше выхода `low`, так что отрезок не плоский.
		if(output <= high[2])
			return low[1] + (high[1] - low[1]) * ((output - low[2]) / (high[2] - low[2]))

	var/list/last = curve[length(curve)]
	return last[1]


/**
 * Считает ли носитель этого расширения «жёсткой» бронёй: от этого зависит выбор кривой.
 *
 * Результат кешируется: процедуру дёргают до трёх раз за слой за удар (по разу на каждую ось
 * вывода), а меняться ему не от чего.
 */
/datum/extension/armor/proc/is_hard_armor()
	if(isnull(ce_hard_armor))
		ce_hard_armor = ce_classify_hard_armor()
	return ce_hard_armor


/**
 * Классификация для кеша `is_hard_armor()`.
 *
 * Кешировать её можно, хотя вывод рейтингов не кеширует ничего: жёсткость зависит только от типа
 * носителя, его материала и типа самого расширения, а они не меняются — `set_extension()` на новый
 * тип создаёт НОВОЕ расширение, а не переселяет старое.
 */
/datum/extension/armor/proc/ce_classify_hard_armor()
	// Баллистическое волокно — мягкая броня, в чём бы её ни носили: вставка плитоноски остаётся
	// аксессуаром `armor_plate` в бронеслоте, и списки ниже записали бы её в жёсткие.
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.ballistic_fiber)
		return FALSE

	for(var/extension_type in ce_hard_armor_extensions)
		if(istype(src, extension_type))
			return TRUE

	for(var/holder_type in ce_hard_armor_holders)
		if(istype(holder, holder_type))
			return TRUE

	if(istype(holder, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/accessory = holder
		return (accessory.slot in ce_hard_armor_accessory_slots)

	return FALSE


/// Кривая острой оси против пуль — по жёсткости брони. Баллистическое волокно — мягкая броня, но
/// пули держит по жёсткой кривой.
/datum/extension/armor/proc/ce_get_sharp_ballistic_curve()
	RETURN_TYPE(/list)
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.ballistic_fiber || is_hard_armor())
		return ce_sharp_ballistic_hard
	return ce_sharp_ballistic_soft


/// Sharp против пуль, мм RHA. Раскалённая броня держит меньше (`laser_heat.dm`).
/datum/extension/armor/proc/get_armor_sharp_ballistic()
	return ce_get_cold_sharp_ballistic() * ce_get_hot_kinetic_mult()


/// Sharp против холодного оружия, мм RHA. Раскалённая броня держит меньше (`laser_heat.dm`).
/datum/extension/armor/proc/get_armor_sharp_melee()
	return ce_get_cold_sharp_melee() * ce_get_hot_kinetic_mult()


/**
 * Sharp против атаки с этими флагами, мм RHA. Пуля несёт сразу `DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP`,
 * поэтому `DAMAGE_FLAG_BULLET` проверяется первым — так же расставляет приоритеты `get_armor_key()`.
 */
/datum/extension/armor/proc/get_armor_sharp(damage_flags = 0)
	return (damage_flags & DAMAGE_FLAG_BULLET) ? get_armor_sharp_ballistic() : get_armor_sharp_melee()


/// Blunt, Bay МПа. Раскалённая броня держит меньше (`laser_heat.dm`).
/datum/extension/armor/proc/get_armor_blunt()
	return ce_get_cold_blunt() * ce_get_hot_kinetic_mult()


/*
	Холодные рейтинги — без поправки на жар, но с износом. По ним выводятся HP брони
	(`ce_get_health_max()`): жар — состояние, а не свойство вещи, и броня, впервые изношенная
	раскалённой, не должна навсегда получить меньше HP.
*/

/// Sharp против пуль холодной брони, мм RHA.
/datum/extension/armor/proc/ce_get_cold_sharp_ballistic()
	if(!isnull(armor_sharp_ballistic))
		return armor_sharp_ballistic

	var/source = get_value("bullet")
	return ce_evaluate_curve(ce_get_sharp_ballistic_curve(), source)


/// Sharp против холодного оружия холодной брони, мм RHA.
/datum/extension/armor/proc/ce_get_cold_sharp_melee()
	if(!isnull(armor_sharp_melee))
		return armor_sharp_melee

	var/source = get_value("melee")
	return ce_evaluate_curve(is_hard_armor() ? ce_sharp_melee_hard : ce_sharp_melee_soft, source)


/// Blunt холодной брони, Bay МПа.
/datum/extension/armor/proc/ce_get_cold_blunt()
	if(!isnull(armor_blunt))
		return armor_blunt

	var/source = get_value("melee")
	var/from_melee = ce_evaluate_curve(is_hard_armor() ? ce_blunt_curve_hard : ce_blunt_curve_soft, source)
	// Баллистическое волокно пулю останавливает, а удар пропускает: его пулевой рейтинг — не толщина
	// плиты, и границы от него нет.
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.ballistic_fiber)
		return from_melee
	// Граница — от БАЛЛИСТИЧЕСКОЙ оси: ось холодного оружия описывает заточку кромки, а не толщину
	// плиты, и `melee` в любом случае уже учтён строкой выше.
	var/floor_value = ce_evaluate_curve(ce_blunt_from_sharp, ce_get_cold_sharp_ballistic())
	return max(from_melee, floor_value)
