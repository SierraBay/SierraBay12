/*
	Atmospheric Experiment System

	Uses the game's real atmospheric system. Player prepares a gas mixture
	matching a target specification, then submits a gas tank to the R&D Console.

	Flow:
	1. Player starts an atmospheric experiment from the R&D Console
	   → Console picks a random target gas, pressure range, and (for hard tasks) temperature range
	2. Player fills a tank from a canister or atmospheric system with the correct gas
	   at the correct pressure (and optionally temperature)
	3. Player clicks tank on R&D Console (use_tool) to submit
	4. Console reads tank.air_contents and evaluates:
	   - Is the target gas the dominant gas (>50% of moles)?
	   - Is the pressure within the target range?
	   - (Tier 2 only) Is the temperature within the target range?
	   - Purity bonus for higher concentration

	Anti-farm: Each gas type can only be successfully completed once per research datum.
	Target pool has 9 gases across 3 difficulty tiers.
	Corporation rotates with each experiment.

	Tier 0 — common gases, wide pressure range, no temp requirement, +8 rep
	Tier 1 — specific gases, moderate pressure range, no temp requirement, +11 rep
	Tier 2 — exotic gases, tight pressure + temperature requirement, +14 rep
*/

// =====================================================
// Research datum — atmospheric tracking vars
// =====================================================

/datum/research
	/// List of gas IDs that have been successfully submitted (anti-farm)
	var/list/atmos_completed_gases = list()
	/// Is an atmospheric experiment currently active?
	var/atmos_experiment_active = FALSE
	/// Gas ID of the target gas (e.g. "oxygen")
	var/atmos_target_gas = null
	/// Human-readable name of the target gas
	var/atmos_target_gas_name = ""
	/// Target pressure minimum (kPa)
	var/atmos_target_pressure_min = 0
	/// Target pressure maximum (kPa)
	var/atmos_target_pressure_max = 0
	/// Target temperature minimum (K), 0 = no requirement
	var/atmos_target_temp_min = 0
	/// Target temperature maximum (K), 0 = no requirement
	var/atmos_target_temp_max = 0
	/// Difficulty tier (0/1/2)
	var/atmos_target_tier = 0
	/// Total atmospheric experiments attempted
	var/atmos_experiments_done = 0
	/// Cooldown timestamp (world.time) before starting next experiment
	var/atmos_cooldown = 0

// =====================================================
// Atmospheric target pool & helper procs
// =====================================================

/// Returns the full pool of atmospheric experiment targets
/proc/get_atmos_target_pool()
	return list(
		// Tier 0 — common gases, wide pressure ranges, no temp requirement
		list("gas" = GAS_OXYGEN,  "name" = "Кислород",           "tier" = 0),
		list("gas" = GAS_NITROGEN,"name" = "Азот",                "tier" = 0),
		list("gas" = GAS_CO2,     "name" = "Углекислый газ",      "tier" = 0),
		// Tier 1 — specific gases, moderate pressure ranges
		list("gas" = GAS_PHORON,  "name" = "Форон",               "tier" = 1),
		list("gas" = GAS_HYDROGEN,"name" = "Водород",             "tier" = 1),
		list("gas" = GAS_N2O,     "name" = "Закись азота",        "tier" = 1),
		// Tier 2 — exotic gases, narrow ranges + temperature requirement
		list("gas" = GAS_HELIUM,  "name" = "Гелий",               "tier" = 2),
		list("gas" = GAS_BORON,   "name" = "Бор",                 "tier" = 2),
		list("gas" = GAS_CHLORINE,"name" = "Хлор",                "tier" = 2)
	)

/// Generate pressure range for a given tier (returns list("min", "max"))
/proc/get_atmos_pressure_range(tier)
	switch(tier)
		if(0)
			// Wide range: pick a center 200-600, range ±200
			var/center = rand(300, 500)
			return list("min" = center - 200, "max" = center + 200)
		if(1)
			// Moderate range: center 200-500, range ±100
			var/center = rand(250, 450)
			return list("min" = center - 100, "max" = center + 100)
		if(2)
			// Tight range: center 200-500, range ±75
			var/center = rand(250, 450)
			return list("min" = center - 75, "max" = center + 75)
	return list("min" = 100, "max" = 600)

/// Generate temperature range for tier 2 (returns list("min", "max") or null)
/proc/get_atmos_temp_range(tier)
	if(tier < 2)
		return null
	// Random temperature target: cold (200-280K) or warm (320-450K)
	if(prob(50))
		// Cold target
		var/center = rand(220, 260)
		return list("min" = center - 30, "max" = center + 30)
	// Warm target
	var/center = rand(340, 420)
	return list("min" = center - 40, "max" = center + 40)

/// Reputation reward per tier
/proc/get_atmos_tier_reward(tier)
	switch(tier)
		if(0)
			return 3
		if(1)
			return 5
		if(2)
			return 10
	return 8

