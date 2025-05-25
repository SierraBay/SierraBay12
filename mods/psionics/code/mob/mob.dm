/mob/living
	var/datum/psi_complexus/psi

/mob/living/Login()
	. = ..()
	if(psi)
		psi.update(TRUE)
		if(!psi.suppressed)
			psi.show_auras()

/mob/living/Destroy()
	QDEL_NULL(psi)
	. = ..()

/mob/living/proc/set_psi_rank(faculty, rank, take_larger, defer_update, temporary)
	if(!src.zone_sel)
		to_chat(src, SPAN_NOTICE("Вы чувствуете, как что-то странное касается вашего разума... но ваш разум не способен это осознать."))
		return
	if(!psi)
		psi = new(src)
	var/current_rank = psi.get_rank(faculty)
	if(current_rank != rank && (!take_larger || current_rank < rank))
		psi.set_rank(faculty, rank, defer_update, temporary)

/mob/living/proc/deflect_psionic_attack(attacker)
	var/blocked = 80 * get_blocked_ratio(null, DAMAGE_PSIONIC)
	if(prob(blocked))
		if(attacker)
			to_chat(attacker, SPAN_WARNING("Твое ментальное воздействие отражено с помощью защиты [src]!"))
			to_chat(src, SPAN_DANGER("[attacker] ментально на тебя воздействует, но ты отражаешь его атаку!"))
		return TRUE
	return FALSE
