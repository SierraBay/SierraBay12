/*
	COMBAT_EXTENDED — точные рейтинги брони в кодексе.

	Кодекс описывает броню словами («It offers a moderate defense against ballistics»), и слова
	эти выбираются по ключам 0–100, то есть по ВХОДУ вывода, а не по его результату: riot-жилет и
	бронежилет оба получают «very strong against blunt force», хотя против пуль у них 3.0 мм и
	20.0 мм. Поэтому рядом со словами показываются те самые числа, по которым считается бой.

	Значения берутся с живого расширения, а не из списка `armor` на типе, поэтому изношенная
	или раскалённая броня показывает свои текущие, просевшие числа. Кодекс генерирует такие записи
	заново на каждый просмотр и не кеширует их, так что устаревших чисел здесь не будет.

	Жёсткая броня на одежде держит луч вычитанием (`laser_heat.dm`), и её блок печатает ещё и
	это: сколько урона луча она держит и сколько жара вмещает. Лучевое оружие печатает свой луч.
*/

/**
 * Блоки кодекса с точными рейтингами брони. У зональной брони — блок на каждую группу зон, со
 * своим износом, даже если группа изношена в ноль.
 */
/datum/extension/armor/proc/ce_get_codex_line(label = "Armor ratings")
	var/list/groups = ce_get_zone_groups()
	if(!length(groups))
		return ce_get_ratings_block(label)

	var/info
	for(var/group in groups)
		var/outer_body_part = ce_set_hit_body_part(ce_armor_zone_groups[group])
		info = ce_codex_join(info, ce_get_ratings_block("[label] ([group])", TRUE))
		ce_set_hit_body_part(outer_body_part)
	return info


/**
 * Блок кодекса с рейтингами по трём осям CE и, у брони, которая держит луч вычитанием, — строками о
 * луче. null — предмет не защищает ни по кинетическим осям, ни от луча, а `show_empty` не задан.
 * Зональная броня читается по контексту `GLOB.ce_hit_body_part`.
 */
/datum/extension/armor/proc/ce_get_ratings_block(label, show_empty = FALSE)
	var/ballistic = get_armor_sharp_ballistic()
	var/blade = get_armor_sharp_melee()
	var/blunt = get_armor_blunt()
	var/list/laser_lines = ce_get_laser_codex_lines()

	if(!show_empty && ballistic <= 0 && blade <= 0 && blunt <= 0 && !length(laser_lines))
		return null

	var/list/lines = list(
		"<b>[label]:</b>",
		"[round(ballistic, 0.1)] mm RHA vs. ballistics",
		"[round(blade, 0.1)] mm RHA vs. blades",
		"[round(blunt / CE_BLUNT_DISPLAY_DIVISOR, 0.1)] MPa vs. impacts"
	)
	lines += laser_lines

	return jointext(lines, "<br>")


/**
 * Блок кодекса с пробитием АТАКИ — зеркало блока брони. Без него «26.0 MPa vs. impacts» читается
 * как порог, который якобы гасит любой удар слабее, а на деле это вычитается из ПРОБИТИЯ атаки.
 *
 * Для острых атак печатаются ОБА числа: острое пробитие и тот импульс, который прилетит, если
 * острую часть остановят. `damage` — урон снаряда либо `force` оружия. `blunt_pen` — собственное
 * тупое пробитие снаряда, Bay МПа; null — выводится из урона.
 */
/proc/ce_attack_codex_line(damage, damage_flags, armor_pen = 0, label = "Penetration", list/extra_lines, blunt_pen)
	if(damage <= 0)
		return null

	var/list/lines = list("<b>[label]:</b>")
	if(ce_is_sharp_attack(damage_flags))
		lines += "[round(ce_derive_penetration(damage, damage_flags, armor_pen), 0.1)] mm RHA"

	if(isnull(blunt_pen))
		blunt_pen = ce_derive_blunt_penetration(damage, damage_flags, armor_pen)
	lines += "[round(blunt_pen / CE_BLUNT_DISPLAY_DIVISOR, 0.1)] MPa impact"

	if(extra_lines)
		lines += extra_lines

	return jointext(lines, "<br>")


/// Склеивает два куска текста механик через пустую строку. Любой из них может быть null.
/proc/ce_codex_join(first, second)
	if(!length(second))
		return first
	if(!length(first))
		return second
	return "[first]<br><br>[second]"


/**
 * Добавляет к тексту механик оба блока CE: чем предмет защищает и чем бьёт. Блок брони ставится
 * ПЕРЕД словесным описанием брони: числа — главное, слова — пояснение к ним.
 */
/obj/item/proc/ce_append_codex(info)
	var/datum/extension/armor/armor_datum = get_extension(src, /datum/extension/armor)
	if(armor_datum)
		info = ce_codex_join(armor_datum.ce_get_codex_line(), info)

	// Нулевая `force` отсекается внутри `ce_attack_codex_line()`, так что обычная одежда ничего не
	// допишет.
	var/attack_flags = damage_flags()
	if(ce_uses_kinetic_path(damtype, attack_flags))
		info = ce_codex_join(info, ce_attack_codex_line(force, attack_flags, armor_penetration))

	return info