/// Corporation rotation for atmospheric experiments
/proc/get_atmos_experiment_corporation(experiment_num)
	var/list/corps = list(
		RND_MISSION_CORP_EINSTEIN,
		RND_MISSION_CORP_FOCAL,
		RND_MISSION_CORP_HEPHAESTUS,
		RND_MISSION_CORP_XION,
		RND_MISSION_CORP_GRAYSON,
		RND_MISSION_CORP_AETHER,
		RND_MISSION_CORP_NANOTRASEN,
		RND_MISSION_CORP_WARD_TAKAHASHI,
		RND_MISSION_CORP_MORPHEUS,
		RND_MISSION_CORP_DAIS
	)
	var/index = (experiment_num % length(corps)) + 1
	return corps[index]

/// Tier name for display
/proc/get_atmos_tier_name(tier)
	switch(tier)
		if(0)
			return "Базовый"
		if(1)
			return "Продвинутый"
		if(2)
			return "Экспертный"
	return "?"

/// Pick a random available target gas (skipping already completed)
/proc/generate_atmos_target(datum/research/files)
	var/list/pool = get_atmos_target_pool()
	var/list/available = list()
	for(var/list/entry in pool)
		var/gid = entry["gas"]
		if(!(gid in files.atmos_completed_gases))
			available += list(entry)
	if(!length(available))
		return null
	return pick(available)

// =====================================================
// R&D Console — atmospheric experiment vars & procs
// =====================================================

/obj/machinery/computer/rdconsole
	/// Last atmospheric experiment result text for display
	var/atmos_result_text = ""

/// Start a new atmospheric experiment — picks a random gas target
/obj/machinery/computer/rdconsole/proc/start_atmos_experiment(mob/living/user)
	if(!files)
		return
	if(world.time < files.atmos_cooldown)
		var/remaining = files.atmos_cooldown - world.time
		var/mins = round(remaining / 60, 0.1)
		to_chat(user, SPAN_WARNING("Эксперимент заблокирован, подождите примерно [mins] минут."))
		return
	if(files.atmos_experiment_active)
		to_chat(user, SPAN_WARNING("Атмосферный эксперимент уже активен. Приложите баллон с газом к консоли."))
		return

	var/list/target = generate_atmos_target(files)
	if(!target)
		to_chat(user, SPAN_WARNING("Все доступные газовые смеси уже успешно сданы."))
		return

	var/tier = target["tier"]
	files.atmos_experiment_active = TRUE
	files.atmos_target_gas = target["gas"]
	files.atmos_target_gas_name = target["name"]
	files.atmos_target_tier = tier

	var/list/pressure = get_atmos_pressure_range(tier)
	files.atmos_target_pressure_min = pressure["min"]
	files.atmos_target_pressure_max = pressure["max"]

	var/list/temp_range = get_atmos_temp_range(tier)
	if(temp_range)
		files.atmos_target_temp_min = temp_range["min"]
		files.atmos_target_temp_max = temp_range["max"]
	else
		files.atmos_target_temp_min = 0
		files.atmos_target_temp_max = 0

	atmos_result_text = ""

	to_chat(user, SPAN_NOTICE("Атмосферный эксперимент #[files.atmos_experiments_done + 1] начат!"))
	to_chat(user, SPAN_NOTICE("Цель: [files.atmos_target_gas_name], давление [files.atmos_target_pressure_min]–[files.atmos_target_pressure_max] кПа."))
	if(files.atmos_target_temp_min > 0)
		to_chat(user, SPAN_NOTICE("Температура: [round(files.atmos_target_temp_min - T0C, 1)]–[round(files.atmos_target_temp_max - T0C, 1)] °C."))
	to_chat(user, SPAN_NOTICE("Заполните баллон нужным газом и приложите его к консоли."))

	SSnano.update_uis(src)

/// Cancel the current atmospheric experiment
/obj/machinery/computer/rdconsole/proc/cancel_atmos_experiment()
	if(!files)
		return
	files.atmos_experiment_active = FALSE
	files.atmos_target_gas = null
	files.atmos_target_gas_name = ""
	files.atmos_target_pressure_min = 0
	files.atmos_target_pressure_max = 0
	files.atmos_target_temp_min = 0
	files.atmos_target_temp_max = 0
	files.atmos_target_tier = 0
	files.atmos_cooldown = world.time + 600 // 10 minutes
	atmos_result_text = ""
	SSnano.update_uis(src)

