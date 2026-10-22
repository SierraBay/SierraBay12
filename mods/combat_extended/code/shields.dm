/*
	COMBAT_EXTENDED — щиты через проход по слоям (§10 спеки, с отступлениями).

	В Bay щит блокирует броском `prob(base_block_chance)` откуда угодно, кроме спины, и блок отменяет
	попадание целиком: ни урона, ни боли, ни удара в руку. Своей брони у щита нет.

	Здесь щит — внешний слой брони на тех зонах, которые он закрывает:
	- щит в руке закрывает зоны своей стойки от атак из дуги `ce_shield_arc_degrees` вокруг взгляда.
	  Щит на спине — грудь и пах от атак из такой же дуги вокруг спины. Дуга Bay — всё, кроме спины
	  и задних диагоналей — с двумя щитами закрывала носителя со всех сторон;
	- попадание в закрытую зону проходит щит как обычный слой. Острое, пробившее щит, идёт дальше, в
	  броню зоны попадания;
	- острое, которое щит остановил, становится тупым и бьёт по тупой броне щита — пуля с множителем
	  импульса `ce_shield_bullet_impact_mult`. Дошедший тупой урон уходит не в зону попадания, а в
	  руку со щитом (у щита на спине — в грудь), мимо её брони: латная перчатка держать щит не
	  помогает. Нематериальный щит (`ce_armor_nonphysical`, энергощит) волны не даёт вовсе;
	- стойки меняются использованием щита в руке. «Целиться» открывает голову и руку с оружием.
	  «Укрыться» закрывает больше, но стрелять из неё может только мастер, и выстрел раскрывает
	  голову и руку с оружием на `ce_shield_cover_fire_exposure`. Удар в ближнем бою из неё
	  раскрывает руку с оружием на время перезарядки удара. В ней щит с `ce_cover_sprite_moves`
	  рисуется поднятым и закрывающим тело (`ce_get_hand_overlay()`). У щита без
	  `ce_stance_switchable` стойка одна — «целиться»;
	- лёжа и без сознания щит не закрывает ничего.

	Рукопашка идёт тем же путём, что и пули: в CE её ведёт парирование (§12), здесь щит встречает её
	слоем, а парирует только оружие (`weapon_parry.dm`).
	Проверки без урона — обезоруживание, захват, прыжок паука, укол шприцем — щит блокирует целиком,
	если закрывает зону.

	Щит на пути попадания `check_shields()` запоминает в `ce_shield_hit` на один тик, проход по
	слоям читает его через `get_armors_by_zone()`, а боевой проход (`modify_damage_by_armor()`)
	забирает. Консультационные проходы — доля блока, доля урона для боли — щит видят, но не забирают.
*/

/// Запас на границе дуги: `arctan()` для соседней диагонали даёт 45 с погрешностью.
#define CE_SHIELD_ARC_EPSILON 0.01

/obj/item/shield
	/// Зоны, которые щит в руке закрывает в стойке «укрыться». `CE_SHIELD_*` и `CE_WEAPON_*` —
	/// рука и кисть по той руке, в которой щит.
	var/list/ce_cover_zones = list(BP_HEAD, BP_CHEST, BP_GROIN, CE_SHIELD_ARM, CE_SHIELD_HAND, CE_WEAPON_ARM, CE_WEAPON_HAND)
	/// Зоны в стойке «целиться»: голова и рука с оружием открыты.
	var/list/ce_aim_zones = list(BP_CHEST, BP_GROIN, CE_SHIELD_ARM, CE_SHIELD_HAND)
	/// Зоны щита на спине, от атак сзади.
	var/list/ce_back_zones = list(BP_CHEST, BP_GROIN)
	/// Стойка щита в руке, `CE_SHIELD_STANCE_*`.
	var/ce_stance = CE_SHIELD_STANCE_AIM
	/// Можно ли менять стойку. Нельзя — щит всегда в стойке «целиться» и закрывает её зоны.
	var/ce_stance_switchable = TRUE
	/// Рисуется ли щит в руке в стойке «укрыться» поднятым и закрывающим тело.
	var/ce_cover_sprite_moves = FALSE
	/// Отражать ли спрайт в правой руке лицом на запад: у части щитов Bay он нарисован задом наперёд.
	var/ce_flip_right_west_sprite = FALSE
	/// Можно ли повесить на щит аксессуар.
	var/ce_accessory_slot = FALSE
	/// Аксессуар на щите.
	var/obj/item/ce_shield_accessory/ce_accessory


