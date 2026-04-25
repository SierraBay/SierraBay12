// Reverse Engineering System
// Allows extracting designs from items with skill-based quality

#define RND_QUALITY_PERFECT 100
#define RND_QUALITY_GOOD 75
#define RND_QUALITY_AVERAGE 50
#define RND_QUALITY_POOR 25
#define RND_QUALITY_DEFECTIVE 0

/**
 * Returns TRUE if this item type can be reverse-engineered into a fabricatable design.
 * Add istype() checks here to permanently block specific item categories.
 */
/proc/can_be_reverse_engineered(obj/item/I)
	// Living creatures in holder wrappers — never allow extracting mob designs
	if(istype(I, /obj/item/holder))
		return FALSE
	// Raw materials (sheets, rods, ingots) — unlimited printing of materials is not allowed
	if(istype(I, /obj/item/stack))
		return FALSE
	// Slime extracts — obtained via xenobiology only
	if(istype(I, /obj/item/slime_extract))
		return FALSE
	return TRUE

// Generates a design from an analyzed item
// Returns the created design datum or null on failure
/datum/research/proc/generate_design_from_item(obj/item/I, mob/living/carbon/human/user)
	if(!istype(I))
		return null

	// Check reverse engineering blacklist
	if(!can_be_reverse_engineered(I))
		return null

	// Check if design already exists for this item type
	var/list/check_designs = physical_server ? physical_server.get_all_designs() : known_designs
	for(var/datum/design/existing in check_designs)
		if(existing.build_path == I.type)
			return existing // Already have this design

	// Create new reverse-engineered design
	var/datum/design/new_design = new /datum/design()
	new_design.build_path = I.type
	new_design.reverse_engineered = TRUE

	// Set materials from item techs (1000 per tech level)
	var/list/tech_to_material = list(
		TECH_MATERIAL = MATERIAL_STEEL,
		TECH_ENGINEERING = MATERIAL_ALUMINIUM,
		TECH_BIO = MATERIAL_PLASTIC,
		TECH_DATA = MATERIAL_GLASS,
		TECH_MAGNET = MATERIAL_SILVER,
		TECH_COMBAT = MATERIAL_STEEL,
		TECH_POWER = MATERIAL_GOLD,
		TECH_PHORON = MATERIAL_PHORON,
		TECH_BLUESPACE = MATERIAL_DIAMOND,
		TECH_ESOTERIC = MATERIAL_URANIUM
	)

	var/list/materials_from_tech = list()
	if(I.origin_tech && length(I.origin_tech))
		for(var/tech in I.origin_tech)
			var/material = tech_to_material[tech]
			if(!material)
				continue
			var/level = max(1, round(I.origin_tech[tech]))
			materials_from_tech[material] = (materials_from_tech[material] || 0) + (level * 1000)

	if(length(materials_from_tech))
		new_design.materials = materials_from_tech
	else if(I.matter && length(I.matter))
		new_design.materials = I.matter.Copy()
	else
		// Fallback: estimate materials
		new_design.materials = list(MATERIAL_STEEL = 1000)

	// Set basic info
	new_design.name = I.name
	new_design.desc = "Reverse-engineered design for [I.name]. [I.desc]"
	var/type_text = "[I.type]"
	new_design.id = "re_[replacetext(type_text, "/", "_")]"
	new_design.build_type = PROTOLATHE
	new_design.category = list("Reverse Engineered")

	// Calculate item difficulty:
	// = max tech level among all origin_tech entries
	// + 1 for each additional tech beyond the first (multi-tech penalty)
	var/max_tech_level = 0
	var/tech_count = 0
	if(I.origin_tech && length(I.origin_tech))
		for(var/tech in I.origin_tech)
			var/lvl = max(1, round(I.origin_tech[tech]))
			if(lvl > max_tech_level)
				max_tech_level = lvl
			tech_count++
	if(!max_tech_level)
		max_tech_level = 1
	var/difficulty = max_tech_level + max(0, tech_count - 1)

	// Skill sum: science + devices
	var/skill_sum = 0
	if(ishuman(user))
		skill_sum = user.get_skill_value(SKILL_SCIENCE) + user.get_skill_value(SKILL_DEVICES)

	// Quality formula:
	// base = 65 when skill_sum == difficulty
	// each point above difficulty: +12 quality (toward 100)
	// each point below difficulty: -5 quality
	var/surplus = skill_sum - difficulty
	var/quality
	if(surplus >= 0)
		quality = 65 + (surplus * 12)
	else
		quality = 65 + (surplus * 5)
	quality += rand(-5, 5)
	new_design.quality = clamp(quality, RND_QUALITY_DEFECTIVE, RND_QUALITY_PERFECT)

	// Set shortname
	new_design.shortname = capitalize(new_design.name)
	if(new_design.quality < RND_QUALITY_AVERAGE)
		new_design.shortname += " defective"
	else if(new_design.quality < RND_QUALITY_GOOD)
		new_design.shortname += " (Low Quality)"

	// Create design file for saving to disk
	new_design.file = new /datum/computer_file/binary/design()
	new_design.file.design = new_design
	new_design.file.filename = sanitizeFileName("[new_design.id]")
	new_design.file.filetype = "design"
	new_design.file.size = 10

	// Assemble UI data
	new_design.AssembleDesignUIData()

	return new_design

