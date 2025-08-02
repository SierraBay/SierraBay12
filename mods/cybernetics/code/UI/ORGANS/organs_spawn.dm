#define ASSISTED "assisted"
#define SYNTETHIC "syntethic"

/mob/living/carbon/human/proc/process_spawn_organs()
	for(var/organ_name in client.prefs.organ_list)
		var/obj/item/organ/organ = internal_organs_by_name[organ_name]
		var/organ_type = client.prefs.organ_list[organ_name]
		var/singleton/cyber_choose/organ/organ_prototype = GET_SINGLETON(text2path(organ_type))
		if(!organ || !organ_prototype)
			continue
		if(organ_prototype.organ_type == SYNTETHIC)
			organ.robotize()
		else if(organ_prototype.organ_type == ASSISTED)
			organ.mechassist()

#undef ASSISTED
#undef SYNTETHIC
