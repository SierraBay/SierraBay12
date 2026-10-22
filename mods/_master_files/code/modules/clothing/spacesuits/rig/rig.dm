/*
	COMBAT_EXTENDED — состояние и жар брони деталей РИГа при осмотре блока управления
	(`mods/combat_extended/code/rig_armor.dm`). Убранные детали лежат в блоке, и иначе их не осмотреть.
*/

/obj/item/rig/examine(mob/user, distance, is_adjacent, infix = "", suffix = "")
	. = ..()
	for(var/line in ce_get_examine_lines())
		to_chat(user, line)
