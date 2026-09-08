/hook/roundend/proc/character_persist_roundend()
	character_persist_roundend_process()
	return TRUE


/hook/death/proc/character_persist_death(mob/living/carbon/human/H, gibbed)
	if (!istype(H))
		return TRUE
	character_persist_try_clear(H, gibbed ? "gibbed" : "death")
	return TRUE


/obj/machinery/cryopod/despawn_occupant()
	if (ishuman(occupant) && occupant.stat != DEAD)
		character_persist_try_save(occupant, "cryo")
	return ..()
