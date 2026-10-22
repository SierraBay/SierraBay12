/*
	COMBAT_EXTENDED — осколки от поломки брони.

	Броня, помеченная `ce_armor_shards`, за точкой поломки колется внутрь. Каждое попадание,
	снявшее с неё HP ниже точки, бросает шанс осколка: доля снятых ниже точки HP от максимума, в
	процентах, с множителем материала. Осколок наносит носителю острый урон в зону попадания и
	застревает в ране. Из чего он и сколько бьёт — решает материал брони (`armor_materials.dm`).

	Бросок делает `ce_apply_wear()`, а наносится осколок после основного попадания, из обёртки
	`apply_damage()` в `_master_files` — по той же причине, что и остаточный удар
	(`residual_blunt.dm`): кор код держит `organ`, найденный ещё до брони.
*/

/obj/item
	/// Броня вещи за точкой поломки колется осколками в носителя. Материалу вещи нужен свой
	/// осколок (`shard_material`). Задаётся в блоке вещи в `code/items/`.
	var/ce_armor_shards = FALSE

/mob/living/carbon/human
	/// Осколки, ждущие конца попадания: по `list(зона, вещь брони)` на каждый. Живут внутри одного
	/// вызова `apply_damage()`.
	var/list/ce_pending_shards


/**
 * Шанс осколка в процентах за износ группы зон с `old_health` до `new_health` HP. Считаются только
 * HP, снятые ниже точки поломки: попадание, которое её проходит, колет броню лишь своей частью
 * за точкой, а с брони в нуле снимать уже нечего. 0 — вещь не колется.
 */
/datum/extension/armor/proc/ce_get_shard_chance(group, old_health, new_health)
	var/obj/item/armor_item = holder
	if(!istype(armor_item) || !armor_item.ce_armor_shards)
		return 0
	var/singleton/ce_armor_material/material = ce_get_material()
	if(!material.shard_material)
		return 0

	var/health_max = ce_get_health_max(group)
	var/break_point = ce_get_break_point() || ce_get_curve_break_point(ce_armor_condition_curve)
	var/lost_below_break = min(old_health, health_max * break_point) - new_health
	if(lost_below_break <= 0)
		return 0
	return 100 * lost_below_break / health_max * material.shard_chance_mult


/// Ставит в очередь осколок от `armor_item` в зону попадания. У простых мобов и экзокостюмов
/// органов нет, и осколку некуда застрять.
/mob/living/proc/ce_queue_shard(def_zone, obj/item/armor_item)
	return

/// Зона запоминается строкой, как у остаточного удара: оторванная основным попаданием
/// конечность ловит осколок культёй.
/mob/living/carbon/human/ce_queue_shard(def_zone, obj/item/armor_item)
	var/obj/item/organ/external/organ = ce_resolve_organ(def_zone)
	if(!organ)
		return
	LAZYADD(ce_pending_shards, list(list(organ.organ_tag, armor_item)))


/**
 * Сам осколок: острый урон в конечность мимо брони — он уже под ней. Застревает, как осколок пули
 * (`/obj/item/projectile/after_wounding()`), только в порезе или проколе: протез и вид без мелких
 * порезов его не держат, и осколок падает на пол.
 */
/mob/living/carbon/human/proc/ce_apply_shard(organ_tag, obj/item/armor_item)
	var/obj/item/organ/external/organ = get_organ(organ_tag)
	if(!organ)
		return
	var/singleton/ce_armor_material/material = GET_SINGLETON(armor_item.ce_armor_material)
	// Материал Bay без осколков удалил бы осколок ещё в `New()`. Материалы брони проверяет
	// юнит-тест «Осколки от поломки брони».
	var/material/shard_source = SSmaterials.get_material_by_name(material.shard_material)
	ASSERT(shard_source?.shard_type)
	var/obj/item/material/shard/shrapnel/shard = new(get_turf(src), material.shard_material)

	visible_message(
		SPAN_DANGER("\The [shard] from \the [armor_item] pierces [src]'s [organ.name]!"),
		SPAN_DANGER("\The [shard] from your [armor_item.name] pierces your [organ.name]!")
	)
	var/brute_before = organ.brute_dam
	var/datum/wound/wound = organ.take_external_damage(material.shard_damage, 0, DAMAGE_FLAG_SHARP, shard)
	if(!wound && organ.brute_dam > brute_before)
		wound = ce_find_pierce_wound(organ)
	if(wound && (wound.damage_type == INJURY_TYPE_CUT || wound.damage_type == INJURY_TYPE_PIERCE))
		organ.embed(shard, TRUE, null, wound)
	updatehealth()


/**
 * Открытый прокол конечности, null — его нет. Прокол осколка Bay сливает с открытым проколом того
 * же вида и стадии (`createwound()`), и тогда `take_external_damage()` раны не отдаёт, хотя урон
 * нанесён. Осколок застревает в открытом проколе.
 */
/proc/ce_find_pierce_wound(obj/item/organ/external/organ)
	for(var/datum/wound/open_wound as anything in organ.wounds)
		if(open_wound.damage_type == INJURY_TYPE_PIERCE)
			return open_wound
	return null
