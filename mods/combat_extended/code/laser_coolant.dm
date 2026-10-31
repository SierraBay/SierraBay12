/*
	COMBAT_EXTENDED — хладагент и вода для раскалённой брони (`laser_heat.dm`).

	Остужают броню хладагент и вода, вода — слабее на свою долю силы (`ce_laser_coolant_strengths`).
	Ниже «хладагент» — обе жидкости: числа настроек — за единицу хладагента, вода считается в
	пересчёте на него. Из смеси полив берёт сперва хладагент.

	Полив. Хладагент льют из открытой ёмкости на вещь — в руке, на полу, на столе, в своём слоте
	снаряжения (`use_tool()` одежды) — или на человека (`use_before()` стеклянной посуды, прицел мимо
	рта: рот — это напоить). Зона прицела не важна: поливают самую горячую броню вещи или человека.
	Блок управления РИГа поливают как вещь из его деталей, убранных или нет (`rig_armor.dm`).
	Снятую броню поливают быстро, и хладагент остужает её насквозь. Надетую поливают дольше — на
	себе дольше всего, — и оба стоят смирно, а хладагент остужает только лицо брони: подбой
	продолжает жечь. Пока горячей брони нет, клик идёт дальше как обычно — например, ёмкость уходит в
	подсумок плитоноски.

	Брызги. Всё, что брызгает на моба или вещь, — пульверизатор, огнетушитель, выплеснутая ёмкость —
	проходит через `touch()` реагентов. Брызги немного остужают лицо брони — по самой сильной
	жидкости в них, — не чаще раза в `ce_laser_spray_interval` на вещь.

	Раскалённая броня от полива шипит и парит, а керамика ещё и трескается (`heat_quench_crack`
	материала).
*/

/datum/extension/armor
	/// Когда брызги в последний раз остужали эту броню (`world.time`). null — ещё не остужали.
	var/ce_spray_time


/**
 * Броня вещи, которую луч уже грел, или null. Расширение не создаётся: брызги задевают любую
 * одежду, а броня, которую луч грел, уже создана.
 */
/proc/ce_get_heated_armor(obj/item/item)
	RETURN_TYPE(/datum/extension/armor)
	var/datum/extension/armor/armor = LAZYACCESS(item?.extensions, /datum/extension/armor)
	if(!istype(armor) || (!armor.ce_heat && !armor.ce_zone_heat))
		return null
	return armor


/// Горячая ли группа зон брони: не остыли лицо или подбой.
/datum/extension/armor/proc/ce_is_hot(group)
	var/datum/ce_armor_heat/heat = ce_get_heat(group)
	return heat && (heat.temperature > 0 || heat.inner_temperature > 0)


/// Сколько в реагентах жидкостей, которыми остужают броню (`ce_laser_coolant_strengths`), единиц.
/proc/ce_get_coolant_amount(datum/reagents/reagents)
	. = 0
	if(!reagents)
		return
	for(var/coolant_type in ce_laser_coolant_strengths)
		. += reagents.get_reagent_amount(coolant_type, TRUE)


/**
 * Забирает из реагентов до `units` единиц жидкостей, которыми остужают броню, — сильные первыми, в
 * порядке `ce_laser_coolant_strengths`. Возвращает `list(сколько забрано, сколько это в единицах
 * хладагента)`.
 */
/datum/reagents/proc/ce_take_coolants(units)
	RETURN_TYPE(/list)
	var/taken = 0
	var/coolant_units = 0
	for(var/coolant_type in ce_laser_coolant_strengths)
		var/list/amounts = get_reagent_amount_list(coolant_type)
		for(var/reagent_type in amounts)
			var/amount = min(units - taken, amounts[reagent_type])
			if(amount <= 0)
				continue
			remove_reagent(reagent_type, amount)
			taken += amount
			coolant_units += amount * ce_laser_coolant_strengths[coolant_type]
	return list(taken, coolant_units)


/**
 * Льёт хладагент или воду из `container` на группу зон `group`. `wearer` — на ком броня, null —
 * снятая. TRUE — клик разобран: броню полили, или полив прервали. FALSE — поливать нечем или броня не
 * горячая, и клик идёт дальше.
 */
