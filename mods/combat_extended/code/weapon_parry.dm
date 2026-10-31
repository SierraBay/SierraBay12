/*
	COMBAT_EXTENDED — парирование с прочностью оружия (§12 спеки, с отступлениями).

	Бросок парирования остаётся байевским: шанс оружия, навык ближнего боя, дуга. Меняется то, что
	бывает после удачного парирования. В Bay удар просто исчезал, а оружие теряло 1 HP с шансом
	твёрдости материала — только материальное и только от материального.

	Здесь оружие встречает удар первым слоем брони, как щит (`shields.dm`), со своей прочностью
	(Toughness) вместо брони:
	- острое, пробившее оружие, идёт дальше, в зону попадания, как обычно, — ослабленное оружием;
	- тупое, которое прошло оружие, — тупой удар или острое, которое оружие остановило и которое
	  срикошетило в тупое, — в зону не идёт, а уходит волной в руку с оружием, мимо брони, в доле
	  `ce_parry_shock_mult`. У оружия в двух руках волна делится между обеими. Это отступление от
	  CE: там парирующему не достаётся ничего;
	- оружие снимает с себя износ: половину того, что его прошло, как в CE.
	Так встречается удар, урон которого дальше пройдёт броню (`ce_shield_armor_call`). Проверку без
	урона — захват, обезоруживание — и некинетический удар — ожог — оружие отбивает целиком, как в
	Bay, сняв с себя износ сразу.

	Прочность — материал, размер и навык, как в CE:
	- материал — твёрдость материала оружия, у оружия без материала — главного материала из
	  `matter`, без него — стали;
	- размер — место в рюкзаке (`BASE_STORAGE_COST`) относительно обычного. Острая прочность — это
	  толщина клинка, она растёт корнем из размера, как корень из Bulk в автопатчере прочности CE.
	  Тупая — это масса, которая гасит удар, она растёт с размером прямо: нож тяжёлый удар почти не
	  держит, ящик и топор держат. Оружие без острия и кромки цельное и держит вдвое лучше;
	- навык ближнего боя носителя.
	Острая прочность стального оружия обычного размера с кромкой — как у брони
	`CE_PARRY_REFERENCE_ARMOR`, тупая — `ce_parry_blunt_toughness`.

	HP — те же, что у материального оружия Bay: `integrity / 5` материала. Материальное оружие
	держит их в здоровье атома и на нуле раскалывается само (`shatter()`), хрупкое — от любого
	износа, как и в Bay. У остального HP живут на вещи, в `ce_parry_health`: здоровье атома
	поменяло бы вещи поведение во взрыве. Такая вещь на нуле ломается и вываливает содержимое.

	Не изнашиваются нематериальные вещи (`ce_armor_nonphysical`) — энергомечи, голограммы,
	псионика, — и волны они не дают. Не изнашивается и помеченное `ce_parry_unbreakable`: оружие
	генокрада и стопки. Ножи Bay помечены `unbreakable`, но от парирования изнашиваются: флаг Bay
	спасает их только от раскалывания о броню.

	Крит — два независимых броска, как в CE. Первый — чистое парирование: удар отбит целиком, ни
	износа, ни волны. Второй — ответный удар: оружие бьёт атакующего своей силой, через его броню.
	Безоружную атаку — удар рукой, захват, обезоруживание — ответ бьёт в руку, которой атаковали:
	это бывший порез о вещь при обезоруживании, в Bay он бросался на каждую попытку. Атаку оружием —
	в зону, которую выбрал парирующий.
*/

/obj/item
	/// Оружие парирует, но от этого не изнашивается и не ломается. Нематериальному
	/// (`ce_armor_nonphysical`) флаг не нужен. Задаётся в блоке вещи в `code/items/`.
	var/ce_parry_unbreakable = FALSE
	/// HP износа от парирования у оружия без материала. null — ещё не парировало.
	var/ce_parry_health

/obj/item/material
	/// Износ от парирования, ещё не снятый со здоровья атома: здоровье целое, а износ дробный.
	var/ce_parry_wear_pending = 0


