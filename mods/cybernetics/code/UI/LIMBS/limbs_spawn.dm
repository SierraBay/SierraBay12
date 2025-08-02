/mob/living/carbon/human/proc/process_spawn_limbs(datum/preferences/input_prefs)
	var/datum/preferences/prefs
	if(input_prefs)
		prefs = input_prefs
	else
		prefs = client.prefs

	for(var/limb_name in prefs.limb_list)
		var/limb_type = prefs.limb_list[limb_name]
		if(limb_type == "Пусто")
			continue
		var/obj/item/organ/external/limb = get_organ(limb_name)
		var/singleton/cyber_choose/limb/data = GET_SINGLETON(text2path(limb_type))
		if(!data.robolimb_data)
			limb.droplimb()
			qdel(limb)
		else
			if(BP_IS_ROBOTIC(limb))
				limb.change_company(data.robolimb_data.company)
			else
				limb.robotize(data.robolimb_data.company)




/obj/item/organ/external/proc/change_company(company, skip_prosthetics = 0, keep_organs = 0)
	update_icon(1)
	if(company)
		var/datum/robolimb/R = all_robolimbs[company]
		if(!istype(R) || (species && (species.name in R.species_cannot_use)) || \
			(species && !(species.get_bodytype(owner) in R.allowed_bodytypes)) || \
			(length(R.applies_to_part) && !(organ_tag in R.applies_to_part)))
			R = basic_robolimb
		else
			model = company
			force_icon = R.icon
			name = "robotic [initial(name)]"
			desc = "[R.desc] It looks like it was produced by [R.company]."
		armor = R.armor
		siemens_coefficient = R.siemens_coefficient
		slowdown = R.speed_modifier
		coolingefficiency = R.coolingefficiency
		expensive = R.expensive
		max_damage = max_damage +  R.addmax_damage
		min_broken_damage = min_broken_damage +  R.addmin_broken_damage
		set_extension(src, /datum/extension/armor, armor)

	return 1
