/mob/living/proc/invoke_psi_powers(list/powers, atom/target)
	if(!psi || !psi.can_use())
		return FALSE
	for(var/thing in powers)
		var/singleton/psionic_power/power = thing
		if(power.use_intent && power.use_intent != a_intent)
			continue
		var/obj/item/result = power.invoke(src, target)
		if(result)
			power.handle_post_power(src, target)
			if(istype(result))
				sound_to(src, sound('sound/effects/psi/power_evoke.ogg'))
				LAZYADD(psi.manifested_items, result)
				put_in_hands(result)
			return TRUE
	return FALSE

/mob/living/UnarmedAttack(atom/A, proximity)
	. = ..()
	if(. && psi)
		for(var/faculty in GLOB.psi_faculty_ids)
			if(invoke_psi_powers(psi.get_melee_powers(faculty), A))
				return FALSE

/mob/living/RangedAttack(atom/A, params)
	if(psi)
		for(var/faculty in GLOB.psi_faculty_ids)
			if(invoke_psi_powers(psi.get_ranged_powers(faculty), A))
				return TRUE
	. = ..()

/mob/living/proc/check_psi_grab(obj/item/grab/grab)
	if(psi && ismob(grab.affecting))
		for(var/faculty in GLOB.psi_faculty_ids)
			if(invoke_psi_powers(psi.get_grab_powers(faculty), grab.affecting))
				return FALSE

/mob/living/attack_empty_hand(bp_hand)
	if(psi)
		if(invoke_psi_powers(psi.get_manifestations(), src))
			return FALSE
	. = ..()
