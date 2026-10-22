/*
	COMBAT_EXTENDED — органы задеваются по остатку пробития.

	Кор версия сравнивает урон с плоским порогом (10, для острого 5) и не знает ни про пробитие,
	ни про броню. Поверх неё ставится бросок на досягаемость из контекста попадания, который
	записал проход по слоям (`organ_depth.dm`).
*/
/obj/item/organ/external/damage_internal_organs(brute, burn, damage_flags)
	// Контекста нет у лазера, энергии, родного тупого урона и прямых вызовов вроде `snacks.dm` —
	// для них всё как раньше.
	var/list/context = owner?.ce_hit_context
	if(!context)
		return ..()

	// Контекст одноразовый: он принадлежит одному попаданию в одну конечность.
	owner.ce_hit_context = null
	if(context[1] != organ_tag)
		return ..()

	// Конечность вот-вот добьют — органы вскрыты, и досягаемость уже ни при чём.
	var/damage_amt = brute
	var/cur_damage = brute_dam
	if((damage_flags & DAMAGE_FLAG_LASER) || BP_IS_ROBOTIC(src))
		damage_amt += burn
		cur_damage += burn_dam
	if(cur_damage + damage_amt >= max_damage)
		return ..()

	if(!prob(context[2] * 100))
		return FALSE
	return ..()