/mob/living/carbon/human
	/// Щит на пути текущего попадания, null — щита нет.
	var/datum/ce_shield_hit/ce_shield_hit
	/// Идёт ли вызов, урон которого дальше пройдёт броню. Тогда `check_shields()` отдаёт щит проходу
	/// по слоям, а не блокирует сама.
	var/ce_shield_armor_call = FALSE
	/// До какого `world.time` выстрел из-за щита держит открытыми голову и руку с оружием.
	var/ce_shield_fire_exposed_until = 0
	/// До какого `world.time` удар из-за щита держит открытой руку с оружием.
	var/ce_shield_melee_exposed_until = 0
	/// Отложенная тупая волна от щита или парирования: `list(теги органов, урон на всех, чем
	/// встречен удар)`. Живёт внутри одного `apply_damage()`.
	var/list/ce_pending_shield_shock


/**
 * Щит на пути попадания. Ссылку на щит не держит: попадание, которое так и не дошло до урона,
 * оставило бы его здесь до следующего, а удалённый щит — неудаляемым. Щит берётся из слота.
 * Парирование встречает удар так же, подтипом `/datum/ce_shield_hit/parry` (`weapon_parry.dm`).
 */
/datum/ce_shield_hit
	/// Слот щита, `slot_*`.
	var/slot
	/// Зона попадания, тег органа.
	var/zone
	/// Зоны тупой волны, теги органов. Волна делится между ними поровну.
	var/list/shock_zones
	/// Чем били — для сообщения о блоке.
	var/attack_text
	/// Тик, в котором щит встретил атаку.
	var/time

/datum/ce_shield_hit/New(slot, zone, shock_zones, attack_text)
	..()
	src.slot = slot
	src.zone = zone
	src.shock_zones = islist(shock_zones) ? shock_zones : list(shock_zones)
	src.attack_text = attack_text
	time = world.time


/// Вещь, встретившая удар, из слота `slot` у `holder`. null — её там уже нет.
/datum/ce_shield_hit/proc/ce_get_item(mob/living/carbon/human/holder)
	var/obj/item/shield/shield = holder.get_equipped_item(slot)
	return istype(shield) ? shield : null


/// Слой брони, которым вещь `item` встречает удар: броня самого щита.
/datum/ce_shield_hit/proc/ce_get_armor(obj/item/item)
	return get_extension(item, /datum/extension/armor)


/// Итог боевого прохода для щита: сообщение о блоке и тупая волна в руку.
/datum/ce_shield_hit/proc/ce_resolve(mob/living/carbon/human/holder, obj/item/item, stopped, shock)
	var/obj/item/shield/shield = item
	if(stopped)
		shield.ce_announce_block(holder, attack_text)
	if(shock > 0)
		holder.ce_pending_shield_shock = list(shock_zones, shock, item.name)


// ============================================================================================
// Что щит закрывает
// ============================================================================================

/// Может ли щит прикрыть носителя сейчас.
/obj/item/shield/proc/ce_can_cover(mob/living/carbon/human/holder)
	return !holder.lying && !holder.incapacitated()

/obj/item/shield/energy/ce_can_cover(mob/living/carbon/human/holder)
	return active && ..()


/// Теги органов, которые щит закрывает у носителя сейчас.
/obj/item/shield/proc/ce_get_covered_zones(mob/living/carbon/human/holder)
	if(holder.back == src)
		return ce_back_zones.Copy()
	if(holder.l_hand != src && holder.r_hand != src)
		return list()
	var/shield_left = holder.l_hand == src
	. = list()
	for(var/zone in ce_get_stance_zones(holder))
		. |= ce_resolve_side_zone(zone, shield_left)


