/*
	COMBAT_EXTENDED — юнит-тесты.

	Урон считается тем же проходом по слоям, что и в бою, а не своей копией формул. Проверяются
	инварианты, а не конкретные числа: числа живут в README и меняются при балансе, инварианты —
	нет.
*/

#define CE_PROMISE_STOPS "держит"
#define CE_PROMISE_DAMPENS "гасит"
#define CE_PROMISE_PENETRATES "пробивает"
/// Насколько далеко от середины площадки тест с настоящим полётом ставит стены и водит снаряды.
#define CE_ARENA_RADIUS 2

/datum/unit_test/combat_extended
	name = "CE: template"
	template = /datum/unit_test/combat_extended
	/// Всё, что тест создал. Удаляется в `cleanup()`.
	var/list/spawned = list()
	/// Середина площадки — клетка космоса у метки `space_turf`.
	var/turf/center
	/// Клетки площадки, ставшие стенами.
	var/list/walled = list()
	/// Двери и окна, поставленные на площадку.
	var/list/placed = list()

/datum/unit_test/combat_extended/proc/cleanup()
	QDEL_NULL_LIST(spawned)


// --- Площадка ---
// Тесты с настоящим полётом снаряда строят площадку сами, в космосе у метки `space_turf`, и убирают
// за собой: пол без воздуха, на нём стены. Пол нужен потому, что космос у края карты уносит всё,
// что в него влетело, на другой уровень (`touch_map_edge()`).

/// Клетка площадки со сдвигом от середины.
/datum/unit_test/combat_extended/proc/spot(offset_x, offset_y)
	RETURN_TYPE(/turf)
	return locate(center.x + offset_x, center.y + offset_y, center.z)

/// Чем площадка не годится, или null: все её клетки — пустой космос не на краю карты.
/datum/unit_test/combat_extended/proc/describe_arena_problem()
	if(!center)
		return "У площадки нет середины."
	for(var/offset_x in -CE_ARENA_RADIUS to CE_ARENA_RADIUS)
		for(var/offset_y in -CE_ARENA_RADIUS to CE_ARENA_RADIUS)
			var/turf/place = spot(offset_x, offset_y)
			if(!is_free_space(place))
				return "Клетка [offset_x],[offset_y] от середины площадки — [place ? place.type : "за краем карты"]: не пустой космос или край карты."
	return null

/// Клетка — пустой космос не на краю карты: в ней нет ничего плотного.
/datum/unit_test/combat_extended/proc/is_free_space(turf/place)
	if(!istype(place, /turf/space))
		return FALSE
	if(place.x <= 1 || place.y <= 1 || place.x >= world.maxx || place.y >= world.maxy)
		return FALSE
	for(var/atom/movable/thing in place)
		if(thing.density)
			return FALSE
	return TRUE

/**
 * Ставит площадку: её середина — ближайшая к метке `space_turf` клетка, вокруг которой все клетки
 * площадки — пустой космос. Сама метка на картах стоит и у края: на Сьерре — во второй клетке от
 * угла. Возвращает, почему площадку не поставить, или null.
 */
/datum/unit_test/combat_extended/proc/place_arena()
	var/turf/landmark = get_space_turf()
	if(!landmark)
		return "На карте нет метки `space_turf`."
	var/reach = 2 * CE_ARENA_RADIUS + 1
	var/turf/nearest
	var/nearest_shift
	for(var/shift_x in -reach to reach)
		for(var/shift_y in -reach to reach)
			var/shift = max(abs(shift_x), abs(shift_y))
			if(nearest && shift >= nearest_shift)
				continue
			center = locate(landmark.x + shift_x, landmark.y + shift_y, landmark.z)
			if(center && !describe_arena_problem())
				nearest = center
				nearest_shift = shift
	center = nearest
	if(!center)
		return "Рядом с меткой `space_turf` нет [reach] на [reach] клеток пустого космоса под площадку."
	return null

/**
 * Занимает площадку для теста с настоящим полётом. FALSE — её нет, и тест уже отчитался: карта без
 * метки — провал, карта без места под площадку — пропуск. Так на карте `away_sites_testing`: космоса
 * там полоса в четыре клетки.
 */
/datum/unit_test/combat_extended/proc/claim_arena()
	if(!get_space_turf())
		fail("На карте нет метки `space_turf`.")
		return FALSE
	var/problem = place_arena()
	if(problem)
		skip(problem)
		return FALSE
	return TRUE

/// Застилает всю площадку клетками типа `turf_type`: полом перед проверками, космосом после.
/datum/unit_test/combat_extended/proc/pave_arena(turf_type)
	for(var/offset_x in -CE_ARENA_RADIUS to CE_ARENA_RADIUS)
		for(var/offset_y in -CE_ARENA_RADIUS to CE_ARENA_RADIUS)
			var/turf/place = spot(offset_x, offset_y)
			place.ChangeTurf(turf_type)

/// Меняет клетку площадки на клетку типа `turf_type`. Пол вернёт `reset_arena()`.
/datum/unit_test/combat_extended/proc/build_turf(offset_x, offset_y, turf_type)
	RETURN_TYPE(/turf)
	var/turf/place = spot(offset_x, offset_y)
	walled |= place
	place.ChangeTurf(turf_type)
	return spot(offset_x, offset_y)

/// Ставит на клетку площадки стену типа `wall_type`.
/datum/unit_test/combat_extended/proc/build_wall(offset_x, offset_y, wall_type = /turf/simulated/wall)
	RETURN_TYPE(/turf/simulated/wall)
	return build_turf(offset_x, offset_y, wall_type)

/// Ставит на клетку площадки дверь или окно типа `path`. Уберёт их `reset_arena()`.
/datum/unit_test/combat_extended/proc/put(offset_x, offset_y, path)
	RETURN_TYPE(/obj)
	var/obj/thing = new path(spot(offset_x, offset_y))
	placed += thing
	return thing

/// Убирает стены, двери, окна и снаряды прошлой проверки.
/datum/unit_test/combat_extended/proc/reset_arena()
	for(var/obj/item/projectile/projectile in spawned)
		if(!QDELETED(projectile))
			qdel(projectile)
	for(var/obj/thing as anything in placed)
		if(!QDELETED(thing))
			qdel(thing)
	placed.Cut()
	for(var/turf/place as anything in walled)
		place.ChangeTurf(/turf/simulated/floor/airless)
	walled.Cut()
	// Искры рикошетов живут пять секунд: дольше теста.
	for(var/obj/sparks/sparks in center)
		qdel(sparks)

/// Один шаг полёта, как в кор `Process()`. FALSE — снаряд на этом шаге кончился.
/datum/unit_test/combat_extended/proc/fly_step(obj/item/projectile/projectile)
	projectile.trajectory.increment()
	projectile.location = projectile.trajectory.return_location(projectile.location)
	projectile.before_move()
	projectile.Move(projectile.location.return_turf())
	return !QDELETED(projectile)

/// Есть ли на стене след пули.
/datum/unit_test/combat_extended/proc/has_bullet_hole(turf/wall)
	return !!(locate(/obj/overlay/bullet_hole) in wall)


/// Человек в плитоноске с заданными аксессуарами, без аксессуаров — голый. null — одеть не вышло.
/datum/unit_test/combat_extended/proc/make_human(list/accessory_types, mobtype = /mob/living/carbon/human)
	var/list/made = create_test_mob_with_mind(null, mobtype)
	var/mob/living/carbon/human/H = locate(made["mobref"])
	if(!istype(H))
		return null
	spawned += H
	if(!length(accessory_types))
		return H

	var/obj/item/clothing/suit/armor/pcarrier/carrier = new(H.loc)
	for(var/accessory_type in accessory_types)
		carrier.attach_accessory(null, new accessory_type(carrier))
	H.equip_to_slot_or_del(carrier, slot_wear_suit)
	return H.wear_suit == carrier ? H : null


/// Ставит человеку навыки `list(путь навыка = уровень)`, остальные — по умолчанию.
/datum/unit_test/combat_extended/proc/set_skills(mob/living/carbon/human/H, list/levels)
	var/list/skills = list()
	for(var/skill in levels)
		skills[skill] = levels[skill]
	H.skillset.skill_list = skills


/**
 * Урон, дошедший до тела: `list(основной урон, урон остаточного удара, заново прошедшего слои)`.
 *
 * Считается проходом без побочных эффектов, то есть без износа брони и без самого урона.
 * Выключатель остаточного удара не смотрится: здесь проверяются формулы, а не выключатель.
 */
/datum/unit_test/combat_extended/proc/delivered_damage(mob/living/target, def_zone, damage, damage_flags, armor_pen)
	var/list/main = target.ce_walk_armor_layers(def_zone, damage, DAMAGE_BRUTE, damage_flags, armor_pen)
	var/list/residual = main[4]
	if(!residual)
		return list(main[1], 0)
	var/list/second = target.ce_walk_armor_layers(def_zone, residual[1], DAMAGE_BRUTE, FLAGS_OFF, new /datum/ce_explicit_pen(residual[2]))
	return list(main[1], second[1])


/**
 * Удар настоящим боевым проходом, с износом брони. Контекст, отложенный остаточный удар и осколки
 * убирает. `armor_pen` — число либо `/datum/ce_explicit_pen`.
 */
/datum/unit_test/combat_extended/proc/combat_hit(mob/living/carbon/human/H, def_zone, damage, damage_flags, armor_pen)
	H.modify_damage_by_armor(def_zone, damage, DAMAGE_BRUTE, damage_flags, H, armor_pen, TRUE)
	H.ce_hit_context = null
	H.ce_pending_residual = null
	H.ce_pending_shards = null


/// Броня новой вещи. С `ratings` она заменяется на заданную, с `material` — материал вещи.
/datum/unit_test/combat_extended/proc/armor_of(path, list/ratings, material)
	var/obj/item/thing = new path
	spawned += thing
	if(ratings)
		set_extension(thing, /datum/extension/armor, ratings)
	if(material)
		thing.ce_armor_material = material
	return get_extension(thing, /datum/extension/armor)


/**
 * Опорные удары холодным оружием: `list(название, сила, флаги, AP)`.
 *
 * Числами, а не типами: холодное оружие в Bay почти всё из `/obj/item/material`, и его сила
 * зависит от материала. Это те же точки, по которым откалиброваны `ce_pen_curve_melee` и
 * `ce_pen_curve_blunt`, плюс энергоклинок как самое бронебойное в билде.
 */
/datum/unit_test/combat_extended/proc/melee_anchors()
	return list(
		list("нож", 15, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 5),
		list("боевой нож", 12, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 10),
		list("меч", 30, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 10),
		list("энергомеч", 30, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 50),
		list("энергоклинок", 40, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 100),
		list("дубинка", 15, FLAGS_OFF, 0),
		list("ящик", 20, FLAGS_OFF, 0)
	)


/// Все кинетические атаки билда: опорное холодное оружие и все пули, по `list(название, урон, флаги, AP)`.
/datum/unit_test/combat_extended/proc/all_attacks()
	var/list/attacks = melee_anchors()
	for(var/path in typesof(/obj/item/projectile/bullet))
		var/obj/item/projectile/bullet/bullet = path
		var/damage = initial(bullet.damage)
		var/flags = initial(bullet.damage_flags)
		if(damage <= 0 || !ce_uses_kinetic_path(initial(bullet.damage_type), flags))
			continue
		attacks += list(list("[path]", damage, flags, initial(bullet.armor_penetration)))
	return attacks


/**
 * Лестница целей: голый человек и четыре жёсткие плиты по возрастанию тира. Названия тиров
 * дописываются в `tiers`. null — кого-то не удалось создать.
 *
 * Первые две — лёгкая стальная пластина и скрытый тактический жилет: числа Bay у них те же, что у
 * light- и medium-вставок. Сами вставки — мягкий кевлар с одной тупой осью на обе, и лестницы не
 * образуют: см. README, «Кевларовые вставки».
 */
/datum/unit_test/combat_extended/proc/make_plate_ladder(list/tiers)
	var/list/plates = list(
		"без брони" = null,
		"light metal" = /obj/item/clothing/accessory/armor_plate/makeshift/light,
		"low-profile tactical" = /obj/item/clothing/accessory/armor_plate/sneaky/tactical,
		"tactical" = /obj/item/clothing/accessory/armor_plate/tactical,
		"merc" = /obj/item/clothing/accessory/armor_plate/merc
	)
	var/list/targets = list()
	for(var/tier in plates)
		var/plate = plates[tier]
		var/mob/living/carbon/human/H = make_human(plate ? list(plate) : null)
		if(!H)
			return null
		tiers += tier
		targets += H
	return targets


/*
	Остаточный удар добавляет урон пробившей атаке, и нельзя, чтобы из-за него плита потяжелее
	пропускала больше, чем полегче. Проверяются все пули билда и опорное холодное оружие против
	голой цели и четырёх плит.

	Модель показывает, где это правило вообще может нарушиться: холодное оружие силой до 16 с AP
	от 85. Такого в билде нет.
*/
/datum/unit_test/combat_extended/residual_monotonic
	name = "CE: Доставленный урон не растёт с тиром плиты"

/datum/unit_test/combat_extended/residual_monotonic/start_test()
	var/list/tiers = list()
	var/list/targets = make_plate_ladder(tiers)
	if(!targets)
		fail("Не удалось создать цели.")
		cleanup()
		return 1

	var/list/attacks = all_attacks()
	var/list/failures = list()
	for(var/list/attack in attacks)
		var/previous
		for(var/i in 1 to length(targets))
			var/list/delivered = delivered_damage(targets[i], BP_CHEST, attack[2], attack[3], attack[4])
			var/total = delivered[1] + delivered[2]
			if(!isnull(previous) && total > previous + 0.001)
				failures += "[attack[1]]: [tiers[i - 1]] [round(previous, 0.01)] -> [tiers[i]] [round(total, 0.01)]"
			previous = total

	cleanup()
	if(length(failures))
		fail("Урон растёт с тиром плиты в [length(failures)] случаях:\n[jointext(failures, "\n")]")
	else
		pass("[length(attacks)] атак против [length(tiers)] целей: урон не растёт.")
	return 1


/*
	Обещания из комментариев `code/__defines/armor.dm` — таблица «Проверка обещаний дефайнов»
	в README. «Держит» для острой атаки значит «острая ось побеждена, атака срикошетила», а не
	«урон ноль». Тупой урон броня гасит, но не отменяет — см. `CE_BLUNT_PEN_MELEE_MULT`.
*/
/datum/unit_test/combat_extended/define_promises
	name = "CE: Обещания дефайнов брони"

/datum/unit_test/combat_extended/define_promises/start_test()
	var/datum/extension/armor/pistol_armor = make_plate(ARMOR_BALLISTIC_PISTOL, 0)
	var/datum/extension/armor/rifle_armor = make_plate(ARMOR_BALLISTIC_RIFLE, 0)
	var/datum/extension/armor/knives_armor = make_plate(0, ARMOR_MELEE_KNIVES)
	var/datum/extension/armor/resistant_armor = make_plate(0, ARMOR_MELEE_RESISTANT)
	var/obj/item/clothing/suit/armor/riot/riot = new
	spawned += riot
	var/datum/extension/armor/riot_armor = get_extension(riot, /datum/extension/armor)

	var/list/knife = list(15, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 5)
	var/list/sword = list(30, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 10)
	var/list/esword = list(30, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 50)
	var/list/baton = list(15, FLAGS_OFF, 0)
	var/list/toolbox = list(20, FLAGS_OFF, 0)

	var/list/promises = list(
		list("ARMOR_BALLISTIC_PISTOL и pistol", pistol_armor, /obj/item/projectile/bullet/pistol, CE_PROMISE_STOPS),
		list("ARMOR_BALLISTIC_PISTOL и holdout", pistol_armor, /obj/item/projectile/bullet/pistol/holdout, CE_PROMISE_STOPS),
		list("ARMOR_BALLISTIC_PISTOL и rifle", pistol_armor, /obj/item/projectile/bullet/rifle, CE_PROMISE_PENETRATES),
		list("ARMOR_BALLISTIC_RIFLE и rifle", rifle_armor, /obj/item/projectile/bullet/rifle, CE_PROMISE_STOPS),
		list("ARMOR_BALLISTIC_RIFLE и apds", rifle_armor, /obj/item/projectile/bullet/rifle/shell/apds, CE_PROMISE_PENETRATES),
		list("ARMOR_MELEE_KNIVES и нож", knives_armor, knife, CE_PROMISE_STOPS),
		list("ARMOR_MELEE_KNIVES и дубинка", knives_armor, baton, CE_PROMISE_DAMPENS),
		list("ARMOR_MELEE_RESISTANT и меч", resistant_armor, sword, CE_PROMISE_STOPS),
		list("ARMOR_MELEE_RESISTANT и ящик", resistant_armor, toolbox, CE_PROMISE_DAMPENS),
		list("riot и меч", riot_armor, sword, CE_PROMISE_STOPS),
		list("riot и pistol", riot_armor, /obj/item/projectile/bullet/pistol, CE_PROMISE_PENETRATES),
		list("riot и энергомеч", riot_armor, esword, CE_PROMISE_PENETRATES)
	)

	var/list/failures = list()
	for(var/list/promise in promises)
		var/list/attack = promise[3]
		if(ispath(attack))
			var/obj/item/projectile/bullet/bullet = attack
			attack = list(initial(bullet.damage), initial(bullet.damage_flags), initial(bullet.armor_penetration))
		var/outcome = try_single_layer(promise[2], attack[1], attack[2], attack[3])
		if(outcome != promise[4])
			failures += "[promise[1]]: ожидалось «[promise[4]]», вышло «[outcome]»"

	cleanup()
	if(length(failures))
		fail("Нарушено [length(failures)] из [length(promises)] обещаний:\n[jointext(failures, "\n")]")
	else
		pass("Все [length(promises)] обещаний держатся.")
	return 1

/// Жёсткая пластина с заданными значениями брони. Не базовый `armor_plate`: тот — кевларовая вставка.
/datum/unit_test/combat_extended/define_promises/proc/make_plate(bullet, melee)
	var/obj/item/clothing/accessory/armor_plate/merc/plate = new
	spawned += plate
	set_extension(plate, /datum/extension/armor, list("bullet" = bullet, "melee" = melee))
	return get_extension(plate, /datum/extension/armor)

/// Итог одного слоя для одной атаки: `CE_PROMISE_*`.
/datum/unit_test/combat_extended/define_promises/proc/try_single_layer(datum/extension/armor/armor, damage, damage_flags, armor_pen)
	var/pen = ce_derive_penetration(damage, damage_flags, armor_pen)
	var/blunt_pen = ce_derive_blunt_penetration(damage, damage_flags, armor_pen)
	var/list/step = armor.ce_try_penetrate(damage, damage_flags, pen, damage, pen, blunt_pen)
	if(ce_is_sharp_attack(damage_flags))
		return ce_is_sharp_attack(step[3]) ? CE_PROMISE_PENETRATES : CE_PROMISE_STOPS
	if(step[1] <= 0)
		return CE_PROMISE_STOPS
	return step[1] < damage ? CE_PROMISE_DAMPENS : CE_PROMISE_PENETRATES


/*
	Вещи без кинетической брони: `bullet` и `melee` нулевые, броня есть только по другим ключам —
	хирургические маски, био-капюшоны, голые скафандры, `rig/zero`. У них все три кинетические
	оси выводятся в ноль, и правка кривых не должна выдать им рейтинг пластины. README, «Мост
	единиц».

	Идёт по настоящим вещам билда, поэтому каждая одежда и каждый РИГ создаются: список брони по
	пути типа не прочитать, `initial()` для списков отдаёт null. Детали РИГа берут броню от блока,
	поэтому смотрится и содержимое вещи. Пропускаются вещи, которые вне игры не создать: базовый
	костюм с капюшоном без `hoodtype` и пси-перчатки, которые без хозяина-псионика удаляют себя в
	`New()`. Брони по кинетике нет ни у тех, ни у других.

	Прочие носители — мобы, протезы, `holder` — читают те же четыре острые кривые. Жёсткие и мягкие
	вещи среди найденных обязательны, чтобы ни одна пара кривых не осталась без проверки.
*/
/datum/unit_test/combat_extended/zero_kinetic_armor
	name = "CE: Вещи без кинетической брони не держат кинетику"

/datum/unit_test/combat_extended/zero_kinetic_armor/start_test()
	var/list/failures = list()
	var/hard_count = 0
	var/soft_count = 0
	var/list/paths = typesof_real(/obj/item/clothing) + typesof_real(/obj/item/rig)
	paths -= /obj/item/clothing/suit/storage/hooded
	paths -= typesof(/obj/item/clothing/gloves/insulated/psi) + typesof(/obj/item/clothing/gloves/latex/psi)
	for(var/path in paths)
		var/obj/item/item = new path
		for(var/obj/item/thing in list(item) + item.contents)
			var/datum/extension/armor/armor = get_extension(thing, /datum/extension/armor)
			if(!armor || armor.get_value("bullet") || armor.get_value("melee"))
				continue
			if(armor.is_hard_armor())
				hard_count++
			else
				soft_count++
			var/sharp_ballistic = armor.get_armor_sharp_ballistic()
			var/sharp_melee = armor.get_armor_sharp_melee()
			var/blunt = armor.get_armor_blunt()
			if(sharp_ballistic || sharp_melee || blunt)
				var/where = thing == item ? "" : " в [path]"
				failures += "[thing.type][where]: Sharp пуль [sharp_ballistic], Sharp холодного [sharp_melee], Blunt [blunt]"
		qdel(item)

	if(!hard_count || !soft_count)
		failures += "без кинетической брони найдено жёстких вещей [hard_count], мягких [soft_count]: одна из пар кривых не проверена"
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("[hard_count + soft_count] вещей без кинетической брони, из них [hard_count] жёстких: все кинетические оси — ноль.")
	return 1


/*
	Проход по слоям берёт броню аксессуара, только если тот закрывает зону попадания
	(`body_parts_covered`), а у аксессуара она по умолчанию пуста. Так самодельные пластины в
	`packs/infinity` лежали мимо `armor_plate` и не держали ничего. Аксессуары создаются, а не
	читаются по типам: список брони через `initial()` не прочитать.
*/
/datum/unit_test/combat_extended/accessory_armor_coverage
	name = "CE: Броня аксессуаров что-то закрывает"

/datum/unit_test/combat_extended/accessory_armor_coverage/start_test()
	var/list/failures = list()
	var/armored_count = 0
	for(var/path in typesof_real(/obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/accessory = new path
		var/datum/extension/armor/armor = get_extension(accessory, /datum/extension/armor)
		var/armored = FALSE
		for(var/key in armor?.armor_values)
			if(armor.armor_values[key])
				armored = TRUE
		if(armored)
			armored_count++
			if(!accessory.body_parts_covered)
				failures += "[path]: есть броня, но не закрыта ни одна часть тела"
		qdel(accessory)

	if(!armored_count)
		failures += "в билде нет аксессуаров с бронёй"
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("[armored_count] аксессуаров с бронёй, каждый что-то закрывает.")
	return 1


/*
	Остаточный удар у человека: удар откладывается, наносится обёрткой `apply_damage()` после
	основного и проходит броню заново. Бьём в руку через наручи: внутренних органов в руке нет,
	так что урон не делится случайно между конечностью и органом.

	Износ на время теста выключен: ожидание считается по новым наручам, а основной проход
	изнашивает их до остаточного удара.
*/
/datum/unit_test/combat_extended/residual_human
	name = "CE: Остаточный удар по человеку"

/datum/unit_test/combat_extended/residual_human/start_test()
	var/old_enabled = ce_residual_blunt_enabled
	var/old_wear = ce_armor_wear_enabled
	ce_armor_wear_enabled = FALSE
	var/list/failures = list()
	var/damage = 45
	var/flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP
	var/armor_pen = 25

	for(var/enabled in list(FALSE, TRUE))
		ce_residual_blunt_enabled = enabled
		var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/arm_guards))
		if(!H)
			failures += "не удалось создать цель в наручах"
			break

		var/list/expected = delivered_damage(H, BP_L_ARM, damage, flags, armor_pen)
		if(expected[2] < 1)
			failures += "атака должна частично пробить наручи, а остаточный удар вышел [expected[2]]"
			break

		var/obj/item/organ/external/arm = H.get_organ(BP_L_ARM)
		H.apply_damage(damage, DAMAGE_BRUTE, BP_L_ARM, flags, null, armor_pen)

		// `take_external_damage()` округляет урон до 0.1, по разу на удар.
		var/should_be = enabled ? expected[1] + expected[2] : expected[1]
		if(abs(arm.brute_dam - should_be) > 0.2)
			failures += "выключатель [enabled]: рука получила [arm.brute_dam], ожидалось [round(should_be, 0.1)]"
		if(H.ce_pending_residual || H.ce_hit_context)
			failures += "выключатель [enabled]: после попадания на человеке остались контекст или отложенный удар"

	ce_residual_blunt_enabled = old_enabled
	ce_armor_wear_enabled = old_wear
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Остаточный удар наносится только при включённом выключателе и проходит броню заново.")
	return 1


/*
	Остаточный удар у моба без органов: удар наносится сразу, из прохода по слоям основного.
	Тем же путём идут экзокостюмы.
*/
/datum/unit_test/combat_extended/residual_simple_mob
	name = "CE: Остаточный удар по простому мобу"

/datum/unit_test/combat_extended/residual_simple_mob/start_test()
	var/old_enabled = ce_residual_blunt_enabled
	ce_residual_blunt_enabled = TRUE

	var/turf/spawn_turf = get_safe_turf() || locate(/turf/simulated/floor)
	var/mob/living/simple_animal/passive/cow/cow = new(spawn_turf)
	spawned += cow
	cow.maxHealth = 1000
	cow.health = 1000
	set_extension(cow, /datum/extension/armor, list("bullet" = ARMOR_BALLISTIC_PISTOL, "melee" = ARMOR_MELEE_KNIVES))

	var/damage = 45
	var/flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP
	var/armor_pen = 25
	var/list/expected = delivered_damage(cow, BP_CHEST, damage, flags, armor_pen)
	cow.apply_damage(damage, DAMAGE_BRUTE, BP_CHEST, flags, null, armor_pen)
	var/taken = 1000 - cow.health

	ce_residual_blunt_enabled = old_enabled
	cleanup()
	if(expected[2] < 1)
		fail("Атака должна частично пробить броню, а остаточный удар вышел [expected[2]].")
	else if(abs(taken - (expected[1] + expected[2])) > 0.01)
		fail("Моб получил [taken], ожидалось [expected[1]] + [expected[2]].")
	else
		pass("Моб получил основной урон и остаточный удар: [round(expected[1], 0.01)] + [round(expected[2], 0.01)].")
	return 1


/*
	Досягаемость органов не убывает с остатком пробития, а значит, плита потяжелее не пускает к
	органам дальше, чем полегче. Сначала сама формула, потом боевой путь: все пули билда и опорное
	холодное оружие против голой цели и четырёх плит.

	Износ на время теста выключен: каждая плита получает сотни попаданий, и сравнивались бы уже
	изношенные плиты.
*/
/datum/unit_test/combat_extended/organ_reach_monotonic
	name = "CE: Досягаемость органов не растёт с тиром плиты"

/datum/unit_test/combat_extended/organ_reach_monotonic/start_test()
	var/old_enabled = ce_organ_depth_enabled
	var/old_wear = ce_armor_wear_enabled
	ce_organ_depth_enabled = TRUE
	ce_armor_wear_enabled = FALSE
	var/list/failures = list()

	for(var/flags in list(DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE))
		var/previous = 0
		for(var/i in 0 to 600)
			var/pen = i * 0.05
			var/reach = ce_organ_reach(pen, flags)
			if(reach < previous || reach > 1)
				failures += "формула, флаги [flags]: при [pen] мм досягаемость [reach] после [previous]"
				break
			previous = reach
		if(previous != 1)
			failures += "формула, флаги [flags]: при 30 мм досягаемость [previous], а не 1"

	var/list/tiers = list()
	var/list/targets = make_plate_ladder(tiers)
	if(!targets)
		failures += "не удалось создать цели"
		targets = list()

	var/attack_count = 0
	for(var/list/attack in all_attacks())
		if(!ce_is_sharp_attack(attack[3]))
			continue
		attack_count++
		var/previous
		for(var/i in 1 to length(targets))
			var/reach = hit_reach(targets[i], BP_CHEST, attack[2], attack[3], attack[4])
			if(isnull(reach))
				failures += "[attack[1]] по «[tiers[i]]»: острое попадание не записало контекст"
				continue
			if(!isnull(previous) && reach > previous + 0.0001)
				failures += "[attack[1]]: [tiers[i - 1]] [round(previous, 0.01)] -> [tiers[i]] [round(reach, 0.01)]"
			previous = reach

	ce_organ_depth_enabled = old_enabled
	ce_armor_wear_enabled = old_wear
	cleanup()
	if(length(failures))
		fail("Досягаемость нарушает монотонность в [length(failures)] случаях:\n[jointext(failures, "\n")]")
	else
		pass("Формула монотонна, [attack_count] острых атак против [length(tiers)] целей: досягаемость не растёт с тиром.")
	return 1

/**
 * Досягаемость, которую записывает настоящий боевой проход, либо null, если контекст не записан.
 * Износ выключает вызывающий тест. Контекст, отложенный остаточный удар и осколки после себя убирает.
 */
/datum/unit_test/combat_extended/proc/hit_reach(mob/living/carbon/human/H, def_zone, damage, damage_flags, armor_pen)
	H.modify_damage_by_armor(def_zone, damage, DAMAGE_BRUTE, damage_flags, H, armor_pen, TRUE)
	var/list/context = H.ce_hit_context
	H.ce_hit_context = null
	H.ce_pending_residual = null
	H.ce_pending_shards = null
	return context ? context[2] : null


/*
	Рикошет и остаточный удар до органов не доходят — байевский эквивалент переноса на внешнюю
	часть тела из CE. В конце то же самое через весь `apply_damage()`: по правилу Bay рикошет
	10-мм пистолета от medium задевал бы органы в 42% попаданий.

	Износ на время теста выключен: одна и та же плита принимает серию попаданий, и «medium держит
	пистолет» должно оставаться правдой до последнего.
*/
/datum/unit_test/combat_extended/organ_reach_secondary
	name = "CE: Рикошет и остаточный удар не достают до органов"

/datum/unit_test/combat_extended/organ_reach_secondary/start_test()
	var/old_enabled = ce_organ_depth_enabled
	var/old_wear = ce_armor_wear_enabled
	ce_organ_depth_enabled = TRUE
	ce_armor_wear_enabled = FALSE
	var/list/failures = list()
	var/flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP

	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/medium))
	if(!H)
		failures += "не удалось создать цель в medium"
	else
		var/list/result = H.modify_damage_by_armor(BP_CHEST, 45, DAMAGE_BRUTE, flags, H, 0, TRUE)
		if(ce_is_sharp_attack(result[3]))
			failures += "pistol должен срикошетить от medium"
		check_context(H, 0, "рикошет", failures)
		H.ce_pending_residual = null

		result = H.modify_damage_by_armor(BP_CHEST, 45, DAMAGE_BRUTE, flags, H, 25, TRUE)
		var/expected = ce_organ_reach(result[5], result[3])
		if(expected <= 0)
			failures += "rifle должен пробить medium с остатком пробития"
		check_context(H, expected, "пробитие", failures)

		var/list/residual = H.ce_pending_residual
		H.ce_pending_residual = null
		if(!residual)
			failures += "пробившая medium rifle должна оставить остаточный удар"
		else
			H.modify_damage_by_armor(residual[1], residual[2], DAMAGE_BRUTE, FLAGS_OFF, H, new /datum/ce_explicit_pen(residual[3]), TRUE)
			check_context(H, 0, "остаточный удар", failures)

		H.modify_damage_by_armor(BP_CHEST, 20, DAMAGE_BRUTE, FLAGS_OFF, H, 0, TRUE)
		if(H.ce_hit_context)
			failures += "родной тупой удар записал контекст"
		H.ce_hit_context = null

		ce_organ_depth_enabled = FALSE
		H.modify_damage_by_armor(BP_CHEST, 45, DAMAGE_BRUTE, flags, H, 25, TRUE)
		if(H.ce_hit_context)
			failures += "при выключенном выключателе записан контекст"
		H.ce_hit_context = null
		H.ce_pending_residual = null
		ce_organ_depth_enabled = TRUE

	var/mob/living/carbon/human/shot = make_human(list(/obj/item/clothing/accessory/armor_plate/medium))
	if(!shot)
		failures += "не удалось создать вторую цель в medium"
	else
		var/obj/item/organ/external/chest = shot.get_organ(BP_CHEST)
		for(var/i in 1 to 4)
			shot.apply_damage(45, DAMAGE_BRUTE, BP_CHEST, flags, null, 0, TRUE)
		var/organ_damage = 0
		for(var/obj/item/organ/internal/I in chest.internal_organs)
			organ_damage += I.damage
		if(!chest.brute_dam)
			failures += "рикошеты через apply_damage() не дошли до груди"
		if(organ_damage)
			failures += "рикошеты через apply_damage() задели органы на [organ_damage]"

	ce_organ_depth_enabled = old_enabled
	ce_armor_wear_enabled = old_wear
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Рикошет и остаточный удар пишут досягаемость 0, пробитие — по остатку, тупой удар — ничего.")
	return 1

/datum/unit_test/combat_extended/organ_reach_secondary/proc/check_context(mob/living/carbon/human/H, reach, what, list/failures)
	var/list/context = H.ce_hit_context
	H.ce_hit_context = null
	if(!context)
		failures += "[what]: контекст не записан"
	else if(context[1] != BP_CHEST || abs(context[2] - reach) > 0.0001)
		failures += "[what]: контекст [context[1]] / [context[2]], ожидалось [BP_CHEST] / [reach]"


/*
	Оверрайд `damage_internal_organs()`: без контекста, с контекстом чужой конечности и на добитой
	конечности — кор версия как есть, иначе сначала бросок досягаемости.

	Бросок кор версии делается детерминированным: при сломанных рёбрах и остром уроне 50 её шанс
	задеть орган упирается в 100%. Остаётся только бросок досягаемости, а при 0 и 1 он тоже
	детерминирован.
*/
/datum/unit_test/combat_extended/organ_reach_gate
	name = "CE: Органы задеваются по досягаемости"

/datum/unit_test/combat_extended/organ_reach_gate/start_test()
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		fail("Не удалось создать цель.")
		cleanup()
		return 1

	var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
	chest.status |= ORGAN_BROKEN
	var/list/cases = list(
		list("досягаемость 0", list(BP_CHEST, 0), 0, FALSE),
		list("досягаемость 1", list(BP_CHEST, 1), 0, TRUE),
		list("без контекста", null, 0, TRUE),
		list("контекст другой конечности", list(BP_HEAD, 0), 0, TRUE),
		list("добитая конечность", list(BP_CHEST, 0), chest.max_damage, TRUE)
	)

	var/list/failures = list()
	for(var/list/test_case in cases)
		for(var/obj/item/organ/internal/I in chest.internal_organs)
			I.damage = 0
		chest.brute_dam = test_case[3]
		H.ce_hit_context = test_case[2]

		var/hit = !!chest.damage_internal_organs(50, 0, DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP)
		var/organ_damage = 0
		for(var/obj/item/organ/internal/I in chest.internal_organs)
			organ_damage += I.damage
		if(hit != test_case[4] || !!organ_damage != test_case[4])
			failures += "[test_case[1]]: органы [hit ? "задеты" : "не задеты"], урон органам [organ_damage]"
		if(H.ce_hit_context)
			failures += "[test_case[1]]: контекст не израсходован"
	chest.brute_dam = 0

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Все [length(cases)] случаев оверрайда ведут себя как задумано.")
	return 1


/*
	Протез, у модели которого не задана `ce_density`, считается плотью владельца —
	ничего не меняется, пока плотность протезов не откалибрована. Проверяются все модели
	`all_robolimbs`, а ветка с заданной плотностью — на временно выставленном значении.
*/
/datum/unit_test/combat_extended/robolimb_density
	name = "CE: Протез без плотности считается плотью"

/datum/unit_test/combat_extended/robolimb_density/start_test()
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		fail("Не удалось создать цель.")
		cleanup()
		return 1

	var/list/failures = list()
	var/flesh = H.species.ce_flesh_rha * H.species.total_health / CE_FLESH_REFERENCE_HEALTH
	var/obj/item/organ/external/arm = H.get_organ(BP_L_ARM)
	if(H.ce_part_density(BP_L_ARM) != flesh)
		failures += "живая рука: [H.ce_part_density(BP_L_ARM)], ожидалось [flesh]"

	arm.robotize()
	if(!BP_IS_ROBOTIC(arm))
		failures += "рука не стала протезом"
	else
		arm.model = null
		if(H.ce_part_density(BP_L_ARM) != flesh)
			failures += "протез без модели: [H.ce_part_density(BP_L_ARM)], ожидалось [flesh]"

		for(var/company in all_robolimbs)
			var/datum/robolimb/R = all_robolimbs[company]
			arm.model = company
			var/expected = isnull(R.ce_density) ? flesh : R.ce_density
			if(H.ce_part_density(BP_L_ARM) != expected)
				failures += "[company]: [H.ce_part_density(BP_L_ARM)], ожидалось [expected]"

		var/company = all_robolimbs[1]
		var/datum/robolimb/R = all_robolimbs[company]
		var/old_density = R.ce_density
		R.ce_density = flesh + 1
		arm.model = company
		if(H.ce_part_density(BP_L_ARM) != flesh + 1)
			failures += "[company] с плотностью [flesh + 1]: [H.ce_part_density(BP_L_ARM)]"
		R.ce_density = old_density

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Все [length(all_robolimbs)] моделей протезов без плотности считаются плотью, заданная плотность читается.")
	return 1


/*
	Подкожная броня (`subdermal_armor.dm`) — самый внутренний слой на всём теле и прибавка к
	плотности тканей. Множитель Bay снят: `get_brute_mod()` с сеткой тот же, что без неё. Орган не
	изнашивается. Обычная сетка мягкая и нож только гасит, хитин генокрада жёсткий и нож
	останавливает. Пистолет пробивает обе, но теряет на них урон. Касание — тычок дубинкой — сетка
	не держит: она под кожей. Наручи на руке его держат, как и прежде.

	Сетка ставится в грудь через `replaced()`, как её ставит сила генокрада. Левая рука — протез:
	в Bay множитель действовал и на протезы. На руках наручи, чтобы порядок слоёв было с чем
	сравнить: у голого человека сетка — единственный слой.
*/
/datum/unit_test/combat_extended/subdermal_armor
	name = "CE: Подкожная броня"
	var/list/zones = list(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_FOOT)

/datum/unit_test/combat_extended/subdermal_armor/start_test()
	var/list/failures = list()
	var/list/meshes = list(
		/obj/item/organ/internal/augment/armor = FALSE,
		/obj/item/organ/internal/augment/armor/changeling = TRUE
	)
	for(var/mesh_type in meshes)
		failures += check_mesh(mesh_type, meshes[mesh_type])

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Обе подкожные брони — внутренний слой на [length(zones)] зонах, с плотностью, без множителя Bay и без износа.")
	return 1


/// Проверки одной подкожной брони. Отдаёт список провалов.
/datum/unit_test/combat_extended/subdermal_armor/proc/check_mesh(mesh_type, hard)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/arm_guards))
	if(!H)
		return list("[mesh_type]: не удалось создать цель в наручах")
	var/obj/item/organ/external/arm = H.get_organ(BP_L_ARM)
	arm.robotize()
	if(!BP_IS_ROBOTIC(arm))
		return list("[mesh_type]: рука не стала протезом")

	var/list/naked = measure(H)
	var/obj/item/organ/internal/augment/armor/mesh = new mesh_type(H)
	mesh.parent_organ = BP_CHEST
	mesh.organ_tag = "[BP_CHEST]_aug_armor"
	mesh.replaced(H, H.get_organ(BP_CHEST))
	var/datum/extension/armor/mesh_armor = get_extension(mesh, /datum/extension/armor)
	if(!(mesh in H.internal_organs) || !mesh_armor)
		return list("[mesh_type]: не встала в грудь или без брони")
	var/list/armored = measure(H)

	. = list()
	for(var/zone in zones)
		var/list/armors = H.get_armors_by_zone(zone, DAMAGE_BRUTE, DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP)
		if(!length(armors) || armors[length(armors)] != mesh_armor)
			. += "[mesh_type], [zone]: сетка не внутренний слой"
		if(zone == BP_L_ARM && length(armors) < 2)
			. += "[mesh_type]: на руке нет слоёв поверх сетки, порядок не проверен"
		var/list/before = naked[zone]
		var/list/after = armored[zone]
		if(abs(after[1] - before[1] - mesh.ce_density_rha) > 0.001)
			. += "[mesh_type], [zone]: плотность [before[1]] -> [after[1]], сетка добавляет [mesh.ce_density_rha]"
		if(after[2] != before[2])
			. += "[mesh_type], [zone]: множитель Bay [before[2]] -> [after[2]]"

	if(mesh_armor.is_hard_armor() != hard)
		. += "[mesh_type]: жёсткость [mesh_armor.is_hard_armor()], ожидалось [hard]"
	if(mesh_armor.ce_can_wear())
		. += "[mesh_type]: изнашивается"
	if(H.ce_armor_stops_contact(BP_CHEST, DAMAGE_BRUTE, FLAGS_OFF))
		. += "[mesh_type]: касание груди остановлено, а сетка под кожей"
	if(!H.ce_armor_stops_contact(BP_L_ARM, DAMAGE_BRUTE, FLAGS_OFF))
		. += "[mesh_type]: касание руки прошло сквозь наручи"

	var/list/pistol_before = naked["pistol"]
	var/list/pistol_after = armored["pistol"]
	if(!ce_is_sharp_attack(pistol_after[2]) || pistol_after[1] >= pistol_before[1])
		. += "[mesh_type]: пистолет должен пробить сетку с потерей урона, вышло [pistol_before[1]] -> [pistol_after[1]]"

	var/list/knife_before = naked["knife"]
	var/list/knife_after = armored["knife"]
	if(hard && ce_is_sharp_attack(knife_after[2]))
		. += "[mesh_type]: хитин должен остановить нож, а тот прошёл с уроном [knife_after[1]]"
	if(!hard && (!ce_is_sharp_attack(knife_after[2]) || knife_after[1] >= knife_before[1]))
		. += "[mesh_type]: сетка должна пропустить нож с потерей урона, вышло [knife_before[1]] -> [knife_after[1]]"


/**
 * Плотность и множитель Bay по зонам — `list(плотность, множитель)` по ключу зоны, — и итоги
 * пистолета и ножа по груди по ключам `pistol` и `knife`.
 */
/datum/unit_test/combat_extended/subdermal_armor/proc/measure(mob/living/carbon/human/H)
	. = list()
	for(var/zone in zones)
		var/obj/item/organ/external/organ = H.get_organ(zone)
		.[zone] = list(H.ce_part_density(zone), organ.get_brute_mod())

	var/obj/item/projectile/bullet/pistol = /obj/item/projectile/bullet/pistol
	.["pistol"] = H.ce_walk_armor_layers(BP_CHEST, initial(pistol.damage), DAMAGE_BRUTE, initial(pistol.damage_flags), initial(pistol.armor_penetration))
	.["knife"] = H.ce_walk_armor_layers(BP_CHEST, 15, DAMAGE_BRUTE, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, 5)


/*
	Контузия от взрыва (`concussion.dm`): бросок на паралич кор `human/ex_act()` откатывается, а
	вместо него — замешательство, муть и сбитая речь. Тяжёлый взрыв бросает `prob(70)`, так что за
	десять взрывов без отката паралич остался бы почти наверняка. Каждый взрыв — по новому человеку:
	тяжёлый взрыв калечит, а раны влияли бы на следующий.

	Сила: лёгкий взрыв без защиты — 1, тяжёлый — 2, лёжа — вдвое меньше, каска со своей бронёй
	`bomb` гасит часть, костюм сапёра — ещё больше. Выключенный мод контузию не накладывает.

	С ног сбивает только тяжёлый взрыв и только незащищённого. Отказы проверяются по самому решению
	(`ce_is_knocked_down_by_blast()`), а не по `weakened` после взрыва: урон взрыва может уронить
	и болью.
*/
/datum/unit_test/combat_extended/concussion
	name = "CE: Контузия от взрыва"

/datum/unit_test/combat_extended/concussion/start_test()
	var/old_switch = ce_concussion_enabled
	ce_concussion_enabled = TRUE
	var/list/failures = list()

	for(var/i in 1 to 10)
		var/mob/living/carbon/human/H = make_human()
		if(!H)
			failures += "не удалось создать цель"
			break
		H.ex_act(EX_ACT_HEAVY)
		if(H.paralysis)
			failures += "взрыв [i]: паралич [H.paralysis]"
		if(!H.is_confused() || !H.eye_blurry || !H.stuttering)
			failures += "взрыв [i]: не контузил — замешательство [H.is_confused()], муть [H.eye_blurry], речь [H.stuttering]"
		if(!H.weakened)
			failures += "взрыв [i]: незащищённого не сбил с ног"

	failures += check_strength()

	ce_concussion_enabled = FALSE
	var/mob/living/carbon/human/control = make_human()
	if(control)
		control.ex_act(EX_ACT_LIGHT)
		if(control.is_confused())
			failures += "выключенный мод контузил"
	ce_concussion_enabled = old_switch

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Десять тяжёлых взрывов без паралича и с контузией, сила падает с бронёй и лёжа, выключатель работает.")
	return 1


/// Сила контузии без защиты, лёжа, в каске и в костюме сапёра. Отдаёт список провалов.
/datum/unit_test/combat_extended/concussion/proc/check_strength()
	. = list()
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		return list("не удалось создать цель для силы")

	var/light = H.ce_get_concussion_strength(EX_ACT_LIGHT)
	var/heavy = H.ce_get_concussion_strength(EX_ACT_HEAVY)
	if(abs(light - 1) > 0.001 || abs(heavy - 2) > 0.001)
		. += "без защиты: лёгкий [light], тяжёлый [heavy], ожидалось 1 и 2"
	if(!H.ce_is_knocked_down_by_blast(EX_ACT_HEAVY) || !H.ce_is_knocked_down_by_blast(EX_ACT_DEVASTATING))
		. += "без защиты: тяжёлый и разрушительный взрыв должны сбивать с ног"
	if(H.ce_is_knocked_down_by_blast(EX_ACT_LIGHT))
		. += "без защиты: лёгкий взрыв сбивает с ног"

	H.lying = TRUE
	var/prone = H.ce_get_concussion_strength(EX_ACT_LIGHT)
	var/prone_knockdown = H.ce_is_knocked_down_by_blast(EX_ACT_HEAVY)
	H.lying = FALSE
	if(abs(prone - light * ce_concussion_prone_mult) > 0.001)
		. += "лёжа: [prone], ожидалось [light * ce_concussion_prone_mult]"
	if(prone_knockdown)
		. += "лёжа: тяжёлый взрыв сбивает с ног"

	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet(H), slot_head)
	var/helmet = H.ce_get_concussion_strength(EX_ACT_LIGHT)
	if(!istype(H.head, /obj/item/clothing/head/helmet) || helmet >= light || helmet <= 0)
		. += "в каске: [helmet], а без защиты [light]"
	if(H.ce_is_knocked_down_by_blast(EX_ACT_HEAVY))
		. += "в каске: тяжёлый взрыв сбивает с ног, хотя по формуле Bay каска его не гасит"

	var/obj/item/old_helmet = H.head
	H.drop_from_inventory(old_helmet)
	qdel(old_helmet)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/bomb_hood(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/bomb_suit(H), slot_wear_suit)
	var/bomb_suit = H.ce_get_concussion_strength(EX_ACT_LIGHT)
	if(!istype(H.wear_suit, /obj/item/clothing/suit/bomb_suit) || bomb_suit >= helmet)
		. += "в костюме сапёра: [bomb_suit], а в каске [helmet]"


/*
	Светошумовая граната (`flashbang_effects.dm`). `bang()` зовётся напрямую, по человеку на клетке
	взрыва, — через весь оверрайд, с оверрайдом `mechs_by_shegar` снаружи.

	- Звук не станит: в сварочных очках вспышка не действует, и стана нет, а замешательство и
	  глухота от звука есть. Выключенный мод — стан Bay, так что проверка не пустая.
	- Каска и защита ушей снимают звуковую часть целиком: ни замешательства, ни глухоты.
	- Вспышка без защиты глаз станит, как в Bay.
	- Граната в левой руке бьёт и обжигает левую кисть, правую не трогает.
*/
/datum/unit_test/combat_extended/flashbang
	name = "CE: Светошумовая граната"

/datum/unit_test/combat_extended/flashbang/start_test()
	var/old_switch = ce_flashbang_enabled
	ce_flashbang_enabled = TRUE
	var/list/failures = list()
	var/goggles = /obj/item/clothing/glasses/welding

	failures += check_bang("звук", list(goggles), FALSE, TRUE)
	failures += check_bang("каска", list(goggles, /obj/item/clothing/head/helmet), FALSE, FALSE)
	failures += check_bang("защита ушей", list(goggles, /obj/item/clothing/ears/earmuffs), FALSE, FALSE)
	failures += check_bang("вспышка", null, TRUE, TRUE)
	failures += check_hand()
	ce_flashbang_enabled = FALSE
	failures += check_bang("выключенный мод, звук Bay", list(goggles), TRUE, TRUE)
	ce_flashbang_enabled = old_switch

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Звук не станит, каска и защита ушей его снимают, вспышка станит, кисть с гранатой ранена, выключатель работает.")
	return 1


/**
 * Взрыв по человеку с вещами `equipment` на его же клетке. Провал, если стан или звуковая часть —
 * замешательство либо глухота — не такие, как ждали. Отдаёт список провалов.
 */
/datum/unit_test/combat_extended/flashbang/proc/check_bang(label, list/equipment, stun_expected, sound_expected)
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		return list("[label]: не удалось создать цель")
	for(var/path in equipment)
		if(!H.equip_to_appropriate_slot(new path(H)))
			return list("[label]: не надеть [path]")
	var/obj/item/grenade/flashbang/grenade = new(get_turf(H))
	spawned += grenade
	grenade.bang(get_turf(H), H)

	var/stunned = H.stunned > 0
	var/sound = H.is_confused() || H.ear_deaf > 0
	if(stunned != stun_expected || sound != sound_expected)
		return list("[label]: стан [H.stunned], замешательство [H.is_confused()], глухота [H.ear_deaf]")
	return list()


/// Граната в левой руке. Отдаёт список провалов.
/datum/unit_test/combat_extended/flashbang/proc/check_hand()
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		return list("не удалось создать цель для руки")
	var/obj/item/grenade/flashbang/grenade = new(get_turf(H))
	spawned += grenade
	if(!H.put_in_l_hand(grenade))
		return list("граната не легла в левую руку")
	grenade.bang(get_turf(H), H)
	var/obj/item/organ/external/left = H.get_organ(BP_L_HAND)
	var/obj/item/organ/external/right = H.get_organ(BP_R_HAND)
	. = list()
	if(left.brute_dam <= 0 || left.burn_dam <= 0)
		. += "левая кисть с гранатой: тупой [left.brute_dam], ожоги [left.burn_dam]"
	if(right.brute_dam || right.burn_dam)
		. += "правая кисть без гранаты ранена: тупой [right.brute_dam], ожоги [right.burn_dam]"


/*
	Парирование с прочностью оружия (`weapon_parry.dm`). Износ и ответный удар зовутся напрямую,
	удар, который оружие встречает слоем брони, — через `ce_on_parried()` и `apply_damage()`, а
	настоящее парирование — через `handle_shield()` и `check_shields()`, с шансом крита 0.

	- Прочность: сталь обычного размера с кромкой — опорные значения; острая растёт корнем из
	  размера, тупая — прямо; лом без кромки вдвое прочнее ножа того же размера; мастер держит лучше
	  неумехи. Материал вещи без своего — главный из `matter`, без него сталь, а HP — как у
	  материального оружия.
	- Износ от кухонного ножа тем меньше, чем больше оружие, ящик не изнашивается вовсе; энергомеч
	  изнашивает клеймор, а кухонный нож — сильнее; ожог и кулак не изнашивают.
	- Слой: ящик по кухонному ножу — в грудь ничего, в руку с ножом меньше половины удара, нож
	  изношен; энергомеч пробивает нож и идёт в грудь слабее, чем без парирования, руке ничего; топор
	  в двух руках делит волну между обеими поровну, вместе столько же, сколько одной; энергомеч волны
	  не даёт. Через `check_shields()` парирование встречает удар слоем, выключенный мод — отбивает
	  целиком.
	- Поломка: материальное — и нож, хотя в Bay он `unbreakable`, — копит дробный износ и
	  раскалывается на нуле, хрупкое — от любого износа; лом до поломки показывает износ при осмотре
	  и ломается на нуле; ящик высыпает содержимое.
	- Не изнашиваются энергомеч и клинок генокрада.
	- Крит: шанс по навыку; при шансе 0 — износ без ответа, при 100 — ответ без износа: за атаку
	  оружием — в зону парирующего, за безоружную — в кисть, которой били.
	- Настоящее парирование энергомеча мечом меч изнашивает, выключенный мод — нет. Байевский бросок
	  на 1 HP против стального ножа выключен.
	- Порез о вещь при обезоруживании выключен, выключенный мод его возвращает.
	- На намерении помощи не парирует даже топор в двух руках, чей бонус Bay прибавляет поверх нуля.
*/

/// Сколько раз пробовать парировать, пока не выйдет. У меча шанс около половины.
#define CE_PARRY_TEST_TRIES 50

/datum/unit_test/combat_extended/weapon_parry
	name = "CE: Парирование с прочностью оружия"

/datum/unit_test/combat_extended/weapon_parry/start_test()
	var/old_switch = ce_parry_enabled
	var/old_crit = ce_parry_crit_chance
	ce_parry_enabled = TRUE
	var/list/failures = list()

	var/mob/living/carbon/human/defender = make_human()
	if(!defender)
		fail("не удалось создать парирующего")
		return 1
	var/turf/T = get_turf(defender)
	failures += check_toughness(T)
	failures += check_wear(T)
	failures += check_breaking(T)
	failures += check_exempt(T)
	failures += check_crits(defender)
	failures += check_real_parry(defender)
	failures += check_layer(T)
	failures += check_disarm(defender)
	failures += check_help_intent(T)

	ce_parry_enabled = old_switch
	ce_parry_crit_chance = old_crit
	for(var/obj/item/material/shard/shard in T)
		qdel(shard)
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Прочность, износ, поломка, исключения, криты, настоящее парирование и порез при обезоруживании — как задумано.")
	return 1


/// Новая вещь в `location`, удаляется в `cleanup()`.
/datum/unit_test/combat_extended/weapon_parry/proc/new_item(path, atom/location, material_key)
	var/obj/item/item = material_key ? new path(location, material_key) : new path(location)
	spawned += item
	return item


/// Ставит человеку навык ближнего боя.
/datum/unit_test/combat_extended/weapon_parry/proc/set_combat_skill(mob/living/carbon/human/H, level)
	var/list/skills = list()
	skills[SKILL_COMBAT] = level
	H.skillset.skill_list = skills


/// Прочность, материал и HP. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_toughness(turf/T)
	. = list()
	var/obj/item/material/knife/kitchen/knife = new_item(/obj/item/material/knife/kitchen, T)
	var/obj/item/material/knife/combat/small = new_item(/obj/item/material/knife/combat, T)
	var/obj/item/material/sword/sword = new_item(/obj/item/material/sword, T)
	var/obj/item/crowbar/crowbar = new_item(/obj/item/crowbar, T)
	var/obj/item/cane/cane = new_item(/obj/item/cane, T)
	var/obj/item/melee/baton/baton = new_item(/obj/item/melee/baton, T)

	var/list/reference = knife.ce_get_parry_toughness(null)
	var/reference_sharp = ce_evaluate_curve(ce_sharp_melee_hard, CE_PARRY_REFERENCE_ARMOR)
	if(abs(reference[1] - reference_sharp) > 0.001 || abs(reference[2] - ce_parry_blunt_toughness) > 0.001)
		. += "стальной кухонный нож: прочность [reference[1]] мм / [reference[2]], ожидалось [reference_sharp] / [ce_parry_blunt_toughness]"

	// Боевой нож маленький, клеймор большой: острая — корень из 0.5 и 2, тупая — сами 0.5 и 2.
	var/list/small_toughness = small.ce_get_parry_toughness(null)
	var/list/sword_toughness = sword.ce_get_parry_toughness(null)
	if(abs(small_toughness[1] - reference[1] * sqrt(0.5)) > 0.001 || abs(sword_toughness[1] - reference[1] * sqrt(2)) > 0.001)
		. += "острая прочность: боевой нож [small_toughness[1]], кухонный [reference[1]], клеймор [sword_toughness[1]] — должна расти корнем из размера"
	if(abs(small_toughness[2] - reference[2] * 0.5) > 0.001 || abs(sword_toughness[2] - reference[2] * 2) > 0.001)
		. += "тупая прочность: боевой нож [small_toughness[2]], кухонный [reference[2]], клеймор [sword_toughness[2]] — должна расти с размером прямо"
	var/list/crowbar_toughness = crowbar.ce_get_parry_toughness(null)
	if(abs(crowbar_toughness[1] - reference[1] * ce_parry_blunt_weapon_mult) > 0.001 || abs(crowbar_toughness[2] - reference[2] * ce_parry_blunt_weapon_mult) > 0.001)
		. += "лом без кромки: [crowbar_toughness[1]] / [crowbar_toughness[2]], а кухонный нож того же размера — [reference[1]] / [reference[2]]"

	var/mob/living/carbon/human/H = make_human()
	set_combat_skill(H, SKILL_MASTER)
	var/list/master = knife.ce_get_parry_toughness(H)
	set_combat_skill(H, SKILL_UNSKILLED)
	var/list/unskilled = knife.ce_get_parry_toughness(H)
	if(!(unskilled[1] < reference[1] && reference[1] < master[1]))
		. += "навык: неумеха [unskilled[1]], обученный [reference[1]], мастер [master[1]]"

	var/list/expected_materials = list(
		"лом" = list(crowbar, MATERIAL_STEEL),
		"трость" = list(cane, MATERIAL_ALUMINIUM),
		"дубинка без matter" = list(baton, MATERIAL_STEEL)
	)
	for(var/label in expected_materials)
		var/list/entry = expected_materials[label]
		var/obj/item/item = entry[1]
		var/material/material = item.ce_get_parry_material()
		if(material?.name != entry[2])
			. += "[label]: материал [material?.name], ожидался [entry[2]]"
	if(crowbar.ce_get_parry_health_max() != knife.get_max_health())
		. += "HP стального лома [crowbar.ce_get_parry_health_max()], а стального ножа — [knife.get_max_health()]"


/// Износ от разных атак. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_wear(turf/T)
	. = list()
	var/obj/item/material/knife/kitchen/knife = new_item(/obj/item/material/knife/kitchen, T)
	var/obj/item/material/knife/combat/small = new_item(/obj/item/material/knife/combat, T)
	var/obj/item/material/sword/sword = new_item(/obj/item/material/sword, T)
	var/obj/item/material/knife/kitchen/attack_knife = new_item(/obj/item/material/knife/kitchen, T)
	var/obj/item/melee/energy/sword/esword = new_item(/obj/item/melee/energy/sword, T)
	esword.activate()
	var/obj/item/storage/toolbox/mechanical/toolbox = new_item(/obj/item/storage/toolbox/mechanical, T)
	spawned += toolbox.contents.Copy()

	var/small_from_knife = small.ce_get_parry_wear(null, attack_knife.force, attack_knife)
	var/knife_from_knife = knife.ce_get_parry_wear(null, attack_knife.force, attack_knife)
	var/sword_from_knife = sword.ce_get_parry_wear(null, attack_knife.force, attack_knife)
	var/toolbox_from_knife = toolbox.ce_get_parry_wear(null, attack_knife.force, attack_knife)
	if(!(small_from_knife > knife_from_knife && knife_from_knife > sword_from_knife && sword_from_knife > 0) || toolbox_from_knife != 0)
		. += "кухонный нож: износ боевого ножа [small_from_knife], кухонного [knife_from_knife], клеймора [sword_from_knife], ящика [toolbox_from_knife] — должен падать с размером до нуля"
	var/sword_from_esword = sword.ce_get_parry_wear(null, esword.force, esword)
	var/knife_from_esword = knife.ce_get_parry_wear(null, esword.force, esword)
	if(!(0 < sword_from_esword && sword_from_esword < knife_from_esword))
		. += "энергомеч: износ меча [sword_from_esword], кухонного ножа [knife_from_esword]"

	var/obj/item/material/knife/kitchen/hot_knife = new_item(/obj/item/material/knife/kitchen, T)
	hot_knife.damtype = DAMAGE_BURN
	var/burn_wear = knife.ce_get_parry_wear(null, hot_knife.force, hot_knife)
	var/fist_wear = sword.ce_get_parry_wear(null, 5, null)
	if(burn_wear || fist_wear)
		. += "ожог износил нож на [burn_wear], кулак меч — на [fist_wear]"


/// Дробный износ, поломка, осмотр и содержимое ящика. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_breaking(turf/T)
	. = list()
	var/obj/item/material/knife/kitchen/knife = new_item(/obj/item/material/knife/kitchen, T)
	var/health_max = knife.get_max_health()
	knife.ce_apply_parry_wear(0.4)
	knife.ce_apply_parry_wear(0.4)
	var/after_two = knife.get_current_health()
	knife.ce_apply_parry_wear(0.4)
	var/after_three = knife.get_current_health()
	if(after_two != health_max || after_three != health_max - 1)
		. += "дробный износ ножа: после 0.8 — [after_two], после 1.2 — [after_three] из [health_max]"
	knife.ce_apply_parry_wear(health_max)
	if(!QDELETED(knife))
		. += "нож на нуле HP не раскололся"

	var/obj/item/material/knife/kitchen/glass = new_item(/obj/item/material/knife/kitchen, T, MATERIAL_GLASS)
	glass.ce_apply_parry_wear(0.1)
	if(!QDELETED(glass))
		. += "стеклянный нож не раскололся от износа"

	var/obj/item/crowbar/crowbar = new_item(/obj/item/crowbar, T)
	crowbar.ce_apply_parry_wear(crowbar.ce_get_parry_health_max() / 2)
	if(QDELETED(crowbar) || !crowbar.ce_get_parry_examine_line())
		. += "лом на половине HP сломан или не показывает износ при осмотре"
	crowbar.ce_apply_parry_wear(crowbar.ce_get_parry_health_max())
	if(!QDELETED(crowbar))
		. += "лом на нуле HP не сломался"

	var/obj/item/storage/toolbox/mechanical/toolbox = new_item(/obj/item/storage/toolbox/mechanical, T)
	var/list/tools = toolbox.contents.Copy()
	spawned += tools
	toolbox.ce_apply_parry_wear(toolbox.ce_get_parry_health_max())
	if(!QDELETED(toolbox) || !length(tools))
		. += "ящик на нуле HP не сломался, или в нём не было инструментов"
	for(var/obj/item/tool in tools)
		if(QDELETED(tool) || tool.loc != T)
			. += "из сломанного ящика не выпал [tool]"


/// Что не изнашивается. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_exempt(turf/T)
	. = list()
	var/obj/item/melee/energy/sword/esword = new_item(/obj/item/melee/energy/sword, T)
	esword.ce_apply_parry_wear(1000)
	if(QDELETED(esword) || !isnull(esword.ce_parry_health))
		. += "энергомеч износился"
	var/obj/item/melee/changeling/arm_blade/blade_type = /obj/item/melee/changeling/arm_blade
	if(!initial(blade_type.ce_parry_unbreakable))
		. += "клинок генокрада не помечен неломающимся"


/// Шанс крита и два его броска. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_crits(mob/living/carbon/human/defender)
	. = list()
	var/turf/T = get_turf(defender)
	var/mob/living/carbon/human/attacker = make_human()
	set_combat_skill(defender, SKILL_MASTER)
	set_combat_skill(attacker, SKILL_UNSKILLED)
	var/skilled = ce_get_parry_crit_chance(defender, attacker)
	set_combat_skill(defender, SKILL_TRAINED)
	set_combat_skill(attacker, SKILL_TRAINED)
	var/equal = ce_get_parry_crit_chance(defender, attacker)
	var/expected_skilled = ce_parry_crit_chance + (SKILL_MASTER - SKILL_UNSKILLED) * ce_parry_crit_chance_per_skill
	if(equal != ce_parry_crit_chance || skilled != expected_skilled)
		. += "шанс крита: при равном навыке [equal], мастер против неумехи [skilled], ожидалось [ce_parry_crit_chance] и [expected_skilled]"

	var/obj/item/melee/energy/sword/esword = new_item(/obj/item/melee/energy/sword, T)
	esword.activate()

	ce_parry_crit_chance = 0
	var/obj/item/material/sword/worn = new_item(/obj/item/material/sword, T)
	worn.ce_on_parried(defender, esword.force, esword, attacker)
	if(worn.get_current_health() >= worn.get_max_health() || attacker.getBruteLoss())
		. += "крит 0: меч [worn.get_current_health()] из [worn.get_max_health()], атакующему [attacker.getBruteLoss()] урона"

	ce_parry_crit_chance = 100
	var/obj/item/material/sword/riposting = new_item(/obj/item/material/sword, T)
	riposting.ce_on_parried(defender, esword.force, esword, attacker)
	var/obj/item/organ/external/aimed = attacker.get_organ(ce_get_riposte_zone(defender))
	if(riposting.get_current_health() < riposting.get_max_health() || !aimed?.brute_dam)
		. += "крит 100, атака оружием: меч [riposting.get_current_health()] из [riposting.get_max_health()], зона ответа [aimed?.organ_tag] — [aimed?.brute_dam]"

	// Навык как у парирующего: у нового человека он выше, и разница срезала бы шанс крита со 100.
	var/mob/living/carbon/human/boxer = make_human()
	set_combat_skill(boxer, SKILL_TRAINED)
	boxer.hand = 1
	riposting.ce_on_parried(defender, 5, null, boxer)
	var/obj/item/organ/external/left = boxer.get_organ(BP_L_HAND)
	var/obj/item/organ/external/right = boxer.get_organ(BP_R_HAND)
	if(!left.brute_dam || right.brute_dam)
		. += "крит 100, кулак левой: левая кисть [left.brute_dam], правая [right.brute_dam]"


/// Настоящее парирование через `handle_shield()`, с шансом крита 0. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_real_parry(mob/living/carbon/human/defender)
	. = list()
	var/turf/T = get_turf(defender)
	var/mob/living/carbon/human/attacker = make_human()
	var/obj/item/melee/energy/sword/esword = new_item(/obj/item/melee/energy/sword, T)
	esword.activate()
	defender.a_intent = I_HURT
	ce_parry_crit_chance = 0

	var/obj/item/material/sword/sword = new_item(/obj/item/material/sword, T)
	if(!parry_once(sword, defender, esword, attacker))
		. += "меч ни разу не парировал энергомеч за [CE_PARRY_TEST_TRIES] попыток"
	else if(sword.get_current_health() >= sword.get_max_health())
		. += "настоящее парирование энергомеча не износило меч"

	// Бросок Bay снимал бы 1 HP с шансом 60% на каждое парирование стального ножа. Топор в двух
	// руках слишком велик, чтобы боевой нож износил его по правилам мода.
	var/obj/item/material/knife/combat/small_knife = new_item(/obj/item/material/knife/combat, T)
	var/obj/item/material/twohanded/fireaxe/steady = new_item(/obj/item/material/twohanded/fireaxe, T)
	steady.wielded = TRUE
	for(var/i in 1 to 10)
		parry_once(steady, defender, small_knife, attacker)
	if(steady.get_current_health() < steady.get_max_health())
		. += "топор износился от стального ножа: [steady.get_current_health()] из [steady.get_max_health()] — остался бросок Bay"

	ce_parry_enabled = FALSE
	var/obj/item/material/sword/bay_sword = new_item(/obj/item/material/sword, T)
	if(!parry_once(bay_sword, defender, esword, attacker))
		. += "выключенный мод: меч ни разу не парировал"
	else if(bay_sword.get_current_health() < bay_sword.get_max_health())
		. += "выключенный мод: энергомеч износил меч, а в Bay оружие изнашивает только материальное"
	ce_parry_enabled = TRUE


/// Парирует атаку, пока не выйдет. TRUE — вышло.
/datum/unit_test/combat_extended/weapon_parry/proc/parry_once(obj/item/weapon, mob/living/carbon/human/defender, obj/item/attack_weapon, mob/living/carbon/human/attacker)
	for(var/i in 1 to CE_PARRY_TEST_TRIES)
		if(weapon.handle_shield(defender, attack_weapon.force, attack_weapon, attacker, BP_CHEST, "the test"))
			return TRUE
	return FALSE


/// Удар, который оружие встречает первым слоем брони. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_layer(turf/T)
	. = list()
	ce_parry_crit_chance = 0
	var/obj/item/storage/toolbox/mechanical/toolbox = new_item(/obj/item/storage/toolbox/mechanical, T)
	spawned += toolbox.contents.Copy()
	var/obj/item/melee/energy/sword/esword = new_item(/obj/item/melee/energy/sword, T)
	esword.activate()
	var/obj/item/material/twohanded/fireaxe/attack_axe = new_item(/obj/item/material/twohanded/fireaxe, T)
	attack_axe.force = attack_axe.force_wielded

	var/list/blunt = parry_layer(/obj/item/material/knife/kitchen, toolbox)
	if(!blunt)
		. += "ящик по кухонному ножу: парирование не встретило удар слоем"
	else
		var/mob/living/carbon/human/H = blunt[1]
		hit_chest(H, toolbox)
		var/obj/item/material/knife/kitchen/knife = blunt[2]
		var/chest = brute_of(H, BP_CHEST)
		var/arm = brute_of(H, BP_R_ARM)
		if(chest || arm <= 0 || arm >= toolbox.force / 2 || brute_of(H, BP_L_ARM))
			. += "ящик по кухонному ножу: грудь [chest], правая рука [arm], левая [brute_of(H, BP_L_ARM)]"
		if(knife.get_current_health() >= knife.get_max_health() || H.ce_shield_hit)
			. += "ящик по кухонному ножу: нож [knife.get_current_health()] из [knife.get_max_health()], попадание забрано — [!H.ce_shield_hit]"

	// Сколько энергомеча доходит до груди, считает проход по слоям: урон груди сравнивать нельзя,
	// без парирования клинок дотягивается до органов и часть урона оставляет там.
	var/list/pierced = parry_layer(/obj/item/material/knife/kitchen, esword)
	var/mob/living/carbon/human/unparried = make_human()
	var/list/bare = unparried.ce_walk_armor_layers(BP_CHEST, esword.force, esword.damtype, esword.damage_flags(), esword.armor_penetration)
	if(!pierced)
		. += "энергомеч по кухонному ножу: парирование не встретило удар слоем"
	else
		var/mob/living/carbon/human/H = pierced[1]
		var/list/through = H.ce_walk_armor_layers(BP_CHEST, esword.force, esword.damtype, esword.damage_flags(), esword.armor_penetration)
		if(!(through[1] > 0 && through[1] < bare[1]) || !ce_is_sharp_attack(through[2]))
			. += "энергомеч сквозь кухонный нож: до груди доходит [through[1]] (острым — [ce_is_sharp_attack(through[2])]), без парирования [bare[1]]"
		hit_chest(H, esword)
		if(brute_of(H, BP_CHEST) <= 0 || brute_of(H, BP_R_ARM))
			. += "энергомеч сквозь кухонный нож: грудь [brute_of(H, BP_CHEST)], правая рука [brute_of(H, BP_R_ARM)]"

	var/list/two_handed = parry_layer(/obj/item/material/twohanded/fireaxe, attack_axe, TRUE)
	var/list/one_handed = parry_layer(/obj/item/material/twohanded/fireaxe, attack_axe)
	if(!two_handed || !one_handed)
		. += "топор по топору: парирование не встретило удар слоем"
	else
		var/mob/living/carbon/human/H = two_handed[1]
		var/mob/living/carbon/human/single = one_handed[1]
		hit_chest(H, attack_axe)
		hit_chest(single, attack_axe)
		var/left = brute_of(H, BP_L_ARM)
		var/right = brute_of(H, BP_R_ARM)
		var/single_arm = brute_of(single, BP_R_ARM)
		if(left <= 0 || abs(left - right) > 0.001 || abs(left + right - single_arm) > 0.01 || brute_of(H, BP_CHEST))
			. += "топор по топору в двух руках: левая рука [left], правая [right], одной рукой [single_arm], грудь [brute_of(H, BP_CHEST)]"

	var/list/field = parry_layer(/obj/item/melee/energy/sword, toolbox, FALSE, TRUE)
	if(!field)
		. += "ящик по энергомечу: парирование не встретило удар слоем"
	else
		var/mob/living/carbon/human/H = field[1]
		hit_chest(H, toolbox)
		if(brute_of(H, BP_R_ARM) || brute_of(H, BP_CHEST))
			. += "ящик по энергомечу: правая рука [brute_of(H, BP_R_ARM)], грудь [brute_of(H, BP_CHEST)] — энергомеч волны не даёт"

	. += check_layer_through_shields(toolbox)


/**
 * Свежий человек держит оружие `weapon_path` в правой руке и парирует им удар `attack_weapon` в
 * грудь. `wielded` — в двух руках, `activate` — включить энергомеч. Отдаёт `list(человек, оружие)`,
 * null — оружие не встретило удар слоем.
 */
/datum/unit_test/combat_extended/weapon_parry/proc/parry_layer(weapon_path, obj/item/attack_weapon, wielded = FALSE, activate = FALSE)
	var/mob/living/carbon/human/H = make_human()
	// Двуручное оружие Bay само берёт в обе руки, пока вторая свободна: занятая левая рука держит
	// его в одной.
	if(!wielded)
		H.put_in_l_hand(new_item(/obj/item/pen, get_turf(H)))
	var/obj/item/weapon = new_item(weapon_path, get_turf(H))
	if(!H.put_in_r_hand(weapon))
		return null
	if(wielded)
		var/obj/item/material/twohanded/two_handed = weapon
		two_handed.wielded = TRUE
	if(activate)
		var/obj/item/melee/energy/energy = weapon
		energy.activate()
	H.ce_shield_armor_call = TRUE
	var/blocked = weapon.ce_on_parried(H, attack_weapon.force, attack_weapon, null, BP_CHEST, "the test")
	H.ce_shield_armor_call = FALSE
	if(blocked || !istype(H.ce_shield_hit, /datum/ce_shield_hit/parry))
		return null
	return list(H, weapon)


/// Удар оружием `attack_weapon` в грудь, настоящим `apply_damage()`.
/datum/unit_test/combat_extended/weapon_parry/proc/hit_chest(mob/living/carbon/human/H, obj/item/attack_weapon)
	H.apply_damage(attack_weapon.force, attack_weapon.damtype, BP_CHEST, attack_weapon.damage_flags(), attack_weapon, attack_weapon.armor_penetration)


/// Тупой урон органа `organ_tag` у человека, 0 — органа нет.
/datum/unit_test/combat_extended/weapon_parry/proc/brute_of(mob/living/carbon/human/H, organ_tag)
	var/obj/item/organ/external/organ = H.get_organ(organ_tag)
	return organ ? organ.brute_dam : 0


/// Парирование через `check_shields()`: встречает удар слоем, выключенный мод — отбивает целиком.
/datum/unit_test/combat_extended/weapon_parry/proc/check_layer_through_shields(obj/item/attack_weapon)
	. = list()
	var/mob/living/carbon/human/H = make_human()
	var/mob/living/carbon/human/attacker = make_human()
	var/obj/item/material/sword/sword = new_item(/obj/item/material/sword, get_turf(H))
	H.put_in_r_hand(sword)
	H.a_intent = I_HURT

	var/list/outcome = parry_through_shields(H, attack_weapon, attacker)
	if(!outcome[1])
		. += "check_shields(): клеймор ни разу не парировал за [CE_PARRY_TEST_TRIES] попыток"
	else if(outcome[2] || !istype(H.ce_shield_hit, /datum/ce_shield_hit/parry))
		. += "check_shields(): парирование отбило удар целиком ([outcome[2]]) вместо слоя брони"
	H.ce_shield_hit = null

	ce_parry_enabled = FALSE
	outcome = parry_through_shields(H, attack_weapon, attacker)
	if(!outcome[1] || outcome[2] != 1 || H.ce_shield_hit)
		. += "выключенный мод: check_shields() — парирование [outcome[1]], итог [outcome[2]], слой [H.ce_shield_hit]"
	H.ce_shield_hit = null
	ce_parry_enabled = TRUE


/**
 * Зовёт `check_shields()` с ударом оружием `attack_weapon`, пока оружие в руке не парирует.
 * Отдаёт `list(парировало ли, что вернула check_shields())`.
 */
/datum/unit_test/combat_extended/weapon_parry/proc/parry_through_shields(mob/living/carbon/human/H, obj/item/attack_weapon, mob/living/carbon/human/attacker)
	for(var/i in 1 to CE_PARRY_TEST_TRIES)
		H.ce_shield_armor_call = TRUE
		var/result = H.check_shields(attack_weapon.force, attack_weapon, attacker, BP_CHEST, "the test")
		H.ce_shield_armor_call = FALSE
		if(result || H.ce_shield_hit)
			return list(TRUE, result)
	return list(FALSE, 0)


/// Порез о вещь при обезоруживании. Отдаёт список провалов.
/datum/unit_test/combat_extended/weapon_parry/proc/check_disarm(mob/living/carbon/human/defender)
	. = list()
	var/turf/T = get_turf(defender)
	var/mob/living/carbon/human/attacker = make_human()
	attacker.hand = 0
	var/obj/item/material/knife/kitchen/knife = new_item(/obj/item/material/knife/kitchen, T)
	var/obj/item/organ/external/hand = attacker.get_organ(BP_R_HAND)
	if(knife.on_disarm_attempt(defender, attacker) || hand.brute_dam)
		. += "порез о нож при обезоруживании не выключен: кисть [hand.brute_dam]"
	ce_parry_enabled = FALSE
	if(!knife.on_disarm_attempt(defender, attacker) || !hand.brute_dam)
		. += "выключенный мод: пореза Bay при обезоруживании нет"
	ce_parry_enabled = TRUE

/**
 * На намерении помощи оружие не парирует. Топор в двух руках — потому что Bay прибавляет его бонус
 * к шансу уже после того, как намерение помощи его обнулило. Отдаёт список провалов.
 */
/datum/unit_test/combat_extended/weapon_parry/proc/check_help_intent(turf/T)
	. = list()
	var/mob/living/carbon/human/H = make_human()
	var/mob/living/carbon/human/attacker = make_human()
	var/obj/item/material/twohanded/fireaxe/axe = new_item(/obj/item/material/twohanded/fireaxe, T)
	var/obj/item/material/knife/kitchen/attack_knife = new_item(/obj/item/material/knife/kitchen, T)
	H.put_in_r_hand(axe)
	axe.wielded = TRUE
	H.a_intent = I_HELP
	if(parry_once(axe, H, attack_knife, attacker))
		. += "на намерении помощи топор в двух руках парирует"
	ce_parry_enabled = FALSE
	if(!parry_once(axe, H, attack_knife, attacker))
		. += "выключенный мод: на намерении помощи топор в двух руках не парирует — проверять нечего"
	ce_parry_enabled = TRUE

#undef CE_PARRY_TEST_TRIES


/*
	Выстрел при обезоруживании (`disarm_gunfire.dm`). Исходы бросков задаются шансами из настроек: 0
	и 100, а для «реакция выиграна, борьба проиграна» — навыками при крутом сдвиге за уровень.

	- Шансы: при равных навыках — базовые, около половины; мастер обоих навыков против неумехи
	  стреляет в него больше чем в 75% попыток, наоборот — меньше чем в 25%. Навык стрельбы
	  держащего двигает только реакцию, его ближний бой — только борьбу.
	- Исходы: реакция проиграна — спуск не нажат; обе выиграны — выстрел в упор, обезоруживающий
	  ранен; борьба проиграна — ружьё отведено.
	- Не стреляет на намерении помощи и на предохранителе.
	- Через `disarm_attackhand()` выстрел в упор заканчивает попытку: ружьё остаётся в руке.
	- Бросок Bay на ружьё выключен; выключенный мод выстрел мода не бросает.
*/
/datum/unit_test/combat_extended/disarm_gunfire
	name = "CE: Выстрел при обезоруживании"

/datum/unit_test/combat_extended/disarm_gunfire/start_test()
	var/old_switch = ce_disarm_gunfire_enabled
	var/old_chance = ce_disarm_gunfire_chance
	var/old_per_skill = ce_disarm_gunfire_chance_per_skill
	ce_disarm_gunfire_enabled = TRUE
	var/list/failures = list()

	failures += check_chances()
	failures += check_outcomes()
	ce_disarm_gunfire_chance = old_chance
	ce_disarm_gunfire_chance_per_skill = old_per_skill
	failures += check_disarm_hook()
	ce_disarm_gunfire_enabled = old_switch
	ce_disarm_gunfire_chance = old_chance
	ce_disarm_gunfire_chance_per_skill = old_per_skill

	// Ружьё удаляется раньше держащего: удалённый человек сначала теряет навыки, а потом роняет
	// ружьё, и проверка неосторожного выстрела при падении читает навык у пустоты.
	for(var/obj/item/gun/gun in spawned)
		qdel(gun)
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Шансы по навыкам, исходы бросков, намерение помощи, предохранитель и обезоруживание — как задумано.")
	return 1


/// Шансы двух бросков по навыкам. Отдаёт список провалов.
/datum/unit_test/combat_extended/disarm_gunfire/proc/check_chances()
	. = list()
	var/mob/living/carbon/human/holder = make_human()
	var/mob/living/carbon/human/disarmer = make_human()
	var/base = ce_disarm_gunfire_chance

	set_skills(holder, list(SKILL_WEAPONS = SKILL_MASTER, SKILL_COMBAT = SKILL_MASTER))
	set_skills(disarmer, list(SKILL_WEAPONS = SKILL_MASTER, SKILL_COMBAT = SKILL_MASTER))
	var/list/equal = ce_get_disarm_gunfire_chances(holder, disarmer)
	if(equal[1] != base || equal[2] != base || abs(base - 50) > 10)
		. += "мастер против мастера: [equal[1]] и [equal[2]], база [base] — ожидалось около половины"

	set_skills(disarmer, list(SKILL_WEAPONS = SKILL_UNSKILLED, SKILL_COMBAT = SKILL_UNSKILLED))
	var/list/master = ce_get_disarm_gunfire_chances(holder, disarmer)
	if(master[1] * master[2] <= 7500)
		. += "мастер против неумехи: [master[1]] и [master[2]] — выстрел в обезоруживающего должен быть чаще 75%"
	var/list/novice = ce_get_disarm_gunfire_chances(disarmer, holder)
	if(novice[1] * novice[2] >= 2500)
		. += "неумеха против мастера: [novice[1]] и [novice[2]] — выстрел должен быть реже 25%"

	set_skills(holder, list(SKILL_WEAPONS = SKILL_MASTER, SKILL_COMBAT = SKILL_TRAINED))
	set_skills(disarmer, list(SKILL_WEAPONS = SKILL_TRAINED, SKILL_COMBAT = SKILL_TRAINED))
	var/list/marksman = ce_get_disarm_gunfire_chances(holder, disarmer)
	if(!(marksman[1] > base && marksman[2] == base))
		. += "стрелок-мастер, в ближнем бою обученный: [marksman[1]] и [marksman[2]] — навык стрельбы должен двигать только реакцию"
	set_skills(holder, list(SKILL_WEAPONS = SKILL_TRAINED, SKILL_COMBAT = SKILL_MASTER))
	var/list/brawler = ce_get_disarm_gunfire_chances(holder, disarmer)
	if(!(brawler[1] == base && brawler[2] > base))
		. += "боец-мастер, стрелок обученный: [brawler[1]] и [brawler[2]] — ближний бой держащего должен двигать только борьбу"


/// Исходы бросков, намерение помощи и предохранитель. Отдаёт список провалов.
/datum/unit_test/combat_extended/disarm_gunfire/proc/check_outcomes()
	. = list()
	var/list/pair = armed_pair()
	if(!pair)
		return list("не удалось вооружить держащего")
	var/mob/living/carbon/human/holder = pair[1]
	var/mob/living/carbon/human/disarmer = pair[2]
	var/obj/item/gun/gun = pair[3]

	force_chances(0)
	var/lost_reaction = gun.ce_disarm_gunfire(holder, disarmer)
	if(lost_reaction != CE_DISARM_GUNFIRE_NONE)
		. += "реакция проиграна: исход [lost_reaction], а спуск не должен быть нажат"

	force_chances(100)
	holder.a_intent = I_HELP
	var/helping = gun.ce_disarm_gunfire(holder, disarmer)
	holder.a_intent = I_HURT
	gun.safety_state = TRUE
	var/safe = gun.ce_disarm_gunfire(holder, disarmer)
	gun.safety_state = FALSE
	if(helping != CE_DISARM_GUNFIRE_NONE || safe != CE_DISARM_GUNFIRE_NONE)
		. += "на намерении помощи исход [helping], на предохранителе — [safe]: ружьё не должно стрелять"

	var/won = gun.ce_disarm_gunfire(holder, disarmer)
	if(won != CE_DISARM_GUNFIRE_DISARMER || disarmer.getFireLoss() <= 0)
		. += "обе выиграны: исход [won], ожоги обезоруживающего [disarmer.getFireLoss()]"

	// Реакция — стрельба мастера против обученного, борьба — ближний бой неумехи против обученного:
	// при сдвиге 50% за уровень это 100% и 0%.
	ce_disarm_gunfire_chance = 50
	ce_disarm_gunfire_chance_per_skill = 50
	set_skills(holder, list(SKILL_WEAPONS = SKILL_MASTER, SKILL_COMBAT = SKILL_UNSKILLED))
	set_skills(disarmer, list(SKILL_WEAPONS = SKILL_TRAINED, SKILL_COMBAT = SKILL_TRAINED))
	gun.next_fire_time = 0
	var/lost_struggle = gun.ce_disarm_gunfire(holder, disarmer)
	if(lost_struggle != CE_DISARM_GUNFIRE_STRAY)
		. += "борьба проиграна: исход [lost_struggle], а ружьё должно быть отведено"

	// Бросок Bay стреляет в клетку из поля зрения `usr`, а в тесте его нет: без него он молчал бы
	// и невыключенный.
	usr = holder
	gun.next_fire_time = 0
	if(gun.on_disarm_attempt(holder, disarmer))
		. += "бросок Bay на ружьё не выключен"
	usr = null


/// Выстрел через само обезоруживание. Отдаёт список провалов.
/datum/unit_test/combat_extended/disarm_gunfire/proc/check_disarm_hook()
	. = list()
	var/list/pair = armed_pair()
	if(!pair)
		return list("не удалось вооружить держащего для обезоруживания")
	var/mob/living/carbon/human/holder = pair[1]
	var/mob/living/carbon/human/disarmer = pair[2]
	var/obj/item/gun/gun = pair[3]

	force_chances(100)
	disarmer.species.disarm_attackhand(disarmer, holder)
	if(disarmer.getFireLoss() <= 0 || holder.get_active_hand() != gun)
		. += "обезоруживание при выигранных бросках: ожоги обезоруживающего [disarmer.getFireLoss()], ружьё в руке — [holder.get_active_hand() == gun]"

	// Обезоруживание Sierra читает выбранную зону, а у человека без клиента её нет.
	ce_disarm_gunfire_enabled = FALSE
	disarmer.zone_sel = new /obj/screen/zone_sel(null)
	spawned += disarmer.zone_sel
	var/burn_before = disarmer.getFireLoss()
	gun.next_fire_time = 0
	disarmer.species.disarm_attackhand(disarmer, holder)
	if(disarmer.getFireLoss() > burn_before)
		. += "выключенный мод: обезоруживание выстрелило в упор"
	ce_disarm_gunfire_enabled = TRUE


/**
 * Держащий на намерении вреда с лазерной винтовкой без предохранителя в активной руке и
 * обезоруживающий рядом. Отдаёт `list(держащий, обезоруживающий, ружьё)`, null — не вышло.
 */
/datum/unit_test/combat_extended/disarm_gunfire/proc/armed_pair()
	var/mob/living/carbon/human/holder = make_human()
	var/mob/living/carbon/human/disarmer = make_human()
	var/obj/item/gun/energy/laser/gun = new(get_turf(holder))
	spawned += gun
	if(!holder.put_in_active_hand(gun))
		return null
	gun.safety_state = FALSE
	holder.a_intent = I_HURT
	set_skills(holder, list(SKILL_WEAPONS = SKILL_MASTER, SKILL_COMBAT = SKILL_MASTER))
	set_skills(disarmer, list(SKILL_WEAPONS = SKILL_MASTER, SKILL_COMBAT = SKILL_MASTER))
	return list(holder, disarmer, gun)


/// Оба броска с шансом `chance` при любых навыках.
/datum/unit_test/combat_extended/disarm_gunfire/proc/force_chances(chance)
	ce_disarm_gunfire_chance = chance
	ce_disarm_gunfire_chance_per_skill = 0


/*
	Форма формулы износа §8. Жёсткая броня теряет больше всего на попадании у самой
	границы пробития: ниже неё износ растёт с пробитием, выше — падает, потому что атака уходит
	навылет. Урон после слоя считается так же, как в `ce_try_penetrate()`.
*/
/datum/unit_test/combat_extended/armor_wear_formula
	name = "CE: Форма формулы износа"

/datum/unit_test/combat_extended/armor_wear_formula/start_test()
	var/list/failures = list()
	var/damage = 40
	var/armor_value = 10

	var/previous = 0
	var/peak_pen = 0
	var/peak_wear = 0
	for(var/i in 1 to 100)
		var/pen = i * 0.5
		var/new_damage = damage * clamp((pen - armor_value) / pen, 0, 1)
		var/wear = ce_armor_wear_amount(damage, new_damage, pen, armor_value, TRUE, TRUE)
		var/rising = pen <= armor_value
		if((rising && wear < previous) || (!rising && wear > previous))
			failures += "жёсткая, острое: при пробитии [pen] износ [wear] после [previous]"
		if(wear > peak_wear)
			peak_wear = wear
			peak_pen = pen
		previous = wear
	if(peak_pen != armor_value)
		failures += "жёсткая, острое: максимум износа при пробитии [peak_pen], а не [armor_value]"

	if(ce_armor_wear_amount(damage, 0, armor_value * 0.49, armor_value, FALSE, TRUE) != 0)
		failures += "жёсткая: тупое слабее половины рейтинга изнашивает"
	if(ce_armor_wear_amount(damage, 0, armor_value * 0.5, armor_value, FALSE, TRUE) <= 0)
		failures += "жёсткая: тупое в половину рейтинга не изнашивает"
	if(ce_armor_wear_amount(damage, 0, armor_value * 0.1, armor_value, TRUE, TRUE) <= 0)
		failures += "жёсткая: слабое острое не изнашивает, а упругим бывает только тупое"
	if(ce_armor_wear_amount(damage, damage, 0, armor_value, TRUE, TRUE) != 0 || ce_armor_wear_amount(damage, damage, armor_value, 0, TRUE, TRUE) != 0)
		failures += "жёсткая: нулевое пробитие или нулевой рейтинг изнашивают"

	// Мягкая: весь остановленный урон, но не меньше пятой части урона до слоя.
	for(var/new_damage in list(0, damage * 0.5, damage * 0.9, damage))
		var/wear = ce_armor_wear_amount(damage, new_damage, armor_value, armor_value, TRUE, FALSE)
		var/expected = max(damage / 5, damage - new_damage)
		if(abs(wear - expected) > 0.0001)
			failures += "мягкая, острое: при уроне после слоя [new_damage] износ [wear], ожидалось [expected]"
	if(ce_armor_wear_amount(damage, 0, armor_value, armor_value, FALSE, FALSE) != 0)
		failures += "мягкая: тупое изнашивает"

	if(ce_get_wear_mult(DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP) != 1)
		failures += "множитель: пуля изнашивает не по формуле"
	if(ce_get_wear_mult(DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE) != ce_armor_melee_wear_mult || ce_get_wear_mult(FLAGS_OFF) != ce_armor_melee_wear_mult)
		failures += "множитель: холодное изнашивает без множителя"

	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Максимум у границы пробития, нули упругого и мягкого тупого, пятая часть у мягкой.")
	return 1


/*
	Кривая состояния §4: рейтинг не растёт при потере HP, полный до 95% и неполный ниже.
	Новая броня читается целой, изношенная — через кривую по всем ключам.
*/
/datum/unit_test/combat_extended/armor_wear_curve
	name = "CE: Кривая состояния брони"

/datum/unit_test/combat_extended/armor_wear_curve/start_test()
	var/old_switch = ce_armor_wear_enabled
	ce_armor_wear_enabled = TRUE
	var/list/failures = list()

	var/previous = 0
	for(var/percent in 0 to 100)
		var/condition = ce_evaluate_curve(ce_armor_condition_curve, percent / 100)
		if(condition < previous || condition > 1)
			failures += "кривая: при [percent]% HP множитель [condition] после [previous]"
		if(percent >= 95 && condition != 1)
			failures += "кривая: при [percent]% HP рейтинг не полный, [condition]"
		if(percent < 95 && condition >= 1)
			failures += "кривая: при [percent]% HP рейтинг ещё полный"
		previous = condition
	if(ce_evaluate_curve(ce_armor_condition_curve, 0) != 0)
		failures += "кривая: при 0 HP рейтинг не ноль"

	var/obj/item/clothing/accessory/armor_plate/medium/plate = new
	spawned += plate
	var/datum/extension/armor/armor = get_extension(plate, /datum/extension/armor)
	for(var/key in armor.armor_values)
		if(armor.get_value(key) != armor.armor_values[key])
			failures += "новая броня: [key] читается как [armor.get_value(key)], а не [armor.armor_values[key]]"
	if(!isnull(armor.ce_get_health_percent()) || armor.ce_get_wear_state())
		failures += "новая броня показывает износ"

	var/health_max = armor.ce_get_health_max()
	for(var/fraction in list(1, 0.95, 0.8, 0.5, 0.2, 0))
		armor.ce_health = health_max * fraction
		var/condition = ce_evaluate_curve(ce_armor_condition_curve, fraction)
		for(var/key in armor.armor_values)
			if(abs(armor.get_value(key) - armor.armor_values[key] * condition) > 0.0001)
				failures += "[fraction * 100]% HP: [key] читается как [armor.get_value(key)], ожидалось [armor.armor_values[key] * condition]"
		if(!!armor.ce_get_wear_state() != (condition < 1))
			failures += "[fraction * 100]% HP: состояние «[armor.ce_get_wear_state()]» при множителе [condition]"

	ce_armor_wear_enabled = old_switch
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Кривая монотонна и начинает падать с 95%, изношенная броня читается через неё по всем ключам.")
	return 1


/*
	Материалы брони и их точки поломки: керамика держит полный рейтинг до своей точки, а ниже
	кривая состояния лишь сжата. Материал без своей точки ломается по самой кривой.

	Материал тест ставит плитам сам, а не берёт с предметов из `code/items/`: так он не зависит от
	того, какие вещи сейчас керамические.
*/
/datum/unit_test/combat_extended/armor_break_points
	name = "CE: Материалы и точки поломки брони"

/datum/unit_test/combat_extended/armor_break_points/start_test()
	var/old_switch = ce_armor_wear_enabled
	ce_armor_wear_enabled = TRUE
	var/list/failures = list()
	check_materials(failures)

	var/curve_point = ce_get_curve_break_point(ce_armor_condition_curve)
	var/obj/item/clothing/accessory/armor_plate/medium/ceramic = new
	var/obj/item/clothing/accessory/armor_plate/medium/plain = new
	spawned += ceramic
	spawned += plain
	ceramic.ce_armor_material = /singleton/ce_armor_material/ceramic
	plain.ce_armor_material = /singleton/ce_armor_material
	var/datum/extension/armor/ceramic_armor = get_extension(ceramic, /datum/extension/armor)
	var/datum/extension/armor/plain_armor = get_extension(plain, /datum/extension/armor)
	var/singleton/ce_armor_material/ceramic_material = GET_SINGLETON(/singleton/ce_armor_material/ceramic)
	var/break_point = ceramic_armor.ce_get_break_point()
	if(isnull(break_point) || break_point != ceramic_material.break_point)
		failures += "броня керамической плиты читает точку [break_point], а у керамики [ceramic_material.break_point]"
	if(break_point >= curve_point)
		failures += "керамика не держит рейтинг дольше обычной брони: точка [break_point] при [curve_point] у кривой"
	if(!isnull(plain_armor.ce_get_break_point()))
		failures += "броня плиты из материала по умолчанию читает точку [plain_armor.ce_get_break_point()]"
	// Обещание керамики: урон, который обычную броню довёл бы до 80% HP, доводит её до точки поломки.
	var/damage_to_80 = plain_armor.ce_get_health_max() * 0.2
	var/ceramic_fraction = 1 - damage_to_80 / ceramic_armor.ce_get_health_max()
	if(abs(ceramic_fraction - break_point) > 0.0001)
		failures += "керамика: урон, доводящий обычную броню до 80% HP, оставляет ей [ceramic_fraction] HP, а не точку [break_point]"

	var/previous = 0
	for(var/percent in 0 to 100)
		var/fraction = percent / 100
		ceramic_armor.ce_health = ceramic_armor.ce_get_health_max() * fraction
		plain_armor.ce_health = plain_armor.ce_get_health_max() * fraction
		var/condition = ceramic_armor.ce_get_condition()
		if(condition < previous || condition > 1)
			failures += "керамика: при [percent]% HP множитель [condition] после [previous]"
		previous = condition
		// У самой точки деление в дробях BYOND может дать и чуть меньше единицы.
		if(fraction > break_point + 0.005 && condition != 1)
			failures += "керамика: при [percent]% HP рейтинг не полный, [condition]"
		if(fraction < break_point - 0.005 && condition >= 1)
			failures += "керамика: при [percent]% HP рейтинг ещё полный"
		if(abs(plain_armor.ce_get_condition() - ce_evaluate_curve(ce_armor_condition_curve, fraction)) > 0.0001)
			failures += "плита без своей точки: при [percent]% HP множитель [plain_armor.ce_get_condition()] не по кривой"

	for(var/share in list(0, 0.25, 0.5, 0.75))
		ceramic_armor.ce_health = ceramic_armor.ce_get_health_max() * break_point * share
		var/expected = ce_evaluate_curve(ce_armor_condition_curve, curve_point * share)
		if(abs(ceramic_armor.ce_get_condition() - expected) > 0.0001)
			failures += "керамика на [share] своей точки: множитель [ceramic_armor.ce_get_condition()], ожидалось [expected]"

	ce_armor_wear_enabled = old_switch
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("У каждой вещи есть материал, точки поломки в (0, 1], звук поломки у всех материалов. Керамика держит рейтинг до своей точки, а ниже кривая сжата пропорционально.")
	return 1

/**
 * Каждая вещь билда ссылается на материал, у каждого материала точка поломки в (0, 1] или не
 * задана и есть звук поломки.
 */
/datum/unit_test/combat_extended/armor_break_points/proc/check_materials(list/failures)
	for(var/item_type in subtypesof(/obj/item))
		var/obj/item/item_path = item_type
		var/material_type = initial(item_path.ce_armor_material)
		if(!ispath(material_type, /singleton/ce_armor_material))
			failures += "[item_type]: материал брони [material_type]"

	for(var/singleton/ce_armor_material/material as anything in GET_SINGLETON_TYPE_LIST(/singleton/ce_armor_material))
		var/point = material.break_point
		if(!isnull(point) && (!isnum(point) || point <= 0 || point > 1))
			failures += "[material.type]: точка поломки [point] вне (0, 1]"
		if(!isnum(material.health_mult) || material.health_mult <= 0)
			failures += "[material.type]: множитель HP [material.health_mult]"
		if(!isfile(material.break_sound) || material.break_sound_volume <= 0)
			failures += "[material.type]: звук поломки [material.break_sound], громкость [material.break_sound_volume]"


/*
	HP выводятся из рейтинга: плита потяжелее несёт не меньше, а выше излома HP растут медленнее.
	Броня против холодного не хрупче medium-плиты — у неё сильна тупая ось. Нижняя граница стоит
	до доли головного убора и до множителя материала: каска без брони и керамика без брони несут
	долю от неё.

	Лестница плит идёт на материале по умолчанию: tactical plate керамическая, light и medium —
	кевларовые вставки, а лестница проверяет вывод HP из рейтинга, а не материал.
*/
/datum/unit_test/combat_extended/armor_wear_health
	name = "CE: HP брони выводятся из рейтинга"

/datum/unit_test/combat_extended/armor_wear_health/start_test()
	var/list/failures = list()

	var/previous = 0
	var/knee = ce_armor_health_knee_mm * ce_armor_health_per_mm
	var/flattened = 0
	for(var/path in list(
		/obj/item/clothing/accessory/armor_plate,
		/obj/item/clothing/accessory/armor_plate/medium,
		/obj/item/clothing/accessory/armor_plate/tactical,
		/obj/item/clothing/accessory/armor_plate/merc
	))
		var/datum/extension/armor/armor = armor_of(path, null, /singleton/ce_armor_material)
		var/health = armor.ce_get_health_max()
		if(health < previous)
			failures += "[path]: [health] HP, у плиты полегче было [previous]"
		previous = health

		var/best_sharp = max(armor.get_armor_sharp_ballistic(), armor.get_armor_sharp_melee())
		var/linear = max(best_sharp * ce_armor_health_per_mm, armor.get_armor_blunt() * ce_armor_health_per_blunt)
		if(linear <= knee && health != max(ce_armor_health_min, linear))
			failures += "[path]: до излома [health] HP, а не линейные [linear]"
		if(linear > knee)
			flattened++
			if(health >= linear || health <= knee)
				failures += "[path]: выше излома [health] HP, ожидалось между [knee] и линейными [linear]"
	if(!flattened)
		failures += "ни одна плита не выше излома — сглаживание не проверено"

	var/riot_health = health_with(/obj/item/clothing/suit/armor/riot)
	var/medium_health = health_with(/obj/item/clothing/accessory/armor_plate/medium, null, /singleton/ce_armor_material)
	if(riot_health < medium_health)
		failures += "riot хрупче medium-плиты: [riot_health] против [medium_health]"

	var/list/ratings = list("melee" = ARMOR_MELEE_RESISTANT, "bullet" = ARMOR_BALLISTIC_RIFLE)
	var/body_health = health_with(/obj/item/clothing/suit/armor/vest, ratings)
	var/head_health = health_with(/obj/item/clothing/head/helmet, ratings)
	var/expected_head = body_health * ce_armor_health_head_mult
	if(abs(head_health - expected_head) > 0.0001)
		failures += "каска: [head_health] HP, ожидалось [expected_head] от [body_health] у брони на тело"
	var/bare_health = health_with(/obj/item/clothing/suit/armor/vest, list())
	if(bare_health != ce_armor_health_min)
		failures += "вещь без брони: [bare_health] HP, а не нижняя граница [ce_armor_health_min]"
	var/bare_head_health = health_with(/obj/item/clothing/head/helmet, list())
	var/expected_bare_head = ce_armor_health_min * ce_armor_health_head_mult
	if(abs(bare_head_health - expected_bare_head) > 0.0001)
		failures += "каска без брони: [bare_head_health] HP, ожидалось [expected_bare_head] — доля от нижней границы"

	var/singleton/ce_armor_material/ceramic = GET_SINGLETON(/singleton/ce_armor_material/ceramic)
	var/ceramic_health = health_with(/obj/item/clothing/suit/armor/vest, ratings, /singleton/ce_armor_material/ceramic)
	if(abs(ceramic_health - body_health * ceramic.health_mult) > 0.0001)
		failures += "керамика: [ceramic_health] HP, ожидалось [ceramic.health_mult] от [body_health]"
	var/bare_ceramic_health = health_with(/obj/item/clothing/suit/armor/vest, list(), /singleton/ce_armor_material/ceramic)
	var/expected_bare_ceramic = ce_armor_health_min * ceramic.health_mult
	if(abs(bare_ceramic_health - expected_bare_ceramic) > 0.0001)
		failures += "керамика без брони: [bare_ceramic_health] HP, ожидалось [expected_bare_ceramic] — доля от нижней границы"

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("HP растут с тиром плиты и сглажены выше излома, riot не хрупче medium, каски и материал берут свою долю после нижней границы.")
	return 1

/// HP новой вещи. С `ratings` броня вещи заменяется на заданную, с `material` — материал вещи.
/datum/unit_test/combat_extended/armor_wear_health/proc/health_with(path, list/ratings, material)
	var/datum/extension/armor/armor = armor_of(path, ratings, material)
	return armor.ce_get_health_max()


/*
	Износ снимает только боевой путь: пуля — ровно по формуле, холодное — с множителем, остаточный
	удар — без него. Выключенный износ не копится, а при включении накопленный возвращается.

	Плита — единственный слой на груди, так что ожидание считается одним `ce_try_penetrate()`. Она
	жёсткая — скрытый тактический жилет с числами medium-вставки: мягкую броню удар не изнашивает
	вовсе, и множителя холодного на ней не проверить.
*/
/datum/unit_test/combat_extended/armor_wear_paths
	name = "CE: Броню изнашивает только боевой путь"

/datum/unit_test/combat_extended/armor_wear_paths/start_test()
	var/old_switch = ce_armor_wear_enabled
	var/old_mult = ce_armor_melee_wear_mult
	ce_armor_wear_enabled = TRUE
	// Нарочно не значение по умолчанию: проверяется, что до износа доходит сам множитель.
	ce_armor_melee_wear_mult = 3
	var/list/failures = list()
	var/pistol_flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP

	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/sneaky/tactical))
	var/datum/extension/armor/armor
	if(H)
		var/obj/item/clothing/suit = H.wear_suit
		var/obj/item/clothing/plate = (locate(/obj/item/clothing/accessory/armor_plate/sneaky/tactical) in suit.accessories)
		armor = get_extension(plate, /datum/extension/armor)
	if(!armor)
		failures += "не удалось создать цель в скрытом тактическом жилете"
	else
		delivered_damage(H, BP_CHEST, 45, pistol_flags, 0)
		H.get_blocked_ratio(BP_CHEST, DAMAGE_BRUTE, pistol_flags, 0, 45)
		if(!isnull(armor.ce_health))
			failures += "консультационный путь износил плиту"

		var/list/hits = list(
			list("пистолет", 45, pistol_flags, 0, 1),
			list("ящик", 20, FLAGS_OFF, 0, ce_armor_melee_wear_mult),
			list("остаточный удар", 10, FLAGS_OFF, new /datum/ce_explicit_pen(200), 1)
		)
		for(var/list/hit in hits)
			var/expected = expected_wear(armor, hit[2], hit[3], hit[4]) * hit[5]
			var/before = isnull(armor.ce_health) ? armor.ce_get_health_max() : armor.ce_health
			combat_hit(H, BP_CHEST, hit[2], hit[3], hit[4])
			if(abs(before - armor.ce_health - expected) > 0.001)
				failures += "[hit[1]]: снято [before - armor.ce_health] HP, ожидалось [expected]"

		var/worn_health = armor.ce_health
		ce_armor_wear_enabled = FALSE
		combat_hit(H, BP_CHEST, 45, pistol_flags, 0)
		if(armor.ce_health != worn_health)
			failures += "выключенный износ копится"
		armor.ce_health = armor.ce_get_health_max() / 2
		if(armor.get_value("bullet") != armor.armor_values["bullet"] || !isnull(armor.ce_get_health_percent()))
			failures += "выключенный износ читается"
		ce_armor_wear_enabled = TRUE
		if(armor.get_value("bullet") >= armor.armor_values["bullet"])
			failures += "при включении накопленный износ не вернулся"

	ce_armor_wear_enabled = old_switch
	ce_armor_melee_wear_mult = old_mult
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Консультационный путь не изнашивает, боевой — по формуле с множителем холодного, выключатель работает.")
	return 1

/**
 * Износ слоя от удара по формуле, без множителя. Пробитие выводится так же, как в
 * `ce_walk_armor_layers()`.
 */
/datum/unit_test/combat_extended/armor_wear_paths/proc/expected_wear(datum/extension/armor/armor, damage, damage_flags, armor_pen)
	var/pen
	var/blunt_pen
	if(istype(armor_pen, /datum/ce_explicit_pen))
		var/datum/ce_explicit_pen/explicit = armor_pen
		pen = explicit.pen
		blunt_pen = explicit.pen
	else
		pen = ce_derive_penetration(damage, damage_flags, armor_pen)
		blunt_pen = ce_derive_blunt_penetration(damage, damage_flags, armor_pen)
	var/list/layer_step = armor.ce_try_penetrate(damage, damage_flags, pen, damage, pen, blunt_pen)
	var/wear = 0
	for(var/list/test as anything in layer_step[5])
		wear += ce_armor_wear_amount(test[1], test[2], test[3], test[4], test[5], armor.is_hard_armor())
	return wear


/*
	Исключения из износа: естественная броня моба, броня на органе, встроенная броня
	экзокостюма, абляционная броня Ascent и нематериальная вещь (`ce_armor_nonphysical`) —
	энергощит. Псионическая броня живёт на `/datum/psi_complexus`,
	а не на вещи, и отсекается тем же правилом, что и естественная.
*/
/datum/unit_test/combat_extended/armor_wear_exempt
	name = "CE: Исключения не изнашиваются"

/datum/unit_test/combat_extended/armor_wear_exempt/start_test()
	var/old_switch = ce_armor_wear_enabled
	ce_armor_wear_enabled = TRUE
	var/list/failures = list()
	// Остановленная пуля: обычная жёсткая плита на ней изнашивается.
	var/list/tests = list(list(45, 0, 4.4, 6, TRUE))
	var/list/ratings = list("melee" = ARMOR_MELEE_KNIVES, "bullet" = ARMOR_BALLISTIC_PISTOL)

	var/obj/item/clothing/accessory/armor_plate/merc/plate = new
	spawned += plate
	var/datum/extension/armor/control = get_extension(plate, /datum/extension/armor)
	control.ce_apply_wear(tests)
	if(isnull(control.ce_health))
		failures += "контроль: обычная плита не износилась"

	var/list/exempt = list()
	var/mob/living/simple_animal/passive/cow/cow = new(get_safe_turf() || locate(/turf/simulated/floor))
	spawned += cow
	set_extension(cow, /datum/extension/armor, ratings)
	exempt["естественная броня моба"] = get_extension(cow, /datum/extension/armor)

	var/mob/living/carbon/human/H = make_human()
	var/obj/item/organ/external/arm = H?.get_organ(BP_L_ARM)
	if(arm)
		set_extension(arm, /datum/extension/armor, ratings)
		exempt["броня органа"] = get_extension(arm, /datum/extension/armor)
	else
		failures += "не удалось создать руку"

	var/mob/living/exosuit/premade/merc/mech = new(get_safe_turf() || locate(/turf/simulated/floor))
	spawned += mech
	var/datum/extension/armor/mech_armor = get_extension(mech, /datum/extension/armor)
	if(!istype(mech_armor, /datum/extension/armor/mech))
		failures += "встроенная броня экзокостюма несёт [mech_armor?.type], а не /datum/extension/armor/mech"
	exempt["встроенная броня экзокостюма"] = mech_armor

	var/obj/item/clothing/accessory/armor_plate/ablative_plate = new
	spawned += ablative_plate
	set_extension(ablative_plate, /datum/extension/armor/ablative, ratings, 1)
	exempt["абляционная броня"] = get_extension(ablative_plate, /datum/extension/armor)

	var/obj/item/shield/energy/energy_shield = new
	spawned += energy_shield
	exempt["нематериальная броня энергощита"] = get_extension(energy_shield, /datum/extension/armor)

	for(var/name in exempt)
		var/datum/extension/armor/armor = exempt[name]
		if(!armor)
			failures += "[name]: броня не создалась"
			continue
		armor.ce_apply_wear(tests)
		if(!isnull(armor.ce_health) || armor.ce_get_condition() != 1)
			failures += "[name]: износилась"

	ce_armor_wear_enabled = old_switch
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Обычная плита изнашивается, все [length(exempt)] исключения — нет.")
	return 1


/*
	Зональная броня изнашивается и читается по группам зон. Зона доходит до процентного пути
	лазера, до кодекса и до осмотра, а после каждого чтения контекст зоны возвращается.

	Рейтинги тест ставит скафандру сам, так что он не зависит от чисел скафандров в билде. Руки
	не бьются вовсе: по ним сверяется целая броня.
*/
/datum/unit_test/combat_extended/armor_zones
	name = "CE: Зональная броня"
	var/pistol_flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP

/datum/unit_test/combat_extended/armor_zones/start_test()
	var/old_switch = ce_armor_wear_enabled
	var/old_mult = ce_armor_secondary_zone_health_mult
	ce_armor_wear_enabled = TRUE
	// Нарочно не значение по умолчанию: проверяется, что до HP групп доходит сама доля.
	ce_armor_secondary_zone_health_mult = 0.5
	var/list/failures = list()

	var/mob/living/carbon/human/H = make_suited_human()
	var/datum/extension/armor/armor = H && get_extension(H.wear_suit, /datum/extension/armor)
	if(!armor)
		failures += "не удалось одеть человека в скафандр"
	else
		check_wear(H, armor, failures)
		check_reading(H, armor, failures)
		check_display(armor, failures)

	ce_armor_wear_enabled = old_switch
	ce_armor_secondary_zone_health_mult = old_mult
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Торс, руки и ноги изнашиваются и читаются отдельно — пулей, лазером, в кодексе и при осмотре.")
	return 1

/// Человек в скафандре с рейтингами medium-плиты. null — одеть не вышло.
/datum/unit_test/combat_extended/armor_zones/proc/make_suited_human()
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		return null
	var/obj/item/clothing/suit/space/void/suit = new(H.loc)
	spawned += suit
	set_extension(suit, /datum/extension/armor, list("melee" = ARMOR_MELEE_KNIVES, "bullet" = ARMOR_BALLISTIC_PISTOL, "laser" = ARMOR_LASER_SMALL))
	H.equip_to_slot_or_del(suit, slot_wear_suit)
	return H.wear_suit == suit ? H : null

/**
 * Боевой путь изнашивает только группу попадания, а HP групп берут свою долю.
 */
/datum/unit_test/combat_extended/armor_zones/proc/check_wear(mob/living/carbon/human/H, datum/extension/armor/armor, list/failures)
	combat_hit(H, BP_CHEST, 45, pistol_flags, 0)
	var/torso_health = armor.ce_get_health(CE_ARMOR_ZONE_TORSO)
	if(isnull(torso_health) || torso_health >= armor.ce_get_health_max(CE_ARMOR_ZONE_TORSO))
		failures += "выстрел в грудь не износил торс"
	if(!isnull(armor.ce_get_health(CE_ARMOR_ZONE_ARMS)) || !isnull(armor.ce_get_health(CE_ARMOR_ZONE_LEGS)))
		failures += "выстрел в грудь износил руки или ноги"
	if(!isnull(armor.ce_health))
		failures += "зональная броня износила общий запас HP"

	combat_hit(H, BP_GROIN, 45, pistol_flags, 0)
	if(armor.ce_get_health(CE_ARMOR_ZONE_TORSO) >= torso_health)
		failures += "выстрел в пах не износил торс"
	torso_health = armor.ce_get_health(CE_ARMOR_ZONE_TORSO)

	combat_hit(H, BP_L_FOOT, 45, pistol_flags, 0)
	if(isnull(armor.ce_get_health(CE_ARMOR_ZONE_LEGS)))
		failures += "выстрел в стопу не износил ноги"
	if(armor.ce_get_health(CE_ARMOR_ZONE_TORSO) != torso_health || !isnull(armor.ce_get_health(CE_ARMOR_ZONE_ARMS)))
		failures += "выстрел в стопу износил торс или руки"
	if(!isnull(GLOB.ce_hit_body_part))
		failures += "контекст зоны не вернулся после боевого прохода"

	var/health_max = armor.ce_get_health_max()
	if(armor.ce_get_health_max(CE_ARMOR_ZONE_TORSO) != health_max)
		failures += "торс: [armor.ce_get_health_max(CE_ARMOR_ZONE_TORSO)] HP, а у вещи [health_max]"
	if(abs(armor.ce_get_health_max(CE_ARMOR_ZONE_LEGS) - health_max * 0.5) > 0.0001)
		failures += "ноги: [armor.ce_get_health_max(CE_ARMOR_ZONE_LEGS)] HP, общая доля 0.5 от [health_max] не дошла"
	var/obj/item/suit = armor.holder
	suit.ce_armor_secondary_zone_health_mult = 0.25
	if(abs(armor.ce_get_health_max(CE_ARMOR_ZONE_ARMS) - health_max * 0.25) > 0.0001)
		failures += "руки: [armor.ce_get_health_max(CE_ARMOR_ZONE_ARMS)] HP, своя доля вещи 0.25 от [health_max] не дошла"
	suit.ce_armor_secondary_zone_health_mult = null

/**
 * Рейтинг по зоне: целые руки читаются как новые, изношенный в ноль торс не держит ничего, а
 * бедро и стопа читают одну и ту же половину HP. И пулей, и лазером.
 */
/datum/unit_test/combat_extended/armor_zones/proc/check_reading(mob/living/carbon/human/H, datum/extension/armor/armor, list/failures)
	ce_armor_wear_enabled = FALSE
	var/intact_bullet = H.get_blocked_ratio(BP_L_ARM, DAMAGE_BRUTE, pistol_flags, 0, 45)
	var/intact_laser = H.get_blocked_ratio(BP_L_ARM, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0, 40)
	ce_armor_wear_enabled = TRUE
	if(intact_bullet <= 0 || intact_laser <= 0)
		failures += "целый скафандр ничего не держит, сравнивать не с чем"

	armor.ce_set_health(CE_ARMOR_ZONE_TORSO, 0)
	armor.ce_set_health(CE_ARMOR_ZONE_LEGS, armor.ce_get_health_max(CE_ARMOR_ZONE_LEGS) / 2)

	for(var/zone in list(BP_L_ARM, BP_R_HAND))
		if(H.get_blocked_ratio(zone, DAMAGE_BRUTE, pistol_flags, 0, 45) != intact_bullet)
			failures += "[zone]: пуля читает износ чужих групп"
		if(H.get_blocked_ratio(zone, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0, 40) != intact_laser)
			failures += "[zone]: лазер читает износ чужих групп"
	for(var/zone in list(BP_CHEST, BP_GROIN))
		if(H.get_blocked_ratio(zone, DAMAGE_BRUTE, pistol_flags, 0, 45) != 0 || H.get_blocked_ratio(zone, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0, 40) != 0)
			failures += "[zone]: торс изношен в ноль, а держит"

	var/legs_bullet = H.get_blocked_ratio(BP_L_LEG, DAMAGE_BRUTE, pistol_flags, 0, 45)
	var/legs_laser = H.get_blocked_ratio(BP_L_LEG, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0, 40)
	if(legs_bullet <= 0 || legs_bullet >= intact_bullet || legs_laser <= 0 || legs_laser >= intact_laser)
		failures += "ноги на половине HP: пуля [legs_bullet] из [intact_bullet], лазер [legs_laser] из [intact_laser]"
	if(H.get_blocked_ratio(BP_R_FOOT, DAMAGE_BRUTE, pistol_flags, 0, 45) != legs_bullet || H.get_blocked_ratio(BP_R_FOOT, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0, 40) != legs_laser)
		failures += "правая стопа и левое бедро читают разный износ"
	if(!isnull(GLOB.ce_hit_body_part))
		failures += "контекст зоны не вернулся после консультационного прохода"

	if(armor.ce_get_wear_state(CE_ARMOR_ZONE_TORSO) != "ruined" || armor.ce_get_wear_state(CE_ARMOR_ZONE_ARMS))
		failures += "словесное состояние: торс «[armor.ce_get_wear_state(CE_ARMOR_ZONE_TORSO)]», руки «[armor.ce_get_wear_state(CE_ARMOR_ZONE_ARMS)]»"

/**
 * Кодекс и осмотр показывают каждую группу со своим износом. Зовётся после `check_reading()`:
 * торс изношен в ноль, ноги наполовину, руки целы.
 */
/datum/unit_test/combat_extended/armor_zones/proc/check_display(datum/extension/armor/armor, list/failures)
	var/list/lines = armor.ce_get_condition_lines()
	var/list/expected = list(
		ce_format_condition_line(CE_ARMOR_ZONE_TORSO, 0),
		ce_format_condition_line(CE_ARMOR_ZONE_ARMS, 100),
		ce_format_condition_line(CE_ARMOR_ZONE_LEGS, 50)
	)
	if(jointext(lines, " | ") != jointext(expected, " | "))
		failures += "осмотр: «[jointext(lines, " | ")]», ожидалось «[jointext(expected, " | ")]»"

	ce_armor_wear_enabled = FALSE
	var/list/intact_blocks = splittext(armor.ce_get_codex_line(), "<br><br>")
	ce_armor_wear_enabled = TRUE
	var/list/worn_blocks = splittext(armor.ce_get_codex_line(), "<br><br>")
	if(!isnull(GLOB.ce_hit_body_part))
		failures += "контекст зоны не вернулся после кодекса"
	if(length(worn_blocks) != 3 || length(intact_blocks) != 3)
		failures += "кодекс: блоков [length(worn_blocks)], ожидалось по одному на торс, руки и ноги"
		return
	if(!findtext(worn_blocks[1], "([CE_ARMOR_ZONE_TORSO])") || !findtext(worn_blocks[2], "([CE_ARMOR_ZONE_ARMS])") || !findtext(worn_blocks[3], "([CE_ARMOR_ZONE_LEGS])"))
		failures += "кодекс: блоки не по группам зон — «[jointext(worn_blocks, " | ")]»"
	if(worn_blocks[1] == intact_blocks[1] || worn_blocks[3] == intact_blocks[3])
		failures += "кодекс: изношенные торс или ноги показаны целыми"
	if(worn_blocks[2] != intact_blocks[2])
		failures += "кодекс: целые руки показаны изношенными"


/*
	Наручи и поножи берут ту же долю HP, что и вторичные группы зональной брони, а пластина на
	торс — нет. Доля берётся от нижней границы HP и доходит до кривой состояния.

	Рейтинги тест ставит вещам сам, одинаковые, так что HP до доли у них равны.
*/
/datum/unit_test/combat_extended/armor_secondary_accessories
	name = "CE: Наручи и поножи берут долю вторичных зон"

/datum/unit_test/combat_extended/armor_secondary_accessories/start_test()
	var/old_switch = ce_armor_wear_enabled
	var/old_mult = ce_armor_secondary_zone_health_mult
	ce_armor_wear_enabled = TRUE
	// Нарочно не значение по умолчанию: проверяется, что до HP доходит сама доля.
	ce_armor_secondary_zone_health_mult = 0.5
	var/list/failures = list()
	var/list/ratings = list("melee" = ARMOR_MELEE_KNIVES, "bullet" = ARMOR_BALLISTIC_PISTOL)

	// Пластина из материала по умолчанию, как и наручи с поножами: у кевларовой вставки свой множитель HP.
	var/datum/extension/armor/plate_armor = armor_of(/obj/item/clothing/accessory/armor_plate/merc, ratings)
	var/plate_health = plate_armor.ce_get_health_max()
	if(plate_armor.ce_is_secondary_zone_accessory())
		failures += "пластина на торс считается бронёй рук или ног"

	for(var/path in list(/obj/item/clothing/accessory/arm_guards, /obj/item/clothing/accessory/leg_guards))
		var/datum/extension/armor/armor = armor_of(path, ratings)
		if(abs(armor.ce_get_health_max() - plate_health * 0.5) > 0.0001)
			failures += "[path]: [armor.ce_get_health_max()] HP, ожидалось 0.5 от [plate_health] у пластины"

		var/obj/item/guards = armor.holder
		guards.ce_armor_secondary_zone_health_mult = 0.25
		if(abs(armor.ce_get_health_max() - plate_health * 0.25) > 0.0001)
			failures += "[path]: [armor.ce_get_health_max()] HP, своя доля вещи 0.25 от [plate_health] не дошла"

		armor.ce_health = armor.ce_get_health_max() / 2
		var/expected = ce_evaluate_curve(ce_armor_condition_curve, 0.5)
		if(abs(armor.ce_get_condition() - expected) > 0.0001)
			failures += "[path]: на половине своих HP множитель [armor.ce_get_condition()], ожидалось [expected]"

	var/datum/extension/armor/bare_armor = armor_of(/obj/item/clothing/accessory/arm_guards, list())
	if(abs(bare_armor.ce_get_health_max() - ce_armor_health_min * 0.5) > 0.0001)
		failures += "наручи без брони: [bare_armor.ce_get_health_max()] HP, ожидалось 0.5 от нижней границы [ce_armor_health_min]"

	ce_armor_wear_enabled = old_switch
	ce_armor_secondary_zone_health_mult = old_mult
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Наручи и поножи берут общую долю и свою долю вещи, пластина торса — нет, кривая читает долю.")
	return 1


/*
	Кевларовые вставки плитоноски и обычный скрытый жилет — баллистическое волокно (`ballistic_fiber`
	у материала): мягкая броня, которая держит пули как жёсткая плита с теми же числами Bay, а нож и
	удар — как одежда. Сверяются с жёсткой бронёй тех же чисел: у лёгкой стальной пластины
	`armor_plate/makeshift/light` числа light-вставки и скрытого жилета, у скрытого тактического жилета
	`sneaky/tactical` — medium.
*/
/datum/unit_test/combat_extended/ballistic_fiber
	name = "CE: Кевларовые вставки"
	var/pistol_flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP
	var/pistol_damage = 45
	/// Вещь из волокна — её жёсткий близнец с теми же числами Bay.
	var/list/twins = list(
		/obj/item/clothing/accessory/armor_plate = /obj/item/clothing/accessory/armor_plate/makeshift/light,
		/obj/item/clothing/accessory/armor_plate/medium = /obj/item/clothing/accessory/armor_plate/sneaky/tactical,
		/obj/item/clothing/accessory/armor_plate/sneaky = /obj/item/clothing/accessory/armor_plate/makeshift/light
	)

/datum/unit_test/combat_extended/ballistic_fiber/start_test()
	var/old_wear = ce_armor_wear_enabled
	var/old_laser = ce_laser_heat_enabled
	ce_armor_wear_enabled = TRUE
	ce_laser_heat_enabled = TRUE
	var/list/failures = list()
	var/list/report = list()
	for(var/insert_type in twins)
		check_ratings(failures, report, insert_type, twins[insert_type])
	check_plates(failures)
	check_attacks(failures, report)
	check_wear(failures, report)
	check_beams(failures)
	ce_armor_wear_enabled = old_wear
	ce_laser_heat_enabled = old_laser
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Вставки — мягкая броня: пули держат как жёсткая плита, нож и удар — как одежда, изнашиваются как мягкая, лучей не останавливают.\n[jointext(report, "\n")]")
	return 1

/**
 * Рейтинги вставки против жёсткого близнеца: против пуль — те же миллиметры, против клинков и удара —
 * по мягким кривым, без нижней границы тупой оси от пулевого рейтинга. HP — из рейтингов самой
 * вставки, с множителем материала. `report` — числа вставки и близнеца для README.
 */
/datum/unit_test/combat_extended/ballistic_fiber/proc/check_ratings(list/failures, list/report, insert_type, twin_type)
	var/datum/extension/armor/insert = armor_of(insert_type)
	var/datum/extension/armor/twin = armor_of(twin_type)
	var/singleton/ce_armor_material/material = insert.ce_get_material()
	if(!material.ballistic_fiber || insert.is_hard_armor())
		failures += "[insert_type]: материал [material.type], жёсткая — [insert.is_hard_armor()]; ожидалось мягкое баллистическое волокно"
	if(!twin.is_hard_armor())
		failures += "[twin_type]: не жёсткая броня, сверять вставку не с чем"
	var/bullet = insert.get_value("bullet")
	var/melee = insert.get_value("melee")
	if(bullet != twin.get_value("bullet") || melee != twin.get_value("melee"))
		failures += "[twin_type]: числа Bay не те, что у [insert_type]"

	var/sharp_ballistic = insert.get_armor_sharp_ballistic()
	var/sharp_melee = insert.get_armor_sharp_melee()
	var/blunt = insert.get_armor_blunt()
	var/soft_ballistic = ce_evaluate_curve(ce_sharp_ballistic_soft, bullet)
	if(abs(sharp_ballistic - twin.get_armor_sharp_ballistic()) > 0.0001 || sharp_ballistic <= soft_ballistic)
		failures += "[insert_type]: против пуль [sharp_ballistic] мм, у жёсткого близнеца [twin.get_armor_sharp_ballistic()], по мягкой кривой [soft_ballistic]"
	var/soft_melee = ce_evaluate_curve(ce_sharp_melee_soft, melee)
	if(abs(sharp_melee - soft_melee) > 0.0001 || sharp_melee >= twin.get_armor_sharp_melee())
		failures += "[insert_type]: против клинков [sharp_melee] мм, по мягкой кривой [soft_melee], у жёсткого близнеца [twin.get_armor_sharp_melee()]"
	var/soft_blunt = ce_evaluate_curve(ce_blunt_curve_soft, melee)
	if(abs(blunt - soft_blunt) > 0.0001 || blunt >= twin.get_armor_blunt())
		failures += "[insert_type]: тупой рейтинг [blunt], по мягкой кривой [soft_blunt], у жёсткого близнеца [twin.get_armor_blunt()]"

	var/linear_health = max(max(sharp_ballistic, sharp_melee) * ce_armor_health_per_mm, blunt * ce_armor_health_per_blunt)
	var/expected_health = max(ce_armor_health_min, ce_flatten_armor_health(linear_health)) * material.health_mult
	if(material.health_mult <= 1 || abs(insert.ce_get_health_max() - expected_health) > 0.0001)
		failures += "[insert_type]: [insert.ce_get_health_max()] HP при множителе материала [material.health_mult], ожидалось [expected_health]"
	report += "[insert_type] ([material.name]): [sharp_ballistic] мм против пуль, [sharp_melee] мм против клинков, тупой [blunt], HP [insert.ce_get_health_max()]; [twin_type]: [twin.get_armor_sharp_ballistic()] мм, [twin.get_armor_sharp_melee()] мм, тупой [twin.get_armor_blunt()], HP [twin.ce_get_health_max()]"

/// Прочие пластины остались жёсткими: мягкими материал делает только две вставки и обычный скрытый
/// жилет. Скрытый тактический жилет — среди жёстких.
/datum/unit_test/combat_extended/ballistic_fiber/proc/check_plates(list/failures)
	var/hard_count = 0
	for(var/plate_type in typesof_real(/obj/item/clothing/accessory/armor_plate))
		if(plate_type in twins)
			continue
		var/datum/extension/armor/armor = armor_of(plate_type)
		var/singleton/ce_armor_material/material = armor.ce_get_material()
		if(material.ballistic_fiber || !armor.is_hard_armor())
			failures += "[plate_type]: материал [material.type], жёсткая — [armor.is_hard_armor()]; ожидалась жёсткая пластина"
		hard_count++
	if(!hard_count)
		failures += "кроме вставок, пластин в билде нет"

/**
 * Что вставка делает с атакой, чистым проходом по слоям: medium держит пистолеты, а винтовка её
 * пробивает; нож проходит вставку острым, а жёсткий близнец его останавливает; остановленный
 * пистолет и ящик бьют через вставку сильнее, чем через близнеца. Обычный скрытый жилет бьётся как
 * light-вставка, тактический нож останавливает. `report` — доставленный урон для README.
 */
/datum/unit_test/combat_extended/ballistic_fiber/proc/check_attacks(list/failures, list/report)
	var/list/targets = list()
	for(var/plate_type in list(
		/obj/item/clothing/accessory/armor_plate,
		/obj/item/clothing/accessory/armor_plate/medium,
		/obj/item/clothing/accessory/armor_plate/sneaky,
		/obj/item/clothing/accessory/armor_plate/makeshift/light,
		/obj/item/clothing/accessory/armor_plate/sneaky/tactical
	))
		var/mob/living/carbon/human/H = make_human(list(plate_type))
		if(!H)
			failures += "атаки: не удалось создать цель в [plate_type]"
			return
		targets += H
	var/mob/living/carbon/human/in_light = targets[1]
	var/mob/living/carbon/human/in_medium = targets[2]
	var/mob/living/carbon/human/in_low_profile = targets[3]
	var/mob/living/carbon/human/in_light_twin = targets[4]
	var/mob/living/carbon/human/in_twin = targets[5]

	// Снаряд — останавливает ли его medium-вставка.
	var/list/bullets = list(
		/obj/item/projectile/bullet/pistol/holdout = TRUE,
		/obj/item/projectile/bullet/pistol = TRUE,
		/obj/item/projectile/bullet/rifle = FALSE
	)
	for(var/bullet_type in bullets)
		var/obj/item/projectile/bullet/bullet = bullet_type
		var/stopped = is_stopped(in_medium, initial(bullet.damage), initial(bullet.damage_flags), initial(bullet.armor_penetration))
		if(stopped != bullets[bullet_type])
			failures += "атаки: [bullet_type] в medium-вставку — остановлен [stopped], ожидалось [bullets[bullet_type]]"

	var/knife_flags = DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE
	if(is_stopped(in_light, 15, knife_flags, 5) || is_stopped(in_medium, 15, knife_flags, 5))
		failures += "атаки: нож остановлен мягкой вставкой"
	if(is_stopped(in_low_profile, 15, knife_flags, 5))
		failures += "атаки: нож остановлен мягким скрытым жилетом"
	if(!is_stopped(in_twin, 15, knife_flags, 5) || !is_stopped(in_light_twin, 15, knife_flags, 5))
		failures += "атаки: нож не остановлен жёстким близнецом — сравнивать не с чем"
	// У обычного скрытого жилета числа и материал light-вставки: бьётся он так же.
	for(var/list/attack in list(list("пистолет", pistol_damage, pistol_flags, 0), list("нож", 15, knife_flags, 5), list("ящик", 20, FLAGS_OFF, 0)))
		var/through_vest = total_delivered(in_low_profile, attack[2], attack[3], attack[4])
		var/through_light = total_delivered(in_light, attack[2], attack[3], attack[4])
		if(abs(through_vest - through_light) > 0.0001)
			failures += "атаки: [attack[1]] через скрытый жилет — [through_vest], через light-вставку — [through_light]; ожидалось поровну"
	// Название, урон, флаги, AP.
	var/list/softer = list(
		list("остановленный пистолет", pistol_damage, pistol_flags, 0),
		list("ящик", 20, FLAGS_OFF, 0)
	)
	for(var/list/attack in softer)
		var/through_insert = total_delivered(in_medium, attack[2], attack[3], attack[4])
		var/through_twin = total_delivered(in_twin, attack[2], attack[3], attack[4])
		if(through_insert <= through_twin || through_insert >= attack[2])
			failures += "атаки: [attack[1]] через medium-вставку — [through_insert], через жёсткого близнеца — [through_twin], без брони — [attack[2]]"

	report += describe_delivered(in_light, "light-вставка")
	report += describe_delivered(in_low_profile, "скрытый жилет")
	report += describe_delivered(in_light_twin, "лёгкая стальная пластина")
	report += describe_delivered(in_medium, "medium-вставка")
	report += describe_delivered(in_twin, "скрытый тактический жилет")

/// Остановила ли броня груди острую атаку: атака вышла из слоёв тупой.
/datum/unit_test/combat_extended/ballistic_fiber/proc/is_stopped(mob/living/carbon/human/H, damage, damage_flags, armor_pen)
	var/list/walked = H.ce_walk_armor_layers(BP_CHEST, damage, DAMAGE_BRUTE, damage_flags, armor_pen)
	return !ce_is_sharp_attack(walked[2])

/// Весь урон, дошедший до груди: основной и остаточный удар.
/datum/unit_test/combat_extended/ballistic_fiber/proc/total_delivered(mob/living/carbon/human/H, damage, damage_flags, armor_pen)
	var/list/delivered = delivered_damage(H, BP_CHEST, damage, damage_flags, armor_pen)
	return delivered[1] + delivered[2]

/// Строка отчёта: урон, дошедший до груди через пластину, по опорным пулям и холодному оружию.
/datum/unit_test/combat_extended/ballistic_fiber/proc/describe_delivered(mob/living/carbon/human/H, label)
	var/list/attacks = list()
	for(var/bullet_type in list(
		/obj/item/projectile/bullet/pistol/holdout,
		/obj/item/projectile/bullet/pistol,
		/obj/item/projectile/bullet/pistol/fast,
		/obj/item/projectile/bullet/pistol/strong,
		/obj/item/projectile/bullet/rifle,
		/obj/item/projectile/bullet/shotgun,
		/obj/item/projectile/bullet/pellet/shotgun
	))
		var/obj/item/projectile/bullet/bullet = bullet_type
		attacks += list(list("[bullet_type]", initial(bullet.damage), initial(bullet.damage_flags), initial(bullet.armor_penetration)))
	attacks += melee_anchors()

	var/list/parts = list()
	for(var/list/attack in attacks)
		var/stopped = ce_is_sharp_attack(attack[3]) && is_stopped(H, attack[2], attack[3], attack[4])
		parts += "[attack[1]] ([attack[2]]) — [stopped ? "стоп " : ""][round(total_delivered(H, attack[2], attack[3], attack[4]), 0.1)]"
	return "[label]: [jointext(parts, ", ")]"

/**
 * Износ по формуле мягкой брони: остановленная пуля снимает с вставки весь свой урон, а удар —
 * ничего; жёсткого близнеца тот же удар изнашивает. `report` — сколько пистолетных пуль подряд
 * держат вставки и их близнецы.
 */
/datum/unit_test/combat_extended/ballistic_fiber/proc/check_wear(list/failures, list/report)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/medium))
	var/mob/living/carbon/human/twin_human = make_human(list(/obj/item/clothing/accessory/armor_plate/sneaky/tactical))
	var/datum/extension/armor/armor = plate_armor(H)
	var/datum/extension/armor/twin = plate_armor(twin_human)
	if(!armor || !twin)
		failures += "износ: не удалось создать цели"
		return

	var/health_max = armor.ce_get_health_max()
	combat_hit(H, BP_CHEST, pistol_damage, pistol_flags, 0)
	var/pistol_wear = health_max - armor.ce_get_health()
	if(abs(pistol_wear - pistol_damage) > 0.001)
		failures += "износ: остановленный пистолет снял с medium-вставки [pistol_wear] HP, ожидался весь его урон — [pistol_damage]"
	var/worn_health = armor.ce_get_health()
	combat_hit(H, BP_CHEST, 20, FLAGS_OFF, 0)
	if(armor.ce_get_health() != worn_health)
		failures += "износ: ящик снял с мягкой вставки [worn_health - armor.ce_get_health()] HP"
	combat_hit(twin_human, BP_CHEST, 20, FLAGS_OFF, 0)
	if(isnull(twin.ce_get_health()))
		failures += "износ: ящик не износил жёсткого близнеца — сравнивать не с чем"

	// Близнец у light-вставки и скрытого жилета общий: каждая пластина — один раз.
	var/list/series_types = list()
	for(var/insert_type in twins)
		series_types |= insert_type
		series_types |= twins[insert_type]
	for(var/plate_type in series_types)
		var/list/series = pistol_series(plate_type)
		if(!series)
			failures += "износ: не удалось создать цель в [plate_type]"
			continue
		report += "[plate_type]: пистолет проходит с [series[1]]-го попадания, половина HP — после [series[2]]-го"

/**
 * Серия пистолетных пуль в новую пластину боевым проходом: `list(каким по счёту попаданием пуля
 * впервые проходит острой, после какого попадания остаётся не больше половины HP)`. null — цели нет.
 */
/datum/unit_test/combat_extended/ballistic_fiber/proc/pistol_series(plate_type)
	var/mob/living/carbon/human/H = make_human(list(plate_type))
	var/datum/extension/armor/armor = plate_armor(H)
	if(!armor)
		return null
	var/first_through
	var/to_half
	for(var/shot in 1 to 100)
		if(!first_through && !is_stopped(H, pistol_damage, pistol_flags, 0))
			first_through = shot
		combat_hit(H, BP_CHEST, pistol_damage, pistol_flags, 0)
		if(!to_half && armor.ce_get_health() <= armor.ce_get_health_max() / 2)
			to_half = shot
		if(first_through && to_half)
			break
	return list(first_through, to_half)

/**
 * Лучи: вставка их не останавливает и вычитанием не держит — слабый луч проходит её с полной долей,
 * а жёсткого близнеца не проходит вовсе. От лазера она не греется, а обугливается.
 */
/datum/unit_test/combat_extended/ballistic_fiber/proc/check_beams(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/medium))
	var/mob/living/carbon/human/twin_human = make_human(list(/obj/item/clothing/accessory/armor_plate/sneaky/tactical))
	var/datum/extension/armor/armor = plate_armor(H)
	var/datum/extension/armor/twin = plate_armor(twin_human)
	if(!armor || !twin)
		failures += "лучи: не удалось создать цели"
		return
	if(armor.ce_can_stop(DAMAGE_BURN, DAMAGE_FLAG_LASER) || armor.ce_uses_laser_heat(DAMAGE_BURN, DAMAGE_FLAG_LASER))
		failures += "лучи: вставка останавливает луч или держит его вычитанием"
	if(!twin.ce_can_stop(DAMAGE_BURN, DAMAGE_FLAG_LASER) || !twin.ce_uses_laser_heat(DAMAGE_BURN, DAMAGE_FLAG_LASER))
		failures += "лучи: жёсткий близнец луч не останавливает — сравнивать не с чем"

	// Луч слабее рейтинга `laser` обеих пластин: близнец держит его вычитанием целиком.
	var/weak_damage = 15
	var/share = H.ce_get_percent_pass_share(BP_CHEST, weak_damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0)
	var/twin_share = twin_human.ce_get_percent_pass_share(BP_CHEST, weak_damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0)
	if(share != 1 || twin_share != 0)
		failures += "лучи: луч в [weak_damage] урона проходит вставку с долей [share], близнеца — с долей [twin_share]; ожидалось 1 и 0"

	H.modify_damage_by_armor(BP_CHEST, 40, DAMAGE_BURN, DAMAGE_FLAG_LASER, H, 0, TRUE)
	var/health = armor.ce_get_health()
	if(armor.ce_heat || isnull(health) || health >= armor.ce_get_health_max())
		failures += "лучи: от лазера вставка нагрелась — [armor.ce_heat ? "да" : "нет"], HP [health] из [armor.ce_get_health_max()]; ожидалось обугливание без нагрева"


/*
	Аксессуары под верхней одеждой (`concealed_accessories.dm`). Скрытый жилет и кобура на униформе
	под халатом посторонним не видны ни в осмотре униформы, ни в строках о состоянии брони, ни в её
	кодексе; носителю и призраку видны. Халат закрывает торс и руки, так что часы на запястье видно и
	под ним. Без халата видно всё, на самой верхней одежде — тоже. Сам жилет на униформе не рисуется.
*/
/datum/unit_test/combat_extended/concealed_accessories
	name = "CE: Аксессуары под верхней одеждой"

/datum/unit_test/combat_extended/concealed_accessories/start_test()
	var/old_wear = ce_armor_wear_enabled
	var/old_repair = ce_armor_repair_enabled
	ce_armor_wear_enabled = TRUE
	ce_armor_repair_enabled = TRUE
	var/list/failures = list()
	check_uniform(failures)
	check_outer_clothing(failures)
	ce_armor_wear_enabled = old_wear
	ce_armor_repair_enabled = old_repair
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Аксессуары униформы под верхней одеждой видны носителю и призраку, посторонним и кодексу — нет; не закрытые и пристёгнутые к самой верхней одежде видны всем.")
	return 1

/// Униформа с жилетом, кобурой и часами: что о них узнают посторонний, носитель, призрак и кодекс —
/// без халата и под ним.
/datum/unit_test/combat_extended/concealed_accessories/proc/check_uniform(list/failures)
	var/mob/living/carbon/human/wearer = make_human()
	var/mob/living/carbon/human/stranger = make_human()
	if(!wearer || !stranger)
		failures += "униформа: не удалось создать людей"
		return
	var/obj/item/clothing/under/color/grey/uniform = new(wearer.loc)
	spawned += uniform
	var/obj/item/clothing/accessory/armor_plate/sneaky/vest = new(uniform)
	var/obj/item/clothing/accessory/storage/holster/holster = new(uniform)
	var/obj/item/clothing/accessory/wristwatch/watch = new(uniform)
	var/list/attached = list(vest, holster, watch)
	for(var/obj/item/clothing/accessory/accessory as anything in attached)
		if(!uniform.can_attach_accessory(accessory))
			failures += "униформа: [accessory.type] к ней не пристёгивается"
			return
		uniform.attach_accessory(null, accessory)
	wearer.equip_to_slot_or_del(uniform, slot_w_uniform)
	if(wearer.w_uniform != uniform)
		failures += "униформа: надеть не вышло"
		return

	var/vest_label = capitalize(vest.name)
	if(length(uniform.ce_get_accessories_seen_by(stranger)) != length(attached))
		failures += "без халата посторонний видит [length(uniform.ce_get_accessories_seen_by(stranger))] аксессуаров из [length(attached)]"
	if(!findtext(uniform.ce_get_repair_codex(), vest_label))
		failures += "без халата кодекс униформы молчит о жилете — сравнивать не с чем"
	if(vest.get_mob_overlay(wearer, slot_w_uniform_str))
		failures += "жилет на униформе рисуется на носителе"
	// Изношенный жилет: о состоянии его брони униформа рассказывает тем же, кому показывает его самого.
	combat_hit(wearer, BP_CHEST, 45, DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP, 0)
	if(!findtext(jointext(uniform.ce_get_accessory_armor_lines(stranger), "\n"), vest.name))
		failures += "без халата посторонний не видит состояния брони изношенного жилета — сравнивать не с чем"

	var/obj/item/clothing/suit/storage/toggle/labcoat/coat = new(wearer.loc)
	spawned += coat
	wearer.equip_to_slot_or_del(coat, slot_wear_suit)
	if(wearer.wear_suit != coat)
		failures += "униформа: надеть халат поверх жилета не вышло"
		return
	if(!(coat.body_parts_covered & vest.body_location) || !(coat.body_parts_covered & holster.body_location) || (coat.body_parts_covered & watch.body_location))
		failures += "халат должен закрывать жилет и кобуру и не закрывать часы — проверять не на чем"

	var/list/seen_by_stranger = uniform.ce_get_accessories_seen_by(stranger)
	if((vest in seen_by_stranger) || (holster in seen_by_stranger))
		failures += "под халатом посторонний видит жилет — [(vest in seen_by_stranger) ? "да" : "нет"], кобуру — [(holster in seen_by_stranger) ? "да" : "нет"]"
	if(!(watch in seen_by_stranger))
		failures += "под халатом посторонний не видит часы на запястье, которого халат не закрывает"
	if(length(uniform.ce_get_accessories_seen_by(wearer)) != length(attached))
		failures += "под халатом носитель видит [length(uniform.ce_get_accessories_seen_by(wearer))] своих аксессуаров из [length(attached)]"
	var/mob/observer/ghost/ghost = new(stranger)
	spawned += ghost
	if(length(uniform.ce_get_accessories_seen_by(ghost)) != length(attached))
		failures += "под халатом призрак видит [length(uniform.ce_get_accessories_seen_by(ghost))] аксессуаров из [length(attached)]"
	if(vest in uniform.ce_get_accessories_seen_by())
		failures += "под халатом жилет виден взгляду со стороны, без смотрящего"
	if(findtext(uniform.ce_get_repair_codex(), vest_label))
		failures += "под халатом кодекс униформы рассказывает о жилете"
	if(findtext(jointext(uniform.ce_get_accessory_armor_lines(stranger), "\n"), vest.name))
		failures += "под халатом посторонний видит состояние брони жилета"
	if(!findtext(jointext(uniform.ce_get_accessory_armor_lines(wearer), "\n"), vest.name))
		failures += "под халатом носитель не видит состояния брони своего жилета"

/// Пластина на плитоноске — аксессуар самой верхней одежды: её не закрывает ничего, видна всем.
/datum/unit_test/combat_extended/concealed_accessories/proc/check_outer_clothing(list/failures)
	var/mob/living/carbon/human/wearer = make_human(list(/obj/item/clothing/accessory/armor_plate/medium))
	var/mob/living/carbon/human/stranger = make_human()
	if(!wearer || !stranger)
		failures += "плитоноска: не удалось создать людей"
		return
	var/obj/item/clothing/carrier = wearer.wear_suit
	if(!length(carrier.accessories) || length(carrier.ce_get_accessories_seen_by(stranger)) != length(carrier.accessories))
		failures += "плитоноска: посторонний видит [length(carrier.ce_get_accessories_seen_by(stranger))] её аксессуаров из [length(carrier.accessories)]"
	if(!findtext(carrier.ce_get_repair_codex(), "Medium ballistic insert"))
		failures += "плитоноска: её кодекс молчит о вставке"


/*
	Зональные вещи в билде: каждая закрывает хотя бы две группы зон — иначе зональность ей ничего
	не даёт. Доли HP вторичных групп больше нуля: на них делится при чтении.
*/
/datum/unit_test/combat_extended/armor_zoned_items
	name = "CE: Зональные вещи"

/datum/unit_test/combat_extended/armor_zoned_items/start_test()
	var/list/failures = list()

	var/zoned_count = 0
	for(var/item_type in subtypesof(/obj/item))
		var/obj/item/item_path = item_type
		var/item_mult = initial(item_path.ce_armor_secondary_zone_health_mult)
		if(!isnull(item_mult) && (!isnum(item_mult) || item_mult <= 0))
			failures += "[item_type]: доля HP вторичных групп [item_mult]"
		if(!initial(item_path.ce_armor_zoned))
			continue
		zoned_count++
		var/covered_groups = 0
		for(var/group in ce_armor_zone_groups)
			if(initial(item_path.body_parts_covered) & ce_armor_zone_groups[group])
				covered_groups++
		if(covered_groups < 2)
			failures += "[item_type]: закрывает групп зон — [covered_groups]"
	if(!zoned_count)
		failures += "в билде нет зональных вещей"

	if(!isnum(ce_armor_secondary_zone_health_mult) || ce_armor_secondary_zone_health_mult <= 0)
		failures += "общая доля HP вторичных групп [ce_armor_secondary_zone_health_mult]"
	if(!(CE_ARMOR_ZONE_TORSO in ce_armor_zone_groups))
		failures += "среди групп зон нет торса"
	var/seen_parts = 0
	for(var/group in ce_armor_zone_groups)
		if(seen_parts & ce_armor_zone_groups[group])
			failures += "группа [group] пересекается с предыдущими"
		seen_parts |= ce_armor_zone_groups[group]

	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("[zoned_count] зональных вещей закрывают по две группы зон и больше, доли HP больше нуля.")
	return 1


/*
	Осколки от поломки брони. Колющаяся вещь есть в билде, и её материал знает свой осколок; у
	каждого материала осколок — материал Bay с осколками, а множитель и урон — числа.

	Шанс считается только по HP, снятым ниже точки поломки, и не колет вещь без флага или без
	осколка у материала. Осколок бьёт конечность ровно на урон материала и застревает, даже когда
	Bay сливает его прокол с открытым. Бьём руки, а не грудь: у груди органы, и кор код режет урон
	по ней вдвое наугад. Боевой путь: человек в самодельной броне ниже точки поломки
	ловит пулю, и осколок из материала брони застревает в груди, а очередь осколков после
	попадания пуста.

	На боевом пути множитель стали поднят так, что шанс выходит за 100%, или опущен в ноль.
	Остаточный удар выключен: он изнашивает броню ещё раз и мог бы кольнуть второй раз.
*/
/datum/unit_test/combat_extended/armor_shards
	name = "CE: Осколки от поломки брони"

/datum/unit_test/combat_extended/armor_shards/start_test()
	var/old_wear = ce_armor_wear_enabled
	var/old_residual = ce_residual_blunt_enabled
	ce_armor_wear_enabled = TRUE
	ce_residual_blunt_enabled = FALSE
	var/list/failures = list()
	check_shard_materials(failures)
	check_chance(failures)
	check_shard_hit(failures)
	check_combat(failures)
	ce_armor_wear_enabled = old_wear
	ce_residual_blunt_enabled = old_residual
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Шанс осколка — доля HP, снятых ниже точки поломки, осколок из материала брони бьёт на урон материала и застревает в ране.")
	return 1

/datum/unit_test/combat_extended/armor_shards/proc/check_shard_materials(list/failures)
	var/shard_items = 0
	for(var/item_type in subtypesof(/obj/item))
		var/obj/item/item_path = item_type
		var/material_type = initial(item_path.ce_armor_material)
		// Вещь без материала ловит тест «Материалы и точки поломки брони».
		if(!initial(item_path.ce_armor_shards) || !ispath(material_type, /singleton/ce_armor_material))
			continue
		shard_items++
		var/singleton/ce_armor_material/material = GET_SINGLETON(material_type)
		if(!material.shard_material)
			failures += "[item_type] колется, а у материала [material_type] нет осколка"
	if(!shard_items)
		failures += "в билде нет колющейся брони"

	for(var/singleton/ce_armor_material/material as anything in GET_SINGLETON_TYPE_LIST(/singleton/ce_armor_material))
		if(material.shard_material)
			var/material/shard_source = SSmaterials.get_material_by_name(material.shard_material)
			if(!shard_source?.shard_type)
				failures += "[material.type]: осколок из [material.shard_material] — у такого материала Bay осколков нет"
		if(!isnum(material.shard_chance_mult) || material.shard_chance_mult < 0)
			failures += "[material.type]: множитель шанса осколка [material.shard_chance_mult]"
		if(!isnum(material.shard_damage) || material.shard_damage <= 0)
			failures += "[material.type]: урон осколка [material.shard_damage]"

/datum/unit_test/combat_extended/armor_shards/proc/check_chance(list/failures)
	var/datum/extension/armor/armor = armor_of(/obj/item/clothing/suit/armor/makeshift)
	var/singleton/ce_armor_material/material = armor.ce_get_material()
	var/health_max = armor.ce_get_health_max()
	var/break_health = health_max * (armor.ce_get_break_point() || ce_get_curve_break_point(ce_armor_condition_curve))
	var/tenth = health_max * 0.1
	// Название, HP до, HP после, ожидаемый шанс при множителе 1.
	var/list/cases = list(
		list("выше точки", health_max, break_health, 0),
		list("через точку", break_health + tenth, break_health - tenth, 10),
		list("ниже точки", break_health / 2, break_health / 2 - 2 * tenth, 20),
		list("в нуле", 0, 0, 0)
	)
	for(var/list/test_case as anything in cases)
		var/expected = test_case[4] * material.shard_chance_mult
		var/chance = armor.ce_get_shard_chance(null, test_case[2], test_case[3])
		if(abs(chance - expected) > 0.0001)
			failures += "самодельная броня [test_case[1]]: шанс [chance]%, ожидалось [expected]%"

	var/datum/extension/armor/unflagged = armor_of(/obj/item/clothing/accessory/armor_plate/medium, null, /singleton/ce_armor_material/steel)
	if(unflagged.ce_get_shard_chance(null, unflagged.ce_get_health_max() * 0.5, 0))
		failures += "стальная плита без флага колется"
	var/datum/extension/armor/shardless = armor_of(/obj/item/clothing/suit/armor/makeshift, null, /singleton/ce_armor_material/kevlar)
	if(shardless.ce_get_shard_chance(null, shardless.ce_get_health_max() * 0.5, 0))
		failures += "самодельная броня из кевлара колется, а у кевлара нет осколка"

/datum/unit_test/combat_extended/armor_shards/proc/check_shard_hit(list/failures)
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		failures += "не удалось создать цель для осколка"
		return
	var/obj/item/clothing/suit/armor/makeshift/vest = new(H.loc)
	spawned += vest
	var/singleton/ce_armor_material/material = GET_SINGLETON(vest.ce_armor_material)
	var/obj/item/organ/external/arm = H.get_organ(BP_L_ARM)
	H.ce_apply_shard(BP_L_ARM, vest)
	// `take_external_damage()` округляет урон до 0.1.
	if(abs(arm.brute_dam - material.shard_damage) > 0.1)
		failures += "осколок нанёс руке [arm.brute_dam], а не [material.shard_damage]"
	if(length(find_shards(arm)) != 1)
		failures += "в руке осколков [length(find_shards(arm))], а не один"

	// Прокол того же размера без осколка: прокол осколка Bay сольёт с ним и раны не отдаст. С
	// осколком в ране он бы не слился — такая рана не заживает сама (`can_autoheal()`).
	var/obj/item/organ/external/pierced_arm = H.get_organ(BP_R_ARM)
	pierced_arm.take_external_damage(material.shard_damage, 0, DAMAGE_FLAG_SHARP)
	H.ce_apply_shard(BP_R_ARM, vest)
	if(abs(pierced_arm.brute_dam - 2 * material.shard_damage) > 0.2)
		failures += "осколок в проколотую руку: у руки [pierced_arm.brute_dam] урона, а не [2 * material.shard_damage]"
	if(length(find_shards(pierced_arm)) != 1)
		failures += "осколок в проколотую руку: осколков [length(find_shards(pierced_arm))], а не один"

/datum/unit_test/combat_extended/armor_shards/proc/check_combat(list/failures)
	var/singleton/ce_armor_material/steel = GET_SINGLETON(/singleton/ce_armor_material/steel)
	var/old_mult = steel.shard_chance_mult
	for(var/mult in list(0, 1000000))
		steel.shard_chance_mult = mult
		var/mob/living/carbon/human/H = make_human()
		if(!H)
			failures += "не удалось создать цель в самодельной броне"
			break
		var/obj/item/clothing/suit/armor/makeshift/vest = new(H.loc)
		spawned += vest
		H.equip_to_slot_or_del(vest, slot_wear_suit)
		if(H.wear_suit != vest)
			failures += "не удалось надеть самодельную броню"
			break
		var/datum/extension/armor/armor = get_extension(vest, /datum/extension/armor)
		armor.ce_health = armor.ce_get_health_max() * 0.5

		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		H.apply_damage(20, DAMAGE_BRUTE, BP_CHEST, DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP, null, 0)
		var/list/shards = find_shards(chest)
		var/expected = mult ? 1 : 0
		if(length(shards) != expected)
			failures += "множитель [mult]: осколков в груди [length(shards)], ожидалось [expected]"
		for(var/obj/item/material/shard/shrapnel/shard as anything in shards)
			if(shard.material?.name != steel.shard_material)
				failures += "осколок из [shard.material?.name], а не из [steel.shard_material]"
		if(H.ce_pending_shards)
			failures += "множитель [mult]: после попадания осталась очередь осколков"
	steel.shard_chance_mult = old_mult

/// Осколки брони, застрявшие в конечности. Удаляются вместе с тестом.
/datum/unit_test/combat_extended/armor_shards/proc/find_shards(obj/item/organ/external/organ)
	. = list()
	for(var/obj/item/material/shard/shrapnel/shard in organ.implants)
		. += shard
		spawned |= shard



/*
	Починка брони хламом (`armor_repair.dm`).

	Числа тест берёт у самого хлама — сколько возвращает одна починка и сколько предела она съедает,
	— а проверяет инварианты: починка не выходит за предел, предел падает на возвращённое ×
	множитель, изношенная в ноль и залатанная до упора броня получает `1 / (1 + множитель)` прежнего
	предела, а кривая состояния читает HP от исходного максимума — залатанная броня слабее новой.
	Набор кузнеца предел поднимает, навык строительства меняет, сколько его съедает хлам, а кодекс
	пишет всё это в самом низу.

	Клик идёт настоящим `use_tool()` и `ce_try_armor_repair()`. Время починки у хлама на время теста
	обнулено: `do_after()` без задержки проходит сразу, так что клик доходит до конца, а отказ,
	пропущенный проверкой, сразу меняет броню.
*/
/datum/unit_test/combat_extended/armor_repair
	name = "CE: Починка брони хламом"

/datum/unit_test/combat_extended/armor_repair/start_test()
	var/old_wear = ce_armor_wear_enabled
	var/old_repair = ce_armor_repair_enabled
	ce_armor_wear_enabled = TRUE
	ce_armor_repair_enabled = TRUE
	var/list/old_times = list()
	for(var/singleton/ce_armor_repair/junk as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/ce_armor_repair))
		old_times[junk] = junk.repair_time
		junk.repair_time = 0
	var/list/failures = list()

	check_junk(failures)
	check_kinds(failures)
	check_cap(failures)
	check_kit(failures)
	check_targets(failures)
	check_codex(failures)
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		failures += "не удалось создать человека"
	else
		check_refusals(H, failures)
		check_clicks(H, failures)
		check_skill(H, failures)
		check_finish(H, failures)
		check_breaches(H, failures)
		check_ablative(H, failures)
		check_rig(H, failures)

	for(var/singleton/ce_armor_repair/junk as anything in old_times)
		junk.repair_time = old_times[junk]
	ce_armor_wear_enabled = old_wear
	ce_armor_repair_enabled = old_repair
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Хлам латает свою броню до падающего предела, набор кузнеца предел поднимает, навык меняет потерю, керамика хламом не латается, абляционную латают отражающими листами с покрытием, убранный РИГ — по детали в зоне прицела, пробоины скафандра — раньше брони.")
	return 1

/// Новый предмет, который удалится после теста.
/datum/unit_test/combat_extended/armor_repair/proc/make(path, amount)
	var/obj/item/thing = amount ? new path(null, amount) : new path
	spawned += thing
	return thing

/// Броня вещи, уже изношенная до доли `fraction` своих HP.
/datum/unit_test/combat_extended/armor_repair/proc/worn_armor_of(path, fraction, list/ratings)
	var/datum/extension/armor/armor = armor_of(path, ratings)
	armor.ce_health = armor.ce_get_health_max() * fraction
	return armor

/**
 * Хлам описан целиком, у каждого рода брони он есть, а предмет находит свой хлам и только его.
 * Бесплатной починки нет: хлам либо съедает предел, либо, как набор кузнеца, поднимает его. У
 * каждого материала, кроме материала по умолчанию, есть название для кодекса.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_junk(list/failures)
	var/list/kinds = list()
	for(var/singleton/ce_armor_repair/junk as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/ce_armor_repair))
		if(!junk.name || !ispath(junk.junk_type, /obj/item))
			failures += "[junk.type]: без названия или предмета"
		if(!(junk.repair_kind in list(CE_ARMOR_REPAIR_METAL, CE_ARMOR_REPAIR_FABRIC, CE_ARMOR_REPAIR_ABLATIVE, CE_ARMOR_REPAIR_HARD)))
			failures += "[junk.type]: род брони «[junk.repair_kind]»"
		if(!isnum(junk.coating_restore_share) || junk.coating_restore_share < 0 || junk.coating_restore_share > 1)
			failures += "[junk.type]: доля покрытия [junk.coating_restore_share]"
		if(!isnum(junk.repair_share) || junk.repair_share <= 0 || junk.repair_share > 1)
			failures += "[junk.type]: доля починки [junk.repair_share]"
		if(!isnum(junk.max_loss_mult) || junk.max_loss_mult < 0 || !isnum(junk.cap_restore_share) || junk.cap_restore_share < 0)
			failures += "[junk.type]: потеря предела [junk.max_loss_mult], подъём предела [junk.cap_restore_share]"
		else if(!junk.max_loss_mult && !junk.cap_restore_share)
			failures += "[junk.type]: починка ничего не стоит и предела не поднимает"
		kinds |= junk.repair_kind
	if(!(CE_ARMOR_REPAIR_METAL in kinds) || !(CE_ARMOR_REPAIR_FABRIC in kinds))
		failures += "хлам есть не у каждого рода брони: [jointext(kinds, ", ")]"

	for(var/material_type in typesof(/singleton/ce_armor_material))
		var/singleton/ce_armor_material/material = GET_SINGLETON(material_type)
		if(material.repair_kind && !(material.repair_kind in list(CE_ARMOR_REPAIR_METAL, CE_ARMOR_REPAIR_FABRIC, CE_ARMOR_REPAIR_ABLATIVE, CE_ARMOR_REPAIR_NONE)))
			failures += "[material_type]: род починки «[material.repair_kind]»"
		else if(material.repair_kind && material.repair_kind != CE_ARMOR_REPAIR_NONE && !(material.repair_kind in kinds))
			failures += "[material_type]: латается «[material.repair_kind]», а такого хлама нет"
		if(material_type != /singleton/ce_armor_material && !material.name)
			failures += "[material_type]: без названия для кодекса"

	// Один предмет бывает хламом разного рода: лист стали по стальной пластине — металл, по
	// абляционному жилету — абляционный хлам.
	var/datum/extension/armor/steel_plate = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	var/datum/extension/armor/vest = armor_of(/obj/item/clothing/suit/armor/laserproof)
	var/list/expected_junk = list(
		list(/obj/item/stack/material/steel, steel_plate, /singleton/ce_armor_repair/stack/steel),
		list(/obj/item/stack/material/rods, steel_plate, /singleton/ce_armor_repair/stack/rods),
		list(/obj/item/stack/material/cloth, steel_plate, /singleton/ce_armor_repair/stack/cloth),
		list(/obj/item/weldingtool, steel_plate, /singleton/ce_armor_repair/welder),
		list(/obj/item/tape_roll, steel_plate, /singleton/ce_armor_repair/tape),
		list(/obj/item/ce_blacksmith_kit, steel_plate, /singleton/ce_armor_repair/blacksmith_kit),
		list(/obj/item/stack/material/plasteel, steel_plate, null),
		list(/obj/item/stack/material/silver, vest, /singleton/ce_armor_repair/stack/ablative/silver),
		list(/obj/item/stack/material/aluminium, vest, /singleton/ce_armor_repair/stack/ablative/aluminium),
		list(/obj/item/stack/material/glass, vest, /singleton/ce_armor_repair/stack/ablative/glass),
		list(/obj/item/stack/material/steel, vest, /singleton/ce_armor_repair/stack/ablative/steel),
		list(/obj/item/ce_blacksmith_kit, vest, /singleton/ce_armor_repair/blacksmith_kit)
	)
	for(var/list/test_case in expected_junk)
		var/datum/extension/armor/target = test_case[2]
		var/singleton/ce_armor_repair/found = ce_get_armor_repair_junk(make(test_case[1]), target)
		if(found?.type != test_case[3])
			failures += "[test_case[1]] по [target.holder.type]: хлам [found?.type], ожидался [test_case[3]]"

/**
 * Чем латать, решает материал, а без своего — жёсткость. Кевларовая вставка — мягкая броня, её
 * латают тканью. Набор кузнеца берёт любую жёсткую броню, керамику в том числе, но не мягкую — ни
 * скафандр, ни кевлар.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_kinds(list/failures)
	var/list/expected_kinds = list(
		/obj/item/clothing/accessory/armor_plate/makeshift/medium = CE_ARMOR_REPAIR_METAL,
		/obj/item/clothing/accessory/armor_plate/merc = CE_ARMOR_REPAIR_METAL,
		/obj/item/clothing/accessory/armor_plate/tactical = CE_ARMOR_REPAIR_NONE,
		/obj/item/clothing/head/helmet/tactical = CE_ARMOR_REPAIR_NONE,
		/obj/item/clothing/suit/armor/laserproof = CE_ARMOR_REPAIR_ABLATIVE,
		/obj/item/clothing/accessory/arm_guards/ablative = CE_ARMOR_REPAIR_ABLATIVE
	)
	for(var/path in expected_kinds)
		var/datum/extension/armor/armor = armor_of(path)
		if(armor.ce_get_repair_kind() != expected_kinds[path])
			failures += "[path]: латается «[armor.ce_get_repair_kind()]», ожидалось «[expected_kinds[path]]»"
	var/datum/extension/armor/soft_armor = armor_of(/obj/item/clothing/suit/space, list("melee" = ARMOR_MELEE_KNIVES))
	if(soft_armor.is_hard_armor() || soft_armor.ce_get_repair_kind() != CE_ARMOR_REPAIR_FABRIC)
		failures += "мягкий EVA-скафандр латается «[soft_armor.ce_get_repair_kind()]», ожидалась ткань"
	var/datum/extension/armor/kevlar_armor = armor_of(/obj/item/clothing/accessory/armor_plate/medium)
	if(kevlar_armor.is_hard_armor() || kevlar_armor.ce_get_repair_kind() != CE_ARMOR_REPAIR_FABRIC)
		failures += "кевларовая вставка латается «[kevlar_armor.ce_get_repair_kind()]», ожидалась ткань"

	var/singleton/ce_armor_repair/kit = GET_SINGLETON(/singleton/ce_armor_repair/blacksmith_kit)
	for(var/path in expected_kinds)
		var/datum/extension/armor/armor = armor_of(path)
		if(!kit.can_repair(armor))
			failures += "[path]: жёсткая броня, а набор кузнеца её не берёт"
	if(kit.can_repair(soft_armor))
		failures += "набор кузнеца берёт мягкий EVA-скафандр"
	if(kit.can_repair(kevlar_armor))
		failures += "набор кузнеца берёт кевларовую вставку"

/**
 * Починка на стальной пластине: одна починка возвращает долю хлама и съедает предел, до упора
 * броня доходит ровно до предела, повторный износ в ноль опускает предел ещё раз. Кривая состояния
 * читает HP от максимума, а осмотр показывает предел. Скотч съедает предел один к одному.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_cap(list/failures)
	var/singleton/ce_armor_repair/steel = GET_SINGLETON(/singleton/ce_armor_repair/stack/steel)
	var/datum/extension/armor/armor = armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium)
	var/health_max = armor.ce_get_health_max()
	if(armor.ce_apply_repair(steel) != 0 || !isnull(armor.ce_health))
		failures += "неизношенная броня латается"

	armor.ce_health = 0
	var/restored = armor.ce_apply_repair(steel)
	if(abs(restored - steel.repair_share * health_max) > 0.0001 || abs(armor.ce_health - restored) > 0.0001)
		failures += "одна починка вернула [restored] HP (стало [armor.ce_health]), ожидалось [steel.repair_share * health_max]"
	if(abs(armor.ce_get_health_lost() - restored * steel.max_loss_mult) > 0.0001)
		failures += "одна починка съела [armor.ce_get_health_lost()] HP предела, ожидалось [restored * steel.max_loss_mult]"

	var/first_cap = health_max / (1 + steel.max_loss_mult)
	repair_to_cap(armor, steel)
	if(abs(armor.ce_health - first_cap) > 0.01 || abs(armor.ce_get_health_cap() - first_cap) > 0.01)
		failures += "до упора: [armor.ce_health] HP при пределе [armor.ce_get_health_cap()], ожидалось [first_cap]"
	if(armor.ce_get_health_max() != health_max)
		failures += "починка поменяла максимум HP: [armor.ce_get_health_max()] вместо [health_max]"
	var/expected_condition = ce_evaluate_curve(ce_armor_condition_curve, first_cap / health_max)
	if(abs(armor.ce_get_condition() - expected_condition) > 0.0001 || armor.ce_get_condition() >= 1)
		failures += "залатанная до упора броня читает множитель [armor.ce_get_condition()], ожидалось [expected_condition] — меньше новой"

	var/list/lines = armor.ce_get_condition_lines()
	var/expected_line = "Armor condition: [armor.ce_get_health_percent()]%/[round(100 * first_cap / health_max)]%"
	if(length(lines) != 1 || lines[1] != expected_line)
		failures += "осмотр: «[jointext(lines, " | ")]», ожидалось «[expected_line]»"

	armor.ce_health = 0
	repair_to_cap(armor, steel)
	var/second_cap = first_cap / (1 + steel.max_loss_mult)
	if(abs(armor.ce_health - second_cap) > 0.01)
		failures += "второй раз из нуля: [armor.ce_health] HP, ожидалось [second_cap]"

	var/singleton/ce_armor_repair/tape = GET_SINGLETON(/singleton/ce_armor_repair/tape)
	var/datum/extension/armor/taped_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/medium, 0)
	repair_to_cap(taped_armor, tape)
	var/tape_cap = taped_armor.ce_get_health_max() / (1 + tape.max_loss_mult)
	if(abs(taped_armor.ce_health - tape_cap) > 0.01)
		failures += "скотчем из нуля: [taped_armor.ce_health] HP, ожидалось [tape_cap]"

/// Латает, пока хлам что-то возвращает. Каждая починка возвращает не меньше доли хлама или ровно
/// остаток до предела, так что сотни шагов хватает с запасом.
/datum/unit_test/combat_extended/armor_repair/proc/repair_to_cap(datum/extension/armor/armor, singleton/ce_armor_repair/junk, group)
	for(var/i in 1 to 100)
		if(!armor.ce_apply_repair(junk, group))
			return

/**
 * Набор кузнеца: сперва поднимает предел на свою долю, потом возвращает HP до нового предела; до
 * упора доводит броню до максимума, но не выше; у брони с полным пределом просто возвращает HP; у
 * целой брони ему делать нечего. Керамику тоже берёт.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_kit(list/failures)
	var/singleton/ce_armor_repair/steel = GET_SINGLETON(/singleton/ce_armor_repair/stack/steel)
	var/singleton/ce_armor_repair/kit = GET_SINGLETON(/singleton/ce_armor_repair/blacksmith_kit)

	var/datum/extension/armor/armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0)
	var/health_max = armor.ce_get_health_max()
	repair_to_cap(armor, steel)
	var/cap = armor.ce_get_health_cap()
	armor.ce_apply_repair(kit)
	var/expected_cap = min(health_max, cap + kit.cap_restore_share * health_max)
	var/expected_health = min(expected_cap, cap + kit.repair_share * health_max)
	if(abs(armor.ce_get_health_cap() - expected_cap) > 0.01 || abs(armor.ce_health - expected_health) > 0.01)
		failures += "набор у предела [cap]: предел [armor.ce_get_health_cap()], HP [armor.ce_health], ожидалось [expected_cap] и [expected_health]"
	repair_to_cap(armor, kit)
	if(armor.ce_get_health_lost() != 0 || abs(armor.ce_health - health_max) > 0.01)
		failures += "набор до упора: потеряно [armor.ce_get_health_lost()] HP предела, HP [armor.ce_health] из [health_max]"

	var/datum/extension/armor/ceramic_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/tactical, 0.5)
	var/ceramic_health = ceramic_armor.ce_health
	var/ceramic_max = ceramic_armor.ce_get_health_max()
	ceramic_armor.ce_apply_repair(kit)
	if(abs(ceramic_armor.ce_health - ceramic_health - kit.repair_share * ceramic_max) > 0.01 || ceramic_armor.ce_get_health_lost())
		failures += "набор по керамике с полным пределом: HP [ceramic_health] → [ceramic_armor.ce_health], потеряно предела [ceramic_armor.ce_get_health_lost()]"

	var/datum/extension/armor/intact_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/tactical, 1)
	if(intact_armor.ce_is_repair_useful(intact_armor.ce_get_repair_result(kit), null))
		failures += "набор находит, что латать, у брони с полными HP и пределом"

/**
 * Кодекс пишет в самом низу материал и хлам, которым броню латают, с долей HP и сдвигом предела
 * одной починки. Керамику — только набором кузнеца, и без строки о навыке: набор предел не съедает.
 * Плитоноска — по блоку на пластину.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_codex(list/failures)
	if(ce_format_repair_share(0.1) != "+10%" || ce_format_repair_share(-0.025) != "-2.5%")
		failures += "доля в кодексе: «[ce_format_repair_share(0.1)]» и «[ce_format_repair_share(-0.025)]», ожидалось «+10%» и «-2.5%»"

	var/list/expected_heads = list(
		/obj/item/clothing/accessory/armor_plate/makeshift/medium = "<b>Repair:</b><br>Material: steel<br>Can be fixed with:<br>",
		/obj/item/clothing/accessory/armor_plate/tactical = "<b>Repair:</b><br>Material: ceramic<br>Can be fixed with:<br>"
	)
	for(var/path in expected_heads)
		var/obj/item/clothing/clothing = make(path)
		var/datum/extension/armor/armor = get_extension(clothing, /datum/extension/armor)
		var/info = clothing.get_mechanics_info()
		var/repair_at = findtext(info, expected_heads[path])
		if(!repair_at || repair_at < findtext(info, "<b>Armor ratings:</b>") || findtext(info, "<br><br>", repair_at))
			failures += "[path]: блока починки нет или он не в самом низу кодекса"
			continue
		var/skill_matters = FALSE
		var/list/found_lines = list()
		for(var/singleton/ce_armor_repair/junk as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/ce_armor_repair))
			var/line = "[junk.get_codex_name()] ([ce_format_repair_share(junk.repair_share)], [ce_format_repair_share(junk.cap_restore_share - junk.repair_share * junk.max_loss_mult)] max)"
			var/line_at = findtext(info, line, repair_at)
			if(junk.can_repair(armor) != !!line_at)
				failures += "[path]: строка «[line]» [junk.can_repair(armor) ? "не найдена" : "лишняя"]"
			if(line_at)
				found_lines[line] = line_at
			if(junk.can_repair(armor) && junk.max_loss_mult)
				skill_matters = TRUE
		var/list/sorted_lines = sortTim(found_lines.Copy(), GLOBAL_PROC_REF(cmp_text_asc))
		var/last_at = 0
		for(var/line in sorted_lines)
			if(found_lines[line] < last_at)
				failures += "[path]: хлам в кодексе не по алфавиту — «[line]» раньше предыдущего"
			last_at = found_lines[line]
		if(skill_matters != !!findtext(info, "Construction skill", repair_at))
			failures += "[path]: строка о навыке [skill_matters ? "не найдена" : "лишняя"]"

	var/obj/item/clothing/suit/armor/pcarrier/carrier = make(/obj/item/clothing/suit/armor/pcarrier)
	var/obj/item/clothing/accessory/armor_plate/medium/plate = new(carrier)
	carrier.attach_accessory(null, plate)
	var/carrier_info = carrier.get_mechanics_info()
	var/plate_repair_at = findtext(carrier_info, "<b>Repair ([capitalize(plate.name)]):</b><br>Material: kevlar<br>")
	if(!plate_repair_at || plate_repair_at < findtext(carrier_info, "<b>[capitalize(plate.name)]:</b>"))
		failures += "плитоноска: блока починки пластины нет или он выше её рейтингов"

/**
 * Что латает клик: плитоноска — аксессуар по зоне прицела, зональный скафандр — группу прицела и
 * только её, каска — себя, куда ни целься.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_targets(list/failures)
	var/obj/item/clothing/suit/armor/pcarrier/carrier = make(/obj/item/clothing/suit/armor/pcarrier)
	var/list/expected_holders = list(
		CE_ARMOR_ZONE_TORSO = /obj/item/clothing/accessory/armor_plate/medium,
		CE_ARMOR_ZONE_ARMS = /obj/item/clothing/accessory/arm_guards,
		CE_ARMOR_ZONE_LEGS = /obj/item/clothing/accessory/leg_guards
	)
	for(var/zone_group in expected_holders)
		var/accessory_type = expected_holders[zone_group]
		carrier.attach_accessory(null, new accessory_type(carrier))
	for(var/zone_group in expected_holders)
		var/datum/extension/armor/armor = carrier.ce_get_repair_armor(zone_group)
		if(armor?.holder?.type != expected_holders[zone_group])
			failures += "плитоноска, [zone_group]: латается [armor?.holder?.type], ожидалось [expected_holders[zone_group]]"
	if(carrier.ce_get_repair_armor(CE_ARMOR_ZONE_HEAD))
		failures += "плитоноска без своей брони латает что-то по прицелу в голову"
	if(ce_get_target_zone_group(BP_R_HAND) != CE_ARMOR_ZONE_ARMS || ce_get_target_zone_group(BP_L_FOOT) != CE_ARMOR_ZONE_LEGS || ce_get_target_zone_group(null) != CE_ARMOR_ZONE_TORSO)
		failures += "зона прицела не в той группе зон"

	var/obj/item/clothing/head/helmet/helmet = make(/obj/item/clothing/head/helmet)
	var/datum/extension/armor/helmet_armor = get_extension(helmet, /datum/extension/armor)
	if(helmet.ce_get_repair_armor(CE_ARMOR_ZONE_TORSO) != helmet_armor)
		failures += "каска по прицелу в грудь латает не себя"

	var/singleton/ce_armor_repair/steel = GET_SINGLETON(/singleton/ce_armor_repair/stack/steel)
	var/obj/item/clothing/suit/space/void/suit = make(/obj/item/clothing/suit/space/void)
	set_extension(suit, /datum/extension/armor, list("melee" = ARMOR_MELEE_KNIVES, "bullet" = ARMOR_BALLISTIC_PISTOL))
	var/datum/extension/armor/suit_armor = get_extension(suit, /datum/extension/armor)
	if(suit.ce_get_repair_armor(CE_ARMOR_ZONE_ARMS) != suit_armor)
		failures += "войдсьют по прицелу в руку латает не себя"
	suit_armor.ce_set_health(CE_ARMOR_ZONE_TORSO, 0)
	suit_armor.ce_set_health(CE_ARMOR_ZONE_ARMS, 0)
	suit_armor.ce_apply_repair(steel, CE_ARMOR_ZONE_ARMS)
	if(suit_armor.ce_get_health(CE_ARMOR_ZONE_ARMS) <= 0 || suit_armor.ce_get_health_lost(CE_ARMOR_ZONE_ARMS) <= 0)
		failures += "войдсьют: починка рук не вернула им HP или не съела предел"
	if(suit_armor.ce_get_health(CE_ARMOR_ZONE_TORSO) != 0 || suit_armor.ce_get_health_lost(CE_ARMOR_ZONE_TORSO) || suit_armor.ce_health_lost)
		failures += "войдсьют: починка рук задела торс или общий предел"

/**
 * Отказы настоящего клика. Неизношенная броня, чужой предмет и выключатель отдают клик дальше;
 * керамика, чужой хлам, набор кузнеца по мягкой броне и по кевлару, броня у предела и незажжённая сварка
 * разбирают его сами и ничего не меняют. Пропусти проверка отказ — ожидание без задержки пройдёт,
 * и броня поменяется.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_refusals(mob/living/carbon/human/H, list/failures)
	var/obj/item/stack/material/steel/steel = make(/obj/item/stack/material/steel, 5)

	var/obj/item/clothing/intact_plate = make(/obj/item/clothing/accessory/armor_plate/makeshift/medium)
	intact_plate.forceMove(H.loc)
	if(intact_plate.ce_try_armor_repair(steel, H))
		failures += "клик сталью по неизношенной пластине не прошёл дальше"
	var/datum/extension/armor/worn_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0.5)
	var/obj/item/clothing/worn_plate = worn_armor.holder
	worn_plate.forceMove(H.loc)
	if(worn_plate.ce_try_armor_repair(make(/obj/item/stack/material/plasteel, 5), H))
		failures += "клик пласталью разобран как починка"
	ce_armor_repair_enabled = FALSE
	if(worn_plate.ce_try_armor_repair(steel, H))
		failures += "при выключенной починке клик сталью не прошёл дальше"
	ce_armor_repair_enabled = TRUE

	var/obj/item/ce_blacksmith_kit/kit = make(/obj/item/ce_blacksmith_kit)
	var/list/refusals = list(
		list("керамика сталью", worn_armor_of(/obj/item/clothing/accessory/armor_plate/tactical, 0.5), steel),
		list("кевлар сталью", worn_armor_of(/obj/item/clothing/accessory/armor_plate/medium, 0.5), steel),
		list("сталь тканью", worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0.5), make(/obj/item/stack/material/cloth, 5)),
		list("сталь незажжённой сваркой", worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0.5), make(/obj/item/weldingtool)),
		list("мягкий скафандр набором кузнеца", worn_armor_of(/obj/item/clothing/suit/space, 0.5, list("melee" = ARMOR_MELEE_KNIVES)), kit),
		list("кевлар набором кузнеца", worn_armor_of(/obj/item/clothing/accessory/armor_plate/medium, 0.5), kit)
	)
	var/datum/extension/armor/capped_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0)
	repair_to_cap(capped_armor, GET_SINGLETON(/singleton/ce_armor_repair/stack/steel))
	refusals += list(list("сталь у предела", capped_armor, steel))

	for(var/list/refusal in refusals)
		var/datum/extension/armor/armor = refusal[2]
		var/obj/item/clothing/clicked = armor.holder
		clicked.forceMove(H.loc)
		var/health = armor.ce_health
		var/lost = armor.ce_get_health_lost()
		if(!clicked.ce_try_armor_repair(refusal[3], H))
			failures += "[refusal[1]]: отказ не разобран, клик ушёл дальше"
		if(armor.ce_health != health || armor.ce_get_health_lost() != lost)
			failures += "[refusal[1]]: броня поменялась — [health] → [armor.ce_health] HP"
	if(steel.get_amount() != 5)
		failures += "отказы потратили сталь: осталось [steel.get_amount()] из 5"
	if(QDELETED(kit) || kit.uses != 1)
		failures += "отказ потратил набор кузнеца"

/**
 * Клик доходит до конца: по пластине — латает её и тратит лист, по плитоноске — `use_tool()`
 * латает пластину в зоне прицела, набор кузнеца по керамике латает её и кончается. Прицела у
 * тестового человека нет, так что зона — торс.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_clicks(mob/living/carbon/human/H, list/failures)
	var/obj/item/stack/material/steel/steel = make(/obj/item/stack/material/steel, 5)
	var/datum/extension/armor/plate_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0.5)
	var/obj/item/clothing/plate = plate_armor.holder
	plate.forceMove(H.loc)
	var/plate_health = plate_armor.ce_health
	if(!plate.ce_try_armor_repair(steel, H) || plate_armor.ce_health <= plate_health || steel.get_amount() != 4)
		failures += "сталь по пластине: HP [plate_health] → [plate_armor.ce_health], осталось [steel.get_amount()] листов из 5"

	var/obj/item/clothing/suit/armor/pcarrier/carrier = make(/obj/item/clothing/suit/armor/pcarrier)
	carrier.forceMove(H.loc)
	var/obj/item/clothing/accessory/armor_plate/medium/carried_plate = new(carrier)
	carrier.attach_accessory(null, carried_plate)
	var/datum/extension/armor/carried_armor = get_extension(carried_plate, /datum/extension/armor)
	carried_armor.ce_health = carried_armor.ce_get_health_max() / 2
	var/carried_health = carried_armor.ce_health
	var/obj/item/stack/material/cloth/cloth = make(/obj/item/stack/material/cloth, 5)
	carrier.use_tool(cloth, H)
	if(carried_armor.ce_health <= carried_health || cloth.get_amount() != 4)
		failures += "ткань по плитоноске: HP пластины [carried_health] → [carried_armor.ce_health], осталось [cloth.get_amount()] ткани из 5"

	var/obj/item/ce_blacksmith_kit/kit = make(/obj/item/ce_blacksmith_kit)
	var/datum/extension/armor/ceramic_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/tactical, 0.5)
	var/obj/item/clothing/ceramic_plate = ceramic_armor.holder
	ceramic_plate.forceMove(H.loc)
	var/ceramic_health = ceramic_armor.ce_health
	if(!ceramic_plate.ce_try_armor_repair(kit, H) || ceramic_armor.ce_health <= ceramic_health || !QDELETED(kit))
		failures += "набор кузнеца по керамике: HP [ceramic_health] → [ceramic_armor.ce_health], набор [QDELETED(kit) ? "потрачен" : "остался"] — у него одна починка"

/**
 * Навык строительства меняет потерю предела, а не время: у обученного — ровно множитель хлама,
 * неумеха теряет больше, мастер меньше. Клик настоящий, с навыком человека.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_skill(mob/living/carbon/human/H, list/failures)
	if(ce_get_repair_skill_mult(SKILL_BASELINE) != 1 || ce_get_repair_skill_mult(SKILL_MIN) <= 1 || ce_get_repair_skill_mult(SKILL_MAX) >= 1)
		failures += "множитель потери: у неумехи [ce_get_repair_skill_mult(SKILL_MIN)], у обученного [ce_get_repair_skill_mult(SKILL_BASELINE)], у мастера [ce_get_repair_skill_mult(SKILL_MAX)]"

	var/singleton/ce_armor_repair/steel_junk = GET_SINGLETON(/singleton/ce_armor_repair/stack/steel)
	var/obj/item/stack/material/steel/steel = make(/obj/item/stack/material/steel, 5)
	for(var/level in list(SKILL_MIN, SKILL_BASELINE, SKILL_MAX))
		set_skills(H, list(SKILL_CONSTRUCTION = level))
		var/datum/extension/armor/armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0.5)
		var/obj/item/clothing/plate = armor.holder
		plate.forceMove(H.loc)
		var/health = armor.ce_health
		plate.ce_try_armor_repair(steel, H)
		var/restored = armor.ce_health - health
		var/expected_loss = restored * steel_junk.max_loss_mult * ce_get_repair_skill_mult(level)
		if(restored <= 0 || abs(armor.ce_get_health_lost() - expected_loss) > 0.0001)
			failures += "навык [level]: вернули [restored] HP, съели [armor.ce_get_health_lost()] HP предела, ожидалось [expected_loss]"
	set_skills(H, list())

/// Починка после ожидания: сталь тратит лист, скотч не кончается, и оба возвращают HP.
/datum/unit_test/combat_extended/armor_repair/proc/check_finish(mob/living/carbon/human/H, list/failures)
	var/obj/item/stack/material/steel/steel = make(/obj/item/stack/material/steel, 5)
	var/datum/extension/armor/metal_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/makeshift/medium, 0.5)
	var/metal_health = metal_armor.ce_health
	metal_armor.ce_finish_repair(GET_SINGLETON(/singleton/ce_armor_repair/stack/steel), null, null, steel, H)
	if(steel.get_amount() != 4 || metal_armor.ce_health <= metal_health)
		failures += "сталь: осталось [steel.get_amount()] листов из 5, HP [metal_health] → [metal_armor.ce_health]"

	var/obj/item/tape_roll/tape = make(/obj/item/tape_roll)
	var/datum/extension/armor/fabric_armor = worn_armor_of(/obj/item/clothing/accessory/armor_plate/medium, 0.5)
	var/fabric_health = fabric_armor.ce_health
	fabric_armor.ce_finish_repair(GET_SINGLETON(/singleton/ce_armor_repair/tape), null, null, tape, H)
	if(QDELETED(tape) || fabric_armor.ce_health <= fabric_health)
		failures += "скотч: [QDELETED(tape) ? "кончился" : "цел"], HP [fabric_health] → [fabric_armor.ce_health]"

/**
 * Пока у скафандра пробоина, сталь идёт на неё, как в Бэй: кор код латает ожог тремя листами, а
 * броня не меняется. Без пробоин та же сталь латает броню — группу зон прицела, торс.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_breaches(mob/living/carbon/human/H, list/failures)
	var/obj/item/clothing/suit/space/void/suit = make(/obj/item/clothing/suit/space/void)
	suit.forceMove(H.loc)
	set_extension(suit, /datum/extension/armor, list("melee" = ARMOR_MELEE_KNIVES, "bullet" = ARMOR_BALLISTIC_PISTOL))
	var/datum/extension/armor/armor = get_extension(suit, /datum/extension/armor)
	armor.ce_set_health(CE_ARMOR_ZONE_TORSO, armor.ce_get_health_max(CE_ARMOR_ZONE_TORSO) / 2)
	var/health = armor.ce_get_health(CE_ARMOR_ZONE_TORSO)
	if(suit.ce_has_breaches())
		failures += "новый войдсьют с пробоинами"

	var/datum/breach/breach = new
	breach.class = 1
	breach.damtype = DAMAGE_BURN
	breach.holder = suit
	suit.breaches += breach
	suit.calc_breach_damage()
	if(!suit.ce_has_breaches())
		failures += "пробоина не видна"
	var/obj/item/stack/material/steel/steel = make(/obj/item/stack/material/steel, 5)
	suit.use_tool(steel, H)
	if(steel.get_amount() != 2 || suit.ce_has_breaches())
		failures += "сталь по скафандру с ожогом: осталось [steel.get_amount()] листов из 5, пробоин [length(suit.breaches)] — кор код ожог не залатал"
	if(armor.ce_get_health(CE_ARMOR_ZONE_TORSO) != health)
		failures += "сталь по скафандру с пробоиной залатала броню: [health] → [armor.ce_get_health(CE_ARMOR_ZONE_TORSO)] HP"

	suit.use_tool(steel, H)
	if(armor.ce_get_health(CE_ARMOR_ZONE_TORSO) <= health || steel.get_amount() != 1)
		failures += "сталь по скафандру без пробоин: HP торса [health] → [armor.ce_get_health(CE_ARMOR_ZONE_TORSO)], осталось [steel.get_amount()] листов из 5"

/// Броня абляционного жилета, изношенная до доли `fraction` своих HP, с выгоревшим дотла покрытием.
/datum/unit_test/combat_extended/armor_repair/proc/spent_vest(fraction)
	var/datum/extension/armor/armor = worn_armor_of(/obj/item/clothing/suit/armor/laserproof, fraction)
	var/datum/ce_armor_heat/heat = armor.ce_get_or_create_heat(null)
	heat.coating_spent = armor.ce_get_coating_max()
	return armor

/**
 * Абляционную броню латают отражающими листами, и лист возвращает и HP, и выгоревшее покрытие, на
 * свои доли: серебро больше всех, дальше алюминий, стекло и сталь. Мягкий и металлический хлам её не
 * латает. Покрытие латается и у брони с целыми HP — настоящим кликом, листом из стопки. Набор
 * кузнеца латает HP, но не покрытие. Кодекс пишет, сколько покрытия вернёт лист.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_ablative(mob/living/carbon/human/H, list/failures)
	var/list/ladder = list(
		/singleton/ce_armor_repair/stack/ablative/silver,
		/singleton/ce_armor_repair/stack/ablative/aluminium,
		/singleton/ce_armor_repair/stack/ablative/glass,
		/singleton/ce_armor_repair/stack/ablative/steel
	)
	var/singleton/ce_armor_repair/better
	for(var/junk_type in ladder)
		var/singleton/ce_armor_repair/junk = GET_SINGLETON(junk_type)
		var/datum/extension/armor/vest = spent_vest(0.5)
		var/coating_max = vest.ce_get_coating_max()
		var/health = vest.ce_health
		vest.ce_apply_repair(junk)
		var/coating_back = coating_max - vest.ce_get_coating_spent()
		var/health_back = vest.ce_health - health
		if(abs(coating_back - coating_max * junk.coating_restore_share) > 0.001 || abs(health_back - vest.ce_get_health_max() * junk.repair_share) > 0.001)
			failures += "[junk_type]: вернул [health_back] HP и [coating_back] покрытия, ожидалось [vest.ce_get_health_max() * junk.repair_share] и [coating_max * junk.coating_restore_share]"
		if(better && (better.coating_restore_share <= junk.coating_restore_share || better.repair_share < junk.repair_share))
			failures += "[junk_type] латает не хуже [better.type]"
		better = junk

	var/datum/extension/armor/refused = spent_vest(0.5)
	for(var/junk_type in list(/singleton/ce_armor_repair/stack/cloth, /singleton/ce_armor_repair/stack/steel, /singleton/ce_armor_repair/tape))
		var/singleton/ce_armor_repair/junk = GET_SINGLETON(junk_type)
		if(junk.can_repair(refused))
			failures += "[junk_type] латает абляционный жилет"

	var/datum/extension/armor/intact = armor_of(/obj/item/clothing/suit/armor/laserproof)
	var/obj/item/clothing/vest_item = intact.holder
	vest_item.forceMove(H.loc)
	var/datum/ce_armor_heat/heat = intact.ce_get_or_create_heat(null)
	heat.coating_spent = intact.ce_get_coating_max()
	var/obj/item/stack/material/silver/silver = make(/obj/item/stack/material/silver, 5)
	if(!vest_item.ce_try_armor_repair(silver, H) || !isnull(intact.ce_health) || intact.ce_get_coating_spent() >= intact.ce_get_coating_max() || silver.get_amount() != 4)
		failures += "серебро по жилету с целыми HP: выгорело [intact.ce_get_coating_spent()] покрытия из [intact.ce_get_coating_max()], HP [intact.ce_health], осталось [silver.get_amount()] листов из 5"

	var/singleton/ce_armor_repair/kit = GET_SINGLETON(/singleton/ce_armor_repair/blacksmith_kit)
	var/datum/extension/armor/kit_vest = spent_vest(0.5)
	var/kit_health = kit_vest.ce_health
	kit_vest.ce_apply_repair(kit)
	if(kit_vest.ce_get_coating_spent() != kit_vest.ce_get_coating_max() || kit_vest.ce_health <= kit_health)
		failures += "набор кузнеца по абляционному жилету: HP [kit_health] → [kit_vest.ce_health], выгорело [kit_vest.ce_get_coating_spent()] покрытия из [kit_vest.ce_get_coating_max()]"

	var/codex = intact.ce_get_repair_codex_block()
	var/datum/extension/armor/steel_plate = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	if(!findtext(codex, "Silver sheet ×1 (+10%, -5% max, +25% coating)") || findtext(codex, "Cloth") || findtext(steel_plate.ce_get_repair_codex_block(), "coating"))
		failures += "кодекс починки абляционного жилета: «[codex]»"

/// Изнашивает все детали РИГа до половины HP, грудную секцию — каждую группу зон.
/datum/unit_test/combat_extended/armor_repair/proc/wear_rig(obj/item/rig/rig)
	for(var/obj/item/piece in list(rig.helmet, rig.gloves, rig.boots))
		var/datum/extension/armor/armor = get_extension(piece, /datum/extension/armor)
		armor.ce_health = armor.ce_get_health_max() / 2
	var/datum/extension/armor/chest = get_extension(rig.chest, /datum/extension/armor)
	for(var/group in chest.ce_get_zone_groups())
		chest.ce_set_health(group, chest.ce_get_health_max(group) / 2)

/// HP деталей РИГа: шлем, перчатки, ботинки и группы зон грудной секции.
/datum/unit_test/combat_extended/armor_repair/proc/rig_health(obj/item/rig/rig)
	. = list()
	for(var/obj/item/piece in list(rig.helmet, rig.gloves, rig.boots))
		var/datum/extension/armor/armor = get_extension(piece, /datum/extension/armor)
		.[piece.name] = armor.ce_health
	var/datum/extension/armor/chest = get_extension(rig.chest, /datum/extension/armor)
	for(var/group in chest.ce_get_zone_groups())
		.["[rig.chest.name] ([group])"] = chest.ce_get_health(group)

/**
 * РИГ латают, не надевая: клик хламом по блоку управления латает деталь в зоне прицела — шлем,
 * перчатки, ботинки или группу зон грудной секции — и ни одну другую, набором кузнеца тоже.
 * Починку убранной детали держит блок. Пока у грудной секции пробоина, сталь по блоку уходит на неё.
 * Осмотр блока молчит о новых деталях и говорит состояние каждой изношенной, с её названием.
 */
/datum/unit_test/combat_extended/armor_repair/proc/check_rig(mob/living/carbon/human/H, list/failures)
	var/obj/item/rig/rig = make(/obj/item/rig/merc)
	rig.forceMove(H.loc)
	H.zone_sel = new /obj/screen/zone_sel(null)
	spawned += H.zone_sel
	if(length(rig.ce_get_examine_lines()))
		failures += "осмотр нового РИГа: «[jointext(rig.ce_get_examine_lines(), "», «")]»"
	wear_rig(rig)
	var/examine = jointext(rig.ce_get_examine_lines(), "\n")
	var/list/labels = list(rig.helmet.name, rig.gloves.name, rig.boots.name)
	for(var/group in list(CE_ARMOR_ZONE_TORSO, CE_ARMOR_ZONE_ARMS, CE_ARMOR_ZONE_LEGS))
		labels += "[rig.chest.name], [group]"
	for(var/label in labels)
		if(!findtext(examine, "Armor condition ([label]): 50%/100%"))
			failures += "осмотр изношенного РИГа без «[label]»: «[examine]»"
	if(length(rig.ce_get_examine_lines()) != length(labels))
		failures += "осмотр изношенного РИГа: [length(rig.ce_get_examine_lines())] строк вместо [length(labels)]"
	var/obj/item/stack/material/steel/steel = make(/obj/item/stack/material/steel, 10)
	var/list/clicks = list(
		list(BP_CHEST, steel, "[rig.chest.name] ([CE_ARMOR_ZONE_TORSO])"),
		list(BP_L_ARM, steel, "[rig.chest.name] ([CE_ARMOR_ZONE_ARMS])"),
		list(BP_R_LEG, steel, "[rig.chest.name] ([CE_ARMOR_ZONE_LEGS])"),
		list(BP_HEAD, steel, rig.helmet.name),
		list(BP_R_HAND, make(/obj/item/ce_blacksmith_kit), rig.gloves.name),
		list(BP_L_FOOT, steel, rig.boots.name)
	)
	for(var/list/click in clicks)
		wear_rig(rig)
		var/list/before = rig_health(rig)
		H.zone_sel.selecting = click[1]
		var/obj/item/tool = click[2]
		var/tool_name = tool.name
		rig.use_tool(tool, H)
		var/list/after = rig_health(rig)
		var/list/repaired = list()
		for(var/part in before)
			if(after[part] != before[part])
				repaired += part
		if(length(repaired) != 1 || repaired[1] != click[3])
			failures += "[tool_name] по РИГу в [click[1]]: залатано «[jointext(repaired, "», «")]», ожидалось «[click[3]]»"
	if(rig.helmet.ce_get_do_after_target() != rig)
		failures += "починку убранного шлема держит [rig.helmet.ce_get_do_after_target()], а не блок РИГа"

	wear_rig(rig)
	var/datum/extension/armor/chest = get_extension(rig.chest, /datum/extension/armor)
	var/health = chest.ce_get_health(CE_ARMOR_ZONE_TORSO)
	var/datum/breach/breach = new
	breach.class = 1
	breach.damtype = DAMAGE_BURN
	breach.holder = rig.chest
	rig.chest.breaches += breach
	rig.chest.calc_breach_damage()
	H.zone_sel.selecting = BP_CHEST
	var/sheets = steel.get_amount()
	rig.use_tool(steel, H)
	if(rig.chest.ce_has_breaches() || chest.ce_get_health(CE_ARMOR_ZONE_TORSO) != health || steel.get_amount() != sheets - 3)
		failures += "сталь по РИГу с ожогом грудной секции: пробоин [length(rig.chest.breaches)], HP торса [health] → [chest.ce_get_health(CE_ARMOR_ZONE_TORSO)], потрачено [sheets - steel.get_amount()] листов вместо 3"
	H.zone_sel = null

/*
	Эффекты снарядов, зависящие от пробития (`projectile_effects.dm`). Дротик и нульглас летят
	настоящим `bullet_act()`: так проверяется вся цепочка — обёртка, запись итога проходом по
	слоям и правка кор кода в вызове `on_hit()`.

	Дротик бьёт в руку под наручами: `can_inject()` смотрит только одежду, не аксессуары, и
	наручи ему не помеха — остановить укол может только броня. Грудь для этого не годится:
	плитоноска — толстая ткань, и `can_inject()` не пустит дротик и без мода.

	Застревание от остановленной пули Bay разыгрывает двумя бросками — порез от тупого удара и
	само застревание, — поэтому `after_wounding()` проверяется ещё и напрямую, с готовым порезом и
	шансом застревания 100%.
*/
/datum/unit_test/combat_extended/projectile_effects
	name = "CE: Эффекты снарядов требуют пробития"

/datum/unit_test/combat_extended/projectile_effects/start_test()
	var/old_enabled = ce_penetration_effects_enabled
	var/old_wear = ce_armor_wear_enabled
	ce_penetration_effects_enabled = TRUE
	// Каждый случай бьёт одну плиту дважды — чужим проходом и своим, — и второй не должен
	// приходить по изношенной.
	ce_armor_wear_enabled = FALSE
	var/list/failures = list()
	check_outcome(failures)
	check_on_hit_blocked(failures)
	check_dart(failures)
	check_wounding(failures)
	check_nullglass(failures)
	ce_penetration_effects_enabled = old_enabled
	ce_armor_wear_enabled = old_wear
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Остановленный бронёй снаряд не застревает, а помеченный не впрыскивает; пробивший — как в Bay.")
	return 1

/datum/unit_test/combat_extended/projectile_effects/proc/check_outcome(list/failures)
	// Название, пластины, снаряд, ожидаемый итог.
	var/list/cases = list(
		list("пистолет по голой груди", null, /obj/item/projectile/bullet/pistol, FALSE),
		list("пистолет через light", list(/obj/item/clothing/accessory/armor_plate), /obj/item/projectile/bullet/pistol, FALSE),
		list("пистолет в medium", list(/obj/item/clothing/accessory/armor_plate/medium), /obj/item/projectile/bullet/pistol, TRUE),
		list("дротик в light", list(/obj/item/clothing/accessory/armor_plate), /obj/item/projectile/bullet/chemdart, TRUE),
		list("лазер по голой груди", null, /obj/item/projectile/beam, FALSE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = make_human(test_case[2])
		if(!H)
			failures += "[test_case[1]]: не удалось создать цель"
			continue
		var/projectile_type = test_case[3]
		var/obj/item/projectile/projectile = new projectile_type(H.loc)
		spawned += projectile
		H.ce_hit_projectile = projectile

		// Остаточный удар и урон из `on_hit()` приходят со своим уроном и итог не пишут.
		projectile_hit(H, projectile, projectile.damage + 1)
		if(!isnull(projectile.ce_armor_stopped) || H.ce_hit_projectile != projectile)
			failures += "[test_case[1]]: проход с чужим уроном записал итог"
			continue

		projectile_hit(H, projectile, projectile.damage)
		if(projectile.ce_armor_stopped != test_case[4])
			failures += "[test_case[1]]: остановлен — [projectile.ce_armor_stopped], ожидалось [test_case[4]]"
		if(H.ce_hit_projectile)
			failures += "[test_case[1]]: после записи итога ссылка на снаряд осталась"
		H.ce_hit_projectile = null

/// Проход по слоям в грудь с уроном `damage` и остальным от снаряда, как у настоящего попадания.
/datum/unit_test/combat_extended/projectile_effects/proc/projectile_hit(mob/living/carbon/human/H, obj/item/projectile/projectile, damage)
	H.modify_damage_by_armor(BP_CHEST, damage, projectile.damage_type, projectile.damage_flags(), H, projectile.armor_penetration, TRUE)
	H.ce_hit_context = null
	H.ce_pending_residual = null
	H.ce_pending_shards = null

/datum/unit_test/combat_extended/projectile_effects/proc/check_on_hit_blocked(list/failures)
	var/obj/item/projectile/bullet/chemdart/dart = new
	var/obj/item/projectile/bullet/pistol/bullet = new
	spawned += dart
	spawned += bullet
	// Название, снаряд, итог прохода, выключатель, ожидаемая доля блока из 0.3.
	var/list/cases = list(
		list("остановленный дротик", dart, TRUE, TRUE, 100),
		list("пробивший дротик", dart, FALSE, TRUE, 0.3),
		list("дротик без прохода", dart, null, TRUE, 0.3),
		list("остановленная пуля без флага", bullet, TRUE, TRUE, 0.3),
		list("остановленный дротик с выключенным модом", dart, TRUE, FALSE, 0.3)
	)
	for(var/list/test_case as anything in cases)
		var/obj/item/projectile/projectile = test_case[2]
		projectile.ce_armor_stopped = test_case[3]
		ce_penetration_effects_enabled = test_case[4]
		var/blocked = projectile.ce_get_on_hit_blocked(0.3)
		ce_penetration_effects_enabled = TRUE
		if(blocked != test_case[5])
			failures += "[test_case[1]]: доля блока в `on_hit()` [blocked], ожидалось [test_case[5]]"

/datum/unit_test/combat_extended/projectile_effects/proc/check_dart(list/failures)
	// Название, пластины, выключатель, впрыснул ли.
	var/list/cases = list(
		list("в голую руку", null, TRUE, TRUE),
		list("в руку под наручами", list(/obj/item/clothing/accessory/arm_guards), TRUE, FALSE),
		list("в руку под наручами с выключенным модом", list(/obj/item/clothing/accessory/arm_guards), FALSE, TRUE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = make_human(test_case[2])
		if(!H)
			failures += "дротик [test_case[1]]: не удалось создать цель"
			continue
		if(H.can_inject(null, BP_L_ARM) != CAN_INJECT)
			failures += "дротик [test_case[1]]: `can_inject()` не пускает укол и без брони — проверять нечего"
			continue
		var/obj/item/projectile/bullet/chemdart/dart = new(H.loc)
		spawned += dart
		dart.reagents.add_reagent(/datum/reagent/water, dart.reagent_amount)

		ce_penetration_effects_enabled = test_case[3]
		H.bullet_act(dart, BP_L_ARM)
		ce_penetration_effects_enabled = TRUE

		var/injected = H.reagents.get_reagent_amount(/datum/reagent/water) > 0
		if(injected != test_case[4])
			failures += "дротик [test_case[1]]: впрыснул — [injected], ожидалось [test_case[4]]"
		if(!isnull(dart.ce_armor_stopped) || H.ce_hit_projectile)
			failures += "дротик [test_case[1]]: итог попадания пережил `bullet_act()`"

/datum/unit_test/combat_extended/projectile_effects/proc/check_wounding(list/failures)
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		failures += "не удалось создать цель для застревания"
		return
	// Название, конечность, итог прохода, выключатель, застрял ли.
	var/list/cases = list(
		list("остановленная пуля", BP_L_ARM, TRUE, TRUE, FALSE),
		list("пробившая пуля", BP_R_ARM, FALSE, TRUE, TRUE),
		list("остановленная пуля с выключенным модом", BP_L_LEG, TRUE, FALSE, TRUE)
	)
	for(var/list/test_case as anything in cases)
		var/obj/item/organ/external/organ = H.get_organ(test_case[2])
		var/datum/wound/cut = organ.take_external_damage(20, 0, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE)
		if(cut?.damage_type != INJURY_TYPE_CUT)
			failures += "[test_case[1]]: не вышло нанести порез"
			continue
		var/obj/item/projectile/bullet/nullglass/bullet = new(H.loc)
		spawned += bullet
		// Шанс застревания `0.5 × урон раны × penetration_modifier` — здесь заведомо больше 100.
		bullet.penetration_modifier = 1000
		bullet.ce_armor_stopped = test_case[3]

		ce_penetration_effects_enabled = test_case[4]
		bullet.after_wounding(organ, cut)
		ce_penetration_effects_enabled = TRUE

		var/embedded = length(find_nullglass(organ)) > 0
		if(embedded != test_case[5])
			failures += "[test_case[1]]: застряла — [embedded], ожидалось [test_case[5]]"

/*
	Нульглас глушит псионику осколком, застрявшим в ране (`disrupts_psionics()` обходит всё
	содержимое моба). Пробившая пуля застревает с шансом 100%. Остановленная тупым ударом режет
	только с шансом `prob(brute)` и застрять не должна никогда — это ловится лишь иногда, а
	наверняка — в `check_wounding()`.
*/
/datum/unit_test/combat_extended/projectile_effects/proc/check_nullglass(list/failures)
	// Название, пластины, глушит ли.
	var/list/cases = list(
		list("в голую грудь", null, TRUE),
		list("в грудь за medium", list(/obj/item/clothing/accessory/armor_plate/medium), FALSE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = make_human(test_case[2])
		if(!H)
			failures += "нульглас [test_case[1]]: не удалось создать цель"
			continue
		if(H.disrupts_psionics())
			failures += "нульглас [test_case[1]]: цель глушит псионику ещё до выстрела"
			continue
		var/obj/item/projectile/bullet/nullglass/bullet = new(H.loc)
		spawned += bullet
		bullet.penetration_modifier = 1000
		H.bullet_act(bullet, BP_CHEST)

		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		find_nullglass(chest)
		var/disrupted = istype(H.disrupts_psionics(), /obj/item/material/shard/nullglass)
		if(disrupted != test_case[3])
			failures += "нульглас [test_case[1]]: глушит псионику — [disrupted], ожидалось [test_case[3]]"

/// Осколки нульгласа, застрявшие в конечности. Удаляются вместе с тестом.
/datum/unit_test/combat_extended/projectile_effects/proc/find_nullglass(obj/item/organ/external/organ)
	. = list()
	for(var/obj/item/material/shard/nullglass/shard in organ.implants)
		. += shard
		spawned |= shard


/*
	Боль и оглушение против брони (`agony_armor.dm`). Снаряды летят настоящим `bullet_act()`, а
	дубинка бьёт настоящим `apply_hit_effect()`: так проверяется вся цепочка — запись доли урона
	проходом по слоям, правки кор кода в `on_hit()`, обёртка `bullet_act()` и оверрайд дубинки.

	Боль меряется на входе в `stun_effect_act()` (`/mob/living/carbon/human/ce_unit_test`), до
	сопротивления одежды току и множителя конечности. Ожидание — полная боль удара, умноженная на
	множитель боли от доли урона, которую даёт чистый запрос `ce_get_armor_pass_share()`.
	Остановленный удар не должен донести боли вовсе. Каждый случай бьёт ещё и с выключенным
	выключателем: боль, которую донёс бы Bay, — проверка, что этот удар вообще причиняет боль.
*/
#define CE_SHARE_STOPPED "остановлен"
#define CE_SHARE_PARTIAL "частично"
#define CE_SHARE_FULL "целиком"
/// Насколько дошедшая боль может разойтись с ожиданием: только погрешность чисел.
#define CE_AGONY_TOLERANCE 0.01
/// Оглушение, которое тест даёт снаряду и дубинке: своего у нелетального оружия почти нет.
#define CE_TEST_STUN 3

/// Человек, который копит боль и оглушение, дошедшие до `stun_effect_act()`, — до сопротивления
/// одежды току и множителя конечности.
/mob/living/carbon/human/ce_unit_test
	var/ce_received_agony = 0
	var/ce_received_stun = 0

/mob/living/carbon/human/ce_unit_test/stun_effect_act(stun_amount, agony_amount, def_zone)
	ce_received_agony += agony_amount
	ce_received_stun += stun_amount
	return ..()

/// Beanbag, который запоминает боль и оглушение на входе в `on_hit()` — уже после брони.
/obj/item/projectile/bullet/shotgun/beanbag/ce_unit_test
	var/list/ce_on_hit_effects

/obj/item/projectile/bullet/shotgun/beanbag/ce_unit_test/on_hit(atom/target, blocked = 0, def_zone = null)
	ce_on_hit_effects = ce_get_armor_effects()
	return ..()


/datum/unit_test/combat_extended/agony_armor
	name = "CE: Боль и оглушение против брони"

/datum/unit_test/combat_extended/agony_armor/start_test()
	var/old_enabled = ce_agony_armor_enabled
	var/list/failures = list()
	check_multiplier(failures)
	check_armor_hardness(failures)
	check_projectiles(failures)
	check_projectile_stun(failures)
	check_bullet_zone(failures)
	check_negative_agony(failures)
	check_baton(failures)
	ce_agony_armor_enabled = old_enabled
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Остановленный бронёй удар не причиняет боли и не оглушает, пробивший — меньше прямой доли урона; боль пули — в ту конечность и не отрицательная.")
	return 1

/// Цель теста: `outfit` — список аксессуаров плитоноски либо тип костюма. null — одеть не вышло.
/datum/unit_test/combat_extended/agony_armor/proc/make_target(outfit)
	if(!ispath(outfit))
		return make_human(outfit, /mob/living/carbon/human/ce_unit_test)
	var/mob/living/carbon/human/ce_unit_test/H = make_human(null, /mob/living/carbon/human/ce_unit_test)
	if(!H)
		return null
	var/obj/item/suit = new outfit(H.loc)
	H.equip_to_slot_or_del(suit, slot_wear_suit)
	return H.wear_suit == suit ? H : null

/datum/unit_test/combat_extended/agony_armor/proc/check_multiplier(list/failures)
	if(ce_get_agony_mult(0) != 0 || ce_get_agony_mult(-1) != 0)
		failures += "множитель боли остановленного удара не ноль"
	if(ce_get_agony_mult(1) != 1)
		failures += "множитель боли удара, прошедшего броню целиком, не единица"
	var/mult = ce_get_agony_mult(0.7)
	if(mult <= 0 || mult >= 0.7)
		failures += "доля урона 0.7 даёт множитель боли [mult], ожидалось больше нуля и меньше прямой доли"

/**
 * Жёсткость брони из случаев ниже. Войдсьют и грудь РИГа — жёсткая броня. Зимняя куртка СБ —
 * мягкая, но с энергетической бронёй: иначе проверять, что мягкая броня лучи не останавливает,
 * было бы не на чем.
 */
/datum/unit_test/combat_extended/agony_armor/proc/check_armor_hardness(list/failures)
	var/datum/extension/armor/voidsuit = armor_of(/obj/item/clothing/suit/space/void)
	if(!voidsuit?.is_hard_armor())
		failures += "войдсьют `suit/space/void` — не жёсткая броня"
	var/obj/item/rig/combat/rig = new
	spawned += rig
	var/datum/extension/armor/rig_chest = get_extension(rig.chest, /datum/extension/armor)
	if(!rig_chest?.is_hard_armor())
		failures += "грудь РИГа `rig/combat` — не жёсткая броня"
	var/datum/extension/armor/coat = armor_of(/obj/item/clothing/suit/storage/hooded/wintercoat/security)
	if(!coat || coat.is_hard_armor() || coat.get_value("energy") <= 0)
		failures += "зимняя куртка СБ — не мягкая броня с энергетической бронёй"

/datum/unit_test/combat_extended/agony_armor/proc/check_projectiles(list/failures)
	// Кевларовые вставки и обычный скрытый жилет — мягкая броня. Лёгкая стальная пластина и скрытый
	// тактический жилет — жёсткая с теми же числами Bay.
	var/list/light = list(/obj/item/clothing/accessory/armor_plate)
	var/list/medium = list(/obj/item/clothing/accessory/armor_plate/medium)
	var/list/low_profile = list(/obj/item/clothing/accessory/armor_plate/sneaky)
	var/list/light_metal = list(/obj/item/clothing/accessory/armor_plate/makeshift/light)
	var/list/low_profile_tactical = list(/obj/item/clothing/accessory/armor_plate/sneaky/tactical)
	var/list/merc = list(/obj/item/clothing/accessory/armor_plate/merc)
	var/list/guards = list(/obj/item/clothing/accessory/arm_guards)
	var/voidsuit = /obj/item/clothing/suit/space/void
	var/coat = /obj/item/clothing/suit/storage/hooded/wintercoat/security
	// Название, пластины или костюм, зона, снаряд, доля урона, урон вместо родного.
	var/list/cases = list(
		list("beanbag в голую грудь", null, BP_CHEST, /obj/item/projectile/bullet/shotgun/beanbag, CE_SHARE_FULL),
		list("beanbag через light-вставку", light, BP_CHEST, /obj/item/projectile/bullet/shotgun/beanbag, CE_SHARE_PARTIAL),
		list("beanbag через tactical", list(/obj/item/clothing/accessory/armor_plate/tactical), BP_CHEST, /obj/item/projectile/bullet/shotgun/beanbag, CE_SHARE_PARTIAL),
		list("beanbag в merc", merc, BP_CHEST, /obj/item/projectile/bullet/shotgun/beanbag, CE_SHARE_STOPPED),
		list("резиновая пуля в лёгкую стальную пластину", light_metal, BP_CHEST, /obj/item/projectile/bullet/pistol/rubber, CE_SHARE_STOPPED),
		list("резиновая пуля через light-вставку", light, BP_CHEST, /obj/item/projectile/bullet/pistol/rubber, CE_SHARE_PARTIAL),
		list("электрод нейтрализатора в light-вставку", light, BP_CHEST, /obj/item/projectile/bullet/electrode, CE_SHARE_STOPPED),
		list("stun-луч в голую руку", null, BP_L_ARM, /obj/item/projectile/beam/stun, CE_SHARE_FULL),
		list("stun-луч в руку под наручами", guards, BP_L_ARM, /obj/item/projectile/beam/stun, CE_SHARE_STOPPED),
		list("stun-луч в войдсьют", voidsuit, BP_CHEST, /obj/item/projectile/beam/stun, CE_SHARE_STOPPED),
		list("stun-луч через мягкую зимнюю куртку СБ", coat, BP_CHEST, /obj/item/projectile/beam/stun, CE_SHARE_FULL),
		list("stun-луч через мягкую medium-вставку", medium, BP_CHEST, /obj/item/projectile/beam/stun, CE_SHARE_FULL),
		list("электрод тазера в лёгкую стальную пластину", light_metal, BP_CHEST, /obj/item/projectile/energy/electrode, CE_SHARE_STOPPED),
		list("электрод тазера через мягкую light-вставку", light, BP_CHEST, /obj/item/projectile/energy/electrode, CE_SHARE_FULL),
		list("электрод тазера через мягкий скрытый жилет", low_profile, BP_CHEST, /obj/item/projectile/energy/electrode, CE_SHARE_FULL),
		list("электрод тазера в скрытый тактический жилет", low_profile_tactical, BP_CHEST, /obj/item/projectile/energy/electrode, CE_SHARE_STOPPED),
		list("plasmastun через лёгкую стальную пластину", light_metal, BP_CHEST, /obj/item/projectile/energy/plasmastun, CE_SHARE_FULL),
		list("plasmastun в скрытый тактический жилет", low_profile_tactical, BP_CHEST, /obj/item/projectile/energy/plasmastun, CE_SHARE_STOPPED),
		list("stun-луч в 40 урона через скрытый тактический жилет", low_profile_tactical, BP_CHEST, /obj/item/projectile/beam/stun, CE_SHARE_PARTIAL, 40),
		list("луч ксенофауны без урона в голую грудь", null, BP_CHEST, /obj/item/projectile/beam/xenofauna, CE_SHARE_FULL),
		list("луч ксенофауны без урона в лёгкую стальную пластину", light_metal, BP_CHEST, /obj/item/projectile/beam/xenofauna, CE_SHARE_STOPPED),
		list("луч ксенофауны без урона через мягкую зимнюю куртку СБ", coat, BP_CHEST, /obj/item/projectile/beam/xenofauna, CE_SHARE_FULL),
		list("болт арбалета без ключа брони в merc", merc, BP_CHEST, /obj/item/projectile/energy/bolt, CE_SHARE_FULL)
	)
	for(var/list/test_case as anything in cases)
		var/list/hit = shoot(test_case, TRUE)
		var/list/bay_hit = shoot(test_case, FALSE)
		if(!hit || !bay_hit)
			failures += "[test_case[1]]: не удалось создать цель"
			continue
		check_agony(failures, test_case[1], test_case[5], hit[2], hit[1], hit[5], bay_hit[1])
		if(!hit[3])
			failures += "[test_case[1]]: после `bullet_act()` снаряду не вернули боль и оглушение"
		if(hit[2] <= 0 && hit[4])
			failures += "[test_case[1]]: остановленный снаряд мутит взгляд"

/**
 * Выстрел настоящим `bullet_act()` по новой цели. Возвращает `list(дошедшая боль, доля урона по
 * чистому запросу, вернулись ли снаряду боль и оглушение, муть в глазах, полная боль снаряда)`,
 * null — цели нет.
 */
/datum/unit_test/combat_extended/agony_armor/proc/shoot(list/test_case, enabled)
	var/mob/living/carbon/human/ce_unit_test/H = make_target(test_case[2])
	if(!H)
		return null
	var/projectile_type = test_case[4]
	var/obj/item/projectile/projectile = new projectile_type(H.loc)
	spawned += projectile
	if(length(test_case) >= 6)
		projectile.damage = test_case[6]
	var/def_zone = test_case[3]
	var/share = H.ce_get_armor_pass_share(def_zone, projectile.damage, projectile.damage_type, projectile.damage_flags(), projectile.armor_penetration)
	var/effects = jointext(projectile.ce_get_armor_effects(), ",")

	ce_agony_armor_enabled = enabled
	H.bullet_act(projectile, def_zone)
	ce_agony_armor_enabled = TRUE

	var/restored = effects == jointext(projectile.ce_get_armor_effects(), ",")
	return list(H.ce_received_agony, share, restored, H.eye_blurry, projectile.agony)

/**
 * Боль после брони: `agony` — дошедшая с выключателем, `full_agony` — полная боль удара,
 * `bay_agony` — дошедшая без выключателя, `share` — доля урона по чистому запросу. Остановленный
 * удар не доносит боли вовсе, остальные доносят полную боль, умноженную на множитель боли.
 */
/datum/unit_test/combat_extended/agony_armor/proc/check_agony(list/failures, name, expected_share, share, agony, full_agony, bay_agony)
	check_share(failures, name, expected_share, share)
	if(bay_agony <= 0)
		failures += "[name]: боль не дошла и без мода — проверять нечего"
		return
	if(share <= 0)
		if(agony != 0)
			failures += "[name]: остановленный удар донёс [agony] боли (без мода [bay_agony])"
		return
	var/expected_agony = full_agony * ce_get_agony_mult(share)
	if(abs(agony - expected_agony) > CE_AGONY_TOLERANCE)
		failures += "[name]: боль [agony], ожидалось [expected_agony] (без мода [bay_agony])"

/// Сверяет долю урона по чистому запросу с ожидаемой: остановлен, частично или целиком.
/datum/unit_test/combat_extended/agony_armor/proc/check_share(list/failures, name, expected_share, share)
	var/actual_share = CE_SHARE_PARTIAL
	if(share <= 0)
		actual_share = CE_SHARE_STOPPED
	else if(share >= 1)
		actual_share = CE_SHARE_FULL
	if(actual_share != expected_share)
		failures += "[name]: доля урона [share] — [actual_share], ожидалось [expected_share]"

/*
	Оглушение снаряда: оглушение, сбивание с ног и муть в глазах. Beanbag получает их от теста и
	запоминает на входе в `on_hit()`. Там они должны быть полными, умноженными на тот же множитель,
	что и боль, — остановленный снаряд не оглушает вовсе. Без выключателя — полные, как в Bay. Цель
	должна получить оглушение, только если оно дошло до `on_hit()`.
*/
/datum/unit_test/combat_extended/agony_armor/proc/check_projectile_stun(list/failures)
	var/list/merc = list(/obj/item/clothing/accessory/armor_plate/merc)
	// Название, пластины, выключатель, доля урона.
	var/list/cases = list(
		list("в голую грудь", null, TRUE, CE_SHARE_FULL),
		list("через light", list(/obj/item/clothing/accessory/armor_plate), TRUE, CE_SHARE_PARTIAL),
		list("в merc", merc, TRUE, CE_SHARE_STOPPED),
		list("в merc с выключенным модом", merc, FALSE, CE_SHARE_STOPPED)
	)
	for(var/list/test_case as anything in cases)
		var/name = "оглушение beanbag [test_case[1]]"
		var/mob/living/carbon/human/H = make_human(test_case[2])
		if(!H)
			failures += "[name]: не удалось создать цель"
			continue
		var/obj/item/projectile/bullet/shotgun/beanbag/ce_unit_test/beanbag = new(H.loc)
		spawned += beanbag
		beanbag.stun = CE_TEST_STUN
		beanbag.weaken = CE_TEST_STUN
		beanbag.eyeblur = CE_TEST_STUN
		var/share = H.ce_get_armor_pass_share(BP_CHEST, beanbag.damage, beanbag.damage_type, beanbag.damage_flags(), beanbag.armor_penetration)
		check_share(failures, name, test_case[4], share)

		var/enabled = test_case[3]
		ce_agony_armor_enabled = enabled
		H.bullet_act(beanbag, BP_CHEST)
		ce_agony_armor_enabled = TRUE

		var/list/on_hit_effects = beanbag.ce_on_hit_effects
		if(!on_hit_effects)
			failures += "[name]: снаряд не дошёл до `on_hit()`"
			continue
		var/expected = enabled ? CE_TEST_STUN * ce_get_agony_mult(share) : CE_TEST_STUN
		var/list/passed = list("оглушение" = on_hit_effects[2], "сбивание с ног" = on_hit_effects[3], "муть в глазах" = on_hit_effects[6])
		for(var/effect in passed)
			if(abs(passed[effect] - expected) > CE_AGONY_TOLERANCE)
				failures += "[name]: [effect] на входе в `on_hit()` — [passed[effect]], ожидалось [expected]"
		var/list/received = list("оглушение" = H.stunned, "сбивание с ног" = H.weakened, "муть в глазах" = H.eye_blurry)
		for(var/effect in received)
			if(!!received[effect] != (expected > 0))
				failures += "[name]: [effect] у цели — [received[effect] || 0], ожидалось [expected > 0 ? "есть" : "нет"]"

/*
	Боль пули — в ту конечность, в которую она попала. Bay терял зону в `bullet/on_hit()`, и боль
	доставалась случайной конечности; три разные зоны подряд так почти наверняка не угадать.
*/
/datum/unit_test/combat_extended/agony_armor/proc/check_bullet_zone(list/failures)
	for(var/def_zone in list(BP_L_ARM, BP_R_LEG, BP_HEAD))
		var/mob/living/carbon/human/H = make_human()
		if(!H)
			failures += "зона пули [def_zone]: не удалось создать цель"
			continue
		var/obj/item/projectile/bullet/shotgun/beanbag/beanbag = new(H.loc)
		spawned += beanbag
		H.bullet_act(beanbag, def_zone)
		var/obj/item/organ/external/hit_organ = H.get_organ(def_zone)
		if(hit_organ.pain <= 0)
			failures += "beanbag в [def_zone]: боль не дошла до конечности попадания"
		for(var/obj/item/organ/external/organ as anything in H.organs)
			if(organ != hit_organ && organ.pain > 0)
				failures += "beanbag в [def_zone]: боль досталась [organ.organ_tag]"

/*
	Снаряд без боли не доносит отрицательной. Пистолет через light: плита снимает больше половины
	урона, и Bay вычитал эту долю блока из нулевой боли. Долю Bay передаёт, только если попадание
	оставило рану, поэтому снаряд — пуля, а не лазер: ожог рану не отдаёт. С выключенным
	выключателем правило мода не работает, а исправление — работает.
*/
/datum/unit_test/combat_extended/agony_armor/proc/check_negative_agony(list/failures)
	for(var/enabled in list(TRUE, FALSE))
		var/mob/living/carbon/human/ce_unit_test/H = make_target(list(/obj/item/clothing/accessory/armor_plate))
		if(!H)
			failures += "отрицательная боль: не удалось создать цель"
			continue
		var/obj/item/projectile/bullet/pistol/bullet = new(H.loc)
		spawned += bullet
		ce_agony_armor_enabled = enabled
		H.bullet_act(bullet, BP_CHEST)
		ce_agony_armor_enabled = TRUE
		if(H.ce_received_agony != 0)
			failures += "пистолет без боли через light[enabled ? "" : " с выключенным модом"]: донёс [H.ce_received_agony] боли"

/*
	Дубинка бьёт настоящим `apply_hit_effect()`. Тычок урона не наносит и касается брони, удар по
	намерению вреда проходит её как удар силой `force`. Полная боль дубинки — та, что доносит Bay:
	при ударе он сам её половинит. Оглушения у дубинки по умолчанию нет — тест даёт его, чтобы было
	что гасить.
*/
/datum/unit_test/combat_extended/agony_armor/proc/check_baton(list/failures)
	// Название, пластины, зона, намерение, доля урона.
	var/list/cases = list(
		list("тычок в голую руку", null, BP_L_ARM, I_HELP, CE_SHARE_FULL),
		list("тычок в руку под наручами", list(/obj/item/clothing/accessory/arm_guards), BP_L_ARM, I_HELP, CE_SHARE_STOPPED),
		list("удар в голую грудь", null, BP_CHEST, I_HURT, CE_SHARE_FULL),
		list("удар через light", list(/obj/item/clothing/accessory/armor_plate), BP_CHEST, I_HURT, CE_SHARE_PARTIAL),
		list("удар в merc", list(/obj/item/clothing/accessory/armor_plate/merc), BP_CHEST, I_HURT, CE_SHARE_STOPPED)
	)
	for(var/list/test_case as anything in cases)
		var/name = "дубинка, [test_case[1]]"
		var/list/hit = baton_hit(test_case, TRUE)
		var/list/bay_hit = baton_hit(test_case, FALSE)
		if(!hit || !bay_hit)
			failures += "[name]: не удалось создать цель"
			continue
		check_agony(failures, name, test_case[5], hit[2], hit[1], bay_hit[1], bay_hit[1])
		if(bay_hit[3] <= 0)
			failures += "[name]: оглушение не дошло и без мода — проверять нечего"
		var/expected_stun = bay_hit[3] * ce_get_agony_mult(hit[2])
		if(abs(hit[3] - expected_stun) > CE_AGONY_TOLERANCE)
			failures += "[name]: дошло оглушения [hit[3]], ожидалось [expected_stun] (без мода [bay_hit[3]])"
		if(!hit[4])
			failures += "[name]: после удара дубинке не вернули боль и оглушение"

/**
 * Удар дубинкой по новой цели. Возвращает `list(дошедшая боль, доля урона по чистому запросу,
 * дошедшее оглушение, вернулись ли дубинке боль и оглушение)`, null — цели нет.
 */
/datum/unit_test/combat_extended/agony_armor/proc/baton_hit(list/test_case, enabled)
	var/mob/living/carbon/human/ce_unit_test/target = make_target(test_case[2])
	var/mob/living/carbon/human/user = make_human()
	if(!target || !user)
		return null
	user.a_intent = test_case[4]
	var/obj/item/melee/baton/loaded/baton = new(user.loc)
	spawned += baton
	baton.stunforce = CE_TEST_STUN
	baton.change_status(TRUE)
	var/def_zone = test_case[3]
	var/damage = user.a_intent == I_HURT ? baton.force : 0
	var/share = target.ce_get_armor_pass_share(def_zone, damage, baton.damtype, baton.damage_flags(), baton.armor_penetration)

	ce_agony_armor_enabled = enabled
	baton.apply_hit_effect(target, user, def_zone)
	ce_agony_armor_enabled = TRUE

	var/restored = baton.agonyforce == initial(baton.agonyforce) && baton.stunforce == CE_TEST_STUN
	return list(target.ce_received_agony, share, target.ce_received_stun, restored)

#undef CE_SHARE_STOPPED
#undef CE_SHARE_PARTIAL
#undef CE_SHARE_FULL
#undef CE_AGONY_TOLERANCE
#undef CE_TEST_STUN


/*
	Щиты через проход по слоям (`shields.dm`): покрытие зон по стойке и руке, дуга, когда щит не
	прикрывает, проверки без урона и настоящие попадания — пули и лучи `bullet_act()`, удар
	`check_shields()` с `apply_damage()`, как в `resolve_item_attack()`. Щит держат в левой руке,
	носитель смотрит на север.

	Тупая волна сверяется с проходом по слоям, которому щит задан вручную: так проверяется, что
	настоящее попадание доводит щит до прохода и отдаёт волну в руку мимо её брони.
*/
#define CE_SHIELD_TOLERANCE 0.01

/// Аксессуар щита для теста: считает нажатия кнопки действия.
/obj/item/ce_shield_accessory/unit_test
	name = "test shield accessory"
	action_name = "Test Accessory"
	var/activations = 0

/obj/item/ce_shield_accessory/unit_test/activate(mob/living/user, obj/item/shield/shield)
	activations++


/datum/unit_test/combat_extended/shields
	name = "CE: Щиты"

/datum/unit_test/combat_extended/shields/start_test()
	var/old_enabled = ce_shields_enabled
	var/old_skill = ce_shield_cover_fire_skill
	var/list/failures = list()
	check_coverage(failures)
	check_arc(failures)
	check_readiness(failures)
	check_gates(failures)
	check_bullets(failures)
	check_back_shield(failures)
	check_beams(failures)
	check_melee(failures)
	check_firing(failures)
	check_stance_toggle(failures)
	check_accessory(failures)
	check_projector(failures)
	check_sprite(failures)
	check_switch(failures)
	ce_shields_enabled = old_enabled
	ce_shield_cover_fire_skill = old_skill
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Щит закрывает зоны стойки из дуги Bay; пробитый пропускает остаток, остановивший острое отдаёт тупую волну в руку мимо её брони; из стойки «укрыться» стреляет только мастер.")
	return 1

/// Носитель щита `shield_path` в слоте `slot`, лицом на север. null — не вышло.
/datum/unit_test/combat_extended/shields/proc/make_holder(shield_path, slot = slot_l_hand, list/outfit, mobtype = /mob/living/carbon/human)
	var/mob/living/carbon/human/H = make_human(outfit, mobtype)
	if(!H)
		return null
	var/obj/item/shield/shield = new shield_path(H.loc)
	spawned += shield
	if(!H.equip_to_slot_if_possible(shield, slot, TRYEQUIP_REDRAW | TRYEQUIP_INSTANT | TRYEQUIP_SILENT))
		return null
	var/obj/item/shield/energy/energy = shield
	if(istype(energy))
		energy.active = TRUE
	H.set_dir(NORTH)
	return H

/// Человек рядом с `H` в направлении `dir`.
/datum/unit_test/combat_extended/shields/proc/make_attacker(mob/living/carbon/human/H, dir)
	var/mob/living/carbon/human/attacker = make_human()
	var/turf/T = get_step(H, dir)
	if(!attacker || !T)
		return null
	attacker.forceMove(T)
	return attacker

/// Пуля или луч в грудь `H`, выпущенные из клетки в направлении `from_dir`.
/datum/unit_test/combat_extended/shields/proc/shoot(mob/living/carbon/human/H, projectile_type, from_dir)
	var/obj/item/projectile/projectile = new projectile_type(H.loc)
	spawned += projectile
	projectile.starting = get_step(H, from_dir)
	H.bullet_act(projectile, BP_CHEST)

/// Проход по слоям в грудь со щитом из слота `slot`, заданным вручную: `ce_walk_armor_layers()`.
/datum/unit_test/combat_extended/shields/proc/walk_with_shield(mob/living/carbon/human/H, projectile_type, slot, shock_zone)
	var/obj/item/projectile/projectile = new projectile_type(H.loc)
	spawned += projectile
	H.ce_shield_hit = new /datum/ce_shield_hit(slot, BP_CHEST, shock_zone, "test")
	. = H.ce_walk_armor_layers(BP_CHEST, projectile.damage, projectile.damage_type, projectile.damage_flags(), projectile.armor_penetration)
	H.ce_shield_hit = null

/datum/unit_test/combat_extended/shields/proc/check_coverage(list/failures)
	// Название, щит, слот, стойка, закрытые зоны.
	var/list/cases = list(
		list("riot в левой руке, целиться", /obj/item/shield/riot, slot_l_hand, CE_SHIELD_STANCE_AIM, list(BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_HAND)),
		list("riot в левой руке, укрыться", /obj/item/shield/riot, slot_l_hand, CE_SHIELD_STANCE_COVER, list(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_L_HAND, BP_R_ARM, BP_R_HAND)),
		list("riot в правой руке, целиться", /obj/item/shield/riot, slot_r_hand, CE_SHIELD_STANCE_AIM, list(BP_CHEST, BP_GROIN, BP_R_ARM, BP_R_HAND)),
		list("buckler", /obj/item/shield/buckler, slot_l_hand, CE_SHIELD_STANCE_AIM, list(BP_CHEST, BP_L_ARM, BP_L_HAND)),
		list("buckler со стойкой «укрыться», которой у него нет", /obj/item/shield/buckler, slot_l_hand, CE_SHIELD_STANCE_COVER, list(BP_CHEST, BP_L_ARM, BP_L_HAND)),
		list("riot на спине", /obj/item/shield/riot, slot_back, CE_SHIELD_STANCE_COVER, list(BP_CHEST, BP_GROIN))
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = make_holder(test_case[2], test_case[3])
		if(!H)
			failures += "покрытие, [test_case[1]]: не удалось создать носителя"
			continue
		var/obj/item/shield/shield = H.get_equipped_item(test_case[3])
		shield.ce_stance = test_case[4]
		var/list/covered = shield.ce_get_covered_zones(H)
		var/list/expected = test_case[5]
		if(length(covered ^ expected))
			failures += "покрытие, [test_case[1]]: [jointext(covered, ", ")], ожидалось [jointext(expected, ", ")]"

/datum/unit_test/combat_extended/shields/proc/check_arc(list/failures)
	// Название, слот щита, откуда атака, встречает ли её щит.
	var/list/cases = list(
		list("в руке, спереди", slot_l_hand, NORTH, TRUE),
		list("в руке, спереди-сбоку", slot_l_hand, NORTHEAST, TRUE),
		list("в руке, сбоку", slot_l_hand, EAST, FALSE),
		list("в руке, с другого бока", slot_l_hand, WEST, FALSE),
		list("в руке, сзади-сбоку", slot_l_hand, SOUTHEAST, FALSE),
		list("в руке, сзади", slot_l_hand, SOUTH, FALSE),
		list("на спине, сзади", slot_back, SOUTH, TRUE),
		list("на спине, сзади-сбоку", slot_back, SOUTHWEST, TRUE),
		list("на спине, спереди", slot_back, NORTH, FALSE),
		list("на спине, сбоку", slot_back, EAST, FALSE)
	)
	for(var/list/test_case as anything in cases)
		var/name = "дуга, щит [test_case[1]]"
		var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot, test_case[2])
		var/mob/living/carbon/human/attacker = H ? make_attacker(H, test_case[3]) : null
		if(!attacker)
			failures += "[name]: не удалось создать людей"
			continue
		var/obj/item/shield/shield = H.get_equipped_item(test_case[2])
		if(!!shield.ce_faces_attack(H, null, attacker) != test_case[4])
			failures += "[name]: [test_case[4] ? "не встречает" : "встречает"] атаку"
	// Снаряд — по клетке выстрела, а не по стрелку, и по углу, а не по восьми направлениям:
	// выстрел на 18° от взгляда встречен, на 72° — нет, хотя оба приходят с северо-востока.
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
	if(!H)
		failures += "дуга снаряда: не удалось создать носителя"
		return
	var/obj/item/shield/shield = H.l_hand
	// Смещение клетки выстрела, встречает ли её щит.
	var/list/shots = list(
		list(0, -1, FALSE),
		list(1, 3, TRUE),
		list(3, 1, FALSE)
	)
	for(var/list/shot as anything in shots)
		var/obj/item/projectile/projectile = new /obj/item/projectile/bullet/pistol(H.loc)
		spawned += projectile
		projectile.starting = locate(H.x + shot[1], H.y + shot[2], H.z)
		if(!projectile.starting)
			failures += "дуга снаряда со смещением [shot[1]], [shot[2]]: клетки нет на карте"
			continue
		if(!!shield.ce_faces_attack(H, projectile, null) != shot[3])
			failures += "дуга: выстрел со смещением [shot[1]], [shot[2]] [shot[3] ? "не встречен" : "встречен"] щитом в руке"

/datum/unit_test/combat_extended/shields/proc/check_readiness(list/failures)
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
	var/mob/living/carbon/human/attacker = H ? make_attacker(H, NORTH) : null
	if(!attacker)
		failures += "готовность щита: не удалось создать людей"
		return
	if(!H.ce_find_blocking_shield(BP_CHEST, null, attacker))
		failures += "готовность щита: стоящий носитель не прикрыт"
	H.lying = TRUE
	if(H.ce_find_blocking_shield(BP_CHEST, null, attacker))
		failures += "готовность щита: лежащий носитель прикрыт"
	H.lying = FALSE

	var/mob/living/carbon/human/E = make_holder(/obj/item/shield/energy)
	if(!E)
		failures += "готовность щита: не удалось создать носителя энергощита"
		return
	var/obj/item/shield/energy/energy = E.l_hand
	energy.active = FALSE
	attacker.forceMove(get_step(E, NORTH))
	if(E.ce_find_blocking_shield(BP_CHEST, null, attacker))
		failures += "готовность щита: выключенный энергощит прикрывает"

/datum/unit_test/combat_extended/shields/proc/check_gates(list/failures)
	// Название, откуда, зона, стойка, блок.
	var/list/cases = list(
		list("обезоруживание спереди в грудь", NORTH, BP_CHEST, CE_SHIELD_STANCE_AIM, TRUE),
		list("обезоруживание сзади в грудь", SOUTH, BP_CHEST, CE_SHIELD_STANCE_AIM, FALSE),
		list("укол шприцем с текстом вместо зоны", NORTH, "the syringe", CE_SHIELD_STANCE_AIM, TRUE),
		list("захват головы в стойке «целиться»", NORTH, BP_HEAD, CE_SHIELD_STANCE_AIM, FALSE),
		list("захват головы в стойке «укрыться»", NORTH, BP_HEAD, CE_SHIELD_STANCE_COVER, TRUE)
	)
	for(var/list/test_case as anything in cases)
		var/name = "проверка без урона, [test_case[1]]"
		var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
		var/mob/living/carbon/human/attacker = H ? make_attacker(H, test_case[2]) : null
		if(!attacker)
			failures += "[name]: не удалось создать людей"
			continue
		var/obj/item/shield/shield = H.l_hand
		shield.ce_stance = test_case[4]
		var/blocked = H.check_shields(0, null, attacker, test_case[3], "the test")
		if(!!blocked != test_case[5])
			failures += "[name]: [blocked ? "заблокировано" : "не заблокировано"]"
		if(H.ce_shield_hit)
			failures += "[name]: щит остался ждать урона"

/datum/unit_test/combat_extended/shields/proc/check_bullets(list/failures)
	var/rifle = /obj/item/projectile/bullet/rifle
	// Пластасталевый щит останавливает винтовку, волна — в левую руку, мимо наручей.
	for(var/guarded in list(FALSE, TRUE))
		var/name = "винтовка в пластасталевый щит[guarded ? " с наручами" : ""]"
		var/list/outfit = guarded ? list(/obj/item/clothing/accessory/arm_guards) : null
		var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot/metal, slot_l_hand, outfit)
		if(!H)
			failures += "[name]: не удалось создать носителя"
			continue
		var/list/walk = walk_with_shield(H, rifle, slot_l_hand, BP_L_ARM)
		// Урон органа Bay округляет до десятых (`take_external_damage()`).
		var/expected_shock = round(walk[7], 0.1)
		if(!walk[6] || expected_shock <= 0)
			failures += "[name]: проход не останавливает пулю щитом с волной (остановлена [walk[6]], волна [expected_shock])"
		shoot(H, rifle, NORTH)
		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		var/obj/item/organ/external/arm = H.get_organ(BP_L_ARM)
		if(chest.brute_dam > 0)
			failures += "[name]: грудь получила [chest.brute_dam]"
		if(abs(arm.brute_dam - expected_shock) > CE_SHIELD_TOLERANCE)
			failures += "[name]: рука со щитом получила [arm.brute_dam], ожидалось [expected_shock]"
		if(H.ce_shield_hit)
			failures += "[name]: щит не забран попаданием"
		var/obj/item/shield/shield = H.l_hand
		var/datum/extension/armor/shield_armor = get_extension(shield, /datum/extension/armor)
		var/group = shield_armor.ce_get_wear_group()
		var/health = shield_armor.ce_get_health(group)
		if(isnull(health) || health >= shield_armor.ce_get_health_max(group))
			failures += "[name]: щит не износился"
		else if(!findtext(jointext(shield.ce_get_examine_lines(), " "), "Armor condition"))
			failures += "[name]: изношенный щит не показывает состояние брони при осмотре"

	// Сзади щит в руке не прикрывает.
	var/mob/living/carbon/human/back_shot = make_holder(/obj/item/shield/riot/metal)
	if(back_shot)
		shoot(back_shot, rifle, SOUTH)
		var/obj/item/organ/external/chest = back_shot.get_organ(BP_CHEST)
		if(chest.brute_dam <= 0)
			failures += "винтовка сзади в носителя пластасталевого щита: грудь цела"

	// Пластиковый щит пули пропускает — с потерей урона, и волны нет.
	var/mob/living/carbon/human/riot_holder = make_holder(/obj/item/shield/riot)
	if(riot_holder)
		var/list/walk = walk_with_shield(riot_holder, rifle, slot_l_hand, BP_L_ARM)
		shoot(riot_holder, rifle, NORTH)
		var/obj/item/organ/external/chest = riot_holder.get_organ(BP_CHEST)
		var/obj/item/organ/external/arm = riot_holder.get_organ(BP_L_ARM)
		var/obj/item/projectile/reference = new rifle
		spawned += reference
		if(walk[6] || walk[1] <= 0 || walk[1] >= reference.damage)
			failures += "винтовка в riot: проход даёт [walk[1]] из [reference.damage], ожидался пробитый щит с потерей урона"
		if(chest.brute_dam <= 0)
			failures += "винтовка в riot: грудь цела"
		if(arm.brute_dam > 0)
			failures += "винтовка в riot: рука со щитом получила [arm.brute_dam]"

	// Энергощит нематериален: пистолет, остановленный им, волны в руку не даёт. Без флага волна
	// была бы — иначе проверять нечего.
	var/mob/living/carbon/human/field_holder = make_holder(/obj/item/shield/energy)
	if(field_holder)
		var/obj/item/shield/field = field_holder.l_hand
		var/pistol = /obj/item/projectile/bullet/pistol
		field.ce_armor_nonphysical = FALSE
		var/list/physical_walk = walk_with_shield(field_holder, pistol, slot_l_hand, BP_L_ARM)
		field.ce_armor_nonphysical = TRUE
		var/list/field_walk = walk_with_shield(field_holder, pistol, slot_l_hand, BP_L_ARM)
		if(physical_walk[7] <= 0)
			failures += "пистолет в энергощит: и без флага волны нет — проверять нечего"
		if(!field_walk[6] || field_walk[7] > 0)
			failures += "пистолет в энергощит: проход даёт волну [field_walk[7]], остановлена [field_walk[6]]"
		shoot(field_holder, pistol, NORTH)
		var/obj/item/organ/external/chest = field_holder.get_organ(BP_CHEST)
		var/obj/item/organ/external/arm = field_holder.get_organ(BP_L_ARM)
		if(chest.brute_dam > 0 || arm.brute_dam > 0)
			failures += "пистолет в энергощит: грудь получила [chest.brute_dam], рука со щитом — [arm.brute_dam]"
		var/datum/extension/armor/field_armor = get_extension(field, /datum/extension/armor)
		if(!isnull(field_armor.ce_health))
			failures += "пистолет в энергощит: нематериальный щит износился"
	else
		failures += "пистолет в энергощит: не удалось создать носителя"

	// Beanbag гасится пластиковым щитом целиком, вместе с болью.
	var/mob/living/carbon/human/ce_unit_test/beanbag_target = make_holder(/obj/item/shield/riot, slot_l_hand, null, /mob/living/carbon/human/ce_unit_test)
	if(beanbag_target)
		shoot(beanbag_target, /obj/item/projectile/bullet/shotgun/beanbag, NORTH)
		var/obj/item/organ/external/chest = beanbag_target.get_organ(BP_CHEST)
		if(chest.brute_dam > 0 || beanbag_target.ce_received_agony > 0)
			failures += "beanbag в riot: грудь получила [chest.brute_dam] урона и [beanbag_target.ce_received_agony] боли"

/datum/unit_test/combat_extended/shields/proc/check_back_shield(list/failures)
	var/rifle = /obj/item/projectile/bullet/rifle
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot/metal, slot_back)
	if(!H)
		failures += "щит на спине: не удалось создать носителя"
		return
	var/list/walk = walk_with_shield(H, rifle, slot_back, BP_CHEST)
	var/expected_shock = round(walk[7], 0.1)
	shoot(H, rifle, SOUTH)
	var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
	if(expected_shock <= 0 || abs(chest.brute_dam - expected_shock) > CE_SHIELD_TOLERANCE)
		failures += "винтовка сзади в щит на спине: грудь получила [chest.brute_dam], ожидалась волна [expected_shock]"

	var/mob/living/carbon/human/front = make_holder(/obj/item/shield/riot/metal, slot_back)
	if(!front)
		failures += "щит на спине: не удалось создать второго носителя"
		return
	shoot(front, rifle, NORTH)
	var/obj/item/organ/external/front_chest = front.get_organ(BP_CHEST)
	if(front_chest.brute_dam <= expected_shock)
		failures += "винтовка спереди в носителя щита на спине: грудь получила [front_chest.brute_dam], не больше волны [expected_shock]"

/datum/unit_test/combat_extended/shields/proc/check_beams(list/failures)
	// Название, щит, прошёл ли лазер.
	var/list/cases = list(
		list("лазер в riot", /obj/item/shield/riot, TRUE),
		list("лазер в пластасталевый щит", /obj/item/shield/riot/metal, FALSE),
		list("лазер во включённый энергощит", /obj/item/shield/energy, FALSE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = make_holder(test_case[2])
		if(!H)
			failures += "[test_case[1]]: не удалось создать носителя"
			continue
		shoot(H, /obj/item/projectile/beam, NORTH)
		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		if((chest.burn_dam > 0) != test_case[3])
			failures += "[test_case[1]]: грудь получила [chest.burn_dam] ожога, ожидалось [test_case[3] ? "больше нуля" : "ноль"]"

/datum/unit_test/combat_extended/shields/proc/check_melee(list/failures)
	// Название, откуда удар, закрыта ли грудь.
	var/list/cases = list(
		list("нож спереди в riot", NORTH, TRUE),
		list("нож сбоку в носителя riot", EAST, FALSE),
		list("нож сзади в носителя riot", SOUTH, FALSE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
		var/mob/living/carbon/human/attacker = H ? make_attacker(H, test_case[2]) : null
		if(!attacker)
			failures += "[test_case[1]]: не удалось создать людей"
			continue
		var/obj/item/material/knife/combat/knife = new(attacker.loc)
		spawned += knife
		H.ce_shield_armor_call = TRUE
		var/blocked = H.check_shields(knife.force, knife, attacker, BP_CHEST, "the knife")
		H.ce_shield_armor_call = FALSE
		H.apply_damage(knife.force, knife.damtype, BP_CHEST, knife.damage_flags(), knife, knife.armor_penetration)
		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		if(blocked)
			failures += "[test_case[1]]: удар с уроном заблокирован сразу, а не щитом в проходе"
		if((chest.brute_dam <= 0) != test_case[3])
			failures += "[test_case[1]]: грудь получила [chest.brute_dam]"
		if(H.ce_shield_hit)
			failures += "[test_case[1]]: щит не забран ударом"

/datum/unit_test/combat_extended/shields/proc/check_firing(list/failures)
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
	if(!H)
		failures += "стрельба из-за щита: не удалось создать носителя"
		return
	var/obj/item/shield/shield = H.l_hand
	if(H.get_skill_value(SKILL_WEAPONS) >= ce_shield_cover_fire_skill)
		failures += "стрельба из-за щита: у тестового человека навык мастера, проверять нечего"
		return
	if(H.ce_shield_blocks_firing())
		failures += "стрельба из-за щита: стойка «целиться» не даёт стрелять"
	shield.ce_stance = CE_SHIELD_STANCE_COVER
	if(!H.ce_shield_blocks_firing())
		failures += "стрельба из-за щита: не мастер стреляет из стойки «укрыться»"

	ce_shield_cover_fire_skill = H.get_skill_value(SKILL_WEAPONS)
	if(H.ce_shield_blocks_firing())
		failures += "стрельба из-за щита: мастер не стреляет из стойки «укрыться»"
	H.ce_note_shot()
	var/list/exposed = shield.ce_get_covered_zones(H)
	if((BP_HEAD in exposed) || (BP_R_ARM in exposed) || !(BP_CHEST in exposed))
		failures += "стрельба из-за щита: после выстрела закрыты [jointext(exposed, ", ")]"
	H.ce_shield_fire_exposed_until = world.time
	if(!(BP_HEAD in shield.ce_get_covered_zones(H)))
		failures += "стрельба из-за щита: голова не закрыта снова, когда окно прошло"

	H.ce_note_melee_attack(1 SECOND)
	var/list/after_swing = shield.ce_get_covered_zones(H)
	if((BP_R_ARM in after_swing) || !(BP_HEAD in after_swing))
		failures += "удар из-за щита: закрыты [jointext(after_swing, ", ")], ожидались все зоны стойки, кроме руки с оружием"

/datum/unit_test/combat_extended/shields/proc/check_stance_toggle(list/failures)
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
	if(!H)
		failures += "стойка: не удалось создать носителя"
		return
	var/obj/item/shield/shield = H.l_hand
	shield.attack_self(H)
	if(shield.ce_stance != CE_SHIELD_STANCE_COVER)
		failures += "стойка: использование в руке не переключает на «укрыться»"
	shield.attack_self(H)
	if(shield.ce_stance != CE_SHIELD_STANCE_AIM)
		failures += "стойка: использование в руке не переключает обратно на «целиться»"

	var/mob/living/carbon/human/E = make_holder(/obj/item/shield/energy)
	if(!E)
		failures += "стойка энергощита: не удалось создать носителя"
		return
	var/obj/item/shield/energy/energy = E.l_hand
	energy.active = FALSE
	energy.attack_self(E)
	if(!energy.active || energy.ce_stance != CE_SHIELD_STANCE_AIM)
		failures += "стойка энергощита: использование выключенного не включает его или меняет стойку"
	energy.attack_self(E)
	if(!energy.active || energy.ce_stance != CE_SHIELD_STANCE_COVER)
		failures += "стойка энергощита: использование включённого не переключает стойку"
	energy.AltClick(E)
	if(energy.active)
		failures += "стойка энергощита: альт-клик не выключает его"

	var/mob/living/carbon/human/B = make_holder(/obj/item/shield/buckler)
	if(!B)
		failures += "стойка баклера: не удалось создать носителя"
		return
	var/obj/item/shield/buckler = B.l_hand
	buckler.attack_self(B)
	if(buckler.ce_stance != CE_SHIELD_STANCE_AIM)
		failures += "стойка баклера: использование в руке переключает стойку, которой у него нет"

/datum/unit_test/combat_extended/shields/proc/check_accessory(list/failures)
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
	if(!H)
		failures += "аксессуар: не удалось создать носителя"
		return
	var/obj/item/shield/shield = H.l_hand
	var/obj/item/ce_shield_accessory/unit_test/accessory = new(H.loc)
	spawned += accessory
	H.put_in_r_hand(accessory)
	shield.use_tool(accessory, H, list())
	if(shield.ce_accessory != accessory || accessory.loc != shield || shield.action_button_name != accessory.action_name)
		failures += "аксессуар: не повешен на riot"
		return
	var/stance = shield.ce_stance
	shield.ui_action_click(H)
	if(accessory.activations != 1 || shield.ce_stance != stance)
		failures += "аксессуар: кнопка действия щита не работает от аксессуара"
	var/obj/item/screwdriver/screwdriver = new(H.loc)
	spawned += screwdriver
	shield.use_tool(screwdriver, H, list())
	if(shield.ce_accessory || shield.action_button_name || !H.IsHolding(accessory))
		failures += "аксессуар: отвёртка не снимает его в руки"

	var/mob/living/carbon/human/B = make_holder(/obj/item/shield/buckler)
	if(!B)
		failures += "аксессуар: не удалось создать носителя баклера"
		return
	var/obj/item/shield/buckler = B.l_hand
	var/obj/item/ce_shield_accessory/unit_test/refused = new(B.loc)
	spawned += refused
	B.put_in_r_hand(refused)
	if(buckler.ce_attach_accessory(refused, B) || buckler.ce_accessory)
		failures += "аксессуар: повешен на баклер без места под него"

	// Место под аксессуар — только у riot и пластасталевого щита. Новый подтип riot, унаследовавший
	// его молча, тест поймает.
	var/list/with_slot = list(/obj/item/shield/riot, /obj/item/shield/riot/metal)
	for(var/shield_type in typesof(/obj/item/shield))
		var/obj/item/shield/shield_path = shield_type
		var/has_slot = !!initial(shield_path.ce_accessory_slot)
		if(has_slot != (shield_type in with_slot))
			failures += "аксессуар: место под него у [shield_type] — [has_slot ? "есть" : "нет"]"

/*
	Прожектор: кнопка действия щита включает свет, как у аварийного прожектора, а альт-клик куда
	угодно при включённом свете — вспышка. Погасший прожектор альт-клик не разбирает. Альт-клик
	по самому щиту в руке — тоже вспышка, про запас. Вспышка слепит того, кого луч освещает и кто
	смотрит на носителя, и только его: не того, кто смотрит в сторону, не того, кто за спиной
	носителя, не того, кто в сварочных очках, и не того, до кого луч не доходит из-за занавески.
	Освещённого, но смотрящего в сторону, и самого носителя вспышка лишь засвечивает, без
	ослепления; в сварочных очках и вне луча — не засвечивает. Перезарядка не даёт второй вспышки
	сразу. Свет тест пересчитывает сам (`relight()`), не
	дожидаясь SSlighting.
*/
/datum/unit_test/combat_extended/shields/proc/check_projector(list/failures)
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot)
	if(!H)
		failures += "прожектор: не удалось создать носителя"
		return
	var/obj/item/shield/shield = H.l_hand
	var/obj/item/ce_shield_accessory/projector/projector = new(H.loc)
	spawned += projector
	H.put_in_r_hand(projector)
	shield.use_tool(projector, H, list())
	if(shield.ce_accessory != projector)
		failures += "прожектор: не повешен на riot"
		return

	// Клетка в двух шагах: альт-клик по соседней клетке без клиента упал бы в панели «Turf».
	var/turf/far_turf = locate(H.x, H.y + 2, H.z)
	shield.AltClick(H)
	if(H.AltClickOn(far_turf))
		failures += "прожектор: погасший разбирает альт-клик куда угодно"
	if(projector.next_dazzle)
		failures += "прожектор: выключенный вспыхивает"
	shield.ui_action_click(H)
	if(!projector.on || !shield.light || shield.light_range != projector.beam_range || shield.light_power != projector.beam_power || shield.light_wedge != projector.beam_angle)
		failures += "прожектор: кнопка действия щита не включает свет, как у аварийного прожектора"
		return

	// Название, смещение от носителя по x и y, куда смотрит, в сварочных очках ли, слепит ли,
	// засвечивает ли — полной вспышкой или лёгкой.
	var/list/cases = list(
		list("смотрит на свет", 0, 2, SOUTH, FALSE, TRUE, TRUE),
		list("смотрит в сторону", 1, 2, NORTH, FALSE, FALSE, TRUE),
		list("за спиной носителя", 0, -2, NORTH, FALSE, FALSE, FALSE),
		list("в сварочных очках", -1, 2, SOUTH, TRUE, FALSE, FALSE),
		list("в сварочных очках смотрит в сторону", -1, 3, NORTH, TRUE, FALSE, FALSE)
	)
	var/list/watchers = list()
	for(var/list/test_case as anything in cases)
		var/turf/T = locate(H.x + test_case[2], H.y + test_case[3], H.z)
		var/mob/living/carbon/human/watcher = make_human()
		if(!T || !watcher)
			failures += "прожектор, [test_case[1]]: не удалось поставить человека"
			continue
		watcher.forceMove(T)
		watcher.set_dir(test_case[4])
		if(test_case[5])
			var/obj/item/clothing/glasses/welding/goggles = new(T)
			spawned += goggles
			watcher.equip_to_slot_or_del(goggles, slot_glasses)
		watchers[watcher] = test_case
	if(!length(watchers))
		return
	relight(shield)
	if(!H.AltClickOn(far_turf))
		failures += "прожектор: альт-клик куда угодно при горящем прожекторе не разобран"
	for(var/mob/living/carbon/human/watcher as anything in watchers)
		var/list/test_case = watchers[watcher]
		var/dazzled = watcher.eye_blurry > 0 && watcher.is_confused()
		if(dazzled != test_case[6])
			failures += "прожектор, [test_case[1]]: [dazzled ? "ослеплён" : "не ослеплён"]"
		var/flashed = !!watcher.screens["flash"]
		if(flashed != test_case[7])
			failures += "прожектор, [test_case[1]]: [flashed ? "засвечен" : "не засвечен"]"
	// Носитель — за прожектором: засвечен, но не ослеплён.
	if(!H.screens["flash"] || H.eye_blurry || H.is_confused())
		failures += "прожектор, носитель: засвечен [!!H.screens["flash"]], муть [H.eye_blurry], растерян [H.is_confused()]; ожидалась лёгкая вспышка без ослепления"

	var/mob/living/carbon/human/looker = watchers[1]
	looker.eye_blurry = 0
	looker.clear_confused()
	shield.AltClick(H)
	if(looker.eye_blurry || looker.is_confused())
		failures += "прожектор: вторая вспышка прошла сквозь перезарядку"

	projector.next_dazzle = 0
	var/obj/structure/curtain/curtain = new(locate(H.x, H.y + 1, H.z))
	spawned += curtain
	relight(shield)
	shield.AltClick(H)
	if(looker.eye_blurry || looker.is_confused())
		failures += "прожектор: вспышка слепит сквозь занавеску"

	var/obj/item/screwdriver/screwdriver = new(H.loc)
	spawned += screwdriver
	shield.use_tool(screwdriver, H, list())
	if(projector.on || shield.light)
		failures += "прожектор: снятый со щита продолжает светить"

/// Пересчитывает свет щита сразу, не дожидаясь очереди SSlighting.
/datum/unit_test/combat_extended/shields/proc/relight(obj/item/shield/shield)
	var/datum/light_source/beam = shield.light
	if(!beam)
		return
	beam.needs_update = LIGHTING_FORCE_UPDATE
	beam.update_corners(TRUE)
	beam.needs_update = LIGHTING_NO_UPDATE

/*
	Спрайт в руке. Щит с `ce_cover_sprite_moves` в стойке «укрыться» сдвинут: лицом к зрителю
	середина щита на середине тела и щит поднят, спиной к зрителю — нетронут. Смена стойки сразу
	перерисовывает руки: прежнего спрайта среди слоёв человека больше нет. У riot в правой руке
	лицом на запад спрайт Bay отражён в любой стойке, у энергощита — нет. Спрайты сравниваются
	попиксельно: готовый `/icon` BYOND кладёт в кеш ресурсов, и по файлу его не узнать.
*/
/datum/unit_test/combat_extended/shields/proc/check_sprite(list/failures)
	for(var/slot in list(slot_l_hand, slot_r_hand))
		var/right = slot == slot_r_hand
		var/slot_name = right ? slot_r_hand_str : slot_l_hand_str
		var/name = "спрайт riot в [right ? "правой" : "левой"] руке"
		var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot, slot)
		if(!H)
			failures += "[name]: не удалось создать носителя"
			continue
		var/obj/item/shield/shield = H.get_equipped_item(slot)
		var/bay_file = GLOB.default_onmob_icons[slot_name]
		var/bay_state = shield.get_icon_state(H, slot_name)
		var/image/lowered = shield.get_mob_overlay(H, slot_name)
		if(!has_layer(H, lowered))
			failures += "[name]: спрайта щита нет среди слоёв человека"
		for(var/facing in GLOB.cardinal)
			var/icon/bay = icon(bay_file, bay_state, facing)
			var/flipped = right && facing == WEST
			if(flipped)
				bay.Flip(EAST)
			if(!same_sprite(icon(lowered.icon, lowered.icon_state, facing), bay))
				failures += "[name], «целиться», [dir2text(facing)]: не [flipped ? "отражённый " : ""]спрайт Bay"

		shield.attack_self(H)
		var/image/raised = shield.get_mob_overlay(H, slot_name)
		if(has_layer(H, lowered))
			failures += "[name]: смена стойки не перерисовала руки"
		var/icon/raised_south = icon(raised.icon, raised.icon_state, SOUTH)
		var/south_center = ce_get_sprite_center_x(raised_south)
		var/bay_center = ce_get_sprite_center_x(icon(bay_file, bay_state, SOUTH))
		var/expected_center = bay_center + round((raised_south.Width() / 2 - bay_center) * ce_shield_cover_sprite_pull, 1)
		if(isnull(south_center) || abs(south_center - expected_center) > 0.5)
			failures += "[name]: лицом к зрителю середина щита на [south_center] px, ожидалось [expected_center] — доля [ce_shield_cover_sprite_pull] пути к середине тела"
		if(abs(south_center - raised_south.Width() / 2) >= abs(bay_center - raised_south.Width() / 2))
			failures += "[name]: лицом к зрителю щит не приблизился к середине тела"
		if(sprite_top(raised_south) != sprite_top(icon(bay_file, bay_state, SOUTH)) + ce_shield_cover_sprite_rise)
			failures += "[name]: лицом к зрителю щит поднят не на [ce_shield_cover_sprite_rise] px"
		if(!same_sprite(icon(raised.icon, raised.icon_state, NORTH), icon(bay_file, bay_state, NORTH)))
			failures += "[name]: спиной к зрителю щит сдвинут"

	var/mob/living/carbon/human/E = make_holder(/obj/item/shield/energy, slot_r_hand)
	if(!E)
		failures += "спрайт энергощита: не удалось создать носителя"
		return
	var/obj/item/shield/energy/energy = E.r_hand
	var/image/energy_lowered = energy.get_mob_overlay(E, slot_r_hand_str)
	if(energy_lowered.icon != GLOB.default_onmob_icons[slot_r_hand_str])
		failures += "спрайт энергощита в правой руке: в «целиться» не спрайт Bay — отражён или сдвинут"
	energy.ce_stance = CE_SHIELD_STANCE_COVER
	var/image/energy_raised = energy.get_mob_overlay(E, slot_r_hand_str)
	if(energy_raised.icon == GLOB.default_onmob_icons[slot_r_hand_str])
		failures += "спрайт энергощита: включённый в «укрыться» не поднят"
	energy.active = FALSE
	var/image/energy_off = energy.get_mob_overlay(E, slot_r_hand_str)
	if(energy_off.icon != GLOB.default_onmob_icons[slot_r_hand_str])
		failures += "спрайт энергощита: выключенный рисуется поднятым"

	// Щит без `ce_cover_sprite_moves` в «укрыться» не сдвигается — так у хитиновых щитов генокрада.
	var/mob/living/carbon/human/U = make_holder(/obj/item/shield/riot)
	if(!U)
		failures += "спрайт щита без флага: не удалось создать носителя"
		return
	var/obj/item/shield/unmoved = U.l_hand
	unmoved.ce_cover_sprite_moves = FALSE
	unmoved.ce_stance = CE_SHIELD_STANCE_COVER
	var/image/unmoved_overlay = unmoved.get_mob_overlay(U, slot_l_hand_str)
	if(unmoved_overlay.icon != GLOB.default_onmob_icons[slot_l_hand_str])
		failures += "спрайт щита без флага: в «укрыться» сдвинут"

	var/mob/living/carbon/human/B = make_holder(/obj/item/shield/buckler)
	if(!B)
		failures += "спрайт баклера: не удалось создать носителя"
		return
	var/obj/item/shield/buckler = B.l_hand
	buckler.ce_stance = CE_SHIELD_STANCE_COVER
	var/image/buckler_overlay = buckler.get_mob_overlay(B, slot_l_hand_str)
	if(buckler_overlay.icon != GLOB.default_onmob_icons[slot_l_hand_str])
		failures += "спрайт баклера: сдвинут, хотя двигать его не нужно"

/// Совпадают ли спрайты попиксельно.
/datum/unit_test/combat_extended/shields/proc/same_sprite(icon/first, icon/second)
	if(first.Width() != second.Width() || first.Height() != second.Height())
		return FALSE
	for(var/x in 1 to first.Width())
		for(var/y in 1 to first.Height())
			if(first.GetPixel(x, y) != second.GetPixel(x, y))
				return FALSE
	return TRUE

/// Есть ли среди слоёв человека спрайт `sprite`: тот же файл и то же состояние.
/datum/unit_test/combat_extended/shields/proc/has_layer(mob/living/carbon/human/H, image/sprite)
	for(var/image/layer in H.overlays_standing)
		if(layer.icon == sprite.icon && layer.icon_state == sprite.icon_state)
			return TRUE
	return FALSE

/// Верхний непрозрачный ряд спрайта, px от нижнего края. null — спрайт пуст.
/datum/unit_test/combat_extended/shields/proc/sprite_top(icon/sprite)
	for(var/y = sprite.Height() to 1 step -1)
		for(var/x in 1 to sprite.Width())
			if(sprite.GetPixel(x, y))
				return y
	return null

/datum/unit_test/combat_extended/shields/proc/check_switch(list/failures)
	var/mob/living/carbon/human/H = make_holder(/obj/item/shield/riot/metal)
	var/mob/living/carbon/human/attacker = H ? make_attacker(H, NORTH) : null
	if(!attacker)
		failures += "выключатель: не удалось создать людей"
		return
	var/obj/item/shield/shield = H.l_hand
	ce_shields_enabled = FALSE
	H.ce_shield_armor_call = TRUE
	H.check_shields(45, null, attacker, BP_CHEST, "the test")
	H.ce_shield_armor_call = FALSE
	shield.attack_self(H)
	ce_shields_enabled = TRUE
	if(H.ce_shield_hit)
		failures += "выключатель: выключенный мод отдаёт щит проходу по слоям"
	if(shield.ce_stance != CE_SHIELD_STANCE_AIM)
		failures += "выключатель: выключенный мод переключает стойку"

#undef CE_SHIELD_TOLERANCE


/*
	Лазеры и нагрев брони (`laser_heat.dm`, `laser_coolant.dm`, `laser_scorch.dm`, блок РИГа —
	`rig_armor.dm`).

	Жар, остывание и ожоги считает тот же код, что и в игре, а время тест ведёт сам: между выстрелами
	батареи зовёт остывание брони на задержку выстрела ствола, а ожоги — через `handle_fire()`, как
	тик Life. Стреляет он настоящими лучами через боевой проход, так что множитель жара и сторону
	прожога проход берёт у снаряда.

	Числа тест берёт у настроек и у самих вещей, а проверяет инварианты. Исключение — обещания плана:
	G40E раскаляет тяжёлую сталь докрасна к третьему попаданию, торс crimson-хардсьюта — добела ровно
	к концу батареи, EOD — позже, а пистолеты греют слабее карабина.

	Время полива на время теста обнулено: `do_after()` без задержки проходит сразу.
*/
#define CE_LASER_TOLERANCE 0.001
#define CE_LASER_SCORCH_ICON 'mods/combat_extended/icons/laser_scorch.dmi'

/datum/unit_test/combat_extended/laser_heat
	name = "CE: Лазеры и нагрев"

/datum/unit_test/combat_extended/laser_heat/start_test()
	var/old_heat = ce_laser_heat_enabled
	var/old_wear = ce_armor_wear_enabled
	var/old_scorch = ce_laser_scorch_enabled
	var/old_tint = ce_laser_glow_tint_enabled
	var/list/old_delays = list(ce_laser_coolant_delay, ce_laser_coolant_other_delay, ce_laser_coolant_self_delay)
	ce_laser_heat_enabled = TRUE
	ce_armor_wear_enabled = TRUE
	ce_laser_scorch_enabled = TRUE
	ce_laser_glow_tint_enabled = TRUE
	var/list/failures = list()

	check_burn_through(failures)
	check_bay_border(failures)
	check_heat_curve(failures)
	check_cooling(failures)
	check_coolers(failures)
	check_burns(failures)
	check_wear(failures)
	check_softening(failures)
	check_coating(failures)
	check_coolant(failures)
	check_rig_block(failures)
	check_consultation(failures)
	check_glow(failures)
	check_haze(failures)
	check_scorch(failures)
	check_switch(failures)

	ce_laser_heat_enabled = old_heat
	ce_armor_wear_enabled = old_wear
	ce_laser_scorch_enabled = old_scorch
	ce_laser_glow_tint_enabled = old_tint
	ce_laser_coolant_delay = old_delays[1]
	ce_laser_coolant_other_delay = old_delays[2]
	ce_laser_coolant_self_delay = old_delays[3]
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Жёсткая броня держит луч вычитанием и греется от остановленного, остывает по расписанию, жжёт носителя подбоем и размягчается; хладагент, покрытие и прожоги работают по плану; блок убранного РИГа ведёт к деталям.")
	return 1

/// Броня пластины в плитоноске человека. null — плитоноски или пластины нет.
/datum/unit_test/combat_extended/proc/plate_armor(mob/living/carbon/human/H)
	var/obj/item/clothing/suit/armor/pcarrier/carrier = H?.wear_suit
	if(!istype(carrier) || !length(carrier.accessories))
		return null
	return get_extension(carrier.accessories[1], /datum/extension/armor)

/// Броня того, что надето на человека в слот костюма.
/datum/unit_test/combat_extended/laser_heat/proc/suit_armor(mob/living/carbon/human/H)
	return H?.wear_suit ? get_extension(H.wear_suit, /datum/extension/armor) : null

/// Человек в развёрнутом риге `rig_type`. null — не вышло.
/datum/unit_test/combat_extended/laser_heat/proc/make_rigged_human(rig_type)
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		return null
	var/obj/item/rig/rig = new rig_type(H.loc)
	spawned += rig
	if(!H.equip_to_slot_if_possible(rig, slot_back, TRYEQUIP_REDRAW | TRYEQUIP_INSTANT | TRYEQUIP_SILENT))
		return null
	rig.deploy(H)
	return H.wear_suit == rig.chest ? H : null

/// Человек в мягкой куртке, которая держит луч только рейтингом `laser`. null — не вышло.
/datum/unit_test/combat_extended/laser_heat/proc/make_coated_human(laser)
	var/mob/living/carbon/human/H = make_human()
	if(!H)
		return null
	var/obj/item/clothing/suit/storage/hooded/wintercoat/coat = new(H.loc)
	spawned += coat
	set_extension(coat, /datum/extension/armor, list("laser" = laser))
	H.equip_to_slot_or_del(coat, slot_wear_suit)
	return H.wear_suit == coat ? H : null

/// Задаёт группе зон брони температуру лица и подбоя.
/datum/unit_test/combat_extended/laser_heat/proc/set_heat(datum/extension/armor/armor, group, temperature, inner_temperature)
	var/datum/ce_armor_heat/heat = armor.ce_get_or_create_heat(group)
	heat.temperature = temperature
	heat.inner_temperature = inner_temperature
	armor.ce_update_glow()
	return heat

/// Температура подбоя группы зон брони.
/datum/unit_test/combat_extended/laser_heat/proc/inner_of(datum/extension/armor/armor, group)
	var/datum/ce_armor_heat/heat = armor.ce_get_heat(group)
	return heat ? heat.inner_temperature : 0

/// Сколько жара хранит группа зон брони — кривая нагрева в обратную сторону.
/datum/unit_test/combat_extended/laser_heat/proc/stored_heat(datum/extension/armor/armor, group)
	return armor.ce_get_heat_capacity(group) * armor.ce_get_temperature(group) ** (1 / ce_laser_heat_temperature_exponent)

/// Сколько жара луч `projectile_type` вложит в броню `armor` сейчас, по `ce_try_burn_through()`: `list(прошедший урон, жар)`.
/datum/unit_test/combat_extended/laser_heat/proc/try_beam(datum/extension/armor/armor, obj/item/projectile/projectile_type)
	return armor.ce_try_burn_through(initial(projectile_type.damage), initial(projectile_type.armor_penetration), initial(projectile_type.ce_laser_heat_mult))

/**
 * Попадание луча `projectile_type` в `def_zone` боевым проходом, как из `bullet_act()`: снаряд
 * доходит до прохода через `ce_hit_projectile`. Стрелок стоит в клетке в направлении `from_dir`.
 * Возвращает урон, прошедший броню.
 */
/datum/unit_test/combat_extended/laser_heat/proc/beam_hit(mob/living/carbon/human/H, def_zone, projectile_type, from_dir = SOUTH)
	var/obj/item/projectile/projectile = new projectile_type(H.loc)
	spawned += projectile
	projectile.starting = get_step(H, from_dir)
	H.ce_hit_projectile = projectile
	var/list/result = H.modify_damage_by_armor(def_zone, projectile.damage, projectile.damage_type, projectile.damage_flags, H, projectile.armor_penetration, TRUE)
	H.ce_hit_projectile = null
	H.ce_pending_shards = null
	return result[1]

/**
 * Батарея ствола `gun_type` лучами `projectile_type` в `def_zone`, с остыванием брони между
 * выстрелами на задержку ствола. Возвращает ступень накала группы зон `group` брони `armor` после
 * каждого попадания.
 */
/datum/unit_test/combat_extended/laser_heat/proc/fire_cell(mob/living/carbon/human/H, def_zone, gun_type, projectile_type, datum/extension/armor/armor, group)
	RETURN_TYPE(/list)
	var/obj/item/gun/energy/gun = gun_type
	var/seconds_between = initial(gun.fire_delay) / (1 SECOND)
	. = list()
	for(var/shot in 1 to initial(gun.max_shots))
		beam_hit(H, def_zone, projectile_type)
		. += ce_get_heat_stage(armor.ce_get_temperature(group))
		armor.ce_process_heat(seconds_between)

/**
 * Батарея по торсу нового рига `rig_type`: `list(ступени после каждого попадания, температура торса
 * в конце)`. null — одеть не вышло.
 */
/datum/unit_test/combat_extended/laser_heat/proc/fire_rig_cell(rig_type, gun_type, projectile_type)
	var/mob/living/carbon/human/H = make_rigged_human(rig_type)
	var/datum/extension/armor/armor = suit_armor(H)
	if(!armor)
		return null
	var/list/stages = fire_cell(H, BP_CHEST, gun_type, projectile_type, armor, CE_ARMOR_ZONE_TORSO)
	return list(stages, armor.ce_get_temperature(CE_ARMOR_ZONE_TORSO))

/// Один тик Life: ожоги от горячей брони через `handle_fire()`, по частям тела — `list(тег части = ожог)`.
/datum/unit_test/combat_extended/laser_heat/proc/life_tick_burns(mob/living/carbon/human/H)
	RETURN_TYPE(/list)
	var/list/before = list()
	for(var/obj/item/organ/external/organ as anything in H.organs)
		before[organ] = organ.burn_dam
	H.handle_fire()
	var/list/burns = list()
	for(var/obj/item/organ/external/organ as anything in H.organs)
		var/burn = organ.burn_dam - before[organ]
		if(burn > CE_LASER_TOLERANCE)
			burns[organ.organ_tag] = burn
	return burns

/// Совпадают ли ожоги `burns` с ожидаемыми `expected` — по частям тела и по числам.
/datum/unit_test/combat_extended/laser_heat/proc/burns_match(list/burns, list/expected)
	if(length(burns) != length(expected))
		return FALSE
	for(var/organ_tag in expected)
		if(abs(burns[organ_tag] - expected[organ_tag]) > CE_LASER_TOLERANCE)
			return FALSE
	return TRUE

/// Ожоги словами для сообщения о провале.
/datum/unit_test/combat_extended/laser_heat/proc/describe_burns(list/burns)
	var/list/parts = list()
	for(var/organ_tag in burns)
		parts += "[organ_tag] [burns[organ_tag]]"
	return length(parts) ? jointext(parts, ", ") : "ничего"

/// Прожоги на картинке `worn`: `list(состояния прожогов, сколько у них эмиссивов)`.
/datum/unit_test/combat_extended/laser_heat/proc/get_scorch_states(image/worn)
	RETURN_TYPE(/list)
	var/list/states = list()
	var/emissives = 0
	for(var/image/overlay as anything in worn?.overlays)
		if(overlay.icon != CE_LASER_SCORCH_ICON)
			continue
		if(overlay.plane == EMISSIVE_PLANE)
			emissives++
		else
			states += overlay.icon_state
	return list(states, emissives)

/// Непрозрачности картинок горячего воздуха среди оверлеев `drawn`.
/datum/unit_test/combat_extended/laser_heat/proc/get_haze_alphas(list/drawn)
	RETURN_TYPE(/list)
	. = list()
	for(var/image/overlay as anything in drawn)
		if(overlay.render_source == HEAT_EFFECT_TARGET)
			. += overlay.alpha

/**
 * Жёсткая броня держит луч вычитанием: проходит урон сверх рейтинга минус AP, а лазерный флаг луч
 * не теряет. Жар — только от остановленной части луча, AP его срезает, множитель луча масштабирует,
 * и снаряд доносит свой множитель до брони. Пистолеты греют слабее карабина. Мягкая броня и щиты
 * вычитанием не держат.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_burn_through(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	if(!armor?.ce_uses_laser_heat(DAMAGE_BURN, DAMAGE_FLAG_LASER))
		failures += "вычитание: merc-пластина не держит луч вычитанием"
		return
	var/laser = armor.get_value("laser")
	for(var/list/test_case in list(list(40, 10), list(70, 10), list(40, 30), list(20, 0), list(40, 70)))
		var/damage = test_case[1]
		var/armor_pen = test_case[2]
		var/expected = clamp(damage - max(0, laser - armor_pen), 0, damage)
		var/list/walked = H.ce_walk_laser_layers(BP_CHEST, damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, armor_pen)
		if(abs(walked[1] - expected) > CE_LASER_TOLERANCE)
			failures += "вычитание: луч [damage] с AP [armor_pen] через рейтинг [laser] — прошло [walked[1]], ожидалось [expected]"
		if(!(walked[2] & DAMAGE_FLAG_LASER))
			failures += "вычитание: жёсткий слой снял с луча лазерный флаг"
	if(armor.ce_heat)
		failures += "вычитание: консультационный проход нагрел броню"

	var/list/stopped = armor.ce_try_burn_through(laser, 0)
	var/list/overflowing = armor.ce_try_burn_through(laser + 30, 0)
	if(stopped[2] <= 0 || abs(overflowing[2] - stopped[2]) > CE_LASER_TOLERANCE)
		failures += "жар: луч [laser] даёт [stopped[2]], луч [laser + 30] — [overflowing[2]]; греть должна только остановленная часть"
	var/list/unstopped = armor.ce_try_burn_through(40, laser)
	if(unstopped[2] != 0)
		failures += "жар: луч, прошедший броню целиком, её греет"
	var/list/plain = armor.ce_try_burn_through(20, 0)
	var/list/pierced = armor.ce_try_burn_through(20, 30)
	if(pierced[1] != 0 || abs(pierced[2] - plain[2] * (1 - 30 / ce_laser_heat_ap_divisor)) > CE_LASER_TOLERANCE)
		failures += "жар: остановленные 20 с AP 30 дают [pierced[2]], без AP — [plain[2]]; AP должен срезать жар"
	var/list/halved = armor.ce_try_burn_through(20, 0, 0.5)
	if(abs(halved[2] - plain[2] / 2) > CE_LASER_TOLERANCE)
		failures += "жар: множитель луча 0.5 даёт [halved[2]] вместо [plain[2] / 2]"

	for(var/projectile_type in list(/obj/item/projectile/beam/midlaser, /obj/item/projectile/beam/smalllaser))
		var/mob/living/carbon/human/target = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
		var/datum/extension/armor/target_armor = plate_armor(target)
		var/list/expected = try_beam(target_armor, projectile_type)
		var/passed = beam_hit(target, BP_CHEST, projectile_type)
		if(abs(passed - expected[1]) > CE_LASER_TOLERANCE || abs(stored_heat(target_armor, null) - expected[2]) > 0.01)
			failures += "жар снаряда [projectile_type]: прошло [passed], набрано [stored_heat(target_armor, null)] жара, ожидалось [expected[1]] и [expected[2]]"

	var/obj/item/projectile/strigoi = /obj/item/projectile/beam/smalllaser
	var/obj/item/projectile/perun = /obj/item/projectile/beam
	var/obj/item/projectile/carbine = /obj/item/projectile/beam/midlaser
	if(!(initial(strigoi.ce_laser_heat_mult) < initial(perun.ce_laser_heat_mult) && initial(perun.ce_laser_heat_mult) < initial(carbine.ce_laser_heat_mult)))
		failures += "жар лучей: «Стригой» [initial(strigoi.ce_laser_heat_mult)], «Перун» [initial(perun.ce_laser_heat_mult)], G40E [initial(carbine.ce_laser_heat_mult)] — пистолеты должны греть слабее карабина"
	for(var/obj/item/projectile/beam_path as anything in typesof(/obj/item/projectile/beam))
		if(initial(beam_path.damage) > 0 && ce_is_laser_heat_attack(initial(beam_path.damage_type), initial(beam_path.damage_flags)) && initial(beam_path.ce_laser_heat_mult) <= 0)
			failures += "жар лучей: [beam_path] не греет броню вовсе"

	var/datum/extension/armor/coat_armor = armor_of(/obj/item/clothing/suit/storage/hooded/wintercoat/security, list("laser" = ARMOR_LASER_SMALL))
	if(coat_armor.ce_uses_laser_heat(DAMAGE_BURN, DAMAGE_FLAG_LASER))
		failures += "вычитание: мягкая куртка держит луч вычитанием"
	var/datum/extension/armor/shield_armor = armor_of(/obj/item/shield/riot, list("laser" = ARMOR_LASER_SMALL))
	if(shield_armor.ce_uses_laser_heat(DAMAGE_BURN, DAMAGE_FLAG_LASER))
		failures += "вычитание: щит держит луч вычитанием и греется"

/**
 * Граница Bay: луч, не пробивший мягкий слой, теряет лазерный флаг, и жёсткий слой под ним читает
 * его как `energy` — по процентной формуле и без нагрева. Без мягкого слоя тот же жёсткий слой
 * держит луч вычитанием и греется.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_bay_border(list/failures)
	var/mob/living/carbon/human/H = make_human()
	var/obj/item/clothing/under/color/grey/uniform = new(H?.loc)
	var/obj/item/clothing/suit/storage/hooded/wintercoat/coat = new(H?.loc)
	spawned += uniform
	spawned += coat
	set_extension(uniform, /datum/extension/armor, list("laser" = ARMOR_LASER_RIFLES))
	set_extension(coat, /datum/extension/armor, list("laser" = 100))
	var/datum/extension/armor/inner = get_extension(uniform, /datum/extension/armor)
	inner.ce_hard_armor = TRUE
	H?.equip_to_slot_or_del(uniform, slot_w_uniform)
	H?.equip_to_slot_or_del(coat, slot_wear_suit)
	if(!H || H.w_uniform != uniform || H.wear_suit != coat)
		failures += "граница Bay: не удалось одеть человека"
		return

	var/list/walked = H.ce_walk_laser_layers(BP_CHEST, 10, DAMAGE_BURN, DAMAGE_FLAG_LASER, 0)
	if(walked[2] & DAMAGE_FLAG_LASER)
		failures += "граница Bay: луч под бронёй мягкого слоя остался лазерным"
	H.modify_damage_by_armor(BP_CHEST, 10, DAMAGE_BURN, DAMAGE_FLAG_LASER, H, 0, TRUE)
	if(inner.ce_heat)
		failures += "граница Bay: луч под бронёй мягкого слоя нагрел жёсткий слой под ним"

	H.drop_from_inventory(coat)
	H.modify_damage_by_armor(BP_CHEST, 10, DAMAGE_BURN, DAMAGE_FLAG_LASER, H, 0, TRUE)
	if(!inner.ce_heat)
		failures += "граница Bay: без мягкого слоя жёсткий слой не греется от луча"

/**
 * Обещания плана о кривой нагрева, настоящими стволами: батарея G40E раскаляет тяжёлую сталь
 * докрасна к третьему попаданию, торс crimson-хардсьюта — добела ровно на последнем, торс EOD к
 * концу батареи ещё не добела. Батарея «Перуна» оставляет crimson ниже белого каления, «Стригоя» —
 * холоднее, чем «Перуна».
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_heat_curve(list/failures)
	var/mob/living/carbon/human/plated = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/plate = plate_armor(plated)
	if(!plate)
		failures += "кривая нагрева: не удалось одеть человека в merc-пластину"
	else
		var/list/plate_stages = fire_cell(plated, BP_CHEST, /obj/item/gun/energy/laser, /obj/item/projectile/beam/midlaser, plate)
		if(length(plate_stages) < 3 || plate_stages[3] < 2)
			failures += "кривая нагрева: G40E по merc-пластине — ступени [jointext(plate_stages, " ")], красная не к третьему попаданию"

	var/list/crimson = fire_rig_cell(/obj/item/rig/merc, /obj/item/gun/energy/laser, /obj/item/projectile/beam/midlaser)
	var/list/eod = fire_rig_cell(/obj/item/rig/merc/heavy, /obj/item/gun/energy/laser, /obj/item/projectile/beam/midlaser)
	var/list/perun = fire_rig_cell(/obj/item/rig/merc, /obj/item/gun/energy/gun, /obj/item/projectile/beam)
	var/list/strigoi = fire_rig_cell(/obj/item/rig/merc, /obj/item/gun/energy/gun/small, /obj/item/projectile/beam/smalllaser)
	if(!crimson || !eod || !perun || !strigoi)
		failures += "кривая нагрева: не удалось одеть человека в риг"
		return
	var/list/stages = crimson[1]
	var/shots = length(stages)
	if(shots < 2 || stages[shots - 1] >= 4 || stages[shots] < 4)
		failures += "кривая нагрева: G40E по crimson-хардсьюту — ступени [jointext(stages, " ")], добела не ровно к концу батареи"
	stages = eod[1]
	if(stages[length(stages)] >= 4)
		failures += "кривая нагрева: G40E раскаляет EOD добела к концу батареи, как и crimson — ступени [jointext(stages, " ")]"
	stages = perun[1]
	if(stages[length(stages)] >= 4)
		failures += "кривая нагрева: батарея «Перуна» раскаляет crimson добела — ступени [jointext(stages, " ")]"
	if(strigoi[2] >= perun[2])
		failures += "кривая нагрева: после батареи «Стригоя» crimson [strigoi[2]], «Перуна» — [perun[2]]; «Стригой» должен греть слабее"

/**
 * Остывание: каждую полосу между ступенями накала броня проходит за свои секунды, в вакууме —
 * медленнее. Подбой догоняет лицо тем быстрее, чем выше проводимость материала. Тёплая броня
 * остаётся на обработке, остывшая с неё снимается.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_cooling(list/failures)
	var/list/edges = ce_laser_heat_stage_temperatures
	var/glow_seconds = 0
	for(var/stage in 2 to length(edges))
		glow_seconds += ce_laser_cooling_band_seconds[stage]
		if(ce_cool_temperature(edges[stage], glow_seconds - 0.5) <= edges[1] || ce_cool_temperature(edges[stage], glow_seconds) > edges[1] + CE_LASER_TOLERANCE)
			failures += "расписание: со ступени [stage] свечение гаснет не за [glow_seconds] с"
	var/total_seconds = 0
	for(var/seconds in ce_laser_cooling_band_seconds)
		total_seconds += seconds
	if(ce_cool_temperature(1, total_seconds - 0.5) <= 0 || ce_cool_temperature(1, total_seconds) > CE_LASER_TOLERANCE)
		failures += "расписание: с полного жара броня остывает не за [total_seconds] с"

	// Вакуум — порогом давления выше давления воздуха: та же клетка с воздухом считается вакуумом.
	var/datum/extension/armor/in_air = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	var/datum/extension/armor/in_vacuum = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	var/obj/item/air_plate = in_air.holder
	var/obj/item/vacuum_plate = in_vacuum.holder
	var/mob/living/carbon/human/H = make_human()
	air_plate.forceMove(H.loc)
	vacuum_plate.forceMove(H.loc)
	set_heat(in_air, null, 0.95, 0.95)
	set_heat(in_vacuum, null, 0.95, 0.95)
	in_air.ce_process_heat(10)
	var/old_pressure = ce_laser_vacuum_pressure
	ce_laser_vacuum_pressure = 1000 * ONE_ATMOSPHERE
	in_vacuum.ce_process_heat(10)
	ce_laser_vacuum_pressure = old_pressure
	var/expected_air = ce_cool_temperature(0.95, 10)
	var/expected_vacuum = ce_cool_temperature(0.95, 10 * ce_laser_vacuum_cooling_mult)
	if(abs(in_air.ce_get_temperature() - expected_air) > CE_LASER_TOLERANCE || abs(in_vacuum.ce_get_temperature() - expected_vacuum) > CE_LASER_TOLERANCE)
		failures += "вакуум: за 10 с на воздухе [in_air.ce_get_temperature()], в вакууме [in_vacuum.ce_get_temperature()]; ожидалось [expected_air] и [expected_vacuum]"

	var/datum/extension/armor/ceramic = armor_of(/obj/item/clothing/accessory/armor_plate/tactical)
	var/obj/item/ceramic_plate = ceramic.holder
	ceramic_plate.forceMove(H.loc)
	set_heat(in_air, null, 0.9, 0)
	set_heat(ceramic, null, 0.9, 0)
	in_air.ce_process_heat(2)
	ceramic.ce_process_heat(2)
	var/steel_inner = inner_of(in_air, null)
	var/ceramic_inner = inner_of(ceramic, null)
	if(ceramic_inner <= 0 || steel_inner <= ceramic_inner || steel_inner > in_air.ce_get_temperature())
		failures += "проводимость: за 2 с подбой стали [steel_inner], керамики [ceramic_inner]; сталь должна догонять лицо быстрее"

	set_heat(in_air, null, 0.3, 0.3)
	if(!in_air.ce_process_heat(1))
		failures += "обработка: тёплую броню сняли с обработки"
	if(in_air.ce_process_heat(total_seconds))
		failures += "обработка: остывшая броня осталась на обработке"

/**
 * Охладитель на носителе — переносной на спине или модуль рига — остужает его броню вдвое быстрее
 * за заряд своей батареи и ослабляет ожоги. Выключенный не делает ничего.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_coolers(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	var/obj/item/device/suit_cooling_unit/unit = new(H?.loc)
	spawned += unit
	if(!armor || !H.equip_to_slot_if_possible(unit, slot_back, TRYEQUIP_REDRAW | TRYEQUIP_INSTANT | TRYEQUIP_SILENT))
		failures += "охладитель: не удалось одеть человека"
		return
	var/charge = unit.cell.charge
	check_cooling_speed(armor, null, 1, "выключенный охладитель", failures)
	if(unit.cell.charge != charge)
		failures += "охладитель: выключенный тратит заряд"
	set_heat(armor, null, 1, 1)
	var/list/plain_burns = life_tick_burns(H)

	unit.turn_on()
	check_cooling_speed(armor, null, ce_laser_cooler_cooling_mult, "переносной охладитель", failures)
	if(unit.cell.charge >= charge)
		failures += "охладитель: переносной остужает броню бесплатно"
	set_heat(armor, null, 1, 1)
	var/list/cooled_burns = life_tick_burns(H)
	var/expected = plain_burns[BP_CHEST] * ce_laser_cooler_burn_mult
	if(!plain_burns[BP_CHEST] || abs(cooled_burns[BP_CHEST] - expected) > CE_LASER_TOLERANCE)
		failures += "охладитель: грудь жжёт на [cooled_burns[BP_CHEST]], без охладителя — на [plain_burns[BP_CHEST]], ожидалось [expected]"

	var/mob/living/carbon/human/rigged = make_rigged_human(/obj/item/rig/merc)
	var/datum/extension/armor/rig_armor = suit_armor(rigged)
	var/obj/item/rig/rig = rigged?.back
	if(!rig_armor || !istype(rig))
		failures += "охладитель: не удалось одеть человека в риг"
		return
	var/obj/item/rig_module/cooling_unit/module = new(rig)
	module.holder = rig
	rig.installed_modules += module
	var/rig_charge = rig.cell.charge
	check_cooling_speed(rig_armor, CE_ARMOR_ZONE_TORSO, 1, "выключенный модуль охлаждения", failures)
	module.active = TRUE
	check_cooling_speed(rig_armor, CE_ARMOR_ZONE_TORSO, ce_laser_cooler_cooling_mult, "модуль охлаждения рига", failures)
	if(rig.cell.charge >= rig_charge)
		failures += "охладитель: модуль рига остужает броню бесплатно"

/// Остужает группу зон брони 10 секунд с белого каления и сверяет с расписанием, ускоренным в `speed` раз.
/datum/unit_test/combat_extended/laser_heat/proc/check_cooling_speed(datum/extension/armor/armor, group, speed, label, list/failures)
	set_heat(armor, group, 0.95, 0.95)
	armor.ce_process_heat(10)
	var/expected = ce_cool_temperature(0.95, 10 * speed)
	if(abs(armor.ce_get_temperature(group) - expected) > CE_LASER_TOLERANCE)
		failures += "[label]: за 10 с броня остыла до [armor.ce_get_temperature(group)], ожидалось [expected]"

/**
 * Ожоги идут в тик Life (`handle_fire()`) по кривой от температуры подбоя, поровну на закрытые
 * вещью части тела. Лицо без подбоя не жжёт, броня головы жжёт слабее, снятая не жжёт вовсе.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_burns(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	var/obj/item/clothing/head/helmet/helmet = new(H?.loc)
	spawned += helmet
	H?.equip_to_slot_or_del(helmet, slot_head)
	var/datum/extension/armor/helmet_armor = get_extension(helmet, /datum/extension/armor)
	if(!armor || H.head != helmet || !helmet_armor)
		failures += "ожоги: не удалось одеть человека"
		return
	var/full_burn = ce_evaluate_curve(ce_laser_burn_curve, 1)
	var/list/organs = armor.ce_get_heated_organs(H, null)
	if(!(H.get_organ(BP_CHEST) in organs) || !(H.get_organ(BP_GROIN) in organs))
		failures += "ожоги: пластина закрывает не грудь и пах"
		return

	set_heat(armor, null, 1, 1)
	var/list/burns = life_tick_burns(H)
	var/list/expected = list()
	for(var/obj/item/organ/external/organ as anything in organs)
		expected[organ.organ_tag] = full_burn / length(organs)
	if(full_burn <= 0 || !burns_match(burns, expected))
		failures += "ожоги: раскалённая пластина жжёт [describe_burns(burns)], ожидалось [describe_burns(expected)]"

	var/list/first_point = ce_laser_burn_curve[1]
	set_heat(armor, null, 1, first_point[1])
	burns = life_tick_burns(H)
	if(length(burns))
		failures += "ожоги: подбой на [first_point[1]], в начале кривой, жжёт [describe_burns(burns)]"
	set_heat(armor, null, 1, 0)
	burns = life_tick_burns(H)
	if(length(burns))
		failures += "ожоги: раскалённое лицо с холодным подбоем жжёт [describe_burns(burns)]"

	set_heat(armor, null, 0, 0)
	set_heat(helmet_armor, null, 1, 1)
	burns = life_tick_burns(H)
	expected = list(BP_HEAD = full_burn * ce_laser_burn_limb_mult)
	if(!burns_match(burns, expected))
		failures += "ожоги: раскалённая каска жжёт [describe_burns(burns)], ожидалось [describe_burns(expected)]"

	set_heat(helmet_armor, null, 0, 0)
	set_heat(armor, null, 1, 1)
	var/obj/item/clothing/suit/carrier = H.wear_suit
	H.drop_from_inventory(carrier)
	H.put_in_hands(carrier)
	burns = life_tick_burns(H)
	if(length(burns))
		failures += "ожоги: плитоноска в руках жжёт [describe_burns(burns)]"

/**
 * Износ от луча — кубический: одинаковый жар изнашивает раскалённую броню во столько раз сильнее,
 * во сколько куб её температуры после попадания больше. Раскалённая добела броня изнашивается от
 * пуль и клинков в `1 + ce_laser_hot_kinetic_wear` раз быстрее. Мягкая броня от луча обугливается:
 * на `ce_laser_soft_char_mult` износа от острой атаки с тем же уроном — и не греется.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_wear(list/failures)
	var/mob/living/carbon/human/cold_human = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/mob/living/carbon/human/hot_human = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/cold = plate_armor(cold_human)
	var/datum/extension/armor/hot = plate_armor(hot_human)
	if(!cold || !hot)
		failures += "износ: не удалось одеть человека"
		return
	set_heat(hot, null, 0.8, 0)
	var/health_max = cold.ce_get_health_max()
	var/beam = /obj/item/projectile/beam/midlaser
	var/list/cold_burn = try_beam(cold, beam)
	var/list/hot_burn = try_beam(hot, beam)
	beam_hit(cold_human, BP_CHEST, beam)
	beam_hit(hot_human, BP_CHEST, beam)
	var/cold_loss = health_max - cold.ce_get_health()
	var/hot_loss = health_max - hot.ce_get_health()
	var/expected_ratio = hot_burn[2] / cold_burn[2] * (hot.ce_get_temperature() / cold.ce_get_temperature()) ** ce_laser_wear_exponent
	if(isnull(cold.ce_get_health()) || cold_loss <= 0 || abs(hot_loss / cold_loss - expected_ratio) > 0.01)
		failures += "износ от луча: холодная пластина потеряла [cold_loss] HP, раскалённая — [hot_loss]; ожидалось в [expected_ratio] раз больше"

	var/datum/extension/armor/kinetic = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	var/list/tests = list(list(45, 0, 4, kinetic.get_armor_sharp_ballistic(), TRUE))
	var/kinetic_max = kinetic.ce_get_health_max()
	kinetic.ce_apply_wear(tests)
	var/cold_kinetic = kinetic_max - kinetic.ce_get_health()
	kinetic.ce_set_health(null, kinetic_max)
	set_heat(kinetic, null, 1, 0)
	kinetic.ce_apply_wear(tests)
	var/hot_kinetic = kinetic_max - kinetic.ce_get_health()
	if(cold_kinetic <= 0 || abs(hot_kinetic / cold_kinetic - (1 + ce_laser_hot_kinetic_wear)) > CE_LASER_TOLERANCE)
		failures += "износ от пуль: холодная пластина потеряла [cold_kinetic] HP, раскалённая добела — [hot_kinetic]; ожидалось в [1 + ce_laser_hot_kinetic_wear] раза больше"

	var/mob/living/carbon/human/coated = make_coated_human(ARMOR_LASER_SMALL)
	var/datum/extension/armor/coat_armor = suit_armor(coated)
	if(!coat_armor)
		failures += "обугливание: не удалось одеть человека"
		return
	var/list/walked = coated.ce_walk_laser_layers(BP_CHEST, 40, DAMAGE_BURN, DAMAGE_FLAG_LASER, 10)
	var/expected_char = ce_armor_wear_amount(40, walked[1], 0, 0, TRUE, FALSE) * ce_laser_soft_char_mult
	var/coat_max = coat_armor.ce_get_health_max()
	coated.modify_damage_by_armor(BP_CHEST, 40, DAMAGE_BURN, DAMAGE_FLAG_LASER, coated, 10, TRUE)
	var/charred = coat_max - coat_armor.ce_get_health()
	if(expected_char <= 0 || abs(charred - expected_char) > CE_LASER_TOLERANCE)
		failures += "обугливание: мягкая броня потеряла [charred] HP от луча, ожидалось [expected_char]"
	if(coat_armor.ce_heat)
		failures += "обугливание: мягкая броня нагрелась от луча"

/**
 * Раскалённая броня теряет Sharp и Blunt на размягчение материала × квадрат температуры, а HP
 * выводятся из холодных рейтингов, даже если первый износ пришёл раскалённой. Керамика
 * размягчается меньше стали. Раскалённый добела скрытый тактический жилет — жёсткая плита на 6 мм —
 * пропускает пистолетную пулю, которую холодный держит.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_softening(list/failures)
	var/datum/extension/armor/armor = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	var/cold_ballistic = armor.get_armor_sharp_ballistic()
	var/cold_melee = armor.get_armor_sharp_melee()
	var/cold_blunt = armor.get_armor_blunt()
	var/singleton/ce_armor_material/material = armor.ce_get_material()
	for(var/temperature in list(0.5, 1))
		set_heat(armor, null, temperature, 0)
		var/mult = 1 - material.heat_softening * temperature ** ce_laser_hot_kinetic_exponent
		if(abs(armor.get_armor_sharp_ballistic() - cold_ballistic * mult) > CE_LASER_TOLERANCE || abs(armor.get_armor_sharp_melee() - cold_melee * mult) > CE_LASER_TOLERANCE || abs(armor.get_armor_blunt() - cold_blunt * mult) > CE_LASER_TOLERANCE)
			failures += "размягчение при [temperature]: пули [armor.get_armor_sharp_ballistic()], клинки [armor.get_armor_sharp_melee()], тупое [armor.get_armor_blunt()]; ожидалось ×[mult] от [cold_ballistic], [cold_melee], [cold_blunt]"
	if(armor.ce_get_cold_sharp_ballistic() != cold_ballistic)
		failures += "размягчение: жар поменял холодный рейтинг"

	// У merc-пластины HP решает тупая ось, у скрытого тактического жилета — острая: проверяются обе.
	for(var/path in list(/obj/item/clothing/accessory/armor_plate/merc, /obj/item/clothing/accessory/armor_plate/sneaky/tactical))
		var/datum/extension/armor/cold_plate = armor_of(path)
		var/datum/extension/armor/first_worn_hot = armor_of(path)
		set_heat(first_worn_hot, null, 1, 0)
		if(abs(first_worn_hot.ce_get_health_max() - cold_plate.ce_get_health_max()) > CE_LASER_TOLERANCE)
			failures += "размягчение: HP [path], впервые изношенной раскалённой, [first_worn_hot.ce_get_health_max()] вместо [cold_plate.ce_get_health_max()]"

	var/singleton/ce_armor_material/ceramic = GET_SINGLETON(/singleton/ce_armor_material/ceramic)
	var/singleton/ce_armor_material/steel = GET_SINGLETON(/singleton/ce_armor_material/steel)
	if(ceramic.heat_softening >= steel.heat_softening)
		failures += "размягчение: керамика [ceramic.heat_softening], сталь [steel.heat_softening]"

	var/datum/extension/armor/vest = armor_of(/obj/item/clothing/accessory/armor_plate/sneaky/tactical)
	var/obj/item/projectile/bullet = /obj/item/projectile/bullet/pistol
	var/pen = ce_derive_penetration(initial(bullet.damage), initial(bullet.damage_flags), initial(bullet.armor_penetration))
	var/vest_cold = vest.get_armor_sharp_ballistic()
	set_heat(vest, null, 1, 0)
	if(vest_cold <= pen || vest.get_armor_sharp_ballistic() >= pen)
		failures += "размягчение: скрытый тактический жилет держит [vest_cold] мм холодным и [vest.get_armor_sharp_ballistic()] мм добела против пистолетной пули с пробитием [pen] мм"

/**
 * Абляционное покрытие забирает свою долю жара каждого попадания, пока не выгорит, и на броне
 * головы его меньше. Отражение жилета Bay сохраняет долю по остатку покрытия и холоду: холодный
 * целый жилет отражает, выгоревший — никогда.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_coating(list/failures)
	var/mob/living/carbon/human/H = make_human()
	var/mob/living/carbon/human/fresh_holder = make_human()
	var/obj/item/clothing/suit/armor/laserproof/vest = new(H?.loc)
	var/obj/item/clothing/suit/armor/laserproof/fresh_vest = new(H?.loc)
	spawned += vest
	spawned += fresh_vest
	H?.equip_to_slot_or_del(vest, slot_wear_suit)
	fresh_holder?.equip_to_slot_or_del(fresh_vest, slot_wear_suit)
	var/datum/extension/armor/armor = get_extension(vest, /datum/extension/armor)
	if(!armor || H.wear_suit != vest || fresh_holder?.wear_suit != fresh_vest)
		failures += "покрытие: не удалось одеть человека в абляционный жилет"
		return
	var/singleton/ce_armor_material/material = armor.ce_get_material()
	var/coating_max = armor.ce_get_coating_max(null)
	if(material.coating_share <= 0 || coating_max != ce_laser_coating_per_rating * armor.get_value("laser"))
		failures += "покрытие: доля [material.coating_share], запас [coating_max] при рейтинге [armor.get_value("laser")]"
		return
	var/datum/extension/armor/helmet_armor = armor_of(/obj/item/clothing/head/helmet/ablative)
	var/helmet_laser = LAZYACCESS(helmet_armor.armor_values, "laser")
	if(abs(helmet_armor.ce_get_coating_max(null) - ce_laser_coating_per_rating * helmet_laser * ce_laser_heat_limb_capacity_mult) > CE_LASER_TOLERANCE)
		failures += "покрытие: у абляционной каски запас [helmet_armor.ce_get_coating_max(null)], ожидался как у брони головы"

	var/beam = /obj/item/projectile/beam/midlaser
	var/list/hit = try_beam(armor, beam)
	beam_hit(H, BP_CHEST, beam)
	var/datum/ce_armor_heat/heat = armor.ce_get_heat(null)
	var/expected_coating = hit[2] * material.coating_share
	if(!heat || abs(heat.coating_spent - expected_coating) > CE_LASER_TOLERANCE || abs(stored_heat(armor, null) - (hit[2] - expected_coating)) > 0.01)
		failures += "покрытие: из [hit[2]] жара забрало [heat?.coating_spent], броне досталось [stored_heat(armor, null)]; ожидалось [expected_coating] покрытию"
		return
	var/expected_reflect = (1 - heat.coating_spent / coating_max) * (1 - heat.temperature)
	if(abs(armor.ce_get_reflect_mult() - expected_reflect) > CE_LASER_TOLERANCE)
		failures += "отражение: жилет сохраняет [armor.ce_get_reflect_mult()], ожидалось [expected_reflect]"

	armor.ce_absorb_laser(coating_max * 10)
	if(abs(heat.coating_spent - coating_max) > CE_LASER_TOLERANCE)
		failures += "покрытие: выгорело [heat.coating_spent] из [coating_max]"
	if(armor.ce_get_reflect_mult() != 0)
		failures += "отражение: выгоревший жилет сохраняет [armor.ce_get_reflect_mult()]"
	var/spent_reflects = count_reflects(H, vest)
	if(spent_reflects)
		failures += "отражение: выгоревший жилет отразил [spent_reflects] лучей из 100"
	if(!count_reflects(fresh_holder, fresh_vest))
		failures += "отражение: холодный целый жилет не отразил ни одного луча из 100"

/// Сколько лучей G40E из 100 в грудь жилет `vest` на `H` отражает броском `handle_shield()`.
/datum/unit_test/combat_extended/laser_heat/proc/count_reflects(mob/living/carbon/human/H, obj/item/clothing/suit/armor/laserproof/vest)
	. = 0
	for(var/i in 1 to 100)
		var/obj/item/projectile/beam/midlaser/beam = new(H.loc)
		beam.starting = get_step(H, SOUTH)
		if(vest.handle_shield(H, beam.damage, beam, null, BP_CHEST, "the test"))
			.++
		qdel(beam)

/**
 * Хладагент. Снятую броню полив остужает насквозь, надетую — только с лица. Поливают самую горячую
 * броню, куда ни целься, кроме рта: рот — это напоить. На вреде и по холодной броне клик идёт
 * дальше. Керамика трескается от полива с `ce_laser_quench_crack_stage`. Брызги остужают только лицо
 * и не чаще раза в `ce_laser_spray_interval`, хладагент — сильнее воды.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_coolant(list/failures)
	var/mob/living/carbon/human/user = make_human()
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/worn = plate_armor(H)
	var/obj/item/clothing/head/helmet/helmet = new(H?.loc)
	spawned += helmet
	H?.equip_to_slot_or_del(helmet, slot_head)
	var/datum/extension/armor/helmet_armor = get_extension(helmet, /datum/extension/armor)
	if(!user || !worn || H.head != helmet || !helmet_armor)
		failures += "хладагент: не удалось одеть человека"
		return

	ce_laser_coolant_delay = 1
	ce_laser_coolant_other_delay = 2
	ce_laser_coolant_self_delay = 3
	if(ce_get_pour_delay(user, null) != 1 || ce_get_pour_delay(user, H) != 2 || ce_get_pour_delay(H, H) != 3)
		failures += "время полива: снятая [ce_get_pour_delay(user, null)], на другом [ce_get_pour_delay(user, H)], на себе [ce_get_pour_delay(H, H)]"
	ce_laser_coolant_delay = 0
	ce_laser_coolant_other_delay = 0
	ce_laser_coolant_self_delay = 0

	var/obj/item/reagent_containers/glass/beaker/large/beaker = new(user.loc)
	spawned += beaker
	beaker.reagents.add_reagent(/datum/reagent/coolant, 100)
	user.put_in_active_hand(beaker)
	user.a_intent = I_HELP
	user.zone_sel = new /obj/screen/zone_sel(null)
	spawned += user.zone_sel
	var/pour = ce_laser_coolant_pour_units

	var/datum/extension/armor/loose = armor_of(/obj/item/clothing/accessory/armor_plate/merc)
	var/obj/item/loose_plate = loose.holder
	loose_plate.forceMove(user.loc)
	set_heat(loose, null, 0.9, 0.9)
	loose_plate.use_tool(beaker, user)
	var/expected = max(0, 0.9 - pour * ce_laser_coolant_cooling)
	if(abs(loose.ce_get_temperature() - expected) > CE_LASER_TOLERANCE || abs(inner_of(loose, null) - expected) > CE_LASER_TOLERANCE || ce_get_coolant_amount(beaker.reagents) != 100 - pour)
		failures += "полив снятой брони: лицо [loose.ce_get_temperature()], подбой [inner_of(loose, null)], хладагента [ce_get_coolant_amount(beaker.reagents)]; ожидалось [expected], [expected], [100 - pour]"
	if(!isnull(loose.ce_get_health()))
		failures += "полив снятой брони: сталь треснула"
	set_heat(loose, null, 0, 0)
	var/coolant_left = ce_get_coolant_amount(beaker.reagents)
	loose_plate.use_tool(beaker, user)
	if(ce_get_coolant_amount(beaker.reagents) != coolant_left)
		failures += "хладагент: полив холодной брони тратит хладагент"

	var/obj/item/reagent_containers/glass/beaker/large/own = new(H.loc)
	spawned += own
	own.reagents.add_reagent(/datum/reagent/coolant, 100)
	H.put_in_active_hand(own)
	set_heat(worn, null, 0.9, 0.9)
	H.wear_suit.use_tool(own, H)
	var/expected_worn = 0.9 - pour * ce_laser_coolant_worn_cooling
	if(abs(worn.ce_get_temperature() - expected_worn) > CE_LASER_TOLERANCE || inner_of(worn, null) != 0.9)
		failures += "полив своей плитоноски: лицо [worn.ce_get_temperature()], подбой [inner_of(worn, null)]; ожидалось [expected_worn] и 0.9"

	set_heat(worn, null, 0.9, 0.9)
	set_heat(helmet_armor, null, 0.5, 0.5)
	user.zone_sel.selecting = BP_HEAD
	beaker.use_before(H, user)
	if(abs(worn.ce_get_temperature() - expected_worn) > CE_LASER_TOLERANCE || helmet_armor.ce_get_temperature() != 0.5)
		failures += "полив другого человека, прицел в голову: пластина [worn.ce_get_temperature()], каска [helmet_armor.ce_get_temperature()]; поливать надо самую горячую броню"

	set_heat(worn, null, 0.9, 0.9)
	H.a_intent = I_HELP
	H.zone_sel = new /obj/screen/zone_sel(null)
	spawned += H.zone_sel
	H.zone_sel.selecting = BP_MOUTH
	own.use_before(H, H)
	user.zone_sel.selecting = BP_CHEST
	user.a_intent = I_HURT
	beaker.use_before(H, user)
	user.a_intent = I_HELP
	if(worn.ce_get_temperature() != 0.9)
		failures += "хладагент: прицел в рот или намерение вреда поливают броню"

	check_quench_crack(beaker, user, failures)
	check_sprays(H, worn, failures)
	check_water(user, H, loose, worn, failures)

/// Ёмкость с `units` единиц реагента `reagent_type` в активной руке `holder`.
/datum/unit_test/combat_extended/laser_heat/proc/make_beaker(mob/living/carbon/human/holder, reagent_type, units)
	var/obj/item/reagent_containers/glass/beaker/large/beaker = new(holder.loc)
	spawned += beaker
	beaker.reagents.add_reagent(reagent_type, units)
	var/obj/item/held = holder.get_active_hand()
	if(held)
		holder.drop_from_inventory(held)
	holder.put_in_active_hand(beaker)
	return beaker

/**
 * Вода остужает броню как хладагент, но слабее на свою долю силы, — и снятую, и надетую. Из смеси
 * полив берёт сперва хладагент и не больше своих единиц на всё. Меньше полива в ёмкости — уходит
 * сколько есть, и остужает ровно на столько. Жидкость не из списка броню не поливает.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_water(mob/living/carbon/human/user, mob/living/carbon/human/H, datum/extension/armor/loose, datum/extension/armor/worn, list/failures)
	var/water = ce_laser_coolant_strengths[/datum/reagent/water]
	var/top
	for(var/coolant_type in ce_laser_coolant_strengths)
		var/strength = ce_laser_coolant_strengths[coolant_type]
		if(!ispath(coolant_type, /datum/reagent) || !isnum(strength) || strength <= 0 || strength > 1 || (!isnull(top) && strength > top))
			failures += "сила жидкостей: [coolant_type] — [strength], после [top]; ожидались доли от сильной к слабой"
		top = strength
	if(ce_laser_coolant_strengths[/datum/reagent/coolant] != 1 || !water || water >= 1)
		failures += "сила жидкостей: хладагент [ce_laser_coolant_strengths[/datum/reagent/coolant]], вода [water]; ожидались 1 и меньше 1"
		return
	var/pour = ce_laser_coolant_pour_units
	var/obj/item/loose_plate = loose.holder

	var/obj/item/reagent_containers/few = make_beaker(user, /datum/reagent/coolant, pour / 2)
	set_heat(loose, null, 0.9, 0.9)
	loose_plate.use_tool(few, user)
	var/expected = 0.9 - pour / 2 * ce_laser_coolant_cooling
	if(expected <= 0 || abs(loose.ce_get_temperature() - expected) > CE_LASER_TOLERANCE || abs(inner_of(loose, null) - expected) > CE_LASER_TOLERANCE || few.reagents.total_volume)
		failures += "полив остатком хладагента: лицо [loose.ce_get_temperature()], подбой [inner_of(loose, null)], в ёмкости [few.reagents.total_volume]; ожидалось [expected], [expected] и 0"

	var/obj/item/reagent_containers/bucket = make_beaker(user, /datum/reagent/water, 100)
	set_heat(loose, null, 0.9, 0.9)
	loose_plate.use_tool(bucket, user)
	expected = 0.9 - pour * ce_laser_coolant_cooling * water
	if(expected <= 0 || abs(loose.ce_get_temperature() - expected) > CE_LASER_TOLERANCE || abs(inner_of(loose, null) - expected) > CE_LASER_TOLERANCE || bucket.reagents.total_volume != 100 - pour)
		failures += "полив снятой брони водой: лицо [loose.ce_get_temperature()], подбой [inner_of(loose, null)], воды [bucket.reagents.total_volume]; ожидалось [expected], [expected] и [100 - pour]"

	var/obj/item/reagent_containers/own = make_beaker(H, /datum/reagent/water, 100)
	set_heat(worn, null, 0.9, 0.9)
	H.wear_suit.use_tool(own, H)
	expected = 0.9 - pour * ce_laser_coolant_worn_cooling * water
	if(abs(worn.ce_get_temperature() - expected) > CE_LASER_TOLERANCE || inner_of(worn, null) != 0.9)
		failures += "полив своей плитоноски водой: лицо [worn.ce_get_temperature()], подбой [inner_of(worn, null)]; ожидалось [expected] и 0.9"

	var/coolant_part = pour * 0.4
	var/obj/item/reagent_containers/mixed = make_beaker(user, /datum/reagent/water, pour * 2)
	mixed.reagents.add_reagent(/datum/reagent/coolant, coolant_part)
	set_heat(loose, null, 0.9, 0.9)
	loose_plate.use_tool(mixed, user)
	expected = 0.9 - (coolant_part + (pour - coolant_part) * water) * ce_laser_coolant_cooling
	var/coolant_left = mixed.reagents.get_reagent_amount(/datum/reagent/coolant)
	var/water_left = mixed.reagents.get_reagent_amount(/datum/reagent/water)
	if(expected <= 0 || abs(loose.ce_get_temperature() - expected) > CE_LASER_TOLERANCE || coolant_left || abs(water_left - (pour * 2 - (pour - coolant_part))) > CE_LASER_TOLERANCE)
		failures += "полив смесью: лицо [loose.ce_get_temperature()], осталось хладагента [coolant_left] и воды [water_left]; ожидалось [expected], 0 и [pour * 2 - (pour - coolant_part)]"

	var/obj/item/reagent_containers/fuel = make_beaker(user, /datum/reagent/fuel, 100)
	set_heat(loose, null, 0.9, 0.9)
	if(loose.ce_try_pour_coolant(fuel, null, user, null) || loose.ce_get_temperature() != 0.9 || fuel.reagents.total_volume != 100)
		failures += "полив топливом: лицо [loose.ce_get_temperature()], в ёмкости [fuel.reagents.total_volume]; топливо броню не остужает"
	set_heat(loose, null, 0, 0)
	set_heat(worn, null, 0, 0)

/**
 * Блок управления убранного РИГа ведёт к деталям: осмотр говорит жар каждой горячей детали,
 * хладагент поливает самую горячую как снятую броню, насквозь, — и мимо модуля химикатов, который
 * забирает любую открытую ёмкость, — а брызги на блок остужают лицо деталей.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_rig_block(list/failures)
	var/mob/living/carbon/human/user = make_human()
	if(!user)
		failures += "блок РИГа: не удалось создать человека"
		return
	var/obj/item/rig/rig = new /obj/item/rig/merc(user.loc)
	spawned += rig
	var/obj/item/rig_module/chem_dispenser/dispenser = new(rig)
	LAZYADD(rig.installed_modules, dispenser)
	dispenser.installed(rig)
	var/datum/extension/armor/chest = get_extension(rig.chest, /datum/extension/armor)
	var/datum/extension/armor/helmet = get_extension(rig.helmet, /datum/extension/armor)
	set_heat(chest, CE_ARMOR_ZONE_ARMS, 0.9, 0.9)
	set_heat(helmet, null, 0.5, 0.5)
	var/examine = jointext(rig.ce_get_examine_lines(), "\n")
	for(var/line in list("Armor heat ([rig.chest.name], [CE_ARMOR_ZONE_ARMS]): [ce_describe_heat(0.9)].", "Armor heat ([rig.helmet.name]): [ce_describe_heat(0.5)]."))
		if(!findtext(examine, line))
			failures += "осмотр горячего РИГа без «[line]»: «[examine]»"

	var/obj/item/reagent_containers/glass/beaker/large/beaker = new(user.loc)
	spawned += beaker
	beaker.reagents.add_reagent(/datum/reagent/coolant, 100)
	user.put_in_active_hand(beaker)
	rig.use_tool(beaker, user)
	var/expected = max(0, 0.9 - ce_laser_coolant_pour_units * ce_laser_coolant_cooling)
	if(abs(chest.ce_get_temperature(CE_ARMOR_ZONE_ARMS) - expected) > CE_LASER_TOLERANCE || abs(inner_of(chest, CE_ARMOR_ZONE_ARMS) - expected) > CE_LASER_TOLERANCE || helmet.ce_get_temperature() != 0.5)
		failures += "полив убранного РИГа с модулем химикатов: рукава [chest.ce_get_temperature(CE_ARMOR_ZONE_ARMS)], их подбой [inner_of(chest, CE_ARMOR_ZONE_ARMS)], шлем [helmet.ce_get_temperature()]; ожидалось [expected], [expected] и 0.5"

	var/obj/item/reagent_containers/spray/sprayer = new(user.loc)
	spawned += sprayer
	sprayer.reagents.add_reagent(/datum/reagent/coolant, 10)
	sprayer.reagents.touch(rig)
	var/expected_spray = 0.5 - ce_laser_spray_cooling
	if(abs(helmet.ce_get_temperature() - expected_spray) > CE_LASER_TOLERANCE || inner_of(helmet, null) != 0.5)
		failures += "брызги на блок РИГа: шлем [helmet.ce_get_temperature()], подбой [inner_of(helmet, null)]; ожидалось [expected_spray] и 0.5"

/// Керамика трескается от полива с `ce_laser_quench_crack_stage` и не трескается ниже.
/datum/unit_test/combat_extended/laser_heat/proc/check_quench_crack(obj/item/reagent_containers/beaker, mob/living/carbon/human/user, list/failures)
	var/datum/extension/armor/ceramic = armor_of(/obj/item/clothing/accessory/armor_plate/tactical)
	var/obj/item/ceramic_plate = ceramic.holder
	ceramic_plate.forceMove(user.loc)
	var/singleton/ce_armor_material/material = ceramic.ce_get_material()
	var/health_max = ceramic.ce_get_health_max()
	var/crack_temperature = ce_laser_heat_stage_temperatures[ce_laser_quench_crack_stage]
	set_heat(ceramic, null, crack_temperature - 0.05, 0)
	ceramic_plate.use_tool(beaker, user)
	if(!isnull(ceramic.ce_get_health()))
		failures += "керамика треснула от полива ниже ступени [ce_laser_quench_crack_stage]"
	set_heat(ceramic, null, crack_temperature, 0)
	ceramic_plate.use_tool(beaker, user)
	var/expected = health_max * (1 - material.heat_quench_crack)
	if(material.heat_quench_crack <= 0 || abs(ceramic.ce_get_health() - expected) > CE_LASER_TOLERANCE)
		failures += "керамика от полива на ступени [ce_laser_quench_crack_stage]: HP [ceramic.ce_get_health()], ожидалось [expected]"

/// Брызги на человека остужают лицо его брони не чаще раза в `ce_laser_spray_interval`: вода — на свою долю
/// силы хладагента, смесь — по самой сильной жидкости.
/datum/unit_test/combat_extended/laser_heat/proc/check_sprays(mob/living/carbon/human/H, datum/extension/armor/worn, list/failures)
	var/obj/item/reagent_containers/spray/sprayer = new(H.loc)
	spawned += sprayer
	sprayer.reagents.add_reagent(/datum/reagent/coolant, 10)
	set_heat(worn, null, 0.9, 0.9)
	sprayer.reagents.touch(H)
	sprayer.reagents.touch(H)
	var/expected = 0.9 - ce_laser_spray_cooling
	if(abs(worn.ce_get_temperature() - expected) > CE_LASER_TOLERANCE || inner_of(worn, null) != 0.9)
		failures += "брызги хладагента дважды подряд: лицо [worn.ce_get_temperature()], подбой [inner_of(worn, null)]; ожидалось [expected] и 0.9"
	worn.ce_spray_time -= ce_laser_spray_interval
	sprayer.reagents.clear_reagents()
	sprayer.reagents.add_reagent(/datum/reagent/water, 10)
	sprayer.reagents.touch(H)
	var/water_cooling = ce_laser_spray_cooling * ce_laser_coolant_strengths[/datum/reagent/water]
	expected -= water_cooling
	if(water_cooling <= 0 || water_cooling >= ce_laser_spray_cooling || abs(worn.ce_get_temperature() - expected) > CE_LASER_TOLERANCE)
		failures += "брызги воды: лицо [worn.ce_get_temperature()], ожидалось [expected]"
	worn.ce_spray_time -= ce_laser_spray_interval
	sprayer.reagents.add_reagent(/datum/reagent/coolant, 10)
	sprayer.reagents.touch(H)
	expected -= ce_laser_spray_cooling
	if(abs(worn.ce_get_temperature() - expected) > CE_LASER_TOLERANCE)
		failures += "брызги воды с хладагентом: лицо [worn.ce_get_temperature()], ожидалось [expected] — по самой сильной жидкости"

/**
 * Консультационный проход — `get_blocked_ratio()` — отвечает так же, как боевой, а у жёсткой брони
 * и так же, как итог снаряда. Мягкая броня держит луч по формуле Bay: боевой урон с нагревом и без
 * него один и тот же.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_consultation(list/failures)
	var/list/outfits = list(
		"merc-пластина" = /obj/item/clothing/accessory/armor_plate/merc,
		"скрытый тактический жилет" = /obj/item/clothing/accessory/armor_plate/sneaky/tactical
	)
	for(var/label in outfits)
		var/mob/living/carbon/human/H = make_human(list(outfits[label]))
		if(!plate_armor(H))
			failures += "проходы: не удалось одеть человека в [label]"
			continue
		for(var/list/test_case in list(list(40, 10), list(70, 10), list(30, 50), list(15, 0), list(40, 10)))
			var/damage = test_case[1]
			var/armor_pen = test_case[2]
			var/blocked = H.get_blocked_ratio(BP_CHEST, DAMAGE_BURN, DAMAGE_FLAG_LASER, armor_pen, damage)
			var/share = H.ce_get_percent_pass_share(BP_CHEST, damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, armor_pen)
			var/list/result = H.modify_damage_by_armor(BP_CHEST, damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, H, armor_pen, TRUE)
			if(abs(damage * (1 - blocked) - result[1]) > CE_LASER_TOLERANCE || abs(damage * share - result[1]) > CE_LASER_TOLERANCE)
				failures += "проходы, [label], луч [damage] с AP [armor_pen]: консультационный пропускает [damage * (1 - blocked)], итог снаряда — [damage * share], боевой — [result[1]]"

	var/mob/living/carbon/human/coated = make_coated_human(ARMOR_LASER_SMALL)
	if(!coated)
		failures += "проходы: не удалось одеть человека в куртку"
		return
	// Без износа: обугливание поменяло бы рейтинг куртки между проходами.
	ce_armor_wear_enabled = FALSE
	for(var/list/test_case in list(list(40, 10), list(15, 0), list(30, 50)))
		var/damage = test_case[1]
		var/armor_pen = test_case[2]
		var/blocked = coated.get_blocked_ratio(BP_CHEST, DAMAGE_BURN, DAMAGE_FLAG_LASER, armor_pen, damage)
		var/list/heated_result = coated.modify_damage_by_armor(BP_CHEST, damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, coated, armor_pen, TRUE)
		ce_laser_heat_enabled = FALSE
		var/list/bay_result = coated.modify_damage_by_armor(BP_CHEST, damage, DAMAGE_BURN, DAMAGE_FLAG_LASER, coated, armor_pen, TRUE)
		ce_laser_heat_enabled = TRUE
		if(abs(damage * (1 - blocked) - heated_result[1]) > CE_LASER_TOLERANCE || abs(heated_result[1] - bay_result[1]) > CE_LASER_TOLERANCE)
			failures += "проходы, мягкая куртка, луч [damage] с AP [armor_pen]: консультационный пропускает [damage * (1 - blocked)], боевой — [heated_result[1]], по Bay — [bay_result[1]]"
	ce_armor_wear_enabled = TRUE

/**
 * Свечение: пластина берёт ступень накала своей брони, плитоноска её показывает, свет — с
 * оранжевого. На носителе горячая вещь несёт слои жара, в руках — нет. Осмотр говорит, как раскалена
 * броня, кодекс — сколько луча она держит, сколько жара вмещает и сколько покрытия осталось.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_glow(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	if(!armor)
		failures += "свечение: не удалось одеть человека"
		return
	var/obj/item/clothing/plate = armor.holder
	var/obj/item/clothing/carrier = H.wear_suit
	var/list/edges = ce_laser_heat_stage_temperatures
	for(var/stage in 0 to length(edges))
		var/temperature = stage ? edges[stage] : 0
		set_heat(armor, null, temperature, 0)
		if(plate.ce_heat_stage != stage || carrier.ce_glow_stage != stage)
			failures += "свечение при [temperature]: пластина на ступени [plate.ce_heat_stage], плитоноска — [carrier.ce_glow_stage], ожидалась [stage]"
		var/lit = stage && ce_laser_glow_light_range[stage] > 0
		if(!plate.light_range != !lit)
			failures += "свечение: на ступени [stage] свет [plate.light_range]"
		if(!(carrier.z_flags & ZMM_MANGLE_PLANES) != !ce_glow_uses_planes(stage))
			failures += "свечение: на ступени [stage] флаг плоскостей Z-Mimic у плитоноски — [carrier.z_flags & ZMM_MANGLE_PLANES]"
		var/list/lines = armor.ce_get_heat_lines()
		var/description = ce_describe_heat(temperature)
		if(description ? (length(lines) != 1 || !findtext(lines[1], description)) : length(lines))
			failures += "осмотр при [temperature]: «[jointext(lines, " | ")]», ожидалось «[description]»"
	if(ce_describe_heat(0) || ce_describe_heat(0.01) != "hot to the touch" || ce_describe_heat(edges[2]) != "red-hot" || ce_describe_heat(1) != "white-hot")
		failures += "осмотр: холодная «[ce_describe_heat(0)]», тёплая «[ce_describe_heat(0.01)]», красная «[ce_describe_heat(edges[2])]», добела «[ce_describe_heat(1)]»"

	set_heat(armor, null, edges[2], 0)
	carrier.get_mob_overlay(H, slot_wear_suit_str)
	var/tinted_layers = length(carrier.ce_worn_heat_layers)
	ce_laser_glow_tint_enabled = FALSE
	carrier.get_mob_overlay(H, slot_wear_suit_str)
	var/untinted_layers = length(carrier.ce_worn_heat_layers)
	ce_laser_glow_tint_enabled = TRUE
	carrier.get_mob_overlay(H, slot_l_hand_str)
	if(tinted_layers != 2 || untinted_layers != 1 || carrier.ce_worn_heat_layers)
		failures += "слои жара: на носителе [tinted_layers], без окраски [untinted_layers], в руках [length(carrier.ce_worn_heat_layers)]; ожидалось 2, 1 и 0"

	set_heat(armor, null, 0, 0)
	var/list/codex = armor.ce_get_laser_codex_lines()
	if(length(codex) != 2 || !findtext(codex[1], "stops [round(armor.get_value("laser"), 0.1)] ") || !findtext(codex[2], "[round(armor.ce_get_heat_capacity(null))] heat"))
		failures += "кодекс merc-пластины: «[jointext(codex, " | ")]»"
	var/datum/extension/armor/vest = armor_of(/obj/item/clothing/suit/armor/laserproof)
	codex = vest.ce_get_laser_codex_lines()
	if(length(codex) != 3 || !findtext(codex[3], "ablative coating"))
		failures += "кодекс абляционного жилета: «[jointext(codex, " | ")]»"
	var/datum/extension/armor/coat = armor_of(/obj/item/clothing/suit/storage/hooded/wintercoat/security, list("laser" = ARMOR_LASER_SMALL))
	if(length(coat.ce_get_laser_codex_lines()))
		failures += "кодекс мягкой куртки пишет строки о луче"
	if(!findtext(ce_beam_codex_line(/obj/item/projectile/beam/midlaser), "heat") || ce_beam_codex_line(/obj/item/projectile/bullet/pistol))
		failures += "кодекс лучей: у G40E нет строки о жаре или она есть у пули"

/**
 * Горячий воздух: один на носителя, по самой горячей из вещей, которые на нём светятся, с
 * непрозрачностью её ступени, а на ступени с нулём его нет. Картинки вещей его не несут, флаг
 * плоскостей Z-Mimic вещь получает и за него, невидимку он не выдаёт. Списки ступеней тест на это
 * время ставит свои: воздух — с нулём и без одинаковых чисел, эмиссив — в ноль, чтобы флаг решал
 * только воздух.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_haze(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	var/obj/item/clothing/head/helmet/helmet = new(H?.loc)
	spawned += helmet
	H?.equip_to_slot_or_del(helmet, slot_head)
	var/datum/extension/armor/helmet_armor = get_extension(helmet, /datum/extension/armor)
	if(!armor || H.head != helmet || !helmet_armor)
		failures += "горячий воздух: не удалось одеть человека"
		return
	var/obj/item/clothing/carrier = H.wear_suit
	var/list/edges = ce_laser_heat_stage_temperatures
	var/top = length(edges)
	var/list/old_haze = ce_laser_glow_haze_alpha
	var/list/old_emissive = ce_laser_glow_emissive_alpha
	ce_laser_glow_haze_alpha = list()
	ce_laser_glow_emissive_alpha = list()
	for(var/stage in 1 to top)
		ce_laser_glow_haze_alpha += (stage - 1) * 50
		ce_laser_glow_emissive_alpha += 0

	for(var/stage in 0 to top)
		set_heat(armor, null, stage ? edges[stage] : 0, 0)
		H.update_icons()
		var/list/hazes = get_haze_alphas(H.atom_overlay_cache)
		var/expected = stage ? ce_laser_glow_haze_alpha[stage] : 0
		if(expected ? (length(hazes) != 1 || hazes[1] != expected) : length(hazes))
			failures += "горячий воздух на ступени [stage]: картинок [length(hazes)], непрозрачность «[jointext(hazes, ", ")]»; ожидалась [expected ? "одна на [expected]" : "ни одной"]"
		if(!(carrier.z_flags & ZMM_MANGLE_PLANES) != !expected)
			failures += "горячий воздух на ступени [stage]: флаг плоскостей Z-Mimic у плитоноски — [carrier.z_flags & ZMM_MANGLE_PLANES], воздух на [expected]"

	// Горячие и каска, и пластина: воздух один и по той, что горячее, — какая бы из них это ни была.
	for(var/list/stages in list(list(top, top - 1), list(top - 1, top)))
		set_heat(helmet_armor, null, edges[stages[1]], 0)
		set_heat(armor, null, edges[stages[2]], 0)
		H.update_icons()
		var/list/hazes = get_haze_alphas(H.atom_overlay_cache)
		if(length(hazes) != 1 || hazes[1] != ce_laser_glow_haze_alpha[top])
			failures += "горячий воздух, каска на ступени [stages[1]], пластина на [stages[2]]: картинок [length(hazes)], непрозрачность «[jointext(hazes, ", ")]»; ожидалась одна на [ce_laser_glow_haze_alpha[top]]"

	var/image/worn_carrier = carrier.get_mob_overlay(H, slot_wear_suit_str)
	var/image/worn_helmet = helmet.get_mob_overlay(H, slot_head_str)
	if(!worn_carrier || !worn_helmet || length(get_haze_alphas(worn_carrier.overlays)) || length(get_haze_alphas(worn_helmet.overlays)))
		failures += "горячий воздух: на картинке плитоноски его [length(get_haze_alphas(worn_carrier?.overlays))], на картинке каски — [length(get_haze_alphas(worn_helmet?.overlays))]; ожидалось, что картинки вещей его не несут"

	H.add_cloaking_source(src)
	H.update_icons()
	if(length(get_haze_alphas(H.atom_overlay_cache)))
		failures += "горячий воздух: дрожит над невидимкой"
	H.remove_cloaking_source(src)
	ce_laser_glow_haze_alpha = old_haze
	ce_laser_glow_emissive_alpha = old_emissive

/**
 * Прожоги: каждое попадание луча в броню, которая греется, оставляет прожог на её вещи со стороны
 * стрелка, не больше `ce_laser_scorch_max`. Свежий вспыхивает добела, потом светится по жару своей
 * брони и светит мимо темноты, пока она горячая. Плитоноска рисует прожоги своей пластины, в руках
 * их не видно. Мягкая броня прожогов не получает, а у рига прожог светится по жару своей группы зон.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_scorch(list/failures)
	var/list/scorch_states = icon_states(CE_LASER_SCORCH_ICON)
	var/list/edges = ce_laser_heat_stage_temperatures
	for(var/stage in 0 to length(edges))
		for(var/side in GLOB.cardinal)
			if(!("[stage]_[side]" in scorch_states))
				failures += "прожоги: в иконке нет состояния [stage]_[side]"
	// Стрелок спереди, сзади, слева и справа от носителя, куда бы тот ни смотрел.
	for(var/facing in GLOB.cardinal)
		if(ce_get_scorch_visible_dir(facing, facing) != SOUTH || ce_get_scorch_visible_dir(facing, turn(facing, 180)) != NORTH || ce_get_scorch_visible_dir(facing, turn(facing, 90)) != WEST || ce_get_scorch_visible_dir(facing, turn(facing, -90)) != EAST)
			failures += "прожоги: у носителя лицом на [dir2text(facing)] прожог виден не с той стороны"

	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	if(!armor)
		failures += "прожоги: не удалось одеть человека"
		return
	var/obj/item/clothing/plate = armor.holder
	var/obj/item/clothing/carrier = H.wear_suit
	H.set_dir(SOUTH)
	beam_hit(H, BP_CHEST, /obj/item/projectile/beam/midlaser, NORTH)
	var/datum/ce_scorch_mark/first_mark = LAZYACCESS(plate.ce_scorch_marks, 1)
	if(LAZYLEN(plate.ce_scorch_marks) != 1 || first_mark.visible_dir != NORTH || LAZYLEN(carrier.ce_scorch_marks))
		failures += "прожоги: луч в спину — на пластине [LAZYLEN(plate.ce_scorch_marks)] прожогов, виден с [first_mark?.visible_dir], на плитоноске [LAZYLEN(carrier.ce_scorch_marks)]"
		return
	for(var/shot in 1 to ce_laser_scorch_max + 1)
		beam_hit(H, BP_CHEST, /obj/item/projectile/beam/midlaser)
	if(length(plate.ce_scorch_marks) != ce_laser_scorch_max || (first_mark in plate.ce_scorch_marks))
		failures += "прожоги: на пластине [length(plate.ce_scorch_marks)] прожогов при пределе [ce_laser_scorch_max], старый [(first_mark in plate.ce_scorch_marks) ? "не вытеснен" : "вытеснен"]"

	var/list/drawn = get_scorch_states(carrier.get_mob_overlay(H, slot_wear_suit_str))
	check_scorch_drawn(drawn, length(edges), TRUE, "свежие на горячей", failures)
	for(var/datum/ce_scorch_mark/mark as anything in plate.ce_scorch_marks)
		mark.fresh_until = 0
	set_heat(armor, null, 0, 0)
	drawn = get_scorch_states(carrier.get_mob_overlay(H, slot_wear_suit_str))
	check_scorch_drawn(drawn, 0, FALSE, "остывшие", failures)
	set_heat(armor, null, edges[3], 0)
	drawn = get_scorch_states(carrier.get_mob_overlay(H, slot_wear_suit_str))
	check_scorch_drawn(drawn, 3, TRUE, "на оранжевой", failures)
	drawn = get_scorch_states(carrier.get_mob_overlay(H, slot_l_hand_str))
	if(length(drawn[1]) || drawn[2])
		failures += "прожоги: плитоноска в руках рисует [length(drawn[1])] прожогов"

	var/datum/ce_scorch_mark/last_mark = plate.ce_scorch_marks[length(plate.ce_scorch_marks)]
	ce_laser_scorch_enabled = FALSE
	beam_hit(H, BP_CHEST, /obj/item/projectile/beam/midlaser)
	drawn = get_scorch_states(carrier.get_mob_overlay(H, slot_wear_suit_str))
	ce_laser_scorch_enabled = TRUE
	if(plate.ce_scorch_marks[length(plate.ce_scorch_marks)] != last_mark || length(drawn[1]))
		failures += "прожоги: выключенные всё равно появляются или рисуются"

	var/mob/living/carbon/human/coated = make_coated_human(ARMOR_LASER_SMALL)
	var/obj/item/clothing/coat = coated?.wear_suit
	if(coated)
		beam_hit(coated, BP_CHEST, /obj/item/projectile/beam/midlaser)
	if(!coat || LAZYLEN(coat.ce_scorch_marks))
		failures += "прожоги: мягкая куртка прожглась или не надета"

	var/mob/living/carbon/human/rigged = make_rigged_human(/obj/item/rig/merc)
	if(!rigged)
		failures += "прожоги: не удалось одеть человека в риг"
		return
	beam_hit(rigged, BP_CHEST, /obj/item/projectile/beam/midlaser)
	var/obj/item/clothing/chest = rigged.wear_suit
	var/datum/ce_scorch_mark/rig_mark = LAZYACCESS(chest.ce_scorch_marks, 1)
	if(rig_mark?.group != CE_ARMOR_ZONE_TORSO)
		failures += "прожоги: прожог на торсе рига светится по группе [rig_mark?.group]"

/// Все прожоги на картинке нарисованы на ступени `stage` и, если `emissive`, светят мимо темноты.
/datum/unit_test/combat_extended/laser_heat/proc/check_scorch_drawn(list/drawn, stage, emissive, label, list/failures)
	var/list/states = drawn[1]
	var/list/wrong = list()
	for(var/state in states)
		if(copytext(state, 1, findtext(state, "_")) != "[stage]")
			wrong += state
	if(length(states) != ce_laser_scorch_max || length(wrong) || drawn[2] != (emissive ? length(states) : 0))
		failures += "прожоги, [label]: нарисовано [length(states)], не на ступени [stage] — [jointext(wrong, " ")], эмиссивов [drawn[2]]"

/**
 * Выключатель: лучи снова идут по формуле Bay, броня не греется, накопленный жар не жжёт и не
 * размягчает броню, хладагент и брызги ничего не делают, а броня всё равно остывает.
 */
/datum/unit_test/combat_extended/laser_heat/proc/check_switch(list/failures)
	var/mob/living/carbon/human/H = make_human(list(/obj/item/clothing/accessory/armor_plate/merc))
	var/datum/extension/armor/armor = plate_armor(H)
	if(!armor)
		failures += "выключатель: не удалось одеть человека"
		return
	ce_laser_heat_enabled = FALSE
	var/blocked = H.get_blocked_ratio(BP_CHEST, DAMAGE_BURN, DAMAGE_FLAG_LASER, 10, 40)
	var/list/result = H.modify_damage_by_armor(BP_CHEST, 40, DAMAGE_BURN, DAMAGE_FLAG_LASER, H, 10, TRUE)
	if(blocked >= 1 || result[1] <= 0 || armor.ce_heat)
		failures += "выключатель: G40E через merc-пластину — держит [blocked], прошло [result[1]], нагрета [!!armor.ce_heat]; ожидалась формула Bay без нагрева"

	set_heat(armor, null, 1, 1)
	var/list/burns = life_tick_burns(H)
	if(length(burns))
		failures += "выключатель: раскалённая броня жжёт [describe_burns(burns)]"
	if(armor.get_armor_sharp_ballistic() != armor.ce_get_cold_sharp_ballistic() || armor.ce_get_hot_wear_mult() != 1)
		failures += "выключатель: раскалённая броня размягчается или быстрее изнашивается"
	if(length(armor.ce_get_laser_codex_lines()) || ce_beam_codex_line(/obj/item/projectile/beam/midlaser))
		failures += "выключатель: кодекс пишет строки о нагреве"

	var/obj/item/reagent_containers/glass/beaker/large/beaker = new(H.loc)
	spawned += beaker
	beaker.reagents.add_reagent(/datum/reagent/coolant, 100)
	H.put_in_active_hand(beaker)
	H.wear_suit.use_tool(beaker, H)
	beaker.reagents.touch(H)
	if(armor.ce_get_temperature() != 1 || ce_get_coolant_amount(beaker.reagents) != 100)
		failures += "выключатель: хладагент остужает броню до [armor.ce_get_temperature()], осталось [ce_get_coolant_amount(beaker.reagents)] хладагента"

	armor.ce_process_heat(10)
	var/expected = ce_cool_temperature(1, 10)
	if(abs(armor.ce_get_temperature() - expected) > CE_LASER_TOLERANCE)
		failures += "выключатель: броня остыла до [armor.ce_get_temperature()], ожидалось [expected]"
	ce_laser_heat_enabled = TRUE

#undef CE_LASER_TOLERANCE
#undef CE_LASER_SCORCH_ICON


/*
	Рикошеты от стен. Площадку тест строит сам, в космосе у метки `space_turf`, и убирает за собой:
	пол без воздуха, на нём стены. Пол нужен потому, что космос у края карты уносит всё, что в него
	влетело, на другой уровень (`touch_map_edge()`).

	Время не идёт: шаг полёта делается вручную, теми же строками, что в кор `Process()`, так что
	рикошет идёт настоящим путём — через `Move()` и `Bump()`. Шанс в полётных проверках заведомо
	100% (`CE_RICOCHET_CERTAIN`), разброс выключен. Бросков в тесте нет, кроме самого разброса и
	промаха по стрелку — их проверки от исхода броска не зависят.
*/
#define CE_RICOCHET_TOLERANCE 0.01
/// Множитель шанса снаряда, с которым любой ненулевой шанс — 100%.
#define CE_RICOCHET_CERTAIN 1000
/// Сколько раз повторяются проверки со случайным исходом.
#define CE_RICOCHET_TRIALS 40

/datum/unit_test/combat_extended/ricochet
	name = "CE: Рикошеты от стен"

/datum/unit_test/combat_extended/ricochet/start_test()
	if(!claim_arena())
		return 1

	var/old_enabled = ce_ricochet_enabled
	var/old_scatter = ce_ricochet_scatter_degrees
	var/old_scale = ce_ricochet_chance_scale
	var/old_debug = ce_ricochet_debug
	var/old_pixel_aim = ce_pixel_aim_enabled
	var/old_corner_tolerance = ce_corner_cut_tolerance
	ce_ricochet_enabled = TRUE
	ce_ricochet_scatter_degrees = 0
	ce_ricochet_chance_scale = 1
	ce_ricochet_debug = FALSE
	// Клетка, из которой пуля встречает угловую стену, зависит от среза угла.
	ce_pixel_aim_enabled = TRUE
	ce_corner_cut_tolerance = 4
	var/list/failures = list()
	pave_arena(/turf/simulated/floor/airless)

	check_surfaces(failures)
	check_doors(failures)
	check_windows(failures)
	check_bare_turfs(failures)
	check_chance(failures)
	check_eligibility(failures)
	check_faces(failures)
	check_corners(failures)
	check_other_bounces(failures)
	check_window_row(failures)
	check_bookkeeping(failures)
	check_aim_kept(failures)
	check_wall_damage(failures)
	check_pellets(failures)
	check_limits(failures)
	check_effects(failures)
	check_firer(failures)
	check_scatter(failures)
	check_switch(failures)
	check_debug(failures)

	ce_ricochet_enabled = old_enabled
	ce_ricochet_scatter_degrees = old_scatter
	ce_ricochet_chance_scale = old_scale
	ce_ricochet_debug = old_debug
	ce_pixel_aim_enabled = old_pixel_aim
	ce_corner_cut_tolerance = old_corner_tolerance
	reset_arena()
	cleanup()
	pave_arena(/turf/space)
	var/arena_problem = describe_arena_problem()
	if(arena_problem)
		failures += "площадка после теста: [arena_problem]"
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Пуля рикошетит от стены по её материалу и углу, теряет урон по шансу и отдаёт остальное стене, отскакивает зеркально от нужной грани и не больше своего предела.")
	return 1

/**
 * Снаряд `projectile_type` в середине площадки, с вектором на клетку со сдвигом `target_x`,
 * `target_y`. Шанс рикошета заведомо 100%, если не задан свой `chance_mult`.
 */
/datum/unit_test/combat_extended/ricochet/proc/aim(target_x, target_y, projectile_type = /obj/item/projectile/bullet/pistol, chance_mult = CE_RICOCHET_CERTAIN)
	RETURN_TYPE(/obj/item/projectile)
	var/obj/item/projectile/projectile = new projectile_type(center)
	spawned += projectile
	// Предмет, созданный прямо на клетке, получает случайный сдвиг (`randpixel`), а вектор начинается
	// с него. Снаряд из ствола рождается в гильзе и летит из середины клетки.
	projectile.pixel_x = 0
	projectile.pixel_y = 0
	projectile.original = spot(target_x, target_y)
	projectile.setup_trajectory(center, projectile.original)
	projectile.ce_ricochet_chance_mult = chance_mult
	return projectile

/// Шанс поверхности: стена — по материалу, армированная — среднее геометрическое, остальное — ноль.
/datum/unit_test/combat_extended/ricochet/proc/check_surfaces(list/failures)
	var/material/steel = SSmaterials.get_material_by_name(MATERIAL_STEEL)
	var/material/plasteel = SSmaterials.get_material_by_name(MATERIAL_PLASTEEL)
	var/material/glass = SSmaterials.get_material_by_name(MATERIAL_GLASS)
	if(steel.ce_ricochet_chance <= 0 || plasteel.ce_ricochet_chance <= steel.ce_ricochet_chance || glass.ce_ricochet_chance != 0)
		failures += "поверхности: сталь [steel.ce_ricochet_chance], пласталь [plasteel.ce_ricochet_chance], стекло [glass.ce_ricochet_chance]; ожидалось 0 < сталь < пласталь, стекло 0"

	var/turf/simulated/wall/plain = build_wall(1, 0)
	var/turf/simulated/wall/reinforced = build_wall(-1, 0, /turf/simulated/wall/r_wall)
	var/turf/simulated/wall/wooden = build_wall(0, 1, /turf/simulated/wall/wood)
	// Стеклянная стена с арматурой: `r_wall/rglass_wall` в Bay материалов не меняет, остаётся стальной.
	var/turf/simulated/wall/glazed = build_wall(0, -1, /turf/simulated/wall/r_wall)
	glazed.material = glass
	var/obj/item/projectile/projectile = aim(2, 2)
	var/plain_chance = plain.ce_get_ricochet_surface_chance(projectile)
	if(abs(plain_chance - steel.ce_ricochet_chance) > CE_RICOCHET_TOLERANCE)
		failures += "поверхности: стальная стена даёт [plain_chance], у стали [steel.ce_ricochet_chance]"
	var/reinforced_chance = reinforced.ce_get_ricochet_surface_chance(projectile)
	var/expected_reinforced = sqrt(steel.ce_ricochet_chance * plasteel.ce_ricochet_chance)
	if(abs(reinforced_chance - expected_reinforced) > CE_RICOCHET_TOLERANCE)
		failures += "поверхности: армированная стена даёт [reinforced_chance], ожидалось среднее геометрическое [expected_reinforced]"
	if(wooden.ce_get_ricochet_surface_chance(projectile) != 0 || glazed.ce_get_ricochet_surface_chance(projectile) != 0)
		failures += "поверхности: деревянная стена даёт [wooden.ce_get_ricochet_surface_chance(projectile)], стеклянная с арматурой — [glazed.ce_get_ricochet_surface_chance(projectile)]; ожидались нули"
	if(center.ce_get_ricochet_surface_chance(projectile) != 0 || projectile.ce_get_ricochet_surface_chance(projectile) != 0)
		failures += "поверхности: шанс есть у пола или у самого снаряда"
	reset_arena()

/// Двери: закрытая — по своему материалу, шлюз со стеклом — на долю, открытая и окошко раздачи — ноль.
/datum/unit_test/combat_extended/ricochet/proc/check_doors(list/failures)
	var/material/steel = SSmaterials.get_material_by_name(MATERIAL_STEEL)
	var/material/plasteel = SSmaterials.get_material_by_name(MATERIAL_PLASTEEL)
	var/obj/machinery/door/airlock = put(1, 0, /obj/machinery/door/airlock)
	var/obj/machinery/door/glazed = put(-1, 0, /obj/machinery/door/airlock/glass)
	var/obj/machinery/door/blast_door = put(0, 1, /obj/machinery/door/blast/regular)
	var/obj/machinery/door/hatch = put(0, -1, /obj/machinery/door/window)
	var/airlock_chance = airlock.ce_get_ricochet_surface_chance(null)
	if(!airlock.density || abs(airlock_chance - steel.ce_ricochet_chance) > CE_RICOCHET_TOLERANCE)
		failures += "двери: закрытый шлюз даёт [airlock_chance], у стали [steel.ce_ricochet_chance]"
	var/glazed_chance = glazed.ce_get_ricochet_surface_chance(null)
	if(ce_ricochet_glass_door_mult >= 1 || abs(glazed_chance - steel.ce_ricochet_chance * ce_ricochet_glass_door_mult) > CE_RICOCHET_TOLERANCE)
		failures += "двери: шлюз со стеклом даёт [glazed_chance], ожидалась доля [ce_ricochet_glass_door_mult] от стали [steel.ce_ricochet_chance]"
	var/blast_chance = blast_door.ce_get_ricochet_surface_chance(null)
	if(!blast_door.density || abs(blast_chance - plasteel.ce_ricochet_chance) > CE_RICOCHET_TOLERANCE)
		failures += "двери: закрытый гермозатвор даёт [blast_chance], у пластали [plasteel.ce_ricochet_chance]"
	if(!hatch.density || hatch.ce_get_ricochet_surface_chance(null) != 0)
		failures += "двери: окошко раздачи даёт [hatch.ce_get_ricochet_surface_chance(null)], ожидался 0"
	airlock.set_density(FALSE)
	if(airlock.ce_get_ricochet_surface_chance(null) != 0)
		failures += "двери: открытый шлюз даёт [airlock.ce_get_ricochet_surface_chance(null)], ожидался 0"
	reset_arena()

/// Окна: рикошетит только армированное во всю клетку, и боросиликатное — охотнее обычного.
/datum/unit_test/combat_extended/ricochet/proc/check_windows(list/failures)
	var/material/glass = SSmaterials.get_material_by_name(MATERIAL_GLASS)
	var/material/boron = SSmaterials.get_material_by_name(MATERIAL_BORON_GLASS)
	var/obj/structure/window/reinforced_pane = put(1, 0, /obj/structure/window/reinforced/full)
	var/obj/structure/window/boron_pane = put(-1, 0, /obj/structure/window/boron_reinforced/full)
	var/obj/structure/window/plain_pane = put(0, 1, /obj/structure/window/basic/full)
	var/obj/structure/window/edge_pane = put(0, -1, /obj/structure/window/reinforced)
	var/reinforced_chance = reinforced_pane.ce_get_ricochet_surface_chance(null)
	if(reinforced_chance <= 0 || abs(reinforced_chance - glass.ce_reinforced_window_ricochet_chance) > CE_RICOCHET_TOLERANCE)
		failures += "окна: армированное во всю клетку даёт [reinforced_chance], у стекла [glass.ce_reinforced_window_ricochet_chance]"
	var/boron_chance = boron_pane.ce_get_ricochet_surface_chance(null)
	if(boron_chance <= reinforced_chance || abs(boron_chance - boron.ce_reinforced_window_ricochet_chance) > CE_RICOCHET_TOLERANCE)
		failures += "окна: армированное боросиликатное даёт [boron_chance], у стекла [boron.ce_reinforced_window_ricochet_chance], у обычного армированного [reinforced_chance]"
	if(!plain_pane.is_fulltile() || plain_pane.ce_get_ricochet_surface_chance(null) != 0)
		failures += "окна: без арматуры даёт [plain_pane.ce_get_ricochet_surface_chance(null)], ожидался 0"
	if(edge_pane.is_fulltile() || !edge_pane.reinf_material || edge_pane.ce_get_ricochet_surface_chance(null) != 0)
		failures += "окна: армированное на краю клетки даёт [edge_pane.ce_get_ricochet_surface_chance(null)], ожидался 0"
	reset_arena()

/// Клетки без материала: несимулируемая стена и обшивка шаттла — как армированная стена, порода и камень культа — как их материалы, нарисованное окно и пол — ноль.
/datum/unit_test/combat_extended/ricochet/proc/check_bare_turfs(list/failures)
	var/material/steel = SSmaterials.get_material_by_name(MATERIAL_STEEL)
	var/material/plasteel = SSmaterials.get_material_by_name(MATERIAL_PLASTEEL)
	var/material/stone = SSmaterials.get_material_by_name(MATERIAL_SANDSTONE)
	var/material/cult = SSmaterials.get_material_by_name(MATERIAL_CULT)
	var/reinforced_wall_chance = sqrt(steel.ce_ricochet_chance * plasteel.ce_ricochet_chance)
	var/turf/vault = build_turf(1, 0, /turf/unsimulated/wall)
	var/turf/hull = build_turf(-1, 0, /turf/simulated/shuttle/wall)
	var/turf/rock = build_turf(0, 1, /turf/simulated/mineral)
	var/turf/painted = build_turf(0, -1, /turf/unsimulated/wall/fakeglass)
	var/turf/shrine = build_turf(1, 1, /turf/unsimulated/wall/cult)
	if(abs(vault.ce_get_ricochet_surface_chance(null) - reinforced_wall_chance) > 0.5)
		failures += "клетки: несимулируемая стена даёт [vault.ce_get_ricochet_surface_chance(null)], у армированной стены [reinforced_wall_chance]"
	if(abs(hull.ce_get_ricochet_surface_chance(null) - reinforced_wall_chance) > 0.5)
		failures += "клетки: обшивка шаттла даёт [hull.ce_get_ricochet_surface_chance(null)], у армированной стены [reinforced_wall_chance]"
	if(stone.ce_ricochet_chance <= 0 || rock.ce_get_ricochet_surface_chance(null) != stone.ce_ricochet_chance)
		failures += "клетки: порода даёт [rock.ce_get_ricochet_surface_chance(null)], у песчаника [stone.ce_ricochet_chance]"
	if(shrine.ce_get_ricochet_surface_chance(null) != cult.ce_ricochet_chance)
		failures += "клетки: камень культа даёт [shrine.ce_get_ricochet_surface_chance(null)], у его материала [cult.ce_ricochet_chance]"
	if(painted.ce_get_ricochet_surface_chance(null) != 0)
		failures += "клетки: нарисованное окно даёт [painted.ce_get_ricochet_surface_chance(null)], ожидался 0"
	center.ce_ricochet_chance = 5
	if(center.density || center.ce_get_ricochet_surface_chance(null) != 0)
		failures += "клетки: неплотная клетка с числом даёт [center.ce_get_ricochet_surface_chance(null)], ожидался 0"
	center.ce_ricochet_chance = 0
	reset_arena()

/// Шанс рикошета: в лоб — ноль, под 45° — шанс поверхности, дальше по тангенсу до 100%; множители и спад.
/datum/unit_test/combat_extended/ricochet/proc/check_chance(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	var/obj/item/projectile/head_on = aim(3, 0, chance_mult = 1)
	var/obj/item/projectile/diagonal = aim(2, 2, chance_mult = 1)
	var/obj/item/projectile/steep = aim(3, 1, chance_mult = 1)
	var/obj/item/projectile/grazing = aim(1, 3, chance_mult = 1)
	var/surface = wall.ce_get_ricochet_surface_chance(diagonal)

	var/head_on_chance = head_on.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(head_on_chance != 0)
		failures += "шанс: в лоб [head_on_chance], ожидался 0"
	var/diagonal_chance = diagonal.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(abs(diagonal_chance - surface) > CE_RICOCHET_TOLERANCE)
		failures += "шанс: под 45° [diagonal_chance], ожидался шанс поверхности [surface]"

	var/steep_tangent = abs(steep.trajectory.offset_y / steep.trajectory.offset_x)
	var/steep_chance = steep.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(steep_tangent <= 0 || steep_tangent >= 1 || abs(steep_chance - surface * steep_tangent) > CE_RICOCHET_TOLERANCE)
		failures += "шанс: круто к стене [steep_chance], ожидалось [surface] × тангенс [steep_tangent]"
	var/grazing_tangent = abs(grazing.trajectory.offset_y / grazing.trajectory.offset_x)
	var/grazing_chance = grazing.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(grazing_tangent <= 1 || abs(grazing_chance - min(100, surface * grazing_tangent)) > CE_RICOCHET_TOLERANCE)
		failures += "шанс: вскользь [grazing_chance], ожидалось [surface] × тангенс [grazing_tangent], не больше 100"
	grazing.ce_ricochet_chance_mult = CE_RICOCHET_CERTAIN
	if(grazing.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X) != 100)
		failures += "шанс: с заведомым множителем [grazing.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)], а не 100"
	// Полёт ровно вдоль грани: поперёк неё шаг нулевой, тангенс бесконечен.
	var/obj/item/projectile/parallel = aim(0, 3, chance_mult = 1)
	var/parallel_chance = parallel.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	parallel.ce_ricochet_chance_mult = 0
	if(parallel_chance != 100 || parallel.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X) != 0)
		failures += "шанс: вдоль стены [parallel_chance], с нулевым множителем [parallel.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)]; ожидалось 100 и 0"

	diagonal.ce_ricochets = 2
	var/decayed_chance = diagonal.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(abs(decayed_chance - surface * ce_ricochet_chance_decay ** 2) > CE_RICOCHET_TOLERANCE)
		failures += "шанс: после двух рикошетов [decayed_chance], ожидалось [surface * ce_ricochet_chance_decay ** 2]"
	diagonal.ce_ricochets = 0
	diagonal.ce_ricochet_chance_mult = 0.5
	var/halved_chance = diagonal.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(abs(halved_chance - surface * 0.5) > CE_RICOCHET_TOLERANCE)
		failures += "шанс: с множителем снаряда 0.5 — [halved_chance], ожидалось [surface * 0.5]"
	diagonal.ce_ricochet_chance_mult = 1
	ce_ricochet_chance_scale = 0.5
	var/scaled_chance = diagonal.ce_get_ricochet_chance(wall, CE_RICOCHET_AXIS_X)
	if(abs(scaled_chance - surface * 0.5) > CE_RICOCHET_TOLERANCE)
		failures += "шанс: с общим множителем 0.5 — [scaled_chance], ожидалось [surface * 0.5]"
	ce_ricochet_chance_scale = 1
	reset_arena()

/// Кто рикошетит: цельные пули — да, мягкие, взрывные, противоматериальные, пробивные и лучи — нет; отказы кор `Bump()`.
/datum/unit_test/combat_extended/ricochet/proc/check_eligibility(list/failures)
	var/list/bouncing = list(
		/obj/item/projectile/bullet/pistol,
		/obj/item/projectile/bullet/pistol/holdout,
		/obj/item/projectile/bullet/flechette,
		/obj/item/projectile/bullet/shotgun,
		/obj/item/projectile/bullet/rifle,
		/obj/item/projectile/bullet/rifle/military,
		/obj/item/projectile/bullet/pellet/shotgun,
		/obj/item/projectile/bullet/pellet/fragment
	)
	var/list/never = list(
		/obj/item/projectile,
		/obj/item/projectile/test,
		/obj/item/projectile/beam,
		/obj/item/projectile/bullet,
		/obj/item/projectile/bullet/gyro,
		/obj/item/projectile/bullet/chemdart,
		/obj/item/projectile/bullet/magnetic,
		/obj/item/projectile/bullet/pistol/rubber,
		/obj/item/projectile/bullet/pistol/practice,
		/obj/item/projectile/bullet/pistol/cap,
		/obj/item/projectile/bullet/shotgun/beanbag,
		/obj/item/projectile/bullet/shotgun/practice,
		/obj/item/projectile/bullet/shotgun/manstopper,
		/obj/item/projectile/bullet/rifle/practice,
		/obj/item/projectile/bullet/rifle/military/practice,
		/obj/item/projectile/bullet/rifle/shell,
		/obj/item/projectile/bullet/rifle/shell/apds,
		/obj/item/projectile/bullet/pellet/blood
	)
	for(var/obj/item/projectile/path as anything in bouncing)
		if(initial(path.ce_ricochets_max) <= 0)
			failures += "кто рикошетит: [path] не рикошетит"
	for(var/obj/item/projectile/path as anything in never)
		if(initial(path.ce_ricochets_max) != 0)
			failures += "кто рикошетит: [path] рикошетит [initial(path.ce_ricochets_max)] раз"
	var/obj/item/projectile/fragment = /obj/item/projectile/bullet/pellet/fragment
	var/obj/item/projectile/pistol = /obj/item/projectile/bullet/pistol
	if(initial(fragment.ce_ricochets_max) <= initial(pistol.ce_ricochets_max))
		failures += "кто рикошетит: осколки гранаты рикошетят не больше пули"

	var/turf/simulated/wall/wall = build_wall(1, 0)
	var/obj/item/projectile/bullet = aim(2, 2)
	if(!bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пистолетная пуля от стальной стены не может"
	bullet.ce_ricochets = bullet.ce_ricochets_max
	if(bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пуля, исчерпавшая рикошеты, может ещё"
	bullet.ce_ricochets = 0

	bullet.penetrating = ce_ricochet_max_penetrating
	if(!bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пуля с `penetrating` на пороге не может"
	bullet.penetrating = ce_ricochet_max_penetrating + 1
	if(bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пробивная пуля может"
	bullet.penetrating = 0

	var/old_damage = bullet.damage
	bullet.damage = 0
	if(bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пуля без урона может"
	bullet.damage = old_damage
	bullet.nodamage = TRUE
	if(bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пуля с `nodamage` может"
	bullet.nodamage = FALSE
	var/obj/item/projectile/beam = aim(2, 2, /obj/item/projectile/beam)
	beam.ce_ricochets_max = 1
	if(beam.ce_can_ricochet(wall))
		failures += "кто рикошетит: луч может, стоит ему разрешить"

	bullet.bumped = TRUE
	if(bullet.ce_can_ricochet(wall) || !bullet.ce_can_ricochet(wall, TRUE))
		failures += "кто рикошетит: второе столкновение за шаг — [bullet.ce_can_ricochet(wall)], вызванное намеренно — [bullet.ce_can_ricochet(wall, TRUE)]; ожидалось наоборот"
	bullet.bumped = FALSE
	bullet.permutated += wall
	if(bullet.ce_can_ricochet(wall))
		failures += "кто рикошетит: пуля может от стены, сквозь которую уже прошла"
	bullet.permutated -= wall
	if(bullet.ce_can_ricochet(center))
		failures += "кто рикошетит: пуля может от пола"
	reset_arena()

/**
 * Четыре грани: шаг по прямой в стену переворачивает составляющую поперёк неё и не трогает вторую,
 * снаряд остаётся в своей клетке, а следующим шагом уходит от стены.
 */
/datum/unit_test/combat_extended/ricochet/proc/check_faces(list/failures)
	// list(стена x, стена y, цель x, цель y)
	var/list/shots = list(
		list(1, 0, 3, 1),
		list(-1, 0, -3, -1),
		list(0, 1, 1, 3),
		list(0, -1, -1, -3)
	)
	for(var/list/shot in shots)
		var/label = "грань [shot[1]],[shot[2]]"
		build_wall(shot[1], shot[2])
		var/obj/item/projectile/projectile = aim(shot[3], shot[4])
		var/datum/plot_vector/vector = projectile.trajectory
		var/expected_x = shot[1] ? -vector.offset_x : vector.offset_x
		var/expected_y = shot[2] ? -vector.offset_y : vector.offset_y
		if(!fly_step(projectile))
			failures += "[label]: пуля застряла в стене, рикошетов [projectile.ce_ricochets]"
			reset_arena()
			continue
		if(projectile.ce_ricochets != 1 || projectile.loc != center || projectile.location.return_turf() != center)
			failures += "[label]: рикошетов [projectile.ce_ricochets], пуля в своей клетке — [projectile.loc == center], точка вектора в ней — [projectile.location.return_turf() == center]"
		if(abs(vector.offset_x - expected_x) > CE_RICOCHET_TOLERANCE || abs(vector.offset_y - expected_y) > CE_RICOCHET_TOLERANCE)
			failures += "[label]: шаг [vector.offset_x],[vector.offset_y], ожидался [expected_x],[expected_y]"
		if(!fly_step(projectile) || projectile.loc != spot(-shot[1], -shot[2]))
			failures += "[label]: после рикошета пуля не ушла от стены"
		reset_arena()

/**
 * Диагональный шаг в клетку (1, 1): грань решают соседние клетки, а в углу — граница клетки,
 * пересечённая первой. Под 45° ровно границы пересекаются разом, поэтому в углы пуля летит под 34°
 * и 56°. Там, где стена продолжается вбок, порядок границ ничего не решает: пуля под 34° и 56°
 * проверяет это с обеих сторон.
 */
/datum/unit_test/combat_extended/ricochet/proc/check_corners(list/failures)
	// list(название, стены помимо угловой, цель x, цель y, перевёрнутая составляющая, клетка пули
	// после рикошета). На диагональном шаге пуля сперва входит в клетку, чью границу линия полёта
	// пересекает первой (срез угла, `projectile_aim.dm`): стена в ней отбивает пулю из её клетки, а
	// из свободной пуля встречает угловую стену уже обычным шагом.
	var/list/corners = list(
		list("стена продолжается по y", list(list(1, 0)), 2, 2, CE_RICOCHET_AXIS_X, list(0, 0)),
		list("стена продолжается по x", list(list(0, 1)), 2, 2, CE_RICOCHET_AXIS_Y, list(0, 0)),
		list("стена продолжается по y, граница x первой", list(list(1, 0)), 3, 2, CE_RICOCHET_AXIS_X, list(0, 0)),
		list("стена продолжается по y, граница y первой", list(list(1, 0)), 2, 3, CE_RICOCHET_AXIS_X, list(0, 1)),
		list("стена продолжается по x, граница x первой", list(list(0, 1)), 3, 2, CE_RICOCHET_AXIS_Y, list(1, 0)),
		list("стена продолжается по x, граница y первой", list(list(0, 1)), 2, 3, CE_RICOCHET_AXIS_Y, list(0, 0)),
		list("внутренний угол, граница x первой", list(list(1, 0), list(0, 1)), 3, 2, CE_RICOCHET_AXIS_X, list(0, 0)),
		list("внутренний угол, граница y первой", list(list(1, 0), list(0, 1)), 2, 3, CE_RICOCHET_AXIS_Y, list(0, 0)),
		list("наружный угол, граница x первой", list(), 3, 2, CE_RICOCHET_AXIS_Y, list(1, 0)),
		list("наружный угол, граница y первой", list(), 2, 3, CE_RICOCHET_AXIS_X, list(0, 1))
	)
	for(var/list/corner in corners)
		var/label = "угол, [corner[1]]"
		build_wall(1, 1)
		for(var/list/extra in corner[2])
			build_wall(extra[1], extra[2])
		var/obj/item/projectile/projectile = aim(corner[3], corner[4])
		var/datum/plot_vector/vector = projectile.trajectory
		var/expected_x = corner[5] == CE_RICOCHET_AXIS_X ? -vector.offset_x : vector.offset_x
		var/expected_y = corner[5] == CE_RICOCHET_AXIS_Y ? -vector.offset_y : vector.offset_y
		var/list/stand = corner[6]
		if(!fly_step(projectile))
			failures += "[label]: пуля застряла в стене"
		else if(projectile.ce_ricochets != 1 || projectile.loc != spot(stand[1], stand[2]))
			failures += "[label]: рикошетов [projectile.ce_ricochets], пуля в клетке [projectile.x - center.x],[projectile.y - center.y], ожидалась [stand[1]],[stand[2]]"
		else if(abs(vector.offset_x - expected_x) > CE_RICOCHET_TOLERANCE || abs(vector.offset_y - expected_y) > CE_RICOCHET_TOLERANCE)
			failures += "[label]: шаг [vector.offset_x],[vector.offset_y], ожидался [expected_x],[expected_y]"
		reset_arena()

/**
 * Двери, окна и клетки без материала отбивают пулю настоящим шагом. Клетка двери или окна сама не
 * плотная, и повтор столкновения от BYOND приходит с ней, а не с дверью: без гашения эха отскочившую
 * пулю добивала бы клетка.
 */
/datum/unit_test/combat_extended/ricochet/proc/check_other_bounces(list/failures)
	// list(название, тип)
	var/list/barriers = list(
		list("шлюз", /obj/machinery/door/airlock),
		list("гермозатвор", /obj/machinery/door/blast/regular),
		list("армированное окно", /obj/structure/window/reinforced/full),
		list("несимулируемая стена", /turf/unsimulated/wall),
		list("порода", /turf/simulated/mineral)
	)
	for(var/list/barrier in barriers)
		if(ispath(barrier[2], /turf))
			build_turf(1, 0, barrier[2])
		else
			put(1, 0, barrier[2])
		var/obj/item/projectile/bullet = aim(3, 1)
		if(!fly_step(bullet) || bullet.ce_ricochets != 1 || bullet.loc != center)
			failures += "преграда, [barrier[1]]: пуля не отскочила, рикошетов [bullet.ce_ricochets]"
		else if(!fly_step(bullet) || bullet.loc != spot(-1, 0))
			failures += "преграда, [barrier[1]]: после рикошета пуля не ушла от преграды"
		reset_arena()

/**
 * Ряд окон: диагональный шаг в окно, которое продолжается вбок. Клетки окон не плотные, и без счёта
 * окон за преграду грань решал бы порядок границ: пуля, первой пересёкшая границу по x, отскочила бы
 * по y.
 */
/datum/unit_test/combat_extended/ricochet/proc/check_window_row(list/failures)
	put(1, 1, /obj/structure/window/reinforced/full)
	put(1, 0, /obj/structure/window/reinforced/full)
	var/obj/item/projectile/bullet = aim(3, 2)
	var/datum/plot_vector/vector = bullet.trajectory
	var/expected_x = -vector.offset_x
	var/expected_y = vector.offset_y
	if(!fly_step(bullet))
		failures += "ряд окон: пуля застряла в окне"
	else if(abs(vector.offset_x - expected_x) > CE_RICOCHET_TOLERANCE || abs(vector.offset_y - expected_y) > CE_RICOCHET_TOLERANCE)
		failures += "ряд окон: шаг [vector.offset_x],[vector.offset_y], ожидался [expected_x],[expected_y]"
	reset_arena()

/// Что рикошет меняет у снаряда: урон и боль по доле шанса между полом и потолком, счётчик, дальность, клетка выстрела. AP остаётся.
/datum/unit_test/combat_extended/ricochet/proc/check_bookkeeping(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	var/obj/item/projectile/bullet = aim(2, 2, /obj/item/projectile/bullet/rifle)
	bullet.agony = 10
	bullet.starting = spot(-2, 0)
	bullet.permutated += center
	var/old_damage = bullet.damage
	var/old_penetration = bullet.armor_penetration
	var/old_life_span = bullet.life_span
	var/share = (ce_ricochet_damage_keep_min + ce_ricochet_damage_keep_max) / 2
	bullet.ce_ricochet(wall, CE_RICOCHET_AXIS_X, share * 100)
	if(abs(bullet.damage - old_damage * share) > CE_RICOCHET_TOLERANCE || abs(bullet.agony - 10 * share) > CE_RICOCHET_TOLERANCE)
		failures += "учёт: урон [bullet.damage], боль [bullet.agony]; ожидалось [old_damage * share] и [10 * share]"
	if(old_penetration <= 0 || bullet.armor_penetration != old_penetration)
		failures += "учёт: AP [bullet.armor_penetration], ожидался прежний [old_penetration]"
	if(bullet.ce_ricochets != 1 || bullet.life_span != old_life_span - ce_ricochet_life_span_cost)
		failures += "учёт: рикошетов [bullet.ce_ricochets], шагов полёта [bullet.life_span] из [old_life_span]"
	if(length(bullet.permutated))
		failures += "учёт: пуля помнит, кого миновала до рикошета"
	if(bullet.starting != center || ce_get_attack_origin(bullet, null) != center)
		failures += "учёт: клетка выстрела не перенесена в клетку рикошета"

	var/obj/item/projectile/capped = aim(2, 2)
	old_damage = capped.damage
	capped.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
	if(ce_ricochet_damage_keep_max >= 1 || abs(capped.damage - old_damage * ce_ricochet_damage_keep_max) > CE_RICOCHET_TOLERANCE)
		failures += "учёт: при шансе 100% урон [capped.damage] из [old_damage], ожидался потолок [ce_ricochet_damage_keep_max]"
	var/obj/item/projectile/floored = aim(2, 2)
	old_damage = floored.damage
	floored.ce_ricochet(wall, CE_RICOCHET_AXIS_X, ce_ricochet_damage_keep_min * 50)
	if(abs(floored.damage - old_damage * ce_ricochet_damage_keep_min) > CE_RICOCHET_TOLERANCE)
		failures += "учёт: при шансе ниже пола урон [floored.damage] из [old_damage], ожидался пол [ce_ricochet_damage_keep_min]"
	reset_arena()

/// Зона прицела после рикошета остаётся той, в которую стреляли.
/datum/unit_test/combat_extended/ricochet/proc/check_aim_kept(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	var/strayed = 0
	for(var/trial in 1 to CE_RICOCHET_TRIALS)
		var/obj/item/projectile/bullet = aim(2, 2)
		bullet.def_zone = BP_HEAD
		bullet.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
		if(bullet.def_zone != BP_HEAD)
			strayed++
	if(strayed)
		failures += "зона: [strayed] из [CE_RICOCHET_TRIALS] отскочивших пуль сменили зону прицела"
	reset_arena()

/// Стена получает урон, который пуля на ней потеряла, и след от неё. HP стены — целые, отсюда допуск в единицу.
/datum/unit_test/combat_extended/ricochet/proc/check_wall_damage(list/failures)
	var/turf/simulated/wall/struck = build_wall(1, 0)
	var/turf/simulated/wall/grazed = build_wall(-1, 0)
	var/obj/item/projectile/direct = aim(2, 2, /obj/item/projectile/bullet/shotgun)
	var/obj/item/projectile/bounced = aim(2, 2, /obj/item/projectile/bullet/shotgun)
	var/share = (ce_ricochet_damage_keep_min + ce_ricochet_damage_keep_max) / 2
	struck.bullet_act(direct)
	bounced.ce_ricochet(grazed, CE_RICOCHET_AXIS_X, share * 100)
	var/direct_loss = struck.get_max_health() - struck.get_current_health()
	var/bounce_loss = grazed.get_max_health() - grazed.get_current_health()
	if(direct_loss <= 0 || abs(bounce_loss - direct_loss * (1 - share)) > 1)
		failures += "стена: рикошет слага снял [bounce_loss] HP, прямое попадание — [direct_loss]; ожидалась доля [1 - share]"
	if(!has_bullet_hole(grazed))
		failures += "стена: рикошет не оставил следа"
	reset_arena()

/// Дробь, потерянная по пути до стены, после рикошета не возвращается.
/datum/unit_test/combat_extended/ricochet/proc/check_pellets(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	var/obj/item/projectile/bullet/pellet/cloud = aim(2, 2, /obj/item/projectile/bullet/pellet/fragment)
	var/launched = 10
	cloud.pellets = launched
	cloud.starting = locate(center.x - 5, center.y, center.z)
	var/flown = cloud.get_pellets(get_dist(cloud.starting, cloud.loc))
	cloud.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
	var/after = cloud.get_pellets(get_dist(cloud.starting, cloud.loc))
	if(flown >= launched || cloud.pellets != flown || after != flown)
		failures += "дробь: из [launched] до стены долетело [flown], после рикошета в облаке [cloud.pellets], считается [after]"
	reset_arena()

/// Предел рикошетов: пуля отскакивает раз, осколки — дважды, дальше стена их останавливает. Без шанса — ни разу.
/datum/unit_test/combat_extended/ricochet/proc/check_limits(list/failures)
	build_wall(1, 0)
	var/turf/simulated/wall/far_wall = build_wall(-1, 0)
	var/obj/item/projectile/bullet = aim(3, 1)
	if(!fly_step(bullet) || bullet.ce_ricochets != 1)
		failures += "предел: пуля не отскочила от первой стены"
	else if(fly_step(bullet))
		failures += "предел: пуля отскочила и от второй стены, рикошетов [bullet.ce_ricochets]"
	else if(!has_bullet_hole(far_wall))
		failures += "предел: вторая стена остановила пулю без попадания"

	var/obj/item/projectile/cloud = aim(3, 1, /obj/item/projectile/bullet/pellet/fragment)
	if(!fly_step(cloud) || !fly_step(cloud) || cloud.ce_ricochets != 2)
		failures += "предел: осколки не отскочили дважды, рикошетов [cloud.ce_ricochets]"
	else if(fly_step(cloud))
		failures += "предел: осколки отскочили в третий раз"

	var/obj/item/projectile/unlucky = aim(3, 1, chance_mult = 0)
	if(fly_step(unlucky))
		failures += "предел: пуля с нулевым шансом отскочила"
	reset_arena()

/// Звук и искры: обычная пуля искрит, беззвучный снаряд — осколки гранаты — нет.
/datum/unit_test/combat_extended/ricochet/proc/check_effects(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	var/obj/item/projectile/bullet = aim(2, 2)
	bullet.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
	var/obj/sparks/sparks = locate() in center
	if(!sparks)
		failures += "эффекты: рикошет пули не искрит"
	else
		qdel(sparks)
	var/obj/item/projectile/fragment = aim(2, 2, /obj/item/projectile/bullet/pellet/fragment)
	fragment.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
	if(!fragment.silenced || (locate(/obj/sparks) in center))
		failures += "эффекты: беззвучный осколок искрит"
	reset_arena()

/// Стрелок: от тел пуля не рикошетит, своя пуля его не задевает, а отскочившая — задевает.
/datum/unit_test/combat_extended/ricochet/proc/check_firer(list/failures)
	var/mob/living/carbon/human/shooter = make_human()
	if(!shooter)
		failures += "стрелок: не удалось создать человека"
		return
	shooter.forceMove(spot(-1, 0))
	var/obj/item/projectile/fresh = aim(2, 2)
	fresh.firer = shooter
	if(fresh.ce_can_ricochet(shooter))
		failures += "стрелок: пуля может срикошетить от человека"
	fresh.Bump(shooter, TRUE)
	if(QDELETED(fresh) || (shooter in fresh.permutated))
		failures += "стрелок: пуля без рикошетов задела стрелка"

	var/obj/item/projectile/bounced = aim(2, 2)
	bounced.firer = shooter
	bounced.ce_ricochets = 1
	bounced.Bump(shooter, TRUE)
	if(!QDELETED(bounced) && !(shooter in bounced.permutated))
		failures += "стрелок: отскочившая пуля прошла сквозь стрелка, не задев"
	spawned -= shooter
	qdel(shooter)
	reset_arena()

/**
 * Разброс: вектор отклоняется от зеркального не больше чем на `ce_ricochet_scatter_degrees`, в
 * стену не разворачивается и держит шаг в клетку по большей оси. Пуля вскользь зеркалится почти
 * вдоль стены: без запрета разброс разворачивал бы в стену каждую пятую.
 */
/datum/unit_test/combat_extended/ricochet/proc/check_scatter(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	ce_ricochet_scatter_degrees = 30
	var/scattered = 0
	var/too_wide = 0
	var/into_wall = 0
	var/bad_step = 0
	for(var/trial in 1 to CE_RICOCHET_TRIALS)
		var/obj/item/projectile/steep = aim(3, 1)
		var/datum/plot_vector/vector = steep.trajectory
		var/mirror_x = -vector.offset_x
		var/mirror_y = vector.offset_y
		steep.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
		var/cosine = (mirror_x * vector.offset_x + mirror_y * vector.offset_y) / (sqrt(mirror_x ** 2 + mirror_y ** 2) * sqrt(vector.offset_x ** 2 + vector.offset_y ** 2))
		if(cosine < cos(ce_ricochet_scatter_degrees) - 0.0001)
			too_wide++
		if(cosine < 0.9999)
			scattered++
		if(abs(max(abs(vector.offset_x), abs(vector.offset_y)) - world.icon_size) > CE_RICOCHET_TOLERANCE || abs(vector.angle - Atan2(vector.offset_x, vector.offset_y)) > CE_RICOCHET_TOLERANCE)
			bad_step++

		var/obj/item/projectile/grazing = aim(1, 3)
		grazing.ce_ricochet(wall, CE_RICOCHET_AXIS_X, 100)
		if(vector.offset_x >= 0 || grazing.trajectory.offset_x > 0)
			into_wall++
	if(!scattered)
		failures += "разброс: ни одна из [CE_RICOCHET_TRIALS] пуль не отклонилась от зеркального угла"
	if(too_wide)
		failures += "разброс: [too_wide] пуль отклонились больше чем на [ce_ricochet_scatter_degrees]°"
	if(into_wall)
		failures += "разброс: [into_wall] пуль развернуло в стену"
	if(bad_step)
		failures += "разброс: у [bad_step] пуль шаг по большей оси не клетка или угол вектора не сходится с шагом"
	ce_ricochet_scatter_degrees = 0
	reset_arena()

/// Выключатель: пуля застревает в стене, как в Bay.
/datum/unit_test/combat_extended/ricochet/proc/check_switch(list/failures)
	var/turf/simulated/wall/wall = build_wall(1, 0)
	ce_ricochet_enabled = FALSE
	var/obj/item/projectile/bullet = aim(3, 1)
	if(fly_step(bullet))
		failures += "выключатель: пуля отскочила, рикошетов [bullet.ce_ricochets]"
	else if(!has_bullet_hole(wall))
		failures += "выключатель: стена остановила пулю без попадания"
	ce_ricochet_enabled = TRUE
	reset_arena()

/// Отладка: с ней столкновение со стеной идёт так же — и рикошет, и попадание.
/datum/unit_test/combat_extended/ricochet/proc/check_debug(list/failures)
	build_wall(1, 0)
	ce_ricochet_debug = TRUE
	var/obj/item/projectile/bounced = aim(3, 1)
	var/obj/item/projectile/embedded = aim(3, 1, chance_mult = 0)
	if(!fly_step(bounced) || bounced.ce_ricochets != 1 || fly_step(embedded))
		failures += "отладка: с ней пуля ведёт себя иначе, рикошетов [bounced.ce_ricochets]"
	ce_ricochet_debug = FALSE
	reset_arena()

#undef CE_RICOCHET_TOLERANCE
#undef CE_RICOCHET_CERTAIN
#undef CE_RICOCHET_TRIALS


/*
	Внешние бронеэлементы мехов (`mech_plates.dm`) — обычная жёсткая броня: рейтинг, пробитие и
	износ выводятся, своих чисел под снаряды нет.

	- Вещи: у каждого бронеэлемента обычное расширение брони, жёсткое и изнашиваемое, с острым
	  рейтингом против пуль.
	- Готовые мехи: боевой несёт противопульный бронеэлемент на каждой из шести частей, мех
	  наёмников — ни одного.
	- Встроенная броня: у каждого меха она есть, жёсткая и неизнашиваемая, лежит под
	  бронеэлементом; пулю и луч не держит, а каждый опорный удар холодным оружием ослабляет.
	  Внутренние бронеплиты — пустышки без брони, и корпус собран без них.
	- Слои: бронеэлемент — внешний слой своей части и только для пуль и лучей; удар, клинок и
	  взрыв идут мимо. Остаточный удар пробившей пули встречает тот же бронеэлемент.
	- Числа: ни одна пуля билда не доставляет через тир выше больше, чем через тир ниже, а по меху
	  без брони доставляет весь урон. Пистолет противопульный бронеэлемент не пробивает и почти не
	  наносит урона, противоматериальная пуля пробивает.
	- Сторона попадания: модификатор получает урон, прошедший броню, и забирается одним попаданием,
	  остаточный удар его не получает; остановленное бронёй целиком так и остаётся нулём. Урон самого снаряда `bullet_act()` не
	  трогает, а попадание в спину бьёт сильнее попадания в лицо ровно на модификаторы части.
	- Износ: попадание изнашивает бронеэлемент только той части, в которую пришлось. Попадания
	  доводят его до порога `ce_mech_plate_break_condition`, и он отваливается прямо в проходе по
	  слоям, ломается и больше ничего не держит.
	- Лучи: бронеэлемент держит луч вычитанием и греется; ни один луч билда не проходит через
	  ключ `laser` выше больше, чем через ключ ниже, а по меху без брони проходит целиком.
	  Противолазерный бронеэлемент несёт абляционное покрытие и карабинный луч не пропускает.
	  Настоящий луч свой тип урона сохраняет, а корпусу наносит физический урон. Раскалённый
	  бронеэлемент хуже держит пули и остывает. Изнашивает его только остановленная часть луча,
	  поэтому под непрерывным огнём он либо отваливается, либо перестаёт держать этот луч вовсе.
	- Приборы: целостность — единица у целого бронеэлемента и ноль ровно на пороге отваливания,
	  между ними идёт по HP и от попаданий только убывает. Строка для анализатора и меню несёт имя
	  бронеэлемента, проценты и жар, без бронеэлемента — «none». Ступень состояния идёт за
	  целостностью. Диагностика работает с питанием и блоком диагностики и сообщает пилотам о
	  каждой ступени хуже.

	Части тестовых мехов несут огромный запас HP: попадания здесь настоящие, а мех с выбитым
	корпусом раздаёт урон остальным частям и умирает.
*/
/datum/unit_test/combat_extended/mech_plates
	name = "CE: Внешняя броня мехов"

/// Все шесть частей меха.
/datum/unit_test/combat_extended/mech_plates/proc/parts_of(mob/living/exosuit/mech)
	RETURN_TYPE(/list)
	return list(mech.head, mech.body, mech.L_arm, mech.R_arm, mech.L_leg, mech.R_leg)

/// Боевой мех с бронеэлементами типа `plate_type` на всех частях, без типа — без брони.
/datum/unit_test/combat_extended/mech_plates/proc/make_mech(plate_type)
	var/mob/living/exosuit/premade/combat/mech = new(get_safe_turf() || locate(/turf/simulated/floor))
	spawned += mech
	for(var/obj/item/mech_component/part in parts_of(mech))
		part.max_hp = 100000
		part.update_health()
		qdel(part.remove_external_armour())
		if(plate_type)
			part.install_external_armour(new plate_type(part))
	return mech

/// Урон корпусу от одного настоящего попадания в грудь.
/datum/unit_test/combat_extended/mech_plates/proc/hit_body(mob/living/exosuit/mech, damage, damage_flags, armor_pen)
	var/before = mech.body.brute_damage
	mech.apply_damage(damage, DAMAGE_BRUTE, BP_CHEST, damage_flags, null, armor_pen)
	return mech.body.brute_damage - before

/// Урон корпусу от настоящего снаряда, прилетевшего с клетки в сторону `side` от меха.
/datum/unit_test/combat_extended/mech_plates/proc/shoot_body(mob/living/exosuit/mech, bullet_type, side, list/failures)
	var/obj/item/projectile/bullet = new bullet_type(get_step(mech, side))
	spawned += bullet
	var/bullet_damage = bullet.damage
	var/before = mech.body.brute_damage
	mech.bullet_act(bullet, BP_CHEST)
	if(bullet.damage != bullet_damage)
		failures += "сторона: `bullet_act()` изменил урон снаряда с [bullet_damage] на [bullet.damage]"
	if(mech.projectile_hit_modifier)
		failures += "сторона: модификатор пережил `bullet_act()`"
	return mech.body.brute_damage - before

/datum/unit_test/combat_extended/mech_plates/start_test()
	var/old_wear = ce_armor_wear_enabled
	var/old_residual = ce_residual_blunt_enabled
	var/old_laser = ce_laser_heat_enabled
	var/list/failures = list()

	// Износ выключен, пока сверяются числа: мехи общие для нескольких проверок.
	ce_armor_wear_enabled = FALSE
	ce_residual_blunt_enabled = TRUE
	var/list/mechs = list(
		"без брони" = make_mech(null),
		"civil" = make_mech(/obj/item/mech_external_armor/civil),
		"buletproof" = make_mech(/obj/item/mech_external_armor/buletproof),
		"admin" = make_mech(/obj/item/mech_external_armor/admin)
	)
	var/list/report = list()
	check_items(failures, report)
	check_premades(failures)
	check_base_armor(failures, report, mechs["без брони"], mechs["buletproof"])
	check_layers(failures, mechs["buletproof"])
	check_tiers(failures, mechs, report)
	check_facing(failures, mechs["без брони"], mechs["buletproof"], mechs["admin"])

	ce_armor_wear_enabled = TRUE
	check_wear(failures, report)
	check_readout(failures)
	ce_laser_heat_enabled = TRUE
	check_lasers(failures, report)

	ce_armor_wear_enabled = old_wear
	ce_residual_blunt_enabled = old_residual
	ce_laser_heat_enabled = old_laser
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Бронеэлементы — жёсткая изнашиваемая броня своей части, держат только пули и лучи, тиры не убывают, сторона попадания считается после брони.\n[jointext(report, "\n")]")
	return 1

/// `report` — рейтинги, HP и теплоёмкость каждого бронеэлемента, для таблицы в README.
/datum/unit_test/combat_extended/mech_plates/proc/check_items(list/failures, list/report)
	for(var/plate_type in subtypesof(/obj/item/mech_external_armor))
		var/datum/extension/armor/armor = armor_of(plate_type)
		if(!armor)
			failures += "вещи: у [plate_type] нет брони"
			continue
		if(armor.type != /datum/extension/armor)
			failures += "вещи: [plate_type] несёт [armor.type], а не обычное расширение брони"
		if(!armor.is_hard_armor() || !armor.ce_can_wear())
			failures += "вещи: [plate_type] жёсткая — [armor.is_hard_armor()], изнашивается — [armor.ce_can_wear()]"
		if(armor.get_armor_sharp_ballistic() <= 0)
			failures += "вещи: у [plate_type] острый рейтинг против пуль [armor.get_armor_sharp_ballistic()]"
		report += "[plate_type]: [armor.get_armor_sharp_ballistic()] мм, тупой [armor.get_armor_blunt()], HP [round(armor.ce_get_health_max(), 0.1)], жара до белого каления [round(armor.ce_get_heat_capacity(), 0.1)], покрытие [round(armor.ce_get_coating_max(), 0.1)]"

/datum/unit_test/combat_extended/mech_plates/proc/check_premades(list/failures)
	var/turf/spawn_turf = get_safe_turf() || locate(/turf/simulated/floor)
	var/mob/living/exosuit/premade/combat/combat = new(spawn_turf)
	spawned += combat
	for(var/obj/item/mech_component/part in parts_of(combat))
		var/obj/item/mech_external_armor/plate = part.installed_armor
		if(!istype(plate, /obj/item/mech_external_armor/buletproof) || plate.owner != part || plate.loc != part)
			failures += "готовые мехи: на [part.name] боевого меха [plate ? plate.type : "нет бронеэлемента"]"

	var/mob/living/exosuit/premade/merc/merc = new(spawn_turf)
	spawned += merc
	for(var/obj/item/mech_component/part in parts_of(merc))
		if(part.installed_armor)
			failures += "готовые мехи: на [part.name] меха наёмников [part.installed_armor.type]"

/// `report` — урон опорных ударов холодным оружием через встроенную броню, для таблицы в README.
/datum/unit_test/combat_extended/mech_plates/proc/check_base_armor(list/failures, list/report, mob/living/exosuit/bare, mob/living/exosuit/bulletproof)
	var/datum/extension/armor/base = get_extension(bare, /datum/extension/armor)
	if(!istype(base, /datum/extension/armor/mech))
		failures += "встроенная броня: мех несёт [base ? base.type : "ничего"]"
		return
	if(!base.is_hard_armor() || base.ce_can_wear())
		failures += "встроенная броня: жёсткая — [base.is_hard_armor()], изнашивается — [base.ce_can_wear()]"
	if(base.get_armor_sharp_ballistic() > 0 || base.get_value("laser") > 0)
		failures += "встроенная броня держит пули ([base.get_armor_sharp_ballistic()] мм) или лучи ([base.get_value("laser")])"

	var/list/armors = bulletproof.get_armors_by_zone(BP_CHEST, DAMAGE_BRUTE, DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP)
	if(length(armors) != 2 || armors[2] != get_extension(bulletproof, /datum/extension/armor))
		failures += "встроенная броня: под бронеэлементом её нет, слоёв [length(armors)]"

	for(var/plating_type in typesof(/obj/item/robot_parts/robot_component/armour/exosuit))
		if(armor_of(plating_type))
			failures += "встроенная броня: внутренняя бронеплита [plating_type] всё ещё несёт броню"
	if(!bare.body.ready_to_install())
		failures += "встроенная броня: корпус без внутренней бронеплиты не готов к установке"

	var/list/line = list()
	for(var/list/attack as anything in melee_anchors())
		var/list/delivered = delivered_damage(bare, BP_CHEST, attack[2], attack[3], attack[4])
		var/total = delivered[1] + delivered[2]
		if(total >= attack[2])
			failures += "встроенная броня: [attack[1]] доставляет [total] из [attack[2]]"
		line += "[attack[1]] [attack[2]] -> [round(total, 0.1)]"
	report += "встроенная броня ([base.get_armor_sharp_melee()] мм против холодного, тупой [base.get_armor_blunt()]): [jointext(line, ", ")]"

/datum/unit_test/combat_extended/mech_plates/proc/check_layers(list/failures, mob/living/exosuit/mech)
	var/list/zones = list(
		BP_HEAD = mech.head, BP_CHEST = mech.body,
		BP_L_ARM = mech.L_arm, BP_R_ARM = mech.R_arm,
		BP_L_LEG = mech.L_leg, BP_R_LEG = mech.R_leg
	)
	for(var/zone in zones)
		var/obj/item/mech_component/part = zones[zone]
		var/plate_armor = get_extension(part.installed_armor, /datum/extension/armor)
		var/list/armors = mech.get_armors_by_zone(zone, DAMAGE_BRUTE, DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP)
		if(!length(armors) || armors[1] != plate_armor)
			failures += "слои: в зоне [zone] первый слой для пули — не бронеэлемент своей части"
		armors = mech.get_armors_by_zone(zone, DAMAGE_BURN, DAMAGE_FLAG_LASER)
		if(!length(armors) || armors[1] != plate_armor)
			failures += "слои: в зоне [zone] первый слой для луча — не бронеэлемент своей части"

	var/body_armor = get_extension(mech.body.installed_armor, /datum/extension/armor)
	var/list/other_attacks = list(
		"удар" = list(DAMAGE_BRUTE, FLAGS_OFF),
		"клинок" = list(DAMAGE_BRUTE, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE),
		"ожог без луча" = list(DAMAGE_BURN, FLAGS_OFF),
		"взрыв" = list(DAMAGE_BRUTE, DAMAGE_FLAG_EXPLODE)
	)
	for(var/attack in other_attacks)
		var/list/kind = other_attacks[attack]
		if(body_armor in mech.get_armors_by_zone(BP_CHEST, kind[1], kind[2]))
			failures += "слои: бронеэлемент держит [attack]"

	var/list/residual_armors = mech.ce_order_armors(mech.get_armors_by_zone(BP_CHEST, DAMAGE_BRUTE, FLAGS_OFF), BP_CHEST, TRUE)
	if(!length(residual_armors) || residual_armors[1] != body_armor)
		failures += "слои: остаточный удар пули идёт мимо бронеэлемента"
	if(body_armor in mech.ce_order_armors(mech.get_armors_by_zone(BP_CHEST, DAMAGE_BRUTE, FLAGS_OFF), BP_CHEST))
		failures += "слои: хук отдаёт бронеэлемент обычному удару"

/// `report` — урон каждой пули через каждый тир, основной и остаточный, для таблицы в README.
/datum/unit_test/combat_extended/mech_plates/proc/check_tiers(list/failures, list/mechs, list/report)
	for(var/list/attack as anything in all_attacks())
		if(!(attack[3] & DAMAGE_FLAG_BULLET))
			continue
		var/previous
		var/list/line = list()
		for(var/tier in mechs)
			var/list/delivered = delivered_damage(mechs[tier], BP_CHEST, attack[2], attack[3], attack[4])
			var/total = delivered[1] + delivered[2]
			line += "[tier] [round(delivered[1], 0.1)]+[round(delivered[2], 0.1)]"
			if(isnull(previous))
				if(abs(total - attack[2]) > 0.01)
					failures += "числа: [attack[1]] по меху без брони доставляет [total] из [attack[2]]"
			else if(total > previous + 0.01)
				failures += "числа: [attack[1]] через [tier] доставляет [total], через тир ниже — [previous]"
			previous = total
		report += "[attack[1]] ([attack[2]], AP [attack[4]]): [jointext(line, ", ")]"

	var/mob/living/exosuit/bulletproof = mechs["buletproof"]
	var/obj/item/projectile/bullet/pistol/pistol = /obj/item/projectile/bullet/pistol
	var/pistol_damage = initial(pistol.damage)
	var/list/pistol_walk = bulletproof.ce_walk_armor_layers(BP_CHEST, pistol_damage, DAMAGE_BRUTE, initial(pistol.damage_flags), initial(pistol.armor_penetration))
	if(ce_is_sharp_attack(pistol_walk[2]) || pistol_walk[1] > pistol_damage * 0.1)
		failures += "числа: пистолет через противопульный бронеэлемент доставляет [pistol_walk[1]] из [pistol_damage]"

	var/obj/item/projectile/bullet/rifle/shell/shell = /obj/item/projectile/bullet/rifle/shell
	var/shell_damage = initial(shell.damage)
	var/list/shell_walk = bulletproof.ce_walk_armor_layers(BP_CHEST, shell_damage, DAMAGE_BRUTE, initial(shell.damage_flags), initial(shell.armor_penetration))
	if(!ce_is_sharp_attack(shell_walk[2]) || shell_walk[1] <= 0 || shell_walk[1] >= shell_damage)
		failures += "числа: противоматериальная пуля через противопульный бронеэлемент доставляет [shell_walk[1]] из [shell_damage]"

/datum/unit_test/combat_extended/mech_plates/proc/check_facing(list/failures, mob/living/exosuit/bare, mob/living/exosuit/bulletproof, mob/living/exosuit/tank)
	var/obj/item/projectile/bullet/rifle/shell/shell = /obj/item/projectile/bullet/rifle/shell
	var/shell_damage = initial(shell.damage)
	var/shell_flags = initial(shell.damage_flags)
	var/shell_pen = initial(shell.armor_penetration)
	var/list/walk = bulletproof.ce_walk_armor_layers(BP_CHEST, shell_damage, DAMAGE_BRUTE, shell_flags, shell_pen)
	var/passed = walk[1]

	// Модификатор умножает и дополняет то, что прошло броню, а не урон до неё. Остаточный удар —
	// вложенное попадание, и модификатора он не получает: разница без него и с ним — только от
	// основного урона.
	var/plain = hit_body(bulletproof, shell_damage, shell_flags, shell_pen)
	bulletproof.projectile_hit_modifier = list(3, 4)
	var/modified = hit_body(bulletproof, shell_damage, shell_flags, shell_pen)
	if(abs((modified - plain) - (passed * 2 + 4)) > 0.01)
		failures += "сторона: с модификатором ×3 +4 корпус получил [modified] вместо [plain] без него, броню прошло [passed]"
	if(bulletproof.projectile_hit_modifier)
		failures += "сторона: модификатор пережил попадание"

	// Остановленное бронёй целиком — ноль с любой стороны.
	var/obj/item/projectile/bullet/pistol/pistol = /obj/item/projectile/bullet/pistol
	var/pistol_damage = initial(pistol.damage)
	var/pistol_flags = initial(pistol.damage_flags)
	var/pistol_pen = initial(pistol.armor_penetration)
	var/list/stopped_walk = tank.ce_walk_armor_layers(BP_CHEST, pistol_damage, DAMAGE_BRUTE, pistol_flags, pistol_pen)
	if(stopped_walk[1] > 0)
		failures += "сторона: пистолет через экспериментальный бронеэлемент доставляет [stopped_walk[1]], проверять нечем"
	else
		tank.projectile_hit_modifier = list(3, 4)
		var/taken = hit_body(tank, pistol_damage, pistol_flags, pistol_pen)
		if(taken)
			failures += "сторона: остановленная бронёй пуля нанесла со спины [taken] урона"
		if(shoot_body(tank, /obj/item/projectile/bullet/pistol, turn(tank.dir, 180), failures))
			failures += "сторона: остановленный бронёй снаряд нанёс урон со спины"

	// Настоящий снаряд по меху без брони: спина против лица.
	var/front = shoot_body(bare, /obj/item/projectile/bullet/pistol, bare.dir, failures)
	var/back = shoot_body(bare, /obj/item/projectile/bullet/pistol, turn(bare.dir, 180), failures)
	var/obj/item/mech_component/body = bare.body
	var/expected = pistol_damage * (body.back_modificator_damage - body.front_modificator_damage) + body.back_additional_damage - body.front_additional_damage
	if(abs((back - front) - expected) > 0.01)
		failures += "сторона: снаряд в спину нанёс [back], в лицо — [front], разница должна быть [expected]"

/// Сколько настоящих попаданий в грудь снимают бронеэлемент с корпуса. `limit` — не сняли.
/datum/unit_test/combat_extended/mech_plates/proc/hits_to_strip(plate_type, bullet_type, limit = 500)
	var/mob/living/exosuit/mech = make_mech(plate_type)
	spawned += mech.body.installed_armor
	var/obj/item/projectile/bullet = bullet_type
	for(var/hits = 1 to limit)
		hit_body(mech, initial(bullet.damage), initial(bullet.damage_flags), initial(bullet.armor_penetration))
		if(!mech.body.installed_armor)
			return hits
	return limit

/// `report` — сколько попаданий снимают бронеэлемент, для таблицы в README.
/datum/unit_test/combat_extended/mech_plates/proc/check_wear(list/failures, list/report)
	for(var/plate_type in list(/obj/item/mech_external_armor/civil, /obj/item/mech_external_armor/buletproof))
		var/list/line = list()
		for(var/bullet_type in list(/obj/item/projectile/bullet/pistol, /obj/item/projectile/bullet/rifle, /obj/item/projectile/bullet/rifle/shell))
			var/hits = hits_to_strip(plate_type, bullet_type)
			if(hits >= 500)
				failures += "износ: [bullet_type] не сняла [plate_type] за [hits] попаданий"
			line += "[bullet_type] — [hits]"
		report += "[plate_type] отваливается: [jointext(line, ", ")]"

	var/mob/living/exosuit/mech = make_mech(/obj/item/mech_external_armor/buletproof)
	var/obj/item/mech_external_armor/plate = mech.body.installed_armor
	spawned += plate
	var/datum/extension/armor/armor = get_extension(plate, /datum/extension/armor)
	var/datum/extension/armor/arm_armor = get_extension(mech.L_arm.installed_armor, /datum/extension/armor)
	var/obj/item/projectile/bullet/rifle/shell/shell = /obj/item/projectile/bullet/rifle/shell
	var/shell_damage = initial(shell.damage)
	var/shell_flags = initial(shell.damage_flags)
	var/shell_pen = initial(shell.armor_penetration)

	hit_body(mech, shell_damage, shell_flags, shell_pen)
	if(isnull(armor.ce_health) || armor.ce_health >= armor.ce_get_health_max())
		failures += "износ: попадание в корпус не износило его бронеэлемент"
	if(!isnull(arm_armor.ce_health))
		failures += "износ: попадание в корпус износило бронеэлемент руки"
	if(mech.body.installed_armor != plate || plate.broken)
		failures += "износ: бронеэлемент отвалился от одного попадания"
		return

	// Попадания до порога: бронеэлемент отваливается посреди прохода по слоям.
	for(var/hits = 1 to 500)
		if(!mech.body.installed_armor)
			break
		hit_body(mech, shell_damage, shell_flags, shell_pen)
	if(mech.body.installed_armor)
		failures += "износ: бронеэлемент остался на корпусе при состоянии [armor.ce_get_condition()]"
		return
	if(armor.ce_get_condition() >= ce_mech_plate_break_condition)
		failures += "износ: бронеэлемент отвалился при состоянии [armor.ce_get_condition()], порог [ce_mech_plate_break_condition]"
	if(!plate.broken || plate.owner || !isturf(plate.loc) || plate.icon_state != plate.broken_icon_state)
		failures += "износ: отвалившийся бронеэлемент разбит — [plate.broken], лежит в [plate.loc], спрайт [plate.icon_state]"
	if(armor in mech.get_armors_by_zone(BP_CHEST, DAMAGE_BRUTE, shell_flags))
		failures += "износ: отвалившийся бронеэлемент остался слоем брони"
	var/list/bare_walk = mech.ce_walk_armor_layers(BP_CHEST, shell_damage, DAMAGE_BRUTE, shell_flags, shell_pen)
	if(abs(bare_walk[1] - shell_damage) > 0.01)
		failures += "износ: без бронеэлемента корпус получает [bare_walk[1]] из [shell_damage]"


/datum/unit_test/combat_extended/mech_plates/proc/check_readout(list/failures)
	// Обратная кривая возвращает вход, на котором прямая даёт тот же выход.
	for(var/output in list(0.1, 0.25, 0.5, 0.75, 1))
		var/input = ce_invert_curve(ce_armor_condition_curve, output)
		if(abs(ce_evaluate_curve(ce_armor_condition_curve, input) - output) > 0.001)
			failures += "приборы: обратная кривая состояния для [output] дала вход [input]"

	var/mob/living/exosuit/mech = make_mech(/obj/item/mech_external_armor/buletproof)
	var/obj/item/mech_component/body = mech.body
	var/obj/item/mech_external_armor/plate = body.installed_armor
	spawned += plate
	var/datum/extension/armor/armor = get_extension(plate, /datum/extension/armor)
	var/health_max = armor.ce_get_health_max()
	var/break_fraction = armor.ce_get_condition_health_fraction(ce_mech_plate_break_condition)

	// Целостность: единица у целого, ноль ровно на пороге отваливания, между ними — по HP.
	// По `list(доля HP, целостность, ступень)`.
	var/list/expectations = list(
		list(1, 1, MECH_EXTERNAL_ARMOUR_INTACT),
		list(break_fraction + (1 - break_fraction) * 0.5, 0.5, MECH_EXTERNAL_ARMOUR_WORN),
		list(break_fraction + (1 - break_fraction) * 0.1, 0.1, MECH_EXTERNAL_ARMOUR_FAILING),
		list(break_fraction, 0, MECH_EXTERNAL_ARMOUR_FAILING)
	)
	for(var/list/expected as anything in expectations)
		armor.ce_set_health(null, health_max * expected[1])
		var/integrity = plate.get_integrity()
		var/condition = body.get_external_armour_condition()
		var/readout = body.get_external_armour_readout()
		if(abs(integrity - expected[2]) > 0.001 || condition != expected[3])
			failures += "приборы: при доле HP [expected[1]] целостность [integrity] и ступень [condition], ожидались [expected[2]] и [expected[3]]"
		if(!findtext(readout, plate.name) || !findtext(readout, ", [round(expected[2] * 100, 1)]%"))
			failures += "приборы: строка при целостности [expected[2]] — «[readout]»"
	if(abs(armor.ce_get_condition() - ce_mech_plate_break_condition) > 0.001)
		failures += "приборы: на нуле целостности множитель рейтинга [armor.ce_get_condition()], порог отваливания [ce_mech_plate_break_condition]"

	// Часть без бронеэлемента.
	qdel(mech.head.remove_external_armour())
	if(mech.head.get_external_armour_readout() != "External armour: none" || mech.head.get_external_armour_condition() != MECH_EXTERNAL_ARMOUR_NONE)
		failures += "приборы: часть без бронеэлемента — «[mech.head.get_external_armour_readout()]», ступень [mech.head.get_external_armour_condition()]"

	// Жар — заметкой в той же строке.
	var/obj/item/mech_external_armor/arm_plate = mech.L_arm.installed_armor
	var/datum/extension/armor/arm_armor = get_extension(arm_plate, /datum/extension/armor)
	if(length(arm_plate.get_status_notes()))
		failures += "приборы: у холодного бронеэлемента есть заметки"
	arm_armor.ce_absorb_laser(100, mech, BP_L_ARM)
	var/list/notes = arm_plate.get_status_notes()
	if(!length(notes) || !findtext(mech.L_arm.get_external_armour_readout(), notes[1]))
		failures += "приборы: жар не попал в строку — «[mech.L_arm.get_external_armour_readout()]»"

	// Диагностика работает с питанием и блоком диагностики.
	mech.power = MECH_POWER_ON
	if(!mech.has_working_diagnostics())
		failures += "приборы: у включённого меха с блоком диагностики она не работает"

	// Настоящие попадания: целостность только убывает, диагностика сообщает о каждой ступени хуже,
	// отвалившийся бронеэлемент показывает ноль.
	armor.ce_set_health(null, health_max)
	var/obj/item/projectile/bullet/rifle/shell/shell = /obj/item/projectile/bullet/rifle/shell
	var/last_integrity = 1
	for(var/hits = 1 to 100)
		hit_body(mech, initial(shell.damage), initial(shell.damage_flags), initial(shell.armor_penetration))
		if(body.installed_armor != plate)
			break
		var/integrity = plate.get_integrity()
		if(integrity > last_integrity + 0.0001)
			failures += "приборы: после [hits] попаданий целостность выросла с [last_integrity] до [integrity]"
			break
		last_integrity = integrity
		if(plate.reported_condition != body.get_external_armour_condition())
			failures += "приборы: диагностика сообщила о ступени [plate.reported_condition], а бронеэлемент на ступени [body.get_external_armour_condition()]"
			break
	if(body.installed_armor == plate)
		failures += "приборы: бронеэлемент не отвалился за 100 попаданий, целостность [last_integrity]"
	else if(plate.get_integrity() != 0 || last_integrity >= 1)
		failures += "приборы: отвалившийся бронеэлемент показывает [plate.get_integrity()], перед этим было [last_integrity]"

	QDEL_NULL(mech.body.diagnostics)
	if(mech.has_working_diagnostics())
		failures += "приборы: диагностика работает без блока диагностики"

/// Урон луча, прошедший броню груди, консультационным проходом.
/datum/unit_test/combat_extended/mech_plates/proc/beam_passed(mob/living/exosuit/mech, beam_type)
	var/obj/item/projectile/beam = beam_type
	var/list/walk = mech.ce_walk_laser_layers(BP_CHEST, initial(beam.damage), DAMAGE_BURN, initial(beam.damage_flags), initial(beam.armor_penetration))
	return walk[1]

/**
 * Непрерывный огонь настоящими лучами в грудь, без остывания: `list(попаданий до отваливания либо
 * null, урон луча через то, что осталось, состояние бронеэлемента)`.
 */
/datum/unit_test/combat_extended/mech_plates/proc/sustain_beam(plate_type, beam_type, limit = 500)
	var/mob/living/exosuit/mech = make_mech(plate_type)
	var/obj/item/mech_external_armor/plate = mech.body.installed_armor
	spawned += plate
	var/datum/extension/armor/armor = get_extension(plate, /datum/extension/armor)
	var/obj/item/projectile/beam = beam_type
	var/stripped
	for(var/hits = 1 to limit)
		mech.apply_damage(initial(beam.damage), DAMAGE_BURN, BP_CHEST, initial(beam.damage_flags), null, initial(beam.armor_penetration))
		if(!mech.body.installed_armor)
			stripped = hits
			break
	return list(stripped, beam_passed(mech, beam_type), armor.ce_get_condition())

/// `report` — урон лучей через каждый бронеэлемент и число лучей до отваливания, для таблиц в README.
/datum/unit_test/combat_extended/mech_plates/proc/check_lasers(list/failures, list/report)
	var/old_wear = ce_armor_wear_enabled
	ce_armor_wear_enabled = FALSE
	// По возрастанию ключа `laser`: 0, 25, 25, 70, 100.
	var/list/mechs = list(
		"без брони" = make_mech(null),
		"civil" = make_mech(/obj/item/mech_external_armor/civil),
		"buletproof" = make_mech(/obj/item/mech_external_armor/buletproof),
		"laserproof" = make_mech(/obj/item/mech_external_armor/laserproof),
		"admin" = make_mech(/obj/item/mech_external_armor/admin)
	)
	for(var/beam_type in typesof(/obj/item/projectile/beam))
		var/obj/item/projectile/beam = beam_type
		var/damage = initial(beam.damage)
		if(damage <= 0 || !ce_is_laser_heat_attack(initial(beam.damage_type), initial(beam.damage_flags)))
			continue
		var/previous
		var/list/line = list()
		for(var/tier in mechs)
			var/passed = beam_passed(mechs[tier], beam_type)
			line += "[tier] [round(passed, 0.1)]"
			if(isnull(previous))
				if(abs(passed - damage) > 0.01)
					failures += "лучи: [beam_type] по меху без брони проходит на [passed] из [damage]"
			else if(passed > previous + 0.01)
				failures += "лучи: [beam_type] через [tier] проходит на [passed], через ключ ниже — на [previous]"
			previous = passed
		report += "[beam_type] ([damage], AP [initial(beam.armor_penetration)]): [jointext(line, ", ")]"

	var/mob/living/exosuit/laserproof = mechs["laserproof"]
	var/obj/item/mech_external_armor/plate = laserproof.body.installed_armor
	var/datum/extension/armor/armor = get_extension(plate, /datum/extension/armor)
	if(!armor.ce_uses_laser_heat(DAMAGE_BURN, DAMAGE_FLAG_LASER))
		failures += "лучи: бронеэлемент не держит луч вычитанием"
	if(armor.ce_get_coating_max() <= 0)
		failures += "лучи: у противолазерного бронеэлемента нет абляционного покрытия"
	if(beam_passed(laserproof, /obj/item/projectile/beam/midlaser) > 0)
		failures += "лучи: карабинный луч проходит противолазерный бронеэлемент"
	if(beam_passed(mechs["civil"], /obj/item/projectile/beam/midlaser) <= 0)
		failures += "лучи: карабинный луч не проходит гражданский бронеэлемент"

	// Настоящий луч по противолазерному бронеэлементу: тип урона луча цел, бронеэлемент греется,
	// корпус цел.
	var/cold_sharp = armor.get_armor_sharp_ballistic()
	var/obj/item/projectile/beam/midlaser/stopped_beam = new(get_step(laserproof, laserproof.dir))
	spawned += stopped_beam
	var/before = laserproof.body.brute_damage + laserproof.body.burn_damage
	laserproof.bullet_act(stopped_beam, BP_CHEST)
	if(stopped_beam.damage_type != DAMAGE_BURN)
		failures += "лучи: `bullet_act()` сменил тип урона луча на [stopped_beam.damage_type]"
	if(laserproof.body.brute_damage + laserproof.body.burn_damage != before)
		failures += "лучи: остановленный луч нанёс корпусу урон"
	if(armor.ce_get_temperature() <= 0)
		failures += "лучи: остановленный луч не нагрел бронеэлемент"

	// Раскалённый бронеэлемент хуже держит пули и остывает.
	for(var/hits = 1 to 30)
		laserproof.apply_damage(initial(stopped_beam.damage), DAMAGE_BURN, BP_CHEST, DAMAGE_FLAG_LASER, null, initial(stopped_beam.armor_penetration))
	var/hot_temperature = armor.ce_get_temperature()
	if(armor.get_armor_sharp_ballistic() >= cold_sharp)
		failures += "лучи: раскалённый до [hot_temperature] бронеэлемент держит пули как холодный"
	armor.ce_process_heat(10)
	if(armor.ce_get_temperature() >= hot_temperature)
		failures += "лучи: бронеэлемент не остывает"

	// Настоящий луч по меху без брони, в лицо и сбоку: корпус получает физический урон, а не ожог.
	var/mob/living/exosuit/bare = mechs["без брони"]
	for(var/side in list(bare.dir, turn(bare.dir, 90)))
		var/obj/item/projectile/beam/midlaser/open_beam = new(get_step(bare, side))
		spawned += open_beam
		var/brute_before = bare.body.brute_damage
		bare.bullet_act(open_beam, BP_CHEST)
		if(bare.body.burn_damage || bare.body.brute_damage <= brute_before)
			failures += "лучи: луч со стороны [side] нанёс корпусу без брони [bare.body.burn_damage] ожога и [bare.body.brute_damage - brute_before] физического урона"

	// Непрерывный огонь: бронеэлемент изнашивает только остановленная часть луча, так что он либо
	// отваливается, либо перестаёт держать этот луч.
	ce_armor_wear_enabled = TRUE
	for(var/plate_type in list(/obj/item/mech_external_armor/civil, /obj/item/mech_external_armor/laserproof))
		for(var/beam_type in list(/obj/item/projectile/beam/midlaser, /obj/item/projectile/beam/heavylaser))
			var/obj/item/projectile/beam = beam_type
			var/list/outcome = sustain_beam(plate_type, beam_type)
			if(outcome[1])
				report += "[plate_type] под [beam_type]: отваливается за [outcome[1]] попаданий"
				continue
			if(outcome[2] < initial(beam.damage) - 0.5)
				failures += "лучи: [plate_type] под [beam_type] не отвалился и всё ещё держит луч: проходит [outcome[2]] из [initial(beam.damage)]"
			report += "[plate_type] под [beam_type]: остаётся с состоянием [round(outcome[3], 0.01)], луч проходит целиком"
	ce_armor_wear_enabled = old_wear


/*
	Попиксельная стрельба, шаг 1 (README, «Попиксельная стрельба и физические промахи»): пиксель
	клика, точка прицела и вектор. Шансы попадания шаг не меняет.

	- Клик: параметры клика списком, как их отдаёт `ClickOn()`, и строкой дают один пиксель; без
	  пикселя в параметрах и с выключенным выключателем его нет.
	- Клетка: без клика — её середина, с кликом — щёлкнутый пиксель, хоть в самом углу.
	- Предмет: сдвиг `pixel_x`/`pixel_y`, поворот и сдвиг `transform`, иконка больше клетки; точка
	  не уходит дальше `ce_aim_tile_reach` от середины клетки; предмет не на карте точки не даёт.
	- Моб: без клика — середина тела; клик в тело — сам пиксель, клик по краю спрайта — не дальше
	  доли радиуса; сдвинутый и лежащий моб несут тело с собой; лежащий шире стоящего, мышь меньше
	  человека, мех занимает клетку.
	- Вектор: шаг по большей оси — клетка, направление — на точку, угол не округлён; вдоль оси и по
	  диагонали шаг точный; отклонение поворачивает вектор; точка в начале вектора его не трогает.
	- Дальность: на 30 клетках вектор в середину клетки входит в неё, а вектор в пиксель не уходит
	  с линии прицела.
	- Снаряд: `setup_trajectory()` нацеливает вектор в пиксель клика и поворачивает за ним эффекты;
	  без клика вектор идёт в середину клетки без округления; клик по мобу целит в тело; повторный
	  `setup_trajectory()` — `redirect()` — идёт как в Бэй; снаряд-трассировщик нацелен как выстрел
	  без клика.
	- Разброс: отклонение не шире дуги, занимает её всю и идёт не целыми градусами; без
	  `dispersion` его нет.
	- След выстрела: `p_x`/`p_y` — щёлкнутый пиксель, без клика — середина клетки, с разбросом —
	  уходит за отклонением.
	- Выключатель возвращает вектор Бэй, отладка вектор не меняет; отладку меха читают его пилоты.
	- Срез угла: стена в клетке, которую линия полёта проходит между двумя точками вектора,
	  останавливает пулю, стена рядом с линией — нет; линия через сам угол проходит, глубже порога —
	  нет; моба в срезанном углу пуля не задевает; стена в нём отбивает пулю рикошетом; трассировщик
	  видит ту же линию; выключатель возвращает прыжок Бэй.
	- Вровень с полом: клик по пятну крови целит в клетку под ним, в щёлкнутый пиксель, и пуля в
	  этой клетке не кончается — и без выключателя тоже; предмет и светильник в полу, который пуля
	  разбивает, клеткой не становятся; правило смотрит на слой, плотность и запас прочности.
	- Мимо предмета: пуля по клику в предмет без запаса прочности летит дальше и `on_hit()` по нему
	  не зовёт — и без выключателя тоже; то, что пуля ломает, предмет со своей реакцией на пулю и
	  неплотная преграда, не пустившая пулю в свою клетку, остаются целью; выстрел себе под ноги
	  кончается сразу.

	Всё, кроме среза угла и клика по лежащему вровень с полом, проверяется без полёта: вектор —
	сразу после `setup_trajectory()` и своими шагами. Остальное — настоящим шагом полёта на
	площадке, через `Move()` и `Bump()`, как рикошеты; рикошеты на это время выключены, кроме
	проверки самого рикошета.
*/
#define CE_AIM_TOLERANCE 0.01
/// Синус наибольшего расхождения направлений, при котором они ещё считаются одним: около 0.01°.
#define CE_AIM_DIRECTION_TOLERANCE 0.0002
/// Сколько раз повторяются проверки со случайным исходом.
#define CE_AIM_TRIALS 40
/// Иконка 64 на 64 пикселя.
#define CE_AIM_BIG_ICON 'icons/obj/structures/fountain.dmi'

/// Человек, который не пускает в свою клетку и неплотный снаряд, как мобы со своими правилами
/// прохода. Воздуху, как любой моб, не мешает.
/mob/living/carbon/human/ce_test_impassable/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	return air_group || !height

/// Предмет со своей реакцией на пулю: считает попадания, и снаряд в нём кончается.
/obj/ce_test_reactive
	name = "test reactive thing"
	var/ce_hits = 0

/obj/ce_test_reactive/bullet_act(obj/item/projectile/P, def_zone)
	ce_hits++

/// Неплотная преграда: снаряд в свою клетку не пускает. Воздуху не мешает.
/obj/ce_test_barrier
	name = "test barrier"
	anchored = TRUE

/obj/ce_test_barrier/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	return air_group || !istype(mover, /obj/item/projectile)

/// Пуля, которая считает свои `on_hit()`.
/obj/item/projectile/bullet/pistol/ce_test_counting
	var/ce_on_hits = 0

/obj/item/projectile/bullet/pistol/ce_test_counting/on_hit(atom/target, blocked = 0, def_zone = null)
	ce_on_hits++
	return ..()

/datum/unit_test/combat_extended/pixel_aim
	name = "CE: Попиксельная стрельба"
	/// Клетка, из которой тест целится.
	var/turf/origin

/datum/unit_test/combat_extended/pixel_aim/start_test()
	origin = get_safe_turf()
	if(!origin || !near(3, 3) || !near(-3, -3))
		fail("Вокруг безопасной клетки нет трёх клеток карты в каждую сторону.")
		return 1
	if(!claim_arena())
		return 1
	var/mob/living/carbon/human/H = make_human()
	var/mob/living/carbon/human/bystander = make_human()
	if(!H || !bystander)
		fail("Не удалось создать людей.")
		return 1

	var/old_enabled = ce_pixel_aim_enabled
	var/old_debug = ce_aim_debug
	var/old_tolerance = ce_corner_cut_tolerance
	var/old_ricochet = ce_ricochet_enabled
	var/old_ricochet_debug = ce_ricochet_debug
	ce_pixel_aim_enabled = TRUE
	ce_aim_debug = FALSE
	ce_corner_cut_tolerance = 4
	ce_ricochet_enabled = FALSE
	ce_ricochet_debug = FALSE
	var/list/failures = list()

	check_click(failures)
	check_turf_point(failures)
	check_object_point(failures)
	check_mob_point(failures, H)
	check_body_sizes(failures, H)
	check_vector(failures)
	check_long_range(failures)
	check_projectile(failures, H)
	check_spread(failures)
	check_clickpoint(failures, H)
	check_switch(failures)
	check_debug(failures, H)

	pave_arena(/turf/simulated/floor/airless)
	check_corner_walls(failures)
	check_corner_tolerance(failures)
	check_corner_mob(failures, H)
	check_corner_ricochet(failures)
	check_corner_trace(failures, H, bystander)
	check_corner_switch(failures)
	check_floor_target(failures)
	check_fly_past(failures)

	ce_pixel_aim_enabled = old_enabled
	ce_aim_debug = old_debug
	ce_corner_cut_tolerance = old_tolerance
	ce_ricochet_enabled = old_ricochet
	ce_ricochet_debug = old_ricochet_debug
	reset_arena()
	cleanup()
	pave_arena(/turf/space)
	var/arena_problem = describe_arena_problem()
	if(arena_problem)
		failures += "площадка после теста: [arena_problem]"
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Пиксель клика доходит до снаряда, точка прицела считается от клетки, предмета и тела моба, вектор идёт в неё без округления угла, разброс — дробными градусами в пределах дуги, сквозь угол стены линия полёта не проходит, клик по пятну крови на полу — клик по полу под ним, а пуля по клику в предмет, которому она ничего не сделает, летит дальше.")
	return 1

/// Клетка со сдвигом от клетки стрелка.
/datum/unit_test/combat_extended/pixel_aim/proc/near(offset_x, offset_y)
	RETURN_TYPE(/turf)
	return locate(origin.x + offset_x, origin.y + offset_y, origin.z)

/// Параметры клика по пикселю `icon_x`, `icon_y` иконки, списком, как их отдаёт `ClickOn()`.
/datum/unit_test/combat_extended/pixel_aim/proc/click_at(icon_x, icon_y)
	RETURN_TYPE(/list)
	return list(MOUSE_1 = "1", MOUSE_ICON_X = "[icon_x]", MOUSE_ICON_Y = "[icon_y]")

/// Новый снаряд в клетке `start`, без неё — в клетке стрелка; ещё без вектора.
/datum/unit_test/combat_extended/pixel_aim/proc/make_projectile(projectile_type = /obj/item/projectile/bullet/pistol, turf/start)
	RETURN_TYPE(/obj/item/projectile)
	var/obj/item/projectile/projectile = new projectile_type(start || origin)
	spawned += projectile
	// Предмет, созданный прямо на клетке, получает случайный сдвиг (`randpixel`), а вектор начинается
	// с него. Снаряд из ствола рождается в гильзе и летит из середины клетки.
	projectile.pixel_x = 0
	projectile.pixel_y = 0
	return projectile

/// Снаряд с вектором на `target`. `click` — пиксель клика по ней, `list(x, y)`, без него клика нет.
/// `start` — клетка выстрела, без неё — клетка стрелка.
/datum/unit_test/combat_extended/pixel_aim/proc/aim(atom/target, list/click, dispersion = 0, turf/start)
	RETURN_TYPE(/obj/item/projectile)
	var/obj/item/projectile/projectile = make_projectile(/obj/item/projectile/bullet/pistol, start)
	projectile.dispersion = dispersion
	if(click)
		projectile.set_clickpoint(click_at(click[1], click[2]))
	projectile.original = target
	projectile.setup_trajectory(start || origin, get_turf(target))
	return projectile

/// Сверяет точку `point` с ожидаемой, расхождение дописывает в `failures`.
/datum/unit_test/combat_extended/pixel_aim/proc/expect_point(list/failures, label, list/point, expected_x, expected_y)
	if(!point)
		failures += "[label]: точки нет, ожидалась [expected_x],[expected_y]"
		return
	if(abs(point[1] - expected_x) > CE_AIM_TOLERANCE || abs(point[2] - expected_y) > CE_AIM_TOLERANCE)
		failures += "[label]: точка [point[1]],[point[2]], ожидалась [expected_x],[expected_y]"

/// Смотрит ли шаг вектора в сторону `delta_x`, `delta_y`.
/datum/unit_test/combat_extended/pixel_aim/proc/points_along(datum/plot_vector/vector, delta_x, delta_y)
	var/cross = vector.offset_x * delta_y - vector.offset_y * delta_x
	var/dot = vector.offset_x * delta_x + vector.offset_y * delta_y
	var/lengths = sqrt(vector.offset_x ** 2 + vector.offset_y ** 2) * sqrt(delta_x ** 2 + delta_y ** 2)
	return dot > 0 && abs(cross) <= CE_AIM_DIRECTION_TOLERANCE * lengths

/// Шаг вектора по большей оси — ровно клетка.
/datum/unit_test/combat_extended/pixel_aim/proc/steps_by_tile(datum/plot_vector/vector)
	return abs(max(abs(vector.offset_x), abs(vector.offset_y)) - world.icon_size) <= CE_AIM_TOLERANCE

/// Повёрнуты ли эффекты снаряда по его вектору, как это делает `setup_trajectory()`.
/datum/unit_test/combat_extended/pixel_aim/proc/effects_follow(obj/item/projectile/projectile)
	var/datum/plot_vector/vector = projectile.trajectory
	var/matrix/expected = matrix().Update(
		scale_x = round(vector.return_hypotenuse() + 0.005, 0.001),
		rotation = round(-vector.angle, 0.1)
	)
	var/matrix/actual = projectile.effect_transform
	if(!actual)
		return FALSE
	return abs(actual.a - expected.a) + abs(actual.b - expected.b) + abs(actual.d - expected.d) + abs(actual.e - expected.e) <= CE_AIM_TOLERANCE

/**
 * Шаг полёта, после которого пуля стоит в клетке точки своего вектора. Кор `Process()` на исход
 * `Move()` не смотрит: пуля, которую шаг не пустил, отстаёт от вектора и следующим шагом
 * перепрыгивает клетку. До цели она при этом доходит, поэтому проверяется каждый шаг.
 */
/datum/unit_test/combat_extended/pixel_aim/proc/fly_along(obj/item/projectile/projectile)
	return fly_step(projectile) && projectile.loc == projectile.location.return_turf()

/// Шаг полёта с проверкой цели, как в кор `Process()`: снаряд, вошедший в клетку того, в кого
/// целились, встречает его, даже неплотного. FALSE — снаряд на этом шаге кончился.
/datum/unit_test/combat_extended/pixel_aim/proc/fly_at_target(obj/item/projectile/projectile)
	if(!fly_step(projectile))
		return FALSE
	var/atom/target = projectile.original
	if(!projectile.bumped && !isturf(target) && projectile.loc == get_turf(target) && !(target in projectile.permutated))
		projectile.Bump(target, TRUE)
	return !QDELETED(projectile)

/// Параметры клика списком и строкой дают один пиксель; без пикселя и без выключателя его нет.
/datum/unit_test/combat_extended/pixel_aim/proc/check_click(list/failures)
	var/obj/item/projectile/from_list = make_projectile()
	from_list.set_clickpoint(click_at(5, 27))
	if(from_list.p_x != 5 || from_list.p_y != 27 || from_list.ce_click_icon_x != 5 || from_list.ce_click_icon_y != 27)
		failures += "клик списком: `p_x`/`p_y` [from_list.p_x],[from_list.p_y], пиксель клика [from_list.ce_click_icon_x],[from_list.ce_click_icon_y]; ожидалось 5,27"

	var/obj/item/projectile/from_text = make_projectile()
	from_text.set_clickpoint("[MOUSE_1]=1;[MOUSE_ICON_X]=5;[MOUSE_ICON_Y]=27")
	if(from_text.p_x != 5 || from_text.p_y != 27 || from_text.ce_click_icon_x != 5 || from_text.ce_click_icon_y != 27)
		failures += "клик строкой: `p_x`/`p_y` [from_text.p_x],[from_text.p_y], пиксель клика [from_text.ce_click_icon_x],[from_text.ce_click_icon_y]; ожидалось 5,27"

	var/obj/item/projectile/pixelless = make_projectile()
	pixelless.set_clickpoint(list(MOUSE_1 = "1"))
	if(!isnull(pixelless.ce_click_icon_x) || !isnull(pixelless.ce_click_icon_y) || pixelless.p_x != initial(pixelless.p_x))
		failures += "клик без пикселя: пиксель клика [pixelless.ce_click_icon_x],[pixelless.ce_click_icon_y], `p_x` [pixelless.p_x]"

	ce_pixel_aim_enabled = FALSE
	var/obj/item/projectile/switched_off = make_projectile()
	switched_off.set_clickpoint(click_at(5, 27))
	ce_pixel_aim_enabled = TRUE
	// Кор версия список не разбирает: с выключенным выключателем пиксель теряется, как в Бэй.
	if(!isnull(switched_off.ce_click_icon_x) || switched_off.p_x != initial(switched_off.p_x) || switched_off.p_y != initial(switched_off.p_y))
		failures += "клик с выключенным выключателем: пиксель клика [switched_off.ce_click_icon_x], `p_x`/`p_y` [switched_off.p_x],[switched_off.p_y]"

/// Клетка: без клика — её середина, с кликом — щёлкнутый пиксель, и в угол он не подтягивается.
/datum/unit_test/combat_extended/pixel_aim/proc/check_turf_point(list/failures)
	var/turf/target = near(2, 1)
	var/center_x = target.x * world.icon_size
	var/center_y = target.y * world.icon_size
	expect_point(failures, "клетка без клика", target.ce_get_aim_point(), center_x, center_y)
	expect_point(failures, "клетка, пиксель 20,9", target.ce_get_aim_point(20, 9), center_x + 3.5, center_y - 7.5)
	expect_point(failures, "клетка, левый нижний пиксель", target.ce_get_aim_point(1, 1), center_x - 15.5, center_y - 15.5)
	expect_point(failures, "клетка, правый верхний пиксель", target.ce_get_aim_point(world.icon_size, world.icon_size), center_x + 15.5, center_y + 15.5)

/// Предмет: сдвиг, поворот и сдвиг `transform`, большая иконка, предел от середины клетки.
/datum/unit_test/combat_extended/pixel_aim/proc/check_object_point(list/failures)
	var/turf/place = near(2, 1)
	var/center_x = place.x * world.icon_size
	var/center_y = place.y * world.icon_size
	var/obj/item/device/flashlight/thing = new(place)
	spawned += thing

	thing.pixel_x = 4
	thing.pixel_y = -3
	expect_point(failures, "предмет со сдвигом без клика", thing.ce_get_aim_point(), center_x, center_y)
	// Пиксель 16,16 — на полпикселя левее и ниже середины иконки.
	expect_point(failures, "предмет со сдвигом", thing.ce_get_aim_point(16, 16), center_x + 3.5, center_y - 3.5)

	thing.pixel_x = 0
	thing.pixel_y = 0
	// Иконка повёрнута на 90° по часовой стрелке: её правая сторона смотрит вниз.
	thing.transform = matrix().Turn(90)
	expect_point(failures, "повёрнутый предмет", thing.ce_get_aim_point(24, 16), center_x - 0.5, center_y - 7.5)

	var/matrix/shifted = matrix()
	shifted.Translate(3, -6)
	thing.transform = shifted
	expect_point(failures, "предмет со сдвигом `transform`", thing.ce_get_aim_point(16, 16), center_x + 2.5, center_y - 6.5)

	// Иконка 64 на 64 стоит левым нижним углом в углу клетки и повёрнута вокруг своей середины —
	// точки на 16 пикселей правее и выше середины клетки.
	thing.icon = CE_AIM_BIG_ICON
	thing.transform = matrix().Turn(180)
	expect_point(failures, "большая повёрнутая иконка", thing.ce_get_aim_point(40, 44), center_x + 8.5, center_y + 4.5)
	thing.icon = initial(thing.icon)
	thing.transform = matrix()

	// Сдвинутый предмет со спрайтом за краем клетки: точка подтянута к её середине вдоль клика.
	thing.pixel_x = 14
	var/list/pulled = thing.ce_get_aim_point(world.icon_size, world.icon_size)
	var/pulled_x = pulled[1] - center_x
	var/pulled_y = pulled[2] - center_y
	if(abs(sqrt(pulled_x ** 2 + pulled_y ** 2) - ce_aim_tile_reach) > CE_AIM_TOLERANCE || pulled_x <= 0 || abs(pulled_x * 15.5 - pulled_y * 29.5) > CE_AIM_TOLERANCE * world.icon_size)
		failures += "предмет за краем клетки: точка [pulled_x],[pulled_y] от середины клетки, ожидалась на [ce_aim_tile_reach] в сторону 29.5,15.5"

	var/obj/item/device/flashlight/nowhere = new
	spawned += nowhere
	if(nowhere.ce_get_aim_point() || nowhere.ce_get_aim_point(16, 16))
		failures += "предмет не на карте дал точку прицела"

/// Моб: середина тела, клик в тело и по краю спрайта, сдвинутый и лежащий моб.
/datum/unit_test/combat_extended/pixel_aim/proc/check_mob_point(list/failures, mob/living/carbon/human/H)
	H.forceMove(near(-2, 1))
	H.pixel_x = H.default_pixel_x
	H.pixel_y = H.default_pixel_y
	H.transform = matrix()
	var/list/tile = H.ce_get_tile_center()
	var/reach = H.ce_get_hit_radius() * ce_aim_clamp_share
	expect_point(failures, "моб без клика", H.ce_get_aim_point(), tile[1], tile[2])
	expect_point(failures, "клик в тело", H.ce_get_aim_point(19, 14), tile[1] + 2.5, tile[2] - 2.5)

	// Левый край спрайта — на 15.5 пикселя левее середины тела: дальше доли радиуса.
	var/list/edge = H.ce_get_aim_point(1, 16)
	var/edge_x = edge[1] - tile[1]
	var/edge_y = edge[2] - tile[2]
	if(abs(sqrt(edge_x ** 2 + edge_y ** 2) - reach) > CE_AIM_TOLERANCE || edge_x >= 0 || abs(edge_x * 0.5 - edge_y * 15.5) > CE_AIM_TOLERANCE * world.icon_size)
		failures += "клик по краю спрайта: точка [edge_x],[edge_y] от середины тела, ожидалась на [reach] в сторону -15.5,-0.5"

	// Моб, сдвинутый со своего места, — на кровати — несёт тело с собой.
	H.pixel_y = H.default_pixel_y + 8
	expect_point(failures, "сдвинутый моб без клика", H.ce_get_aim_point(), tile[1], tile[2] + 8)
	expect_point(failures, "сдвинутый моб, клик в тело", H.ce_get_aim_point(19, 14), tile[1] + 2.5, tile[2] + 5.5)
	// Тело за краем клетки: точка не дальше предела от её середины.
	H.pixel_y = H.default_pixel_y + 14
	expect_point(failures, "моб за краем клетки", H.ce_get_aim_point(), tile[1], tile[2] + ce_aim_tile_reach)
	H.pixel_y = H.default_pixel_y

	// Лежащий повёрнут на 90° по часовой стрелке и сдвинут вниз, как в `update_icons()`.
	var/standing_radius = H.ce_get_hit_radius()
	H.lying = TRUE
	H.transform = matrix().Update(rotation = 90, offset_y = -6)
	var/lying_reach = H.ce_get_hit_radius() * ce_aim_clamp_share
	if(H.ce_get_hit_radius() <= standing_radius)
		failures += "лежащий: радиус тела [H.ce_get_hit_radius()], у стоящего [standing_radius]"
	expect_point(failures, "лежащий без клика", H.ce_get_aim_point(), tile[1], tile[2] - 6)
	expect_point(failures, "лежащий, клик в тело", H.ce_get_aim_point(16, 16), tile[1] - 0.5, tile[2] - 5.5)
	// Голова — верх иконки — у лежащего смотрит на восток, на 13.5 пикселя от середины тела.
	var/list/head = H.ce_get_aim_point(16, 30)
	var/head_x = head[1] - tile[1]
	var/head_y = head[2] - (tile[2] - 6)
	if(abs(sqrt(head_x ** 2 + head_y ** 2) - lying_reach) > CE_AIM_TOLERANCE || head_x <= 0 || abs(head_x * 0.5 - head_y * 13.5) > CE_AIM_TOLERANCE * world.icon_size)
		failures += "лежащий, клик по голове: точка [head_x],[head_y] от середины тела, ожидалась на [lying_reach] в сторону 13.5,0.5"
	H.lying = FALSE
	H.transform = matrix()

/// Радиус тела: человек — в пределах полуклетки, мышь меньше, мех занимает клетку целиком.
/datum/unit_test/combat_extended/pixel_aim/proc/check_body_sizes(list/failures, mob/living/carbon/human/H)
	var/human_radius = H.ce_get_hit_radius()
	if(human_radius <= 0 || human_radius > world.icon_size / 2)
		failures += "размеры: радиус тела человека [human_radius], ожидался в пределах полуклетки"

	var/mob/living/simple_animal/passive/mouse/mouse = new(near(-2, 2))
	spawned += mouse
	if(mouse.ce_get_hit_radius() <= 0 || mouse.ce_get_hit_radius() >= human_radius)
		failures += "размеры: радиус тела мыши [mouse.ce_get_hit_radius()], человека [human_radius]"

	var/mob/living/exosuit/premade/combat/mech = new(near(-2, 3))
	spawned += mech
	// Дальний угол клетки — в 22.6 пикселя от её середины.
	if(mech.ce_get_hit_radius() < world.icon_size * 0.71)
		failures += "размеры: радиус меха [mech.ce_get_hit_radius()] не закрывает клетку"
	// Иконка меха шире клетки и стоит со сдвигом: его обычное место — не сдвиг тела.
	var/list/mech_tile = mech.ce_get_tile_center()
	expect_point(failures, "мех без клика", mech.ce_get_aim_point(), mech_tile[1], mech_tile[2])
	// Из меха стреляют его пилоты: отладку прицела читают они.
	var/list/unmanned = mech.ce_get_gunners()
	LAZYADD(mech.pilots, H)
	var/list/manned = mech.ce_get_gunners()
	LAZYREMOVE(mech.pilots, H)
	var/list/own = H.ce_get_gunners()
	if(length(unmanned) != 1 || unmanned[1] != mech || length(manned) != 1 || manned[1] != H || length(own) != 1 || own[1] != H)
		failures += "стрелки: у меха без пилота — [length(unmanned)], с пилотом — [length(manned)] и пилот среди них — [H in manned], у человека — [length(own)]"

/// Вектор: шаг по большей оси — клетка, направление — на точку, угол не округлён.
/datum/unit_test/combat_extended/pixel_aim/proc/check_vector(list/failures)
	var/start_x = 100 * world.icon_size
	var/start_y = 100 * world.icon_size
	// list(сдвиг точки x, сдвиг точки y)
	var/list/shifts = list(list(100, 37), list(-64, 200), list(5, -300), list(-77, -78), list(13, 1))
	for(var/list/shift in shifts)
		var/label = "вектор на [shift[1]],[shift[2]]"
		var/datum/plot_vector/vector = new
		vector.loc_x = start_x
		vector.loc_y = start_y
		if(!vector.ce_aim_at(start_x + shift[1], start_y + shift[2]))
			failures += "[label]: вектор не нацелен"
			continue
		if(!steps_by_tile(vector))
			failures += "[label]: шаг [vector.offset_x],[vector.offset_y], по большей оси ожидалась клетка"
		if(!points_along(vector, shift[1], shift[2]))
			failures += "[label]: шаг [vector.offset_x],[vector.offset_y] смотрит не на точку"
		if(abs(vector.angle - Atan2(shift[1], shift[2])) > CE_AIM_TOLERANCE)
			failures += "[label]: угол [vector.angle], ожидался [Atan2(shift[1], shift[2])]"
		if(vector.loc_x != start_x || vector.loc_y != start_y)
			failures += "[label]: начало вектора сдвинулось в [vector.loc_x],[vector.loc_y]"

	// Угол на точку 100,37 — 20.3°: до градуса он не округляется.
	var/datum/plot_vector/fine = new
	fine.loc_x = start_x
	fine.loc_y = start_y
	fine.ce_aim_at(start_x + 100, start_y + 37)
	if(abs(fine.angle - round(fine.angle, 1)) < 0.1)
		failures += "вектор: угол [fine.angle] округлён до градуса"

	// Вдоль оси и по диагонали шаг точный, как у `setup()`. list(сдвиг x, сдвиг y, шаг x, шаг y в клетках)
	var/list/exact_shifts = list(list(64, 0, 1, 0), list(0, -96, 0, -1), list(-3, 0, -1, 0), list(-50, 50, -1, 1), list(7, 7, 1, 1))
	for(var/list/shift in exact_shifts)
		var/datum/plot_vector/vector = new
		vector.loc_x = start_x
		vector.loc_y = start_y
		vector.ce_aim_at(start_x + shift[1], start_y + shift[2])
		if(vector.offset_x != shift[3] * world.icon_size || vector.offset_y != shift[4] * world.icon_size)
			failures += "вектор на [shift[1]],[shift[2]]: шаг [vector.offset_x],[vector.offset_y], ожидался ровно [shift[3] * world.icon_size],[shift[4] * world.icon_size]"

	// Отклонение поворачивает вектор против часовой стрелки.
	var/datum/plot_vector/turned = new
	turned.loc_x = start_x
	turned.loc_y = start_y
	turned.ce_aim_at(start_x + 100, start_y, 90)
	if(abs(turned.offset_x) > CE_AIM_TOLERANCE || abs(turned.offset_y - world.icon_size) > CE_AIM_TOLERANCE)
		failures += "вектор: поворот на 90° от востока дал шаг [turned.offset_x],[turned.offset_y], ожидался шаг на север"
	turned.ce_aim_at(start_x + 100, start_y, -45)
	if(abs(turned.offset_x - world.icon_size) > CE_AIM_TOLERANCE || abs(turned.offset_y + world.icon_size) > CE_AIM_TOLERANCE || abs(turned.angle + 45) > CE_AIM_TOLERANCE)
		failures += "вектор: поворот на -45° от востока дал шаг [turned.offset_x],[turned.offset_y] и угол [turned.angle]"

	var/datum/plot_vector/still = new
	still.loc_x = start_x
	still.loc_y = start_y
	still.offset_x = 5
	still.offset_y = -7
	if(still.ce_aim_at(start_x, start_y) || still.offset_x != 5 || still.offset_y != -7)
		failures += "вектор: точка в начале вектора его тронула, шаг [still.offset_x],[still.offset_y]"

/**
 * На 30 клетках вектор в середину клетки входит в неё. Клетки подобраны так, что с углом,
 * округлённым до градуса, — 28.07° стали бы 29° — вектор вошёл бы в соседнюю. Вектор в пиксель
 * клетки с линии прицела не уходит.
 */
/datum/unit_test/combat_extended/pixel_aim/proc/check_long_range(list/failures)
	var/turf/far_start = locate(5, 8, origin.z)
	var/turf/far_target = locate(35, 24, origin.z)
	if(!far_start || !far_target)
		failures += "дальность: на карте нет клеток 5,8 и 35,24"
		return
	var/steps = far_target.x - far_start.x
	var/datum/plot_vector/vector = new
	vector.setup(far_start, far_target)
	vector.ce_aim_at(far_target.x * world.icon_size, far_target.y * world.icon_size)
	for(var/step in 1 to steps)
		vector.increment()
	var/datum/vector_loc/reached = vector.return_location()
	var/turf/reached_turf = reached?.return_turf()
	if(reached_turf != far_target)
		failures += "дальность: через [steps] шагов вектор в клетке [reached_turf?.x],[reached_turf?.y], ожидалась [far_target.x],[far_target.y]"

	var/datum/plot_vector/pixel = new
	pixel.setup(far_start, far_target)
	var/start_x = pixel.loc_x
	var/start_y = pixel.loc_y
	var/aim_x = far_target.x * world.icon_size + 12
	var/aim_y = far_target.y * world.icon_size - 14
	pixel.ce_aim_at(aim_x, aim_y)
	for(var/step in 1 to steps)
		pixel.increment()
	var/off_line = abs((aim_x - start_x) * (pixel.loc_y - start_y) - (aim_y - start_y) * (pixel.loc_x - start_x)) / sqrt((aim_x - start_x) ** 2 + (aim_y - start_y) ** 2)
	if(off_line > 0.5)
		failures += "дальность: через [steps] шагов вектор в пиксель ушёл с линии прицела на [off_line] пикселя"

/// Снаряд: `setup_trajectory()` нацеливает вектор, повторный вызов идёт как в Бэй, трассировщик —
/// как выстрел без клика.
/datum/unit_test/combat_extended/pixel_aim/proc/check_projectile(list/failures, mob/living/carbon/human/H)
	var/turf/target = near(2, 1)
	// Пиксель 30,3 — на 13.5 правее и на 13.5 ниже середины клетки.
	var/obj/item/projectile/clicked = aim(target, list(30, 3))
	var/datum/plot_vector/vector = clicked.trajectory
	if(!points_along(vector, 2 * world.icon_size + 13.5, world.icon_size - 13.5) || !steps_by_tile(vector))
		failures += "снаряд: шаг вектора [vector.offset_x],[vector.offset_y] смотрит не в пиксель клика"
	if(!effects_follow(clicked))
		failures += "снаряд: эффекты не повёрнуты за вектором"

	// Без клика — в середину клетки, и без округления угла: 26.57°, а не 27°.
	var/obj/item/projectile/centered = aim(target)
	if(centered.trajectory.offset_x != world.icon_size || centered.trajectory.offset_y != world.icon_size / 2)
		failures += "снаряд без клика: шаг вектора [centered.trajectory.offset_x],[centered.trajectory.offset_y], ожидался [world.icon_size],[world.icon_size / 2]"

	// Клик по краю спрайта моба целит в его тело.
	H.forceMove(near(-2, 1))
	var/list/body_point = H.ce_get_aim_point(1, 16)
	var/obj/item/projectile/at_mob = aim(H, list(1, 16))
	if(!points_along(at_mob.trajectory, body_point[1] - origin.x * world.icon_size, body_point[2] - origin.y * world.icon_size))
		failures += "снаряд по мобу: шаг вектора [at_mob.trajectory.offset_x],[at_mob.trajectory.offset_y] смотрит не в точку прицела по телу"
	if(points_along(at_mob.trajectory, -2 * world.icon_size - 15.5, world.icon_size - 0.5))
		failures += "снаряд по мобу: вектор смотрит в край спрайта"

	// `redirect()` перенацеливает летящий снаряд в клетку: вектор Бэй, 108.43° становятся 108°.
	clicked.redirect(origin.x - 1, origin.y + 3, origin)
	var/redirected_angle = clicked.trajectory.angle
	if(abs(redirected_angle - 108) > CE_AIM_TOLERANCE)
		failures += "снаряд после `redirect()`: угол вектора [redirected_angle], ожидались 108° Бэй"

	// Трассировщик проверяет ту же линию, что летит выстрел без клика.
	var/obj/item/projectile/trace = make_projectile(/obj/item/projectile/test)
	trace.original = target
	trace.setup_trajectory(origin, target)
	if(trace.trajectory.offset_x != world.icon_size || trace.trajectory.offset_y != world.icon_size / 2)
		failures += "трассировщик: шаг вектора [trace.trajectory.offset_x],[trace.trajectory.offset_y], ожидался [world.icon_size],[world.icon_size / 2], как у выстрела без клика"

/// Разброс: отклонение не шире дуги, занимает её всю, идёт не целыми градусами.
/datum/unit_test/combat_extended/pixel_aim/proc/check_spread(list/failures)
	var/turf/target = near(3, 0)
	var/half_arc = ce_dispersion_arc_degrees / 2
	var/widest = 0
	var/fractional = FALSE
	for(var/trial in 1 to CE_AIM_TRIALS)
		// Цель строго на востоке: угол вектора — само отклонение.
		var/obj/item/projectile/projectile = aim(target, null, 1)
		var/deviation = projectile.trajectory.angle
		widest = max(widest, abs(deviation))
		if(abs(deviation - round(deviation, 1)) > CE_AIM_TOLERANCE)
			fractional = TRUE
		if(!steps_by_tile(projectile.trajectory) || !effects_follow(projectile))
			failures += "разброс: шаг [projectile.trajectory.offset_x],[projectile.trajectory.offset_y] не в клетку или эффекты не повёрнуты"
			break
	if(widest > half_arc + CE_AIM_TOLERANCE)
		failures += "разброс: отклонение [widest]° шире половины дуги [half_arc]°"
	// Сорок бросков, уместившихся в половину своей половины дуги, — шанс 2 в минус сороковой.
	if(widest < half_arc / 2)
		failures += "разброс: наибольшее из [CE_AIM_TRIALS] отклонений — [widest]°, дуга [half_arc * 2]° не занята"
	if(!fractional)
		failures += "разброс: все [CE_AIM_TRIALS] отклонений — целые градусы"

	widest = 0
	for(var/trial in 1 to CE_AIM_TRIALS)
		var/obj/item/projectile/projectile = aim(target, null, 0.5)
		widest = max(widest, abs(projectile.trajectory.angle))
	if(widest > half_arc / 2 + CE_AIM_TOLERANCE)
		failures += "разброс: с половиной `dispersion` отклонение [widest]° шире четверти дуги [half_arc / 2]°"

	var/obj/item/projectile/steady = aim(target)
	if(steady.trajectory.offset_x != world.icon_size || steady.trajectory.offset_y != 0)
		failures += "разброс: без `dispersion` шаг вектора [steady.trajectory.offset_x],[steady.trajectory.offset_y]"

/// След выстрела: `p_x`/`p_y` — пиксель точки прицела, без клика — середина, с разбросом — по линии.
/datum/unit_test/combat_extended/pixel_aim/proc/check_clickpoint(list/failures, mob/living/carbon/human/H)
	var/turf/target = near(2, 1)
	var/obj/item/projectile/clicked = aim(target, list(30, 3))
	if(clicked.p_x != 30 || clicked.p_y != 3)
		failures += "след: `p_x`/`p_y` [clicked.p_x],[clicked.p_y], ожидался пиксель клика 30,3"
	var/obj/item/projectile/centered = aim(target)
	if(centered.p_x != initial(centered.p_x) || centered.p_y != initial(centered.p_y))
		failures += "след без клика: `p_x`/`p_y` [centered.p_x],[centered.p_y], ожидалась середина клетки"

	// Клик по краю спрайта моба: след — там, куда выстрел нацелен, а не где щёлкнули.
	H.forceMove(near(-2, 1))
	var/list/tile = H.ce_get_tile_center()
	var/list/body_point = H.ce_get_aim_point(1, 16)
	var/body_pixel_x = ceil(body_point[1] - tile[1] + world.icon_size / 2 - CE_AIM_TOLERANCE)
	var/body_pixel_y = ceil(body_point[2] - tile[2] + world.icon_size / 2 - CE_AIM_TOLERANCE)
	var/obj/item/projectile/at_mob = aim(H, list(1, 16))
	if(at_mob.p_x != body_pixel_x || at_mob.p_y != body_pixel_y || at_mob.p_x == 1)
		failures += "след по мобу: `p_x`/`p_y` [at_mob.p_x],[at_mob.p_y], ожидался пиксель точки прицела [body_pixel_x],[body_pixel_y]"

	// С разбросом след лежит на линии выстрела, на расстоянии точки прицела: она на полпикселя левее
	// и ниже середины клетки 2,1.
	var/aim_distance = sqrt((2 * world.icon_size - 0.5) ** 2 + (world.icon_size - 0.5) ** 2)
	var/moved = FALSE
	for(var/trial in 1 to CE_AIM_TRIALS)
		var/obj/item/projectile/spread = aim(target, list(16, 16), 1)
		var/datum/plot_vector/vector = spread.trajectory
		var/steps = aim_distance / sqrt(vector.offset_x ** 2 + vector.offset_y ** 2)
		// Пиксель `k` клетки лежит на полпикселя левее отметки `k` от её левого края.
		var/line_x = vector.offset_x * steps - 2 * world.icon_size + world.icon_size / 2 + 0.5
		var/line_y = vector.offset_y * steps - world.icon_size + world.icon_size / 2 + 0.5
		if(abs(spread.p_x - line_x) > 1 || abs(spread.p_y - line_y) > 1)
			failures += "след с разбросом: `p_x`/`p_y` [spread.p_x],[spread.p_y], линия выстрела проходит клетку в [line_x],[line_y]"
			break
		if(spread.p_x != 16 || spread.p_y != 16)
			moved = TRUE
	if(!moved)
		failures += "след с разбросом: все [CE_AIM_TRIALS] выстрелов легли в пиксель клика"

/// Выключатель возвращает вектор Бэй: пиксель клика теряется, угол — целый градус.
/datum/unit_test/combat_extended/pixel_aim/proc/check_switch(list/failures)
	ce_pixel_aim_enabled = FALSE
	var/obj/item/projectile/bay = aim(near(2, 1), list(30, 3))
	ce_pixel_aim_enabled = TRUE
	// 26.57° Бэй округляет до 27°.
	if(abs(bay.trajectory.angle - 27) > CE_AIM_TOLERANCE || abs(bay.trajectory.offset_y - tan(27) * world.icon_size) > CE_AIM_TOLERANCE)
		failures += "выключатель: угол вектора [bay.trajectory.angle], шаг [bay.trajectory.offset_x],[bay.trajectory.offset_y]; ожидались 27° Бэй"
	if(bay.p_x != initial(bay.p_x) || bay.p_y != initial(bay.p_y))
		failures += "выключатель: `p_x`/`p_y` [bay.p_x],[bay.p_y], ожидалась середина клетки"

/// Отладка пишет стрелку и вектор не меняет.
/datum/unit_test/combat_extended/pixel_aim/proc/check_debug(list/failures, mob/living/carbon/human/H)
	ce_aim_debug = TRUE
	var/obj/item/projectile/projectile = make_projectile()
	projectile.firer = H
	projectile.set_clickpoint(click_at(30, 3))
	projectile.original = near(2, 1)
	projectile.setup_trajectory(origin, projectile.original)
	ce_aim_debug = FALSE
	if(!points_along(projectile.trajectory, 2 * world.icon_size + 13.5, world.icon_size - 13.5) || projectile.p_x != 30 || projectile.p_y != 3)
		failures += "отладка: шаг вектора [projectile.trajectory.offset_x],[projectile.trajectory.offset_y], `p_x`/`p_y` [projectile.p_x],[projectile.p_y]"

/**
 * Стена в клетке, которую линия полёта проходит, останавливает пулю, и попадание приходится в неё;
 * стена в соседней клетке, которую линия не задевает, — нет. Линия в цель 2,1 идёт через 1,0 и 1,1:
 * в один из них вектор входит своей точкой, угол другого срезает на диагональном шаге.
 */
/datum/unit_test/combat_extended/pixel_aim/proc/check_corner_walls(list/failures)
	// list(цель x, цель y, клетки на линии, клетки рядом с линией)
	var/list/shots = list(
		list(2, 1, list(list(1, 0), list(1, 1)), list(list(0, 1), list(2, 0))),
		list(1, 2, list(list(0, 1), list(1, 1)), list(list(1, 0), list(0, 2))),
		list(-2, -1, list(list(-1, 0), list(-1, -1)), list(list(0, -1), list(-2, 0))),
		list(2, -1, list(list(1, 0), list(1, -1)), list(list(0, -1), list(2, 0))),
		list(-1, 2, list(list(0, 1), list(-1, 1)), list(list(-1, 0), list(0, 2)))
	)
	for(var/list/shot in shots)
		var/turf/target = spot(shot[1], shot[2])
		for(var/list/crossed in shot[3])
			var/label = "срез угла, выстрел в [shot[1]],[shot[2]], стена на линии в [crossed[1]],[crossed[2]]"
			var/turf/wall = build_wall(crossed[1], crossed[2])
			var/obj/item/projectile/projectile = aim(target, null, 0, center)
			if(fly_step(projectile) && fly_step(projectile))
				failures += "[label]: пуля прошла стену и стоит в [projectile.x - center.x],[projectile.y - center.y]"
			else if(!has_bullet_hole(wall) || projectile.location?.return_turf() != wall)
				failures += "[label]: пуля кончилась, след на стене — [has_bullet_hole(wall)], попадание в клетке стены — [projectile.location?.return_turf() == wall]"
			reset_arena()
		for(var/list/beside in shot[4])
			var/label = "срез угла, выстрел в [shot[1]],[shot[2]], стена в стороне в [beside[1]],[beside[2]]"
			build_wall(beside[1], beside[2])
			var/obj/item/projectile/projectile = aim(target, null, 0, center)
			if(!fly_along(projectile) || !fly_along(projectile) || projectile.loc != target)
				failures += "[label]: пуля до цели не дошла"
			else if(!projectile.density)
				failures += "[label]: после срезанного угла пуля осталась неплотной"
			reset_arena()

/**
 * Клик по тому, что лежит вровень с полом, — клик по полу под ним: целью снаряда становится клетка,
 * точка прицела не подтягивается, и в этой клетке пуля не кончается. Предмет на полу и то, что пуля
 * ломает, клеткой не становятся; что с ними делает пуля — в `check_fly_past()`.
 */
/datum/unit_test/combat_extended/pixel_aim/proc/check_floor_target(list/failures)
	var/turf/place = spot(1, 0)
	var/obj/decal/cleanable/blood/blood = put(1, 0, /obj/decal/cleanable/blood)
	var/obj/item/device/flashlight/thing = put(1, 0, /obj/item/device/flashlight)
	var/obj/machinery/floor_light/lamp = put(1, 0, /obj/machinery/floor_light)
	if(QDELETED(blood) || QDELETED(lamp))
		failures += "вровень с полом: пятно крови или светильник в полу не создались"
		reset_arena()
		return

	if(!blood.ce_is_flush_with_floor())
		failures += "вровень с полом: пятно крови не считается лежащим вровень с полом"
	if(thing.ce_is_flush_with_floor() || lamp.ce_is_flush_with_floor() || place.ce_is_flush_with_floor())
		failures += "вровень с полом: предмет — [thing.ce_is_flush_with_floor()], светильник в полу с запасом прочности — [lamp.ce_is_flush_with_floor()], клетка — [place.ce_is_flush_with_floor()]"
	// Правило смотрит на слой и плотность, а не на тип.
	thing.layer = MOUSETRAP_LAYER
	var/low_thing = thing.ce_is_flush_with_floor()
	thing.layer = initial(thing.layer)
	blood.set_density(TRUE)
	var/dense_blood = blood.ce_is_flush_with_floor()
	blood.set_density(FALSE)
	if(!low_thing || dense_blood)
		failures += "вровень с полом: предмет на слое мышеловки — [low_thing], плотное пятно — [dense_blood]"

	// Пиксель 1,1 пятна, сдвинутого на 4 пикселя вправо, — в 11.5 пикселя левее и в 15.5 ниже середины
	// клетки: дальше предела клика по предмету и не там, где пиксель 1,1 самой клетки.
	blood.pixel_x = 4
	var/obj/item/projectile/at_blood = aim(blood, list(1, 1), 0, center)
	blood.pixel_x = 0
	if(at_blood.original != place)
		failures += "вровень с полом: клик по пятну крови целит в [at_blood.original], а не в клетку под ним"
	if(!points_along(at_blood.trajectory, world.icon_size - 11.5, -15.5) || at_blood.p_x != 5 || at_blood.p_y != 1)
		failures += "вровень с полом: клик по углу сдвинутого пятна — шаг вектора [at_blood.trajectory.offset_x],[at_blood.trajectory.offset_y], `p_x`/`p_y` [at_blood.p_x],[at_blood.p_y]; ожидался щёлкнутый пиксель пятна, без подтягивания к середине клетки"
	var/obj/item/projectile/at_thing = aim(thing, list(16, 16), 0, center)
	var/obj/item/projectile/at_lamp = aim(lamp, list(16, 16), 0, center)
	if(at_thing.original != thing || at_lamp.original != lamp)
		failures += "вровень с полом: клик по предмету целит в [at_thing.original], по светильнику в полу — в [at_lamp.original]"
	// Без попиксельной стрельбы — то же: в пятне выстрел кончался и в Бэй.
	ce_pixel_aim_enabled = FALSE
	var/obj/item/projectile/bay = aim(blood, list(1, 1), 0, center)
	ce_pixel_aim_enabled = TRUE
	if(bay.original != place || bay.trajectory.offset_y)
		failures += "вровень с полом: с выключенным прицелом клик по пятну целит в [bay.original], шаг вектора [bay.trajectory.offset_x],[bay.trajectory.offset_y]"

	// Пуля по клику в пятно идёт через его клетку дальше; по клику в светильник — кончается в нём
	// и разбивает его.
	var/obj/item/projectile/past = aim(blood, null, 0, center)
	if(!fly_at_target(past) || !fly_at_target(past) || past.loc != spot(2, 0))
		failures += "вровень с полом: пуля по клику в пятно крови до клетки за ним не дошла — пуля цела — [!QDELETED(past)]"
	var/obj/item/projectile/into_lamp = aim(lamp, null, 0, center)
	if(fly_at_target(into_lamp) || !lamp.get_damage_value())
		failures += "вровень с полом: пуля по клику в светильник в полу — прошла — [!QDELETED(into_lamp)], урон светильнику [lamp.get_damage_value()]"
	reset_arena()

/**
 * Выстрел, нацеленный в неплотный предмет, которому пуля ничего не сделает, летит дальше, и
 * попаданием по предмету это не считается. Целью остаются то, что пуля ломает, предмет со своей
 * реакцией на пулю и неплотная преграда, не пустившая пулю в свою клетку; выстрел себе под ноги
 * кончается сразу, как в Бэй.
 */
/datum/unit_test/combat_extended/pixel_aim/proc/check_fly_past(list/failures)
	var/turf/place = spot(1, 0)
	var/counting_type = /obj/item/projectile/bullet/pistol/ce_test_counting
	var/obj/item/device/flashlight/thing = put(1, 0, /obj/item/device/flashlight)
	var/obj/machinery/floor_light/lamp = put(1, 0, /obj/machinery/floor_light)
	var/obj/ce_test_reactive/reactive = put(1, 0, /obj/ce_test_reactive)
	var/obj/ce_test_barrier/barrier = put(-1, 0, /obj/ce_test_barrier)

	thing.set_density(TRUE)
	var/dense_thing = thing.ce_has_nothing_to_hit()
	thing.set_density(FALSE)
	if(!thing.ce_has_nothing_to_hit() || dense_thing || lamp.ce_has_nothing_to_hit())
		failures += "мимо предмета: задеть нечего в фонарике — [thing.ce_has_nothing_to_hit()], в плотном фонарике — [dense_thing], в светильнике с запасом прочности — [lamp.ce_has_nothing_to_hit()]"

	// Пуля по клику в фонарик идёт через его клетку дальше, и `on_hit()` по нему не зовёт.
	var/obj/item/projectile/bullet/pistol/ce_test_counting/past = make_projectile(counting_type, center)
	past.original = thing
	past.setup_trajectory(center, place)
	if(!fly_at_target(past) || !fly_at_target(past) || past.loc != spot(2, 0) || past.ce_on_hits)
		failures += "мимо предмета: пуля по клику в фонарик — цела — [!QDELETED(past)], `on_hit()` позван [past.ce_on_hits] раз; ожидалась пуля в клетке за ним без попаданий"
	// Без попиксельной стрельбы — то же: на предмете выстрел кончался и в Бэй.
	ce_pixel_aim_enabled = FALSE
	var/obj/item/projectile/bay = aim(thing, null, 0, center)
	ce_pixel_aim_enabled = TRUE
	if(!fly_at_target(bay) || !fly_at_target(bay) || bay.loc != spot(2, 0))
		failures += "мимо предмета: с выключенным прицелом пуля по клику в фонарик кончилась в его клетке"

	// То, что пуля ломает, и предмет со своей реакцией на пулю остаются целью.
	var/obj/item/projectile/bullet/pistol/ce_test_counting/into_lamp = make_projectile(counting_type, center)
	into_lamp.original = lamp
	into_lamp.setup_trajectory(center, place)
	if(fly_at_target(into_lamp) || !lamp.get_damage_value() || into_lamp.ce_on_hits != 1)
		failures += "мимо предмета: пуля по клику в светильник в полу — прошла — [!QDELETED(into_lamp)], урон светильнику [lamp.get_damage_value()], `on_hit()` позван [into_lamp.ce_on_hits] раз"
	var/obj/item/projectile/into_reactive = aim(reactive, null, 0, center)
	if(fly_at_target(into_reactive) || reactive.ce_hits != 1)
		failures += "мимо предмета: пуля по клику в предмет со своей реакцией на пулю — прошла — [!QDELETED(into_reactive)], реакций [reactive.ce_hits]"

	// Неплотная преграда, не пустившая пулю в свою клетку, — преграда, даже когда целились в неё.
	var/obj/item/projectile/blocked = aim(barrier, null, 0, center)
	if(fly_at_target(blocked))
		failures += "мимо предмета: пуля прошла неплотную преграду, не пустившую её в свою клетку"

	// Выстрел себе под ноги кончается сразу и по предмету попадает, как в Бэй.
	var/obj/item/projectile/bullet/pistol/ce_test_counting/underfoot = make_projectile(counting_type, place)
	underfoot.launch(thing, BP_CHEST)
	if(!QDELETED(underfoot) || underfoot.ce_on_hits != 1)
		failures += "мимо предмета: выстрел по фонарику в своей клетке — пуля цела — [!QDELETED(underfoot)], `on_hit()` позван [underfoot.ce_on_hits] раз"
	reset_arena()

/// Линия через сам угол между двумя стенами проходит, как в Бэй; глубже порога — встречает стену.
/datum/unit_test/combat_extended/pixel_aim/proc/check_corner_tolerance(list/failures)
	var/turf/target = spot(1, 1)
	build_wall(1, 0)
	build_wall(0, 1)
	var/obj/item/projectile/diagonal = aim(target, null, 0, center)
	if(!fly_along(diagonal) || diagonal.loc != target)
		failures += "порог среза: выстрел точно по диагонали между двумя стенами не прошёл"
	// Клик в пиксель 18,15 ведёт линию в полутора пикселях от угла: в клетке стены — 2 пикселя линии.
	var/obj/item/projectile/grazing = aim(target, list(18, 15), 0, center)
	if(!fly_along(grazing) || grazing.loc != target)
		failures += "порог среза: выстрел в двух пикселях от угла стены не прошёл"
	// Клик в пиксель 22,11: в клетке стены — 8 пикселей линии.
	var/obj/item/projectile/clipping = aim(target, list(22, 11), 0, center)
	if(fly_step(clipping))
		failures += "порог среза: выстрел с 8 пикселями линии в клетке стены прошёл"
	// С порогом длиннее любого среза угол не проверяется вовсе.
	ce_corner_cut_tolerance = 100
	var/obj/item/projectile/tolerated = aim(target, list(22, 11), 0, center)
	if(!fly_along(tolerated) || tolerated.loc != target)
		failures += "порог среза: с порогом 100 выстрел через угол стены не прошёл"
	ce_corner_cut_tolerance = 4
	reset_arena()

/// Моба в срезанном углу пуля не задевает и мимо него летит дальше.
/datum/unit_test/combat_extended/pixel_aim/proc/check_corner_mob(list/failures, mob/living/carbon/human/H)
	var/turf/target = spot(2, 1)
	H.forceMove(spot(1, 0))
	var/damage_before = H.getBruteLoss()
	// Бросок Бэй попал бы в стоящего вплотную почти наверняка: три выстрела подряд мимо не случаются.
	for(var/trial in 1 to 3)
		var/obj/item/projectile/projectile = aim(target, null, 0, center)
		if(!fly_along(projectile) || !fly_along(projectile) || projectile.loc != target)
			failures += "моб в срезанном углу: пуля до цели не дошла"
			break
	if(H.getBruteLoss() != damage_before)
		failures += "моб в срезанном углу: задет, урон [H.getBruteLoss() - damage_before]"

	// Моб со своими правилами прохода не пускает и неплотный снаряд: тот обходит его в `Bump()` и
	// летит дальше прыжком Бэй, а повтор столкновения от BYOND моба не задевает.
	H.forceMove(spot(-2, -2))
	var/mob/living/carbon/human/blocker = make_human(null, /mob/living/carbon/human/ce_test_impassable)
	if(!blocker)
		failures += "моб со своими правилами прохода: не удалось создать"
		reset_arena()
		return
	blocker.forceMove(spot(1, 0))
	var/blocker_damage = blocker.getBruteLoss()
	for(var/trial in 1 to 3)
		var/obj/item/projectile/projectile = aim(target, null, 0, center)
		if(!fly_along(projectile) || !fly_along(projectile) || projectile.loc != target)
			failures += "моб со своими правилами прохода: пуля до цели не дошла"
			break
	if(blocker.getBruteLoss() != blocker_damage)
		failures += "моб со своими правилами прохода: задет, урон [blocker.getBruteLoss() - blocker_damage]"
	blocker.forceMove(spot(-2, -2))
	H.forceMove(spot(1, 0))

	// То же по частям: столкновение пропущено, его повтор погашен.
	var/obj/item/projectile/refused = aim(target, null, 0, center)
	refused.ce_cutting_corner = TRUE
	if(refused.Bump(H, TRUE) || QDELETED(refused) || !refused.ce_corner_mob_skipped)
		failures += "моб в срезанном углу: столкновение с ним не пропущено"
	else
		refused.Bump(get_turf(H))
		if(QDELETED(refused) || H.getBruteLoss() != damage_before)
			failures += "моб в срезанном углу: повтор столкновения не погашен"
	H.forceMove(spot(-2, -2))
	reset_arena()

/// Рикошет от стены в срезанном углу: зеркалится составляющая поперёк её грани, пуля летит дальше.
/datum/unit_test/combat_extended/pixel_aim/proc/check_corner_ricochet(list/failures)
	var/old_scatter = ce_ricochet_scatter_degrees
	ce_ricochet_enabled = TRUE
	ce_ricochet_scatter_degrees = 0
	build_wall(1, 0)
	var/obj/item/projectile/projectile = aim(spot(2, 1), null, 0, center)
	// С таким множителем любой ненулевой шанс рикошета — 100%.
	projectile.ce_ricochet_chance_mult = 1000
	var/datum/plot_vector/vector = projectile.trajectory
	var/before_x = vector.offset_x
	var/before_y = vector.offset_y
	if(!fly_step(projectile))
		failures += "рикошет в срезанном углу: пуля застряла в стене"
	else
		if(projectile.ce_ricochets != 1 || projectile.loc != center || !projectile.density)
			failures += "рикошет в срезанном углу: рикошетов [projectile.ce_ricochets], пуля в своей клетке — [projectile.loc == center], плотная — [projectile.density]"
		if(abs(vector.offset_x + before_x) > CE_AIM_TOLERANCE || abs(vector.offset_y - before_y) > CE_AIM_TOLERANCE)
			failures += "рикошет в срезанном углу: шаг [vector.offset_x],[vector.offset_y], ожидался [-before_x],[before_y]"
		if(!fly_step(projectile) || projectile.x >= center.x)
			failures += "рикошет в срезанном углу: после него пуля не ушла от стены"
	ce_ricochet_enabled = FALSE
	ce_ricochet_scatter_degrees = old_scatter
	reset_arena()

/// Трассировщик видит ту же линию, что летит пуля: угол стены её закрывает, моб в срезанном углу — нет.
/datum/unit_test/combat_extended/pixel_aim/proc/check_corner_trace(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/bystander)
	H.forceMove(spot(2, 1))
	var/obj/item/projectile/test/clear = make_projectile(/obj/item/projectile/test, center)
	if(clear.launch(H) != H)
		failures += "трассировщик: до моба за свободным углом линия не дошла"

	bystander.forceMove(spot(1, 0))
	var/obj/item/projectile/test/past_mob = make_projectile(/obj/item/projectile/test, center)
	if(past_mob.launch(H) != H)
		failures += "трассировщик: моб в срезанном углу закрыл линию"
	bystander.forceMove(spot(-2, -2))

	build_wall(1, 0)
	var/obj/item/projectile/test/blocked = make_projectile(/obj/item/projectile/test, center)
	if(blocked.launch(H))
		failures += "трассировщик: линия сквозь угол стены считается свободной"
	reset_arena()

/// С выключенным выключателем диагональный шаг — прыжок Бэй: срезанный угол не проверяется.
/datum/unit_test/combat_extended/pixel_aim/proc/check_corner_switch(list/failures)
	// Линия в цель 2,-1 идёт через 1,0 и срезает угол 1,-1.
	var/turf/target = spot(2, -1)
	build_wall(1, -1)
	ce_pixel_aim_enabled = FALSE
	var/obj/item/projectile/bay = aim(target, null, 0, center)
	var/passed = fly_along(bay) && fly_along(bay) && bay.loc == target
	ce_pixel_aim_enabled = TRUE
	if(!passed)
		failures += "выключатель: с выключенным прицелом пуля встретила стену в срезанном углу"
	reset_arena()


/*
	Физические попадания (`projectile_hits.dm`). Тест включает выключатель сам: части модели
	работают, а без выключателя бросок и вектор — прежние. Каждая проверка проверена поломкой
	(README, «Попиксельная стрельба и физические промахи»).

	Проверяется:
	- дуга навыка: неумелый расширяет дугу, умелый сужает, меньше нуля она не бывает; из орудий
	  меха любой пилот стреляет как мастер; у снаряда без стрелка, простого моба, меха без пилота и
	  удалённого стрелка дуги навыка нет; выстрел в упор и трассировщик летят без разброса;
	- разброс в самом выстреле: вектор качается на дугу навыка и оружия, не шире её и не уже;
	  снаряд без стрелка идёт в середину тела, выстрел обученного по клетке — в пиксель клика;
	- шанс провала: зона, клетки после первой, точность гасит только поправки, выстрел из оружия
	  гасит больше;
	- бросок: провал — мимо или случайная зона по доле, глаза бросаются как голова, расстояние —
	  до клетки цели; навык стрелка и движение цели в бросок не входят; без выключателя — бросок
	  Бэй;
	- выстрел в упор: оружие помечает снаряд, и по тому, в кого целились, вплотную броска нет;
	- круг тела, настоящим полётом: мимо сдвинутого тела пуля летит дальше и попадает в стоящего
	  за ним, через тело — попадает в него; радиус растёт с размером моба;
	- пролёт мимо тела: урон с расстоянием не снимается, моб запоминается, сообщение — только у
	  близкого пролёта небесшумного снаряда;
	- лежащие: клик по клетке с точкой в теле делает целью лежащего, с точкой вне тела — нет, и
	  клик по пятну крови под ним — так же; пуля над лежащим в цель за ним его не задевает, и в
	  срезанном углу тоже;
	- срезанный угол: меха и стоящего, сдвинутого к линии, пуля в нём встречает, человека посреди
	  клетки — нет;
	- живой щит: пуля, промахнувшаяся по щиту, не задевает и держащего; пуля через тело держащего
	  достаётся щиту; после срезанного угла пуля смотрит по диагонали, которой летит; удалённая
	  пуля больше ни в кого не попадает;
	- дробь: пролёт мимо тела у облака один, а бросок — на каждую дробину;
	- дальность: с 20 и 30 клеток выстрел без разброса доходит до тела, и проваленный бросок
	  оставляет долю случайной зоны.

	Тест — подтип теста попиксельной стрельбы: ему нужны те же снаряды и та же площадка.
*/
/datum/unit_test/combat_extended/pixel_aim/physical_hits
	name = "CE: Физические попадания"
	/// Клетки космоса, застеленные полом под дорожку дальнего выстрела.
	var/list/lane_paved = list()

/datum/unit_test/combat_extended/pixel_aim/physical_hits/start_test()
	origin = get_safe_turf()
	if(!origin || !near(3, 3) || !near(-3, -3))
		fail("Вокруг безопасной клетки нет трёх клеток карты в каждую сторону.")
		return 1
	if(!claim_arena())
		return 1
	var/mob/living/carbon/human/H = make_human()
	var/mob/living/carbon/human/bystander = make_human()
	var/mob/living/carbon/human/ce_test_target/mark = make_human(null, /mob/living/carbon/human/ce_test_target)
	if(!H || !bystander || !mark)
		fail("Не удалось создать людей.")
		return 1

	var/old_pixel_aim = ce_pixel_aim_enabled
	var/old_physical_hits = ce_physical_hits_enabled
	var/old_debug = ce_aim_debug
	var/old_tolerance = ce_corner_cut_tolerance
	var/old_ricochet = ce_ricochet_enabled
	var/old_miss_per_tile = ce_miss_per_tile
	var/old_pass_share = ce_miss_pass_share
	var/list/old_zone_chances = ce_zone_miss_chances
	ce_pixel_aim_enabled = TRUE
	ce_physical_hits_enabled = TRUE
	ce_aim_debug = FALSE
	ce_corner_cut_tolerance = 4
	ce_ricochet_enabled = FALSE
	var/list/failures = list()

	check_skill_arc(failures, H)
	check_miss_chance(failures, H)
	check_roll(failures, H)
	check_point_blank(failures, H, bystander)
	check_spread_flight(failures, H)
	check_exact_shots(failures, H, bystander)
	check_radii(failures, H)
	check_roll_inputs(failures, H, mark)

	pave_arena(/turf/simulated/floor/airless)
	// Дальше броски должны попадать наверняка: в грудь, без поправки за расстояние.
	ce_zone_miss_chances = old_zone_chances.Copy()
	ce_zone_miss_chances[BP_CHEST] = 0
	ce_miss_per_tile = 0
	check_body_circle(failures, H, bystander)
	check_prone(failures, H)
	check_corner_bodies(failures, H, bystander)
	check_living_shield(failures)
	check_flyby(failures, mark)
	check_overflight(failures, H, mark)
	check_pellets(failures, mark)
	check_long_range_flight(failures, H, mark, old_miss_per_tile, old_zone_chances)

	ce_pixel_aim_enabled = old_pixel_aim
	ce_physical_hits_enabled = old_physical_hits
	ce_aim_debug = old_debug
	ce_corner_cut_tolerance = old_tolerance
	ce_ricochet_enabled = old_ricochet
	ce_miss_per_tile = old_miss_per_tile
	ce_miss_pass_share = old_pass_share
	ce_zone_miss_chances = old_zone_chances
	reset_arena()
	cleanup()
	pave_arena(/turf/space)
	var/arena_problem = describe_arena_problem()
	if(arena_problem)
		failures += "площадка после теста: [arena_problem]"
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Навык стрелка идёт в дугу разброса, пуля мимо тела летит дальше без броска и без потери урона, бросок считает шанс зоны, расстояние и точность, выстрел в упор не промахивается, клик по клетке под лежащим целит в него, дробь бросает на каждую дробину, с тридцати клеток пуля доходит до тела, а без выключателя бросок — Бэй.")
	return 1

/// Дуга разброса у стрелка `shooter` с разбросом оружия `dispersion`; null — стрелка нет.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/arc_of(mob/shooter, dispersion = 0, projectile_type = /obj/item/projectile/bullet/pistol)
	var/obj/item/projectile/projectile = make_projectile(projectile_type)
	projectile.firer = shooter
	projectile.dispersion = dispersion
	return projectile.ce_get_spread_arc()

/// Навык стрелка — дуга разброса: неумелый расширяет её, умелый сужает, меньше нуля она не бывает.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_skill_arc(list/failures, mob/living/carbon/human/H)
	var/level_arc = ce_skill_dispersion_arc_degrees
	var/weapon_arc = 2 * ce_dispersion_arc_degrees
	// list(уровень навыка, разброс оружия, ожидаемая дуга)
	var/list/cases = list(
		list(SKILL_UNSKILLED, 0, 2 * level_arc),
		list(SKILL_BASIC, 0, level_arc),
		list(SKILL_TRAINED, 0, 0),
		list(SKILL_EXPERIENCED, 0, 0),
		list(SKILL_UNSKILLED, 2, weapon_arc + 2 * level_arc),
		list(SKILL_TRAINED, 2, weapon_arc),
		list(SKILL_EXPERIENCED, 2, max(weapon_arc - level_arc, 0)),
		list(SKILL_MASTER, 2, max(weapon_arc - 2 * level_arc, 0))
	)
	for(var/list/entry as anything in cases)
		set_skills(H, list(SKILL_WEAPONS = entry[1]))
		var/arc = arc_of(H, entry[2])
		if(abs(arc - entry[3]) > CE_AIM_TOLERANCE)
			failures += "дуга навыка: навык [entry[1]], разброс оружия [entry[2]] — дуга [arc], ожидалась [entry[3]]"

	set_skills(H, list(SKILL_WEAPONS = SKILL_UNSKILLED))
	if(abs(arc_of(null, 2) - weapon_arc) > CE_AIM_TOLERANCE)
		failures += "дуга навыка: у снаряда без стрелка дуга [arc_of(null, 2)], ожидался разброс оружия [weapon_arc]"
	var/mob/living/simple_animal/passive/mouse/mouse = new(near(-2, 2))
	spawned += mouse
	if(abs(arc_of(mouse, 2) - weapon_arc) > CE_AIM_TOLERANCE)
		failures += "дуга навыка: у простого моба дуга [arc_of(mouse, 2)], ожидался разброс оружия [weapon_arc]"

	var/mob/living/exosuit/premade/combat/mech = new(near(-2, 3))
	spawned += mech
	if(abs(arc_of(mech, 2) - weapon_arc) > CE_AIM_TOLERANCE)
		failures += "дуга навыка: у меха без пилота дуга [arc_of(mech, 2)], ожидался разброс оружия [weapon_arc]"
	// Всякий, кого мех допустил до орудий, стреляет из них как мастер, каким бы стрелком он ни был.
	var/heavy_arc = 4 * ce_dispersion_arc_degrees
	var/master_arc = max(heavy_arc - (SKILL_MASTER - SKILL_TRAINED) * level_arc, 0)
	LAZYADD(mech.pilots, H)
	if(abs(arc_of(mech, 4) - master_arc) > CE_AIM_TOLERANCE || arc_of(H, 4) <= master_arc)
		failures += "дуга навыка: у меха с неумелым пилотом дуга [arc_of(mech, 4)], ожидалась дуга мастера [master_arc]; у самого пилота [arc_of(H, 4)]"
	LAZYREMOVE(mech.pilots, H)

	// Вектор нацеливается тиком позже выстрела: стрелка к тому времени может уже не быть, и набора
	// навыков у удалённого моба нет.
	var/mob/living/carbon/human/gone = make_human()
	if(gone)
		qdel(gone)
		if(abs(arc_of(gone, 2) - weapon_arc) > CE_AIM_TOLERANCE)
			failures += "дуга навыка: у удалённого стрелка дуга [arc_of(gone, 2)], ожидался разброс оружия [weapon_arc]"

	// Выстрел в упор и трассировщик — без разброса.
	var/obj/item/projectile/point_blank = make_projectile()
	point_blank.firer = H
	point_blank.dispersion = 2
	point_blank.ce_point_blank = TRUE
	if(point_blank.ce_get_spread_arc())
		failures += "дуга навыка: у выстрела в упор дуга [point_blank.ce_get_spread_arc()]"
	if(arc_of(H, 2, /obj/item/projectile/test))
		failures += "дуга навыка: у трассировщика дуга [arc_of(H, 2, /obj/item/projectile/test)]"

	ce_physical_hits_enabled = FALSE
	var/arc_without = arc_of(H, 2)
	ce_physical_hits_enabled = TRUE
	if(abs(arc_without - weapon_arc) > CE_AIM_TOLERANCE)
		failures += "дуга навыка: без выключателя дуга [arc_without], ожидался разброс оружия [weapon_arc]"
	set_skills(H, list())

/// Шанс провала: шанс зоны, клетки после первой, а точность гасит только поправки.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_miss_chance(list/failures, mob/living/carbon/human/H)
	var/obj/item/projectile/projectile = make_projectile()
	var/chest = ce_zone_miss_chances[BP_CHEST]
	var/head = ce_zone_miss_chances[BP_HEAD]
	var/far = 3 * ce_miss_per_tile
	// list(подпись, зона, клетки, точность снаряда, поправка вызвавшего, ожидаемый шанс)
	var/list/cases = list(
		list("грудь вплотную", BP_CHEST, 1, 0, 0, chest),
		list("грудь в той же клетке", BP_CHEST, 0, 0, 0, chest),
		list("голова вплотную", BP_HEAD, 1, 0, 0, head),
		list("грудь с четырёх клеток", BP_CHEST, 4, 0, 0, chest + far),
		list("точность гасит расстояние", BP_CHEST, 4, 5, 0, chest + max(far - 5 * ce_miss_per_hitchance, 0)),
		list("точность не трогает шанс зоны", BP_HEAD, 4, 1000, 0, head),
		list("поправка вызвавшего", BP_CHEST, 1, 0, 50, chest + 50),
		list("точность гасит поправку вызвавшего", BP_CHEST, 1, 1000, 50, chest),
		list("зона не из таблицы", "ce_test_zone", 1, 0, 0, chest)
	)
	for(var/list/entry as anything in cases)
		projectile.hitchance_mod = entry[4]
		projectile.ce_special_miss_modifier = entry[5]
		var/chance = projectile.ce_get_miss_chance(entry[2], entry[3])
		if(abs(chance - entry[6]) > CE_AIM_TOLERANCE)
			failures += "шанс провала, [entry[1]]: [chance], ожидался [entry[6]]"
	if(head <= chest)
		failures += "шанс провала: у головы [head], у груди [chest]"

	// Выстрел из оружия гасит `ce_gun_accuracy_points` сверх своей точности, но не шанс зоны.
	var/gun_points = ce_gun_accuracy_points
	projectile.hitchance_mod = 0
	projectile.ce_special_miss_modifier = gun_points + 100
	var/plain_chance = projectile.ce_get_miss_chance(BP_CHEST, 1)
	projectile.ce_gun_shot = TRUE
	var/gun_chance = projectile.ce_get_miss_chance(BP_CHEST, 1)
	if(gun_points <= 0 || abs(plain_chance - gun_chance - gun_points) > CE_AIM_TOLERANCE)
		failures += "шанс провала, выстрел из оружия: [gun_chance], у снаряда без оружия [plain_chance], прибавка оружия [gun_points]"
	projectile.ce_special_miss_modifier = 0
	var/gun_head_chance = projectile.ce_get_miss_chance(BP_HEAD, 1)
	if(abs(gun_head_chance - head) > CE_AIM_TOLERANCE)
		failures += "шанс провала, выстрел из оружия в голову вплотную: [gun_head_chance], ожидался шанс зоны [head]"
	// Точность ниже нуля прибавляет к провалу: сперва съедает прибавку оружия.
	projectile.hitchance_mod = -(gun_points / ce_miss_per_hitchance + 10)
	var/clumsy_chance = projectile.ce_get_miss_chance(BP_CHEST, 1)
	if(abs(clumsy_chance - (chest + 10 * ce_miss_per_hitchance)) > CE_AIM_TOLERANCE)
		failures += "шанс провала, точность ниже нуля: [clumsy_chance], ожидался [chest + 10 * ce_miss_per_hitchance]"

	// Помечает снаряд само оружие, когда считает ему точность.
	var/obj/item/gun/energy/laser/gun = new(origin)
	spawned += gun
	var/obj/item/projectile/fired = make_projectile()
	var/obj/item/projectile/loose = make_projectile()
	gun.process_accuracy(fired, H, H, 1, TRUE)
	if(!fired.ce_gun_shot || loose.ce_gun_shot)
		failures += "шанс провала: выстрел из оружия помечен — [fired.ce_gun_shot], снаряд без оружия помечен — [loose.ce_gun_shot]"

/// Бросок: провал — мимо или случайная зона по доле; без выключателя — бросок Бэй.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_roll(list/failures, mob/living/carbon/human/H)
	H.forceMove(near(3, 0))
	var/obj/item/projectile/projectile = make_projectile()
	projectile.original = H
	projectile.starting = origin
	// Расстояние — до клетки цели, а не то, что насчитал кор `Bump()`.
	if(projectile.ce_get_hit_distance(H, 1) != 3)
		failures += "бросок: расстояние до цели [projectile.ce_get_hit_distance(H, 1)], ожидалось 3"
	projectile.starting = null
	if(projectile.ce_get_hit_distance(H, 1) != 1)
		failures += "бросок: у незапущенного снаряда расстояние [projectile.ce_get_hit_distance(H, 1)], ожидалось расстояние вызвавшего 1"
	projectile.starting = origin

	var/old_miss_per_tile = ce_miss_per_tile
	var/list/old_zone_chances = ce_zone_miss_chances
	var/old_pass_share = ce_miss_pass_share
	// Провал наверняка: поправка Бэй, с которой его бросок попал бы всегда, не смотрится.
	ce_miss_per_tile = 1000
	var/passed = 0
	var/strayed = 0
	ce_miss_pass_share = 100
	for(var/trial in 1 to CE_AIM_TRIALS)
		if(isnull(projectile.ce_get_projectile_hit_zone(BP_CHEST, H, -1000, 3)))
			passed++
	ce_miss_pass_share = 0
	for(var/trial in 1 to CE_AIM_TRIALS)
		if(projectile.ce_get_projectile_hit_zone(BP_CHEST, H, -1000, 3) in organ_rel_size)
			strayed++
	if(passed != CE_AIM_TRIALS || strayed != CE_AIM_TRIALS)
		failures += "бросок: из [CE_AIM_TRIALS] провалов с долей «мимо» 100 мимо прошло [passed], с долей 0 в зону тела попало [strayed]"

	// Кор `attack_mob()` бросает этот же бросок, а поправка вызвавшего доходит до него как есть: с
	// такой поправкой бросок Бэй попал бы наверняка.
	ce_miss_pass_share = 100
	var/damage_before = H.getBruteLoss()
	if(projectile.attack_mob(H, 3, -1000) || H.getBruteLoss() != damage_before)
		failures += "бросок: кор `attack_mob()` попал там, где бросок провален наверняка, урон [H.getBruteLoss() - damage_before]"
	if(projectile.ce_special_miss_modifier != -1000)
		failures += "бросок: поправка вызвавшего до броска не дошла — запомнено [projectile.ce_special_miss_modifier]"

	// Попадание наверняка, и глаза бросаются как голова.
	ce_miss_per_tile = 0
	ce_zone_miss_chances = old_zone_chances.Copy()
	ce_zone_miss_chances[BP_HEAD] = 0
	var/in_head = 0
	for(var/trial in 1 to CE_AIM_TRIALS)
		if(projectile.ce_get_projectile_hit_zone(BP_EYES, H, 1000, 3) == BP_HEAD)
			in_head++
	ce_miss_pass_share = old_pass_share
	if(in_head != CE_AIM_TRIALS)
		failures += "бросок: с нулевым шансом провала в голову из [CE_AIM_TRIALS] бросков по глазам попало [in_head]"

	// Без выключателя решает поправка Бэй.
	ce_physical_hits_enabled = FALSE
	var/bay_hits = 0
	var/bay_misses = 0
	for(var/trial in 1 to CE_AIM_TRIALS)
		if(projectile.ce_get_projectile_hit_zone(BP_HEAD, H, -1000, 3) == BP_HEAD)
			bay_hits++
		if(isnull(projectile.ce_get_projectile_hit_zone(BP_HEAD, H, 1000, 3)))
			bay_misses++
	ce_physical_hits_enabled = TRUE
	if(bay_hits != CE_AIM_TRIALS || bay_misses != CE_AIM_TRIALS)
		failures += "бросок без выключателя: из [CE_AIM_TRIALS] с поправкой Бэй −1000 попало [bay_hits], с +1000 мимо прошло [bay_misses]"
	// И без попиксельной стрельбы тоже: одни физические попадания не работают.
	ce_pixel_aim_enabled = FALSE
	bay_misses = 0
	for(var/trial in 1 to CE_AIM_TRIALS)
		if(isnull(projectile.ce_get_projectile_hit_zone(BP_HEAD, H, 1000, 3)))
			bay_misses++
	ce_pixel_aim_enabled = TRUE
	if(bay_misses != CE_AIM_TRIALS)
		failures += "бросок без попиксельной стрельбы: из [CE_AIM_TRIALS] с поправкой Бэй +1000 мимо прошло [bay_misses]"
	ce_miss_per_tile = old_miss_per_tile
	ce_zone_miss_chances = old_zone_chances

/// Выстрел в упор: оружие помечает снаряд, и по тому, в кого целились, вплотную броска нет.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_point_blank(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/bystander)
	H.forceMove(near(1, 0))
	bystander.forceMove(near(0, 1))
	var/obj/item/gun/energy/laser/gun = new(origin)
	spawned += gun
	var/obj/item/projectile/marked = make_projectile()
	var/obj/item/projectile/plain = make_projectile()
	gun.process_point_blank(marked, bystander, H)
	if(!marked.ce_point_blank || plain.ce_point_blank)
		failures += "выстрел в упор: помечен — [marked.ce_point_blank], обычный снаряд помечен — [plain.ce_point_blank]"
	for(var/obj/item/projectile/projectile in list(marked, plain))
		projectile.original = H
		projectile.starting = origin
	if(!marked.ce_is_sure_hit(H, 1))
		failures += "выстрел в упор: по цели вплотную нужен бросок"
	if(marked.ce_is_sure_hit(H, 2) || marked.ce_is_sure_hit(bystander, 1))
		failures += "выстрел в упор: без броска с двух клеток — [marked.ce_is_sure_hit(H, 2)], по постороннему — [marked.ce_is_sure_hit(bystander, 1)]"
	if(plain.ce_is_sure_hit(H, 1))
		failures += "выстрел в упор: обычный выстрел по стоящему вплотную идёт без броска"
	H.lying = TRUE
	if(!plain.ce_is_sure_hit(H, 1))
		failures += "выстрел в упор: по лежащему вплотную нужен бросок"
	H.lying = FALSE

	// Ствол упёрт в тело: мимо него выстрел в упор не проходит, куда бы ни смотрел вектор.
	marked.original = near(1, 3)
	marked.setup_trajectory(origin, marked.original)
	plain.original = near(1, 3)
	plain.setup_trajectory(origin, plain.original)
	marked.original = H
	plain.original = H
	if(marked.ce_misses_body(H) || !plain.ce_misses_body(H))
		failures += "выстрел в упор: линия мимо тела — выстрел в упор проходит мимо — [marked.ce_misses_body(H)], обычный — [plain.ce_misses_body(H)]"

/// Круг тела: мимо сдвинутого тела пуля летит дальше и попадает в стоящего за ним, через тело —
/// попадает в него.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_body_circle(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/bystander)
	var/turf/start = spot(-2, 0)
	H.forceMove(spot(2, 0))
	bystander.forceMove(spot(1, 0))
	// Тело постороннего — в 14 пикселях от линии, дальше своего радиуса.
	bystander.pixel_y = bystander.default_pixel_y + 14
	var/target_damage = H.getBruteLoss()
	var/bystander_damage = bystander.getBruteLoss()
	var/obj/item/projectile/past = aim(H, null, 0, start)
	var/pass_distance = past.ce_get_pass_distance(bystander)
	if(isnull(pass_distance) || abs(pass_distance - 14) > CE_AIM_TOLERANCE)
		failures += "круг тела: до сдвинутого тела от линии [isnull(pass_distance) ? "нет расстояния" : pass_distance], ожидалось 14"
	ce_physical_hits_enabled = FALSE
	var/missed_without = past.ce_misses_body(bystander)
	ce_physical_hits_enabled = TRUE
	if(missed_without || !past.ce_misses_body(bystander))
		failures += "круг тела: мимо сдвинутого тела без выключателя — [missed_without], с ним — [past.ce_misses_body(bystander)]"
	var/steps = 0
	while(steps < 4 && fly_at_target(past))
		steps++
	if(bystander.getBruteLoss() != bystander_damage)
		failures += "круг тела: пуля мимо тела задела его, урон [bystander.getBruteLoss() - bystander_damage]"
	if(!QDELETED(past) || H.getBruteLoss() <= target_damage)
		failures += "круг тела: пуля, прошедшая мимо тела, в стоящего за ним не попала — шагов [steps], пуля цела — [!QDELETED(past)]"

	// Тело на линии: пуля попадает в него и дальше не летит.
	bystander.pixel_y = bystander.default_pixel_y
	target_damage = H.getBruteLoss()
	bystander_damage = bystander.getBruteLoss()
	var/obj/item/projectile/through = aim(H, null, 0, start)
	steps = 0
	while(steps < 4 && fly_at_target(through))
		steps++
	if(!QDELETED(through) || bystander.getBruteLoss() <= bystander_damage || H.getBruteLoss() != target_damage)
		failures += "круг тела: пуля через тело — шагов [steps], пуля цела — [!QDELETED(through)], урон телу [bystander.getBruteLoss() - bystander_damage], стоящему за ним [H.getBruteLoss() - target_damage]"
	bystander.forceMove(spot(-2, -2))
	H.forceMove(spot(-2, -2))
	reset_arena()

/// Лежащие: клик по клетке с точкой в теле делает целью лежащего, с точкой вне тела — нет.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_prone(list/failures, mob/living/carbon/human/H)
	var/turf/place = spot(1, 1)
	H.forceMove(place)
	// Лежащий повёрнут и сдвинут вниз, как в `update_icons()`, и неплотен.
	H.lying = TRUE
	H.set_density(FALSE)
	H.transform = matrix().Update(rotation = 90, offset_y = -6)

	var/obj/item/projectile/in_body = aim(place, list(16, 10), 0, center)
	var/obj/item/projectile/off_body = aim(place, list(16, 31), 0, center)
	var/obj/item/projectile/no_click = aim(place, null, 0, center)
	if(in_body.original != H || no_click.original != H)
		failures += "лежащие: клик в тело целит в лежащего — [in_body.original == H], выстрел без клика — [no_click.original == H]"
	if(off_body.original != place)
		failures += "лежащие: клик по клетке мимо тела целит в [off_body.original]"
	ce_physical_hits_enabled = FALSE
	var/obj/item/projectile/bay = aim(place, list(16, 10), 0, center)
	ce_physical_hits_enabled = TRUE
	if(bay.original != place)
		failures += "лежащие: без выключателя клик по клетке целит в [bay.original]"
	// Плотного снаряд встречает сам: целью он не становится.
	H.set_density(TRUE)
	var/obj/item/projectile/at_dense = aim(place, list(16, 10), 0, center)
	H.set_density(FALSE)
	if(at_dense.original != place)
		failures += "лежащие: клик по клетке под плотным мобом целит в [at_dense.original]"
	// Пятно крови под лежащим — тот же пол (`ce_take_floor_target()`).
	var/obj/decal/cleanable/blood/blood = put(1, 1, /obj/decal/cleanable/blood)
	var/obj/item/projectile/in_blood = aim(blood, list(16, 10), 0, center)
	var/obj/item/projectile/off_blood = aim(blood, list(16, 31), 0, center)
	if(in_blood.original != H || off_blood.original != place)
		failures += "лежащие: клик по пятну крови в теле целит в [in_blood.original], мимо тела — в [off_blood.original]"

	var/damage_before = H.getBruteLoss()
	fly_at_target(in_body)
	if(!QDELETED(in_body) || H.getBruteLoss() <= damage_before)
		failures += "лежащие: пуля по клику в тело в лежащего не попала — пуля цела — [!QDELETED(in_body)]"
	damage_before = H.getBruteLoss()
	fly_at_target(off_body)
	if(H.getBruteLoss() != damage_before)
		failures += "лежащие: пуля по клику мимо тела задела лежащего, урон [H.getBruteLoss() - damage_before]"

	H.lying = FALSE
	H.set_density(TRUE)
	H.transform = matrix()
	H.forceMove(spot(-2, -2))
	reset_arena()

/// Срезанный угол: меха — он занимает клетку целиком — пуля в нём встречает, человека — нет.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_corner_bodies(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/bystander)
	// Линия в цель 2,1 входит в клетку 1,1 и срезает угол клетки 1,0.
	var/turf/target = spot(2, 1)
	bystander.forceMove(spot(1, 0))
	var/damage_before = bystander.getBruteLoss()
	var/obj/item/projectile/past_human = aim(target, null, 0, center)
	if(!fly_along(past_human) || !fly_along(past_human) || past_human.loc != target || bystander.getBruteLoss() != damage_before)
		failures += "срезанный угол: пуля мимо человека до цели не дошла или задела его, урон [bystander.getBruteLoss() - damage_before]"
	// Трассировщик до броска не доходит: мимо человека в срезанном углу его ведёт та же проверка круга.
	H.forceMove(target)
	var/obj/item/projectile/test/past_trace = make_projectile(/obj/item/projectile/test, center)
	if(past_trace.launch(H) != H)
		failures += "срезанный угол: трассировщику человек в нём закрыл линию"
	bystander.forceMove(spot(-2, -2))
	H.forceMove(spot(-2, -2))

	var/mob/living/exosuit/premade/combat/mech = new(spot(1, 0))
	spawned += mech
	var/obj/item/projectile/at_mech = aim(target, null, 0, center)
	at_mech.def_zone = BP_CHEST
	fly_step(at_mech)
	if(!QDELETED(at_mech) && !(mech in at_mech.permutated))
		failures += "срезанный угол: меха в нём пуля не встретила"
	H.forceMove(target)
	var/obj/item/projectile/test/mech_trace = make_projectile(/obj/item/projectile/test, center)
	if(mech_trace.launch(H) != mech)
		failures += "срезанный угол: трассировщик меха в нём не встретил"
	H.forceMove(spot(-2, -2))
	ce_physical_hits_enabled = FALSE
	var/obj/item/projectile/bay = aim(target, null, 0, center)
	bay.def_zone = BP_CHEST
	var/passed = fly_along(bay) && !(mech in bay.permutated)
	ce_physical_hits_enabled = TRUE
	if(!passed)
		failures += "срезанный угол: без выключателя пуля встретила меха"
	mech.forceMove(spot(-2, -2))
	reset_arena()

/**
 * Живой щит решает за держащего: пуля, промахнувшаяся по щиту, не задевает и его; пуля, чья линия
 * идёт через тело держащего, достаётся щиту, даже если мимо тела самого щита она проходит. Держащий
 * стоит лицом на запад, щит — в его клетке, сдвинут к стрелку на 10 пикселей, как его ставит захват.
 *
 * Люди здесь свои: раненый в прежних проверках падает, как только захват пересчитает его состояние.
 */
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_living_shield(list/failures)
	var/mob/living/carbon/human/holder = make_human()
	var/mob/living/carbon/human/shield = make_human()
	if(!holder || !shield)
		failures += "живой щит: не удалось создать людей"
		return
	var/turf/place = spot(1, 1)
	holder.forceMove(place)
	holder.set_dir(WEST)
	shield.forceMove(spot(0, 1))
	// У человека без клиента нет куклы зон, а захват читает из неё зону.
	holder.zone_sel = new /obj/screen/zone_sel(null)
	var/obj/item/grab/normal/grab = new(holder, shield)
	if(!QDELETED(grab))
		grab.current_grab = all_grabstates[NORM_NECK]
		shield.forceMove(place)
		shield.pixel_x = shield.default_pixel_x - 10
		shield.pixel_y = shield.default_pixel_y
	if(QDELETED(grab) || !grab.shield_assailant() || holder.lying || shield.lying)
		failures += "живой щит: не удалось взять человека в захват, который им прикрывает"
	else
		fire_at_living_shield(failures, holder, shield)

		// Прикрывает только тот захват, который держит щитом, и только от выстрела в лицо держащему.
		var/obj/item/projectile/probe = aim(holder, null, 0, spot(0, 1))
		probe.set_dir(EAST)
		var/covered = probe.ce_get_living_shield(holder) == shield && probe.ce_get_shield_holder(shield) == holder
		probe.set_dir(WEST)
		var/covered_from_behind = probe.ce_get_living_shield(holder) || probe.ce_get_shield_holder(shield)
		probe.set_dir(EAST)
		grab.current_grab = all_grabstates[NORM_PASSIVE]
		var/covered_by_passive = probe.ce_get_living_shield(holder) || probe.ce_get_shield_holder(shield)
		if(!covered || covered_from_behind || covered_by_passive)
			failures += "живой щит: держащий прикрыт от выстрела в лицо — [covered], в спину — [!!covered_from_behind], простым захватом — [!!covered_by_passive]"
	if(!QDELETED(grab))
		qdel(grab)
	QDEL_NULL(holder.zone_sel)
	holder.forceMove(spot(-2, -2))
	shield.forceMove(spot(-2, -2))
	reset_arena()

/**
 * Поворачивает ещё не летевший снаряд спиной к полёту. Куда он смотрит, когда клетка зовёт его
 * `Bump()` на первом шаге, решает сборка BYOND: 516.1667 под Windows успевает повернуть его по шагу,
 * а в CI (516.1658 под Linux) пули в держащего шли мимо живого щита. Снаряд повёрнут так, как будто
 * BYOND его не повернул.
 */
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/face_away(obj/item/projectile/projectile)
	projectile.set_dir(GLOB.reverse_dir[get_dir(projectile, projectile.original)])

/// Выстрелы по держащему `holder`, прикрытому живым щитом `shield`. Броски до и после этой
/// проверки попадают в грудь наверняка. Щит ранят последним: раненый может упасть.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/fire_at_living_shield(list/failures, mob/living/carbon/human/holder, mob/living/carbon/human/shield)
	var/turf/place = get_turf(holder)
	var/turf/west = spot(0, 1)
	var/holder_damage = holder.getBruteLoss()
	var/shield_damage = shield.getBruteLoss()
	// Выстрел в упор по держащему: по нему самому он не промахнулся бы. Бросок по щиту провален, и
	// провал — мимо: пуля летит дальше мимо обоих.
	ce_zone_miss_chances[BP_CHEST] = 100
	ce_miss_pass_share = 100
	var/obj/item/projectile/missed = aim(holder, null, 0, west)
	missed.ce_point_blank = TRUE
	face_away(missed)
	fly_step(missed)
	if(QDELETED(missed) || missed.loc != place || missed.ce_last_missed != shield || !(holder in missed.permutated))
		failures += "живой щит: пуля, промахнувшаяся по щиту, мимо держащего не прошла — цела — [!QDELETED(missed)], промах по щиту записан — [missed.ce_last_missed == shield]"
	if(holder.getBruteLoss() != holder_damage || shield.getBruteLoss() != shield_damage)
		failures += "живой щит: пуля, промахнувшаяся по щиту, ранила — держащего на [holder.getBruteLoss() - holder_damage], щит на [shield.getBruteLoss() - shield_damage]"
	ce_zone_miss_chances[BP_CHEST] = 0

	// Линия из середины площадки через срезанный угол идёт в 5 пикселях от середины держащего и в 11
	// от середины щита: мимо тела щита, но щит держат на её пути. Последний шаг пули — прямо на
	// север, а летит она на северо-восток, держащему в лицо: по направлению полёта кор `Bump()`
	// решает, прикрыт ли держащий.
	var/obj/item/projectile/skewed = aim(place, list(16, 10), 0, center)
	var/beside_shield = !skewed.ce_crosses_body(shield) && skewed.ce_crosses_body(holder)
	fly_step(skewed)
	if(!beside_shield || !QDELETED(skewed) || shield.getBruteLoss() <= shield_damage || holder.getBruteLoss() != holder_damage)
		failures += "живой щит: пуля через тело держащего мимо тела щита — линия такая — [beside_shield], цела — [!QDELETED(skewed)], урон щиту [shield.getBruteLoss() - shield_damage], держащему [holder.getBruteLoss() - holder_damage]"

	// Бросок по щиту удался: пуля достаётся щиту.
	shield_damage = shield.getBruteLoss()
	var/obj/item/projectile/blocked = aim(holder, null, 0, west)
	blocked.ce_point_blank = TRUE
	face_away(blocked)
	fly_step(blocked)
	if(!QDELETED(blocked) || shield.getBruteLoss() <= shield_damage || holder.getBruteLoss() != holder_damage)
		failures += "живой щит: пуля в щит — цела — [!QDELETED(blocked)], урон щиту [shield.getBruteLoss() - shield_damage], держащему [holder.getBruteLoss() - holder_damage]"

	// Пуля, которая уже попала и удалена, повтор столкновения не разбирает.
	shield_damage = shield.getBruteLoss()
	blocked.Bump(shield, TRUE)
	if(shield.getBruteLoss() != shield_damage)
		failures += "живой щит: удалённая пуля попала ещё раз, урон [shield.getBruteLoss() - shield_damage]"


// --- Полёт, пролёт, дробь, дальность и автоматика ---

/// Мишень: считает попадания, дошедшие до `bullet_act()`, и остаётся целой. На площадке нет
/// гравитации, и каждое попадание толкало бы её на клетку (`on_impact()`), поэтому она закреплена.
/mob/living/carbon/human/ce_test_target
	anchored = TRUE
	var/ce_hits = 0

/mob/living/carbon/human/ce_test_target/bullet_act(obj/item/projectile/P, def_zone)
	ce_hits++
	return 0

/// Слушатель: запоминает сообщения, которые до него дошли.
/obj/ce_test_listener
	name = "test listener"
	anchored = TRUE
	var/list/heard = list()

/obj/ce_test_listener/show_message(msg, type, alt, alt_type)
	heard += msg

/// Сколько сообщений о снаряде, прошедшем мимо, услышал слушатель.
/obj/ce_test_listener/proc/count_misses()
	. = 0
	for(var/message in heard)
		if(findtext(message, "misses"))
			.++

/// Снаряд типа `projectile_type` из клетки `start` (без неё — из клетки стрелка), нацеленный в
/// `target`. `shooter` — стрелок, без него это выстрел автоматики.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/shoot(atom/target, turf/start, mob/shooter, projectile_type = /obj/item/projectile/bullet/pistol, dispersion = 0)
	RETURN_TYPE(/obj/item/projectile)
	var/obj/item/projectile/projectile = make_projectile(projectile_type, start)
	projectile.firer = shooter
	projectile.dispersion = dispersion
	projectile.no_attack_log = TRUE
	projectile.original = target
	projectile.def_zone = BP_CHEST
	projectile.setup_trajectory(start || origin, get_turf(target))
	return projectile

/// Ведёт снаряд шагами полёта, не больше `steps`. TRUE — снаряд цел.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/fly_steps(obj/item/projectile/projectile, steps)
	for(var/index in 1 to steps)
		if(!fly_at_target(projectile))
			return FALSE
	return TRUE

/**
 * Убирает снаряд, который проверка уже отлетала. Снаряд плотен: пуля, прошедшая мимо моба, после
 * этого сталкивается с плотным предметом в той же клетке — повтор столкновения от BYOND, — и
 * оставшийся там снаряд прошлого выстрела сошёл бы за такой предмет.
 */
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/spend(obj/item/projectile/projectile)
	if(!QDELETED(projectile))
		qdel(projectile)

/// Шансы провала броска, одинаковые для всех зон: дробь расходится по зонам сама.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/flat_zone_chances(chance)
	RETURN_TYPE(/list)
	. = list()
	for(var/zone in ce_zone_miss_chances)
		.[zone] = chance

/// Разброс в самом выстреле: вектор качается на дугу навыка, а не только на дугу оружия.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_spread_flight(list/failures, mob/living/carbon/human/H)
	var/turf/target = near(3, 0)
	var/level_arc = ce_skill_dispersion_arc_degrees
	var/weapon_arc = ce_dispersion_arc_degrees
	// list(подпись, навык, разброс оружия, ожидаемая дуга)
	var/list/cases = list(
		list("без навыка", SKILL_UNSKILLED, 0, 2 * level_arc),
		list("базовый", SKILL_BASIC, 0, level_arc),
		list("обученный", SKILL_TRAINED, 0, 0),
		list("обученный с разбросом оружия", SKILL_TRAINED, 1, weapon_arc),
		list("опытный с разбросом оружия", SKILL_EXPERIENCED, 1, max(weapon_arc - level_arc, 0))
	)
	for(var/list/entry as anything in cases)
		set_skills(H, list(SKILL_WEAPONS = entry[2]))
		var/widest = 0
		for(var/trial in 1 to CE_AIM_TRIALS)
			// Цель строго на востоке: угол вектора — само отклонение.
			var/obj/item/projectile/shot = shoot(target, null, H, /obj/item/projectile/bullet/pistol, entry[3])
			widest = max(widest, abs(shot.trajectory.angle))
		var/half_arc = entry[4] / 2
		// Сорок бросков, уместившихся в половину своей половины дуги, — шанс 2 в минус сороковой.
		if(widest > half_arc + CE_AIM_TOLERANCE || widest < half_arc / 2)
			failures += "разброс в полёте, [entry[1]]: наибольшее из [CE_AIM_TRIALS] отклонений — [widest]°, дуга [entry[4]]°"
	set_skills(H, list())

/// Точные выстрелы: снаряд без стрелка идёт в середину тела, выстрел обученного — в пиксель клика.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_exact_shots(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/bystander)
	// Турель пускает снаряд без стрелка и без разброса: дуги навыка у автоматики нет.
	var/turf/place = near(3, 1)
	var/turf/bystander_place = get_turf(bystander)
	bystander.forceMove(place)
	var/list/muzzle = origin.ce_get_tile_center()
	var/list/body = bystander.ce_get_body_center()
	for(var/trial in 1 to CE_AIM_TRIALS)
		var/obj/item/projectile/beam = shoot(bystander, null, null, /obj/item/projectile/beam)
		if(beam.ce_get_spread_arc() || !points_along(beam.trajectory, body[1] - muzzle[1], body[2] - muzzle[2]))
			failures += "точность: выстрел без стрелка — дуга [beam.ce_get_spread_arc()], шаг вектора [beam.trajectory.offset_x],[beam.trajectory.offset_y] не в середину тела"
			break
	bystander.forceMove(bystander_place)

	// Выстрел по клетке: обученный стрелок с оружием без разброса попадает в щёлкнутый пиксель.
	set_skills(H, list(SKILL_WEAPONS = SKILL_TRAINED))
	for(var/trial in 1 to CE_AIM_TRIALS)
		var/obj/item/projectile/shot = make_projectile()
		shot.firer = H
		shot.set_clickpoint(click_at(5, 27))
		shot.original = place
		shot.setup_trajectory(origin, place)
		if(shot.ce_get_spread_arc() || shot.p_x != 5 || shot.p_y != 27)
			failures += "точность: выстрел обученного по клетке — дуга [shot.ce_get_spread_arc()], `p_x`/`p_y` [shot.p_x],[shot.p_y], ожидался пиксель клика 5,27"
			break
	set_skills(H, list())

/// Радиус тела растёт с размером моба, а лежащий шире стоящего.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_radii(list/failures, mob/living/carbon/human/H)
	var/mob/living/simple_animal/passive/mouse/beast = new(near(-2, 2))
	spawned += beast
	var/list/radii = list()
	for(var/size in list(MOB_TINY, MOB_SMALL, MOB_MEDIUM, MOB_LARGE))
		beast.mob_size = size
		radii += beast.ce_get_hit_radius()
	var/standing = H.ce_get_hit_radius()
	H.lying = TRUE
	var/prone = H.ce_get_hit_radius()
	H.lying = FALSE
	if(radii[1] <= 0 || radii[1] >= radii[2] || radii[2] >= radii[3] || radii[3] >= radii[4] || abs(radii[3] - standing) > CE_AIM_TOLERANCE || prone <= standing)
		failures += "радиусы тела: мелкий [radii[1]], небольшой [radii[2]], средний [radii[3]], крупный [radii[4]]; человек стоя [standing], лёжа [prone]"

/// Навык стрелка и движение цели в бросок не входят: кор `attack_mob()` считает их в поправку Бэй,
/// а бросок её не смотрит.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_roll_inputs(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/ce_test_target/mark)
	mark.forceMove(near(3, 0))
	var/list/real_zone_chances = ce_zone_miss_chances
	var/real_miss_per_tile = ce_miss_per_tile
	var/real_pass_share = ce_miss_pass_share
	ce_zone_miss_chances = real_zone_chances.Copy()
	ce_miss_per_tile = 0
	ce_miss_pass_share = 100
	for(var/level in list(SKILL_UNSKILLED, SKILL_MASTER))
		set_skills(H, list(SKILL_WEAPONS = level))
		for(var/stepped in list(FALSE, TRUE))
			// Только что шагнувшей цели бросок Бэй прибавил бы 20 к промаху, стоящей — снял бы 5.
			mark.l_move_time = stepped ? world.time : 0
			var/obj/item/projectile/shot = make_projectile()
			shot.firer = H
			shot.original = mark
			shot.no_attack_log = TRUE
			ce_zone_miss_chances[BP_CHEST] = 0
			var/hits_before = mark.ce_hits
			for(var/trial in 1 to CE_AIM_TRIALS)
				shot.attack_mob(mark, 3)
			var/sure_hits = mark.ce_hits - hits_before
			ce_zone_miss_chances[BP_CHEST] = 100
			hits_before = mark.ce_hits
			for(var/trial in 1 to CE_AIM_TRIALS)
				shot.attack_mob(mark, 3)
			var/sure_misses = CE_AIM_TRIALS - (mark.ce_hits - hits_before)
			if(sure_hits != CE_AIM_TRIALS || sure_misses != CE_AIM_TRIALS)
				failures += "бросок, навык [level], цель шагнула — [stepped]: из [CE_AIM_TRIALS] бросков без промаха попало [sure_hits], из [CE_AIM_TRIALS] без попаданий мимо прошло [sure_misses]"
	ce_zone_miss_chances = real_zone_chances
	ce_miss_per_tile = real_miss_per_tile
	ce_miss_pass_share = real_pass_share
	mark.l_move_time = 0
	set_skills(H, list())

/// Пролёт мимо тела: урон с расстоянием не снимается, моб запоминается, а сообщение — только у
/// близкого пролёта небесшумного снаряда.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_flyby(list/failures, mob/living/carbon/human/ce_test_target/mark)
	var/turf/start = spot(-2, 0)
	var/turf/beyond = spot(2, 0)
	mark.forceMove(spot(0, 0))
	var/obj/ce_test_listener/listener = put(0, 2, /obj/ce_test_listener)
	// list(подпись, сдвиг тела от линии, бесшумный снаряд, сообщений о пролёте)
	var/list/cases = list(
		list("близкий", 14, FALSE, 1),
		list("близкий бесшумный", 14, TRUE, 0),
		list("дальний", 18, FALSE, 0)
	)
	for(var/list/entry as anything in cases)
		mark.pixel_y = mark.default_pixel_y + entry[2]
		listener.heard.Cut()
		var/hits_before = mark.ce_hits
		var/obj/item/projectile/shot = shoot(beyond, start)
		shot.silenced = entry[3]
		// Урон с расстоянием снял бы половину уже с первой клетки.
		shot.damage_falloff = TRUE
		shot.damage_falloff_list = list(list(1, 0.5))
		var/damage = shot.damage
		fly_steps(shot, 3)
		var/heard_misses = listener.count_misses()
		if(QDELETED(shot) || mark.ce_hits != hits_before || shot.damage != damage || !(mark in shot.permutated) || shot.ce_last_missed != mark)
			failures += "пролёт, [entry[1]]: пуля цела — [!QDELETED(shot)], попаданий [mark.ce_hits - hits_before], урон пули [shot.damage] из [damage], моб запомнен — [mark in shot.permutated], промах записан — [shot.ce_last_missed == mark]"
		if(heard_misses != entry[4])
			failures += "пролёт, [entry[1]]: сообщений о пролёте [heard_misses], ожидалось [entry[4]]"

	// Окно на северном краю клетки моба, вдоль полёта: пуля, прошедшая мимо тела, его не задевает.
	// Столкновение с мобом повторяет BYOND — уже с любым плотным предметом в клетке.
	var/obj/structure/window/pane = put(0, 0, /obj/structure/window/reinforced)
	pane.set_dir(NORTH)
	mark.pixel_y = mark.default_pixel_y + 14
	var/obj/item/projectile/beside = shoot(beyond, start)
	fly_steps(beside, 3)
	if(QDELETED(beside) || pane.get_current_health() != pane.get_max_health())
		failures += "пролёт: пуля мимо тела у окна вдоль полёта — цела — [!QDELETED(beside)], прочность окна [pane.get_current_health()] из [pane.get_max_health()]"
	qdel(pane)
	// Окно на восточном краю, поперёк полёта, пулю останавливает: выйти из клетки она может только
	// сквозь него.
	var/obj/structure/window/across = put(0, 0, /obj/structure/window/reinforced)
	across.set_dir(EAST)
	var/obj/item/projectile/stopped = shoot(beyond, start)
	fly_steps(stopped, 3)
	if(!QDELETED(stopped) || across.get_current_health() >= across.get_max_health())
		failures += "пролёт: пуля мимо тела у окна поперёк полёта — цела — [!QDELETED(stopped)], прочность окна [across.get_current_health()] из [across.get_max_health()]"
	qdel(across)

	// Двое в одной клетке: клетка сталкивает пулю только с первым, второго она встречает сама.
	var/mob/living/carbon/human/second = make_human()
	if(second)
		second.forceMove(spot(0, 0))
		var/second_damage = second.getBruteLoss()
		var/shared_before = mark.ce_hits
		var/obj/item/projectile/shared = shoot(beyond, start)
		fly_steps(shared, 3)
		if(!QDELETED(shared) || mark.ce_hits != shared_before || second.getBruteLoss() <= second_damage)
			failures += "пролёт: двое в клетке — пуля мимо первого цела — [!QDELETED(shared)], попаданий в первого [mark.ce_hits - shared_before], урон второму [second.getBruteLoss() - second_damage]"
		second.forceMove(spot(-2, -2))

	// Попавшей пуле урон с расстоянием снимается: проверка выше не пустая.
	mark.pixel_y = mark.default_pixel_y
	var/obj/item/projectile/struck = shoot(mark, start)
	struck.damage_falloff = TRUE
	struck.damage_falloff_list = list(list(1, 0.5))
	var/full_damage = struck.damage
	var/struck_before = mark.ce_hits
	fly_steps(struck, 3)
	if(mark.ce_hits != struck_before + 1 || struck.damage > full_damage * 0.5 + CE_AIM_TOLERANCE)
		failures += "пролёт: попавшая пуля — попаданий [mark.ce_hits - struck_before], урон [struck.damage] из [full_damage], ожидалось не больше половины"
	mark.forceMove(spot(-2, -2))
	reset_arena()

/// Пуля, летящая над лежащим в цель за ним, его не задевает — ни на прямой, ни в срезанном углу.
/// Стоящего в том же углу, сдвинутого к линии, она встречает.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_overflight(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/ce_test_target/mark)
	// Лежащий повёрнут, как в `update_icons()`, и неплотен.
	H.lying = TRUE
	H.set_density(FALSE)
	H.transform = matrix().Update(rotation = 90)
	H.forceMove(spot(0, 0))
	mark.forceMove(spot(2, 0))
	var/damage_before = H.getBruteLoss()
	var/hits_before = mark.ce_hits
	var/obj/item/projectile/over = shoot(mark, spot(-2, 0))
	fly_steps(over, 4)
	if(H.getBruteLoss() != damage_before || mark.ce_hits != hits_before + 1)
		failures += "лежащие: пуля над лежащим в цель за ним — урон лежащему [H.getBruteLoss() - damage_before], попаданий в цель [mark.ce_hits - hits_before]"

	// Линия в цель 2,1 срезает угол клетки 1,0 и идёт в 9 пикселях от середины тела, сдвинутого к
	// ней на 6: через тело.
	H.forceMove(spot(1, 0))
	H.pixel_y = H.default_pixel_y + 6
	mark.forceMove(spot(2, 1))
	hits_before = mark.ce_hits
	var/obj/item/projectile/corner = shoot(mark, center)
	var/crosses = corner.ce_crosses_body(H)
	fly_steps(corner, 2)
	if(!crosses || H.getBruteLoss() != damage_before || mark.ce_hits != hits_before + 1)
		failures += "лежащие: пуля над лежащим в срезанном углу — линия через его тело — [crosses], урон лежащему [H.getBruteLoss() - damage_before], попаданий в цель [mark.ce_hits - hits_before]"

	H.lying = FALSE
	H.set_density(TRUE)
	H.transform = matrix()
	hits_before = mark.ce_hits
	var/obj/item/projectile/blocked = shoot(mark, center)
	fly_steps(blocked, 2)
	if(H.getBruteLoss() <= damage_before || mark.ce_hits != hits_before)
		failures += "срезанный угол: стоящего, сдвинутого к линии, пуля не встретила — урон ему [H.getBruteLoss() - damage_before], попаданий в цель за ним [mark.ce_hits - hits_before]"
	H.pixel_y = H.default_pixel_y
	H.forceMove(spot(-2, -2))
	mark.forceMove(spot(-2, -2))
	reset_arena()

/// Дробь: облако — один снаряд. Пролёт мимо тела у него один, а бросок — на каждую дробину.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_pellets(list/failures, mob/living/carbon/human/ce_test_target/mark)
	var/turf/start = spot(-2, 0)
	var/cloud_type = /obj/item/projectile/bullet/pellet/shotgun
	mark.forceMove(spot(0, 0))
	var/obj/ce_test_listener/listener = put(0, 2, /obj/ce_test_listener)
	var/list/staged_zone_chances = ce_zone_miss_chances
	var/staged_pass_share = ce_miss_pass_share
	ce_miss_pass_share = 100

	// Бросок без промаха: попадает каждая дробина, и облако кончается.
	ce_zone_miss_chances = flat_zone_chances(0)
	var/obj/item/projectile/bullet/pellet/cloud = shoot(mark, start, null, cloud_type)
	var/total = cloud.get_pellets(1)
	var/hits_before = mark.ce_hits
	fly_steps(cloud, 2)
	if(total < 2 || mark.ce_hits - hits_before != total || !QDELETED(cloud))
		failures += "дробь: при броске без промаха из [total] дробин попало [mark.ce_hits - hits_before], облако цело — [!QDELETED(cloud)]"

	// Бросок без попаданий: дробины целы, облако летит дальше.
	ce_zone_miss_chances = flat_zone_chances(100)
	cloud = shoot(mark, start, null, cloud_type)
	hits_before = mark.ce_hits
	fly_steps(cloud, 2)
	if(mark.ce_hits != hits_before || QDELETED(cloud) || cloud.pellets != initial(cloud.pellets))
		failures += "дробь: при броске без попаданий попало [mark.ce_hits - hits_before], облако цело — [!QDELETED(cloud)], дробин осталось [cloud.pellets]"
	// Облако, оставшееся в клетке мишени, — плотный предмет: о него разбилось бы следующее.
	spend(cloud)

	// Каждая дробина бросает сама: с шансом пополам облако попадает частью дробин, а всего — около
	// половины. Треть и две трети — это пять стандартных отклонений от половины.
	ce_zone_miss_chances = flat_zone_chances(50)
	var/mixed = 0
	var/hit_total = 0
	for(var/trial in 1 to CE_AIM_TRIALS)
		cloud = shoot(mark, start, null, cloud_type)
		hits_before = mark.ce_hits
		fly_steps(cloud, 2)
		var/hits = mark.ce_hits - hits_before
		hit_total += hits
		if(hits > 0 && hits < total)
			mixed++
		spend(cloud)
	var/rolled = total * CE_AIM_TRIALS
	if(!mixed || hit_total < rolled / 3 || hit_total > rolled * 2 / 3)
		failures += "дробь: с шансом пополам из [rolled] дробин попало [hit_total], облаков с частью попаданий — [mixed] из [CE_AIM_TRIALS]"

	// Мимо тела: круг проверяет каждая дробина, а пролёт один — дробины целы, сообщение одно.
	ce_zone_miss_chances = flat_zone_chances(0)
	mark.pixel_y = mark.default_pixel_y + 14
	listener.heard.Cut()
	cloud = shoot(spot(2, 0), start, null, cloud_type)
	hits_before = mark.ce_hits
	fly_steps(cloud, 3)
	var/heard_misses = listener.count_misses()
	if(mark.ce_hits != hits_before || QDELETED(cloud) || cloud.pellets != initial(cloud.pellets) || cloud.ce_last_missed != mark || heard_misses != 1)
		failures += "дробь мимо тела: попало [mark.ce_hits - hits_before], облако цело — [!QDELETED(cloud)], дробин осталось [cloud.pellets], промах записан — [cloud.ce_last_missed == mark], сообщений о пролёте [heard_misses], ожидалось одно"
	mark.pixel_y = mark.default_pixel_y

	ce_zone_miss_chances = staged_zone_chances
	ce_miss_pass_share = staged_pass_share
	mark.forceMove(spot(-2, -2))
	reset_arena()

/**
 * Дорожка для дальнего выстрела: ряд пустого космоса через середину площадки, с запада на восток,
 * не длиннее `wanted` клеток. Клетки вне площадки застилаются полом; убирает его `lift_lane()`.
 */
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/lay_lane(wanted)
	RETURN_TYPE(/list)
	var/west = center.x - CE_ARENA_RADIUS
	var/east = center.x + CE_ARENA_RADIUS
	while(east - west + 1 < wanted && is_free_space(locate(east + 1, center.y, center.z)))
		east++
	while(east - west + 1 < wanted && is_free_space(locate(west - 1, center.y, center.z)))
		west--
	. = list()
	for(var/x in west to east)
		var/turf/place = locate(x, center.y, center.z)
		if(istype(place, /turf/space))
			place.ChangeTurf(/turf/simulated/floor/airless)
			lane_paved += locate(x, center.y, center.z)
		. += locate(x, center.y, center.z)

/// Возвращает космос на место дорожки.
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/lift_lane()
	for(var/turf/place as anything in lane_paved)
		place.ChangeTurf(/turf/space)
	lane_paved.Cut()

/**
 * Дальность: с 20 и 30 клеток выстрел без разброса доходит до тела, а бросок там провален наверняка
 * — и всё же попадает на долю случайной зоны. С долей «мимо» 0 попадает каждый выстрел, с долей 100
 * — ни один. Броски здесь настоящие: `real_miss_per_tile` за клетку и таблица зон `real_zone_chances`.
 */
/datum/unit_test/combat_extended/pixel_aim/physical_hits/proc/check_long_range_flight(list/failures, mob/living/carbon/human/H, mob/living/carbon/human/ce_test_target/mark, real_miss_per_tile, list/real_zone_chances)
	var/list/lane = lay_lane(31)
	var/reach = length(lane) - 1
	var/list/distances = list()
	for(var/distance in list(20, 30))
		if(distance <= reach)
			distances += distance
	if(!length(distances))
		distances += reach
	var/staged_miss_per_tile = ce_miss_per_tile
	var/list/staged_zone_chances = ce_zone_miss_chances
	var/staged_pass_share = ce_miss_pass_share
	ce_miss_per_tile = real_miss_per_tile
	ce_zone_miss_chances = real_zone_chances
	set_skills(H, list(SKILL_WEAPONS = SKILL_TRAINED))
	var/turf/start = lane[1]
	var/trials = 5
	for(var/distance in distances)
		mark.forceMove(lane[1 + distance])
		var/obj/item/projectile/probe = shoot(mark, start, H)
		var/sure_failure = probe.ce_get_miss_chance(BP_CHEST, distance) >= 100
		if(distance >= 20 && !sure_failure)
			failures += "дальность, [distance] клеток: шанс провала [probe.ce_get_miss_chance(BP_CHEST, distance)], ожидался провал наверняка"
		// list(доля «мимо», сколько выстрелов попадает)
		for(var/list/entry as anything in list(list(0, trials), list(100, 0)))
			if(entry[1] && !sure_failure)
				continue
			ce_miss_pass_share = entry[1]
			var/hits_before = mark.ce_hits
			var/arrived = 0
			var/steady = TRUE
			for(var/trial in 1 to trials)
				var/obj/item/projectile/shot = shoot(mark, start, H)
				if(shot.ce_get_spread_arc() || shot.trajectory.offset_y)
					steady = FALSE
				fly_steps(shot, distance)
				if(QDELETED(shot) || (mark in shot.permutated))
					arrived++
				spend(shot)
			var/hits = mark.ce_hits - hits_before
			if(!steady || arrived != trials || hits != entry[2])
				failures += "дальность, [distance] клеток, доля «мимо» [entry[1]]: из [trials] выстрелов до цели дошло [arrived], попало [hits], ожидалось [entry[2]]; без разброса — [steady]"
	ce_miss_per_tile = staged_miss_per_tile
	ce_zone_miss_chances = staged_zone_chances
	ce_miss_pass_share = staged_pass_share
	set_skills(H, list())
	mark.forceMove(spot(-2, -2))
	reset_arena()
	lift_lane()

#undef CE_AIM_TOLERANCE
#undef CE_AIM_DIRECTION_TOLERANCE
#undef CE_AIM_TRIALS
#undef CE_AIM_BIG_ICON


/*
	Уколы в броню (`injections.dm`). Правило проверяется трижды: чистым запросом слоя, который
	останавливает укол, через `can_inject()` с объявленным уколом и настоящими процедурами шприца,
	гипоспрея и гипоспрея борга — так проверяются оверрайды, которые укол объявляют, и правка кор
	`syringestab()`.

	Задержки инъекторов обнулены: человек без клиента засыпает на первом же тике `Life()`, и
	`do_after()` у него срывается. Попал ли удар шприцем, видно по крови на шприце: её оставляет
	только удар, дошедший до тела.
*/
/datum/unit_test/combat_extended/injections
	name = "CE: Уколы в броню"
	/// Кто колет.
	var/mob/living/carbon/human/medic
	/// Шприц и гипоспрей для проверок без самого укола.
	var/obj/item/reagent_containers/syringe/needle
	var/obj/item/reagent_containers/hypospray/vial/jet

/datum/unit_test/combat_extended/injections/start_test()
	var/list/failures = list()
	medic = make_human()
	if(!medic)
		fail("Не удалось создать колющего.")
		return 1
	medic.zone_sel = new /obj/screen/zone_sel(null)
	spawned += medic.zone_sel
	// Без навыка шприц колет ударом и мажет мимо вены.
	set_skills(medic, list(SKILL_MEDICAL = SKILL_EXPERIENCED))
	needle = new(medic.loc)
	jet = new(medic.loc)
	spawned += needle
	spawned += jet

	check_numbers(failures)
	check_blockers(failures)
	check_can_inject(failures)
	check_dodging(failures)
	check_injectors(failures)
	check_stab(failures)

	medic.zone_sel = null
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Укол останавливает броня зоны: иглу — любая, струю — только надетая; в конечность идущего укол не попадает; игла на харме ломается о броню.")
	return 1

/// Человек в униформе с аксессуарами. null — одеть не вышло.
/datum/unit_test/combat_extended/injections/proc/make_dressed(uniform_type, list/accessory_types, mobtype = /mob/living/carbon/human)
	var/mob/living/carbon/human/H = make_human(null, mobtype)
	if(!H)
		return null
	var/obj/item/clothing/under/uniform = new uniform_type(H.loc)
	spawned += uniform
	for(var/accessory_type in accessory_types)
		uniform.attach_accessory(null, new accessory_type(uniform))
	H.equip_to_slot_or_del(uniform, slot_w_uniform)
	return H.w_uniform == uniform ? H : null

/// Ставит человека так, будто он стоит на месте дольше нужного или только что шагнул.
/datum/unit_test/combat_extended/injections/proc/set_moving(mob/living/carbon/human/H, moving)
	H.l_move_time = moving ? world.time : world.time - ce_injection_still_time

/// Сколько реагента `reagent_type` у человека в крови.
/datum/unit_test/combat_extended/injections/proc/blood_amount(mob/living/carbon/human/H, reagent_type)
	return H.reagents.get_reagent_amount(reagent_type)

/// Числа инъекторов: каждый шприц и гипоспрей билда колет по правилам мода, струёй — только гипоспреи.
/datum/unit_test/combat_extended/injections/proc/check_numbers(list/failures)
	var/list/families = list(
		/obj/item/reagent_containers/syringe = FALSE,
		/obj/item/reagent_containers/hypospray = TRUE,
		/obj/item/reagent_containers/borghypo = TRUE
	)
	for(var/family in families)
		for(var/path in typesof(family))
			var/obj/item/injector = path
			if(isnull(initial(injector.ce_injection_pen)))
				failures += "числа: у [path] нет пробития укола"
			if(initial(injector.ce_injection_jet) != families[family])
				failures += "числа: [path] колет струёй — [initial(injector.ce_injection_jet)], ожидалось [families[family]]"

/// Слой, который останавливает укол, чистым запросом: иглу и струю по каждой цели.
/datum/unit_test/combat_extended/injections/proc/check_blockers(list/failures)
	var/mob/living/carbon/human/bare = make_human()
	var/mob/living/carbon/human/guarded = make_human(list(/obj/item/clothing/accessory/arm_guards))
	var/mob/living/carbon/human/officer = make_dressed(/obj/item/clothing/under/rank/security)
	var/mob/living/carbon/human/vested = make_dressed(/obj/item/clothing/under/color/grey, list(/obj/item/clothing/accessory/armor_plate/sneaky))
	var/mob/living/carbon/human/padded = make_dressed(/obj/item/clothing/under/rank/security)
	var/mob/living/carbon/human/serpentid = make_human(null, /mob/living/carbon/human/nabber)
	var/mob/living/carbon/human/meshed = make_human()
	if(!bare || !guarded || !officer || !vested || !padded || !serpentid || !meshed)
		failures += "слои: не удалось создать цели"
		return

	// Халат с подбоем поверх униформы охраны: два мягких слоя, каждый из которых укол проходит.
	var/obj/item/clothing/suit/storage/toggle/labcoat/coat = new(padded.loc)
	spawned += coat
	set_extension(coat, /datum/extension/armor, list(melee = ARMOR_MELEE_MINOR))
	padded.equip_to_slot_or_del(coat, slot_wear_suit)
	var/mob/living/carbon/human/coated = make_human()
	var/obj/item/clothing/suit/storage/toggle/labcoat/lone_coat = new(coated.loc)
	spawned += lone_coat
	set_extension(lone_coat, /datum/extension/armor, list(melee = ARMOR_MELEE_MINOR))
	coated.equip_to_slot_or_del(lone_coat, slot_wear_suit)
	if(padded.wear_suit != coat || coated.wear_suit != lone_coat)
		failures += "слои: надеть халат не вышло"
		return

	// Подкожная броня генокрада: жёсткая, иглу она остановила бы, не будь она под кожей.
	var/obj/item/organ/internal/augment/armor/changeling/mesh = new(meshed)
	mesh.parent_organ = BP_CHEST
	mesh.organ_tag = "[BP_CHEST]_aug_armor"
	mesh.replaced(meshed, meshed.get_organ(BP_CHEST))
	var/datum/extension/armor/mesh_armor = get_extension(mesh, /datum/extension/armor)
	if(!(mesh in meshed.internal_organs) || !mesh_armor || mesh_armor.get_armor_sharp_melee() < needle.ce_injection_pen)
		failures += "слои: подкожная броня не встала или слабее иглы — проверять нечего"
		return
	var/datum/extension/armor/hide = get_extension(serpentid, /datum/extension/armor)
	if(!hide || hide.get_armor_sharp_melee() < needle.ce_injection_pen)
		failures += "слои: естественная броня GAS слабее иглы — проверять нечего"
		return
	var/datum/extension/armor/uniform_armor = get_extension(officer.w_uniform, /datum/extension/armor)
	if(!uniform_armor || uniform_armor.get_armor_sharp_melee() <= 0)
		failures += "слои: у униформы охраны нет острой брони — проверять нечего"
		return

	// Название, цель, зона, остановлена ли игла, остановлена ли струя.
	var/list/cases = list(
		list("голая рука", bare, BP_L_ARM, FALSE, FALSE),
		list("униформа охраны", officer, BP_CHEST, FALSE, FALSE),
		list("халат с подбоем", coated, BP_CHEST, FALSE, FALSE),
		list("униформа охраны под халатом с подбоем", padded, BP_CHEST, TRUE, TRUE),
		list("скрытый жилет на униформе", vested, BP_CHEST, TRUE, TRUE),
		list("рука под наручами", guarded, BP_L_ARM, TRUE, TRUE),
		list("хитин GAS", serpentid, BP_CHEST, TRUE, FALSE),
		list("подкожная броня", meshed, BP_CHEST, FALSE, FALSE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = test_case[2]
		var/needle_stopped = !!H.ce_get_injection_blocker(test_case[3], needle)
		var/jet_stopped = !!H.ce_get_injection_blocker(test_case[3], jet)
		if(needle_stopped != test_case[4])
			failures += "слои, [test_case[1]]: игла остановлена — [needle_stopped], ожидалось [test_case[4]]"
		if(jet_stopped != test_case[5])
			failures += "слои, [test_case[1]]: струя остановлена — [jet_stopped], ожидалось [test_case[5]]"

	// Пробитие ровно в рейтинг слоя слой останавливает. Слой без острой брони — обычный халат — не
	// останавливает и укол без пробития.
	var/mob/living/carbon/human/plain = make_human()
	var/obj/item/clothing/suit/storage/toggle/labcoat/plain_coat = new(plain.loc)
	spawned += plain_coat
	plain.equip_to_slot_or_del(plain_coat, slot_wear_suit)
	var/datum/extension/armor/plain_armor = get_extension(plain_coat, /datum/extension/armor)
	if(plain.wear_suit != plain_coat || !plain_armor || plain_armor.get_armor_sharp_melee() != 0)
		failures += "слои: обычный халат не надет, без брони или с острой бронёй — проверять нечего"
		return
	var/full_pen = needle.ce_injection_pen
	needle.ce_injection_pen = uniform_armor.get_armor_sharp_melee()
	if(!officer.ce_get_injection_blocker(BP_CHEST, needle))
		failures += "слои: игла с пробитием ровно в рейтинг униформы охраны её прошла"
	needle.ce_injection_pen = 0
	if(plain.ce_get_injection_blocker(BP_CHEST, needle))
		failures += "слои: иглу без пробития остановил халат без острой брони"
	if(!officer.ce_get_injection_blocker(BP_CHEST, needle))
		failures += "слои: игла без пробития прошла униформу охраны"
	needle.ce_injection_pen = full_pen

	// Запрос не изнашивает броню и возвращает контекст зоны.
	var/obj/item/clothing/accessory/arm_guards/guards_item = locate() in guarded.wear_suit
	var/datum/extension/armor/guards = get_extension(guards_item, /datum/extension/armor)
	if(guarded.ce_get_injection_blocker(BP_L_ARM, needle) != guards)
		failures += "слои: иглу в руку под наручами останавливают не наручи"
	if(!isnull(guards.ce_health))
		failures += "слои: запрос износил наручи"
	if(GLOB.ce_hit_body_part)
		failures += "слои: после запроса остался контекст зоны"

/// Правило в `can_inject()`: действует только на объявленный укол, объявление одноразовое.
/datum/unit_test/combat_extended/injections/proc/check_can_inject(list/failures)
	var/mob/living/carbon/human/guarded = make_human(list(/obj/item/clothing/accessory/arm_guards))
	var/mob/living/carbon/human/suited = make_human()
	if(!guarded || !suited)
		failures += "can_inject: не удалось создать цели"
		return
	set_moving(guarded, FALSE)
	set_moving(suited, FALSE)

	if(guarded.can_inject(medic, BP_L_ARM) != CAN_INJECT)
		failures += "can_inject: без объявления кор версия не пускает укол в руку под наручами — проверять нечего"
		return
	needle.ce_announce_injection(guarded)
	if(guarded.can_inject(medic, BP_L_ARM))
		failures += "can_inject: объявленный укол иглой прошёл в руку под наручами"
	if(guarded.ce_injector)
		failures += "can_inject: объявление осталось после `can_inject()`"
	if(guarded.can_inject(medic, BP_L_ARM) != CAN_INJECT)
		failures += "can_inject: объявление сработало дважды"

	needle.ce_announce_injection(guarded)
	jet.ce_retract_injection(guarded)
	if(guarded.ce_injector != needle)
		failures += "can_inject: чужая вещь сняла объявление шприца"
	needle.ce_retract_injection(guarded)
	if(guarded.ce_injector)
		failures += "can_inject: шприц не снял своё объявление"

	var/obj/item/pen/pen = new(medic.loc)
	spawned += pen
	pen.ce_announce_injection(guarded)
	if(guarded.ce_injector)
		failures += "can_inject: укол объявила вещь без пробития укола"
		guarded.ce_injector = null

	// Порт скафандра ведёт под броню: с ним правило не действует.
	var/obj/item/clothing/suit/space/void/security/voidsuit = new(suited.loc)
	spawned += voidsuit
	suited.equip_to_slot_or_del(voidsuit, slot_wear_suit)
	if(suited.wear_suit != voidsuit || !suited.ce_get_injection_blocker(BP_CHEST, needle))
		failures += "can_inject: войдсьют не надет или иглу не останавливает — проверять нечего"
		return
	needle.ce_announce_injection(suited)
	var/allowed = suited.can_inject(medic, BP_CHEST)
	if(allowed != INJECTION_PORT)
		failures += "can_inject: объявленный укол в грудь войдсьюта — [allowed], ожидался порт ([INJECTION_PORT])"

/// Движение цели: в конечность идущего не попасть, в корпус — можно; себя и лежащего это не касается.
/datum/unit_test/combat_extended/injections/proc/check_dodging(list/failures)
	var/mob/living/carbon/human/runner = make_human()
	if(!runner)
		failures += "движение: не удалось создать цель"
		return
	// Название, двигалась ли цель, кто колет, зона, лежит ли цель, прошёл ли укол.
	var/list/cases = list(
		list("идущему в руку", TRUE, medic, BP_L_ARM, FALSE, FALSE),
		list("идущему в стопу", TRUE, medic, BP_R_FOOT, FALSE, FALSE),
		list("идущему в грудь", TRUE, medic, BP_CHEST, FALSE, TRUE),
		list("идущему в голову", TRUE, medic, BP_HEAD, FALSE, TRUE),
		list("стоящему в руку", FALSE, medic, BP_L_ARM, FALSE, TRUE),
		list("себе в руку на ходу", TRUE, runner, BP_L_ARM, FALSE, TRUE),
		list("лежащему в руку", TRUE, medic, BP_L_ARM, TRUE, TRUE)
	)
	for(var/list/test_case as anything in cases)
		set_moving(runner, test_case[2])
		runner.lying = test_case[5]
		needle.ce_announce_injection(runner)
		var/allowed = !!runner.can_inject(test_case[3], test_case[4])
		if(allowed != test_case[6])
			failures += "движение, [test_case[1]]: укол прошёл — [allowed], ожидалось [test_case[6]]"
	runner.lying = FALSE

/// Настоящие процедуры инъекторов: в грудь под скрытым жилетом не вводят ничего, в голую — вводят.
/datum/unit_test/combat_extended/injections/proc/check_injectors(list/failures)
	var/mob/living/carbon/human/bare = make_human()
	var/mob/living/carbon/human/vested = make_dressed(/obj/item/clothing/under/color/grey, list(/obj/item/clothing/accessory/armor_plate/sneaky))
	if(!bare || !vested)
		failures += "инъекторы: не удалось создать цели"
		return
	set_moving(bare, FALSE)
	set_moving(vested, FALSE)
	medic.zone_sel.selecting = BP_CHEST
	if(vested.can_inject(medic, BP_CHEST) != CAN_INJECT)
		failures += "инъекторы: кор версия не пускает укол в грудь под скрытым жилетом — проверять нечего"
		return

	var/obj/item/reagent_containers/syringe/syringe = new(medic.loc)
	var/obj/item/reagent_containers/syringe/drawer = new(medic.loc)
	var/obj/item/reagent_containers/hypospray/vial/hypospray = new(medic.loc)
	var/obj/item/reagent_containers/borghypo/borghypo = new(medic.loc)
	spawned += syringe
	spawned += drawer
	spawned += hypospray
	spawned += borghypo
	syringe.time = 0
	drawer.time = 0
	hypospray.time = 0
	var/borg_reagent = borghypo.reagent_ids[borghypo.mode]

	for(var/mob/living/carbon/human/H as anything in list(vested, bare))
		var/expected = H == bare
		var/label = expected ? "в голую грудь" : "в грудь под скрытым жилетом"

		syringe.reagents.add_reagent(/datum/reagent/water, 5)
		var/before = blood_amount(H, /datum/reagent/water)
		syringe.injectMob(H, medic)
		if((blood_amount(H, /datum/reagent/water) > before) != expected)
			failures += "инъекторы, шприц [label]: ввёл — [!expected], ожидалось [expected]"
		syringe.reagents.clear_reagents()

		drawer.drawReagents(H, medic)
		if(drawer.reagents.has_reagent(/datum/reagent/blood) != expected)
			failures += "инъекторы, забор крови [label]: кровь взята — [!expected], ожидалось [expected]"
		drawer.reagents.clear_reagents()

		hypospray.reagents.add_reagent(/datum/reagent/water, 5)
		before = blood_amount(H, /datum/reagent/water)
		hypospray.inject_mob(H, medic)
		if((blood_amount(H, /datum/reagent/water) > before) != expected)
			failures += "инъекторы, гипоспрей [label]: ввёл — [!expected], ожидалось [expected]"
		hypospray.reagents.clear_reagents()

		before = blood_amount(H, borg_reagent)
		borghypo.use_before(H, medic)
		if((blood_amount(H, borg_reagent) > before) != expected)
			failures += "инъекторы, гипоспрей борга [label]: ввёл — [!expected], ожидалось [expected]"

		if(H.ce_injector)
			failures += "инъекторы, [label]: после уколов осталось объявление"
			H.ce_injector = null

/// Удар шприцем на намерении вреда. Отдаёт шприц после удара.
/datum/unit_test/combat_extended/injections/proc/stab(mob/living/carbon/human/H, zone)
	RETURN_TYPE(/obj/item/reagent_containers/syringe)
	var/obj/item/reagent_containers/syringe/syringe = new(medic.loc)
	spawned += syringe
	syringe.reagents.add_reagent(/datum/reagent/water, syringe.volume)
	medic.zone_sel.selecting = zone
	syringe.syringestab(H, medic)
	return syringe

/// Удар шприцем: по броне игла ломается и не колет, по конечности идущего удар мажет, иначе колет.
/datum/unit_test/combat_extended/injections/proc/check_stab(list/failures)
	var/mob/living/carbon/human/bare = make_human()
	var/mob/living/carbon/human/guarded = make_human(list(/obj/item/clothing/accessory/arm_guards))
	var/mob/living/carbon/human/officer = make_dressed(/obj/item/clothing/under/rank/security)
	var/mob/living/carbon/human/serpentid = make_human(null, /mob/living/carbon/human/nabber)
	if(!bare || !guarded || !officer || !serpentid)
		failures += "удар: не удалось создать цели"
		return
	// Название, цель, двигалась ли она, зона, попал ли удар, сломана ли игла.
	var/list/cases = list(
		list("стоящему в голую руку", bare, FALSE, BP_L_ARM, TRUE, TRUE),
		list("идущему в голую руку", bare, TRUE, BP_R_ARM, FALSE, FALSE),
		list("идущему в голую грудь", bare, TRUE, BP_CHEST, TRUE, TRUE),
		list("в руку под наручами", guarded, FALSE, BP_L_ARM, FALSE, TRUE),
		list("в хитин GAS", serpentid, FALSE, BP_CHEST, FALSE, TRUE)
	)
	for(var/list/test_case as anything in cases)
		var/mob/living/carbon/human/H = test_case[2]
		set_moving(H, test_case[3])
		var/obj/item/reagent_containers/syringe/syringe = stab(H, test_case[4])
		if(QDELETED(syringe))
			failures += "удар [test_case[1]]: шприц пропал"
			continue
		var/landed = length(syringe.blood_DNA) > 0
		var/broken = syringe.mode == SYRINGE_BROKEN
		if(landed != test_case[5] || broken != test_case[6])
			failures += "удар [test_case[1]]: попал — [landed], игла сломана — [broken]; ожидалось [test_case[5]] и [test_case[6]]"
		if(!landed && syringe.reagents.total_volume != syringe.volume)
			failures += "удар [test_case[1]]: сорванный удар ввёл [syringe.volume - syringe.reagents.total_volume] единиц"

	// Броня, которую игла проходит, удар не срывает никогда: броска Bay больше нет.
	set_moving(officer, FALSE)
	var/stabs = 10
	var/landed_stabs = 0
	for(var/i in 1 to stabs)
		var/obj/item/reagent_containers/syringe/syringe = stab(officer, BP_CHEST)
		if(!QDELETED(syringe) && length(syringe.blood_DNA))
			landed_stabs++
	if(landed_stabs != stabs)
		failures += "удар через униформу охраны: попало [landed_stabs] из [stabs]"


/*
	Толчок вида от выстрела (`view_kick.dm`). Сколько оружие толкает вид и куда, проверяется
	числами: длина по `screen_shake` и по штрафу за одну руку, хват двумя руками против одной,
	направление от цели, выстрел в свою клетку, орудие меха. Числа — от настроек, а не свои.

	Клиента у тестового человека нет, и толкать ему нечего. Поэтому цепочка анимации проигрывается
	на предмете со своим сдвигом: после неё сдвиг должен остаться прежним. А что кор
	`handle_post_fire()` зовёт толчок, видно по ружью, которое эти вызовы считает.
*/
/datum/unit_test/combat_extended/view_kick
	name = "CE: Толчок вида от выстрела"
	/// Стрелок с ружьём в активной руке, вторая рука пуста.
	var/mob/living/carbon/human/shooter
	var/obj/item/gun/energy/laser/gun

/datum/unit_test/combat_extended/view_kick/start_test()
	var/list/failures = list()
	shooter = make_human()
	if(!shooter)
		fail("Не удалось создать стрелка.")
		return 1
	gun = new(shooter.loc)
	spawned += gun
	if(!shooter.put_in_active_hand(gun))
		cleanup()
		fail("Не удалось дать стрелку ружьё.")
		return 1

	check_reach(failures)
	check_direction(failures)
	check_mech_gun(failures)
	check_animation(failures)
	check_hook(failures)

	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Выстрел толкает вид от цели на пиксели по `screen_shake` и штрафу оружия за одну руку, без хвата двумя руками — ещё сильнее; орудие меха не толкает; после толчка вид на прежнем месте.")
	return 1

/// Длины толчка расходятся: дробные настройки не обязаны сходиться до последнего знака.
/datum/unit_test/combat_extended/view_kick/proc/differs(reach, expected)
	return abs(reach - expected) > 0.01

/// Длина толчка: по `screen_shake` и по штрафу за одну руку, с двух рук и с одной.
/datum/unit_test/combat_extended/view_kick/proc/check_reach(list/failures)
	var/point = ce_view_kick_px_per_point
	var/doubling = ce_view_kick_penalty_divisor
	gun.one_hand_penalty = doubling
	gun.screen_shake = 0
	if(gun.ce_get_view_kick_reach(shooter) != 0 || !isnull(gun.ce_get_view_kick(shooter, shooter)))
		failures += "ружьё без `screen_shake` толкает вид"
	if(!gun.ce_kick_view(shooter, shooter))
		failures += "толчок ружья без `screen_shake` не встал на место тряски"

	// Хват двумя руками: ружьё в активной руке, вторая пуста.
	if(!gun.ce_is_braced(shooter))
		failures += "ружьё в одной руке при пустой второй не считается хватом двумя руками"
	gun.one_hand_penalty = 0
	gun.screen_shake = 2
	var/heavy = gun.ce_get_view_kick_reach(shooter)
	if(differs(heavy, 3 * point))
		failures += "две руки, без штрафа, `screen_shake` 2: толчок [heavy], ожидалось [3 * point]"
	gun.screen_shake = 1
	var/light = gun.ce_get_view_kick_reach(shooter)
	if(differs(light, 2 * point))
		failures += "две руки, без штрафа, `screen_shake` 1: толчок [light], ожидалось [2 * point]"
	gun.one_hand_penalty = null
	var/unset = gun.ce_get_view_kick_reach(shooter)
	if(differs(unset, light))
		failures += "две руки, штраф не задан: толчок [unset], ожидалось как без штрафа — [light]"
	gun.one_hand_penalty = doubling / 2
	var/medium = gun.ce_get_view_kick_reach(shooter)
	if(differs(medium, 1.5 * light))
		failures += "две руки, штраф в половину делителя: толчок [medium], ожидалось [1.5 * light]"
	gun.one_hand_penalty = doubling
	var/braced = gun.ce_get_view_kick_reach(shooter)
	if(differs(braced, 2 * light))
		failures += "две руки, штраф равен делителю: толчок [braced], ожидалось вдвое больше, чем без штрафа, — [2 * light]"

	// Вторая рука занята: хвата двумя руками нет, и штраф считается несколько раз.
	var/obj/item/pen/pen = new(shooter.loc)
	spawned += pen
	if(!shooter.put_in_inactive_hand(pen))
		failures += "не удалось занять вторую руку стрелка"
		return
	if(gun.ce_is_braced(shooter))
		failures += "ружьё при занятой второй руке считается хватом двумя руками"
	var/one_handed = gun.ce_get_view_kick_reach(shooter)
	var/expected = (1 + ce_view_kick_one_hand_penalty_mult) * light
	if(differs(one_handed, expected) || one_handed <= braced)
		failures += "одна рука, штраф равен делителю: толчок [one_handed], ожидалось [expected] — больше, чем с двух рук ([braced])"
	for(var/no_penalty in list(0, null))
		gun.one_hand_penalty = no_penalty
		var/unpunished = gun.ce_get_view_kick_reach(shooter)
		if(differs(unpunished, light))
			failures += "одна рука, штраф [isnull(no_penalty) ? "не задан" : "ноль"]: толчок [unpunished], ожидалось как с двух рук — [light]"
	shooter.drop_from_inventory(pen)

/// Направление толчка: от цели, по каждой оси отдельно. Сторона — та, с которой у карты есть клетка.
/datum/unit_test/combat_extended/view_kick/proc/check_direction(list/failures)
	gun.screen_shake = 1
	gun.one_hand_penalty = 0
	var/reach = gun.ce_get_view_kick_reach(shooter)
	var/turf/here = get_turf(shooter)
	var/side = here.x < world.maxx ? 1 : -1
	var/rise = here.y < world.maxy ? 1 : -1

	var/list/sideways = gun.ce_get_view_kick(shooter, locate(here.x + side, here.y, here.z))
	if(!sideways || abs(sideways[1] + side * reach) > 0.01 || abs(sideways[2]) > 0.01)
		failures += "цель сбоку ([side]): толчок [json_encode(sideways)], ожидалось [-side * reach] по x и ноль по y"
	var/list/upward = gun.ce_get_view_kick(shooter, locate(here.x, here.y + rise, here.z))
	if(!upward || abs(upward[2] + rise * reach) > 0.01 || abs(upward[1]) > 0.01)
		failures += "цель по вертикали ([rise]): толчок [json_encode(upward)], ожидалось [-rise * reach] по y и ноль по x"
	var/list/diagonal = gun.ce_get_view_kick(shooter, locate(here.x + side, here.y + rise, here.z))
	var/diagonal_reach = diagonal ? sqrt(diagonal[1] ** 2 + diagonal[2] ** 2) : 0
	if(!diagonal || abs(diagonal_reach - reach) > 0.01 || diagonal[1] * side >= 0 || diagonal[2] * rise >= 0)
		failures += "цель по диагонали: толчок [json_encode(diagonal)], ожидалась длина [reach] от цели по обеим осям"

	var/list/own_turf = gun.ce_get_view_kick(shooter, here)
	if(!own_turf || own_turf[1] != 0 || own_turf[2] != 0)
		failures += "выстрел в свою клетку: толчок [json_encode(own_turf)], ожидался нулевой"

/// Орудие меха вид не толкает, хотя `screen_shake` у него есть, и тряску камеры не оставляет.
/datum/unit_test/combat_extended/view_kick/proc/check_mech_gun(list/failures)
	var/obj/item/mech_equipment/mounted_system/taser/ballistic/smg/mount = new(shooter.loc)
	spawned += mount
	var/obj/item/gun/mounted = mount.holding
	if(!istype(mounted) || !mounted.screen_shake)
		failures += "орудие меха: у модуля нет ружья с `screen_shake`, проверять нечего"
		return
	if(!mounted.ce_is_mech_mounted() || gun.ce_is_mech_mounted())
		failures += "орудие меха: стоит на мехе — [mounted.ce_is_mech_mounted()], ружьё в руке — [gun.ce_is_mech_mounted()]"
	if(mounted.ce_get_view_kick_reach(shooter) != 0)
		failures += "орудие меха толкает вид на [mounted.ce_get_view_kick_reach(shooter)]"
	if(!mounted.ce_kick_view(shooter, get_turf(shooter)))
		failures += "орудие меха оставляет тряску камеры Бэй"

/// Цепочка анимации возвращает сдвиг на место: и один толчок, и два подряд, как в очереди.
/datum/unit_test/combat_extended/view_kick/proc/check_animation(list/failures)
	var/obj/item/pen/viewer = new(shooter.loc)
	spawned += viewer
	viewer.pixel_x = 448
	viewer.pixel_y = -7
	ce_play_view_kick(viewer, 8, -3)
	if(viewer.pixel_x != 448 || viewer.pixel_y != -7)
		failures += "после толчка сдвиг [viewer.pixel_x],[viewer.pixel_y], ожидался прежний 448,-7"
	ce_play_view_kick(viewer, -5.5, 12)
	ce_play_view_kick(viewer, 16, 16)
	if(viewer.pixel_x != 448 || viewer.pixel_y != -7)
		failures += "после двух толчков подряд сдвиг [viewer.pixel_x],[viewer.pixel_y], ожидался прежний 448,-7"

/// Кор `handle_post_fire()` зовёт толчок на каждый выстрел оружия с `screen_shake`.
/datum/unit_test/combat_extended/view_kick/proc/check_hook(list/failures)
#ifdef UNIT_TEST
	var/obj/item/gun/energy/laser/ce_view_kick_probe/probe = new(shooter.loc)
	spawned += probe
	probe.screen_shake = 1
	probe.handle_post_fire(shooter, get_turf(shooter))
	probe.handle_post_fire(shooter, get_turf(shooter))
	if(probe.kicks != 2)
		failures += "кор `handle_post_fire()` позвал толчок [probe.kicks] раз за два выстрела"
	probe.kicks = 0
	probe.screen_shake = 0
	probe.handle_post_fire(shooter, get_turf(shooter))
	if(probe.kicks)
		failures += "кор `handle_post_fire()` зовёт толчок у ружья без `screen_shake`"
#endif

#ifdef UNIT_TEST
/// Ружьё, которое считает, сколько раз его позвали толкнуть вид.
/obj/item/gun/energy/laser/ce_view_kick_probe
	var/kicks = 0

/obj/item/gun/energy/laser/ce_view_kick_probe/ce_kick_view(mob/user, atom/target)
	kicks++
	return ..()
#endif


/*
	Разброс от отдачи (`recoil_spread.dm`). Стаки — числа на стрелке, а время им передаётся
	аргументом: ждать тесту нечего. Проверяется, сколько стаков даёт выстрел — по силе отдачи оружия и
	по навыку стрелка; как стаки убывают и где их потолок; что дуга от них ложится сверх навыка, а не
	внутрь него; и что оружие запоминает дугу в снаряде раньше, чем начисляет стаки за тот же выстрел.

	Срок стака и градусы на стак на время теста — не единицы: с единицей настройка, которую код
	забыл, давала бы те же числа.
*/
/datum/unit_test/combat_extended/recoil_spread
	name = "CE: Разброс от отдачи"
	/// Стрелок с ружьём в активной руке, вторая рука пуста.
	var/mob/living/carbon/human/shooter
	var/obj/item/gun/energy/laser/gun
	/// Время, от которого тест отсчитывает сроки стаков: своё, а не часы мира.
	var/clock = 1000

/datum/unit_test/combat_extended/recoil_spread/start_test()
	var/list/failures = list()
	shooter = make_human()
	if(!shooter)
		fail("Не удалось создать стрелка.")
		return 1
	gun = new(shooter.loc)
	spawned += gun
	if(!shooter.put_in_active_hand(gun))
		cleanup()
		fail("Не удалось дать стрелку ружьё.")
		return 1
	gun.screen_shake = 1
	gun.one_hand_penalty = 0

	var/decay_time_was = ce_recoil_spread_decay_time
	var/arc_per_stack_was = ce_recoil_spread_arc_per_stack
	ce_recoil_spread_decay_time = 4
	ce_recoil_spread_arc_per_stack = 2.5

	check_gain(failures)
	check_decay(failures)
	check_cap(failures)
	check_arc(failures)
	check_shot_order(failures)

	ce_recoil_spread_decay_time = decay_time_was
	ce_recoil_spread_arc_per_stack = arc_per_stack_was
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Выстрел с отдачей даёт стрелку стаки по силе отдачи оружия и по навыку, без отдачи — ни одного; стаки убывают по одному за срок и выше потолка не копятся; дуга от них ложится сверх навыка; оружие запоминает её в снаряде раньше, чем начисляет стаки за тот же выстрел.")
	return 1

/// Числа расходятся: дробные настройки не обязаны сходиться до последнего знака.
/datum/unit_test/combat_extended/recoil_spread/proc/differs(value, expected)
	return abs(value - expected) > 0.01

/// Ставит стрелку `stacks` стаков отдачи с отсчётом от `since`.
/datum/unit_test/combat_extended/recoil_spread/proc/give_stacks(stacks, since = clock)
	shooter.ce_recoil_stacks = stacks
	shooter.ce_recoil_stacks_time = since

/// Снаряд стрелка с разбросом оружия `dispersion` и дугой от отдачи `recoil_arc`.
/datum/unit_test/combat_extended/recoil_spread/proc/make_shot(dispersion = 0, recoil_arc = 0, projectile_type = /obj/item/projectile/bullet/pistol)
	RETURN_TYPE(/obj/item/projectile)
	var/obj/item/projectile/shot = new projectile_type(shooter.loc)
	spawned += shot
	shot.firer = shooter
	shot.dispersion = dispersion
	shot.ce_recoil_arc = recoil_arc
	return shot

/// Стаки за выстрел: сила отдачи оружия на множитель навыка стрелка; без отдачи — ни одного.
/datum/unit_test/combat_extended/recoil_spread/proc/check_gain(list/failures)
	var/skill_step = ce_recoil_spread_gain_per_skill
	var/strength = gun.ce_get_recoil_strength(shooter)
	if(strength <= 0)
		failures += "стаки за выстрел: у ружья с `screen_shake` 1 сила отдачи [strength], проверять нечего"
		return
	// list(уровень навыка оружия, ожидаемый множитель стаков)
	var/list/cases = list(
		list(SKILL_UNSKILLED, 1 + 2 * skill_step),
		list(SKILL_BASIC, 1 + skill_step),
		list(SKILL_TRAINED, 1),
		list(SKILL_EXPERIENCED, 1 - skill_step),
		list(SKILL_MASTER, 1 - 2 * skill_step)
	)
	for(var/list/entry as anything in cases)
		set_skills(shooter, list(SKILL_WEAPONS = entry[1]))
		var/gain = gun.ce_get_recoil_stack_gain(shooter)
		var/expected = strength * max(entry[2], 0)
		if(differs(gain, expected))
			failures += "стаки за выстрел: навык [entry[1]] — [gain], ожидалось [expected]"
	if(ce_get_recoil_skill_mult(SKILL_MASTER + 100) < 0)
		failures += "стаки за выстрел: множитель навыка ушёл ниже нуля — [ce_get_recoil_skill_mult(SKILL_MASTER + 100)]"

	// Стрелок без набора навыков — простой моб — получает стаки как обученный.
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_UNSKILLED))
	var/mob/living/simple_animal/passive/mouse/mouse = new(shooter.loc)
	spawned += mouse
	var/unskilled_mob = gun.ce_get_recoil_stack_gain(mouse)
	if(differs(unskilled_mob, strength))
		failures += "стаки за выстрел: простой моб — [unskilled_mob], ожидалось как у обученного — [strength]"

	// Тяжелее оружие в руках — больше стаков: со штрафом, равным делителю толчка вида, вдвое.
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	gun.one_hand_penalty = ce_view_kick_penalty_divisor
	var/heavy = gun.ce_get_recoil_stack_gain(shooter)
	if(differs(heavy, 2 * strength))
		failures += "стаки за выстрел: штраф за одну руку равен делителю — [heavy], ожидалось вдвое больше, чем без штрафа, — [2 * strength]"
	gun.one_hand_penalty = 0

	// Оружие без `screen_shake` — лучевое — стаков не даёт и не начисляет.
	gun.screen_shake = 0
	give_stacks(0)
	gun.ce_build_recoil(shooter)
	if(gun.ce_get_recoil_stack_gain(shooter) != 0 || shooter.ce_recoil_stacks != 0)
		failures += "стаки за выстрел: ружьё без `screen_shake` даёт [gun.ce_get_recoil_stack_gain(shooter)], начислило [shooter.ce_recoil_stacks]"
	gun.screen_shake = 1

	// Орудие меха стаков не даёт, хотя `screen_shake` у него есть.
	var/obj/item/mech_equipment/mounted_system/taser/ballistic/smg/mount = new(shooter.loc)
	spawned += mount
	var/obj/item/gun/mounted = mount.holding
	if(!istype(mounted) || !mounted.screen_shake)
		failures += "стаки за выстрел: у модуля меха нет ружья с `screen_shake`, проверять нечего"
	else if(mounted.ce_get_recoil_stack_gain(shooter) != 0)
		failures += "стаки за выстрел: орудие меха даёт [mounted.ce_get_recoil_stack_gain(shooter)]"

/// Стаки убывают по одному за срок, ниже нуля не уходят, и выстрел их отсчёт не сбивает.
/datum/unit_test/combat_extended/recoil_spread/proc/check_decay(list/failures)
	var/term = ce_recoil_spread_decay_time
	give_stacks(5.5)
	// list(сколько сроков прошло, сколько стаков осталось). До начала отсчёта стаков не больше
	// начисленного.
	var/list/cases = list(
		list(-3, 5.5),
		list(0, 5.5),
		list(0.5, 5.5),
		list(1, 4.5),
		list(2.5, 3.5),
		list(5, 0.5),
		list(6, 0),
		list(100, 0)
	)
	for(var/list/entry as anything in cases)
		var/stacks = shooter.ce_get_recoil_stacks(clock + entry[1] * term)
		if(differs(stacks, entry[2]))
			failures += "убывание: из 5.5 стака через [entry[1]] срока осталось [stacks], ожидалось [entry[2]]"
	if(shooter.ce_recoil_stacks != 5.5 || shooter.ce_recoil_stacks_time != clock)
		failures += "убывание: чтение стаков изменило их — [shooter.ce_recoil_stacks] с [shooter.ce_recoil_stacks_time], было 5.5 с [clock]"

	// Выстрел через полтора срока: один стак уже снят, а следующий снимется через полсрока, как и
	// без выстрела.
	shooter.ce_add_recoil_stacks(2, clock + 1.5 * term)
	var/after_shot = shooter.ce_get_recoil_stacks(clock + 1.5 * term)
	var/before_term = shooter.ce_get_recoil_stacks(clock + 1.75 * term)
	var/at_term = shooter.ce_get_recoil_stacks(clock + 2 * term)
	if(differs(after_shot, 6.5) || differs(before_term, 6.5) || differs(at_term, 5.5))
		failures += "убывание: выстрел на 2 стака через полтора срока — [after_shot], за четверть срока до второго — [before_term], на втором сроке — [at_term]; ожидалось 6.5, 6.5 и 5.5"

	// У стрелка, с которого стаки уже сошли, отсчёт начинается с выстрела.
	give_stacks(3)
	shooter.ce_add_recoil_stacks(2, clock + 10 * term)
	var/fresh = shooter.ce_get_recoil_stacks(clock + 10.75 * term)
	var/fresh_term = shooter.ce_get_recoil_stacks(clock + 11 * term)
	if(differs(fresh, 2) || differs(fresh_term, 1))
		failures += "убывание: выстрел на 2 стака после того, как прежние сошли, — через три четверти срока [fresh], через срок [fresh_term]; ожидалось 2 и 1"

	// Нулевой срок: стаки не держатся, и делить на него никто не пытается.
	give_stacks(5)
	ce_recoil_spread_decay_time = 0
	var/unkept = shooter.ce_get_recoil_stacks(clock)
	ce_recoil_spread_decay_time = term
	if(unkept != 0)
		failures += "убывание: с нулевым сроком стаков [unkept], ожидался ноль"

/// Больше потолка стаки не копятся.
/datum/unit_test/combat_extended/recoil_spread/proc/check_cap(list/failures)
	var/cap = ce_recoil_spread_max_stacks
	give_stacks(0)
	shooter.ce_add_recoil_stacks(cap - 1, clock)
	shooter.ce_add_recoil_stacks(5, clock)
	var/topped = shooter.ce_get_recoil_stacks(clock)
	shooter.ce_add_recoil_stacks(2 * cap, clock)
	var/flooded = shooter.ce_get_recoil_stacks(clock)
	if(topped != cap || flooded != cap)
		failures += "потолок: [cap - 1] стаков и ещё 5 — [topped], и ещё [2 * cap] — [flooded]; ожидался потолок [cap]"

/// Дуга от отдачи: градусы на стак, сверх разброса оружия и навыка, а не внутри него.
/datum/unit_test/combat_extended/recoil_spread/proc/check_arc(list/failures)
	var/per_stack = ce_recoil_spread_arc_per_stack
	give_stacks(7)
	var/shooter_arc = shooter.ce_get_recoil_arc(clock)
	if(differs(shooter_arc, 7 * per_stack))
		failures += "дуга: у стрелка с 7 стаками — [shooter_arc], ожидалось [7 * per_stack]"

	var/hits_were_enabled = ce_physical_hits_enabled
	var/aim_was_enabled = ce_pixel_aim_enabled
	ce_physical_hits_enabled = TRUE
	ce_pixel_aim_enabled = TRUE
	var/weapon_arc = ce_dispersion_arc_degrees
	var/level_arc = ce_skill_dispersion_arc_degrees
	var/recoil_arc = 12
	// list(подпись, уровень навыка оружия, разброс оружия, дуга от отдачи, ожидаемая дуга).
	// Навык мастера гасит разброс оружия целиком, а отдачу не трогает.
	var/list/cases = list(
		list("обученный без отдачи", SKILL_TRAINED, 1, 0, weapon_arc),
		list("обученный", SKILL_TRAINED, 1, recoil_arc, weapon_arc + recoil_arc),
		list("без навыка", SKILL_UNSKILLED, 0, recoil_arc, 2 * level_arc + recoil_arc),
		list("мастер", SKILL_MASTER, 1, recoil_arc, max(weapon_arc - 2 * level_arc, 0) + recoil_arc)
	)
	for(var/list/entry as anything in cases)
		set_skills(shooter, list(SKILL_WEAPONS = entry[2]))
		var/obj/item/projectile/shot = make_shot(entry[3], entry[4])
		var/arc = shot.ce_get_spread_arc()
		if(differs(arc, entry[5]))
			failures += "дуга, [entry[1]]: разброс оружия [entry[3]], отдача [entry[4]]° — дуга [arc], ожидалась [entry[5]]"

	// Выстрел в упор и трассировщик летят без разброса, сколько бы отдачи ни накопилось.
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	var/obj/item/projectile/point_blank = make_shot(1, recoil_arc)
	point_blank.ce_point_blank = TRUE
	if(point_blank.ce_get_spread_arc())
		failures += "дуга: у выстрела в упор с отдачей дуга [point_blank.ce_get_spread_arc()]"
	var/obj/item/projectile/tracer = make_shot(1, recoil_arc, /obj/item/projectile/test)
	if(tracer.ce_get_spread_arc())
		failures += "дуга: у трассировщика с отдачей дуга [tracer.ce_get_spread_arc()]"

	// Без физических попаданий навык в дугу не идёт, а отдача идёт.
	ce_physical_hits_enabled = FALSE
	var/obj/item/projectile/plain = make_shot(1, recoil_arc)
	var/arc_without = plain.ce_get_spread_arc()
	ce_physical_hits_enabled = hits_were_enabled
	ce_pixel_aim_enabled = aim_was_enabled
	if(differs(arc_without, weapon_arc + recoil_arc))
		failures += "дуга: без физических попаданий дуга [arc_without], ожидались разброс оружия и отдача — [weapon_arc + recoil_arc]"

/// Оружие запоминает дугу в снаряде раньше, чем начисляет стаки за тот же выстрел: первый выстрел
/// летит без отдачи, второй — с отдачей первого.
/datum/unit_test/combat_extended/recoil_spread/proc/check_shot_order(list/failures)
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	// Оружие читает часы мира, а не теста.
	give_stacks(0, world.time)
	var/gain = gun.ce_get_recoil_stack_gain(shooter)
	var/turf/target = get_turf(shooter)
	var/obj/item/projectile/first = make_shot()
	var/obj/item/projectile/second = make_shot()
	gun.process_accuracy(first, shooter, target, 1, TRUE)
	gun.handle_post_fire(shooter, target)
	gun.process_accuracy(second, shooter, target, 1, TRUE)
	gun.handle_post_fire(shooter, target)
	if(first.ce_recoil_arc != 0)
		failures += "выстрел: первый выстрел запомнил дугу от отдачи [first.ce_recoil_arc], ожидался ноль"
	var/expected_arc = gain * ce_recoil_spread_arc_per_stack
	if(differs(second.ce_recoil_arc, expected_arc))
		failures += "выстрел: второй выстрел запомнил дугу [second.ce_recoil_arc], ожидалась отдача первого — [expected_arc]"
	var/stacks = shooter.ce_get_recoil_stacks()
	var/expected_stacks = min(2 * gain, ce_recoil_spread_max_stacks)
	if(differs(stacks, expected_stacks))
		failures += "выстрел: после двух выстрелов стаков [stacks], ожидалось [expected_stacks]"


/*
	Кольцо разброса (`spread_ring.dm`). Дуга следующего выстрела сверяется с дугой настоящего снаряда
	из `process_accuracy()`, радиус кольца — с тем, как далеко от точки прицела проходит выстрел,
	отклонённый на половину дуги (`ce_aim_at()`), а курсор — по его пикселям. Клиента у теста нет:
	стрелок — подтип, которому «есть кому показывать», масштаб экрана тест ставит сам, а как кольцо
	выглядит и успевает ли за мышью, видно только в игре.
*/
/// Допуск на дробные градусы и пиксели расчёта.
#define CE_RING_TOLERANCE 0.01
/// Курсор оружия апстрима.
#define CE_RING_CROSSHAIR 'icons/obj/guns/crosshair.dmi'

/// Стрелок теста кольца разброса: клиента у него нет, а кольцо ему показывается.
/mob/living/carbon/human/ce_test_ring_viewer/ce_has_spread_ring_viewer()
	return TRUE

/datum/unit_test/combat_extended/spread_ring
	name = "CE: Кольцо разброса"
	/// Стрелок с ружьём в активной руке, вторая рука пуста.
	var/mob/living/carbon/human/ce_test_ring_viewer/shooter
	var/obj/item/gun/energy/laser/gun
	/// Клетка стрелка.
	var/turf/origin

/datum/unit_test/combat_extended/spread_ring/start_test()
	shooter = make_human(null, /mob/living/carbon/human/ce_test_ring_viewer)
	if(!shooter)
		fail("Не удалось создать стрелка.")
		return 1
	origin = get_turf(shooter)
	if(!near(3, 3) || !near(-3, -3))
		cleanup()
		fail("Вокруг клетки стрелка нет трёх клеток карты в каждую сторону.")
		return 1
	gun = new(origin)
	spawned += gun
	gun.has_safety = TRUE
	gun.safety_state = TRUE
	if(!shooter.put_in_active_hand(gun))
		cleanup()
		fail("Не удалось дать стрелку ружьё.")
		return 1
	gun.screen_shake = 1
	gun.one_hand_penalty = 0
	gun.dispersion = list(0.5)
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))

	var/aim_was_enabled = ce_pixel_aim_enabled
	var/hits_were_enabled = ce_physical_hits_enabled
	var/decay_time_was = ce_recoil_spread_decay_time
	var/arc_per_stack_was = ce_recoil_spread_arc_per_stack
	ce_pixel_aim_enabled = TRUE
	ce_physical_hits_enabled = TRUE
	ce_recoil_spread_decay_time = 4
	ce_recoil_spread_arc_per_stack = 2.5
	var/list/failures = list()

	check_next_arc(failures)
	check_world_radius(failures)
	check_screen_scale(failures)
	check_cursor(failures)
	check_hover(failures)
	check_wiring(failures)
	check_hiding(failures)

	ce_pixel_aim_enabled = aim_was_enabled
	ce_physical_hits_enabled = hits_were_enabled
	ce_recoil_spread_decay_time = decay_time_was
	ce_recoil_spread_arc_per_stack = arc_per_stack_was
	// Удаляемый стрелок роняет оружие, а оружие без предохранителя бросает осечку по навыкам, которых
	// у него уже нет (`check_accidents()`): проверка, вышедшая раньше срока, оставила бы рантайм.
	gun.safety_state = TRUE
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Кольцо разброса — расстояние, ближе которого к точке прицела проходит выстрел с дугой следующего выстрела, той же, что получает снаряд, — переведено в экранные пиксели и нарисовано вокруг горячей точки курсора с перекрестием апстрима; пересчитывается при наведении, выстреле, сходе отдачи, шаге и смене режима огня; без разброса, над тем, что рядом, и без масштаба его нет, как нет с предохранителем на виду, без оружия в руке, с выключенной настройкой и без попиксельной стрельбы.")
	return 1

/// Клетка со сдвигом от клетки стрелка.
/datum/unit_test/combat_extended/spread_ring/proc/near(offset_x, offset_y)
	RETURN_TYPE(/turf)
	return locate(origin.x + offset_x, origin.y + offset_y, origin.z)

/datum/unit_test/combat_extended/spread_ring/proc/differs(value, expected)
	return abs(value - expected) > CE_RING_TOLERANCE

/// Ставит стрелку `stacks` стаков отдачи с отсчётом от этого мгновения.
/datum/unit_test/combat_extended/spread_ring/proc/give_stacks(stacks)
	shooter.ce_recoil_stacks = stacks
	shooter.ce_recoil_stacks_time = world.time

/datum/unit_test/combat_extended/spread_ring/proc/get_ring()
	RETURN_TYPE(/datum/extension/ce_spread_ring)
	return get_extension(shooter, /datum/extension/ce_spread_ring)

/// Радиус кольца на экране при масштабе `scale` для точки прицела `aim` из нынешней клетки стрелка.
/datum/unit_test/combat_extended/spread_ring/proc/expected_radius(list/aim, scale)
	var/list/arcs = gun.ce_get_next_spread_arcs(shooter)
	var/turf/apex_turf = get_turf(shooter)
	return round(ce_get_spread_ring_world_radius(apex_turf.ce_get_tile_center(), aim, arcs[1]) * scale)

/// Сверяет радиус кольца и курсор оружия с ожидаемыми для точки прицела `aim`.
/datum/unit_test/combat_extended/spread_ring/proc/expect_ring(list/failures, label, datum/extension/ce_spread_ring/ring, list/aim, scale)
	if(!ring)
		failures += "[label]: кольца нет"
		return
	var/expected = expected_radius(aim, scale)
	if(!expected)
		failures += "[label]: ожидаемый радиус — ноль, проверять нечего"
		return
	if(ring.radius != expected)
		failures += "[label]: радиус кольца [ring.radius], ожидался [expected]"
	if(gun.get_mouse_pointer(shooter) != ce_get_spread_ring_cursor(expected, CE_RING_CROSSHAIR))
		failures += "[label]: курсор оружия — не кольцо радиуса [expected] с перекрестием"

/// Кольца нет, и курсор оружия — перекрестие апстрима.
/datum/unit_test/combat_extended/spread_ring/proc/expect_no_ring(list/failures, label, datum/extension/ce_spread_ring/ring)
	if(!ring)
		failures += "[label]: кольца нет вовсе, ожидалось нулевое"
		return
	if(ring.radius)
		failures += "[label]: радиус кольца [ring.radius], ожидался ноль"
	if(gun.get_mouse_pointer(shooter) != CE_RING_CROSSHAIR)
		failures += "[label]: курсор оружия — не перекрестие апстрима"


/// Дуга следующего выстрела — та, что получил бы снаряд: оружие, хват, навык, отдача.
/datum/unit_test/combat_extended/spread_ring/proc/check_next_arc(list/failures)
	var/weapon_arc = 0.5 * ce_dispersion_arc_degrees
	var/level_arc = ce_skill_dispersion_arc_degrees
	var/recoil_arc = 4 * ce_recoil_spread_arc_per_stack
	// list(подпись, уровень навыка оружия, стаки, ожидаемая дуга сейчас, без отдачи)
	var/list/cases = list(
		list("обученный", SKILL_TRAINED, 0, weapon_arc, weapon_arc),
		list("обученный с отдачей", SKILL_TRAINED, 4, weapon_arc + recoil_arc, weapon_arc),
		list("без навыка", SKILL_UNSKILLED, 0, weapon_arc + 2 * level_arc, weapon_arc + 2 * level_arc),
		list("мастер", SKILL_MASTER, 0, 0, 0),
		list("мастер с отдачей", SKILL_MASTER, 4, recoil_arc, 0)
	)
	for(var/list/entry as anything in cases)
		set_skills(shooter, list(SKILL_WEAPONS = entry[2]))
		give_stacks(entry[3])
		var/list/arcs = gun.ce_get_next_spread_arcs(shooter)
		if(differs(arcs[1], entry[4]) || differs(arcs[2], entry[5]))
			failures += "дуга следующего выстрела, [entry[1]]: [arcs[1]], без отдачи [arcs[2]]; ожидалось [entry[4]] и [entry[5]]"

	// Настоящий снаряд из этого оружия получает ту же дугу.
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_BASIC))
	give_stacks(3)
	var/obj/item/projectile/shot = new /obj/item/projectile/bullet/pistol(origin)
	spawned += shot
	shot.firer = shooter
	gun.process_accuracy(shot, shooter, near(3, 0), 1, shooter.can_wield_item(gun) && gun.is_held_twohanded(shooter))
	var/list/basic = gun.ce_get_next_spread_arcs(shooter)
	if(differs(basic[1], shot.ce_get_spread_arc()))
		failures += "дуга следующего выстрела: базовый навык, 3 стака — [basic[1]], а снаряд из оружия получил [shot.ce_get_spread_arc()]"

	// Тяжёлое оружие с одной руки разбрасывает сильнее, двумя руками — нет.
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	give_stacks(0)
	gun.one_hand_penalty = 6
	var/list/two_hands = gun.ce_get_next_spread_arcs(shooter)
	var/obj/item/device/flashlight/filler = new(origin)
	spawned += filler
	shooter.put_in_inactive_hand(filler)
	var/list/one_hand = gun.ce_get_next_spread_arcs(shooter)
	shooter.drop_from_inventory(filler)
	gun.one_hand_penalty = 0
	var/one_hand_expected = (0.5 + 6 * 0.5) * ce_dispersion_arc_degrees
	if(differs(two_hands[1], weapon_arc) || differs(one_hand[1], one_hand_expected))
		failures += "дуга следующего выстрела, штраф за одну руку 6: двумя руками [two_hands[1]], одной [one_hand[1]]; ожидалось [weapon_arc] и [one_hand_expected]"

	// Без физических попаданий навык в дугу не идёт, а отдача идёт.
	ce_physical_hits_enabled = FALSE
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_UNSKILLED))
	give_stacks(4)
	var/list/plain = gun.ce_get_next_spread_arcs(shooter)
	ce_physical_hits_enabled = TRUE
	if(differs(plain[1], weapon_arc + recoil_arc) || differs(plain[2], weapon_arc))
		failures += "дуга следующего выстрела без физических попаданий: [plain[1]], без отдачи [plain[2]]; ожидалось [weapon_arc + recoil_arc] и [weapon_arc]"
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	give_stacks(0)


/// Радиус кольца в мире: `d · sin(дуга / 2)`, и ровно так далеко от точки прицела проходит
/// выстрел, отклонённый на половину дуги.
/datum/unit_test/combat_extended/spread_ring/proc/check_world_radius(list/failures)
	var/list/apex = list(10 * world.icon_size, 10 * world.icon_size)
	var/distance = 5 * world.icon_size
	// list(подпись, сдвиг точки прицела по x, по y, дуга, ожидаемый радиус)
	var/list/cases = list(
		list("на восток, 60°", distance, 0, 60, distance * sin(30)),
		list("на северо-запад, 20°", -3 * world.icon_size, 4 * world.icon_size, 20, distance * sin(10)),
		list("без разброса", distance, 0, 0, 0),
		list("шире полукруга", distance, 0, 400, distance)
	)
	for(var/list/entry as anything in cases)
		var/radius = ce_get_spread_ring_world_radius(apex, list(apex[1] + entry[2], apex[2] + entry[3]), entry[4])
		if(differs(radius, entry[5]))
			failures += "радиус в мире, [entry[1]]: [radius], ожидался [entry[5]]"

	// Выстрел, отклонённый на половину дуги в любую сторону, проходит от точки прицела ровно на
	// радиусе кольца.
	var/list/aim = list(apex[1] + 3 * world.icon_size, apex[2] + world.icon_size)
	var/arc = 40
	var/radius = ce_get_spread_ring_world_radius(apex, aim, arc)
	for(var/side in list(1, -1))
		var/datum/plot_vector/vector = new
		vector.loc_x = apex[1]
		vector.loc_y = apex[2]
		vector.ce_aim_at(aim[1], aim[2], side * arc / 2)
		var/to_aim_x = aim[1] - apex[1]
		var/to_aim_y = aim[2] - apex[2]
		var/pass_distance = abs(vector.offset_x * to_aim_y - vector.offset_y * to_aim_x) / sqrt(vector.offset_x ** 2 + vector.offset_y ** 2)
		if(differs(pass_distance, radius))
			failures += "радиус в мире: выстрел, отклонённый на половину дуги в сторону [side], проходит от точки прицела на [pass_distance], а радиус кольца [radius]"


/// Масштаб экрана: размер карты на экране на клетки вида, по меньшей из сторон.
/datum/unit_test/combat_extended/spread_ring/proc/check_screen_scale(list/failures)
	// list(размер карты на экране, вид, ожидаемый масштаб)
	var/list/cases = list(
		list("1313x1037", "19x15", min(1313 / (19 * world.icon_size), 1037 / (15 * world.icon_size))),
		list("640x480", "15x15", 1),
		list("960x480", 7, 1)
	)
	for(var/list/entry as anything in cases)
		var/scale = ce_get_screen_scale(entry[1], entry[2])
		if(isnull(scale) || differs(scale, entry[3]))
			failures += "масштаб: карта [entry[1]], вид [entry[2]] — [scale], ожидался [entry[3]]"
	for(var/bad in list("", "0x0", "abc"))
		if(!isnull(ce_get_screen_scale(bad, "19x15")))
			failures += "масштаб: из размера карты «[bad]» вышел масштаб [ce_get_screen_scale(bad, "19x15")]"


/**
 * Что не так с кольцом радиуса `radius` на строке пикселей над серединой курсора `cursor`, или null.
 * Правее перекрестия апстрима — его плечо доходит до 15 пикселей от середины — на строке должны
 * быть белый пиксель кольца на радиусе, чёрный пиксель обводки сразу за ним и больше ничего. Кольцо
 * внутри перекрестия так не проверить: такой радиус не смотрится.
 */
/datum/unit_test/combat_extended/spread_ring/proc/describe_ring_row(icon/cursor, radius)
	var/center = cursor.Width() / 2
	if(radius <= world.icon_size / 2)
		return null
	var/row = center + 1
	var/white_found = FALSE
	var/black_found = FALSE
	for(var/x in center + world.icon_size / 2 + 1 to cursor.Width())
		var/pixel = lowertext(cursor.GetPixel(x, row))
		if(!pixel)
			continue
		var/from_center = x - center
		if(pixel == "#ffffff" && from_center >= radius && from_center <= radius + 1)
			white_found = TRUE
		else if(pixel == "#000000" && from_center >= radius + 1 && from_center <= radius + 2)
			black_found = TRUE
		else
			return "пиксель [pixel] в [from_center] от середины, а кольцо — на [radius]"
	if(!white_found || !black_found)
		return "на строке над серединой [white_found ? "есть" : "нет"] белого кольца на [radius] и [black_found ? "есть" : "нет"] чёрной обводки за ним"
	return null

/// Курсор: наименьший квадрат, в который входит кольцо с обводкой; кольцо белое в чёрной обводке
/// вокруг середины; перекрестие апстрима посередине, без него — точка; состояние "", один на радиус.
/datum/unit_test/combat_extended/spread_ring/proc/check_cursor(list/failures)
	// list(радиус, ожидаемый размер картинки)
	var/list/sizes = list(list(10, 32), list(29, 64), list(30, 128), list(125, 256), list(253, 512))
	for(var/list/entry as anything in sizes)
		var/icon/cursor = icon(ce_get_spread_ring_cursor(entry[1], CE_RING_CROSSHAIR))
		if(cursor.Width() != entry[2] || cursor.Height() != entry[2])
			failures += "курсор радиуса [entry[1]]: [cursor.Width()]x[cursor.Height()], ожидался [entry[2]]x[entry[2]]"
		var/list/states = icon_states(cursor)
		if(length(states) != 1 || states[1] != "")
			failures += "курсор радиуса [entry[1]]: состояния [json_encode(states)], ожидалось одно — \"\""
		var/problem = describe_ring_row(cursor, entry[1])
		if(problem)
			failures += "курсор радиуса [entry[1]]: [problem]"
	if(istype(ce_get_spread_ring_cursor(30, CE_RING_CROSSHAIR), /icon))
		failures += "курсор хранится картинкой /icon, а не файлом кэша: в памяти сервера он в сотни раз больше"
	if(ce_get_spread_ring_cursor(30, CE_RING_CROSSHAIR) != ce_get_spread_ring_cursor(30, CE_RING_CROSSHAIR))
		failures += "курсор радиуса 30 рисуется заново на каждый запрос"

	// Перекрестие стоит серединой на середине курсора: его пиксели сдвинуты на полразмера курсора
	// без полклетки.
	var/icon/crosshair = icon(CE_RING_CROSSHAIR)
	var/icon/cursor = icon(ce_get_spread_ring_cursor(30, CE_RING_CROSSHAIR))
	var/shift = cursor.Width() / 2 - world.icon_size / 2
	var/checked = 0
	for(var/x in 1 to world.icon_size)
		for(var/y in 1 to world.icon_size)
			var/crosshair_pixel = crosshair.GetPixel(x, y)
			if(!crosshair_pixel || checked >= 5)
				continue
			checked++
			if(cursor.GetPixel(x + shift, y + shift) != crosshair_pixel)
				failures += "курсор: пиксель перекрестия [x],[y] ([crosshair_pixel]) на курсоре в [x + shift],[y + shift] — [cursor.GetPixel(x + shift, y + shift)]"
	if(!checked)
		failures += "курсор: у перекрестия апстрима нет видимых пикселей, проверять нечего"
	var/icon/dot_cursor = icon(ce_get_spread_ring_cursor(30, null))
	var/dot_center = dot_cursor.Width() / 2
	if(lowertext(dot_cursor.GetPixel(dot_center, dot_center)) != "#ffffff")
		failures += "курсор без перекрестия: посередине [dot_cursor.GetPixel(dot_center, dot_center)], ожидалась белая точка"


/// Во что целится кольцо: клетка и то, что на ней, с пикселем входа мыши; клетка под сеткой под
/// картой; ни панель интерфейса, ни вещь в инвентаре, ни удалённое.
/datum/unit_test/combat_extended/spread_ring/proc/check_hover(list/failures)
	var/datum/extension/ce_spread_ring/ring = get_or_create_extension(shooter, /datum/extension/ce_spread_ring)
	var/turf/east = near(3, 0)
	if(!ring.note_hover(east, "icon-x=20;icon-y=9") || ring.get_aim_target() != east || ring.hover_icon_x != 20 || ring.hover_icon_y != 9)
		failures += "наведение на клетку строкой параметров: цель [ring.get_aim_target()], пиксель [ring.hover_icon_x],[ring.hover_icon_y]; ожидались клетка и 20,9"
	if(!ring.note_hover(east, list(MOUSE_ICON_X = "7", MOUSE_ICON_Y = "30")) || ring.hover_icon_x != 7 || ring.hover_icon_y != 30)
		failures += "наведение на клетку списком параметров: пиксель [ring.hover_icon_x],[ring.hover_icon_y], ожидался 7,30"
	if(!ring.note_hover(east) || !isnull(ring.hover_icon_x) || !isnull(ring.hover_icon_y))
		failures += "наведение без параметров: пиксель [ring.hover_icon_x],[ring.hover_icon_y], ожидалось без пикселя"

	var/obj/screen/panel = new
	spawned += panel
	if(ring.note_hover(panel, "icon-x=1;icon-y=1") || ring.get_aim_target() != east)
		failures += "наведение на панель интерфейса: цель стала [ring.get_aim_target()], ожидалось — осталась клетка"
	if(ring.note_hover(gun, "icon-x=1;icon-y=1") || ring.get_aim_target() != east)
		failures += "наведение на оружие в руке: цель стала [ring.get_aim_target()], ожидалось — осталась клетка"

	// Сетка — своя у каждого клиента, клетка экрана от юго-западного угла: эта — у середины экрана.
	var/obj/screen/click_catcher/catcher = new
	spawned += catcher
	catcher.screen_loc = "8,8"
	var/turf/under_catcher = screen_params_turf(catcher.screen_loc, origin)
	if(!under_catcher)
		failures += "под сеткой [catcher.screen_loc] нет клетки карты, проверять нечего"
	else if(!ring.note_hover(catcher) || ring.get_aim_target() != under_catcher)
		failures += "наведение на сетку под картой: цель [ring.get_aim_target()], ожидалась клетка под ней [under_catcher]"

	var/obj/item/device/flashlight/lying = new(near(2, 1))
	spawned += lying
	if(!ring.note_hover(lying) || ring.get_aim_target() != lying)
		failures += "наведение на предмет на полу: цель [ring.get_aim_target()], ожидался предмет"
	lying.forceMove(null)
	if(ring.get_aim_target())
		failures += "предмет под мышью убрали с карты, а цель осталась — [ring.get_aim_target()]"
	lying.forceMove(near(2, 1))
	qdel(lying)
	if(ring.get_aim_target())
		failures += "предмет под мышью удалён, а цель осталась — [ring.get_aim_target()]"
	remove_extension(shooter, /datum/extension/ce_spread_ring)


/// Кольцо появляется, когда снят предохранитель, и пересчитывается при наведении, выстреле, сходе
/// отдачи, смене режима огня и шаге; без масштаба, над тем, что рядом, и без разброса его нет;
/// шире курсора не растёт.
/datum/unit_test/combat_extended/spread_ring/proc/check_wiring(list/failures)
	shooter.a_intent = I_HELP
	give_stacks(0)
	gun.safety_state = TRUE
	shooter.update_mouse_pointer()
	if(get_ring())
		failures += "предохранитель на виду, а кольцо есть"
	gun.toggle_safety(shooter)
	var/datum/extension/ce_spread_ring/ring = get_ring()
	if(!ring)
		failures += "предохранитель снят, а кольца нет"
		return

	// Масштаб читается с клиента, а его у теста нет: без масштаба кольца нет, дальше тест ставит его сам.
	var/turf/target = near(3, 1)
	shooter.ce_note_spread_hover(target, "icon-x=8;icon-y=24")
	expect_no_ring(failures, "масштаб не прочитан", ring)
	var/scale = 2
	ring.screen_scale = scale
	shooter.update_mouse_pointer()
	expect_ring(failures, "наведение на клетку", ring, target.ce_get_aim_point(8, 24), scale)

	// Выстрел пересчитывает кольцо, даже если мышь не двигалась: здесь цель сменена без пересчёта.
	var/base_radius = ring.radius
	target = near(-2, 3)
	ring.note_hover(target)
	// Стаки начислены децисекунду назад: следующий сойдёт раньше, чем через полный срок от выстрела.
	shooter.ce_recoil_stacks = 2
	shooter.ce_recoil_stacks_time = world.time - 1
	gun.handle_post_fire(shooter, target)
	if(shooter.ce_get_recoil_stacks() <= 2)
		failures += "выстрел не прибавил стаков: ружьё без отдачи, проверять нечего"
	if(shooter.ce_get_next_recoil_shed_time() != world.time + 3)
		failures += "следующий стак сойдёт в [shooter.ce_get_next_recoil_shed_time()], ожидалось через 3 децисекунды — в [world.time + 3]"
	expect_ring(failures, "после выстрела", ring, target.ce_get_aim_point(), scale)
	// Ещё пересчёт под отдачей: таймер у кольца остаётся один.
	shooter.update_mouse_pointer()
	var/list/recoil_timers = list()
	for(var/datum/timer/timer as anything in SStimer.queue)
		if(timer.callback.target == ring && timer.callback.callable == TYPE_PROC_REF(/datum/extension/ce_spread_ring, on_recoil_tick))
			recoil_timers += timer
	if(length(recoil_timers) != 1)
		failures += "после выстрела таймеров, которые сузят кольцо, — [length(recoil_timers)], ожидался один"
	else
		var/datum/timer/recoil_timer = recoil_timers[1]
		if(recoil_timer.fire_time != shooter.ce_get_next_recoil_shed_time() || ring.recoil_tick_time != recoil_timer.fire_time)
			failures += "таймер кольца сработает в [recoil_timer.fire_time] (кольцо ждёт его в [ring.recoil_tick_time]), а стак сойдёт в [shooter.ce_get_next_recoil_shed_time()]"
	// Отдача сошла: срок стака вышел, кольцо сужается.
	var/recoil_radius = ring.radius
	give_stacks(0)
	ring.on_recoil_tick()
	expect_ring(failures, "отдача сошла", ring, target.ce_get_aim_point(), scale)
	if(ring.radius >= recoil_radius)
		failures += "отдача сошла, а кольцо не сузилось: [recoil_radius] и [ring.radius]"

	target = near(1, -3)
	ring.note_hover(target)
	gun.switch_firemodes()
	expect_ring(failures, "смена режима огня", ring, target.ce_get_aim_point(), scale)

	// Шаг стрелка: вершина дуги ушла с ним, цель осталась.
	target = near(-3, -1)
	ring.note_hover(target)
	shooter.forceMove(near(1, 0))
	expect_ring(failures, "шаг стрелка", ring, target.ce_get_aim_point(), scale)
	shooter.forceMove(origin)

	// Шире курсора в 512 пикселей кольцо не растёт.
	ring.screen_scale = 100
	shooter.update_mouse_pointer()
	var/widest_pointer = gun.get_mouse_pointer(shooter)
	var/icon/widest = widest_pointer == CE_RING_CROSSHAIR ? null : icon(widest_pointer)
	if(!widest || widest.Width() != 512)
		failures += "огромный масштаб: курсор [widest ? "[widest.Width()] пикселей" : "не кольцо"], ожидалось кольцо в 512 пикселей"
	ring.screen_scale = scale
	shooter.update_mouse_pointer()

	// Над тем, что рядом, кольца нет: в упор оружие бьёт без разброса, а без намерения вредить не
	// стреляет вовсе.
	var/mob/living/carbon/human/neighbour = make_human()
	if(!neighbour)
		failures += "не удалось создать соседа"
		return
	neighbour.forceMove(near(1, 0))
	shooter.ce_note_spread_hover(neighbour)
	expect_no_ring(failures, "сосед, без намерения вредить", ring)
	shooter.a_intent = I_HURT
	shooter.update_mouse_pointer()
	expect_no_ring(failures, "сосед, с намерением вредить", ring)
	shooter.a_intent = I_HELP
	shooter.ce_note_spread_hover(shooter, "icon-x=20;icon-y=20")
	expect_no_ring(failures, "мышь на самом стрелке", ring)
	shooter.ce_note_spread_hover(origin)
	expect_no_ring(failures, "мышь на клетке стрелка", ring)
	var/turf/far = near(-3, 2)
	shooter.ce_note_spread_hover(far)
	expect_ring(failures, "мышь ушла со стрелка", ring, far.ce_get_aim_point(), scale)

	// Разброса нет — мастер без отдачи с метким оружием: кольца нет; у обученного — снова есть.
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_MASTER))
	shooter.update_mouse_pointer()
	expect_no_ring(failures, "мастер без отдачи", ring)
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	shooter.update_mouse_pointer()
	expect_ring(failures, "обученный после мастера", ring, far.ce_get_aim_point(), scale)
	if(base_radius <= 0)
		failures += "кольцо до выстрела было нулевым, проверять нечего"


/// Кольцо пропадает: оружие брошено, предохранитель поставлен, настройка выключена, попиксельной
/// стрельбы нет, в руке метательное оружие; сжимается в ноль, когда цель ушла с карты.
/datum/unit_test/combat_extended/spread_ring/proc/check_hiding(list/failures)
	shooter.update_mouse_pointer()
	var/datum/extension/ce_spread_ring/ring = get_ring()
	if(!ring)
		failures += "перед проверкой пропажи кольца его нет"
		return
	var/obj/item/device/flashlight/lying = new(near(2, -2))
	spawned += lying
	shooter.ce_note_spread_hover(lying)
	qdel(lying)
	shooter.update_mouse_pointer()
	expect_no_ring(failures, "цель под мышью удалена", ring)

	// Брошенное без предохранителя оружие может выстрелить у того, кто ниже опытного (`check_accidents()`).
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_EXPERIENCED))
	shooter.drop_from_inventory(gun)
	set_skills(shooter, list(SKILL_WEAPONS = SKILL_TRAINED))
	if(get_ring())
		failures += "оружие брошено, а кольцо есть"
	shooter.put_in_active_hand(gun)
	if(!get_ring())
		failures += "оружие снова в руке, а кольца нет"

	var/datum/client_preference/preference = get_client_preference(/datum/client_preference/ce_spread_ring)
	var/default_was = preference.default_value
	preference.default_value = GLOB.PREF_NO
	shooter.update_mouse_pointer()
	var/hidden_by_preference = !get_ring()
	preference.default_value = default_was
	shooter.update_mouse_pointer()
	if(!hidden_by_preference || !get_ring())
		failures += "настройка: выключенная [hidden_by_preference ? "прячет" : "не прячет"] кольцо, включённая [get_ring() ? "показывает" : "не показывает"]"

	ce_pixel_aim_enabled = FALSE
	shooter.update_mouse_pointer()
	var/hidden_without_aim = !get_ring()
	ce_pixel_aim_enabled = TRUE
	if(!hidden_without_aim)
		failures += "без попиксельной стрельбы кольцо есть"

	gun.toggle_safety(shooter)
	if(get_ring())
		failures += "предохранитель поставлен, а кольцо есть"

	var/obj/item/gun/launcher/crossbow/crossbow = new(origin)
	spawned += crossbow
	if(crossbow.ce_shows_spread_ring(shooter))
		failures += "у арбалета есть кольцо разброса"

#undef CE_RING_TOLERANCE
#undef CE_RING_CROSSHAIR


/*
	Кислота против одежды и брони (`acid_armor.dm`). Проход всплеска по частям тела проверяется
	чистым запросом `ce_trace_acid()`, а то, что кислота делает на самом деле, — на людях: её льют
	тем же путём, что спрей (`splash_mob()`), и дают коже один тик (`metabolize()`).

	Ожидаемые числа — от настроек мода и от чисел самой кислоты в Бэй (`touch_met`, `power`,
	`meltdose`, `max_damage`); своё здесь только 0.2 из формулы Бэй. Доля макушки и множитель износа на
	время теста — не по умолчанию: с числом по умолчанию настройка, которую код забыл, давала бы те
	же числа.
*/
#define CE_ACID_BURN_SLACK 0.05

/datum/unit_test/combat_extended/acid_armor
	name = "CE: Кислота против брони"
	/// Кислота, которую льёт тест.
	var/datum/reagent/acid/acid_type = /datum/reagent/acid/polyacid
	/// Доли площади тела: голова целиком, макушка и каждая из двух частей лица.
	var/head_share
	var/scalp_share
	var/face_part_share

/datum/unit_test/combat_extended/acid_armor/start_test()
	var/list/failures = list()
	var/scalp_share_was = ce_acid_scalp_share
	var/wear_mult_was = ce_acid_armor_wear_mult
	ce_acid_scalp_share = 0.4
	ce_acid_armor_wear_mult = 2.5
	// Ожог не меньше прочности части тела может сжечь её дотла (`attempt_dismemberment()`, шанс —
	// треть ожога в процентах: 20% у полного ожога политриновой кислоты на руке, ноге, кисти или
	// стопе). Ожогом человека тогда становится прочность потерянной части, а не то, что нанесла
	// кислота. Тест мерит кислоту, поэтому на его время части тела не теряются.
	var/limbs_could_break = config.limbs_can_break
	config.limbs_can_break = FALSE
	head_share = ce_acid_part_shares[BP_HEAD]
	scalp_share = head_share * ce_acid_scalp_share
	face_part_share = (head_share - scalp_share) / 2

	check_trace_bare(failures)
	check_trace_head(failures)
	check_trace_flimsy(failures)
	check_trace_body(failures)
	check_dose(failures)
	check_protected_head(failures)
	check_melting(failures)
	check_disfigurement(failures)
	check_sealed(failures)
	check_burned_part(failures)

	ce_acid_scalp_share = scalp_share_was
	ce_acid_armor_wear_mult = wear_mult_was
	config.limbs_can_break = limbs_could_break
	cleanup()
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("Полный ожог кислоты даёт доза плавления, меньшая — свою долю; всплеск делится по частям тела; кислотостойкая и непроницаемая вещь, броня и очки на глазах защищают только то, что закрывают; одежда с рейтингом — не броня; броня теряет HP, а не плавится; вещи без защиты на голове плавятся от дозы плавления; лицо обезображивает доза плавления на открытых глазах или рту.")
	return 1

/// Числа расходятся. Доли площади сходятся до тысячных; ожогу и HP нужен запас `CE_ACID_BURN_SLACK`:
/// количество реагента округляется до сотых.
/datum/unit_test/combat_extended/acid_armor/proc/differs(value, expected, tolerance = 0.001)
	return abs(value - expected) > tolerance

/// Надевает на человека новую вещь типа `path` в слот `slot`. null — надеть не вышло.
/datum/unit_test/combat_extended/acid_armor/proc/wear(mob/living/carbon/human/H, path, slot)
	RETURN_TYPE(/obj/item/clothing)
	var/obj/item/clothing/thing = new path(H)
	if(!H.equip_to_slot_or_del(thing, slot))
		return null
	return thing

/// Льёт на человека `amount` единиц кислоты, как спрей, и даёт коже один тик.
/datum/unit_test/combat_extended/acid_armor/proc/douse(mob/living/carbon/human/H, amount)
	var/datum/reagents/source = new /datum/reagents(amount, GLOB.temp_reagents_holder)
	source.add_reagent(acid_type, amount)
	source.splash_mob(H, amount)
	H.touching.metabolize()
	qdel(source)

/// Полный ожог кислоты: `touch_met` единиц по формуле Бэй, не больше `max_damage`.
/datum/unit_test/combat_extended/acid_armor/proc/full_burn()
	return min(initial(acid_type.touch_met) * initial(acid_type.power) * 0.2, initial(acid_type.max_damage))

/// Ожог от всплеска в `splash` единиц на долю тела `skin_share`: полный — с дозы плавления, ниже неё
/// — по количеству.
/datum/unit_test/combat_extended/acid_armor/proc/expected_burn(splash, skin_share = 1)
	return full_burn() * min(splash / initial(acid_type.meltdose), 1) * skin_share

/// Сколько частей тела человека обезображено.
/datum/unit_test/combat_extended/acid_armor/proc/count_disfigured(mob/living/carbon/human/H)
	. = 0
	for(var/obj/item/organ/external/organ in H.organs)
		if(organ.status & ORGAN_DISFIGURED)
			.++

/// Доля площади тела под вещью: части тела, которые она закрывает.
/datum/unit_test/combat_extended/acid_armor/proc/covered_share(mob/living/carbon/human/H, obj/item/cover)
	. = 0
	for(var/obj/item/organ/external/organ in H.organs)
		if(cover.body_parts_covered & organ.body_part)
			. += ce_acid_part_shares[organ.organ_tag]

/// Голый человек: кислота доходит до всего тела и ничего по пути не встречает.
/datum/unit_test/combat_extended/acid_armor/proc/check_trace_bare(list/failures)
	var/mob/living/carbon/human/H = make_human()
	var/datum/ce_acid_trace/trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1) || length(trace.burned) != length(ce_acid_part_shares) || trace.face_exposure != 1)
		failures += "голый: до кожи дошло [trace.skin_share] всплеска, частей тела [length(trace.burned)], лицо открыто на [trace.face_exposure]; ожидалось 1, [length(ce_acid_part_shares)] и 1"
	if(length(trace.armor_hits) || length(trace.soaked))
		failures += "голый: кислота встретила броню [length(trace.armor_hits)] раз и вещей без защиты [length(trace.soaked)]"

/// Голова: шлем закрывает макушку, очки — глаза, маска — рот; закрытое лицо — и глаза, и рот.
/datum/unit_test/combat_extended/acid_armor/proc/check_trace_head(list/failures)
	var/mob/living/carbon/human/H = make_human()
	var/obj/item/clothing/helmet = wear(H, /obj/item/clothing/head/helmet, slot_head)
	if(!helmet)
		failures += "голова: не удалось надеть шлем"
		return
	var/datum/ce_acid_trace/trace = H.ce_trace_acid()
	var/datum/extension/armor/helmet_armor = get_extension(helmet, /datum/extension/armor)
	var/list/hit = length(trace.armor_hits) == 1 ? trace.armor_hits[1] : null
	if(!hit || hit[1] != helmet_armor || hit[2] != HEAD || differs(hit[3], scalp_share))
		failures += "голова, шлем: встреч с бронёй [length(trace.armor_hits)], первая — [hit ? "часть тела [hit[2]], доля [hit[3]]" : "нет"]; ожидалась одна, броня шлема на макушке с долей [scalp_share]"
	if(differs(trace.skin_share, 1 - scalp_share) || trace.face_exposure != 1 || length(trace.soaked))
		failures += "голова, шлем: до кожи дошло [trace.skin_share], лицо открыто на [trace.face_exposure], вещей без защиты [length(trace.soaked)]; ожидалось [1 - scalp_share], 1 и ни одной"

	// Очки, закрывающие глаза, глаза спасают, но лицо с открытым ртом ещё открыто.
	var/obj/item/clothing/goggles = wear(H, /obj/item/clothing/glasses/sunglasses, slot_glasses)
	var/obj/item/clothing/mask = wear(H, /obj/item/clothing/mask/bandana, slot_wear_mask)
	if(!goggles || !mask || !(goggles.body_parts_covered & EYES) || !(mask.body_parts_covered & FACE))
		failures += "голова: не удалось надеть очки, закрывающие глаза, и маску, закрывающую рот"
		return
	mask.permeability_coefficient = 0.25
	trace = H.ce_trace_acid()
	var/expected_share = 1 - scalp_share - face_part_share - face_part_share * 0.75
	if(differs(trace.skin_share, expected_share) || differs(trace.face_exposure, 0.25))
		failures += "голова, шлем, очки и маска с проницаемостью 0.25: до кожи дошло [trace.skin_share], лицо открыто на [trace.face_exposure]; ожидалось [expected_share] и 0.25"
	if(length(trace.armor_hits) != 1 || length(trace.soaked))
		failures += "голова, шлем, очки и маска: встреч с бронёй [length(trace.armor_hits)], вещей без защиты [length(trace.soaked)]; ожидалась одна и ни одной"

	// Кислотостойкая маска закрывает рот целиком: лицо закрыто.
	mask.unacidable = TRUE
	trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1 - head_share) || trace.face_exposure != 0)
		failures += "голова, шлем, очки и кислотостойкая маска: до кожи дошло [trace.skin_share], лицо открыто на [trace.face_exposure]; ожидалось [1 - head_share] и 0"

	// Броня за проницаемым слоем останавливает то, что он пропустил: до кожи доходит столько же,
	// а износа ей достаётся меньше.
	helmet.permeability_coefficient = 0.5
	trace = H.ce_trace_acid()
	hit = length(trace.armor_hits) == 1 ? trace.armor_hits[1] : null
	if(!hit || differs(hit[3], scalp_share * 0.5) || differs(trace.skin_share, 1 - head_share))
		failures += "голова, шлем с проницаемостью 0.5: броня остановила [hit ? hit[3] : "ничего"], до кожи дошло [trace.skin_share]; ожидалось [scalp_share * 0.5] и [1 - head_share]"
	helmet.permeability_coefficient = 1

	// Броня без HP кислоту не держит: шлем становится вещью без защиты.
	if(ce_armor_wear_enabled)
		helmet_armor.ce_get_health_max(null)
		helmet_armor.ce_set_health(null, 0)
		trace = H.ce_trace_acid()
		if(length(trace.armor_hits) || differs(trace.skin_share, 1 - head_share + scalp_share) || !(helmet in trace.soaked))
			failures += "голова, шлем без HP: встреч с бронёй [length(trace.armor_hits)], до кожи дошло [trace.skin_share], шлем среди вещей без защиты — [(helmet in trace.soaked) ? "да" : "нет"]; ожидалось ноль, [1 - head_share + scalp_share] и да"

/// Вещи без защиты: кепка, бандана и очки, не закрывающие глаз, кислоту не держат, а под забралом
/// она до них не доходит.
/datum/unit_test/combat_extended/acid_armor/proc/check_trace_flimsy(list/failures)
	var/mob/living/carbon/human/H = make_human()
	var/obj/item/clothing/cap = wear(H, /obj/item/clothing/head/soft, slot_head)
	var/obj/item/clothing/bandana = wear(H, /obj/item/clothing/mask/bandana, slot_wear_mask)
	var/obj/item/clothing/shades = wear(H, /obj/item/clothing/glasses/hud/security/prot/sunglasses, slot_glasses)
	if(!cap || !bandana || !shades || (shades.body_parts_covered & EYES))
		failures += "вещи без защиты: не удалось надеть кепку, бандану и очки, не закрывающие глаз"
		return
	var/datum/ce_acid_trace/trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1) || trace.face_exposure != 1)
		failures += "кепка, бандана и очки без защиты: до кожи дошло [trace.skin_share], лицо открыто на [trace.face_exposure]; ожидалось 1 и 1"
	for(var/obj/item/worn in list(cap, bandana, shades))
		if(trace.soaked[worn] != 1)
			failures += "кепка, бандана и очки без защиты: до вещи «[worn.name]» дошло [isnull(trace.soaked[worn]) ? "ничего" : trace.soaked[worn]], ожидалось 1"

	// Кислотостойкая кепка макушку не закрывает и не защищает, но и не плавится.
	cap.unacidable = TRUE
	trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1) || (cap in trace.soaked))
		failures += "кислотостойкая кепка: до кожи дошло [trace.skin_share], кепка среди вещей без защиты — [(cap in trace.soaked) ? "да" : "нет"]; ожидалось 1 и нет"

	// Убор с бронёй, который ничего не закрывает, — то же самое.
	qdel(cap)
	var/obj/item/clothing/patch = wear(H, /obj/item/clothing/head/HoS/dermal, slot_head)
	if(!patch || (patch.body_parts_covered & HEAD) || !patch.ce_get_kinetic_armor())
		failures += "вещи без защиты: не удалось надеть убор с бронёй, который ничего не закрывает"
		return
	trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1) || (patch in trace.soaked) || length(trace.armor_hits))
		failures += "убор с бронёй, не закрывающий макушку: до кожи дошло [trace.skin_share], встреч с бронёй [length(trace.armor_hits)], убор среди вещей без защиты — [(patch in trace.soaked) ? "да" : "нет"]; ожидалось 1, ни одной и нет"

	// Каска макушку закрывает, но она одежда с рейтингом, а не броня: кислоту не держит и не
	// плавится.
	qdel(patch)
	var/obj/item/clothing/hardhat = wear(H, /obj/item/clothing/head/hardhat, slot_head)
	if(!hardhat || !(hardhat.body_parts_covered & HEAD) || !hardhat.ce_get_kinetic_armor())
		failures += "вещи без защиты: не удалось надеть каску с рейтингом"
		return
	trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1) || (hardhat in trace.soaked) || length(trace.armor_hits))
		failures += "каска: до кожи дошло [trace.skin_share], встреч с бронёй [length(trace.armor_hits)], каска среди вещей без защиты — [(hardhat in trace.soaked) ? "да" : "нет"]; ожидалось 1, ни одной и нет"

	// Закрывающая макушку шапка без брони — тоже не преграда.
	qdel(hardhat)
	var/obj/item/clothing/hat = wear(H, /obj/item/clothing/head/ushanka, slot_head)
	if(!hat || !(hat.body_parts_covered & HEAD))
		failures += "вещи без защиты: не удалось надеть шапку, закрывающую макушку"
		return
	trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1) || trace.soaked[hat] != 1)
		failures += "шапка без брони: до кожи дошло [trace.skin_share], до шапки — [isnull(trace.soaked[hat]) ? "ничего" : trace.soaked[hat]]; ожидалось 1 и 1"

	// Кислотостойкая шапка закрывает только макушку, а не всё тело, как в Бэй.
	hat.unacidable = TRUE
	trace = H.ce_trace_acid()
	if(differs(trace.skin_share, 1 - scalp_share) || (hat in trace.soaked))
		failures += "кислотостойкая шапка: до кожи дошло [trace.skin_share], ожидалось [1 - scalp_share] — всё, кроме макушки"

	// Под шлемом с забралом кислота до банданы и очков не доходит.
	qdel(hat)
	var/obj/item/clothing/riot = wear(H, /obj/item/clothing/head/helmet/riot, slot_head)
	if(!riot || (riot.body_parts_covered & (HEAD | FACE | EYES)) != (HEAD | FACE | EYES))
		failures += "вещи без защиты: не удалось надеть шлем с забралом"
		return
	trace = H.ce_trace_acid()
	if(length(trace.soaked) || trace.face_exposure != 0 || length(trace.armor_hits) != 3 || differs(trace.skin_share, 1 - head_share))
		failures += "шлем с забралом поверх банданы и очков: вещей без защиты [length(trace.soaked)], лицо открыто на [trace.face_exposure], встреч с бронёй [length(trace.armor_hits)], до кожи дошло [trace.skin_share]; ожидалось ни одной, 0, три и [1 - head_share]"

/// Тело: непроницаемый скафандр и пластина плитоноски закрывают свои части тела, остальные открыты.
/datum/unit_test/combat_extended/acid_armor/proc/check_trace_body(list/failures)
	var/mob/living/carbon/human/sealed = make_human()
	var/obj/item/clothing/suit = wear(sealed, /obj/item/clothing/suit/space/void/security, slot_wear_suit)
	if(!suit || suit.permeability_coefficient != 0)
		failures += "тело: не удалось надеть непроницаемый скафандр"
	else
		var/datum/ce_acid_trace/trace = sealed.ce_trace_acid()
		var/open_share = 1 - covered_share(sealed, suit)
		if(differs(trace.skin_share, open_share) || length(trace.armor_hits))
			failures += "скафандр без шлема: до кожи дошло [trace.skin_share], встреч с бронёй [length(trace.armor_hits)]; ожидалось [open_share] и ни одной: кислоту он не пускает, и останавливать броне нечего"
		for(var/obj/item/organ/external/organ in trace.burned)
			if(suit.body_parts_covered & organ.body_part)
				failures += "скафандр без шлема: кислота дошла до кожи под ним — [organ.name]"

	var/mob/living/carbon/human/plated = make_human(list(/obj/item/clothing/accessory/armor_plate/medium))
	var/obj/item/clothing/carrier = plated?.wear_suit
	var/obj/item/clothing/accessory/plate = carrier ? (locate(/obj/item/clothing/accessory/armor_plate) in carrier.accessories) : null
	if(!plate)
		failures += "тело: не удалось надеть плитоноску с пластиной"
		return
	var/datum/ce_acid_trace/plated_trace = plated.ce_trace_acid()
	var/plate_share = covered_share(plated, plate)
	var/stopped = 0
	for(var/list/hit as anything in plated_trace.armor_hits)
		if(hit[1] != get_extension(plate, /datum/extension/armor))
			failures += "плитоноска с пластиной: кислоту остановила не броня пластины"
		stopped += hit[3]
	if(plate_share <= 0 || differs(stopped, plate_share) || differs(plated_trace.skin_share, 1 - plate_share))
		failures += "плитоноска с пластиной: броня остановила [stopped] всплеска, до кожи дошло [plated_trace.skin_share]; ожидалось [plate_share] и [1 - plate_share]"

	// Одежда без защиты на теле кислоте не помеха, но и не плавится: плавится только то, что на
	// голове. Униформа Бэй пускает девять десятых кислоты, здесь — всю.
	var/mob/living/carbon/human/dressed = make_human()
	var/obj/item/clothing/uniform = wear(dressed, /obj/item/clothing/under/color/grey, slot_w_uniform)
	if(uniform)
		uniform.permeability_coefficient = 1
	if(!uniform || !covered_share(dressed, uniform) || !uniform.ce_is_acid_flimsy())
		failures += "тело: не удалось надеть униформу без защиты"
		return
	var/datum/ce_acid_trace/dressed_trace = dressed.ce_trace_acid()
	if(differs(dressed_trace.skin_share, 1) || length(dressed_trace.soaked))
		failures += "униформа: до кожи дошло [dressed_trace.skin_share], вещей, которые кислота может расплавить, — [length(dressed_trace.soaked)]; ожидалось 1 и ни одной"
	var/flood = 10 * initial(acid_type.meltdose)
	douse(dressed, flood)
	if(QDELETED(uniform) || dressed.w_uniform != uniform)
		failures += "униформа: не пережила [flood] ед. кислоты"

	// Форма охраны — одежда с рейтингом, а не броня: держит ту же десятую, что и любая униформа.
	var/mob/living/carbon/human/officer = make_human()
	var/obj/item/clothing/duty = wear(officer, /obj/item/clothing/under/rank/security, slot_w_uniform)
	if(!duty || !duty.ce_get_kinetic_armor() || !covered_share(officer, duty))
		failures += "тело: не удалось надеть форму с рейтингом"
		return
	var/datum/ce_acid_trace/duty_trace = officer.ce_trace_acid()
	var/duty_share = 1 - covered_share(officer, duty) * (1 - duty.permeability_coefficient)
	if(differs(duty_trace.skin_share, duty_share) || length(duty_trace.armor_hits) || length(duty_trace.burned) != length(ce_acid_part_shares))
		failures += "форма охраны: до кожи дошло [duty_trace.skin_share], встреч с бронёй [length(duty_trace.armor_hits)], частей тела [length(duty_trace.burned)]; ожидалось [duty_share], ни одной и [length(ce_acid_part_shares)]"

/// Доза: полный ожог даёт доза плавления, меньшая — свою долю, и любая капля — уже не 50 единиц.
/datum/unit_test/combat_extended/acid_armor/proc/check_dose(list/failures)
	var/meltdose = initial(acid_type.meltdose)
	for(var/amount in list(meltdose / 8, meltdose / 2, meltdose, 3 * meltdose))
		var/mob/living/carbon/human/H = make_human()
		douse(H, amount)
		var/burn = H.getFireLoss()
		if(differs(burn, expected_burn(amount), CE_ACID_BURN_SLACK))
			failures += "доза, голый, [amount] ед.: ожог [burn], ожидался [expected_burn(amount)]"

	var/datum/reagents/source = new /datum/reagents(10, GLOB.temp_reagents_holder)
	source.add_reagent(acid_type, 10)
	var/datum/reagent/acid/acid = locate(acid_type) in source.reagent_list
	if(!acid)
		failures += "доза: не удалось получить кислоту из колбы"
	else
		// Полный ожог этой кислоты упирается в её потолок: без него формула дала бы больше.
		if(differs(acid.ce_get_full_burn(), full_burn()) || full_burn() != initial(acid_type.max_damage))
			failures += "доза, формула: полный ожог [acid.ce_get_full_burn()], в тесте [full_burn()], потолок кислоты [initial(acid_type.max_damage)]; ожидался потолок"
		// list(всплеск, доля полного действия)
		for(var/list/entry as anything in list(list(0, 0), list(meltdose / 2, 0.5), list(meltdose, 1), list(1000, 1)))
			if(differs(acid.ce_get_dose_share(entry[1]), entry[2]))
				failures += "доза, формула, всплеск [entry[1]] ед.: доля полного действия [acid.ce_get_dose_share(entry[1])], ожидалась [entry[2]]"
	qdel(source)

/// Закрытая голова: шлем, очки и кислотостойкая маска целы, шлем теряет HP, ожог — только открытому
/// телу и только с открытой его доли.
/datum/unit_test/combat_extended/acid_armor/proc/check_protected_head(list/failures)
	var/mob/living/carbon/human/H = make_human()
	var/obj/item/clothing/helmet = wear(H, /obj/item/clothing/head/helmet, slot_head)
	var/obj/item/clothing/goggles = wear(H, /obj/item/clothing/glasses/sunglasses, slot_glasses)
	var/obj/item/clothing/mask = wear(H, /obj/item/clothing/mask/bandana, slot_wear_mask)
	if(!helmet || !goggles || !mask)
		failures += "закрытая голова: не удалось надеть шлем, очки и маску"
		return
	mask.unacidable = TRUE
	var/datum/extension/armor/helmet_armor = get_extension(helmet, /datum/extension/armor)
	var/health_before = helmet_armor.ce_get_health_max(null)
	var/amount = 10
	douse(H, amount)

	if(QDELETED(helmet) || QDELETED(goggles) || QDELETED(mask) || H.head != helmet || H.glasses != goggles || H.wear_mask != mask)
		failures += "закрытая голова: после кислоты на голове не всё — шлем [QDELETED(helmet) ? "расплавлен" : "цел"], очки [QDELETED(goggles) ? "расплавлены" : "целы"], маска [QDELETED(mask) ? "расплавлена" : "цела"]"
	var/burn = H.getFireLoss()
	var/skin_burn = expected_burn(amount, 1 - head_share)
	var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
	if(differs(burn, skin_burn, CE_ACID_BURN_SLACK) || head.burn_dam)
		failures += "закрытая голова, [amount] ед.: ожог [burn], из них голове [head.burn_dam]; ожидалось [skin_burn] открытому телу и ноль голове"
	if(count_disfigured(H))
		failures += "закрытая голова: обезображено частей тела — [count_disfigured(H)], ожидалось ни одной"
	if(ce_armor_wear_enabled)
		var/wear = expected_burn(amount, scalp_share) * ce_acid_armor_wear_mult
		var/health = helmet_armor.ce_get_health(null)
		if(isnull(health) || differs(health_before - health, wear, CE_ACID_BURN_SLACK))
			failures += "закрытая голова: шлем потерял [isnull(health) ? "ноль" : health_before - health] HP, ожидалось [wear] — ожог, который он не пустил к макушке"

/// Плавление: вещи без защиты на голове плавит доза плавления, меньшая — нет; очки, закрывающие
/// глаза, не плавятся вовсе.
/datum/unit_test/combat_extended/acid_armor/proc/check_melting(list/failures)
	var/meltdose = initial(acid_type.meltdose)
	// list(количество кислоты, плавятся ли вещи)
	for(var/list/entry as anything in list(list(meltdose + 1, TRUE), list(meltdose - 1, FALSE)))
		var/mob/living/carbon/human/H = make_human()
		var/obj/item/clothing/cap = wear(H, /obj/item/clothing/head/soft, slot_head)
		var/obj/item/clothing/bandana = wear(H, /obj/item/clothing/mask/bandana, slot_wear_mask)
		var/obj/item/clothing/shades = wear(H, /obj/item/clothing/glasses/hud/security/prot/sunglasses, slot_glasses)
		if(!cap || !bandana || !shades)
			failures += "плавление: не удалось надеть кепку, бандану и очки"
			return
		douse(H, entry[1])
		var/melted = 0
		for(var/obj/item/worn in list(cap, bandana, shades))
			if(QDELETED(worn))
				melted++
		var/left = !isnull(H.head) + !isnull(H.wear_mask) + !isnull(H.glasses)
		if(entry[2] ? (melted != 3 || left) : (melted || left != 3))
			failures += "плавление, [entry[1]] ед. при дозе плавления [meltdose]: расплавилось вещей [melted], на голове осталось [left]; ожидалось [entry[2] ? "три и ни одной" : "ни одной и три"]"

	// Под убором, который пускает половину кислоты, очкам достаётся половина всплеска.
	// list(количество кислоты, плавятся ли очки)
	for(var/list/entry as anything in list(list(1.5 * meltdose, FALSE), list(3 * meltdose, TRUE)))
		var/mob/living/carbon/human/H = make_human()
		var/obj/item/clothing/hood = wear(H, /obj/item/clothing/head/ushanka, slot_head)
		var/obj/item/clothing/shades = wear(H, /obj/item/clothing/glasses/hud/security/prot/sunglasses, slot_glasses)
		if(!hood || !shades)
			failures += "плавление: не удалось надеть убор и очки"
			return
		hood.body_parts_covered = HEAD | FACE | EYES
		hood.permeability_coefficient = 0.5
		douse(H, entry[1])
		if(QDELETED(hood) || !!QDELETED(shades) != entry[2])
			failures += "плавление под убором с проницаемостью 0.5, [entry[1]] ед. при дозе плавления [meltdose]: убор [QDELETED(hood) ? "расплавлен" : "цел"], очки [QDELETED(shades) ? "расплавлены" : "целы"]; ожидались целый убор и [entry[2] ? "расплавленные" : "целые"] очки"

	var/mob/living/carbon/human/guarded = make_human()
	var/obj/item/clothing/goggles = wear(guarded, /obj/item/clothing/glasses/sunglasses, slot_glasses)
	douse(guarded, 10 * meltdose)
	if(!goggles || QDELETED(goggles) || guarded.glasses != goggles)
		failures += "плавление: очки, закрывающие глаза, не пережили [10 * meltdose] ед. кислоты"

/// Обезображивается только голова и только через лицо: доза плавления на открытых глазах или рту.
/datum/unit_test/combat_extended/acid_armor/proc/check_disfigurement(list/failures)
	var/meltdose = initial(acid_type.meltdose)
	var/mob/living/carbon/human/bare = make_human()
	douse(bare, meltdose + 1)
	var/obj/item/organ/external/bare_head = bare.get_organ(BP_HEAD)
	if(!(bare_head.status & ORGAN_DISFIGURED) || count_disfigured(bare) != 1)
		failures += "обезображивание, голый, [meltdose + 1] ед.: голова [(bare_head.status & ORGAN_DISFIGURED) ? "обезображена" : "цела"], обезображено частей тела [count_disfigured(bare)]; ожидалась одна голова"

	// Половина дозы плавления, а не чуть меньше неё: голову с ожогом больше 40 кор обезображивает сам
	// (`/obj/item/organ/external/head/take_external_damage()`), а ожог достаётся случайной части тела.
	var/mob/living/carbon/human/splashed = make_human()
	douse(splashed, meltdose / 2)
	if(expected_burn(meltdose / 2) > 40)
		failures += "обезображивание: половина дозы плавления жжёт на [expected_burn(meltdose / 2)], а проверке нужен ожог не больше 40"
	if(count_disfigured(splashed))
		failures += "обезображивание, голый, [meltdose / 2] ед. — меньше дозы плавления: обезображено частей тела [count_disfigured(splashed)], ожидалось ни одной"

	// Шлем закрывает макушку, а лицо открыто.
	var/mob/living/carbon/human/helmeted = make_human()
	wear(helmeted, /obj/item/clothing/head/helmet, slot_head)
	douse(helmeted, meltdose + 1)
	var/obj/item/organ/external/helmeted_head = helmeted.get_organ(BP_HEAD)
	if(!helmeted.head || !(helmeted_head.status & ORGAN_DISFIGURED))
		failures += "обезображивание, шлем без забрала, [meltdose + 1] ед.: шлем [helmeted.head ? "на голове" : "не надет"], голова [(helmeted_head.status & ORGAN_DISFIGURED) ? "обезображена" : "цела"]; ожидалось обезображенное лицо"

	// Очки закрывают глаза, а рот открыт: лицо закрыто, только когда закрыто и то, и другое.
	var/mob/living/carbon/human/goggled = make_human()
	wear(goggled, /obj/item/clothing/glasses/sunglasses, slot_glasses)
	douse(goggled, meltdose + 1)
	var/obj/item/organ/external/goggled_head = goggled.get_organ(BP_HEAD)
	if(!goggled.glasses || !(goggled_head.status & ORGAN_DISFIGURED))
		failures += "обезображивание, очки без маски, [meltdose + 1] ед.: очки [goggled.glasses ? "на глазах" : "не надеты"], голова [(goggled_head.status & ORGAN_DISFIGURED) ? "обезображена" : "цела"]; ожидалось обезображенное лицо"

	// Доза плавления, восстановленная по проницаемости, — всё ещё доза плавления: 10 единиц серной
	// кислоты под скафандром без шлема доходят до кожи тремя.
	var/datum/reagent/acid/acid_type_was = acid_type
	acid_type = /datum/reagent/acid
	var/mob/living/carbon/human/suited = make_human()
	var/obj/item/clothing/suit = wear(suited, /obj/item/clothing/suit/space/void/security, slot_wear_suit)
	if(!suit)
		failures += "обезображивание: не удалось надеть скафандр"
	else
		suit.body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
		douse(suited, initial(acid_type.meltdose))
		var/obj/item/organ/external/suited_head = suited.get_organ(BP_HEAD)
		if(!(suited_head.status & ORGAN_DISFIGURED))
			failures += "обезображивание, серная кислота, ровно доза плавления под скафандром без шлема: голова цела, ожидалось обезображенное лицо"
	acid_type = acid_type_was

	// Шлем с забралом закрывает и лицо.
	var/mob/living/carbon/human/visored = make_human()
	wear(visored, /obj/item/clothing/head/helmet/riot, slot_head)
	douse(visored, 10 * meltdose)
	if(!visored.head || count_disfigured(visored))
		failures += "обезображивание, шлем с забралом, [10 * meltdose] ед.: шлем [visored.head ? "на голове" : "не надет"], обезображено частей тела [count_disfigured(visored)]; ожидалось ни одной"

/// Непроницаемое: под полным скафандром кислоты нет, а шлем без скафандра закрывает только голову
/// и не плавится.
/datum/unit_test/combat_extended/acid_armor/proc/check_sealed(list/failures)
	var/mob/living/carbon/human/suited = make_human()
	var/obj/item/clothing/suit = wear(suited, /obj/item/clothing/suit/space/void/security, slot_wear_suit)
	var/obj/item/clothing/suit_helmet = wear(suited, /obj/item/clothing/head/helmet/space/void/security, slot_head)
	if(!suit || !suit_helmet)
		failures += "непроницаемое: не удалось надеть скафандр со шлемом"
	else
		douse(suited, 30)
		if(suited.getFireLoss() || !suited.head || !suited.wear_suit)
			failures += "полный скафандр, 30 ед.: ожог [suited.getFireLoss()], шлем [suited.head ? "цел" : "расплавлен"], скафандр [suited.wear_suit ? "цел" : "расплавлен"]; ожидалось ничего"

	var/mob/living/carbon/human/H = make_human()
	var/obj/item/clothing/helmet = wear(H, /obj/item/clothing/head/helmet/space/void/security, slot_head)
	if(!helmet || helmet.permeability_coefficient != 0)
		failures += "непроницаемое: не удалось надеть непроницаемый шлем"
		return
	// Ровно доза плавления: до кожи доходит меньше, и без восстановления всплеска ожог был бы не
	// полным.
	var/amount = initial(acid_type.meltdose)
	douse(H, amount)
	var/burn = H.getFireLoss()
	var/skin_burn = expected_burn(amount, 1 - head_share)
	var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
	if(H.head != helmet || differs(burn, skin_burn, CE_ACID_BURN_SLACK) || head.burn_dam)
		failures += "шлем скафандра без скафандра, [amount] ед.: шлем [H.head == helmet ? "цел" : "расплавлен"], ожог [burn], из них голове [head.burn_dam]; ожидался целый шлем и [skin_burn] открытому телу"

/// Ожог достаётся только той части тела, до которой кислота дошла, а кислотостойкого человека она
/// не жжёт вовсе.
/datum/unit_test/combat_extended/acid_armor/proc/check_burned_part(list/failures)
	// Скафандр закрывает всё, кроме головы: весь ожог — ей. Часть тела кислота выбирает случайно,
	// поэтому попыток несколько.
	for(var/attempt in 1 to 4)
		var/mob/living/carbon/human/H = make_human()
		var/obj/item/clothing/suit = wear(H, /obj/item/clothing/suit/space/void/security, slot_wear_suit)
		if(!suit)
			failures += "открытая часть тела: не удалось надеть скафандр"
			return
		suit.body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
		douse(H, 10)
		var/burn = H.getFireLoss()
		var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
		if(differs(burn, expected_burn(10, head_share), CE_ACID_BURN_SLACK) || differs(head.burn_dam, burn, CE_ACID_BURN_SLACK))
			failures += "скафандр на всё тело без шлема, 10 ед.: ожог [burn], из них голове [head.burn_dam]; ожидалось [expected_burn(10, head_share)], и всё — голове"
			break

	var/mob/living/carbon/human/proofed = make_human()
	proofed.unacidable = TRUE
	douse(proofed, 10)
	if(proofed.getFireLoss() || count_disfigured(proofed))
		failures += "кислотостойкий человек, 10 ед.: ожог [proofed.getFireLoss()], обезображено частей тела [count_disfigured(proofed)]; ожидалось ничего"

#undef CE_ACID_BURN_SLACK


/*
	Тесты урона по видам, перенесённые из `code/unit_tests/mob_tests.dm` и модпаков `tajara` и
	`resomi`. Шаблон `/datum/unit_test/mob_damage` и шаблоны видов остались на своих местах —
	сюда переехали только проверки `DAMAGE_BRUTE`: из шести типов урона через CE идёт только он.
	Тест бьёт в грудь тупым уроном 4, без флагов.

	Ожидания — такие, какие даёт CE:
	- без естественной брони урон меняет только `brute_mod` вида (Unathi, Tajara, Resomi);
	- IPC меньше 4 только за счёт кинетической брони протезов из `ipc_mods`. Когда её заменит
	  плотность, ожидание придётся поменять — README, «Протезы: плотность вместо брони»;
	- GAS без урона: хитин — жёсткая броня с 60 Bay МПа тупой оси, а у удара силой 4 тупое
	  пробитие 30. CE гасит его насухо.

	`STANDARD`, `ARMORED` и `EXTRA_VULNERABLE` объявлены в `mob_tests.dm` и не сбрасываются,
	а `IMMUNE` там сброшен через `#undef`, поэтому здесь своё имя.

	Tajara и Resomi подключаются не глобально, а картой (`maps/sierra/sierra.dm`,
	`mods/dev_mode`), раньше `global_modpacks.dm`. Поэтому их модпаки уже объявлены к этому
	месту, и без них проверки просто не компилируются.
*/
#define CE_EXPECT_IMMUNE 3

/datum/unit_test/mob_damage/brute
	name = "MOB: Human Brute damage check"
	damagetype = DAMAGE_BRUTE

/datum/unit_test/mob_damage/unathi/brute
	name = "MOB: Unathi Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = ARMORED

/datum/unit_test/mob_damage/skrell/brute
	name = "MOB: Skrell Brute Damage Check"
	damagetype = DAMAGE_BRUTE

/datum/unit_test/mob_damage/vox/brute
	name = "MOB: Vox Brute Damage Check"
	damagetype = DAMAGE_BRUTE

/datum/unit_test/mob_damage/diona/brute
	name = "MOB: Diona Brute Damage Check"
	damagetype = DAMAGE_BRUTE

/datum/unit_test/mob_damage/nabber/brute
	name = "MOB: GAS Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = CE_EXPECT_IMMUNE

/datum/unit_test/mob_damage/machine/brute
	name = "MOB: IPC Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = ARMORED

#ifdef MODPACK_TAJARA
/datum/unit_test/mob_damage/tajara/brute
	name = "MOB: Tajara Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = EXTRA_VULNERABLE
#endif

#ifdef MODPACK_RESOMI
/datum/unit_test/mob_damage/resomi/brute
	name = "MOB: Resomi Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = EXTRA_VULNERABLE
#endif

#undef CE_EXPECT_IMMUNE
#undef CE_PROMISE_STOPS
#undef CE_PROMISE_DAMPENS
#undef CE_PROMISE_PENETRATES
#undef CE_ARENA_RADIUS
