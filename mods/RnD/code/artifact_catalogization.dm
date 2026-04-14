/*
	Artifact Catalogization System

	A classification experiment for xenoarcheological artifacts.
	The R&D console detects nearby artifacts (/obj/machinery/artifact) within 3 tiles
	and allows the scientist to classify them through a 3-step quiz.

	Steps:
	1. Effect Type Classification — identify the artifact's emission type
	   (Energy, Psionic, Electro, Particle, Organic, Bluespace, Synth)
	2. Activation Mode — identify how the artifact activates
	   (Touch, Aura, Pulse)
	3. Range Assessment — estimate the artifact's effective range
	   (Short 1-2, Medium 3-4, Long 5+)

	The scientist must observe/analyze the artifact beforehand (using the
	artifact analyser or direct observation) to know the correct answers.

	Reward: +2 rep per correct answer, +4 bonus for all 3 correct = max +10 rep
	with a corporation determined by the artifact's effect type.

	Anti-farm: Each unique artifact_id can only be catalogized once per research datum.
*/

// =====================================================
// Research datum — track catalogized artifacts
// =====================================================

/datum/research
	/// List of artifact_ids that have been catalogized on this console
	var/list/catalogized_artifact_ids = list()

// =====================================================
// Helper procs
// =====================================================

/// Maps artifact effect_type to the corporation interested in that type of research
/proc/get_catalog_effect_corporation(effect_type)
	switch(effect_type)
		if(EFFECT_ENERGY)
			return RND_MISSION_CORP_HEPHAESTUS
		if(EFFECT_PSIONIC)
			return RND_MISSION_CORP_NANOTRASEN
		if(EFFECT_ELECTRO)
			return RND_MISSION_CORP_XION
		if(EFFECT_PARTICLE)
			return RND_MISSION_CORP_WARD_TAKAHASHI
		if(EFFECT_ORGANIC)
			return RND_MISSION_CORP_VEYMED
		if(EFFECT_BLUESPACE)
			return RND_MISSION_CORP_DAIS
		if(EFFECT_SYNTH)
			return RND_MISSION_CORP_BISHOP
	// EFFECT_UNKNOWN or anything else
	return RND_MISSION_CORP_NANOTRASEN

/// Get human-readable name for effect_type constant
/proc/get_catalog_effect_type_name(effect_type)
	switch(effect_type)
		if(EFFECT_UNKNOWN)
			return "Неопознанное"
		if(EFFECT_ENERGY)
			return "Энергетическое"
		if(EFFECT_PSIONIC)
			return "Псионическое"
		if(EFFECT_ELECTRO)
			return "Электромагнитное"
		if(EFFECT_PARTICLE)
			return "Корпускулярное"
		if(EFFECT_ORGANIC)
			return "Органическое"
		if(EFFECT_BLUESPACE)
			return "Блюспейс"
		if(EFFECT_SYNTH)
			return "Синтетическое"
	return "Неопознанное"

/// Get human-readable name for effect mode constant
/proc/get_catalog_effect_mode_name(effect_mode)
	switch(effect_mode)
		if(EFFECT_TOUCH)
			return "Тактильный"
		if(EFFECT_AURA)
			return "Аура"
		if(EFFECT_PULSE)
			return "Импульсный"
	return "Неизвестный"

/// Determine range category from effectrange value
/proc/get_catalog_range_category(effectrange)
	if(effectrange <= 2)
		return "short"
	if(effectrange <= 4)
		return "medium"
	return "long"

/// Get human-readable name for range category
/proc/get_catalog_range_name(range_category)
	switch(range_category)
		if("short")
			return "Малый (1-2)"
		if("medium")
			return "Средний (3-4)"
		if("long")
			return "Большой (5+)"
	return "?"

// =====================================================
// Catalog step info
// =====================================================

/// Step name for display
/proc/get_catalog_step_name(step)
	switch(step)
		if(1)
			return "Классификация излучения"
		if(2)
			return "Режим активации"
		if(3)
			return "Оценка дальности"
	return "Неизвестный этап"

/// Step hint for display
/proc/get_catalog_step_hint(step)
	switch(step)
		if(1)
			return "Определите тип излучения артефакта на основе наблюдений и данных анализатора."
		if(2)
			return "Определите, каким образом артефакт активирует свой эффект."
		if(3)
			return "Оцените радиус действия эффекта артефакта."
	return ""

// =====================================================
// R&D Console — artifact catalogization integration
// Uses RDF scan files from research scanner instead of nearby artifacts
// =====================================================

/obj/machinery/computer/rdconsole
	/// Is artifact catalogization currently in progress
	var/catalog_active = FALSE
	/// Current catalogization step (1-3)
	var/catalog_step = 0
	/// Number of correct answers in current catalogization
	var/catalog_correct = 0
	/// Result text for display
	var/catalog_result_text = ""
	/// Corporation for reward
	var/catalog_reward_corp = null
	/// Artifact data from RDF scan file (stored as list of metadata values)
	var/catalog_artifact_id = null
	var/catalog_effect_type = 0
	var/catalog_effect_mode = 0
	var/catalog_effectrange = 0

/// Check if an RDF file on the loaded disk contains artifact scan data
/obj/machinery/computer/rdconsole/proc/find_artifact_rdf_files()
	if(!disk)
		return list()
	var/datum/research/server_files = get_server_files()
	var/list/result = list()
	for(var/datum/computer_file/data/rdf/rdf_file in disk.stored_files)
		if(!rdf_file.metadata)
			continue
		var/art_id = rdf_file.metadata["artifact_id"]
		if(!art_id)
			continue
		if(server_files && (art_id in server_files.catalogized_artifact_ids))
			continue
		result += rdf_file
	return result