/// Стоит ли щит в стойке «укрыться». Щит без смены стоек всегда в «целиться».
/obj/item/shield/proc/ce_in_cover()
	return ce_stance_switchable && ce_stance == CE_SHIELD_STANCE_COVER


/// Зоны стойки с учётом того, что выстрел или удар из-за щита сейчас раскрыл.
/obj/item/shield/proc/ce_get_stance_zones(mob/living/carbon/human/holder)
	if(!ce_in_cover() || world.time < holder.ce_shield_fire_exposed_until)
		return ce_aim_zones
	if(world.time < holder.ce_shield_melee_exposed_until)
		return ce_cover_zones - list(CE_WEAPON_ARM, CE_WEAPON_HAND)
	return ce_cover_zones


/// Тег органа для зоны щита: `CE_SHIELD_*` и `CE_WEAPON_*` — по руке со щитом.
/proc/ce_resolve_side_zone(zone, shield_left)
	switch(zone)
		if(CE_SHIELD_ARM)
			return shield_left ? BP_L_ARM : BP_R_ARM
		if(CE_SHIELD_HAND)
			return shield_left ? BP_L_HAND : BP_R_HAND
		if(CE_WEAPON_ARM)
			return shield_left ? BP_R_ARM : BP_L_ARM
		if(CE_WEAPON_HAND)
			return shield_left ? BP_R_HAND : BP_L_HAND
	return zone


/// Куда уходит тупая волна от этого щита: в руку со щитом, а у щита на спине — в грудь.
/obj/item/shield/proc/ce_get_shock_zone(mob/living/carbon/human/holder)
	if(holder.back == src)
		return BP_CHEST
	return holder.l_hand == src ? BP_L_ARM : BP_R_ARM


/**
 * Идёт ли атака с той стороны, которую щит закрывает: из дуги `ce_shield_arc_degrees` вокруг
 * взгляда носителя, а у щита на спине — вокруг его спины. Граница дуги включается: при 90 соседняя
 * клетка по диагонали спереди ещё закрыта. Атаку со своей клетки или без источника встречает
 * только щит в руке, как в `check_shield_arc()` Bay.
 */
/obj/item/shield/proc/ce_faces_attack(mob/living/carbon/human/holder, atom/damage_source, mob/attacker)
	var/on_back = holder.back == src
	var/turf/holder_turf = get_turf(holder)
	var/turf/origin = ce_get_attack_origin(damage_source, attacker)
	if(!origin || origin == holder_turf)
		return !on_back
	return ce_is_in_arc(holder_turf, origin, dir2angle(holder.dir) + (on_back ? 180 : 0), ce_shield_arc_degrees)


/**
 * Лежит ли клетка `target` в дуге шириной `arc_degrees` вокруг направления `facing_angle` от клетки
 * `origin`. Углы — в градусах от севера по часовой, как у `dir2angle()`. Граница дуги включается.
 */
/proc/ce_is_in_arc(turf/origin, turf/target, facing_angle, arc_degrees)
	while(facing_angle >= 360)
		facing_angle -= 360
	var/offset = abs(Get_Angle(origin, target) - facing_angle)
	if(offset > 180)
		offset = 360 - offset
	return offset <= arc_degrees / 2 + CE_SHIELD_ARC_EPSILON


/// Клетка, откуда пришла атака: у снаряда — клетка выстрела, иначе — атакующий или сам источник.
/proc/ce_get_attack_origin(atom/damage_source, mob/attacker)
	var/obj/item/projectile/projectile = damage_source
	if(istype(projectile))
		return projectile.starting
	if(attacker)
		return get_turf(attacker)
	if(damage_source)
		return get_turf(damage_source)
	return null


/// Щит, который встаёт на пути атаки в зону `zone`, или null. Руки проверяются раньше спины.
/mob/living/carbon/human/proc/ce_find_blocking_shield(zone, atom/damage_source, mob/attacker)
	for(var/obj/item/shield/shield in list(l_hand, r_hand, back))
		if(!shield.ce_can_cover(src))
			continue
		if(!(zone in shield.ce_get_covered_zones(src)))
			continue
		if(!shield.ce_faces_attack(src, damage_source, attacker))
			continue
		return shield
	return null