// Одежду не ловит: её `get_mechanics_info()` в кор коде не зовёт `..()`, у неё свой оверрайд в
// `_master_files`.
/obj/item/get_mechanics_info()
	return ce_append_codex(..())


/// Блок пробития для снаряда по его типопути. Числа — штатные для типа снаряда, через `initial()`.
/proc/ce_projectile_codex_line(projectile_type, label = "Penetration")
	if(!ispath(projectile_type, /obj/item/projectile))
		return null

	var/obj/item/projectile/projectile = projectile_type
	if(initial(projectile.nodamage))
		return null

	// Снаряд, который уходит в лазер/энергию/взрыв, считается старой процентной формулой,
	// и печатать ему миллиметры RHA было бы враньём.
	var/projectile_flags = initial(projectile.damage_flags)
	if(!ce_uses_kinetic_path(initial(projectile.damage_type), projectile_flags))
		return null

	// Дробь резолвится по слоям НЕЗАВИСИМО, каждая дробина своей атакой, поэтому число
	// дробин — часть ответа на вопрос «что эта штука сделает с бронёй».
	var/list/extra_lines
	if(ispath(projectile_type, /obj/item/projectile/bullet/pellet))
		var/obj/item/projectile/bullet/pellet/shot = projectile_type
		var/count = initial(shot.pellets)
		if(count > 1)
			extra_lines = list("[count] pellets, each resolved against armor separately")

	return ce_attack_codex_line(
		initial(projectile.damage),
		projectile_flags,
		initial(projectile.armor_penetration),
		label,
		extra_lines,
		initial(projectile.ce_blunt_penetration)
	)


/**
 * Блок кодекса луча по его типопути: урон, AP и жар, который луч несёт в броню, остановившую его
 * целиком. null — снаряд не луч, который жёсткая броня держит вычитанием (`laser_heat.dm`).
 */
/proc/ce_beam_codex_line(projectile_type, label = "Beam")
	if(!ispath(projectile_type, /obj/item/projectile))
		return null
	var/obj/item/projectile/projectile = projectile_type
	var/damage = initial(projectile.damage)
	if(initial(projectile.nodamage) || damage <= 0)
		return null
	if(!ce_is_laser_heat_attack(initial(projectile.damage_type), initial(projectile.damage_flags)))
		return null

	var/armor_pen = initial(projectile.armor_penetration)
	var/heat = damage * ce_laser_heat_per_damage * initial(projectile.ce_laser_heat_mult) * max(0, 1 - armor_pen / ce_laser_heat_ap_divisor)
	var/list/lines = list(
		"<b>[label]:</b>",
		"[damage] damage, [armor_pen] armor penetration",
		"hard armor stops as much of it as its laser rating, minus the armor penetration",
		"[round(heat, 0.1)] heat into armor that stops all of it"
	)
	return jointext(lines, "<br>")


/obj/item/ammo_casing/get_mechanics_info()
	. = ..()
	. = ce_codex_join(., ce_projectile_codex_line(projectile_type))


/*
	Огнестрел. Своего пробития у ствола нет — он стреляет чем угодно своего калибра, — поэтому
	печатается пробитие патрона, который выйдет следующим.
*/

/**
 * Следующий живой патрон в оружии, без побочных эффектов. Повторяет порядок
 * `consume_next_projectile()`. Стреляные гильзы пропускаются: у револьвера и болтовки они
 * остаются внутри, но выстрела уже не дадут.
 */
/obj/item/gun/projectile/proc/ce_peek_next_casing()
	if(chambered?.BB)
		return chambered
	for(var/obj/item/ammo_casing/casing as anything in loaded)
		if(casing.BB)
			return casing
	if(ammo_magazine)
		for(var/i = length(ammo_magazine.stored_ammo) to 1 step -1)
			var/obj/item/ammo_casing/casing = ammo_magazine.stored_ammo[i]
			if(casing.BB)
				return casing
	return null

// Помповый дробовик стреляет только из патронника: остальное ждёт передёргивания.
/obj/item/gun/projectile/shotgun/pump/ce_peek_next_casing()
	if(chambered?.BB)
		return chambered
	return null

/obj/item/gun/projectile/get_mechanics_info()
	. = ..()
	var/obj/item/ammo_casing/casing = ce_peek_next_casing()
	if(casing)
		. = ce_codex_join(., ce_projectile_codex_line(casing.projectile_type, "Loaded round ([casing.name])"))


// Лучевое оружие печатает луч текущего режима огня.
/obj/item/gun/energy/get_mechanics_info()
	. = ..()
	. = ce_codex_join(., ce_beam_codex_line(projectile_type))


/*
	Плитоноска. Своей брони у неё нет, а в бою каждая пластина — отдельный слой со своей зоной
	покрытия. Поэтому числа печатаются блоком на пластину, а не суммой.
*/
/obj/item/clothing/suit/armor/pcarrier/get_mechanics_info()
	var/plates_info
	for(var/obj/item/clothing/accessory/plate as anything in accessories)
		var/datum/extension/armor/armor_datum = get_extension(plate, /datum/extension/armor)
		if(armor_datum)
			plates_info = ce_codex_join(plates_info, armor_datum.ce_get_codex_line(capitalize(plate.name)))
	return ce_codex_join(plates_info, ..())
