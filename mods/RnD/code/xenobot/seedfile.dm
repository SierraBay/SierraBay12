/datum/computer_file/binary/plantgene
	filetype = "PDNA"
	size = 10

	var/genesource = ""
	var/genesource_uid = 0
	var/genetype    // Label used when applying trait.
	var/list/values // Values to copy into the target seed datum.

/datum/computer_file/binary/plantgene/clone()
	var/datum/computer_file/binary/plantgene/F = ..()
	F.genesource = genesource
	F.genesource_uid = genesource_uid
	F.genetype = genetype
	F.values = deepCopyList(values)

	return F

/datum/computer_file/binary/plantgene/proc/update_name()
	filename = "PL_GENE_[SSplants.gene_tag_masks[genetype]]_[genesource_uid]"

/datum/computer_file/binary/plantgene/ui_data()
	var/list/data = list(
		"filename" = filename,
		"source" = genesource,
		"strain" = genesource_uid,
		"tag" = genetype,
		"size" = size,
		"mask" = SSplants.gene_tag_masks[genetype]
	)
	return data


//Returns a list of the desired trait values.
/datum/seed/proc/get_gene(genetype)
	if(!genetype)
		return null

	var/list/traits_to_copy
	var/datum/computer_file/binary/plantgene/P = new()
	P.genetype = genetype
	P.genesource_uid = uid
	P.genesource = "[display_name]"
	if(!roundstart)
		P.genesource += " (variety #[uid])"
	P.update_name()

	P.values = list()

	switch(genetype)
		if(GENE_BIOCHEMISTRY)
			P.values["[TRAIT_CHEMS]"] =        chems
			P.values["[TRAIT_EXUDE_GASSES]"] = exude_gasses
			traits_to_copy = list(TRAIT_POTENCY)
		if(GENE_OUTPUT)
			traits_to_copy = list(TRAIT_PRODUCES_POWER,TRAIT_BIOLUM)
		if(GENE_ATMOSPHERE)
			traits_to_copy = list(TRAIT_HEAT_TOLERANCE,TRAIT_LOWKPA_TOLERANCE,TRAIT_HIGHKPA_TOLERANCE)
		if(GENE_HARDINESS)
			traits_to_copy = list(TRAIT_TOXINS_TOLERANCE,TRAIT_PEST_TOLERANCE,TRAIT_WEED_TOLERANCE,TRAIT_ENDURANCE)
		if(GENE_METABOLISM)
			P.values["product_type"] = product_type
			traits_to_copy = list(TRAIT_REQUIRES_NUTRIENTS,TRAIT_REQUIRES_WATER,TRAIT_ALTER_TEMP)
		if(GENE_VIGOUR)
			traits_to_copy = list(TRAIT_PRODUCTION,TRAIT_MATURATION,TRAIT_YIELD,TRAIT_SPREAD)
		if(GENE_DIET)
			P.values["[TRAIT_CONSUME_GASSES]"] = consume_gasses
			traits_to_copy = list(TRAIT_CARNIVOROUS,TRAIT_PARASITE,TRAIT_NUTRIENT_CONSUMPTION,TRAIT_WATER_CONSUMPTION)
		if(GENE_ENVIRONMENT)
			traits_to_copy = list(TRAIT_IDEAL_HEAT,TRAIT_IDEAL_LIGHT,TRAIT_LIGHT_TOLERANCE)
		if(GENE_PIGMENT)
			traits_to_copy = list(TRAIT_PLANT_COLOUR,TRAIT_PRODUCT_COLOUR,TRAIT_BIOLUM_COLOUR,TRAIT_LEAVES_COLOUR)
		if(GENE_STRUCTURE)
			traits_to_copy = list(TRAIT_PLANT_ICON,TRAIT_PRODUCT_ICON,TRAIT_HARVEST_REPEAT,TRAIT_LARGE)
		if(GENE_FRUIT)
			traits_to_copy = list(TRAIT_STINGS,TRAIT_EXPLOSIVE,TRAIT_FLESH_COLOUR,TRAIT_JUICY)
		if(GENE_SPECIAL)
			traits_to_copy = list(TRAIT_TELEPORTING)

	for(var/trait in traits_to_copy)
		P.values["[trait]"] = get_trait(trait)
	return (P ? P : 0)
