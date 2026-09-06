// Field Research Scanner Module
// Hardware scanner for modular computers (PDA / tablet / laptop).
// Install in any modular computer → point the computer at objects → scan results appear in the Scanner program.
// Saves scan data as RDF files with metadata (target type, z-level). Submit RDF to R&D console to advance objectives.

/datum/design/item/modularcomponent/accessory/scanner_research
	name = "field research scanner module"
	desc = "A compact environmental and structural data scanner module for modular computers."
	id = "scan_research"
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500, MATERIAL_GOLD = 500)
	build_path = /obj/item/stock_parts/computer/scanner/research
	sort_string = "VBZDC"

/obj/item/stock_parts/computer/scanner/research
	name = "field research scanner module"
	desc = "An environmental and structural data scanner module. Install it in any modular computer to identify and log research data from nearby objects and structures."
	driver_type = /datum/computer_file/program/scanner
	can_run_scan = FALSE
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	scan_beam_color = "#4db0ce"

/obj/item/stock_parts/computer/scanner/research/can_use_scanner(mob/user, atom/target, proximity)
	if(!..(user, target, proximity))
		return FALSE
	if(isturf(target) || isarea(target))
		return FALSE
	if(target == user || target == loc)
		return FALSE
	return TRUE

/obj/item/stock_parts/computer/scanner/research/proc/tech_display_name(key)
	switch(key)
		if("materials")    return "Materials Science"
		if("engineering")  return "Engineering"
		if("phorontech")   return "Phoron Technology"
		if("powerstorage") return "Power Manipulation"
		if("bluespace")    return "Blue-space Technology"
		if("biotech")      return "Biological Technology"
		if("combat")       return "Combat Systems"
		if("magnets")      return "Electromagnetic Technology"
		if("programming")  return "Data Theory"
		if("esoteric")     return "Esoteric Technology"
	return key

/obj/item/stock_parts/computer/scanner/research/do_on_afterattack(mob/user, atom/target, proximity)
	if(!can_use_scanner(user, target, proximity))
		return

	if(!do_scan_animation(user, target))
		return

	var/list/dat = list()

	// --- Header ---
	dat += "<b>[uppertext(target.name)]</b>"

	// --- Description ---
	if(target.desc && target.desc != "")
		dat += "[target.desc]"

	// --- Location ---
	var/area/scan_area = get_area(target)
	if(scan_area)
		dat += "<i>Location: [scan_area.name]</i>"

	// --- Machinery-specific data ---
	if(istype(target, /obj/machinery))
		var/obj/machinery/M = target

		// Device ID
		if(M.id_tag && M.id_tag != "")
			dat += "<b>Device ID:</b> [M.id_tag]"

		// Power / status
		var/list/status_flags = list()
		if(M.stat & MACHINE_STAT_NOPOWER)  status_flags += "NO POWER"
		if(M.stat & MACHINE_STAT_MAINT)    status_flags += "MAINTENANCE"
		if(M.stat & MACHINE_STAT_EMPED)    status_flags += "EMP DISRUPTED"
		if(M.emagged)                       status_flags += "EMAGGED"
		if(M.panel_open)                    status_flags += "PANEL OPEN"

		var/status_str = length(status_flags) ? jointext(status_flags, " | ") : "OPERATIONAL"
		dat += "<b>Status:</b> [status_str]"

		if(M.idle_power_usage > 0 || M.active_power_usage > 0)
			dat += "<b>Power draw:</b> [M.idle_power_usage]W idle / [M.active_power_usage]W active"

		dat += "<b>Anchored:</b> [M.anchored ? "Yes" : "No"]"

		// Contents (excluding component parts)
		var/list/inserted = M.InsertedContents()
		if(LAZYLEN(inserted))
			var/list/item_names = list()
			for(var/obj/item/I in inserted)
				item_names += I.name
			dat += "<b>Contents:</b> [jointext(item_names, ", ")]"

	// --- Health ---
	if(target.health_max)
		dat += "<b>Health:</b> [target.get_current_health()] / [target.get_max_health()]"

	// --- Component parts (machinery) ---
	if(istype(target, /obj/machinery))
		var/obj/machinery/M2 = target
		if(LAZYLEN(M2.component_parts))
			var/list/part_names = list()
			for(var/obj/item/stock_parts/P in M2.component_parts)
				part_names += P.name
			if(length(part_names))
				dat += "<b>Component parts:</b>\[br\][jointext(part_names, "\[br\]")]"

	// --- Material composition ---
	if(isobj(target))
		var/obj/O = target
		if(LAZYLEN(O.matter))
			var/list/matter_lines = list()
			for(var/mat in O.matter)
				matter_lines += "[mat]: [O.matter[mat]] units"
			dat += "<b>Material composition:</b>\[br\][jointext(matter_lines, "\[br\]")]"

	// --- Technology profile (items only — machinery doesn't have origin_tech) ---
	var/list/tech
	if(isitem(target))
		var/obj/item/I = target
		tech = I.origin_tech

	if(LAZYLEN(tech))
		var/list/tech_lines = list()
		for(var/key in tech)
			tech_lines += "[tech_display_name(key)]: Lv.[tech[key]]"
		dat += "<b>Technology profile:</b>\[br\][jointext(tech_lines, "\[br\]")]"

	// --- Artifact field data ---
	if(istype(target, /obj/machinery/artifact))
		var/obj/machinery/artifact/art = target
		if(art.my_effect)
			dat += "<b>Идентификатор сигнатуры:</b> [art.my_effect.artifact_id]"
		if(art.desc && art.desc != "")
			dat += "<i>[art.desc]</i>"
		// Lore-flavoured field readings
		dat += "<b>Оценка возраста:</b> ~[rand(10, 900)] тыс. лет (погрешность ±[rand(5,40)]%)"
		dat += "<b>Плотность материала:</b> [pick("аномально высокая", "нестандартная", "нехарактерная для известных сплавов")] ([round(rand(180, 340) * 0.1, 0.1)] г/см³)"
		dat += "<b>Фоновое излучение:</b> [rand(12, 280)] мкЗв/ч — [pick("слабое", "умеренное", "повышенное")] превышение нормы"
		dat += "<b>Магнитный отклик:</b> [pick("неустойчивый", "периодический", "стационарный", "отсутствует")]"

	// --- Store metadata for RDF file and push to driver ---
	if(driver && driver.using_scanner)
		driver.scan_file_type = /datum/computer_file/data/rdf
		driver.metadata_buffer.Cut()
		driver.metadata_buffer["target_type"] = "[target.type]"
		var/turf/scan_turf = get_turf(target)
		if(scan_turf)
			driver.metadata_buffer["scan_z"] = "[scan_turf.z]"
		if(scan_area)
			driver.metadata_buffer["scan_area"] = scan_area.name
		// Store artifact effect data for catalogization
		if(istype(target, /obj/machinery/artifact))
			var/obj/machinery/artifact/art = target
			if(art.my_effect)
				driver.metadata_buffer["artifact_id"] = art.my_effect.artifact_id
				driver.metadata_buffer["artifact_effect_type"] = "[art.my_effect.effect_type]"
				driver.metadata_buffer["artifact_effect_mode"] = "[art.my_effect.effect]"
				driver.metadata_buffer["artifact_effectrange"] = "[art.my_effect.effectrange]"
		driver.data_buffer = jointext(dat, "\[br\]\[br\]")
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		SSnano.update_uis(driver.NM)
