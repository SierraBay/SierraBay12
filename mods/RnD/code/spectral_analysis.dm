/*
	Spectral Analysis — Simon Mini-Game

	Non-destructive analysis for the Destructive Analyzer.
	Player loads an item, starts spectral analysis, watches a colour
	sequence played back on 4 buttons, then reproduces it from memory.

	Sequence length depends on the item's total origin_tech levels.
	Reward: +1 reputation per correct press, +3 bonus for a perfect run.
	The item is NOT destroyed.
*/

// ── Anti-farm: remember analyzed types per console ──────────
/datum/research
	var/list/spectral_analyzed_types = list()

// ── Map a tech key to the most relevant corporation ─────────
/proc/get_spectral_tech_corporation(tech_key)
	switch(tech_key)
		if(TECH_ENGINEERING)
			return pick(RND_MISSION_CORP_HEPHAESTUS, RND_MISSION_CORP_GRAYSON)
		if(TECH_MATERIAL)
			return pick(RND_MISSION_CORP_XION, RND_MISSION_CORP_GRAYSON)
		if(TECH_BIO)
			return pick(RND_MISSION_CORP_VEYMED, RND_MISSION_CORP_ZENG_HU)
		if(TECH_COMBAT)
			return pick(RND_MISSION_CORP_ALMALIKI, RND_MISSION_CORP_HEPHAESTUS)
		if(TECH_BLUESPACE)
			return pick(RND_MISSION_CORP_NANOTRASEN, RND_MISSION_CORP_DAIS)
		if(TECH_POWER)
			return pick(RND_MISSION_CORP_EINSTEIN, RND_MISSION_CORP_FOCAL)
		if(TECH_DATA)
			return pick(RND_MISSION_CORP_DAIS, RND_MISSION_CORP_KAPPA)
		if(TECH_MAGNET)
			return pick(RND_MISSION_CORP_MORPHEUS, RND_MISSION_CORP_BISHOP)
		if(TECH_PHORON)
			return RND_MISSION_CORP_AETHER
		if(TECH_ESOTERIC)
			return RND_MISSION_CORP_NANOTRASEN
	return null

// ═══════════════════════════════════════════════════════
//  Destructive Analyzer helpers
// ═══════════════════════════════════════════════════════

/// Validates and locks the analyzer for spectral analysis
/obj/machinery/r_n_d/destructive_analyzer/proc/start_spectral_analysis(mob/living/user)
	if(busy)
		to_chat(user, SPAN_WARNING("Анализатор занят."))
		return FALSE
	if(!loaded_item)
		to_chat(user, SPAN_WARNING("Нет загруженного предмета."))
		return FALSE
	if(!loaded_item.origin_tech || !LAZYLEN(loaded_item.origin_tech))
		to_chat(user, SPAN_WARNING("Предмет не содержит технологических данных."))
		return FALSE
	var/datum/research/F = linked_console ? linked_console.get_server_files() : null
	if(!linked_console || !F)
		to_chat(user, SPAN_WARNING("Нет подключения к R&D консоли."))
		return FALSE
	var/item_type = loaded_item.type
	if(item_type in F.spectral_analyzed_types)
		to_chat(user, SPAN_WARNING("Предмет этого типа уже прошёл спектральный анализ."))
		return FALSE
	busy = TRUE
	flick("d_analyzer_process", src)
	to_chat(user, SPAN_NOTICE("Спектральный анализ начат."))
	return TRUE

/// Releases busy flag after spectral analysis ends
/obj/machinery/r_n_d/destructive_analyzer/proc/finish_spectral()
	busy = FALSE
	on_update_icon()
	if(linked_console)
		SSnano.update_uis(linked_console)

// ═══════════════════════════════════════════════════════
//  R&D Console — Simon mini-game
// ═══════════════════════════════════════════════════════

/obj/machinery/computer/rdconsole
	/// Is the mini-game running
	var/spectral_active = FALSE
	/// "playback" = showing sequence, "input" = waiting for player
	var/spectral_phase = null
	/// The colour sequence the player must reproduce
	var/list/spectral_sequence = list()
	/// Next index the player must press (1-based)
	var/spectral_index = 0
	/// Correct presses so far
	var/spectral_correct = 0
	/// Currently highlighted button colour (or null)
	var/spectral_flash = null
	/// Result HTML for the panel
	var/spectral_result_text = ""
	/// Corporation for reputation reward
	var/spectral_reward_corp = null
	/// The player who started the analysis
	var/mob/spectral_user = null

// ── Entry point: called from Topic ──────────────────────────
/obj/machinery/computer/rdconsole/proc/start_spectral(mob/living/user)
	if(spectral_active)
		to_chat(user, SPAN_WARNING("Спектральный анализ уже запущен."))
		return
	if(!linked_destroy || !linked_destroy.start_spectral_analysis(user))
		return

	// Determine reward corporation from dominant tech
	var/obj/item/I = linked_destroy.loaded_item
	if(I && I.origin_tech && LAZYLEN(I.origin_tech))
		var/best_tech = null
		var/best_level = 0
		for(var/T in I.origin_tech)
			if(I.origin_tech[T] > best_level)
				best_tech = T
				best_level = I.origin_tech[T]
		spectral_reward_corp = get_spectral_tech_corporation(best_tech)

	// ── Set state FIRST so UI renders the game panel ──
	spectral_user = user
	spectral_active = TRUE
	spectral_correct = 0
	spectral_result_text = ""
	spectral_index = 1
	spectral_phase = "playback"

	// Build and play the sequence (async — returns immediately)
	generate_spectral_sequence(I)
	SSnano.update_uis(src)