/**
 * Прочность оружия как слой брони для `ce_try_penetrate()`. Расширением на вещь не ставится —
 * иначе её видели бы кодекс и проход по слоям — и носителя у неё нет: она живёт на попадании
 * (`/datum/ce_shield_hit/parry`), и ссылка на оружие не дала бы ему удалиться. Поэтому `..()` с
 * проверкой носителя не зовётся.
 */
/datum/extension/armor/ce_weapon_toughness
	/// Нематериальное оружие волны в руку не даёт.
	var/nonphysical = FALSE

/datum/extension/armor/ce_weapon_toughness/New(sharp, blunt, nonphysical = FALSE)
	armor_sharp_melee = sharp
	armor_sharp_ballistic = sharp
	armor_blunt = blunt
	src.nonphysical = nonphysical

/// Износ считает само оружие (`ce_apply_parry_wear()`), а не формулы брони.
/datum/extension/armor/ce_weapon_toughness/ce_can_wear()
	return FALSE

/// Острое, пробившее оружие, идёт дальше, в зону. Всё тупое, что прошло оружие, уходит волной в руку.
/datum/extension/armor/ce_weapon_toughness/ce_split_shield_blow(damage, sharp_before, sharp_after)
	if(sharp_after)
		return list(0, damage)
	return list(nonphysical ? 0 : damage * ce_parry_shock_mult, 0)


/**
 * Оружие, встретившее удар, на пути попадания. Как и щит, берётся из слота. Прочность взята в миг
 * парирования, с навыком носителя, а износ посчитан сразу — снимется, если удар дойдёт до урона.
 */
/datum/ce_shield_hit/parry
	var/datum/extension/armor/ce_weapon_toughness/toughness
	var/wear = 0

/datum/ce_shield_hit/parry/New(slot, zone, shock_zones, attack_text, toughness, wear)
	..(slot, zone, shock_zones, attack_text)
	src.toughness = toughness
	src.wear = wear

/datum/ce_shield_hit/parry/ce_get_item(mob/living/carbon/human/holder)
	var/obj/item/weapon = holder.get_equipped_item(slot)
	return istype(weapon) ? weapon : null

/datum/ce_shield_hit/parry/ce_get_armor(obj/item/item)
	return toughness

/datum/ce_shield_hit/parry/ce_resolve(mob/living/carbon/human/holder, obj/item/item, stopped, shock)
	if(!stopped)
		holder.visible_message(SPAN_DANGER("[capitalize(attack_text)] cuts through \the [item]!"))
	var/item_name = item.name
	item.ce_apply_parry_wear(wear, holder)
	if(shock > 0)
		holder.ce_pending_shield_shock = list(shock_zones, shock, item_name)


/**
 * Парирование удалось. Возвращает TRUE, если удар отбит целиком, FALSE — если оружие встречает его
 * первым слоем брони (`ce_register_parry()`). `damage_source` — оружие атакующего, null — безоружная
 * атака.
 */
/obj/item/proc/ce_on_parried(mob/living/user, damage, atom/damage_source, mob/living/attacker, def_zone, attack_text)
	var/crit_chance = ce_get_parry_crit_chance(user, attacker)
	var/clean = prob(crit_chance)
	if(prob(crit_chance))
		ce_riposte(user, attacker, damage_source)
	if(clean)
		return TRUE
	var/wear = ce_get_parry_wear(user, damage, damage_source)
	var/list/attack = ce_get_parry_attack(damage_source)
	var/mob/living/carbon/human/holder = user
	if(istype(holder) && holder.ce_shield_armor_call && ce_uses_kinetic_path(attack[1], attack[2]))
		holder.ce_register_parry(src, def_zone, attack_text, wear)
		return FALSE
	ce_apply_parry_wear(wear, user)
	return TRUE


/// Встречает удар оружием `weapon` первым слоем брони: до конца тика, как щит.
/mob/living/carbon/human/proc/ce_register_parry(obj/item/weapon, def_zone, attack_text, wear)
	var/list/values = weapon.ce_get_parry_toughness(src)
	var/datum/extension/armor/ce_weapon_toughness/toughness = new(values[1], values[2], weapon.ce_armor_nonphysical)
	ce_shield_hit = new /datum/ce_shield_hit/parry(ce_get_shield_slot(weapon), ce_get_block_zone(def_zone), weapon.ce_get_parry_shock_zones(src), attack_text, toughness, wear)