/datum/extension/armor/proc/ce_try_pour_coolant(obj/item/reagent_containers/container, group, mob/living/user, mob/living/carbon/human/wearer)
	if(!ce_laser_heat_enabled || !container.is_open_container() || ce_get_coolant_amount(container.reagents) <= 0 || !ce_is_hot(group))
		return FALSE
	var/obj/item/armor_item = holder
	user.visible_message(
		SPAN_NOTICE("\The [user] starts pouring \the [container] over \the [armor_item]."),
		SPAN_NOTICE("You start pouring \the [container] over \the [armor_item].")
	)
	if(!do_after(user, ce_get_pour_delay(user, wearer), wearer || armor_item.ce_get_do_after_target(), DO_PUBLIC_UNIQUE))
		return TRUE
	// За время полива ёмкость могли убрать или опустошить, а броню — снять или остудить.
	if(user.get_active_hand() != container || !container.is_open_container() || !ce_is_hot(group) || ce_get_heat_wearer() != wearer)
		return TRUE
	var/list/poured = container.reagents.ce_take_coolants(ce_laser_coolant_pour_units)
	var/units = poured[1]
	if(units <= 0)
		return TRUE
	ce_quench(group, poured[2], wearer)
	user.visible_message(
		SPAN_NOTICE("\The [user] pours \the [container] over \the [armor_item]."),
		SPAN_NOTICE("You pour [units] unit\s from \the [container] over \the [armor_item].")
	)
	return TRUE


/// Сколько идёт полив: снятую броню поливают быстрее всего, броню на себе — дольше всего.
/proc/ce_get_pour_delay(mob/living/user, mob/living/carbon/human/wearer)
	if(!wearer)
		return ce_laser_coolant_delay
	return wearer == user ? ce_laser_coolant_self_delay : ce_laser_coolant_other_delay


/**
 * `units` единиц хладагента на группу зон — вода сюда приходит уже в пересчёте на него: остужают
 * лицо, а у снятой брони и подбой. Раскалённая керамика трескается, горячая броня парит.
 */
/datum/extension/armor/proc/ce_quench(group, units, mob/living/carbon/human/wearer)
	var/datum/ce_armor_heat/heat = ce_get_heat(group)
	var/stage = ce_get_heat_stage(heat.temperature)
	var/cooling = units * (wearer ? ce_laser_coolant_worn_cooling : ce_laser_coolant_cooling)
	heat.temperature = max(0, heat.temperature - cooling)
	if(!wearer)
		heat.inner_temperature = max(0, heat.inner_temperature - cooling)
	ce_crack_from_quench(group, stage, wearer)
	ce_release_steam(stage)
	ce_update_glow()


/// Броня, раскалённая с `ce_laser_quench_crack_stage`, трескается от удара холодом, если её материал хрупкий.
/datum/extension/armor/proc/ce_crack_from_quench(group, stage, mob/living/wearer)
	var/singleton/ce_armor_material/material = ce_get_material()
	if(material.heat_quench_crack <= 0 || stage < ce_laser_quench_crack_stage)
		return
	var/obj/item/armor_item = holder
	armor_item.visible_message(SPAN_WARNING("\The [armor_item] cracks from the thermal shock!"))
	var/outer_body_part = ce_set_hit_body_part(group ? ce_armor_zone_groups[group] : null)
	ce_take_wear(ce_get_health_max(group) * material.heat_quench_crack, wearer)
	ce_set_hit_body_part(outer_body_part)


/// Горячую броню остужают: она шипит и парит — `puffs` клубов пара, не больше десяти.
/datum/extension/armor/proc/ce_release_steam(puffs)
	var/turf/turf = get_turf(holder)
	if(puffs <= 0 || !turf)
		return
	playsound(turf, 'sound/effects/iron_sizzle.ogg', 20 + 10 * puffs, TRUE)
	var/datum/effect/steam_spread/steam = new
	steam.set_up(puffs, 0, turf)
	steam.start()


/**
 * Брызги остужают лицо брони на `cooling` во всех её группах зон, не чаще раза в
 * `ce_laser_spray_interval`. Подбоя не касаются.
 */
