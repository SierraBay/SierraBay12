GLOBAL_TYPED_NEW(dview_mob, /mob/dview)


/mob/dview
	anchored = TRUE
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	see_in_dark = 1e6
	simulated = FALSE
	virtual_mob = null


/mob/dview/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE


/mob/dview/Initialize()
	. = ..()
	STOP_PROCESSING_MOB(src)


// Version of view() which ignores darkness
/proc/dview(range = world.view, center, invis_flags = EMPTY_BITFIELD)
	RETURN_TYPE(/list)
	if (!center)
		return
	var/mob/dview/dview_mob = GLOB.dview_mob
	dview_mob.loc = center
	dview_mob.see_invisible = invis_flags
	. = view(range, dview_mob)
	dview_mob.loc = null
