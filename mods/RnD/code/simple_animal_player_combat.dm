// Player-controlled simple animal combat
// Lets ghosts occupying derelict (or other) mobs use ranged fire and special attacks.

/mob/living/simple_animal/Login()
	. = ..()
	if(!client)
		return
	if(projectiletype)
		to_chat(src, SPAN_NOTICE("Click a distant target to fire."))
	if(!isnull(special_attack_min_range))
		to_chat(src, SPAN_NOTICE("Middle-click a target (or use Special Ability) for your special attack."))
		verbs |= /mob/living/simple_animal/verb/simple_animal_special_ability
	else
		verbs -= /mob/living/simple_animal/verb/simple_animal_special_ability

/// Fire projectiletype at non-adjacent targets when a player clicks.
/mob/living/simple_animal/RangedAttack(atom/A, params)
	if(..())
		return TRUE
	if(stat || !A || a_intent == I_HELP)
		return FALSE
	if(!projectiletype)
		return FALSE
	if(!ICheckRangedAttack(A))
		return FALSE
	return shoot_target(A)

/// Middle-click uses special attack when ready and in range; otherwise falls through (point, etc).
/mob/living/simple_animal/MiddleClickOn(atom/A)
	if(!isnull(special_attack_min_range) && can_special_attack(A))
		special_attack_target(A)
		return TRUE
	return ..()

/mob/living/simple_animal/verb/simple_animal_special_ability(atom/target as mob|obj|turf in view())
	set name = "Special Ability"
	set category = "Abilities"
	set desc = "Use your special attack on a visible target."

	if(isnull(special_attack_min_range))
		to_chat(src, SPAN_WARNING("You have no special ability."))
		return
	try_player_special_attack(target, feedback = TRUE)

/mob/living/simple_animal/proc/try_player_special_attack(atom/A, feedback = TRUE)
	if(stat || !client || !A)
		return FALSE
	if(isnull(special_attack_min_range) || isnull(special_attack_max_range))
		return FALSE
	if(!can_special_attack(A))
		if(feedback)
			var/distance = get_dist(src, A)
			if(distance < special_attack_min_range || distance > special_attack_max_range)
				to_chat(src, SPAN_WARNING("That target is out of range for your special ability ([special_attack_min_range]-[special_attack_max_range])."))
			else if(!isnull(special_attack_cooldown) && last_special_attack + special_attack_cooldown > world.time)
				var/seconds = max(1, round((last_special_attack + special_attack_cooldown - world.time) / 10))
				to_chat(src, SPAN_WARNING("Your special ability is recharging ([seconds]s)."))
			else if(!isnull(special_attack_charges) && special_attack_charges <= 0)
				to_chat(src, SPAN_WARNING("You have no special ability charges left."))
			else
				to_chat(src, SPAN_WARNING("You cannot use your special ability right now."))
		return FALSE
	special_attack_target(A)
	return TRUE

/mob/living/simple_animal/Stat()
	. = ..()
	if(!statpanel("Status") || !client)
		return
	// Re-include health here in case this definition replaces the base simple_animal Stat.
	if(show_stat_health)
		stat(null, "Health: [round((health / maxHealth) * 100)]%")
	if(projectiletype && needs_reload)
		stat(null, "Ammo: [max(0, reload_max - reload_count)]/[reload_max]")
	if(!isnull(special_attack_min_range))
		if(!isnull(special_attack_charges) && special_attack_charges <= 0)
			stat(null, "Special: depleted")
		else if(!isnull(special_attack_cooldown) && last_special_attack && (last_special_attack + special_attack_cooldown > world.time))
			stat(null, "Special: [max(1, round((last_special_attack + special_attack_cooldown - world.time) / 10))]s")
		else
			stat(null, "Special: ready (Middle-click)")
