/*
	COMBAT_EXTENDED — кислота против одежды и брони.

	В Бэй кислота на коже (`/datum/reagent/acid/affect_touch()`) смотрит только на голову: плавит по
	очереди головной убор, маску и очки и жжёт случайную часть тела. Броня, жилеты и перчатки ей не
	помеха, а спасает только кислотостойкий (`unacidable`) убор — зато всё тело разом. В Сьерре
	доза к тому же не зависит от количества (ПР «Inf acids»): любая капля считается за 50 единиц —
	плавит всё с головы и жжёт на полную.

	Здесь:
	- доза — сколько кислоты вылилось на человека на самом деле: полный ожог Сьерры даёт доза
	  плавления (`meltdose`), меньшая — свою долю (`ce_get_full_burn()`, `ce_get_dose_share()`);
	- всплеск делится по частям тела по их площади (`ce_acid_part_shares`), голова — на макушку,
	  глаза и рот (`ce_trace_acid()`);
	- на каждой части кислота идёт через вещи снаружи внутрь (`ce_meet_acid()`): кислотостойкая вещь
	  её не пускает, непроницаемая — пускает по своему `permeability_coefficient`, броня
	  останавливает и теряет HP, очки, закрывающие глаза, глаза спасают. Одежда не помеха, даже с
	  рейтингом: форма охраны, ботинки и каска — не броня;
	- ожог — полный на долю дозы и на долю тела, до кожи которой кислота дошла; достаётся он одной
	  случайной части тела из таких;
	- лицо обезображивается, когда до открытых глаз или рта дошла доза плавления (`meltdose`);
	- вещи без защиты на голове — убор, маска, очки — плавятся, когда до них дошла доза плавления.
	  Защитные вещи не плавятся.

	Зовётся из оверрайда `affect_touch()` в `_master_files`. Не люди — по правилам Бэй.
*/

/// Доля ожога на единицу кислоты и её `power` в формуле Бэй.
#define CE_ACID_BURN_RATE 0.2

/// Чем кончился для человека всплеск кислоты: до чего она дошла и что встретила по пути.
/datum/ce_acid_trace
	/// Доля всплеска, дошедшая до кожи.
	var/skin_share = 0
	/// Части тела, до кожи которых кислота дошла.
	var/list/obj/item/organ/external/burned = list()
	/// Доля кислоты, дошедшая до глаз или рта, от пришедшейся на них, — наибольшая из двух. Ноль —
	/// лицо закрыто.
	var/face_exposure = 0
	/// Броня, остановившая кислоту: `list(броня, часть тела, остановленная доля всплеска)` на каждую
	/// встречу.
	var/list/armor_hits = list()
	/// Вещи без защиты на голове, через которые кислота прошла: вещь -> доля кислоты, дошедшая до
	/// неё, от пришедшейся на её часть тела.
	var/list/soaked = list()


/**
 * Броня вещи с рейтингом против клинка или удара. Броня от заразы или радиации — у маски, у халата
 * — не в счёт. Изношенная в ноль рейтинга не несёт. Зональная броня читается по части тела
 * текущего попадания (`ce_set_hit_body_part()`).
 */
/obj/item/proc/ce_get_kinetic_armor()
	RETURN_TYPE(/datum/extension/armor)
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	if(armor && (armor.ce_get_cold_sharp_melee() > 0 || armor.ce_get_cold_blunt() > 0))
		return armor
	return null


/**
 * Броня вещи, которая держит кислоту: жёсткая (`is_hard_armor()`) или из баллистического волокна —
 * шлем, жилет, пластина и вставка плитоноски, наручи, поножи. Одежда с рейтингом — форма охраны,
 * ботинки, каска — не броня: кислота её пропитывает.
 */
/obj/item/proc/ce_get_acid_armor()
	RETURN_TYPE(/datum/extension/armor)
	var/datum/extension/armor/armor = ce_get_kinetic_armor()
	if(!armor)
		return null
	var/singleton/ce_armor_material/material = armor.ce_get_material()
	return (armor.is_hard_armor() || material.ballistic_fiber) ? armor : null


/// Вещь кислоте не помеха, и кислота её плавит: не кислотостойкая, проницаемая и без рейтинга
/// брони. Одежда с рейтингом кислоту тоже не держит, но и не плавится.
/obj/item/proc/ce_is_acid_flimsy()
	return !unacidable && permeability_coefficient >= 1 && !ce_get_kinetic_armor()


