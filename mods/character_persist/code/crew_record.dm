/datum/computer_file/report/crew_record/load_from_mob(mob/living/carbon/human/H)
	. = ..()
	character_persist_apply_crew_record(src, H)
