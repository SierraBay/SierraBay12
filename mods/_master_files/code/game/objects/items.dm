/*
	COMBAT_EXTENDED — парирование с прочностью оружия (`mods/combat_extended/code/weapon_parry.dm`).

	Удачное парирование Bay — в `handle_shield()` базовой вещи — отдаётся моду. Удар, урон которого
	дальше пройдёт броню, оружие встречает первым слоем брони, как щит: тогда `handle_shield()` его
	не отменяет, а отдаёт проходу по слоям. Парирует только первое оружие, встретившее удар, и
	только не на намерении помощи: Bay обнуляет на нём шанс парирования, но двуручное оружие в двух
	руках прибавляет свой бонус уже после этого.

	Порез о вещь при обезоруживании переехал в ответный удар, поэтому здесь он выключен. У ружья свой
	оверрайд без `..()`, и его выстрел при обезоруживании бросает мод отдельно
	(`mods/combat_extended/code/disarm_gunfire.dm`). Осмотр показывает износ оружия без материала: у
	материального его показывает Bay по здоровью атома.
*/

/obj/item/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	var/mob/living/carbon/human/holder = user
	if(ce_parry_enabled && (user.a_intent == I_HELP || (istype(holder) && holder.ce_shield_hit)))
		return 0
	. = ..()
	if(. && ce_parry_enabled && !ce_on_parried(user, damage, damage_source, attacker, def_zone, attack_text))
		return 0


/obj/item/on_disarm_attempt(mob/target, mob/living/attacker)
	if(ce_parry_enabled)
		return 0
	return ..()


/obj/item/examine(mob/user, distance, is_adjacent)
	. = ..()
	var/line = ce_get_parry_examine_line()
	if(line)
		to_chat(user, line)
