/singleton/species/alium/tribe
	name = "Tribe humanoid" // temp, just not to overwrite actual aliens
	var/list/custom_regeneration = list()
	var/list/ignore_gases = list()
	var/phoron_guard = FALSE

/singleton/species/alium/tribe/proc/adapt_to_exoplanet(obj/overmap/visitable/sector/exoplanet/E)
	name = SPECIES_ALIEN
	blood_color = RANDOM_RGB
	flesh_color = RANDOM_RGB
	base_color  = RANDOM_RGB

	species_flags = null
	total_health = 200
	brute_mod = 1
	burn_mod = 1
	oxy_mod = 1
	toxins_mod = 1
	radiation_mod = 1
	flash_mod = 1

	stomach_capacity = 5
	gluttonous = 0

	var/datum/gas_mixture/atmosphere = E.exterior_atmosphere
	adapt_to_atmosphere(atmosphere)

	// simple mobs can survive sierra, so we expect at least about the same from humanoids
	// these are the worst values from among all the species
	var/initial_cold_level_1 = 280
	var/initial_cold_level_2 = 220
	var/initial_cold_level_3 = 130

	var/initial_heat_level_1 = 320
	var/initial_heat_level_2 = 370
	var/initial_heat_level_3 = 600

	var/initial_hazard_low_pressure = HAZARD_LOW_PRESSURE * 2
	var/initial_hazard_high_pressure = HAZARD_HIGH_PRESSURE / 0.84615

	if(initial_cold_level_1 < cold_level_1)
		cold_level_1 = initial_cold_level_1
	if(initial_cold_level_2 < cold_level_2)
		cold_level_2 = initial_cold_level_2
	if(initial_cold_level_3 < cold_level_3)
		cold_level_3 = initial_cold_level_3

	if(initial_heat_level_1 > heat_level_1)
		heat_level_1 = initial_heat_level_1
	if(initial_heat_level_2 > heat_level_2)
		heat_level_2 = initial_heat_level_2
	if(initial_heat_level_3 > heat_level_3)
		heat_level_3 = initial_heat_level_3

	if(initial_hazard_low_pressure < hazard_low_pressure)
		hazard_low_pressure = initial_hazard_low_pressure
	if(initial_hazard_high_pressure > hazard_high_pressure)
		hazard_high_pressure = initial_hazard_high_pressure

	var/gas_pressure = atmosphere.return_pressure()

	// random
	total_health = round(total_health * frand(0.8, 1.2), 0.1)

	// Brute mod depends on pressure
	switch(warning_high_pressure)
		if(10001 to INFINITY)
			brute_mod = round(brute_mod * frand(0, 0.3), 0.1)
		if(5001 to 10000)
			//Over 5k KPa
			brute_mod = round(brute_mod * frand(0.3, 0.5), 0.1)
		if(1001 to 5000)
			//Over 1k KPa
			brute_mod = round(brute_mod * frand(0.4, 0.7), 0.1)
		if(500 to 1000)
			//Over 500 KPa
			brute_mod = round(brute_mod * frand(0.5, 1), 0.1)
		else
			// Regular pressure
			brute_mod = round(brute_mod * frand(0.5, 1.5), 0.1)

	// Burn mod depends on temperatures
	switch(heat_level_1)
		if(10001 to INFINITY)
			// Being in an environment over 10000 celsius is a slight discomfort
			burn_mod = round(burn_mod * frand(0, 0.3), 0.1)
		if(5001 to 10000)
			// Extreme temperatures (roughly over 5000 celsius)
			burn_mod = round(burn_mod * frand(0.3, 0.6), 0.1)
		if(1301 to 5000)
			// Very high temperatures (roughly over 1000 celsius)
			burn_mod = round(burn_mod * frand(0.4, 0.8), 0.1)
		if(700 to 1300)
			// High temperatures (roughly over 400 celsius)
			burn_mod = round(burn_mod * frand(0.6, 1), 0.1)
		else
			// Regular temperatures
			burn_mod = round(burn_mod * frand(0.8, 1.2), 0.1)


	// Oxy mod depends on atmosphere
	switch(gas_pressure)
		if(91 to INFINITY)
			oxy_mod = round(oxy_mod * frand(0.5, 1.5), 0.1)
		if(61 to 90)
			// Lower than of Earth
			oxy_mod = round(oxy_mod * frand(0.5, 1), 0.1)
		if(31 to 60)
			// Low atmosphere
			oxy_mod = round(oxy_mod * frand(0.4, 0.8), 0.1)
		if(11 to 30)
			// Very low atmosphere
			oxy_mod = round(oxy_mod * frand(0.3, 0.6), 0.1)
		if(1 to 10)
			// Almost no atmosphere
			oxy_mod = round(oxy_mod * frand(0, 0.3), 0.1)
		else
			// No atmosphere, no need to breath
			oxy_mod = 0

	// Toxin mod depends on the atmosphere and exoplanet type
	if(atmosphere.get_gas(GAS_PHORON) || atmosphere.get_gas(GAS_CHLORINE))
		// Breathing plasma or chlorine
		toxins_mod = round(toxins_mod * frand(0, 0.3), 0.1)
		phoron_guard = TRUE
	else if (atmosphere.get_by_flag(XGM_GAS_CONTAMINANT))
		// Toxic gases in atmosphere
		toxins_mod = round(toxins_mod * frand(0, 0.5), 0.1)
		phoron_guard = TRUE
	else if (istype(E, /obj/overmap/visitable/sector/exoplanet/shrouded))
		// Shrouded planet
		toxins_mod = round(toxins_mod * frand(0, 1), 0.1)
	else
		// All other cases
		toxins_mod = round(toxins_mod * frand(0, 2), 0.1)

	// Necessary in all cases
	has_organ[BP_LUNGS] = /obj/item/organ/internal/lungs/filtered
	ignore_gases = atmosphere.gas

	if(oxy_mod == 0)
		breathing_organ = null
		has_organ.Remove(BP_LUNGS)

	var/radiation_hotspots = FALSE

	for(var/datum/exoplanet_theme/radiation_bombing in E.themes)
		radiation_hotspots = TRUE
		break

	// Radiation mod depends on planet type and radiation hotspots
	if(radiation_hotspots)
		radiation_mod = round(radiation_mod * frand(0, 0.5), 0.1)
	else if (istype(E, /obj/overmap/visitable/sector/exoplanet/shrouded))
		// Shrouded planet
		radiation_mod = round(radiation_mod * frand(0, 1), 0.1)
	else
		// All other cases
		radiation_mod = round(radiation_mod * frand(0, 2), 0.1)

	// Flash mod depends on daylight brightness
	if(E.sun_brightness_modifier < 0)
		flash_mod = round(flash_mod * frand(1.2, 1.5), 0.1)
	else if (E.sun_brightness_modifier <= 0.5)
		flash_mod = round(flash_mod * frand(1, 1.5), 0.1)
	else if (E.sun_brightness_modifier >= 1.2)
		// Shouldn't be possible, but still accounted
		flash_mod = round(flash_mod * frand(0.5, 1), 0.1)
	else
		flash_mod = round(flash_mod * frand(0.5, 1.5), 0.1)

	if(brute_mod < 1 && prob(40) || brute_mod < 0.5)
		species_flags |= SPECIES_FLAG_NO_MINOR_CUT
	if(brute_mod < 0.9 && prob(40) || brute_mod < 0.5)
		species_flags |= SPECIES_FLAG_NO_EMBED
	if(toxins_mod < 0.1)
		species_flags |= SPECIES_FLAG_NO_POISON

	//Gastronomic traits
	taste_sensitivity = pick(TASTE_HYPERSENSITIVE, TASTE_SENSITIVE, TASTE_DULL, TASTE_NUMB)
	gluttonous = pick(0, GLUT_TINY, GLUT_SMALLER, GLUT_ANYTHING)
	stomach_capacity = 5 * stomach_capacity
	if(prob(20))
		gluttonous |= pick(GLUT_ITEM_TINY, GLUT_ITEM_NORMAL, GLUT_ITEM_ANYTHING, GLUT_PROJECTILE_VOMIT)
		if(gluttonous & GLUT_ITEM_ANYTHING)
			stomach_capacity += ITEM_SIZE_HUGE
			traits[/singleton/trait/boon/cast_iron_stomach] = TRAIT_LEVEL_EXISTS

	//Misc traits
	if(E.sun_brightness_modifier < 0)
		darksight_range = rand(4,8)
		darksight_tint = pick(DARKTINT_MODERATE,DARKTINT_GOOD)
	else if (E.sun_brightness_modifier <= 0.5)
		darksight_range = rand(2,8)
		darksight_tint = pick(DARKTINT_MODERATE,DARKTINT_GOOD)
	else
		darksight_range = rand(1,8)
		darksight_tint = pick(DARKTINT_NONE,DARKTINT_MODERATE,DARKTINT_GOOD)

	if(prob(40))
		genders = list(PLURAL)
	if(prob(10))
		slowdown += pick(-1,1)
	if(prob(10))
		species_flags |= SPECIES_FLAG_NO_SLIP
	if(prob(10))
		species_flags |= SPECIES_FLAG_NO_TANGLE
	if(prob(5))
		species_flags |= SPECIES_FLAG_NO_PAIN

	// Strength
	if(warning_high_pressure > 2000)
		strength = STR_VHIGH
	else if (warning_high_pressure > 700)
		if(prob(40))
			strength = STR_VHIGH
	else
		if(prob(5))
			strength = STR_VHIGH

	// Less need for food and water, if there is almost nothing there
	if(!E.flora_diversity)
		hunger_factor = round(hunger_factor * frand(0, 1), 0.1)
		thirst_factor = round(thirst_factor * frand(0, 1), 0.1)
	if(!E.fauna_types)
		hunger_factor = round(hunger_factor * frand(0, 1), 0.1)
		thirst_factor = round(thirst_factor * frand(0, 1), 0.1)


	if(toxins_mod <= 1 && prob(40) || toxins_mod <= 0.5)
		traits[/singleton/trait/boon/filtered_blood] = TRAIT_LEVEL_EXISTS

	// Natural regeneration
	if(prob(20))
		base_auras = list(/obj/aura/regenerating/human/mod_tribe)
		custom_regeneration["nutrition_damage_mult"] = rand(0, 2)
		custom_regeneration["brute_mult"] = rand(0, 2)
		custom_regeneration["fire_mult"] = rand(0, 2)
		custom_regeneration["tox_mult"] = rand(0, 2)
		custom_regeneration["organ_mult"] = rand(0, 4)
		custom_regeneration["grow_chance"] = rand(0,2)

		custom_regeneration["can_toggle"] = rand(0, 1)

	if(body_temperature <= 150 || body_temperature >= 450 && prob(20))
		body_temperature = null

