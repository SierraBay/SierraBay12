/*
	Внешние бронеэлементы меха — навесная броня, по одному элементу на часть: голову, корпус,
	каждую руку и каждую ногу.

	Бронеэлемент — обычная байевская броня: список `armor` на шкале `code/__defines/armor.dm`, как
	у любого бронежилета. Чисел под каждый снаряд у него нет: что его пробивает, сколько урона
	проходит и как быстро он изнашивается, модпак combat_extended считает из урона и
	`armor_penetration` снаряда и из рейтинга самого элемента. Изношенный элемент отваливается
	(`destroy_armour()`): когда именно, решает тот же модпак.

	Держит бронеэлемент только пули и лучи, и только той части, в которую пришлось попадание
	(`/mob/living/exosuit/get_armors_by_zone()`).

	Приборы меха — анализатор, меню пилота и сообщения диагностики — читают бронеэлемент через
	`get_integrity()` и `get_status_notes()`: на нуле целостности он отваливается.
*/

///Целостность, выше которой бронеэлемент цел, и целостность, выше которой он потрёпан. Ниже — вот-вот отвалится
#define EXTERNAL_ARMOUR_INTACT_ABOVE 0.66
#define EXTERNAL_ARMOUR_WORN_ABOVE 0.33

/obj/item/mech_component
	///Внешний бронеэлемент, навешенный на эту часть
	var/obj/item/mech_external_armor/installed_armor
	///Есть ли у части крепления под внешний бронеэлемент. Без них новый на неё не навесить
	var/can_have_external_armour = TRUE
	///Можно ли снять с части навешенный бронеэлемент
	var/armour_can_be_removed = TRUE

/obj/item/mech_component/Destroy()
	QDEL_NULL(installed_armor)
	return ..()

///Навешивает бронеэлемент на часть. Подходит ли он сюда и откуда берётся, проверяет вызвавший
/obj/item/mech_component/proc/install_external_armour(obj/item/mech_external_armor/plate)
	ASSERT(istype(plate))
	ASSERT(!installed_armor)
	plate.forceMove(src)
	installed_armor = plate
	plate.owner = src
	if(!QDELETED(owner))
		owner.update_icon()

///Снимает бронеэлемент с части и возвращает его. Лежать он остаётся внутри части: куда его деть, решает вызвавший
/obj/item/mech_component/proc/remove_external_armour()
	var/obj/item/mech_external_armor/plate = installed_armor
	if(!plate)
		return
	installed_armor = null
	plate.owner = null
	if(!QDELETED(src) && !QDELETED(owner))
		owner.update_icon()
	return plate

///Состояние спрайта брони на этой части для `base_state` — её icon_state или его варианта. null — рисовать нечего
/obj/item/mech_component/proc/get_external_armour_state(base_state = icon_state)
	if(!installed_armor?.icon_state_suffix)
		return null
	var/static/list/armour_states = icon_states('mods/mechs_by_shegar/icons/external_armour.dmi')
	var/armour_state = "[base_state]_[installed_armor.icon_state_suffix]"
	return (armour_state in armour_states) ? armour_state : null

///Ступень состояния внешнего бронеэлемента части, `MECH_EXTERNAL_ARMOUR_*`: по ней диагностика решает, когда сообщать пилотам
/obj/item/mech_component/proc/get_external_armour_condition()
	if(!installed_armor)
		return MECH_EXTERNAL_ARMOUR_NONE
	var/integrity = installed_armor.get_integrity()
	if(integrity > EXTERNAL_ARMOUR_INTACT_ABOVE)
		return MECH_EXTERNAL_ARMOUR_INTACT
	if(integrity > EXTERNAL_ARMOUR_WORN_ABOVE)
		return MECH_EXTERNAL_ARMOUR_WORN
	return MECH_EXTERNAL_ARMOUR_FAILING

///Строка о внешнем бронеэлементе части для приборов меха: анализатора и меню пилота
/obj/item/mech_component/proc/get_external_armour_readout()
	if(!installed_armor)
		return "External armour: none"
	. = "External armour: [installed_armor.name], [installed_armor.get_integrity_percent()]%"
	for(var/note in installed_armor.get_status_notes())
		. += ", [note]"


