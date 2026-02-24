
/datum/design/item/modularcomponent/accessory/scanner_flora
	name = "flora scanner module"
	desc = "A flora scanner module. It can scan and analyze various flora genes."
	id = "scan_flora"
	req_tech = list(TECH_BIO = 3, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 1000)
	build_path = /obj/item/stock_parts/computer/scanner/flora
	sort_string = "VBZDB"


/obj/item/stock_parts/computer/scanner/flora
	name = "flora scanner module"
	desc = "A flora scanner module. It can scan and analyze various flora genes."
	var/user_skill_level = 0

/obj/item/stock_parts/computer/scanner/flora/can_use_scanner(mob/user, obj/target, proximity = TRUE)
	if(!..(user, target, proximity))
		return 0
	if(!istype(target))
		return 0
	return 1

/obj/item/stock_parts/computer/scanner/flora/do_on_afterattack(mob/user, obj/target, proximity)
	if(!can_use_scanner(user, target, proximity))
		return
	user_level_skillcheck(user)
	var/dat = flora_scan_results(target)
	if(driver && driver.using_scanner)
		driver.data_buffer = jointext(dat, "\[br\]")
		SSnano.update_uis(driver.NM)


/obj/item/stock_parts/computer/scanner/flora/proc/user_level_skillcheck(mob/user)
	// Scanning flora is a complex task, but this module's advanced algorithms and databases make it more accessible.
	user_skill_level = 0
	if(user.skill_check(SKILL_BOTANY, SKILL_TRAINED))
		user_skill_level = 1 //basic info revealed
	if(user.skill_check(SKILL_BOTANY, SKILL_EXPERIENCED))
		user_skill_level = 2 //some special info revealed
		if(user.skill_check(SKILL_SCIENCE, SKILL_EXPERIENCED))
			user_skill_level = 4
	if(user.skill_check(SKILL_BOTANY, SKILL_MASTER))
		user_skill_level = 3 //most info revealed
		if(user.skill_check(SKILL_SCIENCE, SKILL_MASTER))
			user_skill_level = 5
		else if(user.skill_check(SKILL_SCIENCE, SKILL_EXPERIENCED))
			user_skill_level = 4



/obj/item/stock_parts/computer/scanner/flora/proc/flora_scan_results(obj/item/seeds, details = 0)
	RETURN_TYPE(/list)
	if(istype(seeds, /obj/item/reagent_containers/food/snacks/grown) || (istype(seeds,/obj/machinery/portable_atmospherics/hydroponics)|| istype(seeds,/obj/item/seeds)))
		return plant_scan_results(seeds)
	return list("No significant flora genes found in [seeds].")