/**
 * Вещь на части тела `body_part` носителя встречает кислоту. `reaching` — доля кислоты этой части,
 * дошедшая до вещи, `share` — доля всплеска, пришедшаяся на часть. Возвращает долю, прошедшую
 * дальше, и записывает в `trace`, чем встреча кончилась для самой вещи.
 *
 * Защищает вещь только ту часть, которую закрывает: кепка, сидящая на макушке, но не закрывающая
 * её, кислоту не держит.
 */
/obj/item/clothing/proc/ce_meet_acid(datum/ce_acid_trace/trace, mob/living/carbon/human/wearer, body_part, share, reaching)
	if(body_parts_covered & body_part)
		if(unacidable || (body_part == EYES && src == wearer.glasses))
			return 0
		reaching *= clamp(permeability_coefficient, 0, 1)
		if(reaching <= 0)
			return 0
		var/datum/extension/armor/armor = ce_get_acid_armor()
		if(armor)
			trace.armor_hits += list(list(armor, body_part, share * reaching))
			return 0
	if(wearer.ce_acid_melts(src) && ce_is_acid_flimsy())
		trace.soaked[src] = max(trace.soaked[src], reaching)
	return reaching


/// Кислота плавит на человеке только то, что на голове: убор, маску и очки, — как в Бэй.
/mob/living/carbon/human/proc/ce_acid_melts(obj/item/worn)
	return worn == head || worn == wear_mask || worn == glasses


/// Вещи на человеке, которые встречает кислота, снаружи внутрь: на голове — убор, маска, очки; на
/// теле — верхняя одежда, перчатки, обувь, униформа. Аксессуар идёт перед вещью, на которой висит.
/mob/living/carbon/human/proc/ce_get_acid_covers()
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/clothing/gear in list(head, wear_mask, glasses, wear_suit, gloves, shoes, w_uniform))
		for(var/obj/item/clothing/accessory/accessory in gear.accessories)
			. += accessory
		. += gear


/// Надета ли вещь на часть тела `body_part`: закрывает её либо просто сидит на ней — кепка на
/// макушке, бандана на рту, очки на глазах, что бы они сами ни закрывали.
/mob/living/carbon/human/proc/ce_wears_on(obj/item/clothing/cover, body_part)
	if(cover.body_parts_covered & body_part)
		return TRUE
	switch(body_part)
		if(HEAD)
			return cover == head
		if(FACE)
			return cover == wear_mask
		if(EYES)
			return cover == glasses
	return FALSE


/**
 * Проводит кислоту через вещи на части тела `body_part`, снаружи внутрь, и записывает в `trace`,
 * что она встретила. `share` — доля всплеска, пришедшаяся на эту часть. Возвращает долю от
 * `share`, дошедшую до кожи, 0..1.
 */
/mob/living/carbon/human/proc/ce_trace_acid_part(datum/ce_acid_trace/trace, list/covers, body_part, share)
	. = 1
	var/outer_body_part = ce_set_hit_body_part(body_part)
	for(var/obj/item/clothing/cover as anything in covers)
		if(!ce_wears_on(cover, body_part))
			continue
		. = cover.ce_meet_acid(trace, src, body_part, share, .)
		if(. <= 0)
			break
	ce_set_hit_body_part(outer_body_part)


/**
 * Проводит всплеск кислоты по частям тела: до чего она дошла и что встретила. Чистый запрос: вещи
 * и тело не меняются.
 *
 * Голова делится на макушку (`ce_acid_scalp_share`), глаза и рот: их закрывают разные вещи, и
 * закрытое лицо — это закрытые и глаза, и рот.
 */
/mob/living/carbon/human/proc/ce_trace_acid()
	RETURN_TYPE(/datum/ce_acid_trace)
	var/datum/ce_acid_trace/trace = new
	var/list/covers = ce_get_acid_covers()
	for(var/obj/item/organ/external/organ in organs)
		var/share = ce_acid_part_shares[organ.organ_tag]
		if(!share || organ.is_stump())
			continue
		var/reached
		if(organ.organ_tag == BP_HEAD)
			var/scalp_share = share * ce_acid_scalp_share
			var/face_part_share = (share - scalp_share) / 2
			var/eyes = ce_trace_acid_part(trace, covers, EYES, face_part_share)
			var/mouth = ce_trace_acid_part(trace, covers, FACE, face_part_share)
			trace.face_exposure = max(eyes, mouth)
			reached = scalp_share * ce_trace_acid_part(trace, covers, HEAD, scalp_share) + face_part_share * (eyes + mouth)
		else
			reached = share * ce_trace_acid_part(trace, covers, organ.body_part, share)
		if(reached <= 0)
			continue
		trace.skin_share += reached
		if(organ.is_damageable())
			trace.burned += organ
	return trace


