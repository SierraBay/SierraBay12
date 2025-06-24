//'Place of birth' changed to 'Residence'
/obj/item/passport/set_info(mob/living/carbon/human/H)
	if(!istype(H))
		return
	var/singleton/cultural_info/culture = H.get_cultural_value(TAG_HOMEWORLD)
	var/pob = culture ? culture.name : "Unset"
	if(H.dna)
		fingerprint = md5(H.dna.uni_identity)
	else
		fingerprint = "N/A"
	info = "\icon[src] [src]:\nName: [H.real_name]\nSpecies: [H.get_species()]\nPronouns: [H.pronouns]\nAge: [H.age]\nResidence: [pob]\nFingerprint: [fingerprint]"