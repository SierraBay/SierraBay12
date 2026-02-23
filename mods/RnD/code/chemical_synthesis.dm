/*
	Chemical Synthesis Experiment

	Uses the game's real chemistry system. Player synthesizes a target reagent
	and submits a beaker (or other reagent container) to the R&D Console.

	Flow:
	1. Player starts synthesis experiment from R&D Console
	   → Console picks a random target reagent and required volume
	2. Player uses chem dispenser and reactions to synthesize the reagent
	3. Player clicks beaker on R&D Console (use_tool) to submit
	4. Console reads beaker contents and evaluates:
	   - Correct reagent present + sufficient volume + high purity → full rep
	   - Correct reagent present but insufficient volume or low purity → partial rep
	   - Wrong/missing reagent → 0 rep

	Anti-farm: Each reagent type can only be successfully completed once per research datum.
	Target pool has 19 reagents across 3 difficulty tiers.
	Corporation rotates with each experiment.

	Tier 0 — simple reactions (all ingredients from chem dispenser), +8 rep
	Tier 1 — one intermediate synthesis step needed, +11 rep
	Tier 2 — multi-step synthesis chain, +14 rep
*/

// =====================================================
// Research datum — synthesis tracking vars
// =====================================================

/datum/research
	/// List of reagent type paths that have been successfully synthesized (anti-farm)
	var/list/synthesis_completed_types = list()
	/// Is a synthesis experiment currently active?
	var/synthesis_experiment_active = FALSE
	/// Type path of the target reagent
	var/synthesis_target_type = null
	/// Human-readable name of the target reagent
	var/synthesis_target_name = ""
	/// Required minimum volume in units
	var/synthesis_target_volume = 0
	/// Difficulty tier of the current target (0/1/2)
	var/synthesis_target_tier = 0
	/// Total number of synthesis experiments attempted
	var/synthesis_experiments_done = 0
	/// Cooldown timestamp (world.time) before starting next experiment
	var/synthesis_cooldown = 0

// =====================================================
// Synthesis target pool & helper procs
// =====================================================

/// Returns the full pool of available synthesis targets
/proc/get_synthesis_target_pool()
	return list(
		// Tier 0 — all ingredients directly from chem dispenser
		list("type" = /datum/reagent/inaprovaline, "name" = "Инапровалин", "tier" = 0),
		list("type" = /datum/reagent/dylovene, "name" = "Диловен", "tier" = 0),
		list("type" = /datum/reagent/kelotane, "name" = "Келотан", "tier" = 0),
		list("type" = /datum/reagent/thermite, "name" = "Термит", "tier" = 0),
		list("type" = /datum/reagent/coolant, "name" = "Хладагент", "tier" = 0),
		list("type" = /datum/reagent/sodiumchloride, "name" = "Хлорид натрия", "tier" = 0),
		list("type" = /datum/reagent/space_cleaner, "name" = "Космоочиститель", "tier" = 0),
		list("type" = /datum/reagent/diethylamine, "name" = "Диэтиламин", "tier" = 0),
		list("type" = /datum/reagent/hyperzine, "name" = "Гиперзин", "tier" = 0),
		// Tier 1 — requires one intermediate synthesis
		list("type" = /datum/reagent/bicaridine, "name" = "Бикаридин", "tier" = 1),
		list("type" = /datum/reagent/tricordrazine, "name" = "Трикордразин", "tier" = 1),
		list("type" = /datum/reagent/opiate/tramadol, "name" = "Трамадол", "tier" = 1),
		list("type" = /datum/reagent/sterilizine, "name" = "Стерилизин", "tier" = 1),
		list("type" = /datum/reagent/hyronalin, "name" = "Гироналин", "tier" = 1),
		list("type" = /datum/reagent/alkysine, "name" = "Алкизин", "tier" = 1),
		// Tier 2 — multi-step synthesis chain
		list("type" = /datum/reagent/paracetamol, "name" = "Парацетамол", "tier" = 2),
		list("type" = /datum/reagent/arithrazine, "name" = "Аритразин", "tier" = 2),
		list("type" = /datum/reagent/ryetalyn, "name" = "Риеталин", "tier" = 2)
	)