/obj/item/mech_external_armor
	name = "mech external armour plate"
	desc = "Older exosuits carried their armour inside the hull, where it did little good. Modern plates bolt on from the outside, one to a part."
	icon = 'mods/mechs_by_shegar/icons/mech_parts_held.dmi'
	icon_state = "external_armor"
	///Спрайт разбитого бронеэлемента
	var/broken_icon_state = "external_armor_broken"
	///Разбит ли бронеэлемент. Разбитый на меха не навесить
	var/broken = FALSE
	///Часть меха, на которую бронеэлемент навешен
	var/obj/item/mech_component/owner
	///Приписывается к icon_state части меха, чтобы получить спрайт брони на ней. null — на мехе бронеэлемент не виден
	var/icon_state_suffix
	///Ступень состояния (`MECH_EXTERNAL_ARMOUR_*`), о которой диагностика меха уже сообщила пилотам
	var/reported_condition = MECH_EXTERNAL_ARMOUR_INTACT

/obj/item/mech_external_armor/Destroy()
	owner?.remove_external_armour()
	return ..()

/obj/item/mech_external_armor/examine(mob/user)
	. = ..()
	if(broken)
		to_chat(user, SPAN_WARNING("It is broken and cannot be mounted."))
		return
	to_chat(user, SPAN_NOTICE("Integrity: [get_integrity_percent()]%."))
	for(var/note in get_status_notes())
		to_chat(user, SPAN_WARNING("It is [note]."))

///Целостность бронеэлемента от 0 до 1 для приборов меха и осмотра: на нуле он отваливается.
///Сам по себе бронеэлемент не изнашивается: изнашивает его модпак combat_extended, он же и считает.
///Тот модпак подключается раньше, и переопределить эту процедуру у себя не может
/obj/item/mech_external_armor/proc/get_integrity()
	if(broken)
		return 0
#ifdef MODPACK_COMBAT_EXTENDED
	return ce_get_integrity()
#else
	return 1
#endif

///Целостность в процентах, целым числом
/obj/item/mech_external_armor/proc/get_integrity_percent()
	return round(get_integrity() * 100, 1)

///Что приборам стоит знать о бронеэлементе сверх целостности, list(текст). Пустой — нечего.
///Сейчас это жар, и знает о нём только модпак combat_extended
/obj/item/mech_external_armor/proc/get_status_notes()
	RETURN_TYPE(/list)
#ifdef MODPACK_COMBAT_EXTENDED
	return ce_get_status_notes()
#else
	return list()
#endif

///Бронеэлемент только что пострадал: диагностика меха сообщает пилотам, когда он переходит на ступень хуже
/obj/item/mech_external_armor/proc/report_damage()
	var/obj/item/mech_component/part = owner
	if(!part?.owner)
		return
	var/condition = part.get_external_armour_condition()
	if(condition <= reported_condition)
		return
	reported_condition = condition
	part.owner.diagnostics_alert("[part.name] external armour at [get_integrity_percent()]%.")

///Бронеэлемент разбит: отваливается от части и падает под меха
/obj/item/mech_external_armor/proc/destroy_armour()
	if(broken)
		return
	broken = TRUE
	icon_state = broken_icon_state
	var/obj/item/mech_component/part = owner
	if(!part)
		return
	var/mob/living/exosuit/mech = part.owner
	part.remove_external_armour()
	forceMove(get_turf(part))
	if(QDELETED(mech))
		return
	mech.visible_message(SPAN_DANGER("\The [src] breaks off \the [mech]'s [part.name]!"), exclude_mobs = mech.pilots)
	for(var/mob/living/pilot in mech.pilots)
		to_chat(pilot, SPAN_DANGER("\The [src] breaks off your [part.name]!"))


/obj/item/mech_external_armor/civil
	name = "civil mech external armour"
	desc = "Barely armour at all, just part of the mechanical structure. It stops pistol rounds and little else."
	armor = list(
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_SMALL
		)

/obj/item/mech_external_armor/buletproof
	name = "bulletproof mech external armour"
	desc = "This plate turns aside most bullet calibres up to rifle rounds. Against lasers it is little better than bare structure."
	armor = list(
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_SMALL
		)
	icon_state_suffix = "bullet_armour"

/obj/item/mech_external_armor/laserproof
	name = "laserproof mech external armour"
	desc = "This plate is built to soak up laser fire. Against bullets it stops pistol rounds and little else."
	armor = list(
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_RIFLES
		)
	icon_state_suffix = "laser_armour"

//Деды
/obj/item/mech_external_armor/admin
	name = "experimental mech external armour"
	desc = "A complex NanoTrasen laboratory development. It shrugs off nearly any projectile."
	armor = list(
		bullet = ARMOR_BALLISTIC_HEAVY,
		laser = ARMOR_LASER_HEAVY
		)

#undef EXTERNAL_ARMOUR_INTACT_ABOVE
#undef EXTERNAL_ARMOUR_WORN_ABOVE
