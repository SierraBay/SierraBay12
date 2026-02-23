/*
	Explosion Experiment System — Real Bomb Testing

	Uses the game's actual bomb-making system (transfer valve "limitka" bombs)
	and the Kinetic Energy Scanner (explosion_watcher) to perform experiments.

	Flow:
	1. Player starts an explosion experiment from the R&D Console
	   → Console generates a target power range (e.g. 15-25)
	   → The experiment is now "active" on this console
	2. Player places an explosion_watcher beacon within ~10 tiles of the test site
	3. Player builds a real bomb (transfer valve + two tanks) and detonates it
	   → The watcher records the explosion power automatically
	4. Player picks up the watcher and uses it on the R&D Console (afterattack)
	   → Console reads the recorded power and evaluates the result
	5. Scoring:
	   - Power within target range → +14 rep (perfect)
	   - Power within ±50% of range → +6 rep (partial)
	   - Power completely off → 0 rep
	   - Power 0 (no explosion) → experiment cancelled

	Target power is randomized per experiment, gets harder as you complete more.
	Corporation is determined by experiment number (cycles through corps).

	Anti-farm: Each completed experiment increases the next target range,
	up to a maximum. The experiment counter persists on the research datum.
*/

// Track explosion experiments completed
/datum/research
	/// Number of explosion experiments completed on this research datum
	var/explosion_experiments_done = 0
	/// Is an explosion experiment currently active?
	var/explosion_experiment_active = FALSE
	/// Target power minimum for the current experiment
	var/explosion_target_min = 0
	/// Target power maximum for the current experiment
	var/explosion_target_max = 0
	/// Timestamp until which new experiments are locked (world.time)
	var/explosion_cooldown = 0

// =====================================================
// Corporation rotation for explosion experiments
// =====================================================

/// Get the reward corporation for a given experiment number (cycles through corps)
/proc/get_explosion_experiment_corporation(experiment_num)
	var/list/corps = list(
		RND_MISSION_CORP_HEPHAESTUS,
		RND_MISSION_CORP_WARD_TAKAHASHI,
		RND_MISSION_CORP_ALMALIKI,
		RND_MISSION_CORP_FOCAL,
		RND_MISSION_CORP_XION,
		RND_MISSION_CORP_NANOTRASEN,
		RND_MISSION_CORP_EINSTEIN,
		RND_MISSION_CORP_KAPPA,
		RND_MISSION_CORP_ZENG_HU,
		RND_MISSION_CORP_DAIS
	)
	var/index = (experiment_num % length(corps)) + 1
	return corps[index]

/// Generate target power range based on number of completed experiments
/proc/get_explosion_target_range(experiments_done)
	// Base range: 5-15, scales up with each experiment done
	// Scaling: +5 min and +5 max per experiment, capped
	var/min_power = 5 + (experiments_done * 5)
	var/max_power = 15 + (experiments_done * 5)
	// Cap at reasonable levels (don't need a station-ender)
	min_power = min(min_power, 40)
	max_power = min(max_power, 60)
	return list("min" = min_power, "max" = max_power)

// =====================================================
// Explosion watcher — enhanced for R&D Console interaction
// =====================================================

// Override afterattack to submit explosion data to R&D console
/obj/item/device/beacon/explosion_watcher/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(istype(target, /obj/machinery/computer/rdconsole))
		var/obj/machinery/computer/rdconsole/console = target
		if(!proximity_flag)
			to_chat(user, SPAN_WARNING("Вы должны быть рядом с консолью."))
			return
		if(last_power > 0)
			to_chat(user, SPAN_NOTICE("[src.name]: зафиксированная мощность взрыва — [last_power]."))
			console.submit_explosion_data(user, last_power)
			return
		else
			to_chat(user, SPAN_WARNING("[src.name]: нет зафиксированных данных о взрывах."))
			return
	return ..()

// =====================================================
// R&D Console — explosion experiment integration
// =====================================================

/obj/machinery/computer/rdconsole
	/// Last explosion experiment result text for display
	var/explosion_result_text = ""