/// Куда уходит тупая волна парирования: в руку, которая держит оружие.
/obj/item/proc/ce_get_parry_shock_zones(mob/living/carbon/human/holder)
	return list(holder.l_hand == src ? BP_L_ARM : BP_R_ARM)

/// Оружие, которое держат двумя руками, делит волну между обеими.
/obj/item/material/twohanded/ce_get_parry_shock_zones(mob/living/carbon/human/holder)
	if(wielded)
		return list(BP_L_ARM, BP_R_ARM)
	return ..()


/// Шанс крита парирования, 0–100: база и разница навыка ближнего боя с атакующим.
/proc/ce_get_parry_crit_chance(mob/living/user, mob/living/attacker)
	var/chance = ce_parry_crit_chance
	if(istype(user) && istype(attacker))
		chance += user.get_skill_difference(SKILL_COMBAT, attacker) * ce_parry_crit_chance_per_skill
	return clamp(chance, 0, 100)


/// Чем бьёт атака: `list(тип урона, флаги, armor_penetration)`. Без оружия — безоружный тупой удар.
/proc/ce_get_parry_attack(atom/damage_source)
	RETURN_TYPE(/list)
	if(!isitem(damage_source))
		return list(DAMAGE_BRUTE, FLAGS_OFF, 0)
	var/obj/item/weapon = damage_source
	return list(weapon.damtype, weapon.damage_flags(), weapon.armor_penetration)


/**
 * Сколько HP снимет с оружия парированный удар силой `damage`, если крит не снимет износ: половина
 * того, что прошло прочность, как в CE. Чистая процедура. Некинетический удар — ожог, энергия —
 * оружие не изнашивает.
 */
/obj/item/proc/ce_get_parry_wear(mob/living/holder, damage, atom/damage_source)
	if(damage <= 0)
		return 0
	var/list/attack = ce_get_parry_attack(damage_source)
	var/damage_flags = attack[2]
	var/armor_pen = attack[3]
	if(!ce_uses_kinetic_path(attack[1], damage_flags))
		return 0

	var/pen = ce_derive_penetration(damage, damage_flags, armor_pen)
	var/blunt_pen = ce_derive_blunt_penetration(damage, damage_flags, armor_pen)
	var/list/toughness = ce_get_parry_toughness(holder)
	var/datum/extension/armor/ce_weapon_toughness/layer = new(toughness[1], toughness[2])
	var/list/step = layer.ce_try_penetrate(damage, damage_flags, pen, damage, pen, blunt_pen)
	var/taken = step[1]
	// Остаточный удар заново проходит прочность по тупой оси: CE так же заново зовёт
	// `ApplyParryDamage()`.
	if(ce_residual_blunt_enabled && ce_is_sharp_attack(step[3]))
		var/list/residual = ce_residual_blunt(step[1], step[2], damage, pen, blunt_pen)
		if(residual)
			var/list/residual_step = layer.ce_try_penetrate(residual[1], FLAGS_OFF, residual[2])
			taken += residual_step[1]
	qdel(layer)
	return taken * ce_parry_damage_mult


/// Прочность оружия в руках `holder`: `list(острая мм RHA, тупая Bay МПа)`.
/obj/item/proc/ce_get_parry_toughness(mob/living/holder)
	RETURN_TYPE(/list)
	var/material/material = ce_get_parry_material()
	var/scale = material.hardness / CE_PARRY_REFERENCE_HARDNESS * ce_get_parry_solid_mult() * ce_get_parry_skill_mult(holder)
	var/size = ce_get_parry_size()
	var/sharp = ce_evaluate_curve(ce_sharp_melee_hard, CE_PARRY_REFERENCE_ARMOR) * sqrt(size) * scale
	var/blunt = ce_parry_blunt_toughness * size * scale
	return list(sharp, blunt)


