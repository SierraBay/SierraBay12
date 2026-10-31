/*
	COMBAT_EXTENDED — плотность тканей и досягаемость органов.

	Плотность — последний шаг прохода по слоям, как шаг 4 в CE: `pen -= плотность`, урон не
	трогается. Сама по себе она органы не отсекает — 0.22 мм плоти на фоне пробития Bay
	погрешность. Её дело — уменьшить остаток пробития, из которого считаются остаточный удар и
	досягаемость.

	До органов атаку пускает глубина досягаемости `D`: `P = reach × P_bay`. Сам `P_bay` — выбор
	органа, рёбра, `damage_reduction` — остаётся байевским, его считает кор
	`damage_internal_organs()`. Оверрайд в `_master_files` только решает, звать ли его.
*/


/singleton/species
	/// Острая плотность плоти, мм RHA, при здоровье `CE_FLESH_REFERENCE_HEALTH`.
	var/ce_flesh_rha = CE_FLESH_RHA

/datum/robolimb
	/// Острая плотность корпуса протеза, мм RHA. null — протез считается плотью владельца.
	/// Здоровьем вида не масштабируется: толщина корпуса от вида не зависит.
	var/ce_density

/mob/living/carbon/human
	/// Контекст попадания для `damage_internal_organs()`: `list(organ_tag конечности, reach)`. Пишется
	/// проходом по слоям, читается один раз, чистится обёрткой `apply_damage()`.
	var/list/ce_hit_context


/// Досягаемость органов 0..1 по остатку острого пробития после брони и плоти, мм RHA.
/proc/ce_organ_reach(pen, damage_flags)
	var/depth = (damage_flags & DAMAGE_FLAG_BULLET) ? ce_organ_depth_bullet : ce_organ_depth_melee
	if(depth <= 0)
		return 1
	return clamp(pen / depth, 0, 1)


/// Острая плотность части тела, мм RHA. У мобов без органов её нет: доходить не до чего.
/mob/living/proc/ce_part_density(def_zone)
	return 0

/// Подкожная броня добавляется поверх и плоти, и корпуса протеза (`subdermal_armor.dm`).
/mob/living/carbon/human/ce_part_density(def_zone)
	var/obj/item/organ/external/organ = ce_resolve_organ(def_zone)
	if(!organ)
		return 0
	return ce_tissue_density(organ) + ce_get_subdermal_density()


/// Острая плотность самой части тела, без подкожной брони, мм RHA.
/mob/living/carbon/human/proc/ce_tissue_density(obj/item/organ/external/organ)
	if(BP_IS_ROBOTIC(organ) && organ.model)
		var/datum/robolimb/model = all_robolimbs[organ.model]
		if(model && !isnull(model.ce_density))
			return model.ce_density

	return species.ce_flesh_rha * species.total_health / CE_FLESH_REFERENCE_HEALTH


/**
 * Запоминает досягаемость органов для этого попадания. Зовётся только боевым проходом, не
 * консультационным. У рикошета и остаточного удара досягаемость 0.
 */
/mob/living/proc/ce_note_hit(def_zone, reach)
	return

/mob/living/carbon/human/ce_note_hit(def_zone, reach)
	if(!ce_organ_depth_enabled)
		return
	var/obj/item/organ/external/organ = ce_resolve_organ(def_zone)
	if(!organ)
		return
	ce_hit_context = list(organ.organ_tag, reach)


/**
 * Конечность по зоне попадания. `apply_damage()` передаёт в проход по слоям то строку зоны,
 * то сам орган, а зона может быть ещё и `BP_EYES` или `BP_MOUTH`.
 */
/mob/living/carbon/human/proc/ce_resolve_organ(def_zone)
	if(istype(def_zone, /obj/item/organ/external))
		return def_zone
	return get_organ(check_zone(def_zone))
