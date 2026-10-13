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

// Псионики видят объекты на псионическом плане, пока их способности активны и не подавлены.
/mob/living/update_living_sight()
	. = ..()
	if(psi && !psi.suppressed)
		set_see_invisible(max(see_invisible, SEE_INVISIBLE_PSI_PLANE))