// ── Build a random colour sequence ──────────────────────────
/obj/machinery/computer/rdconsole/proc/generate_spectral_sequence(obj/item/I)
	var/length = 4
	if(I && I.origin_tech)
		var/total = 0
		for(var/T in I.origin_tech)
			total += I.origin_tech[T]
		if(total >= 15)
			length = 8
		else if(total >= 8)
			length = 6
		else if(total >= 4)
			length = 5

	spectral_sequence = list()
	var/last_color = null
	var/i = 1
	while(i <= length)
		var/c = pick("red", "green", "blue", "yellow")
		while(c == last_color)
			c = pick("red", "green", "blue", "yellow")
		spectral_sequence += c
		last_color = c
		i++

	// Kick off asynchronous playback
	play_simon_sequence()

// ── Async playback: flashes each colour in turn ─────────────
/obj/machinery/computer/rdconsole/proc/play_simon_sequence()
	set waitfor = FALSE          // returns to caller immediately

	spectral_phase = "playback"
	spectral_flash = null
	SSnano.update_uis(src)
	sleep(5)                     // brief pause before first flash

	for(var/i = 1; i <= LAZYLEN(spectral_sequence); i++)
		if(!spectral_active)     // cancelled mid-playback
			return
		// gap between flashes (distinguishes repeated colours)
		spectral_flash = null
		SSnano.update_uis(src)
		sleep(3)
		// flash
		spectral_flash = spectral_sequence[i]
		SSnano.update_uis(src)
		sleep(10)

	if(!spectral_active)
		return

	// Playback done — let the player press buttons
	spectral_flash = null
	spectral_phase = "input"
	SSnano.update_uis(src)

/obj/machinery/computer/rdconsole/power_change()
	. = ..()
	if(. && (stat & MACHINE_STAT_NOPOWER))
		if(linked_destroy)
			linked_destroy.interrupt_busy_operation()
		else
			cancel_spectral()
			cancel_catalog()

// ── Handle a button press from the player ───────────────────
/obj/machinery/computer/rdconsole/proc/do_spectral_step(mob/living/user, chosen_color)
	if(!spectral_active)
		return
	if(spectral_phase != "input")
		return
	if(!linked_destroy)
		cancel_spectral()
		return
	if(!LAZYLEN(spectral_sequence))
		cancel_spectral()
		return

	var/expected = spectral_sequence[spectral_index]

	if(chosen_color != expected)
		spectral_result_text += "<span class='bad'>Ошибка на шаге [spectral_index]/[LAZYLEN(spectral_sequence)]: ожидалось [expected].</span><br>"
		finish_spectral(user)
		return

	// Correct
	spectral_correct++
	spectral_result_text += "<span class='good'>Шаг [spectral_index]/[LAZYLEN(spectral_sequence)]: [chosen_color] — верно.</span><br>"
	spectral_index++

	if(spectral_index > LAZYLEN(spectral_sequence))
		finish_spectral(user)
		return

	SSnano.update_uis(src)

// ── Finish analysis & grant reputation ──────────────────────
/obj/machinery/computer/rdconsole/proc/finish_spectral(mob/living/user)
	if(!linked_destroy)
		cancel_spectral()
		return

	var/total_rep = spectral_correct
	if(spectral_correct >= LAZYLEN(spectral_sequence))
		total_rep += 3  // perfect bonus

	var/datum/research/F = get_server_files()
	if(total_rep > 0 && spectral_reward_corp && F)
		F.ChangeCorporationReputation(spectral_reward_corp, total_rep)
		var/corp_name = get_rnd_mission_corporation_name(spectral_reward_corp)
		spectral_result_text += "<br><span class='good'>Анализ завершён. Репутация с [corp_name]: +[total_rep]</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Спектральный анализ завершён. Репутация с [corp_name]: +[total_rep]."))
	else
		spectral_result_text += "<br><span class='average'>Анализ завершён. Недостаточно данных для репутации.</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Спектральный анализ завершён, но данных недостаточно."))

	// Mark type as analyzed & register experiment
	if(linked_destroy.loaded_item && F)
		F.spectral_analyzed_types += linked_destroy.loaded_item.type
		F.experiments.do_research_object(linked_destroy.loaded_item)

	linked_destroy.finish_spectral()
	spectral_active = FALSE
	spectral_phase = null
	spectral_sequence = list()
	spectral_index = 0
	spectral_flash = null
	SSnano.update_uis(src)

// ── Cancel / abort ──────────────────────────────────────────
/obj/machinery/computer/rdconsole/proc/cancel_spectral()
	spectral_active = FALSE
	spectral_phase = null
	spectral_correct = 0
	spectral_result_text = ""
	spectral_reward_corp = null
	spectral_sequence = list()
	spectral_index = 0
	spectral_flash = null
	spectral_user = null
	if(linked_destroy)
		linked_destroy.finish_spectral()
	SSnano.update_uis(src)
