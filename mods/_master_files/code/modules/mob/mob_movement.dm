/*
	COMBAT_EXTENDED — тот, кто смотрит в прицел или бинокль, не бегает
	(`mods/combat_extended/code/scopes.dm`): быстрый шаг не выбирается, пока прицел не снят.
*/
/mob/living/set_move_intent(singleton/move_intent/next_intent)
	if(ce_scope_item && next_intent && (next_intent.flags & MOVE_INTENT_QUICK))
		to_chat(src, SPAN_WARNING("You can't run while looking through \the [ce_scope_item]."))
		return FALSE
	return ..()