/// Слот, в котором человек держит или носит щит либо парирующее оружие, или null.
/mob/living/carbon/human/proc/ce_get_shield_slot(obj/item/item)
	if(l_hand == item)
		return slot_l_hand
	if(r_hand == item)
		return slot_r_hand
	if(back == item)
		return slot_back
	return null


/// Тег органа, в который щит или оружие встречает удар. Шприц и имплантёр передают вместо зоны
/// текст атаки — такая зона считается грудью.
/proc/ce_get_block_zone(def_zone)
	var/zone = check_zone(def_zone)
	return (zone in BP_ALL_LIMBS) ? zone : BP_CHEST


// ============================================================================================
// Встреча атаки со щитом
// ============================================================================================

/**
 * Встречает атаку щитом, из `check_shields()`. Возвращает то же, что она: 1 — атака заблокирована,
 * 0 — нет. Если щит закрывает зону, атака, урон которой дальше пройдёт броню, получает щит слоем
 * брони, а проверка без урона блокируется сразу.
 */
/mob/living/carbon/human/proc/ce_meet_shield(atom/damage_source, mob/attacker, def_zone, attack_text)
	ce_shield_hit = null
	var/zone = ce_get_block_zone(def_zone)
	var/obj/item/shield/shield = ce_find_blocking_shield(zone, damage_source, attacker)
	if(!shield)
		return 0
	if(!ce_shield_armor_call)
		shield.ce_announce_block(src, attack_text)
		return 1
	ce_shield_hit = new(ce_get_shield_slot(shield), zone, shield.ce_get_shock_zone(src), attack_text)
	return 0


/// Щит или парирующее оружие текущего попадания в зону `def_zone`, null — на пути ничего нет.
/mob/living/proc/ce_get_hit_shield(def_zone)
	return null

/mob/living/carbon/human/ce_get_hit_shield(def_zone)
	var/datum/ce_shield_hit/hit = ce_shield_hit
	if(!hit || hit.time != world.time)
		return null
	var/obj/item/organ/external/organ = ce_resolve_organ(def_zone)
	if(!organ || organ.organ_tag != hit.zone)
		return null
	return hit.ce_get_item(src)


/// Слой брони щита или парирующего оружия текущего попадания в зону `def_zone`, null — на пути ничего нет.
/mob/living/proc/ce_get_shield_armor(def_zone)
	return null

/mob/living/carbon/human/ce_get_shield_armor(def_zone)
	var/obj/item/item = ce_get_hit_shield(def_zone)
	return item ? ce_shield_hit.ce_get_armor(item) : null


/**
 * Итог боевого прохода для щита или парирования. Попадание на этом забирается — остаточный удар и
 * всё, что породит само попадание, его уже не встретят.
 */
/mob/living/proc/ce_resolve_shield_hit(def_zone, stopped, shock)
	return

/mob/living/carbon/human/ce_resolve_shield_hit(def_zone, stopped, shock)
	var/obj/item/item = ce_get_hit_shield(def_zone)
	if(!item)
		return
	var/datum/ce_shield_hit/hit = ce_shield_hit
	ce_shield_hit = null
	hit.ce_resolve(src, item, stopped, shock)


/**
 * Что прошло слой щита, щит делит так: `list(тупая волна в руку, урон дальше, в броню зоны)`.
 * Острое, которое щит остановил, уходит волной, остальное идёт дальше. Нематериальный щит волны не
 * даёт. Парирующее оружие делит по-своему (`weapon_parry.dm`).
 */
/datum/extension/armor/proc/ce_split_shield_blow(damage, sharp_before, sharp_after)
	if(!sharp_before || sharp_after)
		return list(0, damage)
	var/obj/item/shield = holder
	return list(shield.ce_armor_nonphysical ? 0 : damage, 0)


/**
 * Остановил ли щит атаку некинетического ключа: граница процентного пути «урон не превысил брони
 * слоя», как в `ce_get_percent_pass_share()`. Остальные слои тут ни при чём.
 */