/singleton/species/alium/tribe/handle_post_spawn(mob/living/carbon/human/H)
	..()
	H.bodytemperature = body_temperature

	if(phoron_guard == TRUE)
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
		E.phoron_guard = TRUE

	var/obj/item/implant/translator/natural/I = new()
	I.implant_in_mob(H, BP_HEAD)

/singleton/species/alium/tribe/add_base_auras(mob/living/carbon/human/H)
	..()
	var/mind_message = ""
	if(H.auras && LAZYLEN(custom_regeneration))
		var/list/dmg_types = list()
		for(var/obj/aura/regenerating/human/mod_tribe/regeneration in H.auras)
			regeneration.nutrition_damage_mult = custom_regeneration["nutrition_damage_mult"]
			regeneration.brute_mult = custom_regeneration["brute_mult"]
			regeneration.fire_mult = custom_regeneration["fire_mult"]
			regeneration.tox_mult = custom_regeneration["tox_mult"]
			regeneration.organ_mult = custom_regeneration["organ_mult"]
			regeneration.grow_chance = custom_regeneration["grow_chance"]

			regeneration.can_toggle = custom_regeneration["can_toggle"]

			if(custom_regeneration["brute_mult"])
				dmg_types.Add("физические повреждения")
			if(custom_regeneration["fire_mult"])
				dmg_types.Add("ожоги")
			if(custom_regeneration["tox_mult"])
				dmg_types.Add("токсины")
			if(custom_regeneration["organ_mult"])
				dmg_types.Add("органы")
			if(custom_regeneration["organ_mult"])
				dmg_types.Add("конечности")
			if(custom_regeneration["can_toggle"])
				H.verbs.Add(/mob/living/carbon/human/proc/diona_heal_toggle)

		if(LAZYLEN(dmg_types))
			mind_message += "[SPAN_BOLD("Вы способны регенерировать: ")] [dmg_types.Join(", ")]"

	if(mind_message)
		H.StoreMemory(mind_message, /singleton/memory_options/system)
		to_chat(H, mind_message)

/singleton/species/alium/tribe/equip_survival_gear(mob/living/carbon/human/H, extendedtank = 1)
	return

// Fix for skin colors after rejuvenate
/singleton/species/alium/handle_post_spawn(mob/living/carbon/human/H)
	..()

	if(H && H.dna)
		H.dna.ResetUIFrom(H)