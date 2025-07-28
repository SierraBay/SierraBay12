/mob/living/carbon/human/proc/process_spawn_limbs()
	for(var/limb_name in client.prefs.limb_list)
		var/obj/item/organ/external/limb = get_organ(limb_name)
		var/limb_type = client.prefs.limb_list[limb_name]
		var/singleton/cyber_choose/limb/data = GET_SINGLETON(text2path(limb_type))
		if(!data.robolimb_data)
			limb.droplimb()
			qdel(limb)
		else
			limb.robotize(data.robolimb_data.company)