/// Полный ожог от этой кислоты — тот, что в Сьерре давала любая капля: `touch_met` единиц по
/// формуле Бэй, не больше `max_damage`. Политриновая — 60, серная — 40, соляная — 30.
/datum/reagent/acid/proc/ce_get_full_burn()
	return min(touch_met * power * CE_ACID_BURN_RATE, max_damage)


/// Доля полного действия кислоты от всплеска в `splash` единиц: полное — с дозы плавления, ниже
/// неё — по количеству.
/datum/reagent/acid/proc/ce_get_dose_share(splash)
	return clamp(splash / meltdose, 0, 1)


/// Броня, остановившая кислоту, теряет столько HP, сколько ожога не пустила к коже. Осколков от
/// такого износа нет: кислота броню разъедает, а не раскалывает.
/datum/reagent/acid/proc/ce_wear_acid_armor(datum/ce_acid_trace/trace, splash)
	var/splash_burn = ce_get_full_burn() * ce_get_dose_share(splash)
	for(var/list/hit as anything in trace.armor_hits)
		var/datum/extension/armor/armor = hit[1]
		var/outer_body_part = ce_set_hit_body_part(hit[2])
		armor.ce_take_wear(splash_burn * hit[3] * ce_acid_armor_wear_mult)
		ce_set_hit_body_part(outer_body_part)


/// Плавит вещи без защиты на голове, до которых дошла доза плавления.
/datum/reagent/acid/proc/ce_melt_soaked(mob/living/carbon/human/victim, datum/ce_acid_trace/trace, splash)
	var/melted = FALSE
	for(var/obj/item/worn as anything in trace.soaked)
		if(splash * trace.soaked[worn] < meltdose)
			continue
		to_chat(victim, SPAN_DANGER("The liquid melts your [worn.name] away!"))
		qdel(worn)
		melted = TRUE
	if(!melted)
		return
	victim.update_inv_head(0)
	victim.update_inv_wear_mask(0)
	victim.update_inv_glasses(0)
	victim.update_hair(1)


/**
 * Кислота на коже человека. `dose` — сколько её на коже на самом деле, единицы.
 *
 * На кожу попало только то, что пустила непроницаемая одежда (`splash_mob()`,
 * `reagent_permeability()`), а вещи встретили весь всплеск: он восстанавливается по той же
 * проницаемости. Ожог — полный ожог кислоты на долю дозы и на долю тела, до кожи которой она дошла.
 */
/datum/reagent/acid/proc/ce_burn_human(mob/living/carbon/human/victim, dose)
	if(dose <= 0)
		return
	var/permeability = victim.reagent_permeability()
	var/splash = permeability > 0 ? dose / permeability : dose
	var/datum/ce_acid_trace/trace = victim.ce_trace_acid()
	ce_wear_acid_armor(trace, splash)
	ce_melt_soaked(victim, trace, splash)

	var/burn = ce_get_full_burn() * ce_get_dose_share(splash) * trace.skin_share
	if(burn <= 0 || victim.unacidable || !length(trace.burned))
		to_chat(victim, SPAN_WARNING("Your gear keeps the liquid off your skin."))
		return
	victim.visible_message(
		SPAN_WARNING("\The [victim]'s skin sizzles and burns on contact with the liquid!"),
		SPAN_DANGER("Your skin sizzles and burns!")
	)
	var/obj/item/organ/external/burned = pick(trace.burned)
	if(burned.take_external_damage(0, burn))
		SET_BIT(victim.hud_updateflag, HEALTH_HUD)
	victim.updatehealth()
	if(splash >= meltdose && victim.can_feel_pain())
		victim.emote("scream")
	if(splash * trace.face_exposure >= meltdose)
		var/obj/item/organ/external/face = victim.get_organ(BP_HEAD)
		face?.disfigure(INJURY_TYPE_BURN)

#undef CE_ACID_BURN_RATE
