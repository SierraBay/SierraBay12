/*
	COMBAT_EXTENDED — зональная броня.

	Грудная секция РИГа и скафандр — одна вещь на торс, руки и ноги, и с одним запасом HP
	выстрелы в грудь съедали бы броню ног. Зональная вещь изнашивается и читается по группам зон:
	торс, руки, ноги. Так она повторяет плитоноску, где пластина, наручи и поножи — разные вещи.
	Перчатки и ботинки и так отдельные вещи, поэтому зональные сейчас только грудные секции.

	HP групп лежат в `ce_zone_health` на расширении, `ce_health` у зональной вещи не используется.
	Торс несёт HP вещи, вторичные группы — их долю (`ce_armor_secondary_zone_health_mult`). Ту же
	долю берут наручи и поножи плитоноски: это та же броня рук и ног, только отдельной вещью.
	Группа в процедурах — `CE_ARMOR_ZONE_*`, либо null у незональной брони с одним запасом HP.

	Рейтинг читается через `get_value()`, а зоны у неё нет: процентный путь laser/energy/bomb
	зовёт её из кор кода. Поэтому зона попадания — контекст `GLOB.ce_hit_body_part`: его ставят
	на время вызова проход по слоям и процентные ветки `modify_damage_by_armor()` и
	`get_blocked_ratio()`, а кодекс — на время чтения каждой группы. Без контекста зональная
	вещь читается и изнашивается как торс.
*/

/// Часть тела (флаг `body_parts_covered`), по которой сейчас читается и изнашивается зональная
/// броня. null — зона неизвестна.
GLOBAL_VAR(ce_hit_body_part)

/datum/extension/armor
	/// HP зональной брони по группам зон, `CE_ARMOR_ZONE_*` -> HP. Группы, которых здесь нет, целы.
	var/list/ce_zone_health

/obj/item
	/// Зональная броня: торс, руки и ноги изнашиваются и читаются отдельно. Задаётся в блоке вещи
	/// в `code/items/`.
	var/ce_armor_zoned = FALSE
	/// Своя доля HP вторичных групп зон от HP вещи — у зональной брони, наручей и поножей.
	/// null — `ce_armor_secondary_zone_health_mult`.
	var/ce_armor_secondary_zone_health_mult


/**
 * Ставит часть тела (флаг `body_parts_covered` либо null), по которой читается зональная броня.
 * Возвращает прежнюю: её надо вернуть этой же процедурой после чтения.
 */
/proc/ce_set_hit_body_part(body_part)
	. = GLOB.ce_hit_body_part
	GLOB.ce_hit_body_part = body_part


/// Группа зон, в которую входит часть тела. null и часть тела вне групп читаются как торс.
/proc/ce_get_armor_zone_group(body_part)
	for(var/group in ce_armor_zone_groups)
		if(ce_armor_zone_groups[group] & body_part)
			return group
	return CE_ARMOR_ZONE_TORSO


/**
 * Часть тела (флаг `body_parts_covered`) по зоне попадания. Зональную броню носят только люди: у
 * остальных мобов частей тела нет, и броня читается как торс.
 */
/mob/living/proc/ce_get_hit_body_part(def_zone)
	return null

/mob/living/carbon/human/ce_get_hit_body_part(def_zone)
	var/obj/item/organ/external/organ = ce_resolve_organ(def_zone)
	return organ?.body_part


/datum/extension/armor/proc/ce_is_zoned()
	var/obj/item/armor_item = holder
	return istype(armor_item) && armor_item.ce_armor_zoned && ce_can_wear()


/// Группа зон, которую сейчас читает и изнашивает попадание.
/datum/extension/armor/proc/ce_get_wear_group()
	if(!ce_is_zoned())
		return null
	return ce_get_armor_zone_group(GLOB.ce_hit_body_part)


/// Группы зон, которые закрывает зональная вещь, в порядке `ce_armor_zone_groups`. Пустой list у незональной.
/datum/extension/armor/proc/ce_get_zone_groups()
	RETURN_TYPE(/list)
	. = list()
	if(!ce_is_zoned())
		return
	var/obj/item/armor_item = holder
	for(var/group in ce_armor_zone_groups)
		if(armor_item.body_parts_covered & ce_armor_zone_groups[group])
			. += group


/// Носит ли вещь броню вторичной группы зон целиком: наручи или поножи.
/datum/extension/armor/proc/ce_is_secondary_zone_accessory()
	var/obj/item/clothing/accessory/accessory = holder
	return istype(accessory) && (accessory.slot in ce_armor_secondary_zone_accessory_slots)


/// Доля HP группы зон от HP вещи. У незональной брони (группа null) долю берут только наручи и поножи.
/datum/extension/armor/proc/ce_get_zone_health_mult(group)
	var/is_secondary = group ? group != CE_ARMOR_ZONE_TORSO : ce_is_secondary_zone_accessory()
	if(!is_secondary)
		return 1
	var/obj/item/armor_item = holder
	var/item_mult = armor_item.ce_armor_secondary_zone_health_mult
	return isnull(item_mult) ? ce_armor_secondary_zone_health_mult : item_mult


/// Текущие HP группы зон. null — группа ещё не изнашивалась.
/datum/extension/armor/proc/ce_get_health(group)
	if(!group)
		return ce_health
	return LAZYACCESS(ce_zone_health, group)


/datum/extension/armor/proc/ce_set_health(group, health)
	if(!group)
		ce_health = health
		return
	LAZYSET(ce_zone_health, group, health)
