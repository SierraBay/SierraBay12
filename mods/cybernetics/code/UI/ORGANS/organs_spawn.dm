/mob/living/carbon/human/proc/process_spawn_organs()
	for(var/organ_name in client.prefs.organ_list)
		var/obj/item/organ/organ = get_organ(organ_name)
		if(!organ)
			continue
		organ.robotize()