/datum/extension/armor/proc/ce_spray(cooling)
	if(ce_spray_time && world.time < ce_spray_time + ce_laser_spray_interval)
		return
	ce_spray_time = world.time
	var/stage = ce_get_armor_heat_stage()
	for(var/datum/ce_armor_heat/heat as anything in ce_get_all_heat())
		heat.temperature = max(0, heat.temperature - cooling)
	ce_release_steam(stage ? 1 : 0)
	ce_update_glow()


/// Насколько брызги этих реагентов остужают броню — по самой сильной жидкости в них, от единицы
/// объёма: хладагент сильнее воды. 0 — ни того, ни другого.
/datum/reagents/proc/ce_get_spray_cooling()
	for(var/coolant_type in ce_laser_coolant_strengths)
		if(get_reagent_amount(coolant_type, TRUE) >= 1)
			return ce_laser_spray_cooling * ce_laser_coolant_strengths[coolant_type]
	return 0


/// Брызги этих реагентов на моба или вещь остужают горячую броню на нём.
/datum/reagents/proc/ce_spray_armor(atom/target)
	if(!ce_laser_heat_enabled)
		return
	var/cooling = ce_get_spray_cooling()
	if(cooling <= 0)
		return
	var/list/items
	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		items = human.ce_get_worn_armor_items()
	else if(istype(target, /obj/item/clothing))
		var/obj/item/clothing/clothing = target
		items = list(clothing)
		if(clothing.accessories)
			items += clothing.accessories
	else if(istype(target, /obj/item/rig))
		var/obj/item/rig/rig = target
		items = rig.ce_get_pieces()
	for(var/obj/item/item as anything in items)
		ce_get_heated_armor(item)?.ce_spray(cooling)


/**
 * Самая горячая броня среди вещей `items`: `list(броня, группа зон)`. Горячее — выше лицо или подбой.
 * null — горячей брони нет.
 */
/proc/ce_find_hottest_armor(list/items)
	var/hottest_temperature = 0
	for(var/obj/item/item as anything in items)
		var/datum/extension/armor/armor = ce_get_heated_armor(item)
		if(!armor)
			continue
		for(var/datum/ce_armor_heat/heat as anything in armor.ce_get_all_heat())
			var/temperature = max(heat.temperature, heat.inner_temperature)
			if(temperature > hottest_temperature)
				hottest_temperature = temperature
				. = list(armor, heat.group)


/**
 * Льёт хладагент на самую горячую броню, которую человек носит. Как `ce_try_pour_coolant()` брони:
 * FALSE — горячей брони нет, и клик идёт дальше.
 */
/mob/living/carbon/human/proc/ce_try_pour_coolant(obj/item/reagent_containers/container, mob/living/user)
	var/list/hottest = ce_find_hottest_armor(ce_get_worn_armor_items())
	if(!hottest)
		return FALSE
	var/datum/extension/armor/armor = hottest[1]
	return armor.ce_try_pour_coolant(container, hottest[2], user, src)


/**
 * Льёт хладагент на самую горячую броню среди вещей `items`, надетых или нет. FALSE — `tool` не
 * ёмкость или горячей брони нет, и клик идёт дальше.
 */
/proc/ce_try_pour_coolant_on(list/items, obj/item/tool, mob/living/user)
	var/obj/item/reagent_containers/container = tool
	if(!istype(container) || !ce_laser_heat_enabled)
		return FALSE
	var/list/hottest = ce_find_hottest_armor(items)
	if(!hottest)
		return FALSE
	var/datum/extension/armor/armor = hottest[1]
	return armor.ce_try_pour_coolant(container, hottest[2], user, armor.ce_get_heat_wearer())


/// Льёт хладагент на самую горячую броню этой вещи и её аксессуаров, как `ce_try_pour_coolant_on()`.
/obj/item/clothing/proc/ce_try_pour_coolant(obj/item/tool, mob/living/user)
	var/list/items = list(src)
	if(accessories)
		items += accessories
	return ce_try_pour_coolant_on(items, tool, user)