/datum/extension/armor/proc/ce_percent_stops(damage, damage_type, damage_flags, armor_pen)
	if(!ce_can_stop(damage_type, damage_flags))
		return FALSE
	return ce_is_under_armor(get_blocked(damage_type, damage_flags, armor_pen, damage))


/**
 * Тупая волна от щита или парирующего оружия — мимо брони: её несёт сама вещь, а не удар по зоне.
 * `damage` делится поровну между органами `organ_tags`. `source_name` — чем встречен удар.
 */
/mob/living/carbon/human/proc/ce_apply_shield_shock(list/organ_tags, damage, source_name)
	var/share = damage / length(organ_tags)
	for(var/organ_tag in organ_tags)
		var/obj/item/organ/external/organ = get_organ(organ_tag)
		if(!organ)
			continue
		to_chat(src, SPAN_WARNING("The impact on your [source_name] jars your [organ.name]!"))
		organ.take_external_damage(share, 0, FLAGS_OFF)
	updatehealth()


/obj/item/shield/proc/ce_announce_block(mob/living/carbon/human/holder, attack_text)
	holder.visible_message(SPAN_DANGER("\The [holder] blocks [attack_text] with \the [src]!"))
	ce_play_block_effects(holder)

/obj/item/shield/proc/ce_play_block_effects(mob/living/carbon/human/holder)
	playsound(holder.loc, 'sound/weapons/Genhit.ogg', 50, 1)

/obj/item/shield/energy/ce_play_block_effects(mob/living/carbon/human/holder)
	sparks.set_up(2, loca = holder)
	sparks.start()


// ============================================================================================
// Стойки
// ============================================================================================

/obj/item/shield/proc/ce_toggle_stance(mob/living/user)
	if(!ce_stance_switchable)
		to_chat(user, SPAN_WARNING("\The [src] is too small to take cover behind."))
		return
	if(ce_stance == CE_SHIELD_STANCE_COVER)
		ce_stance = CE_SHIELD_STANCE_AIM
		user.visible_message(
			SPAN_NOTICE("\The [user] lowers \the [src], ready to take aim."),
			SPAN_NOTICE("You lower \the [src], ready to take aim.")
		)
	else
		ce_stance = CE_SHIELD_STANCE_COVER
		user.visible_message(
			SPAN_NOTICE("\The [user] hides behind \the [src]."),
			SPAN_NOTICE("You hide behind \the [src].")
		)
	user.update_inv_l_hand()
	user.update_inv_r_hand()


// ============================================================================================
// Спрайт в руке
// ============================================================================================

/// Кеш спрайтов щитов в руке: ключ — спрайт, состояние, что с ним сделано, и ручки сдвига.
GLOBAL_LIST_EMPTY(ce_shield_hand_icons)

/// Рисуется ли щит в руке сейчас поднятым: стойка «укрыться» у щита с `ce_cover_sprite_moves`.
/obj/item/shield/proc/ce_is_raised()
	return ce_shields_enabled && ce_cover_sprite_moves && ce_in_cover()

/obj/item/shield/energy/ce_is_raised()
	return active && ..()


/**
 * Спрайт щита в руке. В стойке «укрыться» у щита с `ce_cover_sprite_moves` он сдвинут так, чтобы
 * щит закрывал тело и всем было видно, что носитель укрылся. У щита с `ce_flip_right_west_sprite`
 * спрайт в правой руке лицом на запад отражён в любой стойке: это ошибка спрайта Bay, а не стойка.
 * `standing` не меняется.
 */
/obj/item/shield/proc/ce_get_hand_overlay(image/standing, right_hand)
	if(!standing)
		return standing
	var/flip_west = right_hand && ce_flip_right_west_sprite
	var/raise = ce_is_raised()
	if(!flip_west && !raise)
		return standing
	var/icon_key = istype(standing.icon, /icon) ? "\ref[standing.icon]" : "[standing.icon]"
	var/raise_key = raise ? "[ce_shield_cover_sprite_rise]|[ce_shield_cover_sprite_forward]|[ce_shield_cover_sprite_pull]" : "lowered"
	var/key = "[icon_key]|[standing.icon_state]|[flip_west]|[raise_key]"
	var/icon/hand_icon = GLOB.ce_shield_hand_icons[key]
	if(!hand_icon)
		hand_icon = ce_build_hand_icon(standing.icon, standing.icon_state, flip_west, raise)
		GLOB.ce_shield_hand_icons[key] = hand_icon
	var/image/hand_image = new
	hand_image.appearance = standing
	hand_image.icon = hand_icon
	hand_image.icon_state = null
	return hand_image