/// Start artifact catalogization from an RDF file on disk
/obj/machinery/computer/rdconsole/proc/start_catalog(mob/living/user, rdf_ref)
	if(catalog_active)
		to_chat(user, SPAN_WARNING("Каталогизация уже запущена."))
		return
	if(!disk)
		to_chat(user, SPAN_WARNING("Вставьте диск с данными сканирования артефакта."))
		return

	var/datum/computer_file/data/rdf/rdf_file = locate(rdf_ref) in disk.stored_files
	if(!istype(rdf_file) || !rdf_file.metadata)
		to_chat(user, SPAN_WARNING("Файл повреждён или не найден."))
		return

	var/art_id = rdf_file.metadata["artifact_id"]
	if(!art_id)
		to_chat(user, SPAN_WARNING("Файл не содержит данных сканирования артефакта."))
		return

	var/datum/research/F = get_server_files()
	if(!F)
		return
	if(art_id in F.catalogized_artifact_ids)
		to_chat(user, SPAN_WARNING("Этот артефакт уже каталогизирован."))
		return

	catalog_artifact_id = art_id
	catalog_effect_type = text2num(rdf_file.metadata["artifact_effect_type"])
	catalog_effect_mode = text2num(rdf_file.metadata["artifact_effect_mode"])
	catalog_effectrange = text2num(rdf_file.metadata["artifact_effectrange"])

	catalog_active = TRUE
	catalog_step = 1
	catalog_correct = 0
	catalog_result_text = ""
	catalog_reward_corp = get_catalog_effect_corporation(catalog_effect_type)

	to_chat(user, SPAN_NOTICE("Каталогизация артефакта начата. Следуйте инструкциям на консоли."))
	SSnano.update_uis(src)

/// Process a catalog step choice from UI
/obj/machinery/computer/rdconsole/proc/do_catalog_step(mob/living/user, chosen_value)
	if(!catalog_active || catalog_step < 1 || catalog_step > 3)
		return
	if(!catalog_artifact_id)
		cancel_catalog()
		return

	var/step_name = get_catalog_step_name(catalog_step)
	var/is_correct = FALSE

	switch(catalog_step)
		if(1) // Effect type classification
			var/chosen_type = text2num(chosen_value)
			is_correct = (chosen_type == catalog_effect_type)
			var/chosen_name = get_catalog_effect_type_name(chosen_type)
			var/correct_name = get_catalog_effect_type_name(catalog_effect_type)
			if(is_correct)
				catalog_correct++
				catalog_result_text += "<span class='good'>[step_name]: [chosen_name] — Верно!</span><br>"
			else
				catalog_result_text += "<span class='bad'>[step_name]: [chosen_name] — Неверно (правильно: [correct_name])</span><br>"

		if(2) // Activation mode
			var/chosen_mode = text2num(chosen_value)
			is_correct = (chosen_mode == catalog_effect_mode)
			var/chosen_name = get_catalog_effect_mode_name(chosen_mode)
			var/correct_name = get_catalog_effect_mode_name(catalog_effect_mode)
			if(is_correct)
				catalog_correct++
				catalog_result_text += "<span class='good'>[step_name]: [chosen_name] — Верно!</span><br>"
			else
				catalog_result_text += "<span class='bad'>[step_name]: [chosen_name] — Неверно (правильно: [correct_name])</span><br>"

		if(3) // Range assessment
			var/correct_range = get_catalog_range_category(catalog_effectrange)
			is_correct = (chosen_value == correct_range)
			var/chosen_name = get_catalog_range_name(chosen_value)
			var/correct_range_name = get_catalog_range_name(correct_range)
			if(is_correct)
				catalog_correct++
				catalog_result_text += "<span class='good'>[step_name]: [chosen_name] — Верно!</span><br>"
			else
				catalog_result_text += "<span class='bad'>[step_name]: [chosen_name] — Неверно (правильно: [correct_range_name])</span><br>"

	if(catalog_step >= 3)
		finish_catalog(user)
		return

	catalog_step++
	SSnano.update_uis(src)

/// Finish catalogization and grant rewards
/obj/machinery/computer/rdconsole/proc/finish_catalog(mob/living/user)
	var/total_rep = catalog_correct * 5  // +5 per correct answer
	if(catalog_correct >= 3)
		total_rep += 10  // +10 bonus for perfect classification

	var/datum/research/F = get_server_files()
	if(total_rep > 0 && catalog_reward_corp && F)
		F.ChangeCorporationReputation(catalog_reward_corp, total_rep)
		var/corp_name = get_rnd_mission_corporation_name(catalog_reward_corp)
		catalog_result_text += "<br><span class='good'>Каталогизация завершена. Репутация с [corp_name]: +[total_rep]</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Каталогизация артефакта завершена. Репутация с [corp_name]: +[total_rep]."))
	else
		catalog_result_text += "<br><span class='average'>Каталогизация завершена. Классификация неточна — данные не представляют ценности.</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Каталогизация завершена, но классификация слишком неточна."))

	// Mark this artifact as catalogized
	if(catalog_artifact_id && F)
		F.catalogized_artifact_ids += catalog_artifact_id

	catalog_active = FALSE
	catalog_step = 0
	catalog_artifact_id = null
	SSnano.update_uis(src)

/// Cancel artifact catalogization
/obj/machinery/computer/rdconsole/proc/cancel_catalog()
	catalog_active = FALSE
	catalog_step = 0
	catalog_correct = 0
	catalog_result_text = ""
	catalog_reward_corp = null
	catalog_artifact_id = null
	SSnano.update_uis(src)
