/obj/item/grab/resolve_attackby(atom/A, mob/user, click_params)
	if (QDELETED(src) || !assailant)
		return TRUE
	if (A.use_grab(src, user, click_params))
		if (QDELETED(src))
			return TRUE
		assailant.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		action_used()
		if (current_grab.downgrade_on_action)
			downgrade()
		return TRUE
	return ..()