// Extract design from loaded item to disk
/obj/machinery/computer/rdconsole/proc/extract_design_to_disk(mob/living/user)
	if(!linked_destroy || !linked_destroy.loaded_item)
		to_chat(user, SPAN_WARNING("В деструктивном анализаторе нет предмета."))
		return FALSE

	if(!disk)
		to_chat(user, SPAN_WARNING("В консоли нет диска для сохранения дизайна."))
		return FALSE

	if(disk.read_only)
		to_chat(user, SPAN_WARNING("Диск защищен от записи."))
		return FALSE

	var/datum/research/F = get_server_files()
	if(!F)
		to_chat(user, SPAN_WARNING("Нет подключения к серверу R&D."))
		return FALSE

	var/obj/item/I = linked_destroy.loaded_item

	// Generate design
	var/datum/design/new_design = F.generate_design_from_item(I, user)

	if(!new_design)
		to_chat(user, SPAN_WARNING("Не удалось извлечь дизайн из [I.name]."))
		return FALSE

	// Check if design already exists on disk
	var/list/disk_designs = disk.find_files_by_type(/datum/computer_file/binary/design)
	for(var/datum/computer_file/binary/design/existing_file in disk_designs)
		if(existing_file.design.build_path == new_design.build_path)
			to_chat(user, SPAN_NOTICE("Дизайн [new_design.name] уже сохранен на диске."))
			return TRUE

	// Check disk capacity
	if((disk.used_capacity + new_design.file.size) > disk.max_capacity)
		to_chat(user, SPAN_WARNING("Недостаточно места на диске ([disk.used_capacity]/[disk.max_capacity] GQ)."))
		return FALSE

	// Save to disk
	var/datum/computer_file/binary/design/file_copy = new_design.file.clone()
	if(disk.save_file(file_copy))
		// Also add to known designs
		F.AddDesign2Known(new_design)

		// Quality notification
		var/quality_message = ""
		if(new_design.quality >= RND_QUALITY_PERFECT)
			quality_message = SPAN_GOOD("Качество: ИДЕАЛЬНОЕ ([new_design.quality]%)")
		else if(new_design.quality >= RND_QUALITY_GOOD)
			quality_message = SPAN_NOTICE("Качество: Хорошее ([new_design.quality]%)")
		else if(new_design.quality >= RND_QUALITY_AVERAGE)
			quality_message = SPAN_NOTICE("Качество: Среднее ([new_design.quality]%)")
		else
			quality_message = SPAN_WARNING("Качество: ДЕФЕКТНОЕ ([new_design.quality]%). Изделия могут быть опасны!")

		var/skill_sum_info = ishuman(user) ? (user.get_skill_value(SKILL_SCIENCE) + user.get_skill_value(SKILL_DEVICES)) : 0
		to_chat(user, SPAN_GOOD("Дизайн [new_design.name] успешно извлечен и сохранен на диске. [quality_message] (Суммарный навык: [skill_sum_info])"))
		log_and_message_admins("extracted design [new_design.name] (quality: [new_design.quality]%) from [I.name].", user)

		linked_destroy.deconstruct_item()
		return TRUE
	else
		to_chat(user, SPAN_WARNING("Ошибка записи на диск."))
		return FALSE

#undef RND_QUALITY_PERFECT
#undef RND_QUALITY_GOOD
#undef RND_QUALITY_AVERAGE
#undef RND_QUALITY_POOR
#undef RND_QUALITY_DEFECTIVE