/// Спрайт в руке по направлениям: с отражённым западом и с подъёмом `ce_shift_cover_sprite()`.
/proc/ce_build_hand_icon(icon_file, icon_state, flip_west, raise)
	var/icon/result = new('icons/mob/human_races/species/template.dmi')
	for(var/facing in GLOB.cardinal)
		var/icon/sprite = new(icon_file, icon_state, facing)
		if(flip_west && facing == WEST)
			sprite.Flip(EAST)
		if(raise)
			ce_shift_cover_sprite(sprite, facing)
		result.Insert(sprite, dir = facing)
	return result


/**
 * Сдвиг спрайта в стойке «укрыться». Анфас середина щита едет к середине тела, в профиль — к точке
 * на `ce_shield_cover_sprite_forward` впереди неё, но проходит лишь долю пути
 * `ce_shield_cover_sprite_pull`. Щит поднимается на `ce_shield_cover_sprite_rise`.
 * Спиной к зрителю щит не трогается: слой рук рисуется поверх тела, и сдвинутый щит читался бы
 * как щит на спине. Середина тела — середина клетки.
 */
/proc/ce_shift_cover_sprite(icon/sprite, facing)
	if(facing == NORTH)
		return
	var/center = ce_get_sprite_center_x(sprite)
	if(isnull(center))
		return
	var/target = sprite.Width() / 2
	if(facing == EAST)
		target += ce_shield_cover_sprite_forward
	else if(facing == WEST)
		target -= ce_shield_cover_sprite_forward
	var/shift = round((target - center) * ce_shield_cover_sprite_pull, 1)
	if(shift)
		sprite.Shift(shift > 0 ? EAST : WEST, abs(shift))
	sprite.Shift(NORTH, ce_shield_cover_sprite_rise)


/// Середина непрозрачной части спрайта по горизонтали, px от левого края. null — спрайт пуст.
/proc/ce_get_sprite_center_x(icon/sprite)
	var/left
	var/right
	for(var/x in 1 to sprite.Width())
		for(var/y in 1 to sprite.Height())
			if(sprite.GetPixel(x, y))
				if(isnull(left))
					left = x
				right = x
				break
	if(isnull(left))
		return null
	return (left + right) / 2


/// Строки осмотра щита: состояние брони, как у одежды (`_master_files/.../_clothing.dm`), аксессуар и стойка.
/obj/item/shield/proc/ce_get_examine_lines()
	RETURN_TYPE(/list)
	. = list()
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	for(var/line in armor?.ce_get_condition_lines())
		. += SPAN_WARNING(line)
	if(ce_accessory)
		. += SPAN_NOTICE("\A [ce_accessory] is mounted on it.")
		. += ce_accessory.get_shield_examine_lines(src)
	if(!ce_shields_enabled || !ce_stance_switchable)
		return
	if(ce_in_cover())
		. += SPAN_NOTICE("It's held up to take cover behind.")
	else
		. += SPAN_NOTICE("It's held low, leaving room to take aim.")
	. += SPAN_NOTICE("Use it in hand to switch between taking cover and taking aim.")

/obj/item/shield/energy/ce_get_examine_lines()
	. = ..()
	if(ce_shields_enabled)
		. += SPAN_NOTICE("Alt-click it in hand to switch it off.")


/// Щит в руке в стойке «укрыться», который прикрывает сейчас, либо null.
/mob/living/carbon/human/proc/ce_get_cover_shield()
	for(var/obj/item/shield/shield in list(l_hand, r_hand))
		if(shield.ce_in_cover() && shield.ce_can_cover(src))
			return shield
	return null