/// Материал оружия: свой, иначе главный по количеству в `matter`, иначе сталь.
/obj/item/proc/ce_get_parry_material()
	var/material/material = get_material()
	if(material)
		return material
	var/main_name
	var/main_amount = 0
	for(var/material_name in matter)
		if(matter[material_name] > main_amount)
			main_name = material_name
			main_amount = matter[material_name]
	if(main_name)
		material = SSmaterials.get_material_by_name(main_name)
	return material || SSmaterials.get_material_by_name(MATERIAL_STEEL)


/// Размер оружия относительно обычного: место в рюкзаке. Маленький 0.5, большой 2, огромный 4.
/obj/item/proc/ce_get_parry_size()
	var/w = clamp(w_class, ITEM_SIZE_TINY, ITEM_SIZE_GARGANTUAN)
	return BASE_STORAGE_COST(w) / BASE_STORAGE_COST(ITEM_SIZE_NORMAL)


/// Оружие без острия и кромки цельное: множитель прочности по обеим осям.
/obj/item/proc/ce_get_parry_solid_mult()
	return (!sharp && !edge) ? ce_parry_blunt_weapon_mult : 1


/// Множитель прочности от навыка ближнего боя носителя. 1 — у базового уровня Bay, «обученного».
/proc/ce_get_parry_skill_mult(mob/living/holder)
	if(!istype(holder))
		return 1
	return max(0, 1 + (holder.get_skill_value(SKILL_COMBAT) - SKILL_BASELINE) * ce_parry_toughness_per_skill)


/// HP износа от парирования у оружия без материала: как у материального оружия Bay из того же материала.
/obj/item/proc/ce_get_parry_health_max()
	var/material/material = ce_get_parry_material()
	return max(1, round(material.integrity / CE_PARRY_INTEGRITY_PER_HEALTH))


/**
 * Изнашивает ли парирование это оружие. Флаг Bay `unbreakable` здесь не смотрится: в Bay он стоит
 * на всех ножах, чтобы те не раскалывались о броню, и на оружии роботов, а роботы не парируют вовсе.
 * Раскалывание о броню (`check_shatter()`) он по-прежнему отключает.
 */
/obj/item/proc/ce_can_parry_wear()
	return !ce_armor_nonphysical && !ce_parry_unbreakable


/// Сколько процентов HP оружие потеряло от износа, 0–100.
/obj/item/proc/ce_get_parry_damage_percent()
	if(isnull(ce_parry_health))
		return 0
	return round(100 * (1 - ce_parry_health / ce_get_parry_health_max()), 1)

/obj/item/material/ce_get_parry_damage_percent()
	return get_damage_percentage()


/// Снимает с оружия `amount` HP износа от парирования. На нуле оружие ломается.
/obj/item/proc/ce_apply_parry_wear(amount, mob/living/holder)
	if(amount <= 0 || !ce_can_parry_wear())
		return
	var/old_percent = ce_get_parry_damage_percent()
	if(isnull(ce_parry_health))
		ce_parry_health = ce_get_parry_health_max()
	ce_parry_health -= amount
	if(ce_parry_health <= 0)
		ce_break_from_parry()
		return
	ce_report_parry_wear(holder, old_percent)

/obj/item/material/ce_apply_parry_wear(amount, mob/living/holder)
	if(amount <= 0 || !ce_can_parry_wear())
		return
	// Хрупкое раскалывается от любого износа — как от `check_shatter()` в Bay.
	if(material.is_brittle())
		kill_health()
		return
	ce_parry_wear_pending += amount
	var/whole = floor(ce_parry_wear_pending)
	if(whole < 1)
		return
	ce_parry_wear_pending -= whole
	var/old_percent = ce_get_parry_damage_percent()
	if(damage_health(whole, DAMAGE_BRUTE) || QDELETED(src))
		return
	ce_report_parry_wear(holder, old_percent)