/obj/item/stock_parts/computer/scanner/flora/proc/plant_scan_results(obj/target)
	var/list/geneMasks = list()
	for(var/gene_tag in SSplants.gene_tag_masks)
		geneMasks.Add(list(list("tag" = gene_tag, "mask" = SSplants.gene_tag_masks[gene_tag])))

	var/datum/seed/grown_seed
	var/datum/reagents/grown_reagents
	if(istype(target,/obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/G = target
		grown_seed = SSplants.seeds[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/seeds))
		var/obj/item/seeds/S = target
		grown_seed = S.seed

	else if(istype(target,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/H = target
		grown_seed = H.seed
		grown_reagents = H.reagents

	if(!grown_seed)
		return

	if(grown_seed.mysterious && !grown_seed.scanned)
		grown_seed.scanned = TRUE
		var/area/map = locate(/area/overmap)
		for(var/obj/overmap/visitable/sector/exoplanet/P in map)
			if(grown_seed in P.seeds)
				GLOB.stat_flora_scanned += 1
				break

	var/list/dat = list()
	var/gene_info = ""

	var/form_title = "[grown_seed.seed_name] (#[grown_seed.uid])"
	dat += "<h3>Plant data for [form_title]</h3>"

// General Data Section
	dat += "<h2>General Data</h2>"
	dat += "<table style='width: 100%; border-collapse: collapse;'>"
	dat += "<tr style='background: rgba(100, 150, 200, 0.2); border-bottom: 2px solid rgba(100, 200, 255, 0.5);'>"
	dat += "<td style='padding: 8px; font-weight: bold; color: #64c8ff; width: 40%;'><b>Endurance</b></td>"
	dat += "<td style='padding: 8px; color: #e0e0e0;'>[grown_seed.get_trait(TRAIT_ENDURANCE)]</td>"
	if(user_skill_level >= 1)
		dat += "<td style='padding: 8px; color: #888; font-size: 0.9em; text-align: right;'>[SSplants.gene_tag_masks[GENE_HARDINESS] || "N/A"]</td>"
	dat += "</tr>"
	dat += "<tr style='border-bottom: 1px solid rgba(255, 255, 255, 0.1);'>"
	dat += "<td style='padding: 8px; font-weight: bold; color: #64c8ff;'><b>Yield</b></td>"
	dat += "<td style='padding: 8px; color: #e0e0e0;'>[grown_seed.get_trait(TRAIT_YIELD)]</td>"
	if(user_skill_level >= 2)
		dat += "<td style='padding: 8px; color: #888; font-size: 0.9em; text-align: right;'>[SSplants.gene_tag_masks[GENE_VIGOUR] || "N/A"]</td>"
	dat += "</tr>"
	dat += "<tr style='border-bottom: 1px solid rgba(255, 255, 255, 0.1);'>"
	dat += "<td style='padding: 8px; font-weight: bold; color: #64c8ff;'><b>Maturation time</b></td>"
	dat += "<td style='padding: 8px; color: #e0e0e0;'>[grown_seed.get_trait(TRAIT_MATURATION)] cycles</td>"
	if(user_skill_level >= 2)
		dat += "<td style='padding: 8px; color: #888; font-size: 0.9em; text-align: right;'>[SSplants.gene_tag_masks[GENE_VIGOUR] || "N/A"]</td>"
	dat += "</tr>"
	dat += "<tr style='border-bottom: 1px solid rgba(255, 255, 255, 0.1);'>"
	dat += "<td style='padding: 8px; font-weight: bold; color: #64c8ff;'><b>Production time</b></td>"
	dat += "<td style='padding: 8px; color: #e0e0e0;'>[grown_seed.get_trait(TRAIT_PRODUCTION)] cycles</td>"
	if(user_skill_level >= 2)
		dat += "<td style='padding: 8px; color: #888; font-size: 0.9em; text-align: right;'>[SSplants.gene_tag_masks[GENE_VIGOUR] || "N/A"]</td>"
	dat += "</tr>"
	dat += "<tr>"
	dat += "<td style='padding: 8px; font-weight: bold; color: #64c8ff;'><b>Potency</b></td>"
	dat += "<td style='padding: 8px; color: #e0e0e0;'>[grown_seed.get_trait(TRAIT_POTENCY)]</td>"
	if(user_skill_level >= 3)
		dat += "<td style='padding: 8px; color: #888; font-size: 0.9em; text-align: right;'>[SSplants.gene_tag_masks[GENE_BIOCHEMISTRY] || "N/A"]</td>"
	dat += "</tr>"
	dat += "</table>"

// Reagent Data Section
	if(grown_reagents && grown_reagents.reagent_list && length(grown_reagents.reagent_list))
		dat += "<h2 style='margin-top: 15px;'>Reagent Data</h2>"
		dat += "<div style='background: rgba(50, 100, 150, 0.15); border-left: 3px solid rgba(100, 200, 255, 0.6); padding: 10px; border-radius: 3px;'>"
		dat += "This sample contains:<br>"
		for(var/datum/reagent/R in grown_reagents.reagent_list)
			var/amount = grown_reagents.get_reagent_amount(R.type)
			dat += "<div style='margin-left: 10px; color: #64c8ff;'>• [R.name]: <span style='color: #e0e0e0;'>[amount] unit(s)</span></div>"
		dat += "</div>"

	// Other Data Section
	dat += "<h2 style='margin-top: 15px;'>Characteristics</h2>"
	dat += "<div style='background: rgba(50, 100, 150, 0.1); padding: 10px; border-radius: 3px;'>"

	// Harvesting
	if(grown_seed.get_trait(TRAIT_HARVEST_REPEAT))
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_STRUCTURE] || "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 100, 0.15); border-left: 3px solid rgba(100, 200, 100, 0.5);'>✓ This species can be harvested repeatedly. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Mutability
	if(grown_seed.get_trait(TRAIT_IMMUTABLE) == -1)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_SPECIAL] || "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>⚠ This species is highly mutable. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_IMMUTABLE) > 0)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_STRUCTURE] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 150, 200, 0.15); border-left: 3px solid rgba(100, 150, 200, 0.5);'>✓ This species does not possess alterable genetics. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Nutrient Requirements
	if(grown_seed.get_trait(TRAIT_REQUIRES_NUTRIENTS))
		var/nutrient_level = grown_seed.get_trait(TRAIT_NUTRIENT_CONSUMPTION)
		var/nutrient_text = "It requires a supply of nutrient fluid."
		if(nutrient_level < 0.05)
			nutrient_text = "It consumes a minimal amount of nutrient fluid."
		else if(nutrient_level > 0.2)
			nutrient_text = "It requires a heavy supply of nutrient fluid."
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_METABOLISM] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(150, 100, 100, 0.15); border-left: 3px solid rgba(150, 100, 100, 0.5);'>💧 [nutrient_text] <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Water Requirements
	if(grown_seed.get_trait(TRAIT_REQUIRES_WATER))
		var/water_level = grown_seed.get_trait(TRAIT_WATER_CONSUMPTION)
		var/water_text = "It requires a stable supply of water."
		if(water_level < 1)
			water_text = "It requires very little water."
		else if(water_level > 5)
			water_text = "It requires a large amount of water."
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_METABOLISM] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 150, 200, 0.15); border-left: 3px solid rgba(100, 150, 200, 0.5);'>💧 [water_text] <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Mutation potential
	if(grown_seed.mutants && length(grown_seed.mutants))
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(150, 100, 200, 0.15); border-left: 3px solid rgba(150, 100, 200, 0.5);'>🧬 It exhibits high potential for subspecies shift. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Temperature preferences
	gene_info = ""
	if(user_skill_level >= 4)
		gene_info = "[SSplants.gene_tag_masks[GENE_ENVIRONMENT] ||   "N/A"]"
	dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 150, 100, 0.15); border-left: 3px solid rgba(200, 150, 100, 0.5);'>🌡 Ideal temperature: [grown_seed.get_trait(TRAIT_IDEAL_HEAT)]K <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	var/pressure_tolerance = ""
	if(grown_seed.get_trait(TRAIT_LOWKPA_TOLERANCE) < 20)
		pressure_tolerance += "Well adapted to low pressure. "
	if(grown_seed.get_trait(TRAIT_HIGHKPA_TOLERANCE) > 220)
		pressure_tolerance += "Well adapted to high pressure."
	if(pressure_tolerance)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_ATMOSPHERE] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 150, 200, 0.15); border-left: 3px solid rgba(100, 150, 200, 0.5);'>⚙ [pressure_tolerance] <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Temperature tolerance
	if(grown_seed.get_trait(TRAIT_HEAT_TOLERANCE) > 30)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_ATMOSPHERE] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 100, 0.15); border-left: 3px solid rgba(100, 200, 100, 0.5);'>✓ Well adapted to temperature range. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_HEAT_TOLERANCE) < 10)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_ATMOSPHERE] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>⚠ Very sensitive to temperature shifts. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Light preferences
	gene_info = ""
	if(user_skill_level >= 4)
		gene_info = "[SSplants.gene_tag_masks[GENE_ENVIRONMENT] ||   "N/A"]"
	dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 150, 100, 0.15); border-left: 3px solid rgba(200, 150, 100, 0.5);'>💡 Ideal light: [grown_seed.get_trait(TRAIT_IDEAL_LIGHT)] lumen[grown_seed.get_trait(TRAIT_IDEAL_LIGHT) == 1 ? "" : "s"] <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Light tolerance
	if(grown_seed.get_trait(TRAIT_LIGHT_TOLERANCE) > 10)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_ENVIRONMENT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 100, 0.15); border-left: 3px solid rgba(100, 200, 100, 0.5);'>✓ Well adapted to light variations. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_LIGHT_TOLERANCE) < 3)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_ENVIRONMENT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>⚠ Very sensitive to light shifts. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Disease/Pest tolerances
	if(grown_seed.get_trait(TRAIT_TOXINS_TOLERANCE) < 3)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>☠ Highly sensitive to toxins. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_TOXINS_TOLERANCE) > 6)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 100, 0.15); border-left: 3px solid rgba(100, 200, 100, 0.5);'>✓ Remarkably resistant to toxins. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_PEST_TOLERANCE) < 3)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>🐛 Highly sensitive to pests. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_PEST_TOLERANCE) > 6)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 100, 0.15); border-left: 3px solid rgba(100, 200, 100, 0.5);'>✓ Remarkably resistant to pests. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_WEED_TOLERANCE) < 3)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>🌿 Highly sensitive to weeds. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_WEED_TOLERANCE) > 6)
		gene_info = ""
		if(user_skill_level >= 4)
			gene_info = "[SSplants.gene_tag_masks[GENE_HARDINESS] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 100, 0.15); border-left: 3px solid rgba(100, 200, 100, 0.5);'>✓ Remarkably resistant to weeds. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	// Spread capability
	switch(grown_seed.get_trait(TRAIT_SPREAD))
		if(1)
			dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(150, 100, 200, 0.15); border-left: 3px solid rgba(150, 100, 200, 0.5);'>📍 Can be planted outside trays. <span style='float:right;color:#888;font-size:0.85em;'>[user_skill_level >= 5 ? "[SSplants.gene_tag_masks[GENE_VIGOUR] ||   "N/A"]" : ""]</span></div>"
		if(2)
			dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(150, 100, 200, 0.15); border-left: 3px solid rgba(150, 100, 200, 0.5);'>🌳 Robust vine that spreads rapidly. <span style='float:right;color:#888;font-size:0.85em;'>[user_skill_level >= 5 ? "[SSplants.gene_tag_masks[GENE_VIGOUR] ||   "N/A"]" : ""]</span></div>"

	// Carnivorous traits
	switch(grown_seed.get_trait(TRAIT_CARNIVOROUS))
		if(1)
			dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>🥷 Carnivorous - will consume tray pests. <span style='float:right;color:#888;font-size:0.85em;'>[user_skill_level >= 5 ? "[SSplants.gene_tag_masks[GENE_DIET] ||   "N/A"]" : ""]</span></div>"
		if(2)
			dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 50, 50, 0.15); border-left: 3px solid rgba(200, 50, 50, 0.5);'>⚠ DANGEROUS - Carnivorous threat to living things. <span style='float:right;color:#888;font-size:0.85em;'>[user_skill_level >= 5 ? "[SSplants.gene_tag_masks[GENE_DIET] ||   "N/A"]" : ""]</span></div>"

	// Special traits
	if(grown_seed.get_trait(TRAIT_PARASITE))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_DIET] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(150, 100, 50, 0.15); border-left: 3px solid rgba(150, 100, 50, 0.5);'>🦠 Parasitizes weeds for sustenance. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_ALTER_TEMP))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_METABOLISM] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 150, 100, 0.15); border-left: 3px solid rgba(200, 150, 100, 0.5);'>🌡 Alters local temperature by [grown_seed.get_trait(TRAIT_ALTER_TEMP)]K. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_BIOLUM))
		var/biolum_color = grown_seed.get_trait(TRAIT_BIOLUM_COLOUR)
		var/biolum_text = biolum_color ? "Bio-luminescent ([biolum_color])" : "Bio-luminescent"
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_OUTPUT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 200, 100, 0.15); border-left: 3px solid rgba(200, 200, 100, 0.5);'>✨ [biolum_text] <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_PRODUCES_POWER))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_OUTPUT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 200, 100, 0.15); border-left: 3px solid rgba(200, 200, 100, 0.5);'>⚡ Fruit functions as a battery. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_STINGS))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_FRUIT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 100, 100, 0.15); border-left: 3px solid rgba(200, 100, 100, 0.5);'>🔱 Fruit covered in stinging spines. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_JUICY) == 1)
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_FRUIT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 200, 0.15); border-left: 3px solid rgba(100, 200, 200, 0.5);'>💧 Soft-skinned and juicy. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"
	else if(grown_seed.get_trait(TRAIT_JUICY) == 2)
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_FRUIT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 200, 0.15); border-left: 3px solid rgba(100, 200, 200, 0.5);'>💧 Excessively juicy. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_EXPLOSIVE))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_FRUIT] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(200, 50, 50, 0.15); border-left: 3px solid rgba(200, 50, 50, 0.5);'>💣 Internally unstable! <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_TELEPORTING))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_SPECIAL] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(150, 100, 200, 0.15); border-left: 3px solid rgba(150, 100, 200, 0.5);'>⛛ Temporal/spatially unstable. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_EXUDE_GASSES))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_BIOCHEMISTRY] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 150, 200, 0.15); border-left: 3px solid rgba(100, 150, 200, 0.5);'>💨 Releases gas into environment. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	if(grown_seed.get_trait(TRAIT_CONSUME_GASSES))
		gene_info = ""
		if(user_skill_level >= 5)
			gene_info = "[SSplants.gene_tag_masks[GENE_DIET] ||   "N/A"]"
		dat += "<div style='margin-bottom: 6px; padding: 6px; background: rgba(100, 200, 150, 0.15); border-left: 3px solid rgba(100, 200, 150, 0.5);'>🌍 Removes gas from environment. <span style='float:right;color:#888;font-size:0.85em;'>[gene_info]</span></div>"

	dat += "</div>"

	return JOINTEXT(dat)
