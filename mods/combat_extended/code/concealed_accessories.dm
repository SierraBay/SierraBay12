/*
	COMBAT_EXTENDED — аксессуары под верхней одеждой.

	Кор не называет в осмотре человека аксессуары униформы, закрытые верхней одеждой: аксессуар
	закрыт, если верхняя одежда закрывает его `body_location` (`get_visible_accessories()`). Но рядом
	с униформой в том же осмотре стоит ссылка «[?]» — осмотр самой униформы, — и он перечислял все её
	аксессуары подряд, вместе с состоянием их брони, а кодекс униформы — чем их латать. Скрытый жилет
	под курткой находился в один клик.

	Здесь то же правило получает всё, что вещь рассказывает о своих аксессуарах: осмотр вещи
	(`code/modules/clothing/clothing_accessories.dm`), состояние и жар брони аксессуаров
	(`mods/_master_files/code/modules/clothing/_clothing.dm`) и блоки кодекса о починке
	(`armor_repair.dm`). Правило общее для всех аксессуаров, а не только для скрытой брони: кобуру
	или значок под курткой не видно так же.

	Окно обыска (`show_inv()`) правило не трогает: обыскивают руками, и закрытый аксессуар обыск
	находит.
*/

/**
 * Аксессуары вещи, о которых она рассказывает `viewer`. Носитель и призраки видят все, остальные —
 * те, что не закрыты верхней одеждой. Без `viewer` — взгляд со стороны: так читает кодекс, он не
 * знает, кому его покажут.
 */
/obj/item/clothing/proc/ce_get_accessories_seen_by(mob/viewer)
	RETURN_TYPE(/list)
	if(viewer && (viewer == loc || isghost(viewer)))
		return accessories
	return get_visible_accessories()


/// Строки осмотра вещи о состоянии и жаре брони её аксессуаров — тех, что видит `viewer`.
/obj/item/clothing/proc/ce_get_accessory_armor_lines(mob/viewer)
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/clothing/accessory/accessory in ce_get_accessories_seen_by(viewer))
		if(accessory.accessory_flags & ACCESSORY_HIDDEN)
			continue
		var/datum/extension/armor/accessory_armor = get_extension(accessory, /datum/extension/armor)
		if(!accessory_armor)
			continue
		. += accessory_armor.ce_get_condition_lines(accessory.name)
		. += accessory_armor.ce_get_heat_lines(accessory.name)
