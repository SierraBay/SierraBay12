// OOC_NOTES
/mob/CanUseTopic(mob/user, datum/topic_state/state, href_list)
	// Reading someone's OOC notes is a public, read-only lookup, exactly like the flavor text
	// [More] link that core whitelists the same way one line below. Without this
	// default_can_use_topic() hands ghosts STATUS_UPDATE, /atom/Topic() refuses to dispatch, and
	// the link silently does nothing. item/refresh stay excluded so the physical_state recheck in
	// /mob/living/carbon/human/CanUseTopic() keeps working.
	if(href_list && href_list["ooc_notes"] && !href_list["item"] && !href_list["refresh"])
		return STATUS_INTERACTIVE
	return ..()