/// Reputation reward based on tier
/proc/get_synthesis_tier_reward(tier)
	switch(tier)
		if(0)
			return 2
		if(1)
			return 5
		if(2)
			return 8
	return 8

/// Required volume based on tier (randomized within range)
/proc/get_synthesis_tier_volume(tier)
	switch(tier)
		if(0)
			return rand(10, 15)
		if(1)
			return rand(10, 20)
		if(2)
			return rand(15, 25)
	return 10

/// Corporation rotation for synthesis experiments
/proc/get_synthesis_experiment_corporation(experiment_num)
	var/list/corps = list(
		RND_MISSION_CORP_VEYMED,
		RND_MISSION_CORP_ZENG_HU,
		RND_MISSION_CORP_NANOTRASEN,
		RND_MISSION_CORP_BISHOP,
		RND_MISSION_CORP_AETHER,
		RND_MISSION_CORP_MORPHEUS,
		RND_MISSION_CORP_EINSTEIN,
		RND_MISSION_CORP_HEPHAESTUS,
		RND_MISSION_CORP_FOCAL,
		RND_MISSION_CORP_DAIS
	)
	var/index = (experiment_num % length(corps)) + 1
	return corps[index]

/// Tier name for display
/proc/get_synthesis_tier_name(tier)
	switch(tier)
		if(0)
			return "Простой"
		if(1)
			return "Средний"
		if(2)
			return "Сложный"
	return "?"

/// Pick a random available synthesis target (skipping already completed types)
/proc/generate_synthesis_target(datum/research/files)
	var/list/pool = get_synthesis_target_pool()
	var/list/available = list()
	for(var/list/entry in pool)
		var/rtype = entry["type"]
		if(!(rtype in files.synthesis_completed_types))
			available += list(entry)
	if(!length(available))
		return null
	return pick(available)

// =====================================================
// R&D Console — synthesis experiment vars & procs
// =====================================================

/obj/machinery/computer/rdconsole
	/// Last synthesis result text for display
	var/synthesis_result_text = ""

/// Start a new synthesis experiment — picks a random target reagent
/obj/machinery/computer/rdconsole/proc/start_synthesis_experiment(mob/living/user)
	if(!files)
		return
	if(world.time < files.synthesis_cooldown)
		var/remaining = files.synthesis_cooldown - world.time
		var/mins = round(remaining / 60, 0.1)
		to_chat(user, SPAN_WARNING("Эксперимент заблокирован, подождите примерно [mins] минут."))
		return
	if(files.synthesis_experiment_active)
		to_chat(user, SPAN_WARNING("Эксперимент по синтезу уже активен. Принесите ёмкость с реагентом к консоли."))
		return

	var/list/target = generate_synthesis_target(files)
	if(!target)
		to_chat(user, SPAN_WARNING("Все доступные реагенты уже успешно синтезированы."))
		return

	files.synthesis_experiment_active = TRUE
	files.synthesis_target_type = target["type"]
	files.synthesis_target_name = target["name"]
	files.synthesis_target_tier = target["tier"]
	files.synthesis_target_volume = get_synthesis_tier_volume(target["tier"])
	synthesis_result_text = ""

	to_chat(user, SPAN_NOTICE("Эксперимент по синтезу #[files.synthesis_experiments_done + 1] начат!"))
	to_chat(user, SPAN_NOTICE("Цель: синтезировать [files.synthesis_target_name], минимальный объём: [files.synthesis_target_volume] ед."))
	to_chat(user, SPAN_NOTICE("Используйте химический раздатчик для синтеза. Приложите ёмкость с результатом к консоли."))

	SSnano.update_uis(src)

/// Cancel the current synthesis experiment
/obj/machinery/computer/rdconsole/proc/cancel_synthesis_experiment()
	if(!files)
		return
	files.synthesis_experiment_active = FALSE
	files.synthesis_target_type = null
	files.synthesis_target_name = ""
	files.synthesis_target_volume = 0
	files.synthesis_target_tier = 0
	files.synthesis_cooldown = world.time + 600 // 10 minutes
	synthesis_result_text = ""
	SSnano.update_uis(src)