/// Evaluate a gas tank submitted for the atmospheric experiment
/obj/machinery/computer/rdconsole/proc/submit_atmos_tank(mob/living/user, obj/item/tank/T)
	if(!files)
		return
	if(!files.atmos_experiment_active)
		to_chat(user, SPAN_WARNING("Нет активного атмосферного эксперимента. Запустите эксперимент с консоли."))
		return
	if(!T.air_contents)
		to_chat(user, SPAN_WARNING("Баллон не содержит газовой смеси."))
		return

	var/datum/gas_mixture/mix = T.air_contents
	mix.update_values()

	if(mix.total_moles <= 0)
		to_chat(user, SPAN_WARNING("Баллон пуст."))
		return

	var/target_gas = files.atmos_target_gas
	var/target_name = files.atmos_target_gas_name
	var/target_tier = files.atmos_target_tier
	var/max_rep = get_atmos_tier_reward(target_tier)
	var/reward_corp = get_atmos_experiment_corporation(files.atmos_experiments_done)
	var/corp_name = get_rnd_mission_corporation_name(reward_corp)

	// Read mixture data
	var/pressure = mix.return_pressure()
	var/temperature = mix.temperature
	var/target_moles = 0
	if(target_gas in mix.gas)
		target_moles = mix.gas[target_gas]
	var/gas_purity = target_moles / mix.total_moles

	// Evaluate criteria
	var/gas_correct = (gas_purity > 0.5)     // dominant gas
	var/pressure_ok = (pressure >= files.atmos_target_pressure_min && pressure <= files.atmos_target_pressure_max)
	var/temp_ok = TRUE
	var/has_temp_req = (files.atmos_target_temp_min > 0)
	if(has_temp_req)
		temp_ok = (temperature >= files.atmos_target_temp_min && temperature <= files.atmos_target_temp_max)

	// Score
	var/total_rep = 0
	var/result_quality = ""

	if(!gas_correct)
		// Wrong gas dominant
		result_quality = "<span class='bad'>ПРОВАЛ. Газ \"[target_name]\" не является доминирующим в смеси (концентрация: [round(gas_purity * 100)]%).</span>"
		total_rep = 0
	else if(pressure_ok && temp_ok && gas_purity >= 0.8)
		// Perfect
		result_quality = "<span class='good'>ОТЛИЧНО! [target_name]: [round(gas_purity * 100)]%, давление [round(pressure, 1)] кПа"
		if(has_temp_req)
			result_quality += ", температура [round(temperature - T0C, 1)] °C"
		result_quality += ".</span>"
		total_rep = max_rep
	else if(pressure_ok && temp_ok)
		// Good but low purity
		result_quality = "<span class='average'>ХОРОШО. [target_name]: [round(gas_purity * 100)]% — давление и температура в норме, но чистота низкая.</span>"
		total_rep = round(max_rep * 0.7)
	else if(gas_correct && (pressure_ok || temp_ok))
		// Partially correct
		var/issues = ""
		if(!pressure_ok)
			issues += " Давление [round(pressure, 1)] кПа вне диапазона [files.atmos_target_pressure_min]–[files.atmos_target_pressure_max]."
		if(!temp_ok && has_temp_req)
			issues += " Температура [round(temperature - T0C, 1)] °C вне диапазона [round(files.atmos_target_temp_min - T0C, 1)]–[round(files.atmos_target_temp_max - T0C, 1)]."
		result_quality = "<span class='average'>ПРИЕМЛЕМО. Газ верный, но:[issues]</span>"
		total_rep = round(max_rep * 0.5)
	else
		// Gas correct but both pressure and temp wrong
		result_quality = "<span class='bad'>ПРОВАЛ. Газ верный, но параметры полностью не соответствуют заданию.</span>"
		total_rep = 0

	// Build result text
	atmos_result_text = "Эксперимент #[files.atmos_experiments_done + 1]<br>"
	atmos_result_text += "Цель: [target_name], [files.atmos_target_pressure_min]–[files.atmos_target_pressure_max] кПа"
	if(has_temp_req)
		atmos_result_text += ", [round(files.atmos_target_temp_min - T0C, 1)]–[round(files.atmos_target_temp_max - T0C, 1)] °C"
	atmos_result_text += "<br>"
	atmos_result_text += "Результат: давление [round(pressure, 1)] кПа, температура [round(temperature - T0C, 1)] °C<br>"
	atmos_result_text += "Концентрация [target_name]: [round(gas_purity * 100)]%<br><br>"
	atmos_result_text += result_quality

	// Apply reputation reward
	if(total_rep > 0 && reward_corp && files)
		files.ChangeCorporationReputation(reward_corp, total_rep)
		atmos_result_text += "<br><br><span class='good'>Репутация с [corp_name]: +[total_rep]</span>"
		to_chat(user, SPAN_NOTICE("Атмосферный эксперимент завершён! Репутация с [corp_name]: +[total_rep]."))

		// Mark gas as completed (anti-farm)
		files.atmos_completed_gases += target_gas
	else
		atmos_result_text += "<br><br><span class='bad'>Репутация не получена.</span>"
		to_chat(user, SPAN_WARNING("Атмосферный эксперимент завершён. Параметры не соответствуют заданию."))

	// Finalize experiment
	files.atmos_experiments_done++
	files.atmos_experiment_active = FALSE
	files.atmos_target_gas = null
	files.atmos_target_gas_name = ""
	files.atmos_target_pressure_min = 0
	files.atmos_target_pressure_max = 0
	files.atmos_target_temp_min = 0
	files.atmos_target_temp_max = 0
	files.atmos_target_tier = 0
	files.atmos_cooldown = world.time + 1200 // 20 minutes

	SSnano.update_uis(src)