/// Ступень износа по проценту потерянных HP: 0 — цело, 1–3 — «slightly», «moderately» и «severely» осмотра Bay.
/proc/ce_get_parry_wear_state(damage_percent)
	if(damage_percent <= 0)
		return 0
	if(damage_percent < 33)
		return 1
	if(damage_percent < 66)
		return 2
	return 3


/// Сообщает носителю, что оружие перешло на ступень износа хуже.
/obj/item/proc/ce_report_parry_wear(mob/living/holder, old_percent)
	var/state = ce_get_parry_wear_state(ce_get_parry_damage_percent())
	if(!holder || state <= ce_get_parry_wear_state(old_percent))
		return
	var/static/list/messages = list(
		"takes a nick from the blow.",
		"is getting worn down by the blows.",
		"is badly damaged and won't take much more!"
	)
	to_chat(holder, SPAN_WARNING("\The [src] [messages[state]]"))


/**
 * Строка осмотра об износе оружия без материала, null — цело. У материального оружия износ сидит в
 * здоровье атома, и строку пишет сам Bay — теми же словами.
 */
/obj/item/proc/ce_get_parry_examine_line()
	if(isnull(ce_parry_health) || get_max_health())
		return null
	var/state = ce_get_parry_wear_state(ce_get_parry_damage_percent())
	if(!state)
		return null
	var/datum/pronouns/pronouns = choose_from_pronouns()
	var/static/list/degrees = list("slightly", "moderately", "severely")
	var/line = "[pronouns.He] look[pronouns.s] [degrees[state]] damaged."
	return state == 3 ? SPAN_DANGER(line) : SPAN_WARNING(line)


/// Оружие без материала сломалось от парирования.
/obj/item/proc/ce_break_from_parry()
	var/material/material = ce_get_parry_material()
	visible_message(SPAN_DANGER("\The [src] [material.destruction_desc]!"))
	playsound(src, "shatter", 70, TRUE)
	qdel(src)

/// Содержимое сломанного ящика или кейса не пропадает, а высыпается.
/obj/item/storage/ce_break_from_parry()
	var/turf/drop_turf = get_turf(src)
	for(var/obj/item/content in contents)
		remove_from_storage(content, drop_turf, TRUE)
	return ..()


/**
 * Ответный удар оружием по атакующему: силой оружия, его типом урона и пробитием, через броню.
 * Безоружную атаку ответ бьёт в руку, которой атаковали, атаку оружием — в зону, которую выбрал
 * парирующий. Возвращает TRUE, если удар нанесён.
 */
/obj/item/proc/ce_riposte(mob/living/user, mob/living/attacker, atom/damage_source)
	if(!istype(user) || !istype(attacker) || attacker == user || attacker.stat == DEAD)
		return FALSE
	if(force < 1 || !user.Adjacent(attacker))
		return FALSE
	var/armed = isitem(damage_source)
	var/zone = armed ? ce_get_riposte_zone(user) : ce_get_attacking_hand_zone(attacker)
	user.do_attack_animation(attacker)
	if(hitsound)
		playsound(attacker, hitsound, 50, TRUE)
	if(armed)
		attacker.visible_message(SPAN_DANGER("\The [user] ripostes, striking \the [attacker] with \the [src]!"))
	else
		var/datum/pronouns/pronouns = attacker.choose_from_pronouns()
		attacker.visible_message(SPAN_DANGER("\The [attacker] hurts [pronouns.his] hand on \the [src]!"))
	admin_attack_log(user, attacker, "Riposted with \a [src]", "Was hit by a riposte with \a [src]", "riposted with \a [src] at")
	attacker.apply_damage(force, damtype, zone, damage_flags(), src, armor_penetration)
	return TRUE


/// Зона ответного удара по атаке оружием: выбранная парирующим, глаза и рот — голова.
/proc/ce_get_riposte_zone(mob/living/user)
	var/zone = user.zone_sel?.selecting
	return zone ? check_zone(zone) : BP_CHEST


/// Кисть, которой `attacker` атаковал без оружия: активная. null — не человек.
/proc/ce_get_attacking_hand_zone(mob/living/attacker)
	if(!ishuman(attacker))
		return null
	return attacker.hand ? BP_L_HAND : BP_R_HAND