/// Мешает ли щит выстрелить. Из стойки «укрыться» стреляет только мастер.
/mob/living/carbon/human/proc/ce_shield_blocks_firing()
	if(!ce_shields_enabled)
		return FALSE
	var/obj/item/shield/shield = ce_get_cover_shield()
	if(!shield || skill_check(SKILL_WEAPONS, ce_shield_cover_fire_skill))
		return FALSE
	to_chat(src, SPAN_WARNING("Firing from behind \the [shield] seems pointless."))
	return TRUE


/// Выстрел из стойки «укрыться» раскрывает голову и руку с оружием.
/mob/living/carbon/human/proc/ce_note_shot()
	if(ce_shields_enabled && ce_get_cover_shield())
		ce_shield_fire_exposed_until = world.time + ce_shield_cover_fire_exposure


/// Удар из стойки «укрыться» раскрывает руку с оружием на время перезарядки удара.
/mob/living/carbon/human/proc/ce_note_melee_attack(cooldown)
	if(ce_shields_enabled && ce_get_cover_shield())
		ce_shield_melee_exposed_until = world.time + cooldown


// ============================================================================================
// Аксессуар
// ============================================================================================

/**
 * Аксессуар щита. Вешается на щит с `ce_accessory_slot`, снимается отвёрткой и работает от кнопки
 * действия щита, а подтип может разобрать и альт-клик по щиту в руке. Первый — прожектор
 * (`code/items/accessories/shield_projector.dm`).
 */
/obj/item/ce_shield_accessory
	abstract_type = /obj/item/ce_shield_accessory
	w_class = ITEM_SIZE_SMALL
	/// Надпись на кнопке действия щита с этим аксессуаром.
	var/action_name = "Use Shield Accessory"

/// Кнопка действия щита с этим аксессуаром.
/obj/item/ce_shield_accessory/proc/activate(mob/living/user, obj/item/shield/shield)
	return

/// Альт-клик по щиту в руке с этим аксессуаром. TRUE — клик разобран, FALSE — пусть идёт дальше.
/obj/item/ce_shield_accessory/proc/alt_activate(mob/living/user, obj/item/shield/shield)
	return FALSE

/// Аксессуар только что повешен на щит.
/obj/item/ce_shield_accessory/proc/on_attached(obj/item/shield/shield, mob/living/user)
	return

/// Аксессуар снимают со щита: он ещё на нём.
/obj/item/ce_shield_accessory/proc/on_removed(obj/item/shield/shield, mob/living/user)
	return

/// Строки осмотра щита с этим аксессуаром.
/obj/item/ce_shield_accessory/proc/get_shield_examine_lines(obj/item/shield/shield)
	RETURN_TYPE(/list)
	return list()


/obj/item/shield/proc/ce_attach_accessory(obj/item/ce_shield_accessory/accessory, mob/living/user)
	if(!ce_accessory_slot)
		to_chat(user, SPAN_WARNING("\The [accessory] doesn't fit on \the [src]."))
		return FALSE
	if(ce_accessory)
		to_chat(user, SPAN_WARNING("\The [src] already has \a [ce_accessory] mounted."))
		return FALSE
	if(!user.unEquip(accessory, src))
		return FALSE
	ce_accessory = accessory
	action_button_name = accessory.action_name
	accessory.on_attached(src, user)
	user.visible_message(
		SPAN_NOTICE("\The [user] mounts \a [accessory] on \the [src]."),
		SPAN_NOTICE("You mount \the [accessory] on \the [src].")
	)
	return TRUE


/obj/item/shield/proc/ce_remove_accessory(mob/living/user)
	if(!ce_accessory)
		return FALSE
	var/obj/item/ce_shield_accessory/accessory = ce_accessory
	accessory.on_removed(src, user)
	ce_accessory = null
	action_button_name = null
	QDEL_NULL(action)
	user.put_in_hands(accessory)
	user.visible_message(
		SPAN_NOTICE("\The [user] unmounts \the [accessory] from \the [src]."),
		SPAN_NOTICE("You unmount \the [accessory] from \the [src].")
	)
	return TRUE

#undef CE_SHIELD_ARC_EPSILON
