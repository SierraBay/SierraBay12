/*
	COMBAT_EXTENDED — щиты через проход по слоям (`mods/combat_extended/code/shields.dm`).

	Бросок шанса блока Bay выключен: щит встречает атаку в `human/check_shields()`. Использование
	щита в руке переключает стойку, а у энергощита включает его — выключается включённый энергощит
	альт-кликом. В стойке «укрыться» щит в руке рисуется поднятым. Кнопка действия щита — у
	аксессуара, если он висит на щите. Выключатель `ce_shields_enabled` возвращает к Bay бросок,
	использование в руке и поднятый спрайт; исправленный спрайт в правой руке остаётся.
*/

/obj/item/shield/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	if(ce_shields_enabled)
		return 0
	return ..()


/obj/item/shield/attack_self(mob/living/user)
	if(!ce_shields_enabled)
		return ..()
	ce_toggle_stance(user)
	return TRUE


/obj/item/shield/energy/attack_self(mob/living/user)
	if(!ce_shields_enabled || !active)
		return ..()
	ce_toggle_stance(user)
	return TRUE


/obj/item/shield/energy/AltClick(mob/user)
	if(!ce_shields_enabled || !active || !user.IsHolding(src))
		return ..()
	deactivate(user)
	return TRUE


/// Альт-клик по щиту в руке сначала отдаётся аксессуару.
/obj/item/shield/AltClick(mob/user)
	if(ce_accessory && user.IsHolding(src) && ce_accessory.alt_activate(user, src))
		return TRUE
	return ..()


/obj/item/shield/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(istype(tool, /obj/item/ce_shield_accessory))
		ce_attach_accessory(tool, user)
		return TRUE
	if(ce_accessory && isScrewdriver(tool))
		ce_remove_accessory(user)
		return TRUE
	return ..()


/obj/item/shield/ui_action_click(mob/living/user)
	if(ce_accessory)
		ce_accessory.activate(user, src)
		return
	return ..()


/// Щит в руке в стойке «укрыться» рисуется поднятым, а ошибка спрайта в правой руке исправлена.
/obj/item/shield/get_mob_overlay(mob/user_mob, slot)
	. = ..()
	if(slot == slot_l_hand_str || slot == slot_r_hand_str)
		. = ce_get_hand_overlay(., slot == slot_r_hand_str)


/obj/item/shield/examine(mob/user, distance, is_adjacent, infix = "", suffix = "")
	. = ..()
	for(var/line in ce_get_examine_lines())
		to_chat(user, line)


/obj/item/shield/Destroy()
	QDEL_NULL(ce_accessory)
	return ..()