/// Start a new explosion experiment — generates target power range
/obj/machinery/computer/rdconsole/proc/start_explosion_experiment(mob/living/user)
	if(!files)
		return
	// cooldown check
	if(world.time < files.explosion_cooldown)
		var/remaining = files.explosion_cooldown - world.time
		var/mins = round(remaining / 60, 0.1) MINUTES
		to_chat(user, SPAN_WARNING("Эксперимент заблокирован, подождите примерно [mins] минут."))
		return
	if(files.explosion_experiment_active)
		to_chat(user, SPAN_WARNING("Взрывной эксперимент уже запущен. Используйте Kinetic Energy Scanner для сдачи результатов."))
		return

	var/list/target = get_explosion_target_range(files.explosion_experiments_done)
	files.explosion_target_min = target["min"]
	files.explosion_target_max = target["max"]
	files.explosion_experiment_active = TRUE
	explosion_result_text = ""

	to_chat(user, SPAN_NOTICE("Взрывной эксперимент #[files.explosion_experiments_done + 1] начат!"))
	to_chat(user, SPAN_NOTICE("Целевая мощность взрыва: от [files.explosion_target_min] до [files.explosion_target_max]."))
	to_chat(user, SPAN_NOTICE("Разместите Kinetic Energy Scanner вблизи места детонации, соберите и подорвите бомбу, затем приложите сканер к консоли."))

	SSnano.update_uis(src)

/// Cancel the current explosion experiment
/obj/machinery/computer/rdconsole/proc/cancel_explosion_experiment()
	if(!files)
		return
	files.explosion_experiment_active = FALSE
	files.explosion_target_min = 0
	files.explosion_target_max = 0
	files.explosion_cooldown = world.time + 600 // 10 minutes
	explosion_result_text = ""
	SSnano.update_uis(src)

/// Process explosion watcher data submitted to console
/obj/machinery/computer/rdconsole/proc/submit_explosion_data(mob/living/user, power)
	if(!files)
		return
	if(!files.explosion_experiment_active)
		to_chat(user, SPAN_WARNING("Нет активного взрывного эксперимента. Запустите эксперимент с консоли."))
		return
	if(power <= 0)
		to_chat(user, SPAN_WARNING("Сканер не зафиксировал данных о взрыве."))
		return

	var/target_min = files.explosion_target_min
	var/target_max = files.explosion_target_max
	var/target_range = target_max - target_min

	// Evaluate result
	var/total_rep = 0
	var/result_quality = ""
	var/reward_corp = get_explosion_experiment_corporation(files.explosion_experiments_done)
	var/corp_name = get_rnd_mission_corporation_name(reward_corp)

	if(power >= target_min && power <= target_max)
		// Perfect — within target range
		total_rep = 14
		result_quality = "<span class='good'>ОТЛИЧНО! Мощность [power] попала в целевой диапазон [target_min]–[target_max].</span>"
	else
		// How far off are we?
		var/distance
		if(power < target_min)
			distance = target_min - power
		else
			distance = power - target_max

		var/tolerance = target_range * 0.75 // 75% of range width as tolerance

		if(distance <= tolerance)
			// Close enough — partial reward
			total_rep = 6
			result_quality = "<span class='average'>ПРИЕМЛЕМО. Мощность [power] близка к диапазону [target_min]–[target_max] (отклонение: [distance]).</span>"
		else
			// Way off
			total_rep = 0
			if(power > target_max)
				result_quality = "<span class='bad'>ПРОВАЛ. Мощность [power] сильно превышает целевой диапазон [target_min]–[target_max]. Избыточная энергия уничтожила полезные данные.</span>"
			else
				result_quality = "<span class='bad'>ПРОВАЛ. Мощность [power] слишком мала для диапазона [target_min]–[target_max]. Недостаточно данных для анализа.</span>"

	// Build result text
	explosion_result_text = "Эксперимент #[files.explosion_experiments_done + 1]<br>"
	explosion_result_text += "Целевой диапазон: [target_min]–[target_max]<br>"
	explosion_result_text += "Зафиксированная мощность: [power]<br><br>"
	explosion_result_text += result_quality

	// Apply reputation
	if(total_rep > 0 && reward_corp && files)
		files.ChangeCorporationReputation(reward_corp, total_rep)
		explosion_result_text += "<br><br><span class='good'>Репутация с [corp_name]: +[total_rep]</span>"
		to_chat(user, SPAN_NOTICE("Взрывной эксперимент завершён! Репутация с [corp_name]: +[total_rep]."))
	else
		explosion_result_text += "<br><br><span class='bad'>Репутация не получена.</span>"
		to_chat(user, SPAN_WARNING("Взрывной эксперимент завершён. Параметры не соответствуют заданию."))

	// Complete the experiment
	files.explosion_experiments_done++
	files.explosion_experiment_active = FALSE
	files.explosion_target_min = 0
	files.explosion_target_max = 0
	files.explosion_cooldown = world.time + 1200 // 20 minutes

	SSnano.update_uis(src)
