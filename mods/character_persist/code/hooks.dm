/hook/roundend/proc/character_persist_roundend()
	character_persist_roundend_process()
	return TRUE


/hook/death/proc/character_persist_death(mob/living/carbon/human/H, gibbed)
	if (!istype(H))
		return TRUE
	if (character_persist_is_virtual_body(H) || character_persist_is_offstation_antag(H))
		return TRUE
	if (character_persist_in_announced_evac_pod(H))
		var/datum/preferences/prefs = character_persist_prefs_of(character_persist_ckey_of(H))
		if (prefs?.character_persist)
			H.character_persist_round_hold = TRUE
			character_persist_record_skip(H, gibbed)
			return TRUE
	character_persist_try_clear(H, gibbed ? "gibbed" : "death")
	return TRUE


/obj/machinery/cryopod/despawn_occupant()
	if (ishuman(occupant) && occupant.stat != DEAD)
		character_persist_try_save(occupant, "cryo")
	return ..()
