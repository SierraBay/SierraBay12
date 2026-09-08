//Revive from revival stasis
/mob/proc/changeling_revive()
	set category = "Changeling"
	set name = "Revive"
	set desc = "We are ready to revive ourselves on command. Our core can only sustain this twice. It needs new victims to conduct more."

	var/datum/changeling/changeling = changeling_power(0,0,100,DEAD)
	if(!changeling)
		return 0

	if(changeling.max_geneticpoints < 0) //Absorbed by another ling
		to_chat(src, SPAN_WARNING("You have no genomes, not even your own, and cannot revive."))
		return 0
	var/mob/living/carbon/C = src
	// restore us to health
	C.revive()
	// remove our fake death flag
	C.status_flags &= ~(FAKEDEATH)
	// let us move again
	C.UpdateLyingBuckledAndVerbStatus()
	// re-add our changeling powers
	C.make_changeling()
	// sending display messages
	to_chat(C, SPAN_NOTICE("We have regenerated."))
	C.verbs -= /mob/proc/changeling_revive

	return TRUE

//Revive from revival stasis, but one level removed, as the tab refuses to update. Placed in its own tab to avoid hyper-exploding the original tab through the same name being used.

/obj/changeling_revive_holder
	name = "strange object"
	desc = "Please report this object's existence to the dev team! You shouldn't see it."
	mouse_opacity = FALSE
	alpha = 1

/obj/changeling_revive_holder/verb/ling_revive()
	set src = usr.contents
	set category = "Regenerate"
	set name = "Revive"
	set desc = "We are ready to revive ourselves on command. This will tax our core."

	if(!iscarbon(usr))
		return

	var/mob/living/carbon/C = usr
	for (var/obj/item/organ/internal/augment/lingcore/core in C.internal_organs)
		if (!core.stasiscount)
			to_chat(usr, SPAN_WARNING("Our core is unresponsive. It cannot help us, now."))
			return
		core.stasiscount-- // Two uses of revive.
		C.changeling_revive()

	qdel(src)
