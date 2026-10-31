/*
	COMBAT_EXTENDED — внешние бронеэлементы мехов (`mods/mechs_by_shegar`,
	`code/components/external_armor/_external_armour.dm`).

	Бронеэлемент — обычная вещь с бронёй на байевской шкале, и мод считает его как любую жёсткую
	плиту: рейтинг — кривыми из ключа `bullet` (`armor_conversion.dm`), пробитие снаряда — из его
	урона и `armor_penetration` (`attack_penetration.dm`), HP — из рейтинга, износ — формулами §8
	(`armor_wear.dm`). Чисел под каждый снаряд у бронеэлементов нет, как нет их у плит плитоноски.

	Слой он внешний: `/mob/living/exosuit/get_armors_by_zone()` отдаёт бронеэлемент той части
	меха, в которую пришлось попадание, и только пулям и лучам. Остановленная пуля бьёт часть
	тупым остатком, пробившая — уроном, потерявшим долю на слое, и остаточным ударом. Под ним —
	встроенная броня меха, обычная естественная броня моба: от пуль и лучей в ней ничего нет, но
	её `melee` гасит тупой остаток и остаточный удар, как гасит удары холодным оружием.

	Луч бронеэлемент держит вычитанием по ключу `laser` и греется (`laser_heat.dm`): он в списке
	`ce_laser_heat_holders`. Числа бронеэлементов под луч — в `code/items/armor/mech_external_armor.dm`.

	Остаточный удар — тупой и без флагов, и для `get_armors_by_zone()` он уже не пуля. Бронеэлемент
	ему возвращает хук `ce_order_armors()`: иначе хвост пробившей пули шёл бы мимо плиты, которую
	она только что пробила, и слабая бронебойная пуля доставляла бы через бронеэлемент больше, чем
	без него.

	Кроме хука, здесь то, чего нет ни у брони-одежды, ни у самих мехов: бронеэлемент, чей рейтинг
	упал ниже `ce_mech_plate_break_condition`, отваливается от меха.

	Приборам меха и осмотру бронеэлемент отдаёт не долю HP, как броня-одежда, а целостность
	(`ce_get_integrity()`): запас HP до отваливания, от единицы у целого до нуля на пороге. С долей
	HP бронеэлемент отваливался бы на «25%». Жар уходит туда же строкой (`ce_get_status_notes()`),
	а о переходе на ступень хуже диагностика меха сообщает пилотам (`report_damage()`).

	Спрашивает обе процедуры сам модпак мехов, под `#ifdef MODPACK_COMBAT_EXTENDED`: мод
	подключается раньше него и переопределить его процедуры не может.
*/

/mob/living/exosuit/ce_order_armors(list/armors, def_zone, secondary = FALSE)
	if(!secondary)
		return armors
	var/obj/item/mech_component/part = zoneToComponent(def_zone)
	if(!part?.installed_armor)
		return armors
	var/plate_armor = get_extension(part.installed_armor, /datum/extension/armor)
	if(!plate_armor || (plate_armor in armors))
		return armors
	return list(plate_armor) + armors


/obj/item/mech_external_armor/ce_on_armor_worn(group)
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	if(armor.ce_get_group_condition(group) < ce_mech_plate_break_condition)
		destroy_armour()
	else
		report_damage()


/// Запас HP до отваливания, от 1 у целого бронеэлемента до 0 на пороге `ce_mech_plate_break_condition`.
/obj/item/mech_external_armor/proc/ce_get_integrity()
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	var/health = armor?.ce_get_health()
	if(!ce_armor_wear_enabled || isnull(health))
		return 1
	var/break_fraction = armor.ce_get_condition_health_fraction(ce_mech_plate_break_condition)
	return clamp((health / armor.ce_get_health_max() - break_fraction) / (1 - break_fraction), 0, 1)


/// Заметки для приборов меха: как раскалён бронеэлемент. Пустой list у холодного.
/obj/item/mech_external_armor/proc/ce_get_status_notes()
	RETURN_TYPE(/list)
	. = list()
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	var/heat = armor ? ce_describe_heat(armor.ce_get_temperature()) : null
	if(heat)
		. += heat
