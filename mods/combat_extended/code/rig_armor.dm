/*
	COMBAT_EXTENDED — броня деталей РИГа через блок управления.

	Убранные детали РИГа — шлем, перчатки, грудная секция и ботинки — лежат внутри блока управления,
	и ни осмотреть, ни залатать, ни полить их по отдельности нельзя. Поэтому к ним ведёт блок: клик
	хламом латает деталь в зоне прицела (`armor_repair.dm`), клик хладагентом поливает самую горячую
	деталь, а брызги на блок остужают все (`laser_coolant.dm`). Осмотр блока говорит состояние и жар
	каждой детали. Выпущенные детали блок ведёт так же, как убранные.

	Клики приходят из `use_tool()` блока в моде hardsuits. Хладагент — раньше модулей: модуль
	химикатов забирает любую открытую ёмкость. Хлам — после них: модуль саморемонта забирает сталь
	у носителя раньше брони. Осмотр — оверрайд `examine()` блока в `_master_files`.
*/

/// Детали РИГа, которые у него есть: шлем, перчатки, грудная секция, ботинки.
/obj/item/rig/proc/ce_get_pieces()
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/clothing/piece in list(helmet, gloves, chest, boots))
		. += piece


/// Что держит действие с вещью в `do_after()`: у детали, убранной в блок РИГа, — блок, чтобы унесённый
/// блок прерывал действие, иначе сама вещь.
/obj/item/proc/ce_get_do_after_target()
	return istype(loc, /obj/item/rig) ? loc : src


/// Деталь РИГа, которую латает клик по блоку управления с прицелом в зону `zone`: голова — шлем,
/// кисти — перчатки, стопы — ботинки, остальное — грудная секция. null — такой детали у РИГа нет.
/obj/item/rig/proc/ce_get_repair_piece(zone)
	RETURN_TYPE(/obj/item/clothing)
	switch(zone)
		if(BP_HEAD, BP_EYES, BP_MOUTH)
			return helmet
		if(BP_L_HAND, BP_R_HAND)
			return gloves
		if(BP_L_FOOT, BP_R_FOOT)
			return boots
	return chest


/**
 * Латает хламом `tool` деталь РИГа в зоне прицела — как клик по ней самой, грудную секцию по группе
 * зон прицела. FALSE — детали в зоне прицела нет, у грудной секции пробоины или деталь не латается:
 * клик идёт дальше, и пробоины латает грудная секция.
 */
/obj/item/rig/proc/ce_try_piece_repair(obj/item/tool, mob/living/user)
	var/obj/item/clothing/piece = ce_get_repair_piece(user.zone_sel?.selecting)
	if(!piece)
		return FALSE
	var/obj/item/clothing/suit/space/suit = piece
	if(istype(suit) && suit.ce_has_breaches())
		return FALSE
	return piece.ce_try_armor_repair(tool, user)


/**
 * Льёт хладагент на самую горячую деталь РИГа, как на вещь с аксессуарами. FALSE — `tool` не ёмкость
 * или горячей брони нет, и клик идёт дальше.
 */
/obj/item/rig/proc/ce_try_pour_coolant(obj/item/tool, mob/living/user)
	return ce_try_pour_coolant_on(ce_get_pieces(), tool, user)


/// Строки осмотра блока: состояние и жар брони каждой детали, с её названием, как у аксессуаров
/// плитоноски. Пустой list — детали целы и холодные.
/obj/item/rig/proc/ce_get_examine_lines()
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/piece as anything in ce_get_pieces())
		var/datum/extension/armor/armor = get_extension(piece, /datum/extension/armor)
		if(!armor)
			continue
		for(var/line in armor.ce_get_condition_lines(piece.name) + armor.ce_get_heat_lines(piece.name))
			. += SPAN_WARNING(line)