/// Evaluate a beaker/container submitted for the synthesis experiment
/obj/machinery/computer/rdconsole/proc/submit_synthesis_beaker(mob/living/user, obj/item/reagent_containers/container)
	if(!files)
		return
	if(!files.synthesis_experiment_active)
		to_chat(user, SPAN_WARNING("Нет активного эксперимента по синтезу. Запустите эксперимент с консоли."))
		return
	if(!container.reagents || !length(container.reagents.reagent_list))
		to_chat(user, SPAN_WARNING("Ёмкость пуста."))
		return

	var/target_type = files.synthesis_target_type
	var/target_name = files.synthesis_target_name
	var/target_volume = files.synthesis_target_volume
	var/target_tier = files.synthesis_target_tier
	var/max_rep = get_synthesis_tier_reward(target_tier)
	var/reward_corp = get_synthesis_experiment_corporation(files.synthesis_experiments_done)
	var/corp_name = get_rnd_mission_corporation_name(reward_corp)

	// Analyze beaker contents
	var/found_amount = container.reagents.get_reagent_amount(target_type)
	var/total_volume = container.reagents.total_volume
	var/purity = 0
	if(total_volume > 0)
		purity = found_amount / total_volume

	var/total_rep = 0
	var/result_quality = ""

	if(found_amount <= 0)
		// Target reagent not found
		result_quality = "<span class='bad'>ПРОВАЛ. Реагент \"[target_name]\" не обнаружен в ёмкости.</span>"
		total_rep = 0
	else if(found_amount >= target_volume && purity >= 0.8)
		// Perfect: sufficient volume + high purity
		result_quality = "<span class='good'>ОТЛИЧНО! [target_name]: [round(found_amount, 0.1)] ед. (норма: [target_volume] ед.), чистота: [round(purity * 100)]%.</span>"
		total_rep = max_rep
	else if(found_amount >= target_volume)
		// Sufficient volume but low purity
		result_quality = "<span class='average'>ХОРОШО. [target_name]: [round(found_amount, 0.1)] ед. (норма: [target_volume] ед.), но чистота низкая: [round(purity * 100)]%.</span>"
		total_rep = round(max_rep * 0.7)
	else if(found_amount >= target_volume * 0.5)
		// Partial volume
		result_quality = "<span class='average'>ПРИЕМЛЕМО. [target_name]: [round(found_amount, 0.1)] ед. из [target_volume] ед. требуемых.</span>"
		total_rep = round(max_rep * 0.5)
	else
		// Too little reagent
		result_quality = "<span class='bad'>ПРОВАЛ. [target_name]: только [round(found_amount, 0.1)] ед. — недостаточно (норма: [target_volume] ед.).</span>"
		total_rep = 0

	// Build result text
	synthesis_result_text = "Эксперимент #[files.synthesis_experiments_done + 1]<br>"
	synthesis_result_text += "Цель: [target_name], [target_volume] ед.<br>"
	synthesis_result_text += "Сдано: [round(found_amount, 0.1)] ед. из [round(total_volume, 0.1)] ед. общего объёма<br>"
	synthesis_result_text += "Чистота: [round(purity * 100)]%<br><br>"
	synthesis_result_text += result_quality

	// Apply reputation reward
	if(total_rep > 0 && reward_corp && files)
		files.ChangeCorporationReputation(reward_corp, total_rep)
		synthesis_result_text += "<br><br><span class='good'>Репутация с [corp_name]: +[total_rep]</span>"
		to_chat(user, SPAN_NOTICE("Синтез завершён! Репутация с [corp_name]: +[total_rep]."))

		// Mark reagent type as completed (anti-farm)
		files.synthesis_completed_types += target_type
	else
		synthesis_result_text += "<br><br><span class='bad'>Репутация не получена.</span>"
		to_chat(user, SPAN_WARNING("Результат синтеза не соответствует требованиям."))

	// Finalize experiment
	files.synthesis_experiments_done++
	files.synthesis_experiment_active = FALSE
	files.synthesis_target_type = null
	files.synthesis_target_name = ""
	files.synthesis_target_volume = 0
	files.synthesis_target_tier = 0
	files.synthesis_cooldown = world.time + 1200 // 20 minutes

	SSnano.update_uis(src)
